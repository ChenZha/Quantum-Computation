function SetAgilent_33120(obj,val)
% adcmt 6166: 6161-compatible mode must be set to ON (set by using the instrument front panel)

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    if isempty(obj.tune) || ~obj.tune
        OutputValue = 5e-5*round(val(1)/5e-5);
        % round to HP33120 minimum dc output change step:5e-5 volt
        % notes: for HP33120, the set value is the real voltage a
        % 50 Ohm load will get, if the load resistance is much larger
        % than 50 Ohm, the real voltage the load get will be
        % approximately two time the set value.
        fprintf(obj.interfaceobj,['APPL:DC DEF,DEF,',num2str(OutputValue),'V']);
    else % tune to target output value
        % query current output value
        fprintf(obj.interfaceobj,'VOLTage:OFFset?');
        CurrentOutput = str2double(fscanf(obj.interfaceobj));
        if isnan(CurrentOutput)
            error('dcsource:InstrumentError',...
                    [obj.idstr, ': Failed at instrument query!']);
        end
        if CurrentOutput == val(1)
            return;
        end
        temp = CurrentOutput:...
            sign(val(1)-CurrentOutput)*0.05:...
            val(1);
        if temp(end) ~= val(1);
            OutputValue = [temp, val(1)];
        else
            OutputValue = temp;
        end
        OutputValue = 5e-5*round(OutputValue/5e-5);
%         disp('');
%         disp('Setting dc output, please wait...');
        for ii = 1:length(OutputValue)
            % round to HP33120 minimum dc output change step:5e-5 volt
            % notes: for HP33120, the set value is the real voltage a
            % 50 Ohm load will get, if the load resistance is much larger
            % than 50 Ohm, the real voltage the load get will be
            % approximately two time the set value.
            fprintf(DCSource,['APPL:DC DEF,DEF,',num2str(OutputValue(ii)),'V']);
            pause(0.2);         % 40 seconds from 0 to 10V
        end
%         disp('Done!');
%         disp('');
    end
end