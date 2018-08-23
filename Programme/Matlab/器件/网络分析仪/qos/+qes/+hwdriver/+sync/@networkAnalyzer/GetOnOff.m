function bol = GetOnOff(obj)
   % Get instrument output to on or off

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com
    TYP = lower(obj.drivertype);
    try
        switch TYP
            case {'agilent_n5230c'}
                str = query(obj.interfaceobj,':OUTPut:STATe?');
                bol = logical(str2double(str));
            case {'agilent_e5071c'}
                str = query(obj.interfaceobj,':OUTPut:STATe?');
                bol = logical(str2double(str));
            otherwise
                  error('SParamMeter:GetOnOff', ['Unsupported instrument: ',TYP]);
        end
    catch
        error('SParamMeter:GetOnOff', 'Query instrument failed.');
    end
end