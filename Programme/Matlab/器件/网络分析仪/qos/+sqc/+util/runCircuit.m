function [result, singleShotEvents, sequenceSamples, finalCircuit] =...
                runCircuit(circuit,opQs,measureQs,stats,measureType, noConcurrentCZ,logger,wvSamplesTruncatePts)
%  circuit = {'X','Y2p';
%             'CZ','CZ';
%             '','Y2m'};
%  opQs = {'q11','q12'};
%  measureQs = {'q11','q12'};
%  stats = 3000;
%  measureType = 'Mzj'; % default 'Mzj', z projection
%  noConcurrentCZ = false; % default false
% [result, singleShotEvents, sequenceSamples, finalCircuit] =...
%                 sqc.util.runCircuit(circuit,opQs,measureQs,stats,measureType, noConcurrentCZ);
% figure();bar(result);
            
            import sqc.op.physical.*
            import sqc.measure.*
            import sqc.util.qName2Obj

            if nargin < 5
                measureType = 'Mzj';
            end
            if nargin < 6
                noConcurrentCZ = false;
            end
            if nargin < 7
                logger = [];
            end
            if nargin < 8
                wvSamplesTruncatePts = 0;
            end
            numOpQs = numel(opQs);
            opQubits = cell(1,numOpQs);
            for ii = 1:numOpQs
                opQubits{ii} = qName2Obj(opQs{ii});
            end
            if ~isempty(logger)
                logger.info('qCloud.runCircuit','parsing circuit...');
            end
            if noConcurrentCZ
                finalCircuit = sqc.op.physical.gateParser.shiftConcurrentCZ(circuit);
            else
                finalCircuit = circuit;
            end
            process = sqc.op.physical.gateParser.parse(opQubits,circuit,noConcurrentCZ);
            if ~isempty(logger)
                logger.info('qCloud.runCircuit','parse circuit done.');
                logger.info('qCloud.runCircuit','running circuit...');
            end
            process.logSequenceSamples = true;
            waveformLogger = sqc.op.physical.sequenceSampleLogger.GetInstance();
            waveformLogger.clear();
            numMeasureQs = numel(measureQs);
            measureQubits = cell(1,numel(numMeasureQs));
            for ii = 1:numMeasureQs
                measureQubits{ii} = qName2Obj(measureQs{ii});
                measureQubits{ii}.r_avg = stats;
            end
            switch measureType
                case 'Mptomo' % process tomo
                    R = processTomography(measureQubits,process);
                case 'Mstomoj' % joint state tomo
                    R = stateTomography(measureQubits,true);
                    R.setProcess(process);
                case 'Mstomop' % parallel state tomo
                    R = stateTomography(measureQubits,false);
                    R.setProcess(process);
                case 'Mphase' % phase tommo
                    R = phase(measureQubits);
                    R.setProcess(process);
                case 'Mzj' % z projection, joint
                    R = resonatorReadout(measureQubits,true,false);
                    R.delay = process.length;
                    process.Run();
                case 'MzjRaw' % z projection, joint
                    R = resonatorReadout(measureQubits,true,false);
                    R.delay = process.length;
                    R.iqRaw=true;
                    process.Run();
                case 'Mzp' % z projection, parallel
                    R = resonatorReadout(measureQubits,false,false);
                    R.delay = process.length;
                    process.Run();
                otherwise
                    if ~isempty(logger)
                        logger.error('qCloud:runTask:unsupportedMeasurementType',...
                            ['unsupported measurement type: ', measureType]);
                    end
                    throw(MException('QOS:qCloudPlatform:unsupportedMeasurementType',...
                        ['unsupported measurement type: ', measureType]));
            end
            result = R();
            singleShotEvents = R.extradata;
            
            sequenceSamples = waveformLogger.get(opQs);
            sequenceSamples(:,max(1,size(sequenceSamples,2) - wvSamplesTruncatePts+1):end) = [];
%             waveformLogger.plotSequenceSamples(sequenceSamples);
            if ~isempty(logger)
                logger.info('qCloud.runCircuit','run circuit done.');
            end
        end