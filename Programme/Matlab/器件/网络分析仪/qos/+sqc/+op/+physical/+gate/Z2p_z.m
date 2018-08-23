classdef Z2p_z < sqc.op.physical.Z_z_base
    % +pi/2 rotation around the z axis, implement by using the z line
    
% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

   methods
        function obj = Z2p_z(qubit)
			obj = obj@sqc.op.physical.Z_z_base(qubit);
			obj.length = obj.qubits{1}.g_Z2_z_ln;
            obj.zpulse_amp = obj.qubits{1}.g_Z2p_z_amp;
            obj.setGateClass('Z2p');
        end
    end
end