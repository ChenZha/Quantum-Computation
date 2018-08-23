classdef spacer < qes.waveform.waveform
    % a spacer waveform: a series of zeros for padding some space between
    % two waveforms

% Copyright 2017 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    methods
        function obj = spacer(length)
			obj.jWaveform = com.qos.waveform.Spacer(length);
        end
    end
end