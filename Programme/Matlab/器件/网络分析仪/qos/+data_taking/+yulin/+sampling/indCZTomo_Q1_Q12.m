function indCZTomo_Q1_Q12()
% data_taking.yulin.sampling.indCZTomo_Q1_Q12()

import sqc.util.getQSettings
datafile = ['E:\data\20180216_12bit\sampling\CZTomo\','CZTomo_Q1_Q12_',datestr(now,'yymmddTHHMMSS'),'.mat'];
notes = '';

opQs = {'q1','q2','q3','q4','q5','q6','q7','q8','q9','q10','q11','q12'};
stats = 5000;

startTime = now;

circuitLayer1 = {'','CZ','CZ','','CZ','CZ','','CZ','CZ','','CZ','CZ'};

measureQs = {'q2','q3'};
measureType = 'Mptomo';
data_taking.qCloud.calibrationsXLD180322.calibration_lvl3();
[Ptomo23, ~, ~, ~] = sqc.util.runCircuit(circuitLayer1,opQs,measureQs,stats,measureType, false);
measureQs = {'q1'};
measureType = 'Mphase';
circuitPhase = {'Y2m','','','','','','','','','','',''};
[Phase11, ~, ~, ~] = sqc.util.runCircuit([circuitPhase;circuitLayer1],opQs,measureQs,stats,measureType, false);
measureQs = {'q4'};
measureType = 'Mphase';
circuitPhase = {'','','','Y2m','','','','','','','',''};
[Phase14, ~, ~, ~] = sqc.util.runCircuit([circuitPhase;circuitLayer1],opQs,measureQs,stats,measureType, false);
measureQs = {'q5','q6'};
measureType = 'Mptomo';
data_taking.qCloud.calibrationsXLD180322.calibration_lvl3();
[Ptomo56, ~, ~, ~] = sqc.util.runCircuit(circuitLayer1,opQs,measureQs,stats,measureType, false);
measureQs = {'q7'};
measureType = 'Mphase';
circuitPhase = {'','','','','','','Y2m','','','','',''};
[Phase17, ~, ~, ~] = sqc.util.runCircuit([circuitPhase;circuitLayer1],opQs,measureQs,stats,measureType, false);
measureQs = {'q8','q9'};
measureType = 'Mptomo';
data_taking.qCloud.calibrationsXLD180322.calibration_lvl3();
[Ptomo89, ~, ~, ~] = sqc.util.runCircuit(circuitLayer1,opQs,measureQs,stats,measureType, false);
measureQs = {'q10'};
measureType = 'Mphase';
circuitPhase = {'','','','','','','','','','Y2m','',''};
[Phase110, ~, ~, ~] = sqc.util.runCircuit([circuitPhase;circuitLayer1],opQs,measureQs,stats,measureType, false);
measureQs = {'q11','q12'};
measureType = 'Mptomo';
data_taking.qCloud.calibrationsXLD180322.calibration_lvl3();
[Ptomo1112, ~, ~, ~] = sqc.util.runCircuit(circuitLayer1,opQs,measureQs,stats,measureType, false);

circuitLayer2 = {'CZ','CZ','','CZ','CZ','','CZ','CZ','','CZ','CZ',''};

measureQs = {'q1','q2'};
measureType = 'Mptomo';
data_taking.qCloud.calibrationsXLD180322.calibration_lvl3();
[Ptomo12, ~, ~, ~] = sqc.util.runCircuit(circuitLayer2,opQs,measureQs,stats,measureType, false);
measureQs = {'q3'};
measureType = 'Mphase';
circuitPhase = {'','','Y2m','','','','','','','','',''};
[Phase23, ~, ~, ~] = sqc.util.runCircuit([circuitPhase;circuitLayer2],opQs,measureQs,stats,measureType, false);
measureQs = {'q4','q5'};
measureType = 'Mptomo';
data_taking.qCloud.calibrationsXLD180322.calibration_lvl3();
[Ptomo45, ~, ~, ~] = sqc.util.runCircuit(circuitLayer2,opQs,measureQs,stats,measureType, false);
measureQs = {'q6'};
measureType = 'Mphase';
circuitPhase = {'','','','','','Y2m','','','','','',''};
[Phase26, ~, ~, ~] = sqc.util.runCircuit([circuitPhase;circuitLayer2],opQs,measureQs,stats,measureType, false);
measureQs = {'q7','q8'};
measureType = 'Mptomo';
data_taking.qCloud.calibrationsXLD180322.calibration_lvl3();
[Ptomo78, ~, ~, ~] = sqc.util.runCircuit(circuitLayer2,opQs,measureQs,stats,measureType, false);
measureQs = {'q9'};
measureType = 'Mphase';
circuitPhase = {'','','','','','','','','Y2m','','',''};
[Phase29, ~, ~, ~] = sqc.util.runCircuit([circuitPhase; circuitLayer2],opQs,measureQs,stats,measureType, false);
measureQs = {'q10','q11'};
measureType = 'Mptomo';
data_taking.qCloud.calibrationsXLD180322.calibration_lvl3();
[Ptomo1011, ~, ~, ~] = sqc.util.runCircuit(circuitLayer2,opQs,measureQs,stats,measureType, false);
measureQs = {'q12'};
measureType = 'Mphase';
circuitPhase = {'','','','','','','','','','','','Y2m'};
[Phase212, ~, ~, ~] = sqc.util.runCircuit([circuitPhase;circuitLayer2],opQs,measureQs,stats,measureType, false);

circuitLayer3 = {'','','CZ','CZ','','CZ','CZ','','CZ','CZ','',''};

measureQs = {'q1'};
measureType = 'Mphase';
circuitPhase = {'Y2m','','','','','','','','','','',''};
[Phase31, ~, ~, ~] = sqc.util.runCircuit([circuitPhase; circuitLayer3],opQs,measureQs,stats,measureType, false);
measureQs = {'q2'};
measureType = 'Mphase';
circuitPhase = {'','Y2m','','','','','','','','','',''};
[Phase32, ~, ~, ~] = sqc.util.runCircuit([circuitPhase; circuitLayer3],opQs,measureQs,stats,measureType, false);
measureQs = {'q3','q4'};
measureType = 'Mptomo';
data_taking.qCloud.calibrationsXLD180322.calibration_lvl3();
[Ptomo34, ~, ~, ~] = sqc.util.runCircuit(circuitLayer3,opQs,measureQs,stats,measureType, false);
measureQs = {'q5'};
measureType = 'Mphase';
circuitPhase = {'','','','','Y2m','','','','','','',''};
[Phase35, ~, ~, ~] = sqc.util.runCircuit([circuitPhase;circuitLayer3],opQs,measureQs,stats,measureType, false);
measureQs = {'q6','q7'};
measureType = 'Mptomo';
data_taking.qCloud.calibrationsXLD180322.calibration_lvl3();
[Ptomo67, ~, ~, ~] = sqc.util.runCircuit(circuitLayer3,opQs,measureQs,stats,measureType, false);
measureQs = {'q8'};
measureType = 'Mphase';
circuitPhase = {'','','','','','','','Y2m','','','',''};
[Phase38, ~, ~, ~] = sqc.util.runCircuit([circuitPhase;circuitLayer3],opQs,measureQs,stats,measureType, false);
measureQs = {'q9','q10'};
measureType = 'Mptomo';
data_taking.qCloud.calibrationsXLD180322.calibration_lvl3();
[Ptomo910, ~, ~, ~] = sqc.util.runCircuit(circuitLayer3,opQs,measureQs,stats,measureType, false);
measureQs = {'q11'};
measureType = 'Mphase';
circuitPhase = {'','','','','','','','','','','Y2m',''};
[Phase311, ~, ~, ~] = sqc.util.runCircuit([circuitPhase;circuitLayer3],opQs,measureQs,stats,measureType, false);
measureQs = {'q12'};
measureType = 'Mphase';
circuitPhase = {'','','','','','','','','','','','Y2m'};
[Phase312, ~, ~, ~] = sqc.util.runCircuit([circuitPhase; circuitLayer3],opQs,measureQs,stats,measureType, false);

finishTime = now;

save(datafile,...
    'startTime','finishTime',...
'circuitLayer1','circuitLayer2','circuitLayer3',...
'opQs','stats',...
'Ptomo23','Ptomo56','Ptomo89','Ptomo1112',...
'Phase11','Phase14','Phase17','Phase110',...
'Ptomo12','Ptomo45','Ptomo78','Ptomo1011',...
'Phase23','Phase26','Phase29','Phase212',...
'Ptomo34','Ptomo67','Ptomo910',...
'Phase31','Phase32','Phase35','Phase38','Phase311','Phase312');

end
