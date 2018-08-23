function SetAdcmt_6166V(obj,val)
% adcmt 6166: 6161-compatible mode must be set to ON (set by using the instrument front panel)

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    if isempty(obj.tune) || ~obj.tune % round is automatic in ADCMT_6166
        fprintf(obj.interfaceobj,['SOV', num2str(val(1),'%6e')]);
    else % tune to target output value
        % query current output value
        fprintf(obj.interfaceobj,'SRC?');
        CurrentOutputStr=fscanf(obj.interfaceobj);      % format: 'SOI+d.ddddddE-d' or 'SOV+d.ddddddE-d'
        CurrentOutput = str2double(CurrentOutputStr(4:end));
        if isnan(CurrentOutput)
            error('dcsource:InstrumentError',...
                    [obj.idstr, ': Failed at instrument query!']);
        end
        if CurrentOutput == val(1)
            return;
        end
        temp = CurrentOutput:...
            sign(val(1)-CurrentOutput)*5e-2:...
            val(1);
        if temp(end) ~= val(1);
            OutputValue = [temp, val(1)];
        else
            OutputValue = temp;
        end
        for ii = 1:length(OutputValue)
            fprintf(obj.interfaceobj,['SOV', num2str(OutputValue(ii),'%6e')]);  % A
            if ii == 1
            	obj.On();
            end
            pause(0.2);
        end
    end
end