function SetOnOff(obj,On)
   % set instrument output to on or off

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com
    TYP = lower(obj.drivertype);
    try
        switch TYP
            case {'agilent_n5230c'}
                if On
                    fprintf(obj.interfaceobj,':OUTPut:STATe ON');
                else
                    fprintf(obj.interfaceobj,':OUTPut:STATe OFF');
                end
            case {'agilent_e5071c'}
                if On
                    fprintf(obj.interfaceobj,':OUTPut:STATe ON');
                else
                    fprintf(obj.interfaceobj,':OUTPut:STATe OFF');
                end
            otherwise
                  error('SParamMeter:SetOnOff', ['Unsupported instrument: ',TYP]);
        end
    catch
        error('SParamMeter:SetOnOff', 'Setting instrument failed.');
    end
end