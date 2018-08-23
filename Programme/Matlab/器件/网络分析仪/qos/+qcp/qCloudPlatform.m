classdef qCloudPlatform < handle
    % Quantum Computing Cloud Platform backend
    % http://quantumcomputer.ac.cn/index.html
    
% Copyright 2018 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties(SetAccess = private)
        status = 'OFFLINE'  % 'OFFLINE','MAINTENANCE','ACTIVE','CALIBRATION'
    end
    properties (SetAccess = private, GetAccess = private)
        qCloudSettingsRoot
        connection
        logger
        
        eventQueue = {}
        
        user
        qosSettingsRoot
        dataPath
        defaultResultMsgCN
        defaultResultMsgEN
        
        runErrorCount = 0
        runtErrorTime
        
        noConcurrentCZ
        
        singleTakeNumShots = 3000;
        wvSamplesTruncatePts = 0;
        
        sysConfig
        sysStatus
        
        temperatureReader
        
        ctrlPanelHandles

        serving = false;
        
        calibrationOn = true
        stopCalibration
        
        showCalibrationResults =false
        
        lvl1Calibration
        lvl2Calibration
        lvl3Calibration
        lvl4Calibration
        
        lastLvl1CalibrationTime
        lastLvl2CalibrationTime
        lastLvl3CalibrationTime
        lastLvl4CalibrationTime
        lvl1CalibrationInterval
        lvl2CalibrationInterval
        lvl3CalibrationInterval
        lvl4CalibrationInterval
        
        systemTasks = {}
        systemTasksExecutionTimes = []
        
        noConnection = false
    end
    methods (Access = private)
        function obj = qCloudPlatform(qCloudSettingsRoot)
            obj.qCloudSettingsRoot = qCloudSettingsRoot;
            obj.defaultResultMsgCN = qes.util.loadSettings(qCloudSettingsRoot, 'defaultResultMsgCN');
            obj.defaultResultMsgEN = qes.util.loadSettings(qCloudSettingsRoot, 'defaultResultMsgEN');
            obj.singleTakeNumShots = qes.util.loadSettings(qCloudSettingsRoot, 'singleTakeNumShots');
            obj.wvSamplesTruncatePts = qes.util.loadSettings(qCloudSettingsRoot, 'wvSamplesTruncatePts');
            pushoverAPIKey = qes.util.loadSettings(qCloudSettingsRoot, {'pushover','key'});
            pushoverReceiver = qes.util.loadSettings(qCloudSettingsRoot, {'pushover','receiver'});
            obj.user = qes.util.loadSettings(qCloudSettingsRoot, 'user');
            obj.qosSettingsRoot = qes.util.loadSettings(qCloudSettingsRoot, 'qosSettingsRoot');
            logPath = qes.util.loadSettings(qCloudSettingsRoot, 'logPath');
            logfile = fullfile(logPath, [datestr(now,'yyyy-mm-dd_HH-MM-SS'),'_qos.log']);
            logger = qes.util.log4qCloud.getLogger(logfile);
            logger.setFilename(logfile);
            logger.setCommandWindowLevel(logger.ALL);
            logger.setLogLevel(logger.INFO);  
            logger.setNotifier(pushoverAPIKey,pushoverReceiver);
            obj.logger = logger;
            try
                noConnection_ = logical(qes.util.loadSettings(qCloudSettingsRoot, 'noConnection'));
                obj.noConnection = noConnection_(1);
            catch ME0
                obj.logger.warn('qCloud:loadSettingsException',...
                    sprintf('load setting noConnection failed or illegal value: %s, noConnection set to false', ME0.message));
                obj.noConnection = false;
            end
            dataPath = qes.util.loadSettings(qCloudSettingsRoot, 'dataPath');
            if ~isdir(dataPath)
                obj.logger.error('qCloud:invalidPath',sprintf('data path %s is not a valid path.', dataPath));
                throw(MException('QOS:qCloudPlatform:invalidDataPath',sprintf('data path %s is not a valid path.', dataPath)));
            end
            obj.dataPath = dataPath;
            obj.noConcurrentCZ = qes.util.loadSettings(qCloudSettingsRoot, 'noConcurrentCZ');
            
            obj.sysConfig = qcp.systemConfig(qCloudSettingsRoot);
            obj.sysConfig.load();

            obj.sysStatus = qcp.systemStatus(qCloudSettingsRoot);
            obj.sysStatus.load();

            obj.lastLvl1CalibrationTime = obj.sysStatus.lastLvl1CalibrationTime;
            obj.lastLvl2CalibrationTime = obj.sysStatus.lastLvl2CalibrationTime;
            obj.lastLvl3CalibrationTime = obj.sysStatus.lastLvl3CalibrationTime;
            obj.lastLvl4CalibrationTime = obj.sysStatus.lastLvl4CalibrationTime;
            
            calibrationSettings = qes.util.loadSettings(qCloudSettingsRoot, 'calibration');
            obj.lvl1Calibration = str2func(['@(f,g)',calibrationSettings.lvl1Calibration,'(f,g)']);
            obj.lvl1CalibrationInterval = calibrationSettings.lvl1CalibrationInterval*6.9444e-04; % convert from minutes to days
            obj.lvl2Calibration = str2func(['@(f,g)',calibrationSettings.lvl2Calibration,'(f,g)']);
            obj.lvl2CalibrationInterval = calibrationSettings.lvl2CalibrationInterval*6.9444e-04;
            obj.lvl3Calibration = str2func(['@(f,g)',calibrationSettings.lvl3Calibration,'(f,g)']);
            obj.lvl3CalibrationInterval = calibrationSettings.lvl3CalibrationInterval*6.9444e-04;
            obj.lvl4Calibration = str2func(['@(f,g)',calibrationSettings.lvl4Calibration,'(f,g)']);
            obj.lvl4CalibrationInterval = calibrationSettings.lvl4CalibrationInterval*6.9444e-04;
            obj.showCalibrationResults = qes.util.hvar(calibrationSettings.showCalibrationResults);
            
            obj.stopCalibration = qes.util.hvar(false);
           
            temperatureReaderCfg = qes.util.loadSettings(qCloudSettingsRoot, 'temperatureReaderCfg');
            if ~isempty(temperatureReaderCfg)
                r = str2func(['@(x)',temperatureReaderCfg.func,'(x)']);
            else
                r = @(x) [];
            end
            function temperature = TReader()
                try
                    temperature = feval(r, temperatureReaderCfg);
                catch ME
                    obj.logger.warn('qCloud:readTemperatureException',ME.message);
                    temperature = [];
                end
            end
            obj.temperatureReader = @TReader;
            obj.status = 'OFFLINE';
            obj.CreateCtrlPanel();
            infoStr = [obj.status,' | not started'];
            set(obj.ctrlPanelHandles.infoDisp,'String',infoStr);
        end
		function checkSystemTasks(obj)
            if ~isempty(obj.systemTasks) % old system tasks still not executed, no need to check for new ones
                return;
            end
			try
				systemTasksSettings = qes.util.loadSettings(obj.qCloudSettingsRoot, 'systemTasks');
                taskFuncs = systemTasksSettings.functions;
                executionTimes = systemTasksSettings.executionTimes;
			catch ME
				obj.logger.warn('qCloud.checkSystemTasks',['checkSystemTasks exception: ', ME.message]);
                return;
            end
            if isempty(taskFuncs)
                return;
            end
			if ~iscell(taskFuncs)
				taskFuncs = {taskFuncs};
            end
            if ~iscell(executionTimes)
				executionTimes = {executionTimes};
            end
            if numel(taskFuncs) == 1 && strcmpi(taskFuncs{1},'null')
                return;
            end
            try
				qes.util.saveSettings(obj.qCloudSettingsRoot, {'systemTasks','functions'},{'null'}); % json can not have empty array
                qes.util.saveSettings(obj.qCloudSettingsRoot, {'systemTasks','executionTimes'},{'null'});
			catch ME
				obj.logger.warn('qCloud.checkSystemTasks',['clear system tasks settings failed: ',ME.message]);
            end
            if numel(taskFuncs) ~= numel(executionTimes)
                obj.logger.warn('qCloud.checkSystemTasks','bad system tasks setting, functions and executionTimes length not match.');
                return;
            end
            numSystemTasks = numel(taskFuncs);
            for ii = 1:numSystemTasks
                try
                    systemTaskFunc = str2func(taskFuncs{ii});
                catch ME
                    obj.logger.error('qCloud.checkSystemTasks',sprintf('illegal system task ignored: %s', ME.message));
                    continue;
                end
                try
                    if isempty(executionTimes{ii})
                        exeTimes = now;
                    else
                        exeTimes = datenum(executionTimes{ii});
                    end
                catch ME
                    obj.logger.warn('qCloud.checkSystemTasks',...
                        sprintf('illegal system task execution time, set to immediate execution: %s', ME.message));
                    exeTimes = now;
                end
                obj.systemTasks{end+1} = systemTaskFunc;
                obj.systemTasksExecutionTimes(end+1) = exeTimes;
            end
            [obj.systemTasksExecutionTimes,ind] = sort(obj.systemTasksExecutionTimes);
            obj.systemTasks = obj.systemTasks(ind);
        end
        function runSystemTasks(obj)
            if isempty(obj.systemTasks) || now < obj.systemTasksExecutionTimes(1)
                return;
            end
            obj.logger.info('qCloud.runSystemTasks','start running system tasks.');
            status_backup = obj.status;
            infoStr_backup = get(obj.ctrlPanelHandles.infoDisp,'String');
            obj.status = 'MAINTENANCE';
            obj.updateSystemStatus();
            infoStr = [obj.status,' | running system tasks'];
            set(obj.ctrlPanelHandles.infoDisp,'String',infoStr);
            drawnow;
            pause(0.2);
            while ~isempty(obj.systemTasks) && now > obj.systemTasksExecutionTimes(1)
                try
                    obj.logger.info('qCloud.runSystemTasks',sprintf('start running system task: %s ', func2str(obj.systemTasks{1})));
                    feval(obj.systemTasks{1});
                    obj.logger.info('qCloud.runSystemTasks',sprintf('task: %s done.', func2str(obj.systemTasks{1})));
                catch ME
                    obj.logger.warn('qCloud.runSystemTasks',...
                        sprintf('run system task %s failed: %s',func2str(obj.systemTasks{1}), ME.message));
                end
                obj.systemTasks(1) = [];
                obj.systemTasksExecutionTimes(1) = [];
            end
			obj.logger.info('qCloud.runSystemTasks','system tasks done.');
            obj.status = status_backup;
            obj.updateSystemStatus();
            set(obj.ctrlPanelHandles.infoDisp,'String',infoStr_backup);
		end
        function [result, singleShotEvents, sequenceSamples, finalCircuit] =...
                runCircuit(obj,circuit,opQs,measureQs,measureType, stats)
            import sqc.op.physical.*
            import sqc.measure.*
            import sqc.util.qName2Obj

            numOpQs = numel(opQs);
            opQubits = cell(1,numOpQs);
            for ii = 1:numOpQs
                opQubits{ii} = qName2Obj(opQs{ii});
            end
            obj.logger.info('qCloud.runCircuit','parsing circuit...');
            if obj.noConcurrentCZ
                finalCircuit = sqc.op.physical.gateParser.shiftConcurrentCZ(circuit);
            else
                finalCircuit = circuit;
            end
            process = sqc.op.physical.gateParser.parse(opQubits,circuit,obj.noConcurrentCZ);
            obj.logger.info('qCloud.runCircuit','parse circuit done.');
            obj.logger.info('qCloud.runCircuit','running circuit...');
            process.logSequenceSamples = true;
            waveformLogger = sqc.op.physical.sequenceSampleLogger.GetInstance();
            numMeasureQs = numel(measureQs);
            measureQubits = cell(1,numel(numMeasureQs));
            for ii = 1:numMeasureQs
                measureQubits{ii} = qName2Obj(measureQs{ii});
                measureQubits{ii}.r_avg = obj.singleTakeNumShots;
            end
            runProcess = false;
            switch measureType
                case 'Mtomoj'
                    R = stateTomography(measureQubits,true);
                    R.setProcess(process);
                case 'Mtomop'
                    R = stateTomography(measureQubits,false);
                    R.setProcess(process);
                case 'Mphase'
                    R = phase(measureQubits);
                    R.setProcess(process);
                case 'Mzj'
                    R = resonatorReadout(measureQubits,true,false);
                    R.delay = process.length;
                    runProcess = true;
                case 'Mzp'
                    R = resonatorReadout(measureQubits,false,false);
                    R.delay = process.length;
                    runProcess = true;
                otherwise
                    obj.logger.error('qCloud:runTask:unsupportedMeasurementType',...
                        ['unsupported measurement type: ', measureType]);
                    throw(MException('QOS:qCloudPlatform:unsupportedMeasurementType',...
                        ['unsupported measurement type: ', measureType]));
            end
            
%             result = R();
%             singleShotEvents = R.extradata;
            
            result = [];
            numTakes = ceil(stats/obj.singleTakeNumShots);
            singleShotEvents = nan(numMeasureQs,numTakes*obj.singleTakeNumShots);
            for ii = 1:numTakes
                obj.logger.trace('qCloud.runCircuit',sprintf('%0.0f of %0.0f takes', ii, numTakes));
                if runProcess
                    process.Run();
                end
                if ii == 1
                    result = R();
                else
                    result = result + R();
                end
                sInd = (ii-1)*obj.singleTakeNumShots+1;
                singleShotEvents(:,sInd:sInd + obj.singleTakeNumShots-1) = R.extradata;
            end
            result = result/numTakes;
            
            sequenceSamples = waveformLogger.get(opQs);
            sequenceSamples(:,max(1,size(sequenceSamples,2) - obj.wvSamplesTruncatePts+1):end) = [];
%             waveformLogger.plotSequenceSamples(sequenceSamples);
            obj.logger.info('qCloud.runCircuit','run circuit done.');
        end
        function Start(obj)
           obj.ConnectQCP();
           obj.StartBackend();
           obj.StartEventLoop();
        end
        function Stop(obj)
            obj.eventQueue = {};
            obj.status = 'OFFLINE';
            if obj.calibrationOn
                infoStr = [obj.status,' | calibration scheduled'];
            else
                infoStr = [obj.status,' | calibration not scheduled'];
            end
            set(obj.ctrlPanelHandles.infoDisp,'String',infoStr);
            set(obj.ctrlPanelHandles.StartButton,'String','Start',...
                        'Tooltip','Start server.');
            set(obj.ctrlPanelHandles.StartServingButton,'Enable','off');
            set(obj.ctrlPanelHandles.CalibrationButton,'Enable','off');
            set(obj.ctrlPanelHandles.UpdateSystemParametersButton,'Enable','off');
            if obj.calibrationOn
                infoStr = [obj.status,' | calibration scheduled'];
            else
                infoStr = [obj.status,' | calibration not scheduled'];
            end
            set(obj.ctrlPanelHandles.infoDisp,'String',infoStr);
        end
        function ConnectQCP(obj)
            if obj.noConnection
                obj.connection = qcp.qCloudPlatformConnection_null.GetInstance();
            else
                obj.connection = qcp.qCloudPlatformConnection.GetInstance();
            end
            obj.updateSystemConfig();
            obj.status = 'MAINTENANCE';
            obj.updateSystemStatus();
            if obj.calibrationOn
                infoStr = [obj.status,' | calibration scheduled'];
            else
                infoStr = [obj.status,' | calibration not scheduled'];
            end
            set(obj.ctrlPanelHandles.infoDisp,'String',infoStr);
            set(obj.ctrlPanelHandles.UpdateSystemParametersButton,'Enable','on');
        end
        function StartBackend(obj)
            obj.logger.info('qCloud.startup','initializing QOS settings...');
            try
                QS = qes.qSettings.GetInstance(obj.qosSettingsRoot);
            catch ME
                if strcmp(ME.identifier,'QOS:qSettings:invalidRootPath')
                    obj.logger.fatal('qCloud.startup', ME.message);
                    obj.logger.notify();
                else
                    obj.logger.fatal('qCloud.startup', ['unknown error: ', ME.message]);
                    obj.logger.notify();
                end
                rethrow(ME);
            end
            try
                QS.user = obj.user;
            catch ME
                if strcmp(ME.identifier,'QOS:qSettings:invalidUser')
                    obj.logger.fatal('qCloud.startup', ME.message);
                    obj.logger.notify();
                else
                    obj.logger.fatal('qCloud.startup', ['unknown error: ', ME.message]);
                    obj.logger.notify();
                end
                rethrow(ME);
            end
            try
                selectedSession = qes.util.loadSettings(obj.qosSettingsRoot, {QS.user,'selected'});
            catch ME
                if strcmp(ME.identifier,'QOS:loadSettings:settingsNotFound')
                    obj.logger.fatal('qCloud.startup', ME.message);
                    obj.logger.notify();
                else
                    obj.logger.fatal('qCloud.startup', ['unknown error: ', ME.message]);
                    obj.logger.notify();
                end
                rethrow(ME);
            end
            if isempty(selectedSession)
                obj.logger.fatal('qCloud.startup', sprintf('no selected session for %s in QOS settings.', QS.user));
                obj.logger.notify();
                throw(MException('QOS:qCloud:startup',sprintf('no selected session for %s in QOS settings.',QS.user)));
            end
            try
                sessionDate = datenum(selectedSession(2:end),'yymmdd');
                newSession = ['s',datestr(now,'yymmdd')];
                if sessionDate < floor(now)
                    qes.util.copySession(selectedSession,newSession);
                end
            catch ME
                if strfind(ME.identifier,'QOS:copySession:')
                    obj.logger.fatal('qCloud.startup', ME.message);
                    obj.logger.notify();
                else
                    obj.logger.fatal('qCloud.startup', ['unknown error: ', ME.message]);
                    obj.logger.notify();
                end
                rethrow(ME);
            end
            try
                QS.SS(newSession);
            catch ME
                if strfind(ME.identifier,'QOS:qSettings:')
                    obj.logger.fatal('qCloud.startup', ME.message);
                    obj.logger.notify();
                else
                    obj.logger.fatal('qCloud.startup', ['unknown error: ', ME.message]);
                    obj.logger.notify();
                end
                rethrow(ME);
            end
            try
                selectedHwSettings = qes.util.loadSettings(QS.root,{'hardware','selected'});
            catch ME
                if strcmp(ME.identifier,'QOS:loadSettings:settingsNotFound')
                    obj.logger.fatal('qCloud.startup', ME.message);
                    obj.logger.notify();
                else
                    obj.logger.fatal('qCloud.startup', ['unknown error: ', ME.message]);
                    obj.logger.notify();
                end
                rethrow(ME);
            end
            if isempty(selectedHwSettings)
                obj.logger.fatal('qCloud.startup', 'no selected hardware settings.');
                obj.logger.notify();
                throw(MException('QOS:qCloud:startup','no selected hardware settings.'));
            end
            obj.logger.info('qCloud.startup','initializing QOS settings done.');
        %%
            if ~QS.hwCreated
                obj.logger.info('qCloud.startup','creating hardware objects...');
                try
                    QS.CreateHw();
                catch ME
                    if strfind(ME.identifier, 'QOS:loadSettings:')
                        obj.logger.fatal('qCloud.startup', ME.message);
                        obj.logger.notify();
                    elseif strfind(ME.identifier, 'QOS:hwCreator:illegalHaredwareSettings')
                        obj.logger.fatal('qCloud.startup', ME.message);
                        obj.logger.notify();
                    else
                        obj.logger.fatal('qCloud.startup', ['unknown error: ', ME.message]);
                        obj.logger.notify();
                    end
                    rethrow(ME);
                end
                obj.logger.info('qCloud.startup','creating hardware objects done.');
                
                % just in case some dc source levels has changed
                obj.logger.info('qCloud.startup','setting qubit DC bias...');
                qNames = data_taking.public.util.allQNames();
                for ii = 1:numel(qNames)
                    try
                        data_taking.public.util.setZDC(qNames{ii});
                    catch ME
                        obj.logger.fatal('qCloud.startup', sprintf('error in set dz bias for qubit %s: %s', qNames{ii}, ME.message));
                        obj.logger.notify();
                        rethrow(ME);
                    end
                end
                obj.logger.info('qCloud.startup','setting qubit DC bias done.');
            end

        %%  
            obj.logger.info('qCloud.startup','qCloud backend started up successfully.');
            obj.logger.notify();
            
            obj.status = 'MAINTENANCE';
            if obj.calibrationOn
                infoStr = [obj.status,' | calibration scheduled'];
            else
                infoStr = [obj.status,' | calibration not scheduled'];
            end
            set(obj.ctrlPanelHandles.infoDisp,'String',infoStr);
            set(obj.ctrlPanelHandles.StartButton,'String','Stop',...
                        'Tooltip','Stop server.');
            set(obj.ctrlPanelHandles.StartServingButton,'Enable','on');
            set(obj.ctrlPanelHandles.CalibrationButton,'Enable','on');
            if obj.calibrationOn
                infoStr = [obj.status,' | calibration scheduled'];
            else
                infoStr = [obj.status,' | calibration not scheduled'];
            end
            set(obj.ctrlPanelHandles.infoDisp,'String',infoStr);
        end
        function Restart(obj)
            obj.logger.info('qCloud.restart','restarting qCloud...');
            if obj.serving
                obj.logger.info('qCloud.restart','stop serving...');
                obj.StopServing();
            end
            try
                QS = qes.qSettings.GetInstance();
                QS.delete();
            catch
            end
            obj.status = 'OFFLINE';
            obj.updateSystemStatus();
            set(obj.ctrlPanelHandles.StartServingButton,'Enable','off',...
               'String','Start Serving','Tooltip','Start serving.');
            set(obj.ctrlPanelHandles.CalibrationButton,'Enable','off');
            set(obj.ctrlPanelHandles.UpdateSystemParametersButton,'Enable','off');
            if obj.calibrationOn
                infoStr = [obj.status,' | calibration scheduled'];
            else
                infoStr = [obj.status,' | calibration not scheduled'];
            end
            set(obj.ctrlPanelHandles.infoDisp,'String',infoStr);
            
            obj.logger.info('qCloud.restart','deleting hardware objects...');
            hwObjs = qes.qSettings.FindByClass('qes.hwdriver.hardware');
            for ii = 1:numel(hwObjs)
                try
                    hwObjs{ii}.delete();
                catch ME
                    obj.logger.warn('qCloud.restart',['error at deleting hardware objects: ', ME.message]);
                end
            end
            obj.logger.info('qCloud.restart','hardware objects deleted.');
            obj.status = 'OFFLINE';
            try
                obj.Start();
            catch ME
                obj.logger.fatal('qCloud.restart',['restart failed due to: ', ME.message]);
                return;
            end
            obj.logger.info('qCloud.restart','qCloud restarted.');
        end
        function StartServing(obj)
           if strcmp(obj.status,'OFF')
               warning('Server not started.');
               return;
           end
           obj.eventQueue{end+1} = 'RunTask';
           obj.serving = true;
           obj.status = 'ACTIVE';
           obj.updateSystemStatus();
           set(obj.ctrlPanelHandles.StartServingButton,'Enable','on',...
               'String','Stop Serving','Tooltip','Stop serving.');
           if obj.calibrationOn
                infoStr = [obj.status,' | calibration scheduled'];
            else
                infoStr = [obj.status,' | calibration not scheduled'];
            end
            set(obj.ctrlPanelHandles.infoDisp,'String',infoStr);
           obj.logger.info('qCloud.run','qCloud now serving...'); 
        end
        function StopServing(obj)
            rmvInd = [];
            for ii = 1:numel(obj.eventQueue)
                if strcmp(obj.eventQueue{ii},'RunTask')
                   rmvInd = [rmvInd,ii];
                end
            end
            obj.eventQueue(rmvInd) = [];
            obj.serving = false;
            obj.status = 'MAINTENANCE';
            obj.updateSystemStatus();
            set(obj.ctrlPanelHandles.StartServingButton,'Enable','on',...
               'String','Start Serving','Tooltip','Start serving.');
            if obj.calibrationOn
                infoStr = [obj.status,' | calibration scheduled'];
            else
                infoStr = [obj.status,' | calibration not scheduled'];
            end
            set(obj.ctrlPanelHandles.infoDisp,'String',infoStr);
            obj.logger.info('qCloud.restart','qCloud service stopped.');
        end
        function RunTask(obj)
            qTask = obj.connection.getTask();
            if isempty(qTask)
                return;
            end
            obj.logger.info('qCloud.runTask',['running task: ', num2str(qTask.taskId,'%0.0f')]);
            errorMsg = '';
            taskResult = struct();
            taskResult.taskId = qTask.taskId;
            try
                measureType = cell(qTask.measureType);
                measureType = measureType{1};
                [result, singleShotEvents, waveformSamples, finalCircuit] =...
                    obj.runCircuit(qTask.circuit,qTask.opQubits,...
                    qTask.measureQubits,measureType,qTask.stats);
                taskResult.finalCircuit = finalCircuit;
                taskResult.result = result;
                taskResult.singleShotEvents = singleShotEvents;
                taskResult.waveforms = waveformSamples;
            catch ME
                errorMsg = ['run circuit failed: ', ME.message,char(13),char(10)];
                obj.logger.error('qCloud.runTask.runTaskException',ME.message);
                obj.logger.notify();
                obj.runErrorCount = obj.runErrorCount + 1;
                obj.runtErrorTime(end+1) = now;
                ln = numel(obj.runtErrorTime);
                if ln > 4 && obj.runtErrorTime(end) - obj.runtErrorTime(ln-4) < 0.00694 % 10 min
                    throw(ME);
                end
                taskResult.finalCircuit = {};
                taskResult.result = [];
                taskResult.singleShotEvents = [];
                taskResult.waveforms = [];
            end
            QS = qes.qSettings.GetInstance();
            numMQs = numel(qTask.measureQubits);
            taskResult.fidelity = -ones(numMQs,2);
            for ii = 1:numMQs
                try
                    taskResult.fidelity(ii,:) = QS.loadSSettings({qTask.measureQubits{ii},'r_iq2prob_fidelity'});
                catch ME
                    msg = sprintf('load readout fidelity for %s failed due to: %s',...
                        qTask.measureQubits{ii},ME.message);
                    errorMsg = [errorMsg,msg];
                    obj.logger.error('qCloud.runTask',msg);
                end
            end
            
            taskResult.noteCN = [obj.defaultResultMsgCN, errorMsg];
            taskResult.noteEN = [obj.defaultResultMsgEN, errorMsg];
            datafile = fullfile(obj.dataPath,sprintf('task_%08.0f.mat',qTask.taskId));
            tr = data_taking.public.dataproc.qcpdt(taskResult.result);
            save(datafile,'qTask','taskResult','errorMsg','tr');
            taskResult.result = tr;
            
%             if qTask.stats > 1e4
%                 taskResult.singleShotEvents = [];
%             end
            taskResult.singleShotEvents = [];
            obj.connection.pushResult(taskResult);
            obj.logger.info('qCloud.runTask',sprintf('task: %0.0f done.', qTask.taskId));
        end
        function pushTask(obj,circuit,measureQs, stats,measureType)
            % for testing
            % circuit  = {'Y2p','Y2p','Y2p',  'Y2p',  'Y2p',  'Y2p',  'Y2p',  'Y2p','Y2p',  'Y2p','Y2p';
            %    'Y2m','Y2m','Y2m',  'Y2m',  'Y2m',  'Y2m',  'Y2m',  'Y2m','Y2m',  'Y2m','Y2m'};
            % measureQs = {'q1','q2','q3','q4','q5'};
            obj.connection.pushTask(obj,circuit,measureQs,stats,measureType);
        end
        function Calibration(obj,lvl)
            statusBackup = obj.status;
            obj.status = 'CALIBRATION';
            obj.updateSystemStatus();
            if obj.calibrationOn
                infoStr = [obj.status,' | calibration scheduled'];
            else
                infoStr = [obj.status,' | calibration not scheduled'];
            end
            set(obj.ctrlPanelHandles.infoDisp,'String',infoStr);
            switch lvl
                case 1
                    obj.logger.info('qCloud.calibration','start level 1 calibration...');
                    try
                        obj.lvl1Calibration(obj.stopCalibration,obj.showCalibrationResults);
                    catch ME
                        obj.logger.error('qCloud.calibration',['level 1 calibration failed: ', ME.message]);
                    end
                    obj.logger.info('qCloud.calibration','level 1 calibration done.');
                    t = now;
                    obj.lastLvl1CalibrationTime = t;
                    obj.lastLvl2CalibrationTime = t;
                    obj.lastLvl3CalibrationTime = t;
                    obj.lastLvl4CalibrationTime = t;
                    try
                        qes.util.saveSettings(obj.qCloudSettingsRoot,...
                            {'systemStatus','lastLvl1CalibrationTime'},t);
                        qes.util.saveSettings(obj.qCloudSettingsRoot,...
                            {'systemStatus','lastLvl2CalibrationTime'},t);
                        qes.util.saveSettings(obj.qCloudSettingsRoot,...
                            {'systemStatus','lastLvl3CalibrationTime'},t);
                        qes.util.saveSettings(obj.qCloudSettingsRoot,...
                            {'systemStatus','lastLvl4CalibrationTime'},t);
                    catch ME
                        obj.logger.warn('qCloud.updateSettingError',...
                            ['save lastLvl#CalibrationTime failed: ', ME.message]);
                    end
                case 2
                    obj.logger.info('qCloud.calibration','start level 2 calibration...');
                    try
                        obj.lvl2Calibration(obj.stopCalibration,obj.showCalibrationResults);
                    catch ME
                        obj.logger.error('qCloud.calibration',['level 2 calibration failed: ', ME.message]);
                    end
                    obj.logger.info('qCloud.calibration','level 2 calibration done.');
                    t = now;
                    obj.lastLvl2CalibrationTime = t;
                    obj.lastLvl3CalibrationTime = t;
                    obj.lastLvl4CalibrationTime = t;
                    try
                        qes.util.saveSettings(obj.qCloudSettingsRoot,...
                            {'systemStatus','lastLvl2CalibrationTime'},t);
                        qes.util.saveSettings(obj.qCloudSettingsRoot,...
                            {'systemStatus','lastLvl3CalibrationTime'},t);
                        qes.util.saveSettings(obj.qCloudSettingsRoot,...
                            {'systemStatus','lastLvl4CalibrationTime'},t);
                    catch ME
                        obj.logger.warn('qCloud.updateSettingError',...
                            ['save lastLvl#CalibrationTime failed: ', ME.message]);
                    end
                case 3
                    obj.logger.info('qCloud.calibration','start level 3 calibration...');
                    try
                        obj.lvl3Calibration(obj.stopCalibration,obj.showCalibrationResults);
                    catch ME
                        obj.logger.error('qCloud.calibration',['level 3 calibration failed: ', ME.message]);
                    end
                    obj.logger.info('qCloud.calibration','level 3 calibration done.');
                    t = now;
                    obj.lastLvl3CalibrationTime = t;
                    obj.lastLvl4CalibrationTime = t;
                    try
                        qes.util.saveSettings(obj.qCloudSettingsRoot,...
                            {'systemStatus','lastLvl3CalibrationTime'},t);
                        qes.util.saveSettings(obj.qCloudSettingsRoot,...
                            {'systemStatus','lastLvl4CalibrationTime'},t);
                    catch ME
                        obj.logger.warn('qCloud.updateSettingError',...
                            ['save lastLvl#CalibrationTime failed: ', ME.message]);
                    end
                case 4
                    obj.logger.info('qCloud.calibration','start level 4 calibration...');
                    try
                        obj.lvl4Calibration(obj.stopCalibration,obj.showCalibrationResults);
                    catch ME
                        obj.logger.error('qCloud.calibration',['level 4 calibration failed: ', ME.message]);
                    end
                    obj.logger.info('qCloud.calibration','level 4 calibration done.');
                    t = now;
                    obj.lastLvl4CalibrationTime = t;
                    try
                        qes.util.saveSettings(obj.qCloudSettingsRoot,...
                            {'systemStatus','lastLvl4CalibrationTime'},t);
                    catch ME
                        obj.logger.warn('qCloud.updateSettingError',...
                            ['save lastLvl#CalibrationTime failed: ', ME.message]);
                    end
            end
            obj.status = statusBackup;
            if obj.calibrationOn
                infoStr = [obj.status,' | calibration scheduled'];
            else
                infoStr = [obj.status,' | calibration not scheduled'];
            end
            set(obj.ctrlPanelHandles.infoDisp,'String',infoStr);
            obj.updateSystemStatus();
        end
        function updateSystemConfig(obj)
            try
                obj.sysConfig.load();
            catch ME
                obj.logger.error('qCloud.updateSystemConfig',sprintf('load systemConfig settings failed: %s', ME.message));
                return;
            end
            obj.connection.updateSystemConfig(obj.sysConfig);
        end
        function updateSystemStatus(obj)
            try
                obj.sysStatus.load();
            catch ME
                obj.logger.error('qCloud.updateSystemStatus',sprintf('load sysStatus settings failed: %s', ME.message));
                obj.logger.notify();
                return;
            end
            obj.sysStatus.status = obj.status;
            obj.sysStatus.fridgeTemperature = feval(obj.temperatureReader);

            try
                obj.connection.updateSystemStatus(obj.sysStatus);
            catch ME
                obj.logger.fatal('qCloud.updateSystemStatus',sprintf('updating system status failed due to an unknown error: %s', ME.message));
                obj.logger.notify();
                return;
            end
            try
                qes.util.saveSettings(obj.qCloudSettingsRoot,...
                    {'sysStatus','status'},obj.status);
                qes.util.saveSettings(obj.qCloudSettingsRoot,...
                    {'sysStatus','fridgeTemperature'},obj.sysStatus.fridgeTemperature);
            catch ME
                obj.logger.warn('qCloud.updateSettingError',...
                    ['save sysStatus failed: ', ME.message]);
            end
        end
        function updateOneQGateFidelities(obj)
            try
                QS = qes.qSettings.GetInstance();
                oneQFidelities = QS.loadSSettings({'shared','qCloud','oneQGateFidelities'});
            catch ME
                obj.logger.error('qCloud.updateOneQGateFidelities',...
                    sprintf('load updateOneQGateFidelities settings failed: %s', ME.message));
                obj.logger.notify();
                return;
            end
            qNames = fieldnames(oneQFidelities);
            for ii = 1:numel(qNames)
                s = oneQFidelities.(qNames{ii});
                s.qubit = str2double(qNames{ii}(2:end));
                obj.connection.updateOneQGateFidelities(s);
            end
            obj.connection.commitOneQGateFidelities();
        end
        function updateTwoQGateFidelities(obj)
            try
                QS = qes.qSettings.GetInstance();
                twoQFidelities = QS.loadSSettings({'shared','qCloud','twoQGateFidelities'});
            catch ME
                obj.logger.error('qCloud.updateTwoQGateFidelities',...
                    sprintf('load updateTwoQGateFidelities settings failed: %s', ME.message));
                return;
            end
            czSets = fieldnames(twoQFidelities);
            for ii = 1:numel(czSets)
                s.cz = twoQFidelities.(czSets{ii});
                [ind1, ind2] = regexp(czSets{ii},'_q\d+_');
                s.q1= str2double(czSets{ii}(ind1+2:ind2-1));
                str = czSets{ii}(ind2:end);
                [ind1, ind2] = regexp(str,'_q\d+');
                s.q2= str2double(str(ind1+2:ind2));
                obj.connection.updateTwoQGateFidelities(s);
            end
            obj.connection.commitTwoQGateFidelities();
        end
        function updateQubitParemeters(obj)
            try
                QS = qes.qSettings.GetInstance();
                qubitParameters = QS.loadSSettings({'shared','qCloud','qubitParameters'});
            catch ME
                obj.logger.error('qCloud.updateQubitParemeters',...
                    sprintf('load updateQubitParemeters settings failed: %s', ME.message));
                return;
            end
            qNames = fieldnames(qubitParameters);
            for ii = 1:numel(qNames)
                s = qubitParameters.(qNames{ii});
                s.qubit = str2double(qNames{ii}(2:end));
                obj.connection.updateQubitParemeters(s);
            end
            obj.connection.commitQubitParameters();
        end
        function StartEventLoop(obj)
            while isvalid(obj)
                drawnow;
                obj.checkSystemTasks();
				obj.runSystemTasks();
                t = now;
                if (t - obj.lastLvl1CalibrationTime) > obj.lvl1CalibrationInterval
                    if ~qes.util.ismember('CALIBRATION_LVL1',obj.eventQueue)
                        obj.eventQueue{end+1} = 'CALIBRATION_LVL1';
                    end
                elseif (t - obj.lastLvl2CalibrationTime) > obj.lvl2CalibrationInterval
                    if ~qes.util.ismember('CALIBRATION_LVL2',obj.eventQueue)
                        obj.eventQueue{end+1} = 'CALIBRATION_LVL2';
                    end
                elseif (t - obj.lastLvl3CalibrationTime) > obj.lvl3CalibrationInterval
                    if ~qes.util.ismember('CALIBRATION_LVL2',obj.eventQueue)
                        obj.eventQueue{end+1} = 'CALIBRATION_LVL3';
                    end
                elseif (t - obj.lastLvl4CalibrationTime) > obj.lvl4CalibrationInterval
                    if ~qes.util.ismember('CALIBRATION_LVL4',obj.eventQueue)
                        obj.eventQueue{end+1} = 'CALIBRATION_LVL4';
                    end
                end
                if isempty(obj.eventQueue)
                    pause(0.5);
                    continue;
                end
                switch obj.eventQueue{1}
                    case 'STOP'
                        obj.Stop();
                        break;
                    case 'RESTART'
                        obj.Restart();
                    case 'STARTSERVING'
                        obj.StartServing();
                    case 'STOPSERVING'
                        obj.StopServing();
                    case 'CALIBRATION_LVL1'
                        if obj.calibrationOn
                            obj.Calibration(1);
                        end
                    case 'CALIBRATION_LVL2'
                        if obj.calibrationOn
                            obj.Calibration(2);
                        end
                    case 'CALIBRATION_LVL3'
                        if obj.calibrationOn
                            obj.Calibration(3);
                        end
                    case 'CALIBRATION_LVL4'
                        if obj.calibrationOn
                            obj.Calibration(4);
                        end
                    case 'UPDATEPARAMS'
                        obj.updateSystemConfig();
                        obj.updateOneQGateFidelities();
                        obj.updateTwoQGateFidelities();
                        obj.updateQubitParemeters();
                    case 'RunTask' % must be the last one
                        try
                            obj.RunTask();
                            obj.eventQueue{end+1} = 'RunTask';
                            pause(0.5);
                        catch
                            obj.StopServing();
                            continue;
                        end
                end
                obj.eventQueue(1) = [];
            end
        end
        function CreateCtrlPanel(obj)
            % Experiment control panel
            
            h = findall(0,'tag','QOS | QCloud | Control Panel');
            if ~isempty(h)
                figure(h);
                set(h,'Visible','on');
                obj.ctrlPanelHandles = guidata(h);
                return;
            end

            BkGrndColor = [1,1,1];
            scrsz = get(0,'ScreenSize');
            MessWinWinSz = [0.35,0.425,0.3,0.12];
            rw = 1440/scrsz(3);
            rh = 900/scrsz(4);
            MessWinWinSz(3) = rw*MessWinWinSz(3);
            MessWinWinSz(4) = rh*MessWinWinSz(4);
            % set the window position on the center of the screen
            MessWinWinSz(1) = (1 - MessWinWinSz(3))/2;
            MessWinWinSz(2) = (1 - MessWinWinSz(4))/2;

            handles.obj = obj;
            handles.CtrlpanelWin = figure('Menubar','none','NumberTitle','off','Units','normalized ','Position',MessWinWinSz,...
                    'Name','QOS | QCloud | Control Panel','Color',BkGrndColor,...
                    'tag','QOS | QCloud | Control Panel','resize','off',...
                    'HandleVisibility','callback','CloseRequestFcn',{@CtrlpanelClose});
%             handles.CtrlpanelWin = figure('Menubar','none','NumberTitle','off','Units','normalized ','Position',MessWinWinSz,...
%                     'Name','QOS | QCloud | Control Panel','Color',BkGrndColor,...
%                     'tag','QOS | QCloud | Control Panel','resize','off',...
%                     'HandleVisibility','callback');
            warning('off');
            jf = get(handles.CtrlpanelWin,'JavaFrame');
            jf.setFigureIcon(javax.swing.ImageIcon(...
                im2java(qes.ui.icons.qos1_32by32())));
            warning('on');

            handles.infoDisp = uicontrol('Parent', handles.CtrlpanelWin,...
                  'Style','text','Foreg',[0,0,0],'String',obj.status,...
                  'FontUnits','normalized','Fontsize',0.4,'FontWeight','bold',...
                  'Units','normalized','BackgroundColor',[1,1,1],'HorizontalAlignment','left',...
                  'Position',[0.04,0.6,0.925,0.3]);
            Pos = [0.04,0.05,0.45,0.25];
            handles.StartButton = uicontrol('Parent', handles.CtrlpanelWin,...
                'Style','Pushbutton','Foreg',[1,0,0],'String','Start',...
                  'FontUnits','normalized','Fontsize',0.5,'FontWeight','bold',...
                  'Units','normalized',...
                  'Tooltip','Start and initialize the quantum computer.',...
                  'Position',Pos,'Callback',{@StartFunc});
            Pos(1) = Pos(1) + Pos(3) + 0.025;
            handles.StartServingButton = uicontrol('Parent', handles.CtrlpanelWin,...
                'Style','Pushbutton','String','Start Serving',...
                  'FontUnits','normalized','Fontsize',0.5,'FontWeight','bold',...
                  'Units','normalized',...
                  'Tooltip','Start running tasks.',...
                  'Position',Pos,'Callback',{@StartServingFunc});
           if strcmp(obj.status,'OFFLINE')
                set(handles.StartServingButton,'Enable','off','Tooltip','QCP not started.');
           elseif strcmp(obj.status,'MAINTENANCE') 
                set(handles.StartServingButton,'Enable','on','String','Start Serving','Tooltip','Start serving.');
           else
               set(handles.StartServingButton,'Enable','on','String','Stop Serving','Tooltip','Stop serving.');
           end
           Pos = get(handles.StartButton,'Position');
           Pos(2) = Pos(2) + Pos(4) + 0.005;
           handles.CalibrationButton = uicontrol('Parent', handles.CtrlpanelWin,...
                'Style','Pushbutton','String','Calibration',...
                  'FontUnits','normalized','Fontsize',0.5,'FontWeight','bold',...
                  'Units','normalized','Enable','off',...
                  'Tooltip','Perform nonscheduled calibration.',...
                  'Position',Pos,'Callback',{@CalibrationFunc});
           Pos(1) = Pos(1) + Pos(3) + 0.025;
           handles.UpdateSystemParametersButton = uicontrol('Parent', handles.CtrlpanelWin,...
                'Style','Pushbutton','String','Update System Params',...
                  'FontUnits','normalized','Fontsize',0.5,'FontWeight','bold',...
                  'Units','normalized','Enable','off',...
                  'Tooltip','Update system parameters.',...
                  'Position',Pos,'Callback',{@UpdateSystemParamsFunc});
           guidata(handles.CtrlpanelWin,handles);
           obj.ctrlPanelHandles = handles;

           function StartFunc(hObject,eventdata)
                % handles = guidata(hObject);
                if strcmp(handles.obj.status,'OFFLINE')
                    choice = questdlg(...
                        'This will start the system, please confirm:',...
                        'Confirm start','Yes','Cancel','Cancel');
                    switch choice
                        case 'Yes'
                            obj.Start()
                        otherwise
                            return;
                    end
                else
                    choice = questdlg(...
                        'This will stop the system, please confirm:',...
                        'Confirm stop','Yes','Cancel','Cancel');
                    switch choice
                        case 'Yes'
                            if qes.util.ismember('STOP',obj.eventQueue)
                                return;
                            end
                            obj.eventQueue{end+1} = 'STOP';
                        otherwise
                            return;
                    end
                end
           end

           function StartServingFunc(hObject,eventdata)
                if obj.serving
                    choice = questdlg(...
                        'This will stop serving, please confirm:',...
                        'Confirm stop serving','Yes','Cancel','Cancel');
                    switch choice
                        case 'Yes'
                            if qes.util.ismember('STOPSERVING',obj.eventQueue)
                                return;
                            end
                            obj.eventQueue{end+1} = 'STOPSERVING';
                        otherwise
                            return;
                    end
                else
                    choice = questdlg(...
                        'This will start serving, please confirm:',...
                        'Confirm start serving','Yes','Cancel','Cancel');
                    switch choice
                        case 'Yes'
                            if qes.util.ismember('STARTSERVING',obj.eventQueue)
                                return;
                            end
                            obj.eventQueue{end+1} = 'STARTSERVING';
                        otherwise
                            return;
                    end
                end
            end

           function CalibrationFunc(hObject,eventdata)
                if obj.calibrationOn
                    choice = questdlg(...
                        'Start a nonscheduled calibration or Stop the scheduled calibrations:',...
                        'What to do?','Start calibration immediately','Stop scheduled calibrations','Start calibration immediately');
                    switch choice
                        case 'Stop scheduled calibrations'
                            obj.calibrationOn = false;
                            obj.stopCalibration.val = true;
                            obj.logger.info('qCloud.UerOperation','Scheduled calibrations stopped by user.');
                            infoStr = [obj.status,' | calibration not scheduled'];
                            set(obj.ctrlPanelHandles.infoDisp,'String',infoStr);
                            return;
                        case 'Cancel'
                            return;
                    end
                else
                    choice = questdlg(...
                        'Start a nonscheduled calibration or Stop the scheduled calibrations:',...
                        'What to do?','Start calibration immediately','Start scheduled calibrations','Start calibration immediately');
                    switch choice
                        case 'Start scheduled calibrations'
                            obj.calibrationOn = true;
                            obj.stopCalibration.val = false;
                            infoStr = [obj.status,' | calibration scheduled'];
                            set(obj.ctrlPanelHandles.infoDisp,'String',infoStr);
                            return;
                        case 'Cancel'
                            return;
                    end
                end
                choice = questdlg(...
                    'This will start a nonscheduled calibration, please confirm:',...
                    'Confirm calibration','Yes','Cancel','Cancel');
                switch choice
                    case 'Yes'
                        levelOptions = {'CALIBRATION_LVL1','CALIBRATION_LVL2',...
                            'CALIBRATION_LVL3','CALIBRATION_LVL4'};
                        choise = qes.ui.questdlg_multi({'Level 1','Level 2','Level 3','Level 4'},...
                            'Calibration Level', 'CALIBRATION_LVL1',...
                            'Choose the level of calibration to perform:');
                        if isempty(choise)
                            return;
                        end
                        choise = levelOptions{choise};
                        if qes.util.ismember(choise,obj.eventQueue)
                            return;
                        end
                        obj.eventQueue{end+1} = choise;
                    otherwise
                        return;
                end
           end
            
           function UpdateSystemParamsFunc(hObject,eventdata)
                choice = questdlg(...
                    'This will update system parameters, please confirm:',...
                    'Confirm updation','Yes','Cancel','Cancel');
                switch choice
                    case 'Yes'
                        if qes.util.ismember('UPDATEPARAMS',obj.eventQueue)
                            return;
                        end
                        obj.eventQueue{end+1} = 'UPDATEPARAMS';
                    otherwise
                        return;
                end
            end
            
            function CtrlpanelClose(hObject,eventdata)
                % handles = guidata(hObject);
                if isstruct(handles) && isvalid(handles.obj)
                    choice = questdlg(...
                        'This will shutdown QCloud, please confirm:',...
                        'Confirm shutdown','Yes','Cancel','Cancel');
                    switch choice
                        case 'Yes'
                            delete(handles.obj);
                    end
                end
                delete(gcbf);
            end
        end
    end
    methods (Static = true)
        function obj = GetInstance(qCloudSettingsRoot)
            persistent instance;
            if isempty(instance) || ~isvalid(instance)
                if nargin < 1 || ~isdir(qCloudSettingsRoot)
                    throw(MException('QOS:qCloudPlatform:notEnoughArguments',...
                        'qCloudSettingPath not given or not a valid path.'))
                else
                    instance = qcp.qCloudPlatform(qCloudSettingsRoot);
                end
            end
            obj = instance;
            if ~isgraphics(obj.ctrlPanelHandles.CtrlpanelWin)
                obj.CreateCtrlPanel();
            end
        end
    end
    methods
        function addTestUser(obj,userName)
            obj.connection.addTestUser(userName);
        end
        function delete(obj)
            obj.status = 'OFFLINE';
            obj.updateSystemStatus();
            obj.logger.info('qCloud.ShutDown','qCloud shut down.');
            obj.logger.commit();
            if isgraphics(obj.ctrlPanelHandles.CtrlpanelWin)
                close(obj.ctrlPanelHandles.CtrlpanelWin);
            end
        end
    end
end