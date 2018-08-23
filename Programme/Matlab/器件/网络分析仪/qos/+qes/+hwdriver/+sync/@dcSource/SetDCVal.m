function SetDCVal(obj,val,chnl)
    % set instrument dc output value
    % adcmt 6166: 6161-compatible mode must be set to ON (set by using the instrument front panel)

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    TYP = lower(obj.drivertype);
    switch TYP
        case {'agilent33120','hp33120'}  % as voltage source
            SetAgilent_33120(obj,val);
            obj.dcval(chnl) = val;
        case {'adcmt6166i','adcmt6161i'} % as current source
            SetAdcmt_6166I(obj,val);
            obj.dcval(chnl) = val;
        case {'adcmt6166v','adcmt6161v'} % as current source
            SetAdcmt_6166V(obj,val);
            obj.dcval(chnl) = val;
        case {'yokogawa7651i'} % as current source
            SetYokogawa_7651I(obj,val);
            obj.dcval(chnl) = val;
        case {'yokogawa7651v'} % as current source
            SetYokogawa_7651V(obj,val);
            obj.dcval(chnl) = val;
        case {'ustc_dadc_v1'}
            if obj.dcval(chnl) ~= val
                obj.interfaceobj.SetDC(val,chnl);
                obj.dcval(chnl) = val;
            end
        case {'ftda'}
            if obj.dcval(chnl) ~= val
                SetFTDA(obj,val,chnl);
                obj.dcval(chnl) = val;
            end
        otherwise
             error('DCSource:SetDCVal', ['Unsupported instrument: ',TYP]);
    end
    
%     % to have things flushing out on screen, keep for occassions like TV interviews 
%     disp(sprintf('setting power of dc src [%s] to %0.3f on chnl %0.0f',...
%                 obj.name,val,chnl));
end