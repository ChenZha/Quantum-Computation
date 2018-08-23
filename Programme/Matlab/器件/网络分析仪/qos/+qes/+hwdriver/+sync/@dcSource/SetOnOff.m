function SetOnOff(obj,On)
   % set instrument output to on or off
   % adcmt 6166: 6161-compatible mode must be set to ON (set by using the instrument front panel)

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    TYP = lower(obj.drivertype);
    try
        switch TYP
            case {'agilent33120','hp33120'}
                error('todo...');
                % todo
            case {'adcmt6166i','adcmt6166v','adcmt6161i','adcmt6161v'}
                if On
                    fprintf(obj.interfaceobj,'OPR');    % operate
                else
                    fprintf(obj.interfaceobj,'SBY');    % standby
                end
            case {'yokogawa7651i','yokogawa7651v'}
                if On
                    fprintf(obj.interfaceobj,'O1');
                    fprintf(obj.interfaceobj,'E');
                else
                    fprintf(obj.interfaceobj,'O0');
                    fprintf(obj.interfaceobj,'E');
                end
            case {'ustc_dadc_v1'}
                if On
                    % pass
                else
                    for ii = 1:numel(obj.interfaceobj.chnlMap)
                        obj.interfaceobj.SetDC(0,ii);
                    end
                end
            case{'ftda'}
                if On
                   %pass
                else
                   %pass
                end
            otherwise
                 error('DCSource:SetOnOff', ['Unsupported instrument: ',TYP]);
            
        end
    catch
        error('DCSource:SetOnOff', 'Setting instrument failed.');
    end
end