function data = removeJumps(data,jumpThreshold)
% like maltab unwrap is not robust

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

data = unwrap(data/jumpThreshold*2*pi)/2/pi;

end