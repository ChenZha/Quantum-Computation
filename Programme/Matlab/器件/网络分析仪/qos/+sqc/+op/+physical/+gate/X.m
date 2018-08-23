function g = X(qubit)
	% X
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com
	import sqc.op.physical.gate.*
	switch qubit.g_XY_impl
		case {'', 'pi'} % implemented as X
			g = X_(qubit);
		case 'hPi' % implemented as X2p*X2p
			g = X2p(qubit)*X2p(qubit);
            g.setGateClass('X');
		otherwise
			error('unrecognized X gate type: %s, available x gate options are: pi and hPi',...
				qubit.g_XY_typ);
	
	end
end
