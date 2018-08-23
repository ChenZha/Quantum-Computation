classdef Y2p < sqc.op.logical.gate.RY
    % Y/2 gate, pi/2 rotation around Y axis
    % 

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com
    methods
        function obj = Y2p()
            obj = obj@sqc.op.logical.gate.RY(pi/2);
        end
    end
end