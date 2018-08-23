function g = Z2p(qubit)
	% Z/2
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com
	import sqc.op.physical.gate.*
	switch qubit.g_Z_impl
		case 'z' % implement by using z line
			g = Z2p_z(qubit);
		case 'xy' % implement by using X Y gates
			g = sqc.op.physical.gate.X(qubit)*XY_4p(qubit);
		case 'phase'
            g = Z2p_phase(qubit);
		otherwise
			error('unrecognized Z gate type: %s, available z gate options are: xy ,phase and z',...
				qubit.g_Z_typ);
	
    end
    g.setGateClass('Z2p');
end
