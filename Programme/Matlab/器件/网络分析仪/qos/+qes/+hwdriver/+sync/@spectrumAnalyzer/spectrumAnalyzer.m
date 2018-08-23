classdef spectrumAnalyzer < qes.hwdriver.sync.instrument
    % spectrumAnalyzer source driver, basic.
    % basic properties and functions of a spectrumAnalyzer source
    % currently only support Keysight Technologies, N9030B

% Copyright 2016 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com
    
    properties
        startfreq % Hz
        stopfreq % Hz
        bandwidth % Hz
        reflevel = 0 % reference level, dBm
        numpts % number of points
        avgnum = 1 % number of averge times, set to 1 to disable average
        trigmod = 1  % 1/2/3/4 for 'IMM'/'VID'/'LINE'/'EXT'
        extref = 1 % 1/2 for 'INT'/'EXT' 10MHz reference
        on % true/false, set/query operating status
    end
    
    methods (Access = private)
        function obj = spectrumAnalyzer(name,interfaceobj,drivertype)
            if isempty(interfaceobj)
                throw(MException('QOS_spectrumAnalyzer:InvalidInput',...
                    sprintf('Input ''%s'' can not be empty!','interfaceobj')));
            end
            set(interfaceobj,'Timeout',10); 
            if nargin < 3
                drivertype = [];
            end
            obj = obj@qes.hwdriver.sync.instrument(name,interfaceobj,drivertype);
            ErrMsg = obj.InitializeInstr();
            if ~isempty(ErrMsg)
                throw(MException('QOS_spectrumAnalyzer:InstSetError',sprintf('%s: %s',obj.name, ErrMsg)));
            end
            fprintf(interfaceobj,':POW:RF:ATT 0dB');
            fprintf(interfaceobj,':INIT:CONT ON');
            %%% uiinfoobj to be implemented
        end
        [varargout] = InitializeInstr(obj)
    end
    methods (Static)
        obj = GetInstance(name,interfaceobj,drivertype)
    end
    methods
        function val = avg_amp(obj)
            % Gets the average amplitude of the entire trace
            
            % the following lines are necessary, without what one got is
            % history: avg_amp returns data even if the instrument is not
            % running(waiting for trigger for example).
            fprintf(obj.interfaceobj,'*CLS');
            fprintf(obj.interfaceobj,'*ESE 1'); 
            fprintf(obj.interfaceobj,':INIT:IMM'); 
            fprintf(obj.interfaceobj,'*OPC'); 
            while ~str2double(qes.hwdriver.sync.iquery(obj.interfaceobj,'*STB?'))
                pause(0.005);
            end   
            val = str2double(qes.hwdriver.sync.iquery(obj.interfaceobj, ':TRAC:MATH:MEAN? TRACE1'));
        end
        function val = peak_amp(obj)
            % Gets the current amplitude from the peak detector
            val = num2str(qes.hwdriver.sync.iquery(obj.interfaceobj, ':CALC:MARK:Y?'));
        end
        function val = peak_freq(obj)
            % Gets the current frequency from the peak detector
            val = num2str(qes.hwdriver.sync.iquery(obj.interfaceobj, ':CALC:MARK:X?'));
        end
        function val = get_trace(obj)
            % Gets the current amplitude from the peak detector
            fprintf(obj.interfaceobj,'*CLS');
            fprintf(obj.interfaceobj,'*ESE 1'); 
            fprintf(obj.interfaceobj,':INIT:IMM'); 
            fprintf(obj.interfaceobj,'*OPC'); 
            while ~str2double(qes.hwdriver.sync.iquery(obj.interfaceobj,'*STB?'))
                pause(0.005);
            end

            fprintf(obj.interfaceobj,':FORM ASC,8');
            fprintf(obj.interfaceobj,':FORM:BORD NORM'); % big endian
            resp = qes.hwdriver.sync.iquery(obj.interfaceobj,':TRAC? TRACE1');
            val = str2double(strsplit(resp,','));
        end
        
        function set.avgnum(obj,val)
            if isempty(val) || val <= 0 || ceil(val) ~=val
                throw(MException('QOS_spectrumAnalyzer:SetAverage','average number value should be positive integer.'));
            end
            obj.avgnum = val;
            fprintf(obj.interfaceobj,[':AVER:COUN ', num2str(val,'%0.0f')]);
            if val > 1
                fprintf(obj.interfaceobj,':AVER:TYPE LOG'); % LOG/MAX/MIN/RMS
                fprintf(obj.interfaceobj,':AVER ON');
            else
                fprintf(obj.interfaceobj,':AVER OFF');
            end
        end
        function val = get.avgnum(obj)
            val = str2double(qes.hwdriver.sync.iquery(obj.interfaceobj,':AVER:COUN?'));
        end

        function set.startfreq(obj,val)
            if isempty(val) || ~isnumeric(val) || ~isreal(val) || val <= 0
                throw(MException('QOS_spectrumAnalyzer:SetError','Invalid frequency value.'));
            end
            if val < 3 || val > 8.4e9 %  Keysight Technologies, N9030B
                warning('spectrumAnalyzer:OutOfLimit','Frequency value out of limits.');
                return;
            end
            fprintf(obj.interfaceobj,[':FREQ:STAR ', num2str(val/1e6,'%0.6f'),'MHz']);
        end
        function val = get.startfreq(obj)
            val = str2double(qes.hwdriver.sync.iquery(obj.interfaceobj,':FREQ:STAR?'));
        end
        function set.stopfreq(obj,val)
            if isempty(val) || ~isnumeric(val) || ~isreal(val) || val <= 0
                throw(MException('QOS_spectrumAnalyzer:SetError','Invalid frequency value.'));
            end
            if val < 3 || val > 8.4e9 %  Keysight Technologies, N9030B
                warning('spectrumAnalyzer:OutOfLimit','Frequency value out of limits.');
                return;
            end
            fprintf(obj.interfaceobj,[':FREQ:STOP ', num2str(val/1e6,'%0.6f'),'MHz']);
        end
        function val = get.stopfreq(obj)
            val = str2double(qes.hwdriver.sync.iquery(obj.interfaceobj,':FREQ:STOP?'));
        end
        function set.trigmod(obj,val)
            switch val
                case 1
                    fprintf(obj.interfaceobj,':TRIG:SOUR IMM');
                case 2
                    fprintf(obj.interfaceobj,':TRIG:SOUR VID');
                case 3
                    fprintf(obj.interfaceobj,':TRIG:SOUR LINE');
                case 4
                    fprintf(obj.interfaceobj,':TRIG:SOUR EXT');
                otherwise
                    throw(MException('QOS_spectrumAnalyzer:SetTrigMode','Invalid trig mode.'));
            end
        end
        function val = get.trigmod(obj)
            resp = qes.hwdriver.sync.iquery(obj.interfaceobj,':TRIG:SOUR?');
            resp((resp == 10) | (resp == 13)) = [];
            switch resp
                case 'IMM'
                    val = 1;
                case 'VID'
                    val = 2;
                case 'LINE'
                    val = 3;
                case {'EXT1','EXT2'}
                    val = 4;
                otherwise
                    throw(MException('QOS_spectrumAnalyzer:GetTrigModMode','query instrument failed.'));
            end
        end
        function set.extref(obj,val)
            switch val
                case 1
                    fprintf(obj.interfaceobj,':SENS:ROSC:SOUR INT');
                case 2
                    fprintf(obj.interfaceobj,':SENS:ROSC:SOUR EXT');
                otherwise
                    throw(MException('QOS_spectrumAnalyzer:SetExtRefMode','Invalid trig mode.'));
            end
        end
        function val = get.extref(obj)
            resp = qes.hwdriver.sync.iquery(obj.interfaceobj,':SENS:ROSC:SOUR?');
            resp((resp == 10) | (resp == 13)) = [];
            switch resp
                case 'INT'
                    val = 1;
                case 'EXT'
                    val = 2;
                otherwise
                    throw(MException('QOS_spectrumAnalyzer:GetExtRefMode','query instrument failed.'));
            end
        end
        function set.reflevel(obj,val)
            if isempty(val) || ~isnumeric(val) || ~isreal(val) || val < -150 || val > 30
                throw(MException('QOS_spectrumAnalyzer:SetError','Invalid reference level value.'));
            end
            fprintf(obj.interfaceobj,['DISP:WIND:TRAC:Y:RLEV ', num2str(val, '%0.1f'),'dBm']);
        end
        function val = get.reflevel(obj)
            val = str2double(qes.hwdriver.sync.iquery(obj.interfaceobj,'DISP:WIND:TRAC:Y:RLEV?'));
        end
        function set.bandwidth(obj,val)
            if isempty(val) || ~isnumeric(val) || ~isreal(val) || val <= 0
                throw(MException('QOS_spectrumAnalyzer:SetError','Invalid bandwith value.'));
            elseif val > 8e6 %  Keysight Technologies, N9030B
                warning('spectrumAnalyzer:SetError','bandwith value exceeds maximum.');
                val = 8e6;
            end
            fprintf(obj.interfaceobj,[':BAND ', num2str(val/1e6, '%0.6f'),'MHz']);
        end
        function val = get.bandwidth(obj)
            val = str2double(qes.hwdriver.sync.iquery(obj.interfaceobj,':BAND?'));
        end
        function set.numpts(obj,val)
            if isempty(val) || val <= 0 || ceil(val) ~=val
                throw(MException('QOS_spectrumAnalyzer:SetNumPts','numpts value should be positive integer.'));
            end
            fprintf(obj.interfaceobj,[':SWE:POIN ', num2str(val, '%0.0f')]);
        end
        function val = get.numpts(obj)
            val = str2double(qes.hwdriver.sync.iquery(obj.interfaceobj,':SWE:POIN?'));
        end

        function set.on(obj,val)
            if isempty(val)
                throw(MException('QOS_spectrumAnalyzer:SetOnOff', 'value of ''on'' must be a bolean.'));
            end
            if ~islogical(val)
                if val == 0 || val == 1
                    val = logical(val);
                else
                    throw(MException('QOS_spectrumAnalyzer:SetOnOff', 'value of ''on'' must be a bolean.'));
                end
            end
            if val
                fprintf(obj.interfaceobj,'*CLS');
                fprintf(obj.interfaceobj,'*ESE 1');
                fprintf(obj.interfaceobj,'*OPC');
            else
                throw(MException('QOS_spectrumAnalyzer:SetOnOff', 'off not implemeted.'));
            end
            obj.on = val;
        end
        function val = get.on(obj)
            if logical(str2double(qes.hwdriver.sync.iquery(obj.interfaceobj,'*OPC?')));
                val = true;
            else
                val = false;
            end
        end
        function On(obj)
            % set on, this method is introduced for functional
            % programming.
            obj.on = true;
        end
        function Off(obj)
            % set off, this method is introduced for functional
            % programming.
            obj.on = false;
        end
        
    end
end