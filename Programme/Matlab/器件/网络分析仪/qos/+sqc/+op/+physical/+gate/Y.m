function g = Y(qubit)
	% Y
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com
	import sqc.op.physical.gate.*
	switch qubit.g_XY_impl
		case 'pi' % implemented as Y
			g = Y_(qubit);
		case 'hPi' % implemented as Y2p*Y2p
			g = Y2p(qubit)*Y2p(qubit);
            g.setGateClass('Y');
		otherwise
			error('unrecognized XY gate type: %s, available XY gate type options are: pi and hPi',...
				qubit.g_Z_typ);
	
	end
end
