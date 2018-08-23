classdef Y4p < sqc.op.logical.gate.RY
    % Y/4 gate, pi/4 rotation around Y axis
    % 

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com
    methods
        function obj = Y4p()
            obj = obj@sqc.op.logical.gate.RY(pi/4);
        end
    end
end