classdef systemStatus < handle
    % qCloud system status
    
% Copyright 2018 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        status
        fridgeTemperature
        lastLvl1CalibrationTime
        lastLvl2CalibrationTime
        lastLvl3CalibrationTime
        lastLvl4CalibrationTime
        noticeCN
        noticeEN
    end
    properties (Dependent = true)
        lastCalibrationTime
    end
    properties (SetAccess = private, GetAccess = private)
        qCloudSettingsRoot
    end
    properties (Constant = true)
        statusOptions = {'ACTIVE','MAINTENANCE','CALIBRATION','OFFLINE'};
    end
    methods
        function obj = systemStatus(qCloudSettingsRoot)
            obj.qCloudSettingsRoot = qCloudSettingsRoot;
        end
        function load(obj)
			s = qes.util.loadSettings(obj.qCloudSettingsRoot, {'systemStatus'});
            if isempty(s)
                error('settings not found.');
            end
            fn = fieldnames(s);
			for ii = 1:numel(fn)
				obj.(fn{ii}) = s.(fn{ii});
            end
        end
        function val = get.lastCalibrationTime(obj)
            val = max([obj.lastLvl1CalibrationTime,obj.lastLvl2CalibrationTime,...
                obj.lastLvl3CalibrationTime, obj.lastLvl4CalibrationTime]);
        end
        function set.status(obj,val)
            if ~qes.util.ismember(val,obj.statusOptions)
                throw(MException('QOS_qcp:illegalArgumentException',sprintf('%s is not a qcp system status option.', val)));
            end
            obj.status = val;
        end
    end
end