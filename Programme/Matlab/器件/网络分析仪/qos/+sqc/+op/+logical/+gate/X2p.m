classdef X2p < sqc.op.logical.gate.RX
    % +X/2 gate, pi/2 rotation around X axis
    % 

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com
    methods
        function obj = X2p()
           obj = obj@sqc.op.logical.gate.RX(pi/2);
        end
    end
end