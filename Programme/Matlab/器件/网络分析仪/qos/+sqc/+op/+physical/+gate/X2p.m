classdef X2p < sqc.op.physical.gate.XY_base
    % half pi around X axis
    
% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com
    
    methods
        function obj = X2p(qubit)
			obj = obj@sqc.op.physical.gate.XY_base(qubit);
			obj.length = obj.qubits{1}.g_XY2_ln;
            obj.amp = obj.qubits{1}.g_XY2_amp;
            obj.setGateClass('X2p');
        end
    end
end