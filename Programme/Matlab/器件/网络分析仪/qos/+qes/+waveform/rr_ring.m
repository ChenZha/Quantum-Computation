classdef rr_ring < qes.waveform.waveform
    % resonator readout with ring

% Copyright 2017 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com

    methods
        function obj = rr_ring(length, amplitude, edgeWidth,  ringWidth, ringAmplitude)
			obj.jWaveform = com.qos.waveform.RRRing(length, amplitude, edgeWidth, ringAmplitude, ringWidth);
        end
    end
end