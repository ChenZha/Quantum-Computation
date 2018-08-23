function g = Z(qubit)
	% Z
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com
	import sqc.op.physical.gate.*
	switch qubit.g_Z_impl
		case 'z' % implemented by z pulse
			g = Z_z(qubit);
		case 'xy' % implemented by using X Y gates
			g = X(qubit)*Y(qubit);
        case 'phase'
            g = Z_phase(qubit);
		otherwise
			error('unrecognized Z gate implementation: %s, available z gate implementation options are: xy ,phase and z',...
				qubit.g_Z_typ);
    end
    g.setGateClass('Z');
end
