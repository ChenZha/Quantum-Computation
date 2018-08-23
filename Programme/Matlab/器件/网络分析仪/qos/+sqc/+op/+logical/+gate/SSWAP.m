classdef SSWAP < sqc.op.logical.operator
    % sqrt swap

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com
    methods
        function obj = SSWAP()
            obj = obj@sqc.op.logical.operator(...
                sparse([1,2,2,3,3,4],[1,2,3,2,3,4],[1,(1+1i)/2,(1-1i)/2,(1-1i)/2,(1+1i)/2,1]));
        end
    end
end