classdef Y4m < sqc.op.logical.gate.RY
    % -Y/4 gate, -pi/4 rotation around Y axis
    % 

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    methods
        function obj = Y4m()
            obj = obj@sqc.op.logical.gate.RY(-pi/4);
        end
    end
end