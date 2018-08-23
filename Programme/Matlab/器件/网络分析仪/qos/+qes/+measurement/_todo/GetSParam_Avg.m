classdef GetSParam_Avg < Measurement
    % average can be done in the InstrumentObject(SParamMeter) object by
    % setting the avgcounts property, yet for some instruments model,
    % setting avgcounts to large values(allowed setting values) dose not
    % increase the actual average times, thus if large average times is
    % needed(>1000 for example), set a small value in InstrumentObject's avgcounts
    % and measure multiple times to obtain a large average, this is what
    % this class do.
    % total average times is num_avgs*InstrumentObject.avgcounts.
    properties
        num_avgs = 1;
    end
    methods
        function obj = GetSParam_Avg(InstrumentObject)
            obj = obj@Measurement(InstrumentObject);
            obj.numericscalardata = false;
        end
        function Run(obj)
            Run@Measurement(obj);
            obj.dataready = false;
            s = [];
            for ii = 1:obj.num_avgs
                [f_,s_] = obj.InstrumentObject.GetData;
                s = [s,s_(:)];
            end
            obj.data = [mean(s,2),f_(:)]';
            obj.dataready = true;
        end
    end
end