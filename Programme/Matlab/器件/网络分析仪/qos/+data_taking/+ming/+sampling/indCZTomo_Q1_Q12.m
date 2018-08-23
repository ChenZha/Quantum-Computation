function [Phase11,Phase14,Phase17,Phase110,Phase23,Phase26,Phase29,Phase212,Phase31,Phase32,Phase35,Phase38,Phase311,Phase312,Ptomo12,Ptomo23,Ptomo34,Ptomo45,Ptomo56,Ptomo67,Ptomo78,Ptomo89,Ptomo910,Ptomo1011,Ptomo1112]=indCZTomo_Q1_Q12(layer)
% data_taking.ming.sampling.indCZTomo_Q1_Q12()
if nargin<1
    layer=[1 2 3];
end

import sqc.util.getQSettings
datafile = ['E:\data\20180216_12bit\sampling\20180502\','CZTomo_Q1_Q12_',datestr(now,'yymmddTHHMMSS'),'.mat'];
notes = '';

opQs = {'q1','q2','q3','q4','q5','q6','q7','q8','q9','q10','q11','q12'};
qubits=opQs;
stats = 5000;

startTime = now;

circuitPhase1 = {'Y2p','','','','','','','','','','',''};
circuitPhase2 = {'','Y2p','','','','','','','','','',''};
circuitPhase3 = {'','','Y2p','','','','','','','','',''};
circuitPhase4 = {'','','','Y2p','','','','','','','',''};
circuitPhase5 = {'','','','','Y2p','','','','','','',''};
circuitPhase6 = {'','','','','','Y2p','','','','','',''};
circuitPhase7 = {'','','','','','','Y2p','','','','',''};
circuitPhase8 = {'','','','','','','','Y2p','','','',''};
circuitPhase9 = {'','','','','','','','','Y2p','','',''};
circuitPhase10 = {'','','','','','','','','','Y2p','',''};
circuitPhase11 = {'','','','','','','','','','','Y2p',''};
circuitPhase12 = {'','','','','','','','','','','','Y2p'};

circuitLayer1 = {'','CZ','CZ','','CZ','CZ','','CZ','CZ','','CZ','CZ'};

if ismember(1,layer)
    measureQs = {'q2','q3'};
    measureType = 'Mptomo';
    data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0)
    circuitPhase = {'Y2p','','','Y2p','Y2p','Y2p','Y2p','Y2p','Y2p','Y2p','Y2p','Y2p'};
    [Ptomo23, ~, ~, ~] = sqc.util.runCircuit([circuitPhase;circuitLayer1],opQs,measureQs,stats,measureType, false);
    measureQs = {'q1'};
    measureType = 'Mphase';
    data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0)
    [Phase11, ~, ~, ~] = sqc.util.runCircuit([circuitPhase1;circuitLayer1],opQs,measureQs,stats,measureType, false);
    measureQs = {'q4'};
    measureType = 'Mphase';
    [Phase14, ~, ~, ~] = sqc.util.runCircuit([circuitPhase4;circuitLayer1],opQs,measureQs,stats,measureType, false);
    
    measureQs = {'q5','q6'};
    measureType = 'Mptomo';
    data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0)
    circuitPhase = {'Y2p','Y2p','Y2p','Y2p','','','Y2p','Y2p','Y2p','Y2p','Y2p','Y2p'};
    [Ptomo56, ~, ~, ~] = sqc.util.runCircuit([circuitPhase;circuitLayer1],opQs,measureQs,stats,measureType, false);
    measureQs = {'q7'};
    measureType = 'Mphase';
    data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0)
    [Phase17, ~, ~, ~] = sqc.util.runCircuit([circuitPhase7;circuitLayer1],opQs,measureQs,stats,measureType, false);
    
    measureQs = {'q8','q9'};
    measureType = 'Mptomo';
    data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0)
    circuitPhase = {'Y2p','Y2p','Y2p','Y2p','Y2p','Y2p','Y2p','','','Y2p','Y2p','Y2p'};
    [Ptomo89, ~, ~, ~] = sqc.util.runCircuit([circuitPhase;circuitLayer1],opQs,measureQs,stats,measureType, false);
    measureQs = {'q10'};
    measureType = 'Mphase';
    data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0)
    [Phase110, ~, ~, ~] = sqc.util.runCircuit([circuitPhase10;circuitLayer1],opQs,measureQs,stats,measureType, false);
    
    measureQs = {'q11','q12'};
    measureType = 'Mptomo';
    data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0)
    circuitPhase = {'Y2p','Y2p','Y2p','Y2p','Y2p','Y2p','Y2p','Y2p','Y2p','Y2p','',''};
    [Ptomo1112, ~, ~, ~] = sqc.util.runCircuit([circuitPhase;circuitLayer1],opQs,measureQs,stats,measureType, false);
    
    disp('Tomo Layer 1 Done!')
else
    Ptomo23=[];
    Phase11=[];
    Phase14=[];
    Ptomo56=[];
    Phase17=[];
    Ptomo89=[];
    Phase110=[];
    Ptomo1112=[];
end

circuitLayer2 = {'CZ','CZ','','CZ','CZ','','CZ','CZ','','CZ','CZ',''};

if ismember(2,layer)
    measureQs = {'q1','q2'};
    measureType = 'Mptomo';
    data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0)
    circuitPhase = {'','','','Y2p','Y2p','Y2p','Y2p','Y2p','Y2p','Y2p','Y2p','Y2p'};
    [Ptomo12, ~, ~, ~] = sqc.util.runCircuit([circuitPhase;circuitLayer1;circuitLayer2],opQs,measureQs,stats,measureType, false);
    measureQs = {'q3'};
    measureType = 'Mphase';
    data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0)
    [Phase23, ~, ~, ~] = sqc.util.runCircuit([circuitPhase3;circuitLayer1;circuitLayer2],opQs,measureQs,stats,measureType, false);
    
    measureQs = {'q4','q5'};
    measureType = 'Mptomo';
    data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0)
    circuitPhase = {'Y2p','Y2p','Y2p','','','','Y2p','Y2p','Y2p','Y2p','Y2p','Y2p'};
    [Ptomo45, ~, ~, ~] = sqc.util.runCircuit([circuitPhase;circuitLayer1;circuitLayer2],opQs,measureQs,stats,measureType, false);
    measureQs = {'q6'};
    measureType = 'Mphase';
    data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0)
    [Phase26, ~, ~, ~] = sqc.util.runCircuit([circuitPhase6;circuitLayer1;circuitLayer2],opQs,measureQs,stats,measureType, false);
    
    measureQs = {'q7','q8'};
    measureType = 'Mptomo';
    data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0)
    circuitPhase = {'Y2p','Y2p','Y2p','Y2p','Y2p','Y2p','','','','Y2p','Y2p','Y2p'};
    [Ptomo78, ~, ~, ~] = sqc.util.runCircuit([circuitPhase;circuitLayer1;circuitLayer2],opQs,measureQs,stats,measureType, false);
    measureQs = {'q9'};
    measureType = 'Mphase';
    data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0)
    [Phase29, ~, ~, ~] = sqc.util.runCircuit([circuitPhase9;circuitLayer1; circuitLayer2],opQs,measureQs,stats,measureType, false);
    
    measureQs = {'q10','q11'};
    measureType = 'Mptomo';
    data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0)
    circuitPhase = {'Y2p','Y2p','Y2p','Y2p','Y2p','Y2p','Y2p','Y2p','Y2p','','',''};
    [Ptomo1011, ~, ~, ~] = sqc.util.runCircuit([circuitPhase;circuitLayer1;circuitLayer2],opQs,measureQs,stats,measureType, false);
    measureQs = {'q12'};
    measureType = 'Mphase';
    data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0)
    [Phase212, ~, ~, ~] = sqc.util.runCircuit([circuitPhase12;circuitLayer1;circuitLayer2],opQs,measureQs,stats,measureType, false);
    
    disp('Tomo Layer 2 Done!')
else
    Ptomo12=[];
    Phase23=[];
    Ptomo45=[];
    Phase26=[];
    Ptomo78=[];
    Phase29=[];
    Ptomo1011=[];
    Phase212=[];
end

circuitLayer3 = {'','','CZ','CZ','','CZ','CZ','','CZ','CZ','',''};

if ismember(3,layer)
    measureQs = {'q1'};
    measureType = 'Mphase';
    [Phase31, ~, ~, ~] = sqc.util.runCircuit([circuitPhase1;circuitLayer1;circuitLayer2; circuitLayer3],opQs,measureQs,stats,measureType, false);
    measureQs = {'q2'};
    measureType = 'Mphase';
    [Phase32, ~, ~, ~] = sqc.util.runCircuit([circuitPhase2;circuitLayer1;circuitLayer2; circuitLayer3],opQs,measureQs,stats,measureType, false);
    
    measureQs = {'q3','q4'};
    measureType = 'Mptomo';
    data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0)
    circuitPhase = {'','','','','','','Y2p','Y2p','Y2p','Y2p','Y2p','Y2p'};
    [Ptomo34, ~, ~, ~] = sqc.util.runCircuit([circuitPhase;circuitLayer1;circuitLayer2; circuitLayer3],opQs,measureQs,stats,measureType, false);
    measureQs = {'q5'};
    measureType = 'Mphase';
    data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0)
    [Phase35, ~, ~, ~] = sqc.util.runCircuit([circuitPhase5;circuitLayer1;circuitLayer2;circuitLayer3],opQs,measureQs,stats,measureType, false);
    
    measureQs = {'q6','q7'};
    measureType = 'Mptomo';
    data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0)
    circuitPhase = {'Y2p','Y2p','Y2p','','','','','','','Y2p','Y2p','Y2p'};
    [Ptomo67, ~, ~, ~] = sqc.util.runCircuit([circuitPhase;circuitLayer1;circuitLayer2;circuitLayer3],opQs,measureQs,stats,measureType, false);
    measureQs = {'q8'};
    measureType = 'Mphase';
    data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0)
    [Phase38, ~, ~, ~] = sqc.util.runCircuit([circuitPhase8;circuitLayer1;circuitLayer2;circuitLayer3],opQs,measureQs,stats,measureType, false);
    
    measureQs = {'q9','q10'};
    measureType = 'Mptomo';
    data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0)
    circuitPhase = {'Y2p','Y2p','Y2p','Y2p','Y2p','Y2p','','','','','',''};
    [Ptomo910, ~, ~, ~] = sqc.util.runCircuit([circuitPhase;circuitLayer1;circuitLayer2;circuitLayer3],opQs,measureQs,stats,measureType, false);
    measureQs = {'q11'};
    measureType = 'Mphase';
    data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0)
    [Phase311, ~, ~, ~] = sqc.util.runCircuit([circuitPhase11;circuitLayer1;circuitLayer2;circuitLayer3],opQs,measureQs,stats,measureType, false);
    measureQs = {'q12'};
    measureType = 'Mphase';
    [Phase312, ~, ~, ~] = sqc.util.runCircuit([circuitPhase12;circuitLayer1;circuitLayer2; circuitLayer3],opQs,measureQs,stats,measureType, false);
    
    disp('Tomo Layer 3 Done!')
else
    Phase31=[];
    Phase32=[];
    Ptomo34=[];
    Phase35=[];
    Ptomo67=[];
    Phase38=[];
    Ptomo910=[];
    Phase311=[];
    Phase312=[];
end


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
