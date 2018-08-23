classdef T < sqc.op.logical.operator
    % T gate

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com
    methods
        function obj = T()
            obj = obj@sqc.op.logical.operator();
            pie = sym('pi');
            obj.m = [1,0;0,exp(1i*pie/4)];
        end
    end
end