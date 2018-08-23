classdef specAmp < qes.measurement.measurement
    %

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    
    properties
        freq
        avgnum  = 1
    end
    properties (SetAccess = private, GetAccess = private)
        
    end
    methods
        function obj = specAmp(InstrumentObject)
            obj = obj@qes.measurement.measurement(InstrumentObject);
            obj.timeout = 60; % default timeout 60 seconds.
        end
        function set.freq(obj,val)
            if isempty(val) || ~isnumeric(val) || ~isreal(val) || val <= 0
                throw(MException('QOS_specAmp:InvalidInput','Invalid frequency value.'));
            end
            obj.freq = val;
            % ucsb
%             obj.InstrumentObject.bandwidth = 100;
%             obj.InstrumentObject.startfreq = obj.freq - 50;
%             obj.InstrumentObject.stopfreq = obj.freq + 50;
%             obj.InstrumentObject.numpts = 101;

            obj.instrumentObject.bandwidth = 200;
            obj.instrumentObject.startfreq = obj.freq - 100;
            obj.instrumentObject.stopfreq = obj.freq + 100;
            obj.instrumentObject.numpts = 201;
            pause(0.3);
        end
        function set.avgnum(obj,val)
            if isempty(val) || ~isnumeric(val) || ~isreal(val) ||val <= 0
                error('GetSpecAmp:InvalidInput','Invalid avgnum value.');
            end
            obj.avgnum = ceil(val);
        end
        function Run(obj)
            if isempty(obj.freq) 
                throw(MException('QOS_specAmp:propertyNotSet','some properties are not set yet!'));
            end
            Run@qes.measurement.measurement(obj); % check object and its handle properties are isvalid or not
            obj.dataready = false;
            
            Maxtries = 10;
            for ii = 1:Maxtries
                spcamp = obj.instrumentObject.avg_amp();
                if spcamp> 30 || spcamp < -140 
                    if ii == Maxtries
                        throw(MException('QOS_specAmp:RunError',...
                            sprintf('measured value %0.0f dBm out of feasible range: -140dBm to 30dBm.', spcamp)));
                    else
                        pause(0.2);
                        continue;
                    end
                else
                    break;
                end
            end

%             amp = obj.instrumentObject.get_trace();
%             obj.data = mean(amp);
            obj.data = spcamp;
            obj.dataready = true;
        end
    end
end