%%m, Pgate,2, 'CZ');
%%
qubits = {'q11','q10'};
setQSettings('r_avg',2000);
for ii = 1:numel(qubits)
     q = qubits{ii};
    tuneup.correctf01byPhase('qubits',q,'delayTime',1e-6,'gui',true,'save',true);
    tuneup.xyGateAmpTuner('qubit',q,'gateTyp','X/2','AE',true,'AENumPi',41,'gui',true,'save',true);
    tuneup.iq2prob_01('qubits',q,'numSamples',2e4,'gui',true,'fineTune',false,'save',true);
end
tuneup.czAmplitude('controlQ','q11','targetQ','q12',...
    'notes','','gui',true,'save',true);
tuneup.czDynamicPhase('controlQ','q11','targetQ','q10','dynamicPhaseQ','q11',...
              'numCZs',10,'PhaseTolerance',0.03,'gui','true','save',true);
tuneup.czDynamicPhase('controlQ','q11','targetQ','q10','dynamicPhaseQ','q10',...
              'numCZs',10,'PhaseTolerance',0.03,'gui','true','save',true);

setQSettings('r_avg',2000);
numGates = int16(unique(round(logspace(log10(1),log10(40),20))));
[Pref,Pgate] = randBenchMarking('qubit1','q11','qubit2','q10',...
       'process','CZ','numGates',numGates,'numReps',50,...
       'gui',true,'save',true);
[fidelity,h] = toolbox.data_tool.randBenchMarking(numGates, Pref, Pgate,2, 'CZ');
%%
qubits = {'q11','q12'};
setQSettings('r_avg',2000);
for ii = 1:numel(qubits)
     q = qubits{ii};
    tuneup.correctf01byPhase('qubits',q,'delayTime',1e-6,'gui',true,'save',true);
    tuneup.xyGateAmpTuner('qubit',q,'gateTyp','X/2','AE',true,'AENumPi',41,'gui',true,'save',true);
    tuneup.iq2prob_01('qubits',q,'numSamples',2e4,'gui',true,'fineTune',false,'save',true);
end
tuneup.czAmplitude('controlQ','q11','targetQ','q12',...
    'notes','','gui',true,'save',true);
tuneup.czDynamicPhase('controlQ','q11','targetQ','q12','dynamicPhaseQ','q11',...
              'numCZs',10,'PhaseTolerance',0.03,'gui','true','save',true);
tuneup.czDynamicPhase('controlQ','q11','targetQ','q12','dynamicPhaseQ','q12',...
              'numCZs',10,'PhaseTolerance',0.03,'gui','true','save',true);

setQSettings('r_avg',2000);
numGates = int16(unique(round(logspace(log10(1),log10(30),15))));
[Pref,Pgate] = randBenchMarking('qubit1','q11','qubit2','q12',...
       'process','CZ','numGates',numGates,'numReps',50,'gui',true,'save',true);
[fidelity,h] = toolbox.data_tool.randBenchMarking(numGates, Pref, Pgate,2, 'CZ');
%%
qubits = {'q11','q10'};
setQSettings('r_avg',2000);
for ii = 1:numel(qubits)
     q = qubits{ii};
    tuneup.correctf01byPhase('qubits',q,'delayTime',1e-6,'gui',true,'save',true);
    tuneup.xyGateAmpTuner('qubit',q,'gateTyp','X/2','AE',true,'AENumPi',41,'gui',true,'save',true);
    tuneup.iq2prob_01('qubits',q,'numSamples',2e4,'gui',true,'fineTune',false,'save',true);
end
tuneup.czDynamicPhase('controlQ','q11','targetQ','q10','dynamicPhaseQ','q11',...
              'numCZs',10,'PhaseTolerance',0.03,'gui','true','save',true);
tuneup.czDynamicPhase('controlQ','q11','targetQ','q10','dynamicPhaseQ','q10',...
              'numCZs',10,'PhaseTolerance',0.03,'gui','true','save',true);

setQSettings('r_avg',2000);
numGates = int16(unique(round(logspace(log10(1),log10(40),15))));
[Pref,Pgate] = randBenchMarking('qubit1','q11','qubit2','q10',...
       'process','CZ','numGates',numGates,'numReps',50,...
       'gui',true,'save',true);
[fidelity,h] = toolbox.data_tool.randBenchMarking(numGates, Pref, Pgate,2, 'CZ');
%%
qubits = {'q12','q11'};
process = {'X/2','-X/2','Y/2','-Y/2'};
for ii = 1:numel(qubits)
     q = qubits{ii};
     for jj = 1:numel(process)
         setQSettings('r_avg',1000);
        tuneup.iq2prob_01('qubits',q,'numSamples',2e4,'gui',true,'fineTune',false,'save',true);
        tuneup.correctf01byPhase('qubits',q,'delayTime',1e-6,'gui',true,'save',true);
        tuneup.xyGateAmpTuner('qubit',q,'gateTyp','X/2','AE',true,'AENumPi',41,'gui',true,'save',true);
        tuneup.iq2prob_01('qubits',q,'numSamples',2e4,'gui',true,'fineTune',false,'save',true);

        if strcmp(process{jj},'X') || strcmp(process{jj},'Y')
            numGates = int16(unique(round(logspace(log10(10),log10(300),20))));
        else
            numGates = int16(unique(round(logspace(log10(10),log10(380),20))));
        end
        setQSettings('r_avg',1000);
        [Pref,Pgate] = randBenchMarking('qubit1',q,'qubit2',[],...
               'process',process{jj},'numGates',numGates,'numReps',70,...
               'gui',true,'save',true);   
        [fidelity,h] = toolbox.data_tool.randBenchMarking(numGates, Pref, Pgate, 1, process{jj});
     end
end
