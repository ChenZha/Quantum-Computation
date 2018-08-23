classdef RX < sqc.op.logical.operator
    % X rotation
    % also RX = exp(-1j*theta/2*sigmaX)

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com
    methods
        function obj = RX(theta)
            obj = obj@sqc.op.logical.operator(...
                [cos(theta/2),-1i*sin(theta/2);-1i*sin(theta/2),cos(theta/2)]);
        end
    end
end