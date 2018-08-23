classdef (Sealed = true) NIDAQUSB5132 < Hardware
    % dirver for NI DAQ-5132 Digitizer
    % driver based.

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        smplrate        % Hz, sampling rate
        workmode = 1;   % 1/2, continues(default)/triggered
        timeout = 30;   % seconds, default:30 seconds.
        
        chnl1enabled@logical scalar = true;  % logical, channel 1 enabled or not
        chnl1range          % V, channel 1 Vpp, USB-5132 Vpp: 0.04/0.1/0.2/0.4/1/2/4/10/20/40
        chnl1offset = 0;  % V, channel 1 Offset
        
        chnl2enabled@logical scalar  = true;  % logical, channel 2 enabled or not
        chnl2range          % V, channel 2 Vpp, USB-5132 Vpp: 0.04/0.1/0.2/0.4/1/2/4/10/20/40 V
        chnl2offset = 0;  % V, channel 2 Offset
        
        numsamples    % number of data points to fetch for each data acquisition
    end
    properties (SetAccess = private)
        running@logical scalar  = false;
    end
    properties (Constant = true, Hidden = true, GetAccess = private)
        triggerlevel = 0.2;     % Volts
        trigposslop = true;     % true/false, tirgger slop positive or negative
    end
    properties (Hidden = true,  SetAccess = private, GetAccess = private)
        deviceobj
        acquisition
    end
    methods (Access = private)
        function obj = NIDAQUSB5132(name, deviceobj)
            % NIDAQUSB5132 deviceobj is created by icdevice:
            % deviceobj = icdevice('niscope.mdd', 'DAQ::Dev1',  'optionstring','simulate=false');
            % niscope.mdd is the driver, see doc for details.
            if ~ischar(name)
                error('NIDAQUSB5132:InvalidInputType',...
                    'Input ''%s'' must be a character string!',...
                    'name');
            end
            obj = obj@Hardware(name);
            if ~isa(deviceobj,'icdevice') || ~isvalid(deviceobj)
                error('NIDAQUSB5132:InvalidInput', 'deviceobj should be a valid icdevice object!');
            end
            obj.deviceobj = deviceobj;
            if strcmp(obj.deviceobj.Status,'closed')
                connect(obj.deviceobj);
            end
        end
    end
    methods (Static)
        obj = GetInstance(name,deviceobj)
    end
    methods
        function set.smplrate(obj,val)
            val = round(val);
            if isempty(val) || val <=0
                error('NIDAQUSB5132:InvalidInput','smplrate should be a positive integer!');
            end
            if val > 50e6
                error('NIDAQUSB5132:InvalidInput','smplrate out of range!');
            end
            obj.smplrate = val;
        end
        function set.workmode(obj,val)
            if val ~=1 && val ~= 2
                error('NIDAQUSB5132:InvalidInput','available workmodes 1/2 continues/trigger!');
            end
            obj.workmode = val;
        end
        function set.numsamples(obj,val)
            val = round(val);
            if isempty(val) || val <=0
                error('NIDAQUSB5132:InvalidInput','numsamples should be a positive integer!');
            end
            obj.numsamples = val;
        end
        Config(obj)
        Run(obj)
        VoltSignal = FetchData(obj)
        function Stop(obj)
            % Stop acquisition
            if isempty(obj.acquisition)
                return;
            end
            invoke(obj.acquisition, 'abort');
            obj.acquisition = [];
            obj.running =  false;
        end
        function Reset(obj)
            % Reset divice object, do this incase of unable to connect
            % error
            obj.Stop();
            if strcmp(obj.deviceobj.Status,'open')
                disconnect(obj.deviceobj);
            end
            connect(obj.deviceobj);
            obj.Config();
        end
        function bol = eq(obj1,obj2)
            bol = false;
            if strcmp(obj1.name, obj2.name)
                bol = true;
            end
        end
        function delete(obj)
            obj.Stop();
            if strcmp(obj.deviceobj.Status,'open')
                disconnect(obj.deviceobj);
            end
        end
    end
    
end