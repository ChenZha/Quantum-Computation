function [y, fs] = siren()
    % siren sound
    % sound(sounds.siren)
    % usage:
    % sound(sounds.siren)
    
% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    fs = 8192;
    y = cos((1:.6:3000).^1.1);
end