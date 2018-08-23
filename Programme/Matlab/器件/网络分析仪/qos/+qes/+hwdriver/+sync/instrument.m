classdef (Abstract = true) instrument < qes.hwdriver.hardware
    % base class for interface based hardware - gpib, tcpip, udp, i2c,
    % bluetooth, visa etc.
    % instrument classes only implement frequently used instrument
    % properties and functionalities so as to provide a unified 
    % interface for a category of instruments.
    % For example, AWG tries to implement common functionalities of all 
    % kinds of awgs and DACs, ignores most model specific properties
    % and functionalities. To use those model specific properties and
    % functionalities, develop a coustom driver class to implement
    % those properties and functionalities, add it as advdriver
    % property of a instrument class object.

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties (SetAccess = immutable, GetAccess = protected)
        % string, driver type, this property is use to identify which driver to be used
        drivertype@char
    end
    properties
        timeout = Inf
        % instrument classes only implement frequently used instrument
        % properties and functionalities so as to provide a unified 
        % interface for a category of instruments.
        % For example, AWG tries to implement common functionalities of all 
        % kinds of awgs and DACs, ignores most model specific properties
        % and functionalities. To use those model specific properties and
        % functionalities, develop a coustom driver class to implement
        % those properties and functionalities, add it as advdriver
        % property of a instrument class object.
%         advdriver
%         % instrument on active mode or not. On active mode, the online
%         % status of the instrument is constantly checked, if not online,
%         % the instrument tries to reconnect the instrument, if still can not
%         % bring the intrument online, an exception is throwed. Though
%         % happens very rarely, for instruments that are not currently
%         % running measurement tasks, it is adviced to turn then into
%         % non-active mode to prevent then from interrupping the running
%         % of measurement, because some of then might accidentally goes
%         % offline and could not be reconnected.
%         active = false; % default false;
    end
    properties (SetAccess = private)
        % instrument interface object is open/connected/responsive or not
        isopen 
    end
    properties (SetAccess = protected,GetAccess = protected)
        % any Matlab supported instrument communication interface object:
        % GPIB, VISA, TCPIP, UDP, I2C, BLUETOOTH etc.
        interfaceobj
    end
%     properties (SetAccess = protected, GetAccess = private)
%         instronlinechecker     % timer to check that the instrument stays online.
%         % instrument online ckeck interval,do checking every checkinterval seconds
%         % ckecking too frequenty might interrupt measurement if the
%         % communication to instruments is slow, if not sure, check this by:
%         % tic; obj.Test(); toc
%         % seconds
%         checkinterval = 60;  
%     end
    methods
        function obj = instrument(name,interfaceobj,drivertype)
            if ~isa(interfaceobj,'icinterface') && ~isa(interfaceobj,'qes.hwdriver.icinterface_compatible')
                error('instrument:InvalidInputType',...
                    'Input ''%s'' should be an interface object!',...
                    'interfaceobj');
            end
            obj = obj@qes.hwdriver.hardware(name);
            obj.interfaceobj = interfaceobj;
            if strcmp(obj.interfaceobj.Status,'closed')
                qes.hwdriver.sync.instrument.FOpenClose(obj,true);
            end
            if nargin > 2 && ~isempty(drivertype)
                obj.drivertype = drivertype;
            else % driver type not specified by user, try to identify it by querying the instrument and lookup in the instrumentLib.
                try
                    indstrs = strtrim(strsplit(query(obj.interfaceobj,'*IDN?'),','));
                    InstruLib = qes.hwdriver.instrumentLib();
                    d = InstruLib.GetDriverTyp(indstrs{1},indstrs{2});
                    if isempty(d)
                        % unable to identify the driver type, the user has to specify it if necessary.
                        warning('instrument:IdentifyDriverTypeFail',...
                            'Unable to identify the driver type.');
                    end
                    obj.drivertype = d;
                catch
                    % unable to identify the driver type, the user has to specify it if necessary.
                    warning('instrument:IdentifyDriverTypeFail',...
                        'Unable to identify the driver type.');
                end
            end
%             obj.instronlinechecker = timer('ExecutionMode','fixedRate','BusyMode','drop',...
%                         'Period',obj.checkinterval,'TimerFcn',{@qes.hwdriver.sync.instrument.checkinstronline,obj},...
%                         'ObjectVisibility','off');
        end
        function set.timeout(obj,val)
            if isempty(val)
                val = Inf;
            end
            if ~isreal(val) || val <=0
                error('instrument:InvalidInput',...
                        'timeout should be a positive number');
            end
            obj.timeout = val;
        end
%         function set.active(obj, val)
%             if isempty(val) || ~islogical(val)
%                 error('instrument:SetError','active should be logical.');
%             end
%             if isempty(obj.instronlinechecker) % during construction, obj.instronlinechecker might be empty
%                 return;
%             end
%             if val
%                 if strcmp(obj.instronlinechecker.Running,'off')
%                     start(obj.instronlinechecker);
%                 end
%                 obj.active = true;
%             else
%                 if strcmp(obj.instronlinechecker.Running,'on')
%                     stop(obj.instronlinechecker);
%                 end
%                 obj.active = false;
%             end
%         end
        function status = get.isopen(obj)
            status = false;
            if strcmp(obj.interfaceobj.Status,'closed')
                return;
            end
            try
                obj.Test();
                status = true;
            catch
            end
        end
%         function set.checkinterval(obj, val)
%             if ~isnumeric(val) || ~(val  > 0)
%                 error('instrument:SetError','checkinterval is not a positive number.');
%             end
%              if isempty(obj.instronlinechecker) % during construction, obj.instronlinechecker might be empty
%                 return;
%              end
%             orig_active_status = obj.active;
%             obj.active = false; % stop timer if running
%             set(obj.instronlinechecker,'Period',val);
%             obj.checkinterval = val;
%             obj.active = orig_active_status; % restore running status
%         end
        function Response = Test(obj)
            % test instrument communication
            Response = query(obj.interfaceobj,'*IDN?'); % takes about 5ms on a dc source(gpib), about 250ms on tek awg 5k(tcpip)
        end
        function CLS(obj)
            % clear instrument status
            obj.Write('*CLS');
        end
        function RST(obj)
            % reset instrument
            obj.Write('*RST');
        end
        function bol = IsValid(obj)
            % check the validity of hanlde properties and the object itself
            if ~isvalid(obj)
                bol = false;
                return;
            end
            bol = true;
            if ~isvalid(obj.interfaceobj) 
                bol = false;
                return;
            end
        end
        function Write(obj,cmd)
            fprintf(obj.interfaceobj,cmd);
        end
        function Read(obj)
            fscanf(obj.interfaceobj);
        end
        function resp = Query(obj,cmd)
            resp = iquery(obj.interfaceobj,cmd);
        end
        function Reconnect(obj)
            % Reconnect the instrument
            interfaceclass = class(obj.interfaceobj);
            switch interfaceclass
                case 'tcpip'
                    if isvalid(obj.interfaceobj) && strcmp(obj.interfaceobj.Status,'open')
                        qes.hwdriver.sync.instrument.FOpenClose(obj,false);
                    end
                    newinterfaceobj = tcpip(obj.interfaceobj.RemoteHost,...
                        obj.interfaceobj.RemotePort);
                    newinterfaceobj.Terminator = obj.interfaceobj.Terminator;
                    newinterfaceobj.Timeout = obj.interfaceobj.Timeout;
                    newinterfaceobj.InputBufferSize = obj.interfaceobj.InputBufferSize;
                    newinterfaceobj.OutputBufferSize = obj.interfaceobj.OutputBufferSize;
                    newinterfaceobj.ByteOrder = obj.interfaceobj.ByteOrder;
                    obj.interfaceobj = newinterfaceobj;
                    qes.hwdriver.sync.instrument.FOpenClose(obj,true);
            end
        end
        function delete(obj)
%             if obj.instronlinechecker.Running
%                 stop(obj.instronlinechecker);  % stop checking first
%             end
%             delete(obj.instronlinechecker);
            if strcmp(obj.interfaceobj.Status,'open')
                qes.hwdriver.sync.instrument.FOpenClose(obj,false);
            end
            delete(obj.interfaceobj);
        end
%         function varargout = subsref(obj,S)
%             varargout = cell(1,nargout);
%             switch S(1).type
%                 case '.'
%                     if numel(S) == 1
%                         if nargout
%                             varargout{:} = obj.(S(1).subs);
%                         else
%                             obj.(S(1).subs);
%                         end
%                     else
%                         switch S(2).type
%                             case '()'
%                                 if nargout
%                                     if numel(S) == 2
%                                         varargout{:} = obj.(S(1).subs)(S(2).subs{:});
%                                     else
%                                         varargout{:} = subsref(obj.(S(1).subs)(S(2).subs{:}),S(3:end));
%                                     end
%                                 else
%                                     if numel(S) == 2
%                                         obj.(S(1).subs)(S(2).subs{:});
%                                     else
%                                         subsref(obj.(S(1).subs)(S(2).subs{:}),S(3:end));
%                                     end
%                                 end
%                             case '{}' 
%                                 if numel(S) == 2
%                                     varargout{:} = obj.(S(1).subs){S(2).subs{:}};
%                                 else
%                                     varargout{:} = subsref(obj.(S(1).subs){S(2).subs{:}},S(3:end));
%                                 end
%                         end
%                     end
%                 case '()'
%                     objs = qes.qHandle.FindByProp('name',S(1).subs);
%                     removeidx = [];
%                     for ii = 1:numel(objs)
%                         if ~isa(objs{ii},'qes.hwdriver.sync.instrument');
%                             removeidx = [removeidx,ii];
%                         end
%                     end
%                     objs(removeidx) = [];
%                     varargout{1} = objs;
%             end
%         end
     end
    methods (Static = true, Hidden = true)
        function FOpenClose(varargin)
            persistent objnamelist
            persistent interfaceobjlist
            if nargin == 0
                fclose('all');
            else
                obj = varargin{1};
                open = varargin{2};
            end
            try
                if open
                    fopen(obj.interfaceobj);
                else
                    fclose(obj.interfaceobj);
                end
            catch
                error('instrument:UnsuccessfulOpen',...
                   [obj.name ': Could not open/close interface object!']);
            end
            [~,Locb] = ismember(obj.name,objnamelist);
            if Locb
                if open
                    interfaceobjlist(Locb) = {obj.interfaceobj};
                else
                    objnamelist(Locb) = [];
                    interfaceobjlist(Locb) = [];
                end
            else
                objnamelist = [objnamelist,{obj.name}];
                interfaceobjlist = [interfaceobjlist,{obj.interfaceobj}];
            end
        end
%         function checkinstronline(hObject,eventdata,obj)
%             if strcmp(obj.interfaceobj.Status,'closed')
%                 try
%                     fopen(obj.interfaceobj);
%                 catch
%                     warning('instrument:instrumentOffline',...
%                        [obj.name ': instrument offline, reconnection failed!']);
%                 end
%             else
%                 try
%                     obj.Test();
%                 catch
%                     warning('instrument:instrumentOffline',...
%                            [obj.name ': instrument offline!']);
%                 end
%             end
%         end
    end
    
end