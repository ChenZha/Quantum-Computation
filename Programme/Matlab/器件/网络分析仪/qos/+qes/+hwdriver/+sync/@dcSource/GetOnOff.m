function On = GetOnOff(obj)
   % query instrument output status
   % adcmt 6166: 6161-compatible mode must be set to ON (set by using the instrument front panel)

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    TYP = lower(obj.drivertype);
    try
        switch TYP
            case {'agilent33120','hp33120'}
                error('this part is not finished.');
                % todo
            case {'adcmt6166i','adcmt6166v','adcmt6161i','adcmt6161v'}
                flushinput(obj.interfaceobj); % query dose not flush input butter(R2013b)
                str = query(obj.interfaceobj,'OPR?');    % operate
                if strcmp(str(1:3),'OPR')
                    On = true;
                else
                    On = false;
                end
            case {'yokogawa7651i','yokogawa7651v'}
                error('this part is not finished.');
                % todo
            case {'ustc_dadc_v1'}
                On = true; % always on, off is just output zero
            otherwise
                 error('DCSource:SetOnOff', ['Unsupported instrument: ',TYP]);
        end
    catch
        error('DCSource:SetOnOff', 'Query instrument failed.');
    end
end