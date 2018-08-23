function StopContinuousWv(obj,chnl)
    %
    %

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    TYP = lower(obj.drivertype);
    switch TYP
        case {'ustc_da_v1'}
            obj.interfaceobj.StopContinuousRun(chnl);
        otherwise
            error('AWG:SetRunModeError','Unsupported awg!');
    end
end
