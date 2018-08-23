classdef experiment < qes.qHandle
    % experiment

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

	properties
        sweeps      % array of sweeps
        measurements    % cell array of measurements
        plotdata@logical scalar = true; % plot live data or not
        datafileprefix % datafile prefix
        notes@char    % character string, any notes
        % save data or not
        savedata@logical scalar = true
        savesnap@logical scalar = false
        % axes for data plot, if not specified, an new axes is created
        showctrlpanel@logical scalar = true; % true(default)/false show dashbord or not
        % true/false(default) save snapshot with data or not
        plotaxes
        % default plot functions are provided for simple data sets, for
        % complex data, custum plotfunctions are needed.
        plotfcn % if empty, default built-in plotfunctions are used.
    end
    properties
        % some times we use an experiment object to save data in a easy way
        % only in very rare cases that the user needs to modify these properties.
        data 
        measurementnames  
        sweepvals
        paramnames
    end
    properties (SetAccess = private)
        settings
        running = false; % true/false: idle/running
        paused = false; %
        log % logging
    end
    properties (SetAccess = private, GetAccess = private)
        % paramnames
        swpmainparam
        % measurementnames
        datapath
        datafilename
        swpidx
        stepidx
        totalsteps
        stepsdone
        starttime % unit: days
        ctrlpanel   % control panel gui handle, empty if disabled(showctrlpanel = false)
        % abort = true: an abort action is pending, waiting for the on
        % going measurement operation to finish to execute
        abort@logical scalar  = false
        % pause = true: a pause action is pending, waiting for the on going
        % measurement operations to finish to execute, default: false(do not change).
        pause@logical scalar = false
		runned = false
    end
    properties (SetAccess = private, GetAccess = private, Hidden = true, SetObservable = true)
        busy = false; % true, experiment is busy: setting instruments, taking data etc.
    end
    properties (SetAccess = private, GetAccess = private, Hidden = true, Dependent = true)
        swpsizes
    end
    events % notify anyone who's interested that the experiment 
        ExperimentStarted  % is running or
        ExperimentStopped  % is stopped
    end
	methods
        function obj = experiment(settingsobj)
            obj = obj@qes.qHandle('');
            if nargin == 0 % if settingsobj not giving, get the existing instance or creat one
                try
                    settingsobj = qes.qSettings.GetInstance();
                catch
                    error('experiment:GetSettingsError','qes.qSettings not created or not conditioned, creat the qes.qSettings object, select user(by using SU) and select session(by using SS) first.');
                end
            end
            if ~isa(settingsobj,'qes.qSettings')
                error('experiment:InvalidInput','settingsobj is not a valid qes.qSettings class object!');
            end
            data_saving_path = settingsobj.loadSSettings('data_path');
            if isempty(data_saving_path) || ~ischar(data_saving_path) 
                error('experiment:InvalidSettings','data_path not set or not valid, check the settings file.');
            end
            if ~exist(data_saving_path,'dir')
                error('experiment:InvalidSettings','datadir ''%s'' not exist, check the settings file.', data_saving_path);
            end
            obj.datapath = data_saving_path;
            obj.sweeps = {};
            obj.measurements = {};

            obj.settings.hw_settings = settingsobj.loadHwSettings();
            obj.settings.session_settings = settingsobj.loadSSettings();
            obj.settings.user = settingsobj.user;
            obj.log.timestamp  = now;
            obj.log.event = {'object creation'};
            addlistener(obj,'busy','PostSet',@qes.experiment.ExePauseAbort);
        end
        function set.sweeps(obj, Sweeps)
            ln = numel(Sweeps);
            for ii = 1:ln
                if ~isa(Sweeps(ii),'qes.sweep') || ~isvalid(Sweeps(ii)) ||...
                     Sweeps(ii).size == 0
                    error('experiment:SetSweeps','At least one of the sweeps is not a valid Sweep class object or has zero sweep size!');
                end
            end
            obj.sweeps = Sweeps;
        end
%         function set.sweeps(obj, Sweeps)
%             if iscell(Sweeps)
%                 for ii = 1:length(Sweeps)
%                     if ~isa(Sweeps{ii},'qes.sweep') || ~isvalid(Sweeps{ii}) ||...
%                          Sweeps{ii}.size == 0
%                         error('experiment:SetSweeps','At least one of the sweeps is not a valid Sweep class object or has zero sweep size!');
%                     end
%                 end
%                 obj.sweeps = Sweeps;
%             else
%                 ln = numel(Sweeps);
%                 temp = cell(1,ln);
%                 for ii = 1:ln
%                     if ~isa(Sweeps(ii),'qes.sweep') || ~isvalid(Sweeps(ii)) ||...
%                          Sweeps(ii).size == 0
%                         error('experiment:SetSweeps','At least one of the sweeps is not a valid Sweep class object or has zero sweep size!');
%                     else
%                         temp(ii) = {Sweeps(ii)};
%                     end
%                 end
%                 obj.sweeps = temp;
%             end
%         end
        function set.measurements(obj, Measurements)
            ln0 = numel(obj.measurements);
            if iscell(Measurements)
                for ii = 1:length(Measurements)
                    if ~isa(Measurements{ii},'Measurement') || ~isvalid(Measurements{ii})
                        error('experiment:SetMeasurements','At least one of the Measurements is not a valid Measurement class object!');
                    end
                end
                obj.measurements = Measurements;
            else
                ln = numel(Measurements);
                temp = cell(1,ln);
                if ln > 1
                    for ii = 1:ln
                        if ~isa(Measurements(ii),'Measurement') || ~isvalid(Measurements(ii))
                            error('experiment:SetMeasurements','At least one of the Measurements is not a valid Measurement class object!');
                        else
                            temp(ii) = {Measurements(ii)};
                        end
                    end
                else % Measurement is now callable
                    if ~isa(Measurements,'qes.measurement.measurement') || ~isvalid(Measurements)
                        error('experiment:SetMeasurements','At least one of the Measurements is not a valid measurement class object!');
                    else
                        temp = {Measurements};
                    end
                end
                obj.measurements = temp;
            end
            if ln0 == numel(obj.measurements)
                return;
            end
            NumMeasurements = numel(obj.measurements);
            %             if NumMeasurements == 0
            %                 error('Experiment:RunError','The number of measurements is zero, need at least one measurement to run an experiment!');
            %             end
              % we assume at least one measurements
            if NumMeasurements == 0
                throw(MException('QOS_experiment:noMeasurement','remove all measurements is not allowed.'));
            end
            obj.data = cell(NumMeasurements,1);
            obj.totalsteps = prod(obj.swpsizes);
            for ii = 1:NumMeasurements
                if obj.measurements{ii}.numericscalardata
                    if length(obj.swpsizes) == 1
                        obj.data{ii} = NaN*ones(obj.swpsizes,1);
                    else
                        obj.data{ii} = NaN*ones(obj.swpsizes);
                    end
                else
                    if length(obj.swpsizes) == 1
                        obj.data{ii} = cell(obj.swpsizes,1);
                    else
                        obj.data{ii} = cell(obj.swpsizes);
                    end
                end
            end
        end
        function set.datafileprefix(obj, val)
			if ~ischar(val) || ~isempty(regexp(val,'[\\/:\*\?"<>\|]', 'once'))
				error('experiment:SetDatafileprefix','not a valid file name!');
			end
            obj.datafileprefix = val;
        end
        function addSettings(obj,fieldNames,vals)
            % add settings to save with data
            if ~iscell(fieldNames)
                fieldNames = {fieldNames};
            end
            if ~iscell(vals)
                fieldNames = {vals};
            end
            if numel(fieldNames) ~= numel(vals)
                error('experiment:inValidInput','fieldNames and vals length not match.');
            end
            for ii = 1:numel(fieldNames)
                % removed for convenience
%                 if ~isvarname(fieldNames{ii})
%                     error('experiment:inValidInput','%s is not a valid field name.', fieldNames{ii});
%                 end
%                 if isfield(obj.settings,fieldNames{ii})
%                     error('experiment:inValidInput','%s already exist in settings, overwriting an existing field is not allowed.', fieldNames{ii});
%                 end
                obj.settings.(fieldNames{ii}) = vals{ii};
            end
        end
        function set.showctrlpanel(obj,val)
            if ~islogical(val)
                if val == 0 || val == 1
                    val = logical(val);
                else
                    error('experiment:SetShowctrlpanel','showctrlpanel should be a bolean!');
                end
            end
            obj.showctrlpanel = val;
            if ~obj.showctrlpanel
                if ~isempty(obj.ctrlpanel) && ishghandle(obj.ctrlpanel)
                    close(obj.ctrlpanel);
                    obj.ctrlpanel = [];
                end
            end
        end
        function set.plotaxes(obj,val)
            if ~isempty(val) && ~ishghandle(val)
                error('experiment:SetPlotAxes','not a axes handle.');
            end
            obj.plotaxes = val;
        end
        function set.plotfcn(obj,val)
            if ~isempty(val) && ~isa(val,'function_handle')
                error('experiment:SetPlotFcn','not a function handle.');
            end
            obj.plotfcn = val;
        end
        function val = get.swpsizes(obj)
            if isempty(obj.sweeps)
                val = [];
                return;
            end
            val = arrayfun(@(x) x.size, obj.sweeps);
        end
        function PlotData(obj)
            if ~obj.plotdata || isempty(obj.data) || isempty(obj.data{1})
                return;
            end
            if isempty(obj.plotaxes) || ~ishghandle(obj.plotaxes)
                h = figure('NumberTitle','off','Name',['QOS | Experiment: ',obj.name],'Color',[1,1,1]);
                warning('off');
                jf = get(h,'JavaFrame');
                jf.setFigureIcon(javax.swing.ImageIcon(...
                im2java(qes.ui.icons.qos1_32by32())));
                warning('on');
                obj.plotaxes = axes('Parent',h);
            end
            hold(obj.plotaxes,'off');
            if ~isempty(obj.plotfcn)
                try
                    feval(obj.plotfcn,obj.data,obj.sweepvals,obj.paramnames,obj.swpmainparam,obj.measurementnames,obj.plotaxes);
                catch ME
                    disp('Plotting failed, the given plot function unable to plot the current data set.');
                    rethrow(ME)
                end
                return;
            end
            NumMeasurements = numel(obj.data);
            switch NumMeasurements
                case 0 % no measurements
                    return;
                case 1 % single measuremts, almost all experiments are of this type
                    try
                        qes.util.plotfcn.OneMeas_Def(obj.data,obj.sweepvals,obj.paramnames,obj.swpmainparam,obj.measurementnames,obj.plotaxes);
                    catch
                        warning('Experiment:PlotFail','unable to plot, data might be too complex, a dedicated plotting function is needed.');
                    end
                case 2
                    warning('Experiment:PlotFail','data might be too complex, a dedicated plotting function is needed.');
                    return;   % todo
                otherwise
                    warning('Experiment:PlotFail','data might be too complex, a dedicated plotting function is needed.');
                    return; % todo
            end
            drawnow;
        end
        function Run(obj)
            % run experiment
            %
            
            if ~obj.IsValid()
                throw(MException('Experiment:InvalidObject',...
                    'The object itself not valid or some of its handle class properties not valid.'));
            end
            if obj.runned
                throw(MException('Experiment:RunnedError',...
                    'This experiment object has been runned already, when finished run, an experiment object releases all occuppied resources to be available for other applications, thus can not run again.'));
            end
            NumSweeps = numel(obj.sweeps);
            if NumSweeps == 0
                throw(MException('Experiment:noSweeps',...
                    'The number of sweeps is zero, needs at least one sweep to run an experiment.'));
            end
            % in case of not the first run, swpidx and stepidx need to be
            % resetted, new datafile should also be created, otherwise the
            % experiment continues from the privious stop point and data
            % will be stored to the datafile of the previous run.
            if obj.showctrlpanel && (isempty(obj.ctrlpanel) ||~ishghandle(obj.ctrlpanel))
                obj.CreateCtrlPanel();
                obj.UpdateProgress();
            end
            obj.Reset();  % Reset sweep idexes etc.

            obj.datafilename = fullfile(obj.datapath,[obj.datafileprefix,...
                datestr(now,'_yymmddTHHMMSS'),num2str(99*rand(1),'%02.0f'),'_.mat']);
%             NumMeasurements = numel(obj.measurements);
%         %             if NumMeasurements == 0
%         %                 error('Experiment:RunError','The number of measurements is zero, need at least one measurement to run an experiment!');
%         %             end
%           % we assume at least one measurements
%             if NumMeasurements > 0
%                 obj.data = cell(NumMeasurements,1);
%                 obj.totalsteps = prod(obj.swpsizes);
%                 for ii = 1:NumMeasurements
%                     if obj.measurements{ii}.numericscalardata
%                         if length(obj.swpsizes) == 1
%                             obj.data{ii} = NaN*ones(obj.swpsizes,1);
%                         else
%                             obj.data{ii} = NaN*ones(obj.swpsizes);
%                         end
%                     else
%                         if length(obj.swpsizes) == 1
%                             obj.data{ii} = cell(obj.swpsizes,1);
%                         else
%                             obj.data{ii} = cell(obj.swpsizes);
%                         end
%                     end
%                 end
%             end
            NumSwps = length(obj.sweeps);
            obj.sweepvals = cell(1,NumSwps);
            obj.swpmainparam = ones(1,NumSwps);
            obj.paramnames = cell(1,NumSwps);
            for ii = 1:NumSwps
                obj.sweepvals{ii} = obj.sweeps(ii).vals;
                obj.paramnames{ii} = obj.sweeps(ii).paramnames;
                obj.swpmainparam(ii) = obj.sweeps(ii).mainparam;
            end
            NumMeasurements = length(obj.measurements);
            for ii = 1:NumMeasurements
                obj.measurementnames{ii} = obj.measurements{ii}.name;
            end
            obj.starttime = now;
            obj.log.timestamp(end+1) = now;
            obj.log.event{end+1} = 'run';
            obj.RunExperiment();
            notify(obj,'ExperimentStopped');
            obj.runned = true;

            if obj.stepsdone == obj.totalsteps % done
                obj.log.timestamp(end+1) = now;
                obj.log.event{end+1} = 'measurement done';
                obj.running = false;
                obj.paused = false;
                
                obj.UpdateProgress(); % status is set within
                warning('off');
                sound(qes.ui.sounds.notify2);
                warning('on');
            end
            if obj.savedata
                obj.SaveData(true);  % during the running process, data is
                                 % saved every 30 seconds. at the end there might be
                                 % some new data points not saved, so do a
                                 % force saving!
            end
            for mObj = obj.measurements
                mObj{1}.delete();
            end
            for swpObj = obj.sweeps
                swpObj.delete();
            end
            if ~isempty(obj.ctrlpanel) && ishghandle(obj.ctrlpanel)
                close(obj.ctrlpanel);  % this crashes matlab some times
            end
        end
        % some times we use an experiment object to save data in a easy way
        function SaveData(obj,force)
            if nargin == 1
                force = false;
            end
            if ~obj.running && ~force
                             % when the process is stopped by 'Abort' rather than process completion, 
                             % the object is reset and data is erased from buffer, do a in this case
                             % SaveData will save an empty cell to disk.
                             % when stopped by process completion, data is
                             % kept is buffer until the next run.
                return;
            end
            persistent LastSavingTime

            if ~force && ~isempty(LastSavingTime) && now - LastSavingTime < 6.9440e-04 % 60 seconds
                return;
            end
            Data = obj.data;
            SweepVals = obj.sweepvals;
            ParamNames = obj.paramnames;
            SwpMainParam = obj.swpmainparam;
            Config = obj.settings;
            Config.measurement_names = obj.measurementnames;
            Config.plotfcn = '';
            Log = obj.log;
            if ~isempty(obj.plotfcn)
                Config.plotfcn = func2str(obj.plotfcn);
            end
            NumSwps = numel(obj.sweeps);
            SwpData = cell(1,NumSwps);
            try
                for nn = 1:NumSwps
                    SwpData{nn} = obj.sweeps(nn).swpdata;
                end
            catch
            end
            Notes = obj.notes;

            maxnumtries = 5;
            for ii = 1: maxnumtries
                try
                    save(obj.datafilename,'SweepVals','ParamNames','SwpMainParam','Data','SwpData','Notes','Config','Log');
                catch
                    if ii < 5
                        continue;
                    end
                     % this happens when some other program(a backup software for example) is accessing the datafile,
                     % it is not problem if it dose not happen constantly.
                    warning('Experiment:SaveDataFail',[datestr(now,'dd mmm HH:MM:SS'),10,'Uable to save datafile.']);
                end
            end
            LastSavingTime = now;
        end
        function bol = IsValid(obj)
            % check the validity of hanlde properties and the object itself
            if ~isvalid(obj)
                bol = false;
                return;
            end
            bol = true;
            for ii = 1:length(obj.sweeps)
                if ~IsValid(obj.sweeps(ii)) 
                    bol = false;
                    return;
                end
            end
            for ii = 1:length(obj.measurements)
                if ~IsValid(obj.measurements{ii})
                    bol = false;
                    return;
                end
            end
        end
        function delete(obj)
            if ~isempty(obj.ctrlpanel) && ishghandle(obj.ctrlpanel)
                if ~isempty(obj.plotaxes) && ishghandle(obj.plotaxes)
                    close(get(obj.plotaxes,'parent'));
                end
                close(obj.ctrlpanel);  % this crashes matlab some times
            end
        end
    end
    methods (Access = private, Hidden = true)
        function RunExperiment(obj)
            % This is a private method, call public method Run to run an experiment.
            %
            notify(obj,'ExperimentStarted'); % this has to be here, not outside this function.
            obj.running = true; % running
            NumSweeps = numel(obj.sweeps);
            persistent lastprogundationtime
            if isempty(lastprogundationtime)
                lastprogundationtime  = now;
            end
            persistent lastplottime
            if isempty(lastplottime)
                lastplottime  = now;
            end
            obj.UpdateProgress();
            obj.PlotData();
            while obj.swpidx > 0
                if obj.sweeps(obj.swpidx).IsDone()
                    obj.sweeps(obj.swpidx).Reset();
                    obj.stepidx(obj.swpidx) = obj.sweeps(obj.swpidx).idx;
                    obj.swpidx = obj.swpidx - 1;
                    continue;
                end
                obj.busy = true;
                if obj.abort
                    return;
                end
                obj.stepidx(obj.swpidx) =  obj.sweeps(obj.swpidx).idx;
                obj.sweeps(obj.swpidx).Step();
                if obj.swpidx < NumSweeps
                    obj.swpidx = obj.swpidx + 1;
                    continue;
                end
                % Run measurements
				% measurements can be changed dynamically, for example:
				% it might be that measurements are not set at the creation of the experiment because
				% the properties of some measurements are dependent on the sweep parameters or dynamicall
				% created during the sweep.
				% number of measurements can not change though.
				NumMeasurements = numel(obj.measurements); 
                for ii = 1:NumMeasurements
                    obj.measurements{ii}.Run();
                end
                % Get data
                for ii = 1:NumMeasurements
                    tic;
                    while 1
                        if obj.measurements{ii}.dataready || toc > obj.measurements{ii}.timeout
                            idx = sub2ind_(size(obj.data{ii}),obj.stepidx);
                            obj.stepsdone = obj.stepsdone + 1;
                            if obj.measurements{ii}.numericscalardata
                                obj.data{ii}(idx) = obj.measurements{ii}.data;
                            else
                                obj.data{ii}(idx) =  {obj.measurements{ii}.data};
                            end
                            break;
                        end
                        pause(0.05);
                    end
                end
               % save data
               if obj.savedata
                   obj.SaveData(); % call SaveData without extra arguments will save data once
                                   % at most every 30 seconds, this is to avoid too much
                                   % disc I/O, which might be considerably slow.
               end
               if obj.showctrlpanel && (isempty(obj.ctrlpanel) ||~ishghandle(obj.ctrlpanel))
                     obj.CreateCtrlPanel();
               end
               obj.busy = false;
               if now - lastprogundationtime > 5.7870e-05 % 5 seconds
                    obj.UpdateProgress();
                    lastprogundationtime = now;
               end
               if now - lastplottime > 5.7870e-05 % 5 seconds
                    obj.PlotData();
                    lastplottime = now;
               end
               % plot data

               if obj.paused || ~obj.running
                   return;
               end
            end
            obj.UpdateProgress();
            obj.PlotData();

            function ndx = sub2ind_(siz,subindx)
                % a modification of Matlab SUB2IND.
                siz = double(siz);
                lensiz = length(siz);
                if lensiz < 2
                    error(message('MATLAB:sub2ind_:InvalidSize'));
                end

                numOfIndInput = length(subindx);
                if lensiz < numOfIndInput
                    %Adjust for trailing singleton dimensions
                    siz = [siz, ones(1,numOfIndInput-lensiz)];
                elseif lensiz > numOfIndInput
                    %Adjust for linear indexing on last element
                    siz = [siz(1:numOfIndInput-1), prod(siz(numOfIndInput:end))];
                end

                if numOfIndInput == 2

                    v1 = subindx(1);
                    v2 = subindx(2);
                    if ~isequal(size(v1),size(v2))
                        %Verify sizes of subscripts
                        error('SubscriptVectorSize');
                    end
                    if any(v1(:) < 1) || any(v1(:) > siz(1)) || ...
                       any(v2(:) < 1) || any(v2(:) > siz(2))
                        %Verify subscripts are within range
                        error('IndexOutOfRange');
                    end
                    %Compute linear indices
                    ndx = v1 + (v2 - 1).*siz(1);

                else
                    %Compute linear indices
                    k = [1 cumprod(siz(1:end-1))];
                    ndx = 1;
                    s = size(subindx(1)); %For size comparison
                    for i = 1:numOfIndInput
                        v = subindx(i);
                        %%Input checking
                        if ~isequal(s,size(v))
                            %Verify sizes of subscripts
                            error('SubscriptVectorSize');
                        end
                        if (any(v(:) < 1)) || (any(v(:) > siz(i)))
                            %Verify subscripts are within range
                            error('IndexOutOfRange');
                        end
                        ndx = ndx + (v-1)*k(i);
                    end
                end
            end

        end
        function CreateCtrlPanel(obj)
            % Experiment control panel
            
            h = findall(0,'tag',['QOS | Experiment | Control Panel',obj.name]);
            if ~isempty(h)
                figure(h);
                set(h,'Visible','on');
                obj.ctrlpanel = h;
                return;
            end

            BkGrndColor = [1,1,1];
            scrsz = get(0,'ScreenSize');
            MessWinWinSz = [0.35,0.425,0.3,0.10];
            rw = 1440/scrsz(3);
            rh = 900/scrsz(4);
            MessWinWinSz(3) = rw*MessWinWinSz(3);
            MessWinWinSz(4) = rh*MessWinWinSz(4);
            % set the window position on the center of the screen
            MessWinWinSz(1) = (1 - MessWinWinSz(3))/2;
            MessWinWinSz(2) = (1 - MessWinWinSz(4))/2;

            obj.ctrlpanel = figure('Menubar','none','NumberTitle','off','Units','normalized ','Position',MessWinWinSz,...
                    'Name',['QOS | Experiment: ',obj.name,' | Control Panel'],'Color',BkGrndColor,...
                    'tag',['QOS|Experiment|Ctrlpanel',obj.name],'resize','off',...
                    'HandleVisibility','callback','CloseRequestFcn',{@CtrlpanelClose});
            warning('off');
            jf = get(obj.ctrlpanel,'JavaFrame');
            jf.setFigureIcon(javax.swing.ImageIcon(...
                im2java(qes.ui.icons.qos1_32by32())));
            warning('on');
            handles.obj = obj;
            handles.CtrlpanelWin = obj.ctrlpanel; 
            panel = uipanel('parent',obj.ctrlpanel,'Position',[0.025,0.425,0.95,0.60],...
                'BackgroundColor',BkGrndColor,'BorderType','none');
        %    handles.ProgressBar = waitbar2a(0,panel,'BarColor',[1 0 0; 0 1 0]); % varied color
            handles.ProgressBar = qes.ui.waitbar2a(0,panel,'BarColor',[0.694,0.839,0.196]);
            handles.AbortRunButton = uicontrol('Parent', obj.ctrlpanel,...
                'Style','Pushbutton','Foreg',[1,0,0],'String','Run/Abort',...
                  'FontUnits','normalized','Fontsize',0.5,'FontWeight','bold',...
                  'Units','normalized',...
                  'Tooltip','Run the experiment if idle, abort the experiment if running.',...
                  'Position',[0.075,0.1,0.40,0.3],'Callback',{@AbortFunc});
            handles.PauseButton = uicontrol('Parent', obj.ctrlpanel,...
                'Style','Pushbutton','String','Pause/Resume',...
                  'FontUnits','normalized','Fontsize',0.5,'FontWeight','bold',...
                  'Units','normalized',...
                  'Tooltip','Pause or resume the running experiment(has a lag, do not click repeatedly.).',...
                  'Position',[0.525,0.1,0.40,0.3],'Callback',{@PauseFunc});
           guidata(obj.ctrlpanel,handles);
           obj.UpdateProgress();

           function AbortFunc(hObject,eventdata)
                % handles = guidata(hObject);
                if handles.obj.running
                    choice = questdlg(...
                        'This will stop the experiment objet and erase data, please confirm:',...
                        'Confirm Abort','Yes','Cancel','Cancel');
                else
                    choice = questdlg(...
                        'Run the experiment, please confirm:',...
                        'Confirm Run','Yes','Cancel','Cancel');
                end
                switch choice
                    case 'Yes'
                        if handles.obj.running
                            handles.obj.abort = true;
                            if handles.obj.paused % abort action only excecuted when experiment is running.
                                handles.obj.RunExperiment();
                            end
                        else
                            handles.obj.Run();
                        end
                    otherwise
                        return;
                end
            end

            function PauseFunc(hObject,eventdata)
                % handles = guidata(hObject);
                if ~handles.obj.running
                    return;
                end
                if ~handles.obj.paused % running
                    handles.obj.pause = true; % submit a pause request
                else
                    handles.obj.paused = false; % order of these two lines is important!
                    handles.obj.log.timestamp(end+1) = now;
                    handles.obj.log.event{end+1} = 'resume measurement';
                    handles.obj.RunExperiment(); % continue running the experiment.
                end
            end

            function CtrlpanelClose(hObject,eventdata)
                % handles = guidata(hObject);
                if isstruct(handles) && isa(handles.obj,'Experiment') && isvalid(handles.obj)
                    handles.obj.ctrlpanel = [];
                end
                delete(gcbf);
            end
        end
        function UpdateProgress(obj)
        %
            str1 = '';
            if isempty(obj.stepidx)
                 obj.stepidx = zeros(1,numel(obj.sweeps));
            end
            for ii = 1:length(obj.swpsizes)
                tempstr = sprintf('Sweep %d: %d of %d', ii,obj.stepidx(ii),obj.swpsizes(ii));
                str1 = [str1,tempstr, ' | '];
            end
            if isempty(obj.starttime)
                Progress = 0;
                str2 = 'Idle';
            elseif obj.stepsdone == 0
                Progress = 0;
                if obj.paused
                    str2 = ['Paused'];
                else
                    str2 = ['Running'];
                end
            else
                Progress = obj.stepsdone/obj.totalsteps;
                str2 = [num2str(100*Progress,'%0.0f'), '%,'];
                TimeTaken = now - obj.starttime; % days
                TimeLeft = (obj.totalsteps-obj.stepsdone)/obj.stepsdone*TimeTaken*24;
                hh = floor(TimeLeft);
                mm = round(60*mod(TimeLeft,1));
                if obj.paused
                    str2 = ['Paused: ',str2,'   ',...
                        num2str(hh,'%0.0f'), ' hr ',num2str(mm,'%0.0f'),' min left'];
                else
                    str2 = ['Running: ',str2,'   ',...
                        num2str(hh,'%0.0f'), ' hr ',num2str(mm,'%0.0f'),' min left'];
                end
            end
            if obj.stepsdone == obj.totalsteps
                str2 = 'Done!';
            end
            if isempty(obj.ctrlpanel) ||~ishghandle(obj.ctrlpanel) % no ctrlpanel, print to command window
                home();
                disp(['Experiment[',obj.name,'] ',str1]);
                disp(str2);
            else
                ProgressInfoStr = str2;
                handles = guidata(obj.ctrlpanel);
                qes.ui.waitbar2a(Progress, handles.ProgressBar,ProgressInfoStr);
            end
        end
        function Reset(obj)
            % Reset a running process. only to be called privatly.
            obj.swpidx = 1;
            obj.stepidx = zeros(1,numel(obj.sweeps));
            for ii = 1:length(obj.sweeps)
                obj.sweeps(ii).Reset();
            end
            for ii = 1:length(obj.measurements)
                obj.measurements{ii}.Abort();
            end
            obj.stepsdone = 0;
            obj.starttime = [];
            obj.running = false; % idle
            obj.abort = false; % clear pending status
            obj.pause = false; % clear pending status
            obj.paused = false;
            obj.UpdateProgress();
            obj.log.timestamp  = now;
            obj.log.event = {'rest'}; % log also cleared
        end
    end
    methods (Static = true, Access = protected, Hidden = true)
        function ExePauseAbort(metaProp,eventData)
            % execute pending abort or pause action
            obj = eventData.AffectedObject;
            if isempty(obj.busy) || obj.busy
                return;
            end
            if obj.abort % abort shadows pause
                obj.log.timestamp(end+1) = now;
                obj.log.event{end+1} = 'abort';
                SaveData(obj,1);
                obj.Reset();
                obj.abort = false; % clear pending status
            elseif obj.pause
                obj.log.timestamp(end+1) = now;
                obj.log.event{end+1} = 'pause';
                obj.paused = true;
                obj.pause = false; % clear pending status
            end
        end
    end
end