classdef X4m < sqc.op.physical.gate.XY_base
    % -pi/4 around X axis
    
% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    methods
        function obj = X4m(qubit)
			obj = obj@sqc.op.physical.gate.XY_base(qubit);
			obj.length = obj.qubits{1}.g_XY4_ln;
            obj.amp = obj.qubits{1}.g_XY4_amp;
            obj.phase = pi;
            obj.setGateClass('X4m');
        end
    end
end