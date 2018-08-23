classdef numeric < qes.waveform.waveform
    % numeric waveform: specify every waveform data points
    %

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        wavedata
    end
    methods
        function set.wavedata(obj,val)
%             % checking removed for efficiency
%             if isempty(val) || ~isreal(val)
%                 error('Wv_Mnl:InvalidInput','wavedata should be real!');
%             end
%             val = val(:);
            obj.length = numel(val);
            obj.wavedata = val;
        end
    end
    methods (Static = true, Hidden=true)
        function v = TimeFcn(obj,t)
            v = zeros(1,length(t));
            ti = obj.t0:obj.t0+obj.length-1;
            idx = t >= obj.t0 & t <= obj.t0 + obj.length-1;
            v(idx) = interp1(ti,obj.wavedata,t(idx));
        end
        function v = FreqFcn(obj,f)
            v = wvfcn.FFT(obj,f);
        end
    end
end