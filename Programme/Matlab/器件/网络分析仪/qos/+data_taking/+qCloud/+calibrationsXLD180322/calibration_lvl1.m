function calibration_lvl1(stopFlag,gui)

import sqc.util.getQSettings
import sqc.util.setQSettings
import data_taking.public.xmon.*


if nargin < 2
    gui = qes.util.hvar(false);
end
if nargin < 1
    stopFlag = qes.util.hvar(false);
end

iq2ProbNumSamples = 2e4;
correctf01DelayTime = 1e-6;
AENumPi = 31;
gAmpTuneRange = 0.03;
fineTune = false;

setQSettings('r_avg',2000);
logger = qes.util.log4qCloud.getLogger();

% qubitGroups = {{'q1','q3','q5','q7','q9','q11'},...
%  			   {'q2','q4','q6','q8','q10','q12'}};
% correctf01 = {[false,true,true,false,true,false],...
%             [true,true,true,true,true,true]};
        
qubitGroups = {{'q1','q3','q7','q11'},...
    {'q5','q9'},...
    {'q6','q12'},...
    {'q2','q4','q8','q10'}};
correctf01 = true;
        
for ii = 1:numel(qubitGroups)
    
    qs = qubitGroups{ii};

    tuneup.correctf01byPhase('qubits',qs,'delayTime',correctf01DelayTime,...
        'gui',gui.val,'save',true,'doCorrection',true,'logger',logger);
    qs = qubitGroups{ii};

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
%czQSets = {{{'q1','q2'};{'q1','q3','q5','q9'};{'q2','q4','q6','q8','q10','q12'}},...
%           {{'q3','q2'};{'q1','q3','q5','q9'};{'q2','q4','q6','q8','q10','q12'}},...
%           {{'q3','q4'};{'q1','q3','q5','q9'};{'q2','q4','q6','q8','q10','q12'}},...
%           {{'q5','q4'};{'q1','q3','q5','q9'};{'q2','q4','q6','q8','q10','q12'}},...
%           {{'q5','q6'};{'q1','q3','q5','q9'};{'q2','q4','q6','q8','q10','q12'}},...
%           {{'q7','q6'};{'q1','q3','q5','q9','q7'};{'q2','q4','q6','q8','q10','q12'}},...
%           {{'q7','q8'};{'q1','q3','q5','q9','q7'};{'q2','q4','q6','q8','q10','q12'}},...
%           {{'q9','q8'};{'q1','q3','q5','q9'};{'q2','q4','q6','q8','q10','q12'}},...
%           {{'q9','q10'};{'q1','q3','q5','q9'};{'q2','q4','q6','q8','q10','q12'}},...
%           {{'q11','q10'};{'q1','q3','q5','q9','q11'};{'q2','q4','q6','q8','q10','q12'}},...
%		   {{'q11','q12'};{'q1','q3','q5','q9','q11'};{'q2','q4','q6','q8','q10','q12'}},...
%          };
% numCZs = [7,7,7,7,7,7,7,7,7,7,7];

czQSets = {{{'q1','q2'};{'q1','q3','q5','q9'};{'q2','q4','q6','q8','q10','q12'}},...
           {{'q3','q2'};{'q1','q3','q5','q9'};{'q2','q4','q6','q8','q10','q12'}},...
           {{'q3','q4'};{'q1','q3','q5','q9'};{'q2','q4','q6','q8','q10','q12'}},...
           {{'q5','q4'};{'q1','q3','q5','q9'};{'q2','q4','q6','q8','q10','q12'}},...
           {{'q5','q6'};{'q1','q3','q5','q9'};{'q2','q4','q6','q8','q10','q12'}},...
           {{'q7','q6'};{'q1','q3','q5','q9','q7'};{'q2','q4','q6','q8','q10','q12'}},...
           {{'q7','q8'};{'q1','q3','q5','q9','q7'};{'q2','q4','q6','q8','q10','q12'}},...
           {{'q9','q8'};{'q1','q3','q5','q9'};{'q2','q4','q6','q8','q10','q12'}},...
           {{'q9','q10'};{'q1','q3','q5','q9'};{'q2','q4','q6','q8','q10','q12'}},...
           {{'q11','q10'};{'q1','q3','q5','q9','q11'};{'q2','q4','q6','q8','q10','q12'}},...
		   {{'q11','q12'};{'q1','q3','q5','q9','q11'};{'q2','q4','q6','q8','q10','q12'}},...
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