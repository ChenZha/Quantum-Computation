function g = H(qubit)
	% Hardmard [1,1;1,-1], |0> -> |0>+|1>, |1> -> |0>-|1>
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com
	
	import sqc.op.physical.gate.*
	% g = Y4m(qubit)*X(qubit)*Y4p(qubit);
    g = X(qubit)*Y2p(qubit);
    g.setGateClass('H');
end
