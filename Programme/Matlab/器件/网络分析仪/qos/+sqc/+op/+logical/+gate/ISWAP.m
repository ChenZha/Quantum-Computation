classdef ISWAP < sqc.op.logical.operator
    % iswap

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com
    methods
        function obj = ISWAP()
            obj = obj@sqc.op.logical.operator(sparse([1,2,3,4],[1,3,2,4],[1,1i,1i,1]));
        end
    end
end