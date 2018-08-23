function r = gauss(n, bandwidth)
	% n samples from 0 to sampling frequency/2,
	% -3dB at bandwidth*sampling frequency/2
	% gaussian shaped low pass filter 

% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

	if nargin < 2
		bandwidth  = 0.26;
	end
	assert(bandwidth > 0);
	
	x = 1/bandwidth*sqrt(log(2)/2);
	r = exp(-(linspace(0,x/2,n)).^2);
	x = exp(-(0.5*x)^2);
	r = (r - x)/(1-x);

end