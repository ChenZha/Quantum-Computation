classdef RY < sqc.op.logical.operator
    % Y rotation
    % also RY = exp(-1j*theta/2*sigmaY)

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com
    methods
        function obj = RY(theta)
            obj = obj@sqc.op.logical.operator(...
                [cos(theta/2),-sin(theta/2);sin(theta/2),cos(theta/2)]);
        end
    end
end