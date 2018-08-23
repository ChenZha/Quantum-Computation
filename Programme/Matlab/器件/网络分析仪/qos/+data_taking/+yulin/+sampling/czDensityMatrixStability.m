import sqc.util.setQSettings
import data_taking.public.xmon.*
%%
qubits = {'q11','q10'};
setQSettings('r_avg',1000);
for ii = 1:numel(qubits)
q = qubits{ii};
    tuneup.correctf01byPhase('qubits',q,'delayTime',1e-6,'gui',true,'save',true,'doCorrection',true,'iter',true);
    tuneup.iq2prob_01('qubits',q,'numSamples',1e4,'gui',true,'save',true);
    tuneup.xyGateAmpTuner('qubit',q,'gateTyp','X/2','AE',true,'AENumPi',41,'gui',true,'save',true);
    tuneup.iq2prob_01('qubits',q,'numSamples',2e4,'gui',true,'save',true);
end
setQSettings('r_avg',2000);
tuneup.czAmplitude('controlQ','q11','targetQ','q10','notes','','gui',true,'save',true);
tuneup.czDynamicPhase('controlQ','q11','targetQ','q10','dynamicPhaseQ','q11',...
              'numCZs',10,'PhaseTolerance',0.03,'gui','true','save',true);
tuneup.czDynamicPhase('controlQ','q11','targetQ','q10','dynamicPhaseQ','q10',...
              'numCZs',10,'PhaseTolerance',0.03,'gui','true','save',true);
for ii = 1:numel(qubits)
    q = qubits{ii};
%     tuneup.correctf01byPhase('qubits',q,'delayTime',1e-6,'gui',true,'save',true,'doCorrection',true,'iter',true);
    tuneup.iq2prob_01('qubits',q,'numSamples',2e4,'gui',true,'save',true);
end
%%
setQSettings('r_avg',3000);
TimeSpan = 100*60;
Time = [];
CZTomoData = {};
Chi = {};
fidelity = [];
datafile = ['E:\data\20180216_12bit\sampling\stability\','q11_q12_cz_DensityMatrixStabilityIQCalibration_',datestr(now,'yymmddTHHMMSS'),'.mat'];
notes = 'r_avg=3000;Run immediatly after calibrations, IQ calibration between takes.';
hf = qes.ui.qosFigure('1 CZ Chi Stability',false);
ax = axes('parent',hf);
circuit = {'CZ','CZ'};
 opQs = {'q11','q12'};
 measureQs = {'q11','q12'};
 stats = 3000;
 measureType = 'Mptomo'; % default 'Mzj', z projection
 noConcurrentCZ = false; % default false
tic
while 1
    Time(end+1) = toc;
    [result, ~, ~, ~] = sqc.util.runCircuit(circuit,opQs,measureQs,stats,measureType, noConcurrentCZ);
    CZTomoData{end+1} = result;
    Chi{end+1} = sqc.qfcns.processTomoData2Chi(CZTomoData{end});
    fidelity(end+1)  = real(trace(Chi{end}*Chi{1}));
    save(datafile,'Time','CZTomoData','Chi','fidelity','circuit','notes');
    try
        plot(ax,Time/60,fidelity,'-s');
        xlabel(ax,'Time(min.)');
        ylabel(ax,'Trace(\chi_{i}\chi_{1})');
    catch
        hf = qes.ui.qosFigure('1 CZ Chi Stability',false);
        ax = axes('parent',hf);
    end
    drawnow;
    if Time(end) > TimeSpan
        break;
    end
    for ii = 1:numel(qubits)
        q = qubits{ii};
    %     tuneup.correctf01byPhase('qubits',q,'delayTime',1e-6,'gui',true,'save',true,'doCorrection',true,'iter',true);
        tuneup.iq2prob_01('qubits',q,'numSamples',2e4,'gui',true,'save',true);
    end
end
%%
setQSettings('r_avg',3000);
TimeSpan = 30*60;
Time = [];
CZTomoData = {};
Chi = {};
fidelity = [];
datafile = ['E:\data\20180216_12bit\sampling\stability\','q11_q12_cz_DensityMatrixStabilityIQCalibration_',datestr(now,'yymmddTHHMMSS'),'.mat'];
notes = 'r_avg=3000;Run immediatly after calibrations, IQ calibration between takes.';
hf = qes.ui.qosFigure('1 CZ Chi Stability',false);
ax = axes('parent',hf);
circuit = {'CZ','CZ'};
 opQs = {'q11','q12'};
 measureQs = {'q11','q12'};
 stats = 3000;
 measureType = 'Mptomo'; % default 'Mzj', z projection
 noConcurrentCZ = false; % default false
tic
while 1
    Time(end+1) = toc;
    [result, ~, ~, ~] = sqc.util.runCircuit(circuit,opQs,measureQs,stats,measureType, noConcurrentCZ);
    CZTomoData{end+1} = result;
    Chi{end+1} = sqc.qfcns.processTomoData2Chi(CZTomoData{end});
    fidelity(end+1)  = real(trace(Chi{end}*Chi{1}));
    save(datafile,'Time','CZTomoData','Chi','fidelity','circuit','notes');
    try
        plot(ax,Time/60,fidelity,'-s');
        xlabel(ax,'Time(min.)');
        ylabel(ax,'Trace(\chi_{i}\chi_{1})');
    catch
        hf = qes.ui.qosFigure('1 CZ Chi Stability',false);
        ax = axes('parent',hf);
    end
    drawnow;
    if Time(end) > TimeSpan
        break;
    end
    for ii = 1:numel(qubits)
        q = qubits{ii};
    %     tuneup.correctf01byPhase('qubits',q,'delayTime',1e-6,'gui',true,'save',true,'doCorrection',true,'iter',true);
        tuneup.iq2prob_01('qubits',q,'numSamples',2e4,'gui',true,'save',true);
    end
end
%% 2CZs
qubits = {'q12','q11','q10'};
setQSettings('r_avg',1000);
for ii = 1:numel(qubits)
q = qubits{ii};
    tuneup.correctf01byPhase('qubits',q,'delayTime',1e-6,'gui',true,'save',true,'doCorrection',true,'iter',true);
    tuneup.iq2prob_01('qubits',q,'numSamples',1e4,'gui',true,'save',true);
    tuneup.xyGateAmpTuner('qubit',q,'gateTyp','X/2','AE',true,'AENumPi',41,'gui',true,'save',true);
    tuneup.iq2prob_01('qubits',q,'numSamples',2e4,'gui',true,'save',true);
end
setQSettings('r_avg',2000);
tuneup.czAmplitude('controlQ','q11','targetQ','q12',...
    'notes','','gui',true,'save',true);
tuneup.czDynamicPhase('controlQ','q11','targetQ','q12','dynamicPhaseQ','q11',...
              'numCZs',10,'PhaseTolerance',0.03,'gui','true','save',true);
tuneup.czDynamicPhase('controlQ','q11','targetQ','q12','dynamicPhaseQ','q10',...
              'numCZs',10,'PhaseTolerance',0.03,'gui','true','save',true);
        
tuneup.czAmplitude('controlQ','q11','targetQ','q10',...
    'notes','','gui',true,'save',true);
tuneup.czDynamicPhase('controlQ','q11','targetQ','q10','dynamicPhaseQ','q11',...
              'numCZs',10,'PhaseTolerance',0.03,'gui','true','save',true);
tuneup.czDynamicPhase('controlQ','q11','targetQ','q10','dynamicPhaseQ','q10',...
              'numCZs',10,'PhaseTolerance',0.03,'gui','true','save',true);

for ii = 1:numel(qubits)
    q = qubits{ii};
%     tuneup.correctf01byPhase('qubits',q,'delayTime',1e-6,'gui',true,'save',true,'doCorrection',true,'iter',true);
    tuneup.iq2prob_01('qubits',q,'numSamples',2e4,'gui',true,'save',true);
end

%%
TimeSpan = 40*60;
Time = [];
CZTomoData = {};
Chi = {};
fidelity = [];
datafile = ['E:\data\20180216_12bit\sampling\stability\','Q10_q11_q12_cz_DensityMatrixStabilityNoCalibration_',datestr(now,'yymmddTHHMMSS'),'.mat'];
notes = 'r_avg=3000;Run immediatly after calibrations, No calibration between takes.';
hf = qes.ui.qosFigure('2 CZ Chi Stability',false);
ax = axes('parent',hf);
circuit = {'','CZ','CZ';
            'CZ','CZ',''};
 opQs = {'q10','q11','q12'};
 measureQs = {'q10','q11','q12'};
 stats = 3000;
 measureType = 'Mptomo'; % default 'Mzj', z projection
 noConcurrentCZ = false; % default false
tic
while 1
    Time(end+1) = toc;
    [result, ~, ~, ~] = sqc.util.runCircuit(circuit,opQs,measureQs,stats,measureType, noConcurrentCZ);
    CZTomoData{end+1} = result;
    Chi{end+1} = sqc.qfcns.processTomoData2Chi(CZTomoData{end});
    fidelity(end+1)  = real(trace(Chi{end}*Chi{1}));
    save(datafile,'Time','CZTomoData','Chi','fidelity','circuit','notes');
    try
        plot(ax,Time/60,fidelity,'-s');
        xlabel(ax,'Time(min.)');
        ylabel(ax,'Trace(\chi_{i}\chi_{1})');
    catch
        hf = qes.ui.qosFigure('2 CZ Chi Stability',false);
        ax = axes('parent',hf);
    end
    drawnow;
    if Time(end) > TimeSpan
        break;
    end
%     for ii = 1:numel(qubits)
%         q = qubits{ii};
%     %     tuneup.correctf01byPhase('qubits',q,'delayTime',1e-6,'gui',true,'save',true,'doCorrection',true,'iter',true);
%         tuneup.iq2prob_01('qubits',q,'numSamples',2e4,'gui',true,'save',true);
%     end
end
