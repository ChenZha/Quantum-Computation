classdef (Sealed = true) acz < qes.waveform.waveform
    % adiabatic cz gate waveform
	% reference: J. M. Martinis and M. R. Geller, Phys. Rev. A 90, 022307(2014)

% Copyright 2016 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties 
        amp = 1
        thf = 0.55*pi/2
        thi = 0.05
        lam2 = -0.18
        lam3 = 0.04
        resolution = 1024
        w = 0
        f01
        detuning2Zpa
    end
    methods
        function obj = acz(ln)
            if nargin == 0
                ln = 0;
            end
            obj = obj@qes.waveform.waveform(ln);
        end
    end
    methods (Static = true, Hidden=true)
        function v = TimeFcn(obj,t)
            ti=linspace(0,1,obj.resolution);
            han2 = (1-obj.lam3)*(1-cos(2*pi*ti))+obj.lam2*(1-cos(4*pi*ti))+obj.lam3*(1-cos(6*pi*ti));
            thsl=obj.thi+(obj.thf-obj.thi)*han2/max(han2);
            tlu=cumsum(sin(thsl))*ti(2);%t(¦Ó)
            tlu=tlu-tlu(1);
            ti=linspace(0, tlu(end), obj.resolution);
            th=interp1(tlu,thsl,ti,'linear', 0);%¦È(t)
            th=1./tan(th);
            th=th-th(1);
            th=th/min(th);
            ti = linspace(obj.t0, obj.t0+obj.length-1, obj.resolution);
            if ~isempty(obj.f01) && ~isempty(obj.detuning2Zpa)
                detuning = obj.f01+ th*obj.amplitude;
                v = interp1(ti, obj.detuning2Zpa(detuning), t, 'pchip',0);
            else
                v = interp1(ti, th*obj.amp,t, 'pchip',0);
            end
        end
        function v = FreqFcn(obj,f)
            v = qes.waveform.fcns.FFT(obj,f);
        end
    end
end