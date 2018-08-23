function SetPower(obj,val)
% set microwave source frequecy and power
%

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    TYP = lower(obj.drivertype);
    switch TYP
        case {'agilent e82xx','agilent e8200','agle82xx','agle8200','agl e82xx','agl e8200',...
                'anritsu_mg3692c'}
            d = fprintf(obj.interfaceobj,[':SOUR:POWER ',num2str(val(1),'%0.2f'),'DBM']);
        case {'rohde&schwarz sma100', 'r&s sma100','rssma100'}
            d = fprintf(obj.interfaceobj,[':SOUR:POW ',num2str(val(1),'%0.2f')]);
        otherwise
            d = mtwisted.defer.fail(...
                mtwisted.Failure(MException(...
                'QOS_hwdriver_MWSource:SetPowerFail',sprintf('Unsupported instrument: %s',TYP))));
    end
end