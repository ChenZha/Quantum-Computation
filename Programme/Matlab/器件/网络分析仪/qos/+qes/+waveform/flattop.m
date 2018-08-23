classdef (Sealed = true) flattop < qes.waveform.waveform
    % A rectangular pulse convolved(multiplication in frequency domain)
    % with a gaussian to have smooth rise and fall.
	
% Copyright 2017 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com

    methods
        function obj = flattop(length, amplitude, edgeWidth)
			obj.jWaveform = com.qos.waveform.Flattop(length, amplitude, edgeWidth);
        end
    end
end