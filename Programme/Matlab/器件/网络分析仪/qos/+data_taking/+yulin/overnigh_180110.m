qubits = {'q1','q2','q3','q4','q5','q6','q7','q10','q11'};
for ii = 1:numel(qubits)
    try
    q = qubits{ii};
tuneup.iq2prob_01('qubits',q,'numSamples',2e4,'gui',true,'fineTune',false,'save',true);
tuneup.correctf01byPhase('qubits',q,'delayTime',0.7e-6,'gui',true,'save',true);
tuneup.xyGateAmpTuner('qubit',q,'gateTyp','X/2','AE',true,'gui',true,'save',true);
tuneup.iq2prob_01('qubits',q,'numSamples',2e4,'gui',true,'fineTune',false,'save',true);

setQSettings('r_avg',1000);
numGates = int16(unique(round(logspace(1,log10(250),20))));
[Pref,Pgate] = randBenchMarking('qubit1',q,'qubit2',[],...
       'process','Y/2','numGates',numGates,'numReps',60,...
       'gui',true,'save',true);   
[fidelity,h] = toolbox.data_tool.randBenchMarking(numGates, Pref, Pgate, 1, 'Y/2');
    catch ME
        ME
    end
end

qubits = {'q6','q10,''q11'};
for ii = 1:numel(qubits)
    try
    q = qubits{ii};
tuneup.iq2prob_01('qubits',q,'numSamples',2e4,'gui',true,'fineTune',false,'save',true);
tuneup.correctf01byPhase('qubits',q,'delayTime',0.7e-6,'gui',true,'save',true);
tuneup.xyGateAmpTuner('qubit',q,'gateTyp','X/2','AE',true,'gui',true,'save',true);
tuneup.iq2prob_01('qubits',q,'numSamples',2e4,'gui',true,'fineTune',false,'save',true);

setQSettings('r_avg',1000);
numGates = int16(unique(round(logspace(1,log10(250),20))));
[Pref,Pgate] = randBenchMarking('qubit1',q,'qubit2',[],...
       'process','X/2','numGates',numGates,'numReps',60,...
       'gui',true,'save',true);   
[fidelity,h] = toolbox.data_tool.randBenchMarking(numGates, Pref, Pgate, 1, 'X/2');
    catch
    end
end

qubits = {'q1','q2','q3','q4','q5','q6','q7','q10','q11'};
for ii = 1:numel(qubits)
    try
    q = qubits{ii};
tuneup.iq2prob_01('qubits',q,'numSamples',2e4,'gui',true,'fineTune',false,'save',true);
tuneup.correctf01byPhase('qubits',q,'delayTime',0.7e-6,'gui',true,'save',true);
tuneup.xyGateAmpTuner('qubit',q,'gateTyp','X/2','AE',true,'gui',true,'save',true);
tuneup.iq2prob_01('qubits',q,'numSamples',2e4,'gui',true,'fineTune',false,'save',true);

setQSettings('r_avg',1000);
numGates = int16(unique(round(logspace(1,log10(200),20))));
[Pref,Pgate] = randBenchMarking('qubit1',q,'qubit2',[],...
       'process','X','numGates',numGates,'numReps',60,...
       'gui',true,'save',true);   
[fidelity,h] = toolbox.data_tool.randBenchMarking(numGates, Pref, Pgate, 1, 'X');
    catch ME
        ME
    end
end