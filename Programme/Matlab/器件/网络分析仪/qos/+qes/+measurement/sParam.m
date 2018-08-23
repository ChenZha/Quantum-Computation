classdef sParam < qes.measurement.measurement
    % Measure scatter parameter with a networkAnalyzer object
    % data(:,1): frequency;
    % data(:,2): scatter parameter;
    % all settings are done in InstrumentObject

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    methods
        function obj = sParam(InstrumentObject)
            if (~isa(InstrumentObject,'qes.hwdriver.sync.networkAnalyzer')) || ~isvalid(InstrumentObject) &&...
                    (~isa(InstrumentObject,'qes.hwdriver.async.networkAnalyzer') || ~isvalid(InstrumentObject))
                throw(MException('QOS_SParam:InvalidInput','InstrumentObject is not a valid networkAnalyzer class object.'));
            end
            obj = obj@qes.measurement.measurement(InstrumentObject);
            % InstrumentObject.CreateMeasurement('TRACE_S21',[2,1]);
            obj.numericscalardata = false;
        end
        function Run(obj)
            % Run the measurement
            Run@qes.measurement.measurement(obj); % check object and its handle properties are isvalid or not
            obj.instrumentObject.CreateMeasurement('TRACE_S21',[2,1]);
            obj.dataready = false;
            [f,s] = obj.instrumentObject.GetData;
            obj.data = [s(:),f(:)]';
            obj.dataready = true;
        end
    end
    
end