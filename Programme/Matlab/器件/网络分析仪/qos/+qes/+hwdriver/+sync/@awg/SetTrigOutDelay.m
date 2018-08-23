function SetTrigOutDelay(obj,chnl,delay)
    % Set trigger output delay
    %

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    TYP = lower(obj.drivertype);
    switch TYP
        case {'tek5000','tek5k',...
              'tek7000','tek7k',...
              'tek70000','tek70k'}
            % AWG: Tecktronix AWG 5000,7000,70000
            % pass, not support
        case {'ustc_da_v1'}
            obj.interfaceobj.SetBoardTrigDelayByChnl(chnl,delay);
        otherwise
            error('AWG:SetTrigIntervalError','Unsupported awg!');
    end
end
