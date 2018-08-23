function [varargout] = InitializeInstr(obj)
    % Initialize instrument
    %

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    TYP = lower(obj.drivertype);
    ErrMsg = '';
    switch TYP
        case {'agle82xx','agle8200','agl e82xx','agl e8200'}
            fprintf(obj.interfaceobj,'*RST');
            fprintf(obj.interfaceobj,':SOUR:FREQ:MODE FIX');
            fprintf(obj.interfaceobj, ':SOUR:POW:MODE FIX');
            % set reference oscillator source to auto: 
            % Applying a 10 MHz signal to the Reference Oscillator connector automatically sets the
            % Reference Oscillator to EXTernal, when NO signal is present at the 10 MHz
            % Reference Oscillator connector, internal source is used.
            fprintf(obj.interfaceobj, ':ROSCillator:SOURce:AUTO ON');
            obj.freqlimits = [250e-6,40]; % GHz
            obj.powerlimits = [-120,20]; % dBm
            obj.numChnls = 1;
        case {'rohde&schwarz sma100', 'r&s sma100'}
            fprintf(obj.interfaceobj,'*RST');
            fprintf(obj.interfaceobj,':SOUR:FREQ:MODE FIX'); % FIX CW are synonymous
            fprintf(obj.interfaceobj,':SOUR:POW:MODE FIX'); 
            % Applying a 10 MHz signal to the Reference Oscillator connector automatically sets the
            % Reference Oscillator to EXTernal, when NO signal is present at the 10 MHz
            % Reference Oscillator connector, internal source is used.
            fprintf(obj.interfaceobj, ':ROSCillator:SOURce:AUTO ON');
            obj.freqlimits = [9e-6,6]; % GHz
            obj.powerlimits = [-130,20]; % dBm
            obj.numChnls = 1;
        case {'anritsu_mg3692c'}
            fprintf(obj.interfaceobj,'*RST');
            fprintf(obj.interfaceobj,':SOUR:FREQ:MODE FIX'); % FIX CW are synonymous
            fprintf(obj.interfaceobj,':SOUR:POW:MODE FIX'); 
            % Applying a 10 MHz signal to the Reference Oscillator connector automatically sets the
            % Reference Oscillator to EXTernal, when NO signal is present at the 10 MHz
            % Reference Oscillator connector, internal source is used.
            fprintf(obj.interfaceobj, ':ROSCillator:SOURce:AUTO ON');
            obj.freqlimits = [2e9,20e9]; % GHz
            obj.powerlimits = [-130,22]; % dBm
            obj.numChnls = 1;
		case {'sc5511a','simulatedmwsrc'}
			obj.freqlimits = obj.interfaceobj.freqlimits; % GHz
            obj.powerlimits = obj.interfaceobj.powerlimits; % dBm
			obj.numChnls = obj.interfaceobj.numChnls;
        case {'sinolink'}
            obj.freqlimits = [10e6,20e9]; % GHz
            obj.powerlimits = [-50,24]; % dBm
			obj.numChnls = 1;
        case {'anapico'}
            fprintf(obj.interfaceobj,'*RST');
            fprintf(obj.interfaceobj,'SOURce:ROSCillator:SOURce EXTernal');
            obj.freqlimits = [1e6,12.5e9;1e6,12.5e9;1e6,12.5e9;1e6,12.5e9]; % Hz
            obj.powerlimits = [-30,25;-30,25;-30,25;-30,25]; % dBm
			obj.numChnls = 4;
        otherwise
             ErrMsg = ['Unsupported instrument: ',TYP];
    end
    varargout{1} = ErrMsg;
end