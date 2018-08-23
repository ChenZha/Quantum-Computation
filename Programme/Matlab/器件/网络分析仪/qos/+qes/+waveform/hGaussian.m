classdef (Sealed = true) hGaussian < qes.waveform.waveform
    % half gaussian pulse

% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties 
        amp = 1         % pulse amplitude
        rsigma = 0.2123;   % sigma/length, by default, rsigma = 0.2123 (FWHM = length/2)
    end
    methods
        function obj = hGaussian(ln)
            if nargin == 0
                ln = 0;
            end
            obj = obj@qes.waveform.waveform(ln);
        end
    end
    methods (Static = true, Hidden=true)
        function v = TimeFcn(obj,t)
            sigma = 2*obj.rsigma*obj.length;
            t = t - obj.t0 -obj.length;
            v = zeros(1,numel(t));
            idx = t <= 0;
            v(idx) = obj.amp*exp(-t(idx).^2/(2*sigma^2));
        end
        function v = FreqFcn(obj,f)
            sigma = obj.rsigma*obj.length;
            sigmaf = 1/(2*pi*sigma);
            ampf = obj.amp*sqrt(2*pi*sigma^2);
            
            z = f==0;
            z2=(abs(f)*sigma<=5.5);
        	v = 0.5*((1-z)*ampf*1j.*exp(-f.^2/(2*sigmaf^2) -...
                1j*2*pi*f*(obj.t0+obj.length/2)).*(1+erf(1j*sqrt(2)*pi*(f*sigma).*z2)+(z2-1)));
        end
    end
end