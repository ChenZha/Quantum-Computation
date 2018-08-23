classdef Z_phase < sqc.op.physical.gate.Z_phase_base
    % pi rotation around the z axis, implement by phase shift
    
% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    methods
        function obj = Z_phase(qubit)
            obj = obj@sqc.op.physical.gate.Z_phase_base(qubit,pi);
			obj.length = 0;
        end
    end
end