classdef Pz0 < sqc.op.logical.operator
    % z Projection operator |0><0|
    % |0><0| = (I+Z)/2
    methods
        function obj = Pz0()
            obj = obj@sqc.op.logical.operator();
            obj.m = sym([1,0;0,0]);
        end
    end
end