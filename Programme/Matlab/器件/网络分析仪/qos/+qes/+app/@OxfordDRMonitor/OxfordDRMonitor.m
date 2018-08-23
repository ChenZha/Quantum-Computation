classdef OxfordDRMonitor < handle
    % Monitor of Oxford dilution fridges.

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com
    properties
        checkinterval = 30; % seconds
        notify = true;
        notifyinterval = 60; % minutes % todo, add a set method
        
        notifier % push notification object
        process = 1 % 1/2/3/4 idle/base temperature/warming up/cooling down, default = 1
        
        maxbasetemp = 35e-3 % maximum base temperature, K
        mintankpres = 0.80 % minmum tank pressure, bar
        maxptcwitemp = 30 % maximum pulse tube compressure cooling water inlet temperature, C
        maxptcwotemp = 45 % maximum pulse tube compressure cooling water outlet temperature, C
    end
    properties (SetAccess = private)
        fridgeobj
        datadir
    end
    properties (SetAccess = private, GetAccess = private)
        timerobj % dilution fridge query schedulor
        restartcount = 0; % times of restart tries
        datarsvtimerobj % data resave schedulor
        alarmobj % alarm player, a timer object
        starttime % monitor creation time
        
        m % matfile data object
        time % data time stamp
        temperature % array, temperature of all temperature channels, K
        tempres % array, resistance of all temperature channels, Ohm
        tempchnl % cell, name of temperature channels to read/set, if empty, read/set all channels
        pressure % array, presurre of all pressure channels, bar
        preschnl % cell, name of preschnl channels to read or set, if empty, read/set all channels
        ptcstatus@logical % string, pulse tube compressor status
        ptcwit % pulse tube compressor cooling water inlet termperature
        ptcwot % pulse tube compressor cooling water outlet termperature
        eventtime % event time stamp
        event % event log
        
        dpoint % data point
        dlen % length of data
        
        numtempchnls
        npreschls
        tempchnlnames
        preschlnames
        temperatureax %
        pressureax
        ptcwax
        
        parent % gui parent figure
        uihandles
        
        password = 'Sub10mK'; % to do, add a set method
    end
    methods (Access = private)
        function obj = OxfordDRMonitor(Fridge)
            % Fridge, OxfordDR class object
            DLen = 200000;
            obj.starttime = now;
            if ~isa(Fridge,'OxfordDR')
                error('DRMonitor:ConstructorError','Fridge is not a OxfordDR class object.');
            end
            obj.fridgeobj = Fridge;
            obj.numtempchnls = numel(obj.fridgeobj.tempnamelst);
            obj.npreschls = numel(obj.fridgeobj.presnamelst);
            obj.tempchnlnames = obj.fridgeobj.tempnamelst;
            obj.preschlnames = obj.fridgeobj.presnamelst;
            if ~isvarname(obj.fridgeobj.name)
                warning('DRMonitor:AbnormalFridgeName','Name of the fridge is not a legal variable name.');
                FridgeName = 'Unknown';
            else
                FridgeName = obj.fridgeobj.name;
            end
            choice  = questdlg('Append data to an existing datafile?','Data saving method','Append to existing','Create a new datafile','Create a new datafile');
            CreateNewDataFile = false;
            if ~isempty(choice) && strcmp(choice, 'Append to existing')
                [datafilename,pathname,~] = uigetfile('*.mat','Select an existing datafile');
                if ischar(datafilename)
                    datafilefullname = fullfile(pathname,datafilename);
                    obj.datadir = pathname;
                    try
                        OxfordDRMonitor.ResaveData([],[],datafilefullname);
                        obj.m = matfile(datafilefullname,'Writable', true);
                        fridgename = obj.m.fridgename;
                        if strcmp(fridgename,obj.fridgeobj.name)
                            obj.time = obj.m.time;
                            obj.temperature =  obj.m.temperature;
                            obj.tempres =  obj.m.tempres;
                            obj.tempchnl = obj.m.tempchnl;
                            obj.pressure = obj.m.pressure;
                            obj.preschnl = obj.m.preschnl;
                            obj.ptcstatus = obj.m.ptcstatus;
                            obj.ptcwit = obj.m.ptcwit;
                            obj.ptcwot = obj.m.ptcwot;
                            obj.eventtime = obj.m.eventtime;
                            obj.event = obj.m.event;
                            obj.dpoint = obj.m.dpoint;
                            obj.dlen = length(obj.time);
                        else
                            MessageDisp(['The selected datafile fridge name ''', fridgename,...
                                ''' is different from the current fridge name ''',...
                                obj.fridgeobj.name,'''. Data will be saved to a new datafile.']);
                            CreateNewDataFile = true;
                        end
                    catch
                        MessageDisp(['Unrecognized data format or datafile corrupted, data file will be saved to a new data file.']);
                        CreateNewDataFile = true;
                    end
                else
                    CreateNewDataFile = true;
                end
            else
                CreateNewDataFile = true;
            end
            if CreateNewDataFile
                fldr = uigetdir(pwd,'Select a directory to save monitor data:');
                if ~ischar(fldr) || ~isdir(fldr)
                    error('DRMonitor:ConstructorError','Monitor data directory not selected.');
                end
                obj.datadir = fldr;
                datafilename = ['DR_',FridgeName,'_',datestr(now,'yymmddTHHMMSS'),num2str(99*rand(1,1),'%02.0f'),'.mat'];
                datafilefullname = fullfile(fldr,datafilename);
                % note: though freely enlarging matrix dimmention is allowed in
                % matlab it is not a good programming habit, it brings down
                % performance.
                % pre allocation is very important in writing to disk, 
                % otherwise the resulting datafile can take more than 100 times
                % of disk space than ordinary saving, dramatically dragging
                % down disk I/O.
                time = NaN*zeros(DLen,1);
                temperature =  NaN*zeros(DLen, obj.numtempchnls); % array, temperature of all temperature channels, K
                tempres =  NaN*zeros(DLen, obj.numtempchnls); % array, resistance of all temperature channels, Ohm
                tempchnl = obj.fridgeobj.tempnamelst; % cell, name of temperature channels
                pressure = NaN*zeros(DLen, obj.npreschls); % array, presurre of all pressure channels, bar
                preschnl = obj.preschlnames; % cell, name of preschnl channels to read or set, if empty, read/set all channels
                ptcstatus = logical(zeros(DLen, 1)); % string, pulse tube compressor status
                ptcwit = NaN*zeros(DLen,1); % pulse tube compressor cooling water inlet termperature
                ptcwot = NaN*zeros(DLen,1); % pulse tube compressor cooling water outlet termperature
                dpoint = 0;
                fridgename = obj.fridgeobj.name;
                eventtime = [];
                event = {};
                try
                    save(datafilefullname,'fridgename','time','temperature','tempchnl','tempres','pressure',...
                        'preschnl','ptcstatus','ptcwit','ptcwot','dpoint','eventtime','event','-v7.3');
                catch
                    error('DRMonitor:ConstructorError','Unable to create a new datafile on disk.');
                end
                obj.m = matfile(datafilefullname,'Writable', true);
                obj.time = time;
                obj.temperature = temperature;
                obj.tempres = tempres;
                obj.pressure = pressure;
                obj.ptcstatus = obj.ptcstatus;
                obj.ptcwit = ptcwit;
                obj.ptcwot = ptcwot;
                obj.dpoint = 0;
                obj.dlen = DLen;
                obj.eventtime = eventtime;
                obj.event = event;
            end
            obj.timerobj = timer('ExecutionMode','fixedRate','BusyMode','drop',...
                        'Period',obj.checkinterval,'TimerFcn',{@OxfordDRMonitor.DRRead,obj},...
                        'ErrorFcn',{@OxfordDRMonitor.Restart,obj},...
                        'ObjectVisibility','off');
            start(obj.timerobj);
            obj.eventtime(end+1) = now;
            obj.event(end+1) = {'Monitor started.'};
            obj.datarsvtimerobj = timer('ExecutionMode','fixedRate','BusyMode','queue',...
                        'Period',36000,'TimerFcn',{@OxfordDRMonitor.ResaveData,datafilefullname},...
                        'ErrorFcn',{},'ObjectVisibility','off');
            start(obj.datarsvtimerobj);
            if ~isempty(obj.notifier)
                obj.notifier.title = [obj.fridgeobj.name,' Important!'];
                obj.notifier.message = [datestr(now,'dd mmm, HH:MM:SS'),10,'Monitor started.'];
                obj.notifier.priority = 0;
                obj.notifier.timestamp = [];
                obj.notifier.Push();
            end
            obj.alarmobj = timer('ExecutionMode','fixedDelay','BusyMode','drop',...
                        'Period',0.5,'TimerFcn',{@OxfordDRMonitor.Alarm},...
                        'ErrorFcn',{},'ObjectVisibility','off');
            sound(sounds.notify2);
        end
    end
    methods
        function set.checkinterval(obj, val)
            if ~isnumeric(val) || ~(val  > 0)
                error('DRMonitor:SetError','checkinterval is not a positive number.');
            end
            if val < 5
                warning('DRMonitor:SetWarning','checkinterval set to 5 seconds(minimum).');
                val = 5;
            end
            obj.checkinterval = val;
        end
        function set.notifier(obj, val)
            % todo...
            obj.notifier = val;
        end
        function RestoreAxesRange(obj)
            XLim = [obj.time(1),obj.time(obj.dpoint)+min(1,0.3*(obj.time(obj.dpoint)-obj.time(1)))];
            t = obj.temperature(:);
            t = t(~isnan(t));
            TempYLim = [min(t),max(t)];
            if isempty(TempYLim)
                TempYLim = [2e-3,350];
            end
            p = obj.pressure(:);
            p = p(~isnan(p));
            PresYLim = 1000*[min(p),max(p)];
            if isempty(PresYLim)
                PresYLim = [1e-5,5e3];
            end
            set(obj.temperatureax,'XLim',XLim,'YLim',TempYLim);
            set(obj.pressureax,'XLim',XLim,'YLim',PresYLim);
            obj.Chart();
        end
        function delete(obj)
            if ~isempty(obj.timerobj) && isobject(obj.timerobj) && isvalid(obj.timerobj)
                stop(obj.timerobj);
                delete(obj.timerobj);
            end
            if ~isempty(obj.datarsvtimerobj) && isobject(obj.datarsvtimerobj) && isvalid(obj.datarsvtimerobj)
                stop(obj.datarsvtimerobj);
                delete(obj.datarsvtimerobj);
            end
            if ~isempty(obj.alarmobj) && isobject(obj.alarmobj) && isvalid(obj.alarmobj)
                stop(obj.alarmobj);
                delete(obj.alarmobj);
            end
            if ~isempty(obj.notifier)
                obj.notifier.title = [obj.fridgeobj.name,' Important!'];
                obj.notifier.message = [datestr(now,'dd mmm, HH:MM:SS'),10,'Monitor exit.'];
                obj.notifier.priority = 0;
                obj.notifier.timestamp = [];
                obj.notifier.Push();
            end
            obj.eventtime(end+1) = now;
            obj.event(end+1) = {'Exit'};
            obj.m.eventtime = obj.eventtime;
            obj.m.event = obj.event;
            sound(sounds.du);
        end
    end
    methods (Access = private, Hidden = true)
        function ExpandDataCapacity(obj)
            DLen = 100000;
            datafilefullname = obj.m.Properties.Source;
            load(datafilefullname);
            time = [time;NaN*zeros(DLen,1)];
            temperature =  [temperature;NaN*zeros(DLen, obj.numtempchnls)]; % array, temperature of all temperature channels, K
            tempres =  [tempres; NaN*zeros(DLen, obj.numtempchnls)]; % array, resistance of all temperature channels, Ohm
            pressure = [pressure; NaN*zeros(DLen, obj.npreschls)]; % array, presurre of all pressure channels, bar
            ptcstatus = [ptcstatus; logical(zeros(DLen, 1))]; % string, pulse tube compressor status
            ptcwit = [ptcwit; NaN*zeros(DLen,1)]; % pulse tube compressor cooling water inlet termperature
            ptcwot = [ptcwot; NaN*zeros(DLen,1)]; % pulse tube compressor cooling water outlet termperature
            save(datafilefullname,'fridgename','time','temperature','tempchnl','tempres','pressure',...
                        'preschnl','ptcstatus','ptcwit','ptcwot','dpoint','eventtime','event','-v7.3');
            obj.time = time;
            obj.temperature = temperature;
            obj.tempres = tempres;
            obj.pressure = pressure;
            obj.ptcstatus = obj.ptcstatus;
            obj.ptcwit = ptcwit;
            obj.ptcwot = ptcwot;
            obj.dlen = length(time);
        end
        CreateGUI(obj);
        Chart(obj)
        StatusChk(obj)
        [AlertLvl, Msg] = Chk_OxfordDR400_55084(obj)
    end
    methods (Static  = true)
        obj = GetInstance(FridgeObj)
    end
    methods (Static = true, Hidden = true)
        DRRead(hObject,eventdata,obj)
        ResaveData(hObject,eventdata,datafilefullname)
        Restart(hObject,eventdata,obj)
        function Alarm(hObject,eventdata)
            sound(sounds.siren);
        end
    end
end