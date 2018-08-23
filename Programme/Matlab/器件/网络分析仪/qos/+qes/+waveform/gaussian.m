classdef (Sealed = true) gaussian < qes.waveform.waveform
    % gaussian

% Copyright 2017 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com

    methods
        function obj = gaussian(length,amplitude,rSigma) 
            if nargin < 3
                rSigma = 0.2123; % sigma/length, by default, rsigma = 0.2123 (FWHM = length/2)
			end
			obj.jWaveform = com.qos.waveform.Gaussian(length,amplitude,rSigma);
        end
    end
end