function [varargout] = InitializeInstr(obj)
    % Initialize instrument
    %

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    TYP = lower(obj.drivertype);
    ErrMsg = '';
    try
        switch TYP
            case {'agilent_n5230c'}
                if strcmp(obj.interfaceobj.Status,'open')
                    fclose(obj.interfaceobj);
                end
                obj.interfaceobj.Timeout=120; 
                obj.interfaceobj.InputBufferSize = 2000000; % bytes, should be enough for most applications
                if strcmp(obj.interfaceobj.Status,'closed')
                    fopen(obj.interfaceobj);
                end
                fprintf(obj.interfaceobj,'*RST');
                % set work mode to linear(default)
                fprintf(obj.interfaceobj,':INITiate:IMMediate'); % trig
                obj.DeleteMeasurement(); % after reset, a default measurement is automatically created by the instrument, we don't need it.
                obj.numports = 2; % 2 ports
            case {'agilent_e5071c'}
                if strcmp(obj.interfaceobj.Status,'open')
                    fclose(obj.interfaceobj);
                end
                obj.interfaceobj.Timeout=120; 
                obj.interfaceobj.InputBufferSize = 2000000; % bytes, should be enough for most applications
                if strcmp(obj.interfaceobj.Status,'closed')
                    fopen(obj.interfaceobj);
                end
                fprintf(obj.interfaceobj,'*RST');
                % set work mode to linear(default)
                % setup trig mode
                fprintf(obj.interfaceobj,':TRIG:SEQ:SOUR BUS');
                fprintf(obj.interfaceobj,':TRIG:AVER ON');
                obj.DeleteMeasurement(); % after reset, a default measurement is automatically created by the instrument, we don't need it.
                obj.numports = 2; % 2 ports
            otherwise
                 ErrMsg = ['Unsupported instrument: ',TYP];
        end
    catch
        ErrMsg = 'Could not initialize instrument!';
    end
    varargout{1} = ErrMsg;
end