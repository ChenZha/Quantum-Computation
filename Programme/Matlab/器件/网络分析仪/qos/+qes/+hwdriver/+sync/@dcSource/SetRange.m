function SetRange(obj, val)
    % Set range
    % adcmt 6166: 6161-compatible mode must be set to ON (set by using the instrument front panel)

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    TYP = lower(obj.drivertype);
    try
        switch TYP
            case {'agilent33120','hp33120'}
                % todo
            case {'adcmt6166i','adcmt6161i'} % as current source
                if isempty(val)
                    fprintf(obj.interfaceobj,'SIRX');   % set to auto range.
                elseif val(1) <= 1e-3
                    fprintf(obj.interfaceobj,'I1');
                elseif val(1) <= 10e-3
                    fprintf(obj.interfaceobj,'I2');
                elseif val(1) <= 100e-3
                    fprintf(obj.interfaceobj,'I3');
                else
                    error('DCSource:SetRange', 'max dcval too large, no suitable range.');
                end
            case {'adcmt6166v','adcmt 61661v'}  % as voltage source
                 if isempty(val)
                     fprintf(obj.interfaceobj,'SVRX');   % set to auto range.
                 elseif val(1) <= 1
                    fprintf(obj.interfaceobj,'V4');
                elseif val(1) <= 10
                    fprintf(obj.interfaceobj,'V5');
                elseif val(1) <= 100
                    fprintf(obj.interfaceobj,'V6');
                elseif val(1) <= 1000
                    fprintf(obj.interfaceobj,'V7');
                else
                    error('DCSource:SetRange', 'max dcval too large, no suitable range.');
                end
            case {'yokogawa7651i'} % as current source
                if isempty(val)
                    fprintf(obj.interfaceobj,'R6');   % yokogawa7651 dose not support auto range, select the max range
                elseif val(1) <= 1e-3
                    fprintf(obj.interfaceobj,'R4');
                elseif val(1) <= 10e-3
                    fprintf(obj.interfaceobj,'R5');
                elseif val(1) <= 100e-3
                    fprintf(obj.interfaceobj,'R6');
                else
                    error('DCSource:SetRange', 'max dcval too large, no suitable range.');
                end
            case {'yokogawa7651v'} % as voltage source
                if isempty(val)
                    fprintf(obj.interfaceobj,'R6');   % yokogawa7651 dose not support auto range, select the max range
                elseif val(1) <= 100-3
                    fprintf(obj.interfaceobj,'R2');   
                elseif val(1) <= 100e-3
                    fprintf(obj.interfaceobj,'R3');   
                elseif val(1) <= 1
                    fprintf(obj.interfaceobj,'R4');   
                elseif val(1) <= 10
                    fprintf(obj.interfaceobj,'R5');   
                elseif val(1) <= 30
                    fprintf(obj.interfaceobj,'R6');   
                else
                    error('DCSource:SetRange', 'max dcval too large, no suitable range.');
                end
            case {'ustc_dadc_v1'}
                % pass
            otherwise
                  error('DCSource:SetRange', ['Unsupported instrument: ',TYP]);
        end
    catch
        error('DCSource:SetRange', 'Setting instrument failed.');
    end
end