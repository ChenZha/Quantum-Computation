classdef (Abstract = true) Z_phase_base < sqc.op.physical.operator
    % base class for z gates implement by using phase shift
    
% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        phase
    end
    methods
        function obj = Z_phase_base(qubit,phase)
			assert(numel(qubit)==1);
            obj = obj@sqc.op.physical.operator(qubit);
            obj.phase = phase;
        end
    end
    methods (Hidden = true)
        function GenWave(obj)
            
        end
    end
end