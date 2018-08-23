gui = true;
save = true;
iq2ProbNumSamples = 2e4;
correctf01DelayTime = 0.6e-6;
AENumPi = 21;
gAmpTuneRange = 0.03;

qubitGroups = {{'q1','q4','q7'},...
               {'q2','q5','q8'},...
               {'q3','q6'}};
           
numCZs = [6,6,6,6,6,6,6];
PhaseTolerance = 0.03;
%%
setQSettings('r_avg',2000);
%% single qubit gates
for ii = 1:numel(qubitGroups)
    tuneup.iq2prob_01_parallel('qubits',qubitGroups{ii},'numSamples',iq2ProbNumSamples,'gui',gui,'save',save);
    tuneup.correctf01byPhase('qubits',qubitGroups{ii},'delayTime',correctf01DelayTime,'gui',gui,'save',save);
    tuneup.xyGateAmpTuner_parallel('qubits',qubitGroups{ii},'gateTyp','X/2','AENumPi',AENumPi,'tuneRange',gAmpTuneRange,'gui',gui,'save',save);
end

%% cz
czQSets = {{{'q1','q2'};{'q1','q4'};{'q2','q5','q8'};{'q6'}},...
           {{'q3','q2'};{'q4'};{'q2','q5','q8'};{'q3','q6'}},...
           {{'q3','q4'};{'q4'};{'q2','q5','q8'};{'q3','q6'}},...
           {{'q5','q4'};{'q4'};{'q2','q5','q8'};{'q6'}},...
           {{'q5','q6'};{'q4'};{'q2','q5','q8'};{'q6'}},...
           {{'q7','q6'};{'q4','q7'};{'q2','q5','q8'};{'q6'}},...
           {{'q7','q8'};{'q4','q7'};{'q2','q5','q8'};{'q6'}},...
          };
     
for ii = 1:numel(czQSets)
    tuneup.czAmplitude('controlQ',czQSets{ii}{1}{1},'targetQ',czQSets{ii}{1}{2},'gui',gui,'save',save);
    for jj = 2:numel(czQSets{ii})
        tuneup.czDynamicPhase_parallel('controlQ',czQSets{ii}{1}{1},'targetQ',czQSets{ii}{1}{2},'dynamicPhaseQs',czQSets{ii}{jj},...
            'numCZs',numCZs(ii),'PhaseTolerance',PhaseTolerance,...
            'gui',gui,'save',save);
    end
end

for ii = 1:numel(czQSets)
    tuneup.czAmplitude('controlQ',czQSets{ii}{1}{1},'targetQ',czQSets{ii}{1}{2},'gui',gui,'save',save);
    for jj = 2:numel(czQSets{ii})
        tuneup.czDynamicPhase_parallel('controlQ',czQSets{ii}{1}{1},'targetQ',czQSets{ii}{1}{2},'dynamicPhaseQs',czQSets{ii}{jj},...
            'numCZs',numCZs(ii),'PhaseTolerance',PhaseTolerance,...
            'gui',gui,'save',save);
    end
end

data_taking.public.scripts.temp.GHZ_4Q();

%%
setQSettings('r_avg',2000);
%% single qubit gates
for ii = 1:numel(qubitGroups)
    tuneup.iq2prob_01_parallel('qubits',qubitGroups{ii},'numSamples',iq2ProbNumSamples,'gui',gui,'save',save);
    tuneup.correctf01byPhase('qubits',qubitGroups{ii},'delayTime',correctf01DelayTime,'gui',gui,'save',save);
    tuneup.xyGateAmpTuner_parallel('qubits',qubitGroups{ii},'gateTyp','X/2','AENumPi',AENumPi,'tuneRange',gAmpTuneRange,'gui',gui,'save',save);
end

%% cz
czQSets = {{{'q1','q2'};{'q1','q4','q10'};{'q2','q5','q8','q11'};{'q6'}},...
           {{'q3','q2'};{'q4','q10'};{'q2','q5','q8','q11'};{'q3','q6'}},...
           {{'q3','q4'};{'q4','q10'};{'q2','q5','q8','q11'};{'q3','q6'}},...
           {{'q5','q4'};{'q4','q10'};{'q2','q5','q8','q11'};{'q6'}},...
           {{'q5','q6'};{'q4','q10'};{'q2','q5','q8','q11'};{'q6'}},...
           {{'q7','q6'};{'q4','q7','q10'};{'q2','q5','q8','q11'};{'q6'}},...
           {{'q7','q8'};{'q4','q7','q10'};{'q2','q5','q8','q11'};{'q6'}},...
          };
     
for ii = 1:numel(czQSets)
    tuneup.czAmplitude('controlQ',czQSets{ii}{1}{1},'targetQ',czQSets{ii}{1}{2},'gui',gui,'save',save);
    for jj = 2:numel(czQSets{ii})
        tuneup.czDynamicPhase_parallel('controlQ',czQSets{ii}{1}{1},'targetQ',czQSets{ii}{1}{2},'dynamicPhaseQs',czQSets{ii}{jj},...
            'numCZs',numCZs(ii),'PhaseTolerance',PhaseTolerance,...
            'gui',gui,'save',save);
    end
end

data_taking.public.scripts.temp.GHZ_5Q();

%%
setQSettings('r_avg',2000);
%% single qubit gates
for ii = 1:numel(qubitGroups)
    tuneup.iq2prob_01_parallel('qubits',qubitGroups{ii},'numSamples',iq2ProbNumSamples,'gui',gui,'save',save);
    tuneup.correctf01byPhase('qubits',qubitGroups{ii},'delayTime',correctf01DelayTime,'gui',gui,'save',save);
    tuneup.xyGateAmpTuner_parallel('qubits',qubitGroups{ii},'gateTyp','X/2','AENumPi',AENumPi,'tuneRange',gAmpTuneRange,'gui',gui,'save',save);
end

%% cz
czQSets = {{{'q1','q2'};{'q1','q4','q10'};{'q2','q5','q8','q11'};{'q6'}},...
           {{'q3','q2'};{'q4','q10'};{'q2','q5','q8','q11'};{'q3','q6'}},...
           {{'q3','q4'};{'q4','q10'};{'q2','q5','q8','q11'};{'q3','q6'}},...
           {{'q5','q4'};{'q4','q10'};{'q2','q5','q8','q11'};{'q6'}},...
           {{'q5','q6'};{'q4','q10'};{'q2','q5','q8','q11'};{'q6'}},...
           {{'q7','q6'};{'q4','q7','q10'};{'q2','q5','q8','q11'};{'q6'}},...
           {{'q7','q8'};{'q4','q7','q10'};{'q2','q5','q8','q11'};{'q6'}},...
          };
     
for ii = 1:numel(czQSets)
    tuneup.czAmplitude('controlQ',czQSets{ii}{1}{1},'targetQ',czQSets{ii}{1}{2},'gui',gui,'save',save);
    for jj = 2:numel(czQSets{ii})
        tuneup.czDynamicPhase_parallel('controlQ',czQSets{ii}{1}{1},'targetQ',czQSets{ii}{1}{2},'dynamicPhaseQs',czQSets{ii}{jj},...
            'numCZs',numCZs(ii),'PhaseTolerance',PhaseTolerance,...
            'gui',gui,'save',save);
    end
end

data_taking.public.scripts.temp.GHZ_6Q();

%%
setQSettings('r_avg',2000);
%% single qubit gates
for ii = 1:numel(qubitGroups)
    tuneup.iq2prob_01_parallel('qubits',qubitGroups{ii},'numSamples',iq2ProbNumSamples,'gui',gui,'save',save);
    tuneup.correctf01byPhase('qubits',qubitGroups{ii},'delayTime',correctf01DelayTime,'gui',gui,'save',save);
    tuneup.xyGateAmpTuner_parallel('qubits',qubitGroups{ii},'gateTyp','X/2','AENumPi',AENumPi,'tuneRange',gAmpTuneRange,'gui',gui,'save',save);
end

%% cz
czQSets = {{{'q1','q2'};{'q1','q4','q10'};{'q2','q5','q8','q11'};{'q6'}},...
           {{'q3','q2'};{'q4','q10'};{'q2','q5','q8','q11'};{'q3','q6'}},...
           {{'q3','q4'};{'q4','q10'};{'q2','q5','q8','q11'};{'q3','q6'}},...
           {{'q5','q4'};{'q4','q10'};{'q2','q5','q8','q11'};{'q6'}},...
           {{'q5','q6'};{'q4','q10'};{'q2','q5','q8','q11'};{'q6'}},...
           {{'q7','q6'};{'q4','q7','q10'};{'q2','q5','q8','q11'};{'q6'}},...
           {{'q7','q8'};{'q4','q7','q10'};{'q2','q5','q8','q11'};{'q6'}},...
          };
     
for ii = 1:numel(czQSets)
    tuneup.czAmplitude('controlQ',czQSets{ii}{1}{1},'targetQ',czQSets{ii}{1}{2},'gui',gui,'save',save);
    for jj = 2:numel(czQSets{ii})
        tuneup.czDynamicPhase_parallel('controlQ',czQSets{ii}{1}{1},'targetQ',czQSets{ii}{1}{2},'dynamicPhaseQs',czQSets{ii}{jj},...
            'numCZs',numCZs(ii),'PhaseTolerance',PhaseTolerance,...
            'gui',gui,'save',save);
    end
end

data_taking.public.scripts.temp.GHZ_6Q();

%%
setQSettings('r_avg',2000);
%% single qubit gates
for ii = 1:numel(qubitGroups)
    tuneup.iq2prob_01_parallel('qubits',qubitGroups{ii},'numSamples',iq2ProbNumSamples,'gui',gui,'save',save);
    tuneup.correctf01byPhase('qubits',qubitGroups{ii},'delayTime',correctf01DelayTime,'gui',gui,'save',save);
    tuneup.xyGateAmpTuner_parallel('qubits',qubitGroups{ii},'gateTyp','X/2','AENumPi',AENumPi,'tuneRange',gAmpTuneRange,'gui',gui,'save',save);
end

%% cz
czQSets = {{{'q1','q2'};{'q1','q4','q10'};{'q2','q5','q8','q11'};{'q6'}},...
           {{'q3','q2'};{'q4','q10'};{'q2','q5','q8','q11'};{'q3','q6'}},...
           {{'q3','q4'};{'q4','q10'};{'q2','q5','q8','q11'};{'q3','q6'}},...
           {{'q5','q4'};{'q4','q10'};{'q2','q5','q8','q11'};{'q6'}},...
           {{'q5','q6'};{'q4','q10'};{'q2','q5','q8','q11'};{'q6'}},...
           {{'q7','q6'};{'q4','q7','q10'};{'q2','q5','q8','q11'};{'q6'}},...
           {{'q7','q8'};{'q4','q7','q10'};{'q2','q5','q8','q11'};{'q6'}},...
          };
     
for ii = 1:numel(czQSets)
    tuneup.czAmplitude('controlQ',czQSets{ii}{1}{1},'targetQ',czQSets{ii}{1}{2},'gui',gui,'save',save);
    for jj = 2:numel(czQSets{ii})
        tuneup.czDynamicPhase_parallel('controlQ',czQSets{ii}{1}{1},'targetQ',czQSets{ii}{1}{2},'dynamicPhaseQs',czQSets{ii}{jj},...
            'numCZs',numCZs(ii),'PhaseTolerance',PhaseTolerance,...
            'gui',gui,'save',save);
    end
end

data_taking.public.scripts.temp.GHZ_7Q();

%%
setQSettings('r_avg',2000);
%% single qubit gates
for ii = 1:numel(qubitGroups)
    tuneup.iq2prob_01_parallel('qubits',qubitGroups{ii},'numSamples',iq2ProbNumSamples,'gui',gui,'save',save);
    tuneup.correctf01byPhase('qubits',qubitGroups{ii},'delayTime',correctf01DelayTime,'gui',gui,'save',save);
    tuneup.xyGateAmpTuner_parallel('qubits',qubitGroups{ii},'gateTyp','X/2','AENumPi',AENumPi,'tuneRange',gAmpTuneRange,'gui',gui,'save',save);
end

%% cz
czQSets = {{{'q1','q2'};{'q1','q4','q10'};{'q2','q5','q8','q11'};{'q6'}},...
           {{'q3','q2'};{'q4','q10'};{'q2','q5','q8','q11'};{'q3','q6'}},...
           {{'q3','q4'};{'q4','q10'};{'q2','q5','q8','q11'};{'q3','q6'}},...
           {{'q5','q4'};{'q4','q10'};{'q2','q5','q8','q11'};{'q6'}},...
           {{'q5','q6'};{'q4','q10'};{'q2','q5','q8','q11'};{'q6'}},...
           {{'q7','q6'};{'q4','q7','q10'};{'q2','q5','q8','q11'};{'q6'}},...
           {{'q7','q8'};{'q4','q7','q10'};{'q2','q5','q8','q11'};{'q6'}},...
          };
     
for ii = 1:numel(czQSets)
    tuneup.czAmplitude('controlQ',czQSets{ii}{1}{1},'targetQ',czQSets{ii}{1}{2},'gui',gui,'save',save);
    for jj = 2:numel(czQSets{ii})
        tuneup.czDynamicPhase_parallel('controlQ',czQSets{ii}{1}{1},'targetQ',czQSets{ii}{1}{2},'dynamicPhaseQs',czQSets{ii}{jj},...
            'numCZs',numCZs(ii),'PhaseTolerance',PhaseTolerance,...
            'gui',gui,'save',save);
    end
end

data_taking.public.scripts.temp.GHZ_7Q();

%%
setQSettings('r_avg',2000);
%% single qubit gates
for ii = 1:numel(qubitGroups)
    tuneup.iq2prob_01_parallel('qubits',qubitGroups{ii},'numSamples',iq2ProbNumSamples,'gui',gui,'save',save);
    tuneup.correctf01byPhase('qubits',qubitGroups{ii},'delayTime',correctf01DelayTime,'gui',gui,'save',save);
    tuneup.xyGateAmpTuner_parallel('qubits',qubitGroups{ii},'gateTyp','X/2','AENumPi',AENumPi,'tuneRange',gAmpTuneRange,'gui',gui,'save',save);
end

%% cz
czQSets = {{{'q1','q2'};{'q1','q4','q10'};{'q2','q5','q8','q11'};{'q6'}},...
           {{'q3','q2'};{'q4','q10'};{'q2','q5','q8','q11'};{'q3','q6'}},...
           {{'q3','q4'};{'q4','q10'};{'q2','q5','q8','q11'};{'q3','q6'}},...
           {{'q5','q4'};{'q4','q10'};{'q2','q5','q8','q11'};{'q6'}},...
           {{'q5','q6'};{'q4','q10'};{'q2','q5','q8','q11'};{'q6'}},...
           {{'q7','q6'};{'q4','q7','q10'};{'q2','q5','q8','q11'};{'q6'}},...
           {{'q7','q8'};{'q4','q7','q10'};{'q2','q5','q8','q11'};{'q6'}},...
          };
     
for ii = 1:numel(czQSets)
    tuneup.czAmplitude('controlQ',czQSets{ii}{1}{1},'targetQ',czQSets{ii}{1}{2},'gui',gui,'save',save);
    for jj = 2:numel(czQSets{ii})
        tuneup.czDynamicPhase_parallel('controlQ',czQSets{ii}{1}{1},'targetQ',czQSets{ii}{1}{2},'dynamicPhaseQs',czQSets{ii}{jj},...
            'numCZs',numCZs(ii),'PhaseTolerance',PhaseTolerance,...
            'gui',gui,'save',save);
    end
end

data_taking.public.scripts.temp.GHZ_8Q();

%%
setQSettings('r_avg',2000);
%% single qubit gates
for ii = 1:numel(qubitGroups)
    tuneup.iq2prob_01_parallel('qubits',qubitGroups{ii},'numSamples',iq2ProbNumSamples,'gui',gui,'save',save);
    tuneup.correctf01byPhase('qubits',qubitGroups{ii},'delayTime',correctf01DelayTime,'gui',gui,'save',save);
    tuneup.xyGateAmpTuner_parallel('qubits',qubitGroups{ii},'gateTyp','X/2','AENumPi',AENumPi,'tuneRange',gAmpTuneRange,'gui',gui,'save',save);
end

%% cz
czQSets = {{{'q1','q2'};{'q1','q4','q10'};{'q2','q5','q8','q11'};{'q6'}},...
           {{'q3','q2'};{'q4','q10'};{'q2','q5','q8','q11'};{'q3','q6'}},...
           {{'q3','q4'};{'q4','q10'};{'q2','q5','q8','q11'};{'q3','q6'}},...
           {{'q5','q4'};{'q4','q10'};{'q2','q5','q8','q11'};{'q6'}},...
           {{'q5','q6'};{'q4','q10'};{'q2','q5','q8','q11'};{'q6'}},...
           {{'q7','q6'};{'q4','q7','q10'};{'q2','q5','q8','q11'};{'q6'}},...
           {{'q7','q8'};{'q4','q7','q10'};{'q2','q5','q8','q11'};{'q6'}},...
          };
     
for ii = 1:numel(czQSets)
    tuneup.czAmplitude('controlQ',czQSets{ii}{1}{1},'targetQ',czQSets{ii}{1}{2},'gui',gui,'save',save);
    for jj = 2:numel(czQSets{ii})
        tuneup.czDynamicPhase_parallel('controlQ',czQSets{ii}{1}{1},'targetQ',czQSets{ii}{1}{2},'dynamicPhaseQs',czQSets{ii}{jj},...
            'numCZs',numCZs(ii),'PhaseTolerance',PhaseTolerance,...
            'gui',gui,'save',save);
    end
end

data_taking.public.scripts.temp.GHZ_8Q();

%%
setQSettings('r_avg',2000);
%% single qubit gates
for ii = 1:numel(qubitGroups)
    tuneup.iq2prob_01_parallel('qubits',qubitGroups{ii},'numSamples',iq2ProbNumSamples,'gui',gui,'save',save);
    tuneup.correctf01byPhase('qubits',qubitGroups{ii},'delayTime',correctf01DelayTime,'gui',gui,'save',save);
    tuneup.xyGateAmpTuner_parallel('qubits',qubitGroups{ii},'gateTyp','X/2','AENumPi',AENumPi,'tuneRange',gAmpTuneRange,'gui',gui,'save',save);
end

%% cz
czQSets = {{{'q1','q2'};{'q1','q4','q10'};{'q2','q5','q8','q11'};{'q6'}},...
           {{'q3','q2'};{'q4','q10'};{'q2','q5','q8','q11'};{'q3','q6'}},...
           {{'q3','q4'};{'q4','q10'};{'q2','q5','q8','q11'};{'q3','q6'}},...
           {{'q5','q4'};{'q4','q10'};{'q2','q5','q8','q11'};{'q6'}},...
           {{'q5','q6'};{'q4','q10'};{'q2','q5','q8','q11'};{'q6'}},...
           {{'q7','q6'};{'q4','q7','q10'};{'q2','q5','q8','q11'};{'q6'}},...
           {{'q7','q8'};{'q4','q7','q10'};{'q2','q5','q8','q11'};{'q6'}},...
          };
     
for ii = 1:numel(czQSets)
    tuneup.czAmplitude('controlQ',czQSets{ii}{1}{1},'targetQ',czQSets{ii}{1}{2},'gui',gui,'save',save);
    for jj = 2:numel(czQSets{ii})
        tuneup.czDynamicPhase_parallel('controlQ',czQSets{ii}{1}{1},'targetQ',czQSets{ii}{1}{2},'dynamicPhaseQs',czQSets{ii}{jj},...
            'numCZs',numCZs(ii),'PhaseTolerance',PhaseTolerance,...
            'gui',gui,'save',save);
    end
end

data_taking.public.scripts.temp.GHZ_8Q();


%%
q = 'q5';
tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);
tuneup.correctf01byPhase('qubits',q,'delayTime',0.7e-6,'gui','true','save',true);
tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);

setQSettings('r_avg',5000);
ramsey('qubit',q,'mode','dp',... % available modes are: df01, dp and dz
      'time',[20:25:10e3],'detuning',[2]*1e6,...
      'dataTyp','P','phaseOffset',0,'notes','','gui',true,'save',true);
spin_echo('qubit',q,'mode','dp',... % available modes are: df01, dp and dz
      'time',[0:50:20e3],'detuning',[2]*1e6,...
      'notes','','gui',true,'save',true);
  
tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);
setQSettings('r_avg',2000);
% bias = sqc.util.detune2zpa(q,-200e6)
bais = -1.5e4:300:3e4;
T1_1('qubit',q,'biasAmp',bais,'biasDelay',20,'time',[20:500:28e3],... % [20:200:2.8e4]
      'gui',true,'save',true);
%%
q = 'q6';
tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);
tuneup.correctf01byPhase('qubits',q,'delayTime',0.7e-6,'gui','true','save',true);
tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);

setQSettings('r_avg',5000);
ramsey('qubit',q,'mode','dp',... % available modes are: df01, dp and dz
      'time',[20:25:10e3],'detuning',[2]*1e6,...
      'dataTyp','P','phaseOffset',0,'notes','','gui',true,'save',true);
spin_echo('qubit',q,'mode','dp',... % available modes are: df01, dp and dz
      'time',[0:50:20e3],'detuning',[2]*1e6,...
      'notes','','gui',true,'save',true);
  
tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);
setQSettings('r_avg',2000);
% bias = sqc.util.detune2zpa(q,-200e6)
bais = -2e4:300:3e4;
T1_1('qubit',q,'biasAmp',bais,'biasDelay',20,'time',[20:500:28e3],... % [20:200:2.8e4]
      'gui',true,'save',true);