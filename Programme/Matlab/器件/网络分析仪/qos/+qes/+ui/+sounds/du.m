function [y, fs] = du()
    % du sound
    % usage:
    % sound(sounds.du)
    
% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    fs = 8192;
    y = sin(1:0.3:500);
end