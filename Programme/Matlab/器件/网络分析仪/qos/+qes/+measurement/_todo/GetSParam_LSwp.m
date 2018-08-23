classdef GetSParam_LSwp < Measurement
    % Measure scatter parameter with a SParamMeter object, long sweep.
    % Sweep with sweep point exceeds instrument maximum: break down the
    % sweep into several small sweeps, each with a sweep size
    % obj.InstrumentObject.swppoints or less.
    % data(:,1): frequency;
    % data(:,2): scatter parameter;
    % all instrument settings are done in InstrumentObject

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        swppoints  % total sweep points.
    end
    methods
        function obj = GetSParam_LSwp(InstrumentObject)
            if ~isa(InstrumentObject,'SParamMeter') || ~isvalid(InstrumentObject)
                error('GetSParam_LSwp:InvalidInput','InstrumentObject is not a valid SParamMeter class object!');
            end
            obj = obj@Measurement(InstrumentObject);
            obj.numericscalardata = false;
        end
        function Run(obj)
            % Run the measurement
            if isempty(obj.swppoints) || isempty(obj.maxswppoints)
                error('GetSParam_LSwp:RunError','some properties are not set yet!');
            end
            Run@Measurement(obj);
            obj.dataready = false;
            swpfreq = linspace(obj.startfreq,obj.stopfreq,obj.swppoints);
            iswppoints = obj.InstrumentObject.swppoints;
            n = ceil(obj.swppoints/iswppoints);
            obj.data = NaN*ones(n*iswppoints,2); % preallocate to avoid possible memory leakage in case of huge data
            dp = 0;
            for ii = 1:n
                start_idx = iswppoints*(ii-1)+1;
                if ii < n
                    stop_idx = start_idx+iswppoints-1;
                else
                    stop_idx = min(start_idx+iswppoints-1,obj.swppoints);
                    obj.InstrumentObject.swppoints = stop_idx - start_idx + 1;
                end
                obj.InstrumentObject.swpstopfreq = swpfreq(stop_idx);
                obj.InstrumentObject.swpstartfreq = swpfreq(start_idx);
                obj.InstrumentObject.CreateMeasurement('TRACE_S21',[2,1]);
                [f,s] = obj.InstrumentObject.GetData;
                dln = length(f);
                obj.data(dp+1:dp+dln,:) = [s(:),f(:)];
                dp = dp+dln;
            end
            obj.data(dp+1:end,:) = [];
            obj.data = obj.data';
            obj.InstrumentObject.swppoints = iswppoints; % restore original settings
            obj.dataready = true;
        end
    end
    
end