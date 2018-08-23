classdef cos < qes.waveform.waveform
    % cosine envelop
    %

% Copyright 2016 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com

    methods
        function obj = cos(length,amplitude) 
			obj.jWaveform = com.qos.waveform.Cos(length,amplitude);
        end
    end
end