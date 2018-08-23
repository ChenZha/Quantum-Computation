function g = Delay(qubit,length)
	% Hardmard
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com
	
	g = sqc.op.physical.gate.I(qubit);
    g.ln = length;
    g.setGateClass('I');
end
