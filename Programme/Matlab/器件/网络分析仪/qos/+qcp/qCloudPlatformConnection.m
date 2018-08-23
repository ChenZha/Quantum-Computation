classdef qCloudPlatformConnection < handle
    % connects to Quantum Computing Cloud frontend:
    % http://quantumcomputer.ac.cn/index.html
    
% Copyright 2018 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties (SetAccess = private, GetAccess = private)
        backend
        logger
    end
    methods (Access = private)
        function obj = qCloudPlatformConnection()
             obj.backend = com.alibaba.quantum.impl.QuantumComputerPlatformHttpClientImplV2();
%             obj.backend = com.alibaba.quantum.impl.QuantumComputerPlatformServiceV2MockImpl();
            obj.logger = qes.util.log4qCloud.getLogger();
            obj.logger.info('qCloud.qCloudPlatformConnection','connection to frontend established.');
        end
    end
    methods (Static = true)
        function obj = GetInstance()
            persistent instance;
            if isempty(instance) || ~isvalid(instance)
                instance = qcp.qCloudPlatformConnection();
            end
            obj = instance;
        end
    end
    methods
        function task = getTask(obj)
			resp = obj.backend.getNumQueuingTasks();
			if ~resp.isSuccess()
                msg = cell(resp.getMessage());
                obj.logger.error('qCloud.getTask',msg{1});
                throw(MException('QOS:qCloudPlatformConnection:getTaskException',msg{1}));
            end
			numQueuingTasks = resp.getData();
			if numQueuingTasks == 0
				task = [];
				return;
			end
            obj.logger.info('qCloud.getTask','getting task...');
            resp = obj.backend.getTask();
            if ~resp.isSuccess()
                msg = cell(resp.getMessage());
                obj.logger.error('qCloud.getTask',msg{1});
                throw(MException('QOS:qCloudPlatformConnection:getTaskException',msg{1}));
            end
            jTask = resp.getData();
            if isempty(jTask)
                obj.logger.info('qCloud.getTask',resp.getMessage());
                task = [];
                return;
            end
            task = struct();
            task.taskId = jTask.getTaskId();
            task.userId = jTask.getUserId();
            task.stats = jTask.getStats();
            circuit = cell(jTask.getCircuit());
            nc = size(circuit,2);
            idleQInd = [];
            opQubits = {};
            for ii = 1:nc
                if all(strcmp(circuit(:,ii),'I') | strcmp(circuit(:,ii),''))
                    idleQInd = [idleQInd, ii];
                else
                    opQubits{end+1} = ['q',num2str(ii,'%0.0f')];
                end
            end
            circuit(:,idleQInd) = [];
            sz = size(circuit);
            for ii = 1:sz(1)
                for jj = 1:sz(2)
                    if length(circuit{ii,jj}) > 2 && strcmp(circuit{ii,jj}(1:3),'CZ_')
                        circuit{ii,jj} = 'CZ';
                    end
                    gate_ = circuit{ii,jj};
                    pStartInd = regexp(circuit{ii,jj},'_.+');
                    if ismember(circuit{ii,jj}(1:pStartInd-1),{'Rx','Ry','Rz','Rxy'})
                        convertDeg2Rad = true;
                    else
                        convertDeg2Rad = false;
                    end
                    if ~isempty(pStartInd)
                        circuit{ii,jj}(pStartInd(1)) = '(';
                        circuit{ii,jj} = [circuit{ii,jj},')'];
                        sInd = regexp(circuit{ii,jj},'_.+');
                        if isempty(sInd)
                            if convertDeg2Rad
                                circuit{ii,jj} = [circuit{ii,jj}(1:pStartInd),...
                                    num2str(str2double(circuit{ii,jj}(pStartInd+1:end-1))*pi/180,'%0.5f'),')'];
                            end
                            continue;
                        elseif length(sInd) > 1
                            obj.logger.info('qCloud.getTask',sprintf('illegal gate format %s in task: %s',...
                                    gate_, num2str(task.taskId,'%0.0f')));
                        else
                            if convertDeg2Rad
                                circuit{ii,jj} = [circuit{ii,jj}(1:pStartInd),...
                                    num2str(str2double(circuit{ii,jj}(pStartInd+1:sInd-1))*pi/180,'%0.5f'),...
                                    ','...
                                    num2str(str2double(circuit{ii,jj}(sInd+1:end-1))*pi/180,'%0.5f'),...
                                    ')'];
                            else
                                circuit{ii,jj}(sInd) = ',';
                            end
                        end
                    end
                end
            end
            for jj = 1:sz(2)
                if strcmp(circuit{sz(1),jj},'M')
                    circuit(sz(1),:) = [];
                    break;
                end
            end
            task.circuit = circuit;
            task.opQubits = opQubits;
            task.measureQubits = cell(jTask.getMeasureQubits()).';
            measureQubits = cell(jTask.getMeasureQubits()).';
            numMQs = numel(measureQubits);
            if numMQs == 0
                measureQubits = opQubits;
            else
                for ii = 1:numMQs
                    measureQubits{ii} = ['q',num2str(str2double(measureQubits{ii}(2:end))+1,'%0.0f')];
                end
            end
            task.measureQubits = fliplr(measureQubits);
            task.measureType = jTask.getMeasureType();
            task.submissionTime = jTask.getSubmissionTime();
            task.useCache = jTask.isUseCache();
            obj.logger.info('qCloud.getTask',['got task, task id: ',...
                num2str(task.taskId,'%0.0f')]);
        end
        function pushTask(obj,circuit,measureQubits,stats,measureType)
            % for testing
            obj.logger.info('qCloud.pushTask','pushing task...');
            jTask = com.alibaba.quantum.domain.v2.QuantumTask();
            jTask.setCircuit(circuit);
            jTask.setMeasureQubits(measureQubits);
            jTask.setStats(stats);
            jTask.setMeasureType(measureType)
            resp = obj.backend.pushTask(jTask);
            if ~resp.isSuccess()
                msg = cell(resp.getMessage());
                obj.logger.error('qCloud.pushTask',msg{1});
                throw(MException('QOS:qCloudPlatformConnection:pushTaskException',msg{1}));
            end
            obj.logger.info('qCloud.pushTask','push task to server done.');
        end
        function pushResult(obj,result)
            obj.logger.info('qCloud.pushResult',['pushing result, task id: ',...
                num2str(result.taskId,'%0.0f')]);
            jResult = com.alibaba.quantum.domain.v2.QuantumResult();
            jResult.setTaskId(result.taskId);
            jResult.setFinalCircuit(result.finalCircuit);
            jResult.setResult(result.result);
            jResult.setFidelity(result.fidelity);
            jResult.setSingleShotEvents(result.singleShotEvents);
            jResult.setWaveforms(result.waveforms);
            jResult.setNoteCN(result.noteCN);
            jResult.setNoteEN(result.noteEN);
            resp = obj.backend.pushResult(jResult);
            if isempty(resp)
                obj.logger.error('qCloud.pushResult',msg{1});
                throw(MException('QOS:qCloudPlatformConnection:pushResultException',msg{1}));
            end
            if ~resp.isSuccess()
                msg = cell(resp.getMessage());
                obj.logger.error('qCloud.pushResult',msg{1});
                throw(MException('QOS:qCloudPlatformConnection:pushResultException',msg{1}));
            end
            obj.logger.info('qCloud.pushResult','push result done.');
        end
		function numTasks = getNumQueuingTasks(obj)
			resp = obj.backend.getNumQueuingTasks();
            if ~resp.isSuccess()
                msg = cell(resp.getMessage());
                obj.logger.error('qCloud.getNumQueuingTasks',msg{1});
                throw(MException('QOS:qCloudPlatformConnection:getNumQueuingTasksException',msg{1}));
            end
			numTasks = resp.getData();
		end
		function updateSystemConfig(obj,sysConfig)
            obj.logger.info('qCloud.updateSystemConfig','updating system configuration...');
            jSysConfig = com.alibaba.quantum.domain.v2.SystemConfig();
            jSysConfig.setOneQGates(sysConfig.oneQGates);
            jSysConfig.setOneQGatesLabel(sysConfig.oneQGatesLabel);
			jSysConfig.setTwoQGates(sysConfig.twoQGates);
            jSysConfig.setTwoQGatesLabel(sysConfig.twoQGatesLabel);
            jSysConfig.setMeasureSizeUpperLimit(sysConfig.measureSizeUpperLimit);
            resp = obj.backend.updateSystemConfig(jSysConfig);
            if ~resp.isSuccess()
                msg = cell(resp.getMessage());
                obj.logger.error('qCloud.updateSystemConfig',msg{1});
                throw(MException('QOS:qCloudPlatformConnection:updateSystemConfigException',msg{1}));
            end
            obj.logger.info('qCloud.updateSystemConfig','system configuration updated.');
		end
		function updateSystemStatus(obj,sysStatus)
            obj.logger.info('qCloud.updateSystemStatus','updating system status...');
			jSysStatus = com.alibaba.quantum.domain.v2.SystemStatus();
			switch sysStatus.status
				case 'ACTIVE'
					jSysStatus.setStatus(...
                        javaMethod('valueOf','com.alibaba.quantum.domain.v2.SystemStatus$Status','ACTIVE'));
                case 'MAINTENANCE'
					jSysStatus.setStatus(...
                        javaMethod('valueOf','com.alibaba.quantum.domain.v2.SystemStatus$Status','MAINTANANCE'));
				case 'CALIBRATION'
					jSysStatus.setStatus(...
                        javaMethod('valueOf','com.alibaba.quantum.domain.v2.SystemStatus$Status','CALIBRATION'));
				case 'OFFLINE'
					jSysStatus.setStatus(...
                        javaMethod('valueOf','com.alibaba.quantum.domain.v2.SystemStatus$Status','OFFLINE'));
                otherwise
                    obj.logger.error('qCloud.updateSystemStatus',['invalid status settings: ', sysStatus.status]);
                    throw(MException('QOS:qCloudPlatformConnection:updateSystemStatusException',...
                        ['invalid status settings: ', sysStatus.status]));
			end
            jSysStatus.setFridgeTemperature(sysStatus.fridgeTemperature);
            jSysStatus.setLastCalibrationTime(datestr(sysStatus.lastCalibrationTime,'yyyy-mm-dd HH:MM:SS'));
            if ~iscell(sysStatus.noticeCN)
                noticeCN = sysStatus.noticeCN;
            else
                noticeCN = '';
                for ii = 1:numel(sysStatus.noticeCN)
                    noticeCN = [noticeCN,sysStatus.noticeCN{ii}];
                end
            end
			jSysStatus.setNoticeCN(noticeCN);
            if ~iscell(sysStatus.noticeEN)
                noticeEN = sysStatus.noticeEN;
            else
                noticeEN = '';
                for ii = 1:numel(sysStatus.noticeEN)
                    noticeEN = [noticeEN,sysStatus.noticeEN{ii}];
                end
            end
            jSysStatus.setNoticeEN(noticeEN);
            resp = obj.backend.updateSystemStatus(jSysStatus);
            if ~resp.isSuccess()
                msg = cell(resp.getMessage());
                obj.logger.error('qCloud.updateSystemStatus',msg{1});
                throw(MException('QOS:qCloudPlatformConnection:updateSystemStatusException',resp.getMessage));
            end
            obj.logger.info('qCloud.updateSystemStatus','system status updated.');
		end
		function updateOneQGateFidelities(obj,s)
            obj.logger.info('qCloud.updateOneQGateFidelities',['updating gate fidelities for qubit: ',...
                num2str(s.qubit,'%0.0f')]);
            jOneQGateFidelities = com.alibaba.quantum.domain.v2.OneQGateFidelities();
            jOneQGateFidelities.setQubit(s.qubit);
            % negative value, no data, java: null
            if s.X > 0
                jOneQGateFidelities.setX(java.lang.Float(s.X));
            end
            if s.X2p > 0
                jOneQGateFidelities.setX2p(java.lang.Float(s.X2p));
            end
            if s.X2m > 0
                jOneQGateFidelities.setX2m(java.lang.Float(s.X2m));
            end
            if s.Y > 0
                jOneQGateFidelities.setY(java.lang.Float(s.Y));
            end
            if s.Y2p > 0
                jOneQGateFidelities.setY2p(java.lang.Float(s.Y2p));
            end
            if s.Y2m > 0
                jOneQGateFidelities.setY2m(java.lang.Float(s.Y2m));
            end
            if s.Z > 0
                jOneQGateFidelities.setZ(java.lang.Float(s.Z));
            end
            if s.Z2p > 0
                jOneQGateFidelities.setZ2p(java.lang.Float(s.Z2p));
            end
            if s.Z2m > 0
                jOneQGateFidelities.setZ2m(java.lang.Float(s.Z2m));
            end
            if s.H > 0
                jOneQGateFidelities.setH(java.lang.Float(s.H));
            end
            obj.backend.updateOneQGateFidelities(jOneQGateFidelities);
%             if ~resp.isSuccess()
%                 msg = cell(resp.getMessage());
%                 obj.logger.error('qCloud.updateOneQGateFidelities',msg{1});
%                 throw(MException('QOS:qCloudPlatformConnection:updateOneQGateFidelities',msg{1}));
%             end
%             obj.logger.info('qCloud.updateOneQGateFidelities','gate fidelities updated.');
        end
        function commitOneQGateFidelities(obj)
            obj.logger.info('qCloud.commitOneQGateFidelities','commit one qubit gate fidelities.');
            resp = obj.backend.commitOneQGateFidelities();
            if ~resp.isSuccess()
                msg = cell(resp.getMessage());
                obj.logger.error('qCloud.commitOneQGateFidelities',msg{1});
                throw(MException('QOS:qCloudPlatformConnection:commitOneQGateFidelities',msg{1}));
            end
            obj.logger.info('qCloud.commitOneQGateFidelities','one qubit gate fidelities updated.');
        end
		function updateTwoQGateFidelities(obj,s)
            obj.logger.info('qCloud.updateTwoQGateFidelities',...
                sprintf('updating two qubit gate fidelity: q%s-q%s',...
                num2str(s.q1,'%0.0f'), num2str(s.q2,'%0.0f')));
            jTwoQGateFidelity = com.alibaba.quantum.domain.v2.TwoQGateFidelity();
            jTwoQGateFidelity.setQ1(s.q1);
            jTwoQGateFidelity.setQ2(s.q2);
            % negative value: no data(java null)
            if s.cz > 0
                jTwoQGateFidelity.setCz(java.lang.Float(s.cz));
            end
            obj.backend.updateTwoQGateFidelities(jTwoQGateFidelity);
%             if ~resp.isSuccess()
%                 msg = cell(resp.getMessage());
%                 obj.logger.error('qCloud.updateTwoQGateFidelities',msg{1});
%                 throw(MException('QOS:qCloudPlatformConnection:updateTwoQGateFidelities',msg{1}));
%             end
%             obj.logger.info('qCloud.updateTwoQGateFidelities','gate fidelity updated.');
        end
        function commitTwoQGateFidelities(obj)
            obj.logger.info('qCloud.commitTwoQGateFidelities','commit two-qubit gate fidelities.');
            resp = obj.backend.commitTwoQGateFidelities();
            if ~resp.isSuccess()
                msg = cell(resp.getMessage());
                obj.logger.error('qCloud.commitTwoQGateFidelities',msg{1});
                throw(MException('QOS:qCloudPlatformConnection:commitTwoQGateFidelities',msg{1}));
            end
            obj.logger.info('qCloud.commitTwoQGateFidelities','two-qubit gate fidelities updated.');
        end
		function updateQubitParemeters(obj,s)
            obj.logger.info('qCloud.updateQubitParemeters',...
                sprintf('updating parameters for qubit: %s',...
                num2str(s.qubit,'%0.0f')));
            jQubitParameters = com.alibaba.quantum.domain.v2.QubitParameters();
            jQubitParameters.setQubit(s.qubit);
            jQubitParameters.setF01(s.f01);
            if s.f12 > 0 % negative value: no data(java null)
                jQubitParameters.setF12(s.f12);
            end
            jQubitParameters.setT1(s.T1);
            jQubitParameters.setT2star(s.T2star);
            jQubitParameters.setReadoutFidelity(s.readoutFidelity);
            obj.backend.updateQubitParemeters(jQubitParameters);
%             if ~resp.isSuccess()
%                 msg = cell(resp.getMessage());
%                 obj.logger.error('qCloud.updateQubitParemeters',msg{1});
%                 throw(MException('QOS:qCloudPlatformConnection:updateQubitParemeters',msg{1}));
%             end
%             obj.logger.info('qCloud.updateQubitParemeters','qubit parameters updated.');
        end
        function commitQubitParameters(obj)
            obj.logger.info('qCloud.commitQubitParameters','commit changes of qubit parameters.');
            resp = obj.backend.commitQubitParemeters();
            if ~resp.isSuccess()
                msg = cell(resp.getMessage());
                obj.logger.error('qCloud.commitQubitParameters',msg{1});
                throw(MException('QOS:qCloudPlatformConnection:commitQubitParameters',msg{1}));
            end
            obj.logger.info('qCloud.commitQubitParameters','qubit parameters updated.');
        end
        function addTestUser(obj,userName)
            if ~ischar(userName)
                obj.logger.error('qCloud.setTestUser','illegal argument.');
            end
            obj.logger.info('qCloud.setTestUser',['add test user: ', userName]);
            resp = obj.backend.givePermission(userName);
            if ~resp.isSuccess()
                msg = cell(resp.getMessage());
                obj.logger.error('qCloud.setTestUser',msg{1});
                throw(MException('QOS:qCloudPlatformConnection:setTestUser',msg{1}));
            end
            obj.logger.info('qCloud.setTestUser',['test user: ', userName,' added.']);
        end
    end
end