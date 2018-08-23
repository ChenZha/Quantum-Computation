classdef iSwap < sqc.op.physical.operator
    % iSwap
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

	properties
		
	end
    methods
        function obj = iSwap(control_q, target_q)
            obj = obj@sqc.op.physical.operator({control_q, target_q});
            
            error('to be implemeted');
			% use sqc.op.physical.op.Detune to detune other qubits
            
            obj.setGateClass('iSwap');
        end
    end
	methods (Hidden = true)
        function GenWave(obj)
            
			
			% apply detune to other qubits
			% todo...
        end
    end
end