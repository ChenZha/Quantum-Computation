classdef prob_iq_ustc_ad_i < sqc.measure.prob_iq_ustc_ad
    % isolated readout
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    methods
        function obj = prob_iq_ustc_ad_i(iq_ustc_ad_obj,qs)
            obj = obj@sqc.measure.prob_iq_ustc_ad(iq_ustc_ad_obj,qs);
        end
        function Run(obj)
            Run@sqc.measure.prob_iq_ustc_ad(obj);
			d = obj.data;
			d0 = d==0;
			d1 = d==1;
			if obj.threeStates
				d2 = d==2;
				obj.data = [sum(d0,2),sum(d1,2),sum(d2,2)]/obj.n;
			else
				obj.data = [sum(d0,2),sum(d1,2)]/obj.n;
			end
        end
    end
end