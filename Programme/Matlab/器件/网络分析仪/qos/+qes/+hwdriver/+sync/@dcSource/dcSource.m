classdef dcSource < qes.hwdriver.sync.instrument
    % dc current or voltage source driver.
    % basic properties and functions of a dc source
    % adcmt 6166: 6161-compatible mode must be set to ON (set by using the instrument front panel)

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
%         dcval   % dc value
        % maximun dc output value, the smallest range for this value is selected. 
        % if empty, instrument will be set to auto range if possible.
        max
        on % true/false, output on/off
        % set to the target dc output value directly or tune to it slowly
        % while setting a new dc value. default: tune
        tune@logical scalar = true 
    end
    properties % (SetAccess = immutable)
        % safty limits, dcvals out of safty limits are rejected.
        safty_limit
    end
    methods (Access = private,Hidden = true)
        function obj = dcSource(name,interfaceobj,drivertype)
            if isempty(interfaceobj)
                error('dcSource:InvalidInput',...
                    'Input ''%s'' can not be empty!',...
                    'interfaceobj');
            end
            if nargin < 3
                drivertype = [];
            end
            obj = obj@qes.hwdriver.sync.instrument(name,interfaceobj,drivertype);
            if nargin > 3
                obj.intinfo = intinfo;
            end
            ErrMsg = obj.InitializeInstr();
            if ~isempty(ErrMsg)
                error('dcSource:InstSetError',[obj.name, ': %s'], ErrMsg);
            end
            obj.chnlProps = {'dcval'};
            obj.chnlPropSetMothds = {@(obj,dcval,chnl)SetDCVal(obj,chnl,dcval)};
            obj.chnlPropGetMothds = {@(obj,chnl)GetDCVal(obj,chnl)};
        end
        [varargout] = InitializeInstr(obj)
        SetRange(obj,val)
        SetOnOff(obj,OnOrOff)
        onstatus = GetOnOff(obj)
        SetAgilent_33120(obj,val)
        SetAdcmt_6166I(obj,val)
        SetAdcmt_6166V(obj,val)
        SetYokogawa_7651I(obj,val)
        SetYokogawa_7651V(obj,val)
        SetFTDA(obj,val,chnl)
    end
    methods (Static)
        obj = GetInstance(name,interfaceobj,drivertype)
    end
    methods
%         function set.dcval(obj,val)
% %            if isempty(val) || ~isnumeric(val) || ~isreal(val)
% %                error('dcSource:InvalidInput',...
% %                    [obj.name, ': Invalid input ''%s''!'],...
% %                    'val');
% %            end
%             if any(val(1) > obj.safty_limit)
%                 error('dcSource:InvalidInput',[obj.name, ': DC value out of safty limit!']);
%             end
%             SetDCVal(obj,val);
%             for ii = 1:obj.numChnls
%                 SetDCVal(obj,val(ii),ii);
%             end
%         end
%         function dcval = get.dcval(obj)
%             dcval = NaN*ones(1,obj.numChnls);
%             for ii = 1:obj.numChnls
%                 dcval(ii) = GetDCVal(obj,ii);
%             end
%         end
        function set.max(obj,val)
            if ~isnumeric(val) || val <= 0
                error('dcSource:SetRange', 'max dcval should be a positive number.');
            end
            SetRange(obj,val);
            obj.max = val;
        end
        function set.on(obj,val)
            if isempty(val)
                error('dcSource:SetOnOff', 'on must be a bolean.');
            end
            if ~islogical(val)
                if val == 0 || val == 1
                    val = logical(val);
                else
                    error('dcSource:SetOnOff', 'on must be a bolean.');
                end
            end
            obj.SetOnOff(val);
            obj.on = val;
        end
        function val = get.on(obj)
            val = GetOnOff(obj);
        end
        function On(obj)
            % set on, this method is introduced for functional
            % programming.
            obj.on = true;
        end
        function Off(obj)
            % set off, this method is introduced for functional
            % programming.
            obj.on = false;
        end
    end
    methods(Hidden = true)
        SetDCVal(obj,val,chnl)
        dcval = GetDCVal(obj,chnl)
    end
end