classdef (Sealed = true) rect_s < qes.waveform.waveform
    % rectangular pulse with sharp rising and falling
    % only frequency domain funciton is used in pulse generation, time
    % domain funciton is just for display

% Copyright 2016 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties 
        amp = 1
        overshoot = 0
        % float, half of the gaussian pulse length, unit: 1/sampling frequency
        % only used in time domain function for display.
        overshoot_w = 1
        direct0 = 1
        direct1 = 1
        fwhm = 10
    end
    methods
        function obj = rect_s(ln)
            if nargin == 0
                ln = 0;
            end
            obj = obj@qes.waveform.waveform(ln);
        end
        function set.overshoot_w(obj,val)
            if val <= 0
                % if no overshoot is needed, set overshoot = 0;
                error('rect_s:invalidinput','overshoot width should be positive.');
            end
            obj.overshoot_w = val;
        end
        function set.fwhm(obj,val)
            if val <= 0
                error('rect_s:invalidinput','fwhm should be positive.');
            end
            obj.fwhm = val;
        end
    end
    methods (Static = true, Hidden=true)
        function v = TimeFcn(obj,t)
            o_amp = 2*sqrt(log(2)/pi)/obj.overshoot_w;  % area == 1
            sigma = 0.4246*obj.overshoot_w; % 2*FWHM = total gaussian pulse length
            overshoot_amp = obj.overshoot*sign(obj.amp)*o_amp;
%             v = obj.amp*(t > obj.t0).*(t < obj.t0 + obj.length-1) +...
%                 obj.overshoot*o_amp*exp(-(t-(obj.t0+1)).^2/(2*sigma^2))+...
%                 obj.overshoot*o_amp*exp(-(t-(obj.t0+obj.length-2)).^2/(2*sigma^2));
            
%             rise_ln = round(obj.overshoot_w); 
%             v = obj.amp*(t >= obj.t0 + rise_ln).*(t <= obj.t0 + obj.length-1-rise_ln) +...
%                 overshoot_amp*exp(-(t-(obj.t0+rise_ln)).^2/(2*sigma^2))+...
%                 overshoot_amp*exp(-(t-(obj.t0+obj.length-1-rise_ln)).^2/(2*sigma^2));

            v = obj.amp*(t >= obj.t0).*(t < obj.t0 + obj.length) +...
                overshoot_amp*exp(-(t-obj.t0).^2/(2*sigma^2))+...
                overshoot_amp*exp(-(t-(obj.t0+obj.length)).^2/(2*sigma^2));
        end
        function v = FreqFcn(obj,f)
%             a = 2*sqrt(log(2))/obj.fwhm;
%             v = obj.amp*abs(obj.length)*sinc(obj.length*f).*exp(-1j*2*pi*f*(obj.t0+(obj.length-1)/2))+...
%                 obj.overshoot*(erf(a*(obj.length-3)))*(obj.direct0*exp(-1j*2*pi*f*(obj.t0+1))+obj.direct1*exp(-1j*2*pi*f*(obj.t0 + obj.length-2)));


%             rise_ln = round(obj.overshoot_w); 
%             a = 2*sqrt(log(2))/obj.fwhm;
%             v = obj.amp*abs(obj.length-2*rise_ln)*sinc((obj.length-2*rise_ln)*f).*exp(-1j*2*pi*f*(obj.t0+(obj.length-1)/2))+...
%                 obj.overshoot*(erf(a*(obj.length-2*rise_ln)))*(obj.direct0*exp(-1j*2*pi*f*(obj.t0+rise_ln))+...
%                 obj.direct1*exp(-1j*2*pi*f*(obj.t0 + obj.length-1-rise_ln)));

            a = 2*sqrt(log(2))/obj.fwhm;
            v = obj.amp*abs(obj.length)*sinc(obj.length*f).*exp(-1j*2*pi*f*(obj.t0+obj.length/2))+...
                obj.overshoot*sign(obj.amp)*erf(a*obj.length)*(obj.direct0*exp(-1j*2*pi*f*obj.t0)+...
                obj.direct1*exp(-1j*2*pi*f*(obj.t0 + obj.length)));
        end
    end
end