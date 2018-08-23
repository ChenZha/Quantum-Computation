classdef GetIQ_VNA < GetIQ
    %

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        n = 1
        freq
    end
    
	methods
        function obj = GetIQ_VNA(InstrumentObject)
            if ~isa(InstrumentObject,'SParamMeter') || ~isvalid(InstrumentObject)
                error('GetIQ_VNA:InvalidInput','InstrumentObject is not a valid SParamMeter class object!');
            end
            obj = obj@GetIQ(InstrumentObject);
            obj.InstrumentObject.swppoints = 2;
        end
        function set.n(obj,val)
            if isempty(val) || ceil(val) ~=val || val <=0
                error('GetIQ_VNA:InvalidInput','n should be a positive integer!');
            end
            obj.InstrumentObject.avgcounts = val;
            obj.InstrumentObject.CreateMeasurement('TRACE_S21',[2,1]);
            obj.n = val;
        end
        function set.freq(obj,val)
            obj.InstrumentObject.swpstartfreq = val-0.01e6;
            obj.InstrumentObject.swpstopfreq = val+0.01e6;
            obj.InstrumentObject.CreateMeasurement('TRACE_S21',[2,1]);
            obj.freq = val;
        end
        function Run(obj)
            Run@Measurement(obj); % check object and its handle properties are isvalid or not
            [~,s] = obj.InstrumentObject.GetData();
            obj.data = mean(s);
            obj.dataready = true;
        end
    end
    
end