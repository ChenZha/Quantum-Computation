function calibration_lvl3(stopFlag,gui)

import sqc.util.getQSettings
import sqc.util.setQSettings
import data_taking.public.xmon.*

iq2ProbNumSamples = 1e4;
correctf01DelayTime = 0.6e-6;
fineTune = false;

setQSettings('r_avg',2000);
logger = qes.util.log4qCloud.getLogger();

%% single qubit gates
% qubitGroups = {{'q1','q3','q5','q7','q9','q11'},...
%                {'q2','q4','q6','q8','q10'}};
qubitGroups = {{'q1','q3','q6','q10'},...
               {'q7','q11','q4'},...
               {'q5','q8'},{'q9','q2'}};
correctf01 = {[false,true,true,true],...
               [false,true,true],...
               [true,true],[false,true]};
for ii = 1:numel(qubitGroups) 
    qs = qubitGroups{ii};
    if ii == 2 || ii == 4 % do not correct max f01 qubits: q7, q9
        qs = qs(2:end);
    end
    tuneup.correctf01byPhase('qubits',qs,'delayTime',correctf01DelayTime,...
        'gui',gui.val,'save',true,'doCorrection',correctf01{ii},'logger',logger);
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