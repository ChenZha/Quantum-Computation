classdef (Sealed = true) ramp < qes.waveform.waveform
    % Ramp

% Copyright 2016 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties 
        amp@double scalar = 1         % pulse amplitude
        fall@logical scalar = true
    end
    methods
        function obj = ramp(ln)
            if nargin == 0
                ln = 0;
            end
            obj = obj@qes.waveform.waveform(ln);
        end
    end
    methods (Static = true, Hidden=true)
        function v = TimeFcn(obj,t)
            ln = obj.length;
            if ln == 0
                v = [];
                return;
            end
            v = obj.amp*(t>=obj.t0).*(t<obj.t0+ln).*(1-(t-obj.t0)/ln);
            if ~obj.fall
                v = fliplr(v);
            end
        end
        function v = FreqFcn(obj,f)
            z = f == 0;
            f = 1j*2*pi*(f + z);
            v = obj.amp*((1-z).*exp(-f*obj.t0).*(1./f-(1-exp(-f*obj.length))./(f.^2*obj.length)) + z*obj.length/2);
        end

    end
end