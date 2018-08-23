function [y, fs] = notify2()
    % a notify sound
    % usage:
    % sound(sounds.notify2)
    
% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    fs = 8192;
    y = [sin(1:.6:800), sin(1:.7:800), sin(1:.4:800)];
end