function g = Ry(qubit, ang)
% arbitary rotation around y axis

% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

	g = sqc.op.physical.gate.Rxy(qubit, pi, ang);
end