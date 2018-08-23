classdef RZ < sqc.op.logical.operator
    % Z rotation
    % also RX = exp(-1j*theta/2*sigmaZ)

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com
    methods
        function obj = RZ(theta)
            obj = obj@sqc.op.logical.operator([exp(-1i*theta/2),0;0,exp(1i*theta/2)]);
        end
    end
end