classdef H < sqc.op.logical.operator
    % Hadamard gate

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com
    methods
        function obj = H()
            obj = obj@sqc.op.logical.operator(1/sqrt(2)*[1,1;1,-1]);
        end
    end
end