classdef (Sealed = true) rect < qes.waveform.waveform
    % rectangular pulse

% Copyright 2017 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com

    methods
        function obj = rect(length, amplitude)
			obj.jWaveform = com.qos.waveform.Rect(length, amplitude);
        end
    end
end