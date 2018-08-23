classdef I < sqc.op.logical.operator
    % Identity

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com
    methods
        function obj = I()
            obj = obj@sqc.op.logical.operator([1,0;0,1]);
        end
    end
end