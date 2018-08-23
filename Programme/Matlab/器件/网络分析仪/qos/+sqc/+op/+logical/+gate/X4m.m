classdef X4m < sqc.op.logical.gate.RX
    % -X/4 gate, -pi/4 rotation around X axis
    % 

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com
    methods
        function obj = X4m()
            obj = obj@sqc.op.logical.gate.RX(-pi/4);
        end
    end
end