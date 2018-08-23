classdef CXi < sqc.op.logical.operator
    % invert cnot, the second qubit is the target: |target_bit,control_bit>
    % can be fromed by: (qgates.H.*qgates.H)*qgates.CX*(qgates.H.*qgates.H)
    % 

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com
    methods
        function obj = CXi()
            obj = obj@sqc.op.logical.operator(sparse([1,2,3,4],[1,4,3,2],[1,1,1,1]));
        end
    end
end