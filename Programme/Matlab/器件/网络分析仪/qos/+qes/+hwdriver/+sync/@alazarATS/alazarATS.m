classdef alazarATS < qes.hwdriver.hardware
    % dirver for Alazar Tech ATS Digitizer
    % Tested with AlazarTech ATS9360-FIFO 12-bit, 1.8 GS/s, 2-channel digitizer
    % other models may not supported.

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% version: 2016/12/10, tested, improved efficiency
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        % Hz, sampling rate when clocksource = 1(internal), value cast to one of the available options:
		% [1e3,      2e3,        5e3,...
%            10e3,     20e3,       50e3,...
%            100e3,    200e3       500e3,...
%            1e6,      2e6,        5e6,...
%            10e6,     20e6,       25e6,       50e6,...
%            100e6,    125e6,      160e6,      180e6,      200e6,      250e6,      400e6,      500e6,      800e6,...
%            1e9,      1.2e9,      1.5e9,      1.6e9,      1.8e9]; 
        smplrate
        workmode = 1;   % 1/2, triggered(default)/continues
        timeout = 15;   % seconds, default:30 seconds.
        
        chnl1enabled@logical scalar = true;  % logical, channel 1 enabled or not
        chnl2enabled@logical scalar  = true;  % logical, channel 2 enabled or not
        % Channel Vpp, Channel Vpp value will be cast to one of the availbale options:
		% [20e-3,      40e-3,        50e-3,       80e-3,...
%            100e-3,      125e-3,       200e-3,        250e-3,     400e-3,       500e-3,     800e-3...
%             1,        1.25,       2,          2.5,        4,          5,          8,...
%             10,     16,   20,     40];
        chnl1range = 0.4;
        chnl2range = 0.4;
        
        num_records = 1000;         % number of records to aquire
        record_ln = 1000;    % record length in samples
        % 1/2, internal/external, internal clock source is recommended incase of external is used,
		% smplrate is not used, the sample rate is the frequency of the external clock plugged in.
        clocksource = 2;
    end
    properties (Constant = true, Hidden = true, GetAccess = private)
        samplerate_options = [1e3,      2e3,        5e3,...
                              10e3,     20e3,       50e3,...
                              100e3,    200e3       500e3,...
                              1e6,      2e6,        5e6,...
                              10e6,     20e6,       25e6,       50e6,...
                              100e6,    125e6,      160e6,      180e6,      200e6,      250e6,      400e6,      500e6,      800e6,...
                              1e9,      1.2e9,      1.5e9,      1.6e9,      1.8e9,...
                              2e9];                  
        samplerate_codes = [hex2dec('00000001'),hex2dec('00000002'),hex2dec('00000004'),...
                            hex2dec('00000008'),hex2dec('0000000A'),hex2dec('0000000C'),...
                            hex2dec('0000000E'),hex2dec('00000010'),hex2dec('00000012'),...
                            hex2dec('00000014'),hex2dec('00000018'),hex2dec('0000001A'),...
                            hex2dec('0000001C'),hex2dec('0000001E'),hex2dec('00000021'),hex2dec('00000022'),...
                            hex2dec('00000024'),hex2dec('00000025'),hex2dec('00000026'),hex2dec('00000027'),hex2dec('00000028'),hex2dec('0000002B'),hex2dec('0000002D'),hex2dec('00000030'),hex2dec('00000032'),...
                            hex2dec('00000035'),hex2dec('00000037'),hex2dec('0000003A'),hex2dec('0000003B'),hex2dec('0000003D'),...
                            hex2dec('0000003F'),hex2dec('00000040')]; % the last one is external clock
       range_options = [20e-3,      40e-3,        50e-3,       80e-3,...
                              100e-3,      125e-3,       200e-3,        250e-3,     400e-3,       500e-3,     800e-3...
                              1,        1.25,       2,          2.5,        4,          5,          8,...
                              10,     16,   20,     40];
       range_codes = [hex2dec('00000001');hex2dec('00000002');hex2dec('00000003');hex2dec('00000004');...
                        hex2dec('00000005');hex2dec('00000028');hex2dec('00000006');hex2dec('00000030');hex2dec('00000007');hex2dec('00000008');hex2dec('00000009');...
                        hex2dec('0000000A');hex2dec('00000021');hex2dec('0000000B');hex2dec('00000025');hex2dec('0000000C');hex2dec('0000000D');hex2dec('0000000E');...
                        hex2dec('0000000F');hex2dec('00000012');hex2dec('00000010');hex2dec('00000011')];
    end
    properties (Constant = true, Hidden = true, GetAccess = private)
        triggerlevel = 0.2;     % Volts
        trigposslop = true;     % true/false, tirgger slop positive or negative
    end
    properties (Hidden = true,  SetAccess = private, GetAccess = private)
        deviceobj
    end
    methods (Access = private)
        function obj = alazarATS(name, BoardGroupID, BoardID)
            % alazarATS deviceobj is created by
            if ~ischar(name)
                error('alazarATS:InvalidInputType',...
                    'Input ''%s'' must be a character string!',...
                    'name');
            end
            obj = obj@qes.hwdriver.hardware(name);
            if nargin < 2
                BoardGroupID = 1;
                BoardID = 1;
            end
            if ~qes.hwdriver.sync.alazarATS.LoadLib()
                error('alazarATS:LoadLibFailed','Load lib failed.');
            end
            obj.deviceobj = calllib('ATSApi', 'AlazarGetBoardBySystemID', BoardGroupID, BoardID);

            ApiSuccess = 512;
            TRIG_ENGINE_OP_J = hex2dec('00000000');
            TRIG_ENGINE_J = hex2dec('00000000');
            TRIG_ENGINE_K = hex2dec('00000001');
            TRIG_EXTERNAL = hex2dec('00000002');
            TRIG_DISABLE = hex2dec('00000003');
            TRIGGER_SLOPE_POSITIVE = hex2dec('00000001');
            TRIGGER_SLOPE_NEGATIVE = hex2dec('00000002');
            AC_COUPLING                 =   hex2dec('00000001');
            DC_COUPLING                 =	hex2dec('00000002');
            ETR_2V5 = hex2dec('00000003');
            AUX_OUT_TRIGGER             =	0;
            
            % Select trigger inputs and levels as required
            % TriggerSlope:0 is NEGATIVE, 1 is POSITIVE.
            if obj.trigposslop
                TriggerSlope = 1;
            else
                TriggerSlope = 0;
            end
            % TriggerLevel
            % In our case, the range of trigger is [-2.5V,2.5V],corresponds to
            % integer located in [0,255].
            TriggerLevel_V = obj.triggerlevel;
            TriggerLevel = fix(128+127*(TriggerLevel_V/2.5));
            if TriggerSlope == 0;
                retCode = ...
                    calllib('ATSApi', 'AlazarSetTriggerOperation', ...       
                        obj.deviceobj,		...	% HANDLE -- board handle
                        TRIG_ENGINE_OP_J,	...	% U32 -- trigger operation 
                        TRIG_ENGINE_J,		...	% U32 -- trigger engine id
                        TRIG_EXTERNAL,		...	% U32 -- trigger source id
                        TRIGGER_SLOPE_NEGATIVE,	... % U32 -- trigger slope id
                        TriggerLevel,				...	% U32 -- trigger level from 0 (-range) to 255 (+range)
                        TRIG_ENGINE_K,		...	% U32 -- trigger engine id
                        TRIG_DISABLE,		...	% U32 -- trigger source id for engine K
                        TRIGGER_SLOPE_POSITIVE, ...	% U32 -- trigger slope id
                        128					...	% U32 -- trigger level from 0 (-range) to 255 (+range)
                        );
            elseif TriggerSlope == 1;
                retCode = ...
                    calllib('ATSApi', 'AlazarSetTriggerOperation', ...       
                        obj.deviceobj,		...	% HANDLE -- board handle
                        TRIG_ENGINE_OP_J,	...	% U32 -- trigger operation 
                        TRIG_ENGINE_J,		...	% U32 -- trigger engine id
                        TRIG_EXTERNAL,		...	% U32 -- trigger source id
                        TRIGGER_SLOPE_POSITIVE,	... % U32 -- trigger slope id
                        TriggerLevel,				...	% U32 -- trigger level from 0 (-range) to 255 (+range)
                        TRIG_ENGINE_K,		...	% U32 -- trigger engine id
                        TRIG_DISABLE,		...	% U32 -- trigger source id for engine K
                        TRIGGER_SLOPE_POSITIVE, ...	% U32 -- trigger slope id
                        128					...	% U32 -- trigger level from 0 (-range) to 255 (+range)
                        );
            end
            if retCode ~= ApiSuccess
                error('Error: AlazarSetTriggerOperation failed -- %s\n', qes.hwdriver.sync.alazarATS.errorToText(retCode));
            end

            % TODO: Select external trigger parameters as required
            retCode = ...
                calllib('ATSApi', 'AlazarSetExternalTrigger', ...       
                    obj.deviceobj,		...	% HANDLE -- board handle
                    DC_COUPLING,		...	% U32 -- external trigger coupling id
                    ETR_2V5				...	% U32 -- external trigger range id
                    );
            if retCode ~= ApiSuccess
                error('Error: AlazarSetExternalTrigger failed -- %s\n', qes.hwdriver.sync.alazarATS.errorToText(retCode));
            end

            % TODO: Set trigger delay as required. 
            triggerDelay_sec = 0;
            triggerDelay_samples = 0;
        %     triggerDelay_samples = uint32(floor(triggerDelay_sec * samplesPerSec + 0.5));
            retCode = calllib('ATSApi', 'AlazarSetTriggerDelay', obj.deviceobj, triggerDelay_samples);
            if retCode ~= ApiSuccess
                error('Error: AlazarSetTriggerDelay failed -- %s\n', qes.hwdriver.sync.alazarATS.errorToText(retCode));
            end

            % TODO: Set trigger timeout as required. 

            % NOTE:
            % The board will wait for a for this amount of time for a trigger event. 
            % If a trigger event does not arrive, then the board will automatically 
            % trigger. Set the trigger timeout value to 0 to force the board to wait 
            % forever for a trigger event.
            %
            % IMPORTANT: 
            % The trigger timeout value should be set to zero after appropriate 
            % trigger parameters have been determined, otherwise the 
            % board may trigger if the timeout interval expires before a 
            % hardware trigger event arrives.
            triggerTimeout_sec = 0;
            triggerTimeout_clocks = 0;
        %     triggerTimeout_clocks = uint32(floor(triggerTimeout_sec / 10.e-6 + 0.5));
            retCode = ...
                calllib('ATSApi', 'AlazarSetTriggerTimeOut', ...       
                    obj.deviceobj,            ...	% HANDLE -- board handle
                    triggerTimeout_clocks	... % U32 -- timeout_sec / 10.e-6 (0 == wait forever)
                    );
            if retCode ~= ApiSuccess
                error('Error: AlazarSetTriggerTimeOut failed -- %s\n', qes.hwdriver.sync.alazarATS.errorToText(retCode));
            end

            % TODO: Configure AUX I/O connector as required
            retCode = ...
                calllib('ATSApi', 'AlazarConfigureAuxIO', ...       
                    obj.deviceobj,		...	% HANDLE -- board handle
                    AUX_OUT_TRIGGER,	...	% U32 -- mode
                    0					...	% U32 -- parameter
                    );	
            if retCode ~= ApiSuccess
                error('Error: AlazarConfigureAuxIO failed -- %s\n', qes.hwdriver.sync.alazarATS.errorToText(retCode));
            end
            
            
            
        end
    end
    methods (Static = true, Hidden = true)
        AlazarDefs
        obj = GetInstance(name, BoardGroupID, BoardID)
        LoadLibStatus = LoadLib()
        [methodinfo,structs,enuminfo,ThunkLibName] = AlazarInclude_pcwin32()
        [methodinfo,structs,enuminfo,ThunkLibName] = AlazarInclude_pcwin64()
        [methodinfo,structs,enuminfo]=AlazarInclude()
        [text] = errorToText(errorCode)
    end
    methods
        function set.smplrate(obj,val)
            if obj.clocksource == 2; % external
%                 scode = obj.samplerate_codes(end);
%                 retCode = ...
%                     calllib('ATSApi', 'AlazarSetCaptureClock', ...
%                     obj.deviceobj,		...	% HANDLE -- board handle
%                     2,		...	% U32 -- clock source id
%                     scode,...	% U32 -- sample rate id
%                     0,	...	% U32 -- clock edge id
%                     0					...	% U32 -- clock decimation
%                     );
%                 if retCode ~= int32(512)
%                     error('Error: AlazarSetCaptureClock failed -- %s\n', qes.hwdriver.sync.alazarATS.errorToText(retCode));
%                 end
                obj.smplrate = val;
            else
                [~,idx]=min(abs(val - obj.samplerate_options));
%                 scode = obj.samplerate_codes(idx);
%                 retCode = ...
%                         calllib('ATSApi', 'AlazarSetCaptureClock', ...
%                         obj.deviceobj,		...	% HANDLE -- board handle
%                         1,		...	% U32 -- clock source id
%                         scode,...	% U32 -- sample rate id
%                         0,	...	% U32 -- clock edge id
%                         0					...	% U32 -- clock decimation
%                         );
%                 if retCode ~= int32(512)
%                     error('Error: AlazarSetCaptureClock failed -- %s\n', qes.hwdriver.sync.alazarATS.errorToText(retCode));
%                 end
                obj.smplrate = obj.samplerate_options(idx);
            end
        end
        function set.workmode(obj,val)
            if val ~=1 && val ~= 2
                error('alazarATS:InvalidInput','available workmodes 1/2 trigger/continues!');
            end
            obj.workmode = val;
        end
        function set.clocksource(obj,val)
            if val ~=1 && val ~= 2
                error('alazarATS:InvalidInput','available clocksource 1/2 internal/external!');
            end
            obj.clocksource = val;
        end
        function set.chnl1range(obj,val)
            [~,idx]=min(abs(val - obj.range_options));
            rcode = obj.range_codes(idx);
            retCode = ...
                calllib('ATSApi', 'AlazarInputControl', ...       
                    obj.deviceobj,		...	% HANDLE -- board handle
                    1,			...	% U8 -- input channel 
                    2,		...	% U32 -- input coupling id
                    rcode, ...	% U32 -- input range id
                    2	...	% U32 -- input impedance id  % 50 Ohm
                    );
            if retCode ~= 512
                error('Error: AlazarInputControl failed -- %s\n', qes.hwdriver.sync.alazarATS.errorToText(retCode));
            end
            obj.chnl1range = obj.range_options(idx);
        end
        function set.chnl2range(obj,val)
            [~,idx]=min(abs(val - obj.range_options));
            rcode = obj.range_codes(idx);
            retCode = ...
                calllib('ATSApi', 'AlazarInputControl', ...       
                    obj.deviceobj,		...	% HANDLE -- board handle
                    2,			...	% U8 -- input channel 
                    2,		...	% U32 -- input coupling id
                    rcode, ...	% U32 -- input range id
                    2	...	% U32 -- input impedance id  % 50 Ohm
                    );
            if retCode ~= 512
                error('Error: AlazarInputControl failed -- %s\n', qes.hwdriver.sync.alazarATS.errorToText(retCode));
            end
            obj.chnl2range = obj.range_options(idx);
        end
        
        function set.num_records(obj,val)
            val = round(val);
            if isempty(val) || val <=0
                error('alazarATS:InvalidInput','num_records should be a positive integer!');
            end
            obj.num_records = val;
        end
        function set.record_ln(obj,val)
            val = round(val);
            if isempty(val) || val <=0
                error('alazarATS:InvalidInput','record_ln should be a positive integer!');
            end
            if mod(val,128) ~= 0 
                val_ = 128*max(ceil(val/128),3);
                warning('alazarATS:numperseg_value_error','record_ln can only be a multiple of 128 and has a minmum of 384, value increased from %s to %s',...
                    num2str(val,'%0.0f'), num2str(val_,'%0.0f'));
                val= val_;
            end
            obj.record_ln = val;
        end
        VoltSignal = FetchData(obj)
        function Reset(obj)
            % Reset divice object, do this incase of unable to connect
            % error
            error('not implemeted for alazarATS');
        end
    end
    
end