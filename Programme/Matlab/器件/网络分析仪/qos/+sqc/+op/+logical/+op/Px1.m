classdef Px1 < sqc.op.logical.operator
    % x Projection operator (<0|+<1|)(|0>+|1>)/2
    methods
        function obj = Px1()
            obj = obj@sqc.op.logical.operator();
            obj.m = sym([1,1;1,1]/2);
        end
    end
end