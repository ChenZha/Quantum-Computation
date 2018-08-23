function d = SetOnOff(obj,On)
   % set instrument output to on or off

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com
    TYP = lower(obj.drivertype);
    switch TYP
        case {'agle82xx','agle8200','agl e82xx','agl e8200',...
                'rohde&schwarz sma100', 'r&s sma100',...
                'anritsu_mg3692c'}
            if On
                d = fprintf(obj.interfaceobj,':OUTP ON ');
            else
                d = fprintf(obj.interfaceobj,':OUTP OFF ');
            end
        otherwise
            d = mtwisted.defer.fail(...
                mtwisted.Failure(MException(...
                'QOS_hwdriver_MWSource:SetOnOffFail',['Unsupported instrument: ',TYP])));
    end
end