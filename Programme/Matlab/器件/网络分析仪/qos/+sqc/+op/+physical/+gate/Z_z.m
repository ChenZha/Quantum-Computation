classdef Z_z < sqc.op.physical.gate.Z_z_base
    % pi rotation around the z axis, implement by using the z line
    
% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    methods
        function obj = Z_z(qubit)
            obj = obj@sqc.op.physical.gate.Z_z_base(qubit);
			obj.length = obj.qubits{1}.g_Z_z_ln;
            obj.amp = obj.qubits{1}.g_Z_z_amp;
            obj.setGateClass('Z');
        end
    end
end