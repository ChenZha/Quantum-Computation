classdef Pz1 < sqc.op.logical.operator
    % z Projection operator |1><1|
    % |1><1| = (I-Z)/2
    methods
        function obj = Pz1()
            obj = obj@sqc.op.logical.operator([0,0;0,1]);
        end
    end
end