classdef prob_iq_ustc_ad_i1 < sqc.measure.prob_iq_ustc_ad_i
    % wrapper of prob_iq_ustc_i, only return data(:,2) the probability of
    % |1>
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    methods
        function obj = prob_iq_ustc_ad_i1(iq_ustc_ad_obj,qs)
            obj = obj@sqc.measure.prob_iq_ustc_ad_i(iq_ustc_ad_obj,qs);
        end
        function Run(obj)
            Run@sqc.measure.prob_iq_ustc_ad_i(obj);
            obj.data = obj.data(:,2);
        end
    end
end