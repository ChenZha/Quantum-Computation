function calibration_lvl2(stopFlag,gui)

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
fineTune = false;

AENumPi = 31;
gAmpTuneRange = 0.03;

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
        
for ii = 1:numel(qubitGroups)
    qs = qubitGroups{ii};
    tuneup.correctf01byPhase('qubits',qs,'delayTime',correctf01DelayTime,...
        'gui',gui.val,'save',true,'doCorrection',true,'logger',logger);
    tuneup.iq2prob_01('qubits',qs,'numSamples',iq2ProbNumSamples,...
        'fineTune',fineTune,'gui',gui.val,'save',true,'logger',logger);
    if ~gui.val
        drawnow;pause(0.1);
    end

    if stopFlag.val
        stopFlag.val = false;
        return;
    end
    tuneup.xyGateAmpTuner_parallel('qubits',qubitGroups{ii},'gateTyp','X/2','AENumPi',AENumPi,...
        'tuneRange',gAmpTuneRange,'gui',gui.val,'save',true,'logger',logger);
    tuneup.iq2prob_01('qubits',qubitGroups{ii},'numSamples',iq2ProbNumSamples,...
        'fineTune',fineTune,'gui',gui.val,'save',true,'logger',logger);
    if ~gui.val
        drawnow;pause(0.1);
    end
    if stopFlag.val
        stopFlag.val = false;
        return;
    end
end

end