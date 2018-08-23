classdef sigmaZ < sqc.op.logical.operator
    % sigma z
    methods
        function obj = sigmaZ()
            obj = obj@sqc.op.logical.operator([1,0;0,-1]);
        end
    end
end