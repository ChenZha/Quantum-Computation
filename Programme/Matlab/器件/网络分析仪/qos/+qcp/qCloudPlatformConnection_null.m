classdef qCloudPlatformConnection_null < handle
    % connects to Quantum Computing Cloud frontend:
    % http://quantumcomputer.ac.cn/index.html
    
% Copyright 2018 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties (SetAccess = private, GetAccess = private)
        backend
        logger
    end
    methods (Access = private)
        function obj = qCloudPlatformConnection_null()
             obj.backend = [];
            obj.logger = qes.util.log4qCloud.getLogger();
            obj.logger.info('qCloud.qCloudPlatformConnection','connection to frontend established.');
        end
    end
    methods (Static = true)
        function obj = GetInstance()
            persistent instance;
            if isempty(instance) || ~isvalid(instance)
                instance = qcp.qCloudPlatformConnection_null();
            end
            obj = instance;
        end
    end
    methods
        function task = getTask(obj)
			task = [];
        end
        function pushTask(obj,circuit,measureQubits,stats,measureType)
        end
        function pushResult(obj,result)
        end
		function numTasks = getNumQueuingTasks(obj)
			numTasks = 0;
		end
		function updateSystemConfig(obj,sysConfig)
		end
		function updateSystemStatus(obj,sysStatus)
		end
		function updateOneQGateFidelities(obj,s)
        end
        function commitOneQGateFidelities(obj)
        end
		function updateTwoQGateFidelities(obj,s)
        end
        function commitTwoQGateFidelities(obj)
        end
		function updateQubitParemeters(obj,s)
        end
        function commitQubitParameters(obj)
        end
        function addTestUser(obj,userName)
        end
    end
end