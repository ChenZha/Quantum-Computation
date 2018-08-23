classdef networkAnalyzer < qes.hwdriver.sync.instrument
    % Network analyzer driver for S-parameters, basic.
    % Currently support Agilent PNA E8300 series network analyzers only.
    % Agilent PNA E8300/agilent_n5230c series network analyzers ROSCillator source is
    % selected automatically:
    % Applying a 10 MHz signal to the Reference Oscillator connector automatically sets the
    % Reference Oscillator to EXTernal, when NO signal is present at the 10 MHz
    % Reference Oscillator connector, internal source is used.
    
    % Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
    % mail4ywu@gmail.com/mail4ywu@icloud.com
    
    properties
        on = false		% output off/on
        avgcounts % average factor, avgcounts = 1 to disable averaging.
        swpstartfreq		% Hz, an array in case of segment sweep
        swpstopfreq		% Hz, an array in case of segment sweep
        swppoints   % number of sweep points, an array in case of segment sweep
        bandwidth % Hz
        swpmode		% sweep mode: 0/1/2/3 continuous/groups/hold/single
        power % dBm
        trigmode = 0  % 0/1/2, immediate/'external/manual
        measurements % name list of all created measurements
        measurement % name the measurement to get data from
    end
    properties (GetAccess = private, SetAccess = private)
        numports    % number of ports
        averaging = false    % average or not
        numsegments = 1
    end
    
    methods (Access = private)
        function obj = networkAnalyzer(name,interfaceobj,drivertype)
            if isempty(interfaceobj)
                error('networkAnalyzer:InvalidInput',...
                    'Input ''%s'' can not be empty!',...
                    'interfaceobj');
            end
            if nargin < 3
                drivertype = [];
            end
            obj = obj@qes.hwdriver.sync.instrument(name,interfaceobj,drivertype);
            ErrMsg = obj.InitializeInstr();
            if ~isempty(ErrMsg)
                error('networkAnalyzer:InstSetError',[obj.name, ': %s'], ErrMsg);
            end
        end
        [ varargout] = InitializeInstr(obj)
        val = GetMeasurements(obj)
        SetOnOff(obj,On)
        bol = GetOnOff(obj)
    end
    methods (Static)
        obj = GetInstance(name,interfaceobj,drivertype)
    end
    methods
        CreateMeasurement(obj, MeasurementName, SIdx)
        DeleteMeasurement(obj, MeasurementName)
        [Freq, S] = GetData(obj)
        function set.bandwidth(obj,val)
            % for Agilent Technologies,N52xx, N83xx series only
            AgilentN83xxOptions = [1,1.5, 2,3,5,7];
            AgilentN83xxOptions = [AgilentN83xxOptions,AgilentN83xxOptions*10,AgilentN83xxOptions*100,...
                AgilentN83xxOptions*1e3,AgilentN83xxOptions*10e3,100e3,150e3,200e3,250e3];
            AgilentN83xxOptions(2) = [];
            
            for ii = 1:length(val)
                [~, idx] = min(abs((AgilentN83xxOptions-val(ii))));
                val_ = AgilentN83xxOptions(idx);
                if val_ ~= val(ii)
                    warning('networkAnalyzer:SetBandwidth', ['Bandwidth rounded to the closest allowed value of ', num2str(val_,'%0.0f'),'Hz.']);
                end
                val(ii) = val_;
            end
            obj.bandwidth = val;
        end
        function val = get.measurements(obj)
            val = GetMeasurements(obj);
        end
        function val = get.measurement(obj)
            TYP = lower(obj.drivertype);
            switch TYP
                case {'agilent_n5230c'}
                    str = query(obj.interfaceobj,':CALCulate:PARameter:SELect?');
                    val = strtrim(strrep(str,'"',''));
                case {'agilent_e5071c'}
                    % nothing to do
                    val = [];
                otherwise
                    error('SParamMeter:getmeasurement', ['Unsupported instrument: ',TYP]);
            end
        end
        function set.measurement(obj, MeasurementName)
            TYP = lower(obj.drivertype);
            switch TYP
                case {'agilent_n5230c'}
                    measurementlist = obj.measurements;
                    if isempty(measurementlist) || ~ismember(MeasurementName,measurementlist)
                        error('networkAnalyzer:SetMeasurement', ['Measurement ', MeasurementName ,' not exist.']);
                    else
                        fprintf(obj.interfaceobj,[':CALCulate:PARameter:SELect ',MeasurementName]);
                    end
                case {'agilent_e5071c'}
                    % nothing to do
                    val = [];
                otherwise
                    error('SParamMeter:setmeasurement', ['Unsupported instrument: ',TYP]);
            end
        end
        function val = get.on(obj)
            val = GetOnOff(obj);
        end
        function  set.on(obj, val)
            if isempty(val)
                error('networkAnalyzer:SetOnOff', 'value of ''on'' must be a bolean.');
            end
            if ~islogical(val)
                if val == 0 || val == 1
                    val = logical(val);
                else
                    error('networkAnalyzer:SetOnOff', 'value of ''on'' must be a bolean.');
                end
            end
            SetOnOff(obj,val);
            obj.on = val;
        end
%         function  set.timeout(obj, val)
%             if val>0
%                 obj.interfaceobj.Timeout=val;
%             end
%         end
        function val = get.avgcounts(obj)
            val = str2double(query(obj.interfaceobj,[':SENSe1:AVERage:COUNt?']));
        end
        function set.avgcounts(obj, value)
            if value > 1
                fprintf(obj.interfaceobj,':SENSe1:AVERage:STATe ON');
                fprintf(obj.interfaceobj,[':SENSe1:AVERage:COUNt ',num2str(value)]);
                obj.averaging = true;
            else
                fprintf(obj.interfaceobj,':SENSe1:AVERage:STATe OFF');
                obj.averaging = false;
            end
            obj.avgcounts = value;
        end
        function val = get.swpmode(obj)
            TYP = lower(obj.drivertype);
            switch TYP
                case {'agilent_n5230c'}
                    str = strtrim(query(obj.interfaceobj,':SENSe:SWEep:MODE?'));
            switch str
                case 'CONT'
                    val = 0;
                case 'SING'
                    val = 1;
                case 'GRO'
                    val = 2;
                case 'HOLD'
                    val = 3;
                otherwise
                    val = [];
            end
                case {'agilent_e5071c'}
                    error('sweep mode not supported on E5071C right now! Need to be developed!')
                otherwise
                    error('SParamMeter:getswpmode', ['Unsupported instrument: ',TYP]);
            end
            
        end
        function set.swpmode(obj,val)
            TYP = lower(obj.drivertype);
            switch TYP
                case {'agilent_n5230c'}
                    switch val
                case 0
                    fprintf(obj.interfaceobj,':SENSe:SWEep:MODE CONTinuous');
                case 1
                    fprintf(obj.interfaceobj,':SENSe:SWEep:MODE SINGle');
                case 2
                    fprintf(obj.interfaceobj,':SENSe:SWEep:MODE GROups');
                case 3
                    fprintf(obj.interfaceobj,':SENSe:SWEep:MODE HOLD');
                otherwise
                    error('Invalid input');
            end
            obj.swpmode = val;
                case {'agilent_e5071c'}
                    error('sweep mode not supported on E5071C right now! Need to be developed!')
                otherwise
                    error('SParamMeter:setswpmode', ['Unsupported instrument: ',TYP]);
            end
            
        end
        function val = get.power(obj)
            TYP = lower(obj.drivertype);
            switch TYP
                case {'agilent_n5230c'}
                    val = str2double(query(obj.interfaceobj,':SOURce:POWer:LEVel:IMMediate:AMPLitude?'));
                case {'agilent_e5071c'}
                    val = str2double(query(obj.interfaceobj,':SOURce:POWer:LEVel:IMMediate:AMPLitude?'));
                otherwise
                    error('SParamMeter:getpower', ['Unsupported instrument: ',TYP]);
            end
            
        end
        function set.power(obj, value)
            TYP = lower(obj.drivertype);
            switch TYP
                case {'agilent_n5230c'}
                    if value < -30 || value > 20 % Agilent PNA E8300 series
                        error('power out of limits');
                    end
                    fprintf(obj.interfaceobj,[':SOURce:POWer:LEVel:IMMediate:AMPLitude ', num2str(value)]);
                    obj.power = value;
                case {'agilent_e5071c'}
                    if value < -85 || value > 10 % Agilent PNA E8300 series
                        error('power out of limits');
                    end
                    fprintf(obj.interfaceobj,[':SOURce:POWer:LEVel:IMMediate:AMPLitude ', num2str(value)]);
                    obj.power = value;
                otherwise
                    error('SParamMeter:setpower', ['Unsupported instrument: ',TYP]);
            end
            
        end
        function val = get.trigmode(obj)
            TYP = lower(obj.drivertype);
            switch TYP
                case {'agilent_n5230c'}
                    str = strtrim(query(obj.interfaceobj,':TRIGger:SEQuence:SOURce?'));
                    switch str
                        case 'IMM'
                            val = 0;
                        case 'EXT'
                            val = 1;
                        case 'MAN'
                            val = 2;
                        otherwise
                            val = [];
                    end
                case {'agilent_e5071c'}
                    str = strtrim(query(obj.interfaceobj,':TRIGger:SEQuence:SOURce?'));
                    switch str
                        case 'INT'
                            val = 0;
                        case 'EXT'
                            val = 1;
                        case 'MAN'
                            val = 2;
                        case 'BUS'
                            val = 3;
                        otherwise
                            val = [];
                    end
                otherwise
                    error('SParamMeter:gettrigmode', ['Unsupported instrument: ',TYP]);
            end
            
        end
        function set.trigmode(obj, val)
            TYP = lower(obj.drivertype);
            switch TYP
                case {'agilent_n5230c'}
                    switch val
                case 0
                    fprintf(obj.interfaceobj,':TRIGger:SEQuence:SOURce IMMediate');
                case 1
                    fprintf(obj.interfaceobj,':TRIGger:SEQuence:SOURce EXTernal');
                case 2
                    fprintf(obj.interfaceobj,':TRIGger:SEQuence:SOURce MANual');
                otherwise
                    error('Invalid input');
            end
            obj.trigmode = val;
                case {'agilent_e5071c'}
                    switch val
                case 0
                    fprintf(obj.interfaceobj,':TRIGger:SEQuence:SOURce INT');
                case 1
                    fprintf(obj.interfaceobj,':TRIGger:SEQuence:SOURce EXTernal');
                case 2
                    fprintf(obj.interfaceobj,':TRIGger:SEQuence:SOURce MANual');
                case 3
                    fprintf(obj.interfaceobj,':TRIGger:SEQuence:SOURce BUS');
                otherwise
                    error('Invalid input');
            end
            obj.trigmode = val;
                otherwise
                    error('SParamMeter:settrigmode', ['Unsupported instrument: ',TYP]);                    
            end
            
        end
    end
end

% to create a measurement for S12 and name it as Test1
% ':CALCulate:PARameter:DEFine:EXTended Test1,S12'

% to select the measurement named Test1
% ':CALCulate1:PARameter:SELect TEST1'

% to display a trace <trace num> in window 2 for the measurement named Test1
% ':DISPlay:WINDow2:TRACe<trace num>:FEED Test1'

