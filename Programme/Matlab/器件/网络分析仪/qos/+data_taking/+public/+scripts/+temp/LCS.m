gui = true;
updateSettings = true;
iq2ProbNumSamples = 2e4;
correctf01DelayTime = 0.6e-6;
AENumPi = 31;
gAmpTuneRange = 0.02;
fineTune = false;

qubitGroups = {{'q1','q4','q7'},...
               {'q2','q5'},...
               {'q3','q6'}};
           
czQSets = {{{'q1','q2'};{'q1','q4','q10'};{'q2','q5','q8','q11'};{'q6'}},...
           {{'q3','q2'};{'q1','q4','q10'};{'q2','q5','q8','q11'};{'q3','q6'}},...
           {{'q3','q4'};{'q1','q4','q10'};{'q2','q5','q8','q11'};{'q3','q6'}},...
           {{'q5','q4'};{'q1','q4','q10'};{'q2','q5','q8','q11'};{'q6'}},...
           {{'q5','q6'};{'q1','q4','q10'};{'q2','q5','q8','q11'};{'q6'}},...
           {{'q7','q6'};{'q1','q4','q7','q10'};{'q2','q5','q8','q11'};{'q6'}},...
          };
numCZs = [7,7,7,7,7,7,7,7,7,7,7];
PhaseTolerance = 0.03;

setQSettings('r_avg',2000);
%%
for ii = 1:numel(qubitGroups)
    tuneup.iq2prob_01('qubits',qubitGroups{ii},'numSamples',iq2ProbNumSamples,'fineTune',fineTune,'gui',gui,'save',updateSettings);
    tuneup.correctf01byPhase('qubits',qubitGroups{ii},'delayTime',correctf01DelayTime,'gui',gui,'save',updateSettings);
    tuneup.xyGateAmpTuner_parallel('qubits',qubitGroups{ii},'gateTyp','X/2','AENumPi',AENumPi,'tuneRange',gAmpTuneRange,'gui',gui,'save',updateSettings);
end

for ii = 1:numel(czQSets)
    tuneup.czAmplitude('controlQ',czQSets{ii}{1}{1},'targetQ',czQSets{ii}{1}{2},'gui',gui,'save',updateSettings);
    for jj = 2:numel(czQSets{ii})
        tuneup.czDynamicPhase_parallel('controlQ',czQSets{ii}{1}{1},'targetQ',czQSets{ii}{1}{2},'dynamicPhaseQs',czQSets{ii}{jj},...
            'numCZs',numCZs(ii),'PhaseTolerance',PhaseTolerance,...
            'gui',gui,'save',updateSettings);
    end
end
%%
data_taking.public.scripts.temp.GHZ_4Q()
data_taking.public.scripts.temp.LCS_3Q()
