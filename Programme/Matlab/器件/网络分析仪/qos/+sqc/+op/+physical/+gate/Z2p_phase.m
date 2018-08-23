classdef Z2p_phase < sqc.op.physical.gate.Z_phase_base
    % pi/2 rotation around the z axis, implement by phase shift
    
% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    methods
        function obj = Z2p_phase(qubit)
            obj = obj@sqc.op.physical.gate.Z_phase_base(qubit,pi/2);
			obj.length = 0;
        end
    end
end