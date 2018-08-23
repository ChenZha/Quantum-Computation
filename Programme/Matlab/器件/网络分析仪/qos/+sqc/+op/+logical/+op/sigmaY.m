classdef sigmaY < sqc.op.logical.operator
    % sigma Y
    methods
        function obj = sigmaY()
            obj = obj@sqc.op.logical.operator([0,-1j;1j,0]);
        end
    end
end