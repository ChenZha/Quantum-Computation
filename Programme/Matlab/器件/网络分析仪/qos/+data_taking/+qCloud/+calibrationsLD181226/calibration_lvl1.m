function calibration_lvl1(stopFlag,gui)

import sqc.util.getQSettings
import sqc.util.setQSettings
import data_taking.public.xmon.*

iq2ProbNumSamples = 1e4;
correctf01DelayTime = 0.6e-6;
AENumPi = 25;
gAmpTuneRange = 0.03;
fineTune = false;

setQSettings('r_avg',2000);
logger = qes.util.log4qCloud.getLogger();

%% single qubit gates
qubitGroups = {{'q1','q3','q6','q10'},...
               {'q7','q11','q4'},...
               {'q5','q8'},{'q9','q2'}};
correctf01 = {[false,true,true,true],...
               [false,true,true],...
               [true,true],[false,true]};
for ii = 1:numel(qubitGroups)
    tuneup.iq2prob_01('qubits',qubitGroups{ii},'numSamples',iq2ProbNumSamples,'fineTune',fineTune,'gui',gui.val,'save',true,'logger',logger);
    
    qs = qubitGroups{ii};
    if ii == 2 || ii == 4 % do not correct max f01 qubits: q7, q9
        qs = qs(2:end);
    end

    tuneup.correctf01byPhase('qubits',qs,'delayTime',correctf01DelayTime,'gui',gui.val,'save',true,'doCorrection',correctf01{ii},'logger',logger);
    qs = qubitGroups{ii};
 
%     if ii == 4 % do not correct q9
%         qs = qs(2:end);
%     end

    if ~gui.val
        drawnow;pause(0.1);
    end
    if stopFlag.val
        tuneup.iq2prob_01('qubits',qubitGroups{ii},'numSamples',iq2ProbNumSamples,'fineTune',fineTune,'gui',gui.val,'save',true,'logger',logger);
        stopFlag.val = false;
        return;
    end
    tuneup.xyGateAmpTuner_parallel('qubits',qs,'gateTyp','X/2','AENumPi',AENumPi,'tuneRange',gAmpTuneRange,'gui',gui.val,'save',true,'logger',logger);
%     tuneup.xyGateAmpTuner_parallel('qubits',qubitGroups{ii},'gateTyp','X','AENumPi',AENumPi,'tuneRange',gAmpTuneRange,'gui',gui,'save',true,'logger',logger);
    tuneup.iq2prob_01('qubits',qubitGroups{ii},'numSamples',iq2ProbNumSamples,'fineTune',fineTune,'gui',gui.val,'save',true,'logger',logger);
    if ~gui.val
        drawnow;pause(0.1);
    end
    if stopFlag.val
        stopFlag.val = false;
        return;
    end
end

%% cz
czQSets = {{{'q1','q2'};{'q1','q3','q5','q11'};{'q2','q4','q6','q8','q10'}},...
           {{'q3','q2'};{'q1','q3','q5','q11'};{'q2','q4','q6','q8','q10'}},...
           {{'q3','q4'};{'q1','q3','q5','q11'};{'q2','q4','q6','q8','q10'}},...
           {{'q5','q4'};{'q1','q3','q5','q11'};{'q2','q4','q6','q8','q10'}},...
           {{'q5','q6'};{'q1','q3','q5','q11'};{'q2','q4','q6','q8','q10'}},...
           {{'q7','q6'};{'q1','q3','q5','q7','q11'};{'q2','q4','q6','q8','q10'}},...
           {{'q7','q8'};{'q1','q3','q5','q7','q11'};{'q2','q4','q6','q8','q10'}},...
           {{'q9','q8'};{'q1','q3','q5','q9','q11'};{'q2','q4','q6','q8','q10'}},...
           {{'q9','q10'};{'q1','q3','q5','q9','q11'};{'q2','q4','q6','q8','q10'}},...
           {{'q11','q10'};{'q1','q3','q5','q11'};{'q2','q4','q6','q8','q10'}},...
          };
numCZs = [7,7,7,7,7,7,7,7,7,7,7];
PhaseTolerance = 0.03;
     
for ii = 1:numel(czQSets)
    tuneup.czAmplitude('controlQ',czQSets{ii}{1}{1},'targetQ',czQSets{ii}{1}{2},...
        'gui',gui.val,'save',true,'logger',logger,'repeatIfOutOfBoundButClose',true);
    if ~gui.val
        drawnow;pause(0.1);
    end
    if stopFlag.val
        stopFlag.val = false;
        return;
    end
    for jj = 2:numel(czQSets{ii})
        tuneup.czDynamicPhase_parallel('controlQ',czQSets{ii}{1}{1},...
            'targetQ',czQSets{ii}{1}{2},'dynamicPhaseQs',czQSets{ii}{jj},...
            'numCZs',numCZs(ii),'PhaseTolerance',PhaseTolerance,...
            'gui',gui.val,'save',true,'logger',logger);
        if ~gui.val
            drawnow;pause(0.1);
        end
        if stopFlag.val
            stopFlag.val = false;
        return;
    end
    end
end

end