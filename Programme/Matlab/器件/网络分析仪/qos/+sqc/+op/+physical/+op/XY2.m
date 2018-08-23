classdef XY2 < sqc.op.physical.gate.X2m
    % -pi/2 rotation at at an arbitary axis in the xy plane
	% Note: halfPiAmp for different rotation axis are not exactly the same,
	% use this operation for coarse application or tunning only.
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        phi % axis 
    end
    methods
        function obj = XY2(qubit, phi_)
            obj = obj@sqc.op.physical.gate.X2m(qubit);
			obj.phi = phi_;
        end
    end
    methods (Hidden = true)
        function GenWave(obj)
            GenWave@sqc.op.physical.gate.X2m(obj)
            obj.phase = obj.phi;
        end
    end
end