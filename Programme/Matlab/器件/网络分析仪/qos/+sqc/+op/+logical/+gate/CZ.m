classdef CZ < sqc.op.logical.operator
    % controled phase gate
    % 

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com
    methods
        function obj = CZ()
            obj = obj@sqc.op.logical.operator(sparse([1,2,3,4],[1,2,3,4],[1,1,1,-1]));
        end
    end
end