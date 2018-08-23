function [d1, d2] = GetFreqPwer(obj)
% query frequency and power from instrument
%

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    TYP = lower(obj.drivertype);
    switch TYP
        case {'agle82xx','agle8200','agl e82xx','agl e8200',...
                'rohde&schwarz sma100', 'r&s sma100',...
                'anritsu_mg3692c'}
            d1 = query(obj.interfaceobj,':SOUR:FREQ?');
            d1.addCallback(@(x)str2double(x));
            d2 = mtwisted.defer.wrap(@obj.interfaceobj.fprintf,':SOUR:POW?');
            d2.addCallback(@(x)str2double(x));
        otherwise
            d1 = mtwisted.defer.fail(...
                mtwisted.Failure(MException(...
                'qes:hwdriver:MWSource:GetFreqPwerFail',['Unsupported instrument: ',TYP])));
            d2 = d1;
    end
end
