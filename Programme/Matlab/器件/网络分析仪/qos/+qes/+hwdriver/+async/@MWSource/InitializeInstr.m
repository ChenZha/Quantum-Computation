function d = InitializeInstr(obj)
    % Initialize instrument
    % set reference oscillator source to auto: 
    % Applying a 10 MHz signal to the Reference Oscillator connector automatically sets the
    % Reference Oscillator to EXTernal, when NO signal is present at the 10 MHz
    % Reference Oscillator connector, internal source is used.

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    TYP = lower(obj.drivertype);
    switch TYP
        case {'agle82xx','agle8200','agl e82xx','agl e8200'}
            % implement a deferred list
            [d1,d2,d3,d4] = Set_Agle82xx_rssma100_anritsu_mg36xx(obj);
            obj.freqlimits = [250e-6,40]; % GHz
            obj.powerlimits = [-120,20]; % dBm
        case {'rohde&schwarz sma100', 'r&s sma100'}
            d = Set_Agle82xx_rssma100_anritsu_mg36xx(obj);
        case {'anritsu_mg3692c'}
            d = Set_Agle82xx_rssma100_anritsu_mg36xx(obj);
            obj.freqlimits = [2e9,20e9]; % GHz
            obj.powerlimits = [-130,22]; % dBm
        otherwise
            d = mtwisted.defer.fail(...
                mtwisted.Failure(MException(...
                'qes:hwdriver:MWSource:InitializeInstrFail',['Unsupported instrument: ',TYP])));
    end
end

function [d1,d2,d3,d4] = Set_Agle82xx_rssma100_anritsu_mg36xx(obj)
    d1 = fprintf(obj.interfaceobj,'*RST');
    d2 = fprintf(obj.interfaceobj,':SOUR:FREQ:MODE FIX');
    d3 = fprintf(obj.interfaceobj,':SOUR:POW:MODE FIX');
    d4 = fprintf(obj.interfaceobj,':ROSCillator:SOURce:AUTO ON');
end
