classdef CX < sqc.op.logical.operator
    % cnot, the first bit is the target bit: |control_bit,target_bit>
    % 

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com
    methods
        function obj = CX()
            obj = obj@sqc.op.logical.operator(sparse([1,2,3,4],[1,2,4,3],[1,1,1,1]));
        end
    end
end