classdef numericT < qes.waveform.waveform
    % waveform with numeric model
    %

% Copyright 2018 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com

    methods
        function obj = numericT(length, amplitude, modelSamples)
			obj.jWaveform = com.qos.waveform.NumericT(length, amplitude, modelSamples);
        end
    end
end