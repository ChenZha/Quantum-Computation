function Run(obj,chnl,N)
    % Run awg to output waveform N times, wave data should be already transfered
    % to AWG. N < 1, stop

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    N = round(N);
    TYP = lower(obj.drivertype);
    switch TYP
        case {'ustc_da_v1'}
             obj.interfaceobj.Run(N);
        otherwise
            error('AWG:OffError','Unsupported awg!');
    end
end