classdef sigmaX < sqc.op.logical.operator
    % sigma X
    methods
        function obj = sigmaX()
            obj = obj@sqc.op.logical.operator([0,1;1,0]);
        end
    end
end