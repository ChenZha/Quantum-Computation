classdef SWAP < sqc.op.logical.operator
    methods
        function obj = SWAP()
            obj = obj@sqc.op.logical.operator(sparse([1,2,3,4],[1,3,2,4],[1,1,1,1]));
        end
    end
end