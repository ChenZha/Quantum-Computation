classdef systemConfig < handle
    % qCloud system configuration
    
% Copyright 2018 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        oneQGates = {}
        oneQGatesLabel = {}
        twoQGates = {}
        twoQGatesLabel = {}
        measureSizeUpperLimit
    end
    properties (SetAccess = private, GetAccess = private)
        qCloudSettingsRoot
    end
    methods
        function obj = systemConfig(qCloudSettingsRoot)
            obj.qCloudSettingsRoot = qCloudSettingsRoot;
        end
        function load(obj)
			s = qes.util.loadSettings(obj.qCloudSettingsRoot, {'systemConfig'});
            fn = fieldnames(s);
			for ii = 1:numel(fn)
				obj.(fn{ii}) = s.(fn{ii});
            end
        end
        function set.measureSizeUpperLimit(obj,val)
            if val < 1
                throw(MException('QOS_qcp:illegalArgumentException',sprintf('zeros or negative measureSizeUpperLimit %0.0f.', val)));
            end
            obj.measureSizeUpperLimit = ceil(val);
        end
    end
end