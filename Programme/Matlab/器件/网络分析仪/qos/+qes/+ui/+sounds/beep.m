function [y, fs] = beep()
    % beep sound
    % usage:
    % sound(sounds.beep)
    
% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    fs = 8192;
    y = sin(1:1.5:1200);
end