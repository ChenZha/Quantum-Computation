function U = xyRotUnitary(phase,angle)
    % the unitary matrix of a ideal xy rotaion of phase(rotation axis) and angle
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

	alpha = [1,exp(1j*phase)]/sqrt(2);
	alpha_p = [-exp(-1j*phase),1]/sqrt(2);
	U = alpha'*alpha + exp(1j*angle)*(alpha_p'*alpha_p);
end