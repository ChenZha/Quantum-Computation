function r = cosine(n, bandwidth)
	% n samples from 0 to sampling frequency/2,
	% 1 from 0 to bandwidth*sampling frequency/2, rolls of from bandwidth*sampling frequency/2 to sampling frequency/2 in a cosine shape
	% cosine edged low pass filter 

% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

	if nargin < 2
		bandwidth  = 0.8;
	end
	assert(bandwidth <= 1 & bandwidth > 0);
	
	r = ones(1,n);
	start = ceil(bandwidth*n);
	if start < n
		r(start:end) = 0.5+0.5*cos(linspace(0,pi,n-start+1));
	end
end