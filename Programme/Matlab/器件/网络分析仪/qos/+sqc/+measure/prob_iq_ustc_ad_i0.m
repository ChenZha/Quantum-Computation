classdef prob_iq_ustc_ad_i0 < sqc.measure.prob_iq_ustc_ad_i
    % wrapper of prob_iq_ustc_i, only return data(:,2) the probability of
    % |0>
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    methods
        function obj = prob_iq_ustc_ad_i0(iq_ustc_ad_obj)
            obj = obj@sqc.measure.prob_iq_ustc_ad_i(iq_ustc_ad_obj);
        end
        function Run(obj)
            Run@sqc.measure.prob_iq_ustc_ad_i(obj);
            obj.data = obj.data(:,1);
        end
    end
end