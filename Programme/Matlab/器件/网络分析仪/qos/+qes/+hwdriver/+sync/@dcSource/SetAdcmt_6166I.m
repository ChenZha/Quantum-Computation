function SetAdcmt_6166I(obj,val)
% adcmt 6166: 6161-compatible mode must be set to ON (set by using the instrument front panel)

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    if abs(val) > obj.max || abs(val) > obj.safty_limit
        error(sprintf('dc level %0.4e great than maximum or safty limit % 0.4e', val, max(obj.max,obj.safty_limit)));
    end
    if isempty(obj.tune) || ~obj.tune % round is automatic in ADCMT_6166
        fprintf(obj.interfaceobj,['SOI', num2str(val(1),'%6e')]);
    else % tune to target output value
        % query current output value
        CurrentOutputStr = query(obj.interfaceobj,'SRC?');  % format: 'SOI+d.ddddddE-d' or 'SOV+d.ddddddE-d'
        CurrentOutput = str2double(CurrentOutputStr(4:end));
        if isnan(CurrentOutput)
            error('dcsource:InstrumentError',...
                    [obj.idstr, ': Failed at instrument query!']);
        end
        if CurrentOutput == val(1)
            return;
        end
        temp = CurrentOutput:...
            sign(val(1)-CurrentOutput)*50e-6:...
            val(1);
        if temp(end) ~= val(1)
            OutputValue = [temp, val(1)];
        else
            OutputValue = temp;
        end
        for ii = 1:length(OutputValue)
            fprintf(obj.interfaceobj,['SOI', num2str(OutputValue(ii),'%6e')]);  % A
            if ii == 1
            	obj.on=1;
            end
            pause(0.2);     % 40 seconds from 0 to 10mA
        end
    end
end