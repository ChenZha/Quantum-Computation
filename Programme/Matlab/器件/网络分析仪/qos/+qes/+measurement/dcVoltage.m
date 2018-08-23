classdef dcVoltage < qes.measurement.measurement
    %

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties (SetAccess = private, GetAccess = private)
        voltMeterChnl
    end
    methods
        function obj = dcVoltage(voltMeterChnl)
            obj = obj@qes.measurement.measurement([]);
            obj.voltMeterChnl = voltMeterChnl;
            obj.timeout = 20;
        end
        
        function Run(obj)
            Run@qes.measurement.measurement(obj); % check object and its handle properties are isvalid or not
            obj.dataready = false;
            obj.data = obj.voltMeterChnl.voltage;
            obj.dataready = true;
        end
    end
end