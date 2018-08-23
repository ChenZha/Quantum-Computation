function [varargout] = InitializeInstr(obj)
    % Initialize instrument
    %

% Copyright 2016 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    TYP = lower(obj.drivertype);
    ErrMsg = '';
    try
        switch TYP
            case {'tekdpo7000','oscilloscope_dpo70404'}
                obj.timeout = 120; % seconds
                if strcmp(obj.interfaceobj.Status,'open')
                    fclose(obj.interfaceobj);
                end
                obj.interfaceobj.Timeout=30; 
                obj.interfaceobj.InputBufferSize = 20000000; % bytes, should be enough for most applications
                if strcmp(obj.interfaceobj.Status,'closed')
                    fopen(obj.interfaceobj);
                end
%                fprintf(obj.interfaceobj,'*RST');
                % set work mode to linear(default)
%                fprintf(obj.interfaceobj,':INITiate:IMMediate'); % trig
            otherwise
                 ErrMsg = ['Unsupported instrument: ',TYP];
        end
    catch
        ErrMsg = 'Could not initialize instrument!';
    end
    varargout{1} = ErrMsg;
end