function [varargout] = InitializeInstr(obj)
    % Initialize instrument
    % adcmt 6166: 6161-compatible mode must be set to ON (set by using the instrument front panel)

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    ErrMsg = '';
    TYP = lower(obj.drivertype);
    try
        switch TYP
            case {'agilent33120','hp33120'}
                % todo
                obj.safty_limit = 30;
            case {'adcmt6166i','adcmt6161i'} % as current source
                fprintf(obj.interfaceobj,'IF'); % set to current source mode
                fprintf(obj.interfaceobj,'SIRX');   % set to auto range.
                fprintf(obj.interfaceobj,'LMV3.0E+1');   % set votage safety limit to 30V max
                fprintf(obj.interfaceobj,'LMI1.25E-1');   % set current safety limit to 125mA max
                obj.safty_limit = 50e-3;
                obj.numChnls = 1;
            case {'adcmt6166v','adcmt61661v'}  % as voltage source
                fprintf(obj.interfaceobj,'VF'); % set to voltage source mode
                fprintf(obj.interfaceobj,'SVRX');   % set to auto range.
                % fprintf(DCSource,'V5');   % set to range 10V.
                fprintf(obj.interfaceobj,'LMV3.0E+1');   % set votage safety limit to 30V max
                fprintf(obj.interfaceobj,'LMI1.25E-1');   % set current safety limit to 125mA max
                obj.safty_limit = 30;
                obj.numChnls = 1;
            case {'yokogawa7651i'} % as current source
                fprintf(obj.interfaceobj,'F5'); % set to current source mode
                fprintf(obj.interfaceobj,'R5');   % R4/R5/R6: 1mA/10mA/100mA range, adjust to suit you application
                obj.safty_limit = 50e-3;
                obj.numChnls = 1;
            case {'yokogawa7651v'} % as voltage source
                fprintf(obj.interfaceobj,'F1'); % set to voltage source mode
                fprintf(obj.interfaceobj,'R5');   %  R2/R3/R4/R5/R6: 10mA/100mA/1V/10V/30V range, adjust to suit you application
                obj.safty_limit = 30;
                obj.numChnls = 1;
            case{'ftda'}
                obj.safty_limit = 30;
                obj.numChnls = 4;
            case {'ustc_dadc_v1'}
                obj.numChnls = obj.interfaceobj.numChnls;
                obj.safty_limit = 30;
            otherwise
                 ErrMsg = ['Unsupported instrument: ',TYP];
        end
    catch
        ErrMsg = 'Failed at initializing instrument!';
    end
    varargout{1} = ErrMsg;
end