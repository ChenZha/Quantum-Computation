classdef Y_ < sqc.op.physical.gate.XY_base
    % pi rotation around Y axis
    
% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    methods
        function obj = Y_(qubit)
            obj = obj@sqc.op.physical.gate.XY_base(qubit);
			obj.length = obj.qubits{1}.g_XY_ln;
            obj.amp = obj.qubits{1}.g_XY_amp;
            obj.phase = pi/2;
            obj.setGateClass('Y');
        end
    end
end