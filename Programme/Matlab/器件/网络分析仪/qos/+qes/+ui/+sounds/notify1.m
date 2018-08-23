function [y, fs] = notify1()
    % a notify sound
    % usage:
    % sound(sounds.notify1)
    
% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    fs = 8192;
    y = [sin(1:.6:400), sin(1:.7:400), sin(1:.4:400)];
end