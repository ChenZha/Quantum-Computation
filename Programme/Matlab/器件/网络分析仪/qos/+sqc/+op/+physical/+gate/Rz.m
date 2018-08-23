classdef Rz < sqc.op.physical.gate.Z_phase_base
    % arbitary rotation around the z axis, implement by phase shift
    
% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    methods
        function obj = Rz(qubit,phase)
            obj = obj@sqc.op.physical.gate.Z_phase_base(qubit,phase);
			obj.length = 0;
        end
    end
end