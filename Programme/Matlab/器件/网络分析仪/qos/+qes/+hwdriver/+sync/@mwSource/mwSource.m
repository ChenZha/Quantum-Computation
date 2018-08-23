classdef mwSource < qes.hwdriver.sync.instrument
    % microwave source driver

% Copyright 2015 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties % (SetAccess = immutable)
        freqlimits
        powerlimits
    end
    methods (Access = private)
        function obj = mwSource(name,interfaceobj,drivertype)
            if isempty(interfaceobj)
                error('mwSource:InvalidInput',...
                    'Input ''%s'' can not be empty!',...
                    'interfaceobj');
            end
            set(interfaceobj,'Timeout',10); 
            if nargin < 3
                drivertype = [];
            end
            obj = obj@qes.hwdriver.sync.instrument(name,interfaceobj,drivertype);
            ErrMsg = obj.InitializeInstr();
            if ~isempty(ErrMsg)
                error('mwSource:InstSetError',[obj.name, ': %s'], ErrMsg);
            end
            obj.chnlProps = {'frequency','power','on'};
            obj.chnlPropSetMothds = {@(obj,f,chnl)SetFreq(obj,chnl,f),...
                                      @(obj,p,chnl)SetPower(obj,chnl,p),...
									  @(obj,onoff,chnl)SetOnOff(obj,chnl,onoff)};
            obj.chnlPropGetMothds = {@(obj,chnl)GetFreq(obj,chnl),...
                                      @(obj,chnl)GetPower(obj,chnl),...
									  @(obj,chnl)GetOnOff(obj,chnl)};
        end
        [varargout] = InitializeInstr(obj)
    end
    methods (Static)
        obj = GetInstance(name,interfaceobj,drivertype)
    end
    methods
        function On(obj)
            % set on, this method is introduced for functional
            % programming.
			for ii = 1:obj.numChnls
				obj.SetOnOff(true,ii);
			end
        end
        function Off(obj)
            % set off, this method is introduced for functional
            % programming.
            for ii = 1:obj.numChnls
				obj.SetOnOff(false,ii);
			end
        end
        function delete(obj)
            for ii = 1:obj.numChnls
				obj.SetOnOff(false,ii);
			end
        end
    end
    methods (Hidden = true)
        SetPower(obj,val,chnl)
        SetFreq(obj,val,chnl)
        power = GetPower(obj,chnl)
        frequency = GetFreq(obj,chnl)
		SetOnOff(obj,OnOrOff,chnl)
        onstatus = GetOnOff(obj,chnl)
    end
end