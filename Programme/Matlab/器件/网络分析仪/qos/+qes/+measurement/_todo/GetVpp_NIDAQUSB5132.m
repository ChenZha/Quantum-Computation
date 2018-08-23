classdef GetVpp_NIDAQUSB5132 <  Measurement
    % Measure vpp of a single frequency signal with noise by NI DAQ USB5132
    % note: 
    % numsamples, smplrate are properly set wihtin the digitizer object and
    % the digitizer object already configured and running.
    % numsamples should be large enough for the sample to cover at 50 periods
    % of the signal, if not so, vpp might not be accurate.
    % smplrate should be at least 2 times higher than than the signal
    % frequency.
    % the signal must be a single frequency signal, otherwise vpp dose not
    % make much sense.

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        freqlb % signal frequency lower bound, Hz
        frequb % signal frequency upper bound, Hz
        method=1 % vpp method, 1/2/3: range/bandpass filter then range/fft, default: range
    end
    
	methods
        function obj = GetVpp_NIDAQUSB5132(InstrumentObject)
            if ~isa(InstrumentObject,'NIDAQUSB5132') || ~isvalid(InstrumentObject)
                error('GetVpp_NIDAQUSB5132:InvalidInput','InstrumentObject is not a valid NIDAQUSB5132 class object!');
            end
            obj = obj@Measurement(InstrumentObject);
        end
        function Set.method(obj,val)
            if isempty(val) || ~isnumeric(val)
                retrun;
            end
            val = round(val);
            switch val
                case 1
                    obj.method = 1;
                case 2
                    obj.method = 2;
                case 3
                    obj.method = 3;
            end
        end
        function Run(obj)
            % Run the measurement
            if isempty(obj.freqlb) || isempty(obj.frequb) || obj.freqlb >= obj.frequb
                error('GetVpp_NIDAQUSB5132:InvalidPoperty','Some properties are not set or not properly set!');
            end
            Run@Measurement(obj); % check object and its handle properties are isvalid or not
            Volt = obj.InstrumentObject.FetchData();
            if ~isempty(Volt)
                switch obj.method
                    case 1
                        obj.data = range(Volt);
                        obj.extradata = Volt;
                    case 2
                        Volt = BandPassFilter(Volt,obj.freqlb,obj.frequb,...
                                obj.freqlb*2/3,obj.frequb*4/3,...
                                0.1,30,obj.InstrumentObject.smplrate);
                        obj.data = range(Volt);
                        obj.extradata = Volt;
                    case 3
                        t = (1:length(Volt))/obj.InstrumentObject.smplrate;
                        [X,Y] = FFTSpectrum(t,Volt);
                        Y(X<obj.freqlb | X>obj.frequb) = [];
                        if isempty(Y)
                            obj.data = NaN;
                            obj.extradata = NaN;
                        else
                            obj.data = 2*max(Y);
                            obj.extradata = Volt;
                        end
                end
            else
                obj.data = NaN;
                obj.extradata = NaN;
            end
            obj.dataready = true;
        end
    end
end