classdef (Sealed = true) acz < qes.waveform.waveform
    % adiabatic cz gate waveform
	% reference: J. M. Martinis and M. R. Geller, Phys. Rev. A 90, 022307(2014)

% Copyright 2017 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com

    methods
        function obj = acz(length, amplitude, thf, thi, lam2, lam3,...
                ampInDetune, f01, maxF01, k)
            if nargin == 6  % to be backward compatible
                ampInDetune = false;
                f01 = 6e6;
                maxF01 = 6e6;
                k = 1e7;
            end
			obj.jWaveform = com.qos.waveform.ACZ(length, amplitude, thf, thi, lam2, lam3,...
                ampInDetune, f01, maxF01,k);
        end
    end
end