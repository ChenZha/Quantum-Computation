classdef Z2 < sqc.op.logical.gate.RZ
    % Z/2 gate
    % 

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com
    methods
        function obj = Z2()
            obj = obj@sqc.op.logical.gate.RZ(pi/2);
        end
    end
end