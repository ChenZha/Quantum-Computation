function dcval = GetDCVal(obj,chnl)
    % query dc value from instrument
    % adcmt 6166: 6161-compatible mode must be set to ON (set by using the instrument front panel)

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    TYP = lower(obj.drivertype);
    try
        switch TYP
            case {'agilent33120','hp33120'}
                flushinput(obj.interfaceobj); % query dose not flush input butter(R2013b)
                dcval = str2double(query(obj.interfaceobj,'VOLTage:OFFset?'));
            case {'adcmt6166i','adcmt6166v','adcmt6161i','adcmt6161v'}
                flushinput(obj.interfaceobj); % query dose not flush input butter(R2013b)
                CurrentOutputStr = query(obj.interfaceobj,'SRC?');  % format: 'SOI+d.ddddddE-d' or 'SOV+d.ddddddE-d'
                dcval = str2double(CurrentOutputStr(4:end));
            case {'yokogawa7651i','yokogawa7651v'}
                flushinput(obj.interfaceobj); % query dose not flush input butter(R2013b)
                dcval = str2double(query(obj.interfaceobj,'SA?'));
            case {'ustc_dadc_v1'}
                dcval = obj.dcval(chnl);
            case{'ftda'}
                fopen(obj.interfaceobj);
                str=sprintf('DA=%d;RW=0;ADDR=0x01;VAL=0x%05X',chnl,0);
                fprintf(obj.interfaceobj, str);
                str= fscanf(obj.interfaceobj,'%s',7);
                fclose(obj.interfaceobj);%��CPU�еĹر���ϳɶԳ���

                result =  sscanf(str,'0x%05X'); %��obj.str���ַ���ת�������֣�Ŀǰ����ֵ�Ǹ�24λ16����������Ҫ�����ǰ4bit��֮����޸Ĺ̼���ֱ�ӷ���20λʮ������������0x����
                dcval=result;
                %                 fprintf('Readback 0x%05X\n', result);%�����ã���ӡһ�»ض�ֵ
%                 obj.Close();
            otherwise
                 error('DCSource:GetDCVal', ['Unsupported instrument: ',TYP]);
        end
    catch
        error('DCSource:GetDCVal', 'Query instrument failed.');
    end
end