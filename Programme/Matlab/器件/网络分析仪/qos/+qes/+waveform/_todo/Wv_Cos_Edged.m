classdef Wv_Cos_Edged < Wv_Oscillation
    % cosine wave pulse with gaussian edges
    %

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com
    properties
        edgeln = 1;
    end
    methods
        function obj = Wv_Cos_Edged()
            obj = obj@Wv_Oscillation();
        end
        function GenWave(obj)
            GenWave@Waveform(obj); % check parameters
            if isempty(obj.period)
                error('Wv_Cos_Edged:GenWaveError','period not set!');
            end
            Wave = zeros(1,obj.length);
            x = (1:obj.length)-1;
            if x(end) > obj.length
                error('Wv_Cos_Edged:ParameterError', 'waveform length too short for the current parameter set!');
            end
            Wave(x+1) = obj.amp_corr*obj.amp*cos(2*pi*x/obj.period+obj.phase+obj.phase_corr)+obj.zero_corr;
            env = wvenvelop.gedgedsqr(obj.length,obj.edgeln);
            obj.wvdata  = env.*Wave;
            obj.NormalizeSetVppVoff();
        end
    end
end