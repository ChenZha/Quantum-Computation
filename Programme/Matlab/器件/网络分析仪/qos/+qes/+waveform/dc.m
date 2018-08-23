classdef dc < qes.waveform.waveform
    % dc

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    methods
        function obj = dc(length,level)
            obj.jWaveform = com.qos.waveform.DC(length, level);
        end
    end
end