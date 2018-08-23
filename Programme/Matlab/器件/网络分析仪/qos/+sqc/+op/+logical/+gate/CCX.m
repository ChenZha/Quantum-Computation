classdef CCX < sqc.op.logical.operator
    % ccnot or toffoli, the firt bit is the target bit: |control_bit2,control_bit1,target_bit>
    % 

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com
    methods
        function obj = CCX()
            obj = obj@sqc.op.logical.operator(sparse([1,2,3,4,5,6,7,8],[1,2,3,4,5,6,8,7],[1,1,1,1,1,1,1,1]));
        end
    end
end