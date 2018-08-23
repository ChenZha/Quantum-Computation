classdef CY < sqc.op.logical.operator
    % controled Y
    % 

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com
    methods
        function obj = CY()
            obj = obj@sqc.op.logical.operator(sparse([1,2,3,4],[1,2,4,3],[1,1,-1i,1i]));
        end
    end
end