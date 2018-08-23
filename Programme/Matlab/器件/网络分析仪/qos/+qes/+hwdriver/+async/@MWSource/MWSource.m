classdef MWSource < qes.hwdriver.Instrument
    % microwave source driver, async

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties % (AbortSet = true) do not use AbortSet
        frequency   % Hz
        power       % dBm
        on % true/false, output on/off
    end
    properties % (SetAccess = immutable)
        freqlimits
        powerlimits
    end
    methods (Access = private)
        function obj = MWSource(name,interfaceobj,drivertype)
            if isempty(interfaceobj)
                error('MWSource:InvalidInput',...
                    'Input ''%s'' can not be empty!',...
                    'interfaceobj');
            end
            interfaceobj.Timeout = 10;
            if nargin < 3
                drivertype = [];
            end
            obj = obj@qes.hwdriver.Instrument(name,interfaceobj,drivertype);
            ErrMsg = obj.InitializeInstr();
            if ~isempty(ErrMsg)
                error('MWSource:InstSetError',[obj.name, ': %s'], ErrMsg);
            end
        end
        d = InitializeInstr(obj)
        d = SetPower(obj,val)
        d = SetFreq(obj,val)
        [Freq, Power]=GetFreqPwer(obj)
        d = SetOnOff(obj,OnOrOff)
        onstatus = GetOnOff(obj)
    end
    methods (Static)
        obj = GetInstance(name,interfaceobj,drivertype)
    end
    methods
        function set.frequency(obj,val)
            if isempty(val)
                obj.frequency = val;
                return;
            end
            if isempty(val) || ~isnumeric(val) || ~isreal(val) || val <= 0
                error('MWSource:SetError','Invalid frequency value.');
            end
            if ~isempty(obj.freqlimits) &&...
                    (val < obj.freqlimits(1) || val > obj.freqlimits(2))
                warning('MWSource:OutOfLimit','Frequency value out of limits.');
                return;
            end
            d = SetFreq(obj,val);
            obj.frequency = val;
        end
        function frequency = get.frequency(obj)
            [frequency, ~] = GetFreqPwer(obj);
        end
        function set.power(obj,val)
            if isempty(val) || ~isnumeric(val) || ~isreal(val)
                error('MWSource:SetError','Invalid power value.');
            end
            if ~isempty(obj.powerlimits) &&...
                    (val < obj.powerlimits(1) || val > obj.powerlimits(2))
                warning('MWSource:OutOfLimit',[obj.name, ': Power value out of limits!']);
                return;
            end
            SetPower(obj,val);
            obj.power = val;
        end
        function power = get.power(obj)
            [~, power] = GetFreqPwer(obj);
        end
        function set.on(obj,val)
            if isempty(val)
                error('MWSource:SetOnOff', 'value of ''on'' must be a bolean.');
            end
            if ~islogical(val)
                if val == 0 || val == 1
                    val = logical(val);
                else
                    error('MWSource:SetOnOff', 'value of ''on'' must be a bolean.');
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
        function delete(obj)
            obj.on = false;
        end
    end
end