gui = true;
update = true;
iq2ProbNumSamples = 2e4;
correctf01DelayTime = 0.6e-6;
AENumPi = 31;
gAmpTuneRange = 0.03;
fineTune = false;

% qubitGroups = {{'q1','q4','q7','q10'},...
%                {'q2','q5','q8','q11'},...
%                {'q3','q6','q9'}};
           
qubitGroups = {{'q1','q4','q7'},...
               {'q2','q5'},...
               {'q3','q6'}};
           
czQSets = {{{'q1','q2'};{'q1','q4'};{'q2','q5'};{'q6'}},...
           {{'q3','q2'};{'q1','q4'};{'q2','q5'};{'q3','q6'}},...
           {{'q3','q4'};{'q1','q4'};{'q2','q5'};{'q3','q6'}},...
           {{'q5','q4'};{'q1','q4'};{'q2','q5'};{'q6'}},...
           {{'q5','q6'};{'q1','q4'};{'q2','q5'};{'q6'}},...
           {{'q7','q6'};{'q1','q4','q7'};{'q2','q5'};{'q6'}},...
          };
numCZs = [7,7,7,7,7,7,7,7,7,7,7];
PhaseTolerance = 0.03;

setQSettings('r_avg',2000);
%%
for ii = 1:numel(qubitGroups)
    tuneup.iq2prob_01('qubits',qubitGroups{ii},'numSamples',iq2ProbNumSamples,'fineTune',fineTune,'gui',gui,'save',update);
    tuneup.correctf01byPhase('qubits',qubitGroups{ii},'delayTime',correctf01DelayTime,'gui',gui,'save',update);
    tuneup.xyGateAmpTuner_parallel('qubits',qubitGroups{ii},'gateTyp','X/2','AENumPi',AENumPi,'tuneRange',gAmpTuneRange,'gui',gui,'save',update);
    tuneup.iq2prob_01('qubits',qubitGroups{ii},'numSamples',iq2ProbNumSamples,'fineTune',fineTune,'gui',gui,'save',update);
end

% for ii = 1:numel(czQSets)
%     tuneup.czAmplitude('controlQ',czQSets{ii}{1}{1},'targetQ',czQSets{ii}{1}{2},'gui',gui,'save',update);
%     for jj = 2:numel(czQSets{ii})
%         tuneup.czDynamicPhase_parallel('controlQ',czQSets{ii}{1}{1},'targetQ',czQSets{ii}{1}{2},'dynamicPhaseQs',czQSets{ii}{jj},...
%             'numCZs',numCZs(ii),'PhaseTolerance',PhaseTolerance,...
%             'gui',gui,'save',update);
%     end
% end

for ii = 1:numel(czQSets)
    % tuneup.czAmplitude('controlQ',czQSets{ii}{1}{1},'targetQ',czQSets{ii}{1}{2},'gui',gui,'save',update);
    for jj = 2:numel(czQSets{ii})
        tuneup.czDynamicPhase_parallel('controlQ',czQSets{ii}{1}{1},'targetQ',czQSets{ii}{1}{2},'dynamicPhaseQs',czQSets{ii}{jj},...
            'numCZs',numCZs(ii),'PhaseTolerance',PhaseTolerance,...
            'gui',gui,'save',update);
    end
end

for ii = 1:numel(qubitGroups)
    tuneup.iq2prob_01('qubits',qubitGroups{ii},'numSamples',iq2ProbNumSamples,'fineTune',fineTune,'gui',gui,'save',update);
end

%%
setQSettings('r_avg',5000);
for ii = 1:4
data_taking.yulin.GHZ_Prob(3);
end

for ii = 1:4
data_taking.yulin.GHZ_Prob(4);
end

for ii = 1:6
data_taking.yulin.GHZ_Prob(5);
end

for ii = 1:10
data_taking.yulin.GHZ_Prob(6);
end

for ii = 1:10
data_taking.yulin.GHZ_Prob(7);
end
%% 
for ii = 1:numel(qubitGroups)
    tuneup.iq2prob_01('qubits',qubitGroups{ii},'numSamples',iq2ProbNumSamples,'fineTune',fineTune,'gui',gui,'save',update);
    tuneup.correctf01byPhase('qubits',qubitGroups{ii},'delayTime',correctf01DelayTime,'gui',gui,'save',update);
    tuneup.iq2prob_01('qubits',qubitGroups{ii},'numSamples',iq2ProbNumSamples,'fineTune',fineTune,'gui',gui,'save',update);
end

for ii = 1:numel(czQSets)
    for jj = 2:numel(czQSets{ii})
        tuneup.czDynamicPhase_parallel('controlQ',czQSets{ii}{1}{1},'targetQ',czQSets{ii}{1}{2},'dynamicPhaseQs',czQSets{ii}{jj},...
            'numCZs',numCZs(ii),'PhaseTolerance',PhaseTolerance,...
            'gui',gui,'save',update);
    end
end

for ii = 1:numel(qubitGroups)
    tuneup.iq2prob_01('qubits',qubitGroups{ii},'numSamples',iq2ProbNumSamples,'fineTune',fineTune,'gui',gui,'save',update);
end
%%
data_taking.public.scripts.temp.GHZ_4Q();

%% 
for ii = 1:numel(qubitGroups)
    tuneup.iq2prob_01('qubits',qubitGroups{ii},'numSamples',iq2ProbNumSamples,'fineTune',fineTune,'gui',gui,'save',update);
    tuneup.correctf01byPhase('qubits',qubitGroups{ii},'delayTime',correctf01DelayTime,'gui',gui,'save',update);
    tuneup.iq2prob_01('qubits',qubitGroups{ii},'numSamples',iq2ProbNumSamples,'fineTune',fineTune,'gui',gui,'save',update);
end

for ii = 1:numel(czQSets)
    for jj = 2:numel(czQSets{ii})
        tuneup.czDynamicPhase_parallel('controlQ',czQSets{ii}{1}{1},'targetQ',czQSets{ii}{1}{2},'dynamicPhaseQs',czQSets{ii}{jj},...
            'numCZs',numCZs(ii),'PhaseTolerance',PhaseTolerance,...
            'gui',gui,'save',update);
    end
end

for ii = 1:numel(qubitGroups)
    tuneup.iq2prob_01('qubits',qubitGroups{ii},'numSamples',iq2ProbNumSamples,'fineTune',fineTune,'gui',gui,'save',update);
end
%%
data_taking.public.scripts.temp.GHZ_5Q();

%% 
for ii = 1:numel(qubitGroups)
    tuneup.iq2prob_01('qubits',qubitGroups{ii},'numSamples',iq2ProbNumSamples,'fineTune',fineTune,'gui',gui,'save',update);
    tuneup.correctf01byPhase('qubits',qubitGroups{ii},'delayTime',correctf01DelayTime,'gui',gui,'save',update);
    tuneup.iq2prob_01('qubits',qubitGroups{ii},'numSamples',iq2ProbNumSamples,'fineTune',fineTune,'gui',gui,'save',update);
end

for ii = 1:numel(czQSets)
    for jj = 2:numel(czQSets{ii})
        tuneup.czDynamicPhase_parallel('controlQ',czQSets{ii}{1}{1},'targetQ',czQSets{ii}{1}{2},'dynamicPhaseQs',czQSets{ii}{jj},...
            'numCZs',numCZs(ii),'PhaseTolerance',PhaseTolerance,...
            'gui',gui,'save',update);
    end
end

for ii = 1:numel(qubitGroups)
    tuneup.iq2prob_01('qubits',qubitGroups{ii},'numSamples',iq2ProbNumSamples,'fineTune',fineTune,'gui',gui,'save',update);
end
%%
data_taking.public.scripts.temp.GHZ_6Q();
%% 
for ii = 1:numel(qubitGroups)
    tuneup.iq2prob_01('qubits',qubitGroups{ii},'numSamples',iq2ProbNumSamples,'fineTune',fineTune,'gui',gui,'save',update);
    tuneup.correctf01byPhase('qubits',qubitGroups{ii},'delayTime',correctf01DelayTime,'gui',gui,'save',update);
    tuneup.iq2prob_01('qubits',qubitGroups{ii},'numSamples',iq2ProbNumSamples,'fineTune',fineTune,'gui',gui,'save',update);
end

for ii = 1:numel(czQSets)
    for jj = 2:numel(czQSets{ii})
        tuneup.czDynamicPhase_parallel('controlQ',czQSets{ii}{1}{1},'targetQ',czQSets{ii}{1}{2},'dynamicPhaseQs',czQSets{ii}{jj},...
            'numCZs',numCZs(ii),'PhaseTolerance',PhaseTolerance,...
            'gui',gui,'save',update);
    end
end

for ii = 1:numel(qubitGroups)
    tuneup.iq2prob_01('qubits',qubitGroups{ii},'numSamples',iq2ProbNumSamples,'fineTune',fineTune,'gui',gui,'save',update);
end
%%
data_taking.public.scripts.temp.GHZ_7Q();

%%
q = 'q2';
tuneup.iq2prob_01('qubits',q,'numSamples',2e4,'gui',true,'fineTune',false,'save',true);
tuneup.correctf01byPhase('qubits',q,'delayTime',0.7e-6,'gui',true,'save',true);
tuneup.xyGateAmpTuner('qubit',q,'gateTyp','X/2','AE',true,'gui',true,'save',true);
tuneup.iq2prob_01('qubits',q,'numSamples',2e4,'gui',true,'fineTune',false,'save',true);

setQSettings('r_avg',1000);
numGates = int16(unique(round(logspace(1,log10(300),20))));
[Pref,Pgate] = randBenchMarking('qubit1',q,'qubit2',[],...
       'process','X/2','numGates',numGates,'numReps',60,...
       'gui',true,'save',true);   
[fidelity,h] = toolbox.data_tool.randBenchMarking(numGates, Pref, Pgate, 1, 'X/2');

tuneup.iq2prob_01('qubits',q,'numSamples',2e4,'gui',true,'fineTune',false,'save',true);
tuneup.correctf01byPhase('qubits',q,'delayTime',0.7e-6,'gui',true,'save',true);
tuneup.xyGateAmpTuner('qubit',q,'gateTyp','X/2','AE',true,'gui',true,'save',true);
tuneup.iq2prob_01('qubits',q,'numSamples',2e4,'gui',true,'fineTune',false,'save',true);
[Pref,Pgate] = randBenchMarking('qubit1',q,'qubit2',[],...
       'process','Y/2','numGates',numGates,'numReps',60,...
       'gui',true,'save',true);   
[fidelity,h] = toolbox.data_tool.randBenchMarking(numGates, Pref, Pgate, 1, 'X/2');

%%
q = 'q3';
tuneup.iq2prob_01('qubits',q,'numSamples',2e4,'gui',true,'fineTune',false,'save',true);
tuneup.correctf01byPhase('qubits',q,'delayTime',0.7e-6,'gui',true,'save',true);
tuneup.xyGateAmpTuner('qubit',q,'gateTyp','X/2','AE',true,'gui',true,'save',true);
tuneup.iq2prob_01('qubits',q,'numSamples',2e4,'gui',true,'fineTune',false,'save',true);

setQSettings('r_avg',1000);
numGates = int16(unique(round(logspace(1,log10(300),20))));
[Pref,Pgate] = randBenchMarking('qubit1',q,'qubit2',[],...
       'process','X/2','numGates',numGates,'numReps',60,...
       'gui',true,'save',true);   
[fidelity,h] = toolbox.data_tool.randBenchMarking(numGates, Pref, Pgate, 1, 'X/2');

tuneup.iq2prob_01('qubits',q,'numSamples',2e4,'gui',true,'fineTune',false,'save',true);
tuneup.correctf01byPhase('qubits',q,'delayTime',0.7e-6,'gui',true,'save',true);
tuneup.xyGateAmpTuner('qubit',q,'gateTyp','X/2','AE',true,'gui',true,'save',true);
tuneup.iq2prob_01('qubits',q,'numSamples',2e4,'gui',true,'fineTune',false,'save',true);
[Pref,Pgate] = randBenchMarking('qubit1',q,'qubit2',[],...
       'process','Y/2','numGates',numGates,'numReps',60,...
       'gui',true,'save',true);   
[fidelity,h] = toolbox.data_tool.randBenchMarking(numGates, Pref, Pgate, 1, 'X/2');
