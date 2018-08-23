classdef X2m < sqc.op.logical.gate.RX
    % -X/2 gate, -pi/2 rotation around X axis
    % also: X2m = exp(1j*)

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com
    methods
        function obj = X2m()
            obj = obj@sqc.op.logical.gate.RX(-pi/2);
        end
    end
end