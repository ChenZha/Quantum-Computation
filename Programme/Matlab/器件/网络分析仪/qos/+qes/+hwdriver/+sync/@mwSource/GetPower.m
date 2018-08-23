function Power = GetPower(obj,chnl)
% query Power and power from instrument
%

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    TYP = lower(obj.drivertype);
    switch TYP
        case {'agle82xx','agle8200','agl e82xx','agl e8200',...
                'rohde&schwarz sma100', 'r&s sma100',...
                'anritsu_mg3692c'}
            % Frequency = str2double(query(obj.interfaceobj,':SOUR:FREQ?'));
            Power = str2double(query(obj.interfaceobj, ':SOUR:POW?'));
        case {'sc5511a','simulatedmwsrc'}
			Power = obj.interfaceobj.getPower(chnl);
        case {'sinolink'}
            fwrite(obj.interfaceobj,'LEVEL?');
            Power = str2double(char(fread(obj.interfaceobj,obj.interfaceobj.BytesAvailable)'));
        case {'anapico'}
            Power = str2double(query(obj.interfaceobj,['SOURce',num2str(chnl),':POWer?']));
        otherwise
             error('MWSource:QueryError', ['Unsupported instrument: ',TYP]);
    end
end