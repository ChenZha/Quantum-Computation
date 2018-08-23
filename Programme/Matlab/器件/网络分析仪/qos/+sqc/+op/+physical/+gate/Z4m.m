function g = Z4m(qubit)
	% -Z/4
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com
	import sqc.op.physical.gate.*
	switch qubit.g_Z_impl
		case 'z' % implement by using z line
			error('not implemented');
		case 'xy' % implement by using X Y gates
			error('not implemented');
		case 'phase'
            g = Z4m_phase(qubit);
		otherwise
			error('unrecognized Z gate type: %s, available z gate options are: xy ,phase and z',...
				qubit.g_Z_typ);
	
    end
    g.setGateClass('Z4m');
end
