classdef XY_4p < sqc.op.physical.gate.X
    % pi rotation around pi/4 axis in the XY plane
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    methods
        function obj = XY_4p(qubit)
            obj = obj@sqc.op.physical.gate.X(qubit);
            obj.phase = pi/4;
            obj.setGateClass('XY_4p');
        end
    end
end