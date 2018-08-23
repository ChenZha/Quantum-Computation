classdef CSWAP < sqc.op.logical.operator
    % controled swap, the second bit is the control bit: |control_bit,target_bit>

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com
    methods
        function obj = CSWAP()
            obj = obj@sqc.op.logical.operator(sparse([1,2,3,4,5,6,7,8],[1,2,3,4,5,7,6,8],[1,1,1,1,1,1,1,1]));
        end
    end
end