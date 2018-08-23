function SetYokogawa_7651V(obj,val)
%

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    if isempty(obj.tune) || ~obj.tune	% round is automatic in ADCMT_6166
        fprintf(obj.interfaceobj,['SA', num2str(val(1),'%0.6E')]);
    else % tune to target output value
        % query current output value
        fprintf(obj.interfaceobj,'SA?');
        CurrentOutput = str2double(fscanf(obj.interfaceobj));
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
            fprintf(obj.interfaceobj,['SA', num2str(OutputValue(ii),'%0.6E')]);
            if ii == 1
            	obj.on = true;
            end
            pause(0.2);
        end
    end
end