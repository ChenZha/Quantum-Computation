classdef Py1 < sqc.op.logical.operator
    % y Projection operator (i<0|+<1|)(i|0>-|1>)/2
    methods
        function obj = Py1()
            obj = obj@sqc.op.logical.operator();
            obj.m = sym([1,-1i;1i,1]/2);
        end
    end
end