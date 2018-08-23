function [Phase,Ptomo,datafile]=indCZTomo_Q1_Q12_incircuit(layer)
% data_taking.ming.sampling.indCZTomo_Q1_Q12()
if nargin<1
    layer=[1 2];
end

import sqc.util.getQSettings
path=['E:\data\20180622_12bit\sampling\' datestr(now,'yymmdd') '\Tomo'];
if ~exist(path)
    mkdir(path)
end

datafile = [path,'\CZTomo_Q1_Q12_',datestr(now,'yymmddTHHMMSS'),'.mat'];
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
circuitLayer2 = {'CZ','CZ','','CZ','CZ','','CZ','CZ','','CZ','CZ',''};
circuitLayer3 = {'','','CZ','CZ','','CZ','CZ','','CZ','CZ','',''};
circuitLayer4 = {'I(40)','I(40)','I(40)','I(40)','I(40)','I(40)','I(40)','I(40)','I(40)','I(40)','I(40)','I(40)'};

    Ptomo12=[];
    Ptomo23=[];
    Ptomo34=[];
    Ptomo45=[];
    Ptomo56=[];
    Ptomo67=[];
    Ptomo78=[];
    Ptomo89=[];
    Ptomo910=[];
    Ptomo1011=[];
    Ptomo1112=[];
    
if ismember(1,layer)
    measureQs = {'q1','q2'};
    measureType = 'Mptomo';
%     check2Qreadout(measureQs,qubits)
    circuitPhase = {'','','','','Y2p','Y2p','Y2p','Y2p','Y2p','Y2p','Y2p','Y2p'};
    [Ptomo12, ~, ~, ~] = sqc.util.runCircuit([circuitPhase;circuitLayer1;circuitLayer2;circuitLayer3;circuitLayer4],opQs,measureQs,stats,measureType, false);
    disp('Tomo1 Done!')
    
    measureQs = {'q2','q3'};
    measureType = 'Mptomo';
    check2Qreadout(measureQs,qubits)
    circuitPhase = {'','','','','','Y2p','Y2p','Y2p','Y2p','Y2p','Y2p','Y2p'};
    [Ptomo23, ~, ~, ~] = sqc.util.runCircuit([circuitPhase;circuitLayer1;circuitLayer2;circuitLayer3;circuitLayer4],opQs,measureQs,stats,measureType, false);
    disp('Tomo2 Done!')
    
    measureQs = {'q3','q4'};
    measureType = 'Mptomo';
    check2Qreadout(measureQs,qubits)
    circuitPhase = {'','','','','','','Y2p','Y2p','Y2p','Y2p','Y2p','Y2p'};
    [Ptomo34, ~, ~, ~] = sqc.util.runCircuit([circuitPhase;circuitLayer1;circuitLayer2;circuitLayer3;circuitLayer4],opQs,measureQs,stats,measureType, false);
    disp('Tomo3 Done!')
    
    measureQs = {'q4','q5'};
    measureType = 'Mptomo';
    check2Qreadout(measureQs,qubits)
    circuitPhase = {'Y2p','','','','','','','Y2p','Y2p','Y2p','Y2p','Y2p'};
    [Ptomo45, ~, ~, ~] = sqc.util.runCircuit([circuitPhase;circuitLayer1;circuitLayer2;circuitLayer3;circuitLayer4],opQs,measureQs,stats,measureType, false);
    disp('Tomo4 Done!')
    
    measureQs = {'q5','q6'};
    measureType = 'Mptomo';
    check2Qreadout(measureQs,qubits)
    circuitPhase = {'Y2p','Y2p','','','','','','','Y2p','Y2p','Y2p','Y2p'};
    [Ptomo56, ~, ~, ~] = sqc.util.runCircuit([circuitPhase;circuitLayer1;circuitLayer2;circuitLayer3;circuitLayer4],opQs,measureQs,stats,measureType, false);
    disp('Tomo5 Done!')
    
    measureQs = {'q6','q7'};
    measureType = 'Mptomo';
    check2Qreadout(measureQs,qubits)
    circuitPhase = {'Y2p','Y2p','Y2p','','','','','','','Y2p','Y2p','Y2p'};
    [Ptomo67, ~, ~, ~] = sqc.util.runCircuit([circuitPhase;circuitLayer1;circuitLayer2;circuitLayer3;circuitLayer4],opQs,measureQs,stats,measureType, false);
    disp('Tomo6 Done!')
    
    measureQs = {'q7','q8'};
    measureType = 'Mptomo';
    check2Qreadout(measureQs,qubits)
    circuitPhase = {'Y2p','Y2p','Y2p','Y2p','','','','','','','Y2p','Y2p'};
    [Ptomo78, ~, ~, ~] = sqc.util.runCircuit([circuitPhase;circuitLayer1;circuitLayer2;circuitLayer3;circuitLayer4],opQs,measureQs,stats,measureType, false);
    disp('Tomo7 Done!')
    
    measureQs = {'q8','q9'};
    measureType = 'Mptomo';
    check2Qreadout(measureQs,qubits)
    circuitPhase = {'Y2p','Y2p','Y2p','Y2p','Y2p','','','','','','','Y2p'};
    [Ptomo89, ~, ~, ~] = sqc.util.runCircuit([circuitPhase;circuitLayer1;circuitLayer2;circuitLayer3;circuitLayer4],opQs,measureQs,stats,measureType, false);
    disp('Tomo8 Done!')
    
    measureQs = {'q9','q10'};
    measureType = 'Mptomo';
    check2Qreadout(measureQs,qubits)
    circuitPhase = {'Y2p','Y2p','Y2p','Y2p','Y2p','Y2p','','','','','',''};
    [Ptomo910, ~, ~, ~] = sqc.util.runCircuit([circuitPhase;circuitLayer1;circuitLayer2;circuitLayer3;circuitLayer4],opQs,measureQs,stats,measureType, false);
    disp('Tomo9 Done!')
    
    measureQs = {'q10','q11'};
    measureType = 'Mptomo';
    check2Qreadout(measureQs,qubits)
    circuitPhase = {'Y2p','Y2p','Y2p','Y2p','Y2p','Y2p','Y2p','','','','',''};
    [Ptomo1011, ~, ~, ~] = sqc.util.runCircuit([circuitPhase;circuitLayer1;circuitLayer2;circuitLayer3;circuitLayer4],opQs,measureQs,stats,measureType, false);
    disp('Tomo10 Done!')
    
    measureQs = {'q11','q12'};
    measureType = 'Mptomo';
    check2Qreadout(measureQs,qubits)
    circuitPhase = {'Y2p','Y2p','Y2p','Y2p','Y2p','Y2p','Y2p','Y2p','','','',''};
    [Ptomo1112, ~, ~, ~] = sqc.util.runCircuit([circuitPhase;circuitLayer1;circuitLayer2;circuitLayer3;circuitLayer4],opQs,measureQs,stats,measureType, false);
    disp('Tomo11 Done!')

end

    Phase1=[];
    Phase2=[];
    Phase3=[];
    Phase4=[];
    Phase5=[];
    Phase6=[];
    Phase7=[];
    Phase8=[];
    Phase9=[];
    Phase10=[];
    Phase11=[];
    Phase12=[];

if ismember(2,layer)
    
    data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0)
    
    measureQs = {'q1'};
    measureType = 'Mphase';
    [Phase1, ~, ~, ~] = sqc.util.runCircuit([circuitPhase1;circuitLayer1;circuitLayer2;circuitLayer3;circuitLayer4],opQs,measureQs,stats,measureType, false);
    
    measureQs = {'q2'};
    measureType = 'Mphase';
    [Phase2, ~, ~, ~] = sqc.util.runCircuit([circuitPhase2;circuitLayer1;circuitLayer2;circuitLayer3;circuitLayer4],opQs,measureQs,stats,measureType, false);
    
    measureQs = {'q3'};
    measureType = 'Mphase';
    [Phase3, ~, ~, ~] = sqc.util.runCircuit([circuitPhase3;circuitLayer1;circuitLayer2;circuitLayer3;circuitLayer4],opQs,measureQs,stats,measureType, false);
    
    measureQs = {'q4'};
    measureType = 'Mphase';
    [Phase4, ~, ~, ~] = sqc.util.runCircuit([circuitPhase4;circuitLayer1;circuitLayer2;circuitLayer3;circuitLayer4],opQs,measureQs,stats,measureType, false);
    
    measureQs = {'q5'};
    measureType = 'Mphase';
    [Phase5, ~, ~, ~] = sqc.util.runCircuit([circuitPhase5;circuitLayer1;circuitLayer2;circuitLayer3;circuitLayer4],opQs,measureQs,stats,measureType, false);
    
    measureQs = {'q6'};
    measureType = 'Mphase';
    [Phase6, ~, ~, ~] = sqc.util.runCircuit([circuitPhase6;circuitLayer1;circuitLayer2;circuitLayer3;circuitLayer4],opQs,measureQs,stats,measureType, false);
    
    measureQs = {'q7'};
    measureType = 'Mphase';
    [Phase7, ~, ~, ~] = sqc.util.runCircuit([circuitPhase7;circuitLayer1;circuitLayer2;circuitLayer3;circuitLayer4],opQs,measureQs,stats,measureType, false);
    
    measureQs = {'q8'};
    measureType = 'Mphase';
    [Phase8, ~, ~, ~] = sqc.util.runCircuit([circuitPhase8;circuitLayer1;circuitLayer2;circuitLayer3;circuitLayer4],opQs,measureQs,stats,measureType, false);
    
    measureQs = {'q9'};
    measureType = 'Mphase';
    [Phase9, ~, ~, ~] = sqc.util.runCircuit([circuitPhase9;circuitLayer1;circuitLayer2;circuitLayer3;circuitLayer4],opQs,measureQs,stats,measureType, false);
    
    measureQs = {'q10'};
    measureType = 'Mphase';
    [Phase10, ~, ~, ~] = sqc.util.runCircuit([circuitPhase10;circuitLayer1;circuitLayer2;circuitLayer3;circuitLayer4],opQs,measureQs,stats,measureType, false);
    
    measureQs = {'q11'};
    measureType = 'Mphase';
    [Phase11, ~, ~, ~] = sqc.util.runCircuit([circuitPhase11;circuitLayer1;circuitLayer2;circuitLayer3;circuitLayer4],opQs,measureQs,stats,measureType, false);
    
    measureQs = {'q12'};
    measureType = 'Mphase';
    [Phase12, ~, ~, ~] = sqc.util.runCircuit([circuitPhase12;circuitLayer1;circuitLayer2;circuitLayer3;circuitLayer4],opQs,measureQs,stats,measureType, false);
    
    disp('Phase Done!')

end

Phase=[Phase2,Phase3,Phase4,Phase5,Phase6,Phase7,Phase8,Phase9,Phase10,Phase11,Phase12];
Ptomo=[Ptomo23,Ptomo34,Ptomo45,Ptomo56,Ptomo67,Ptomo78,Ptomo89,Ptomo910,Ptomo1011,Ptomo1112];

finishTime = now;

save(datafile,...
    'startTime','finishTime',...
    'circuitLayer1','circuitLayer2','circuitLayer3','circuitLayer4',...
    'opQs','stats',...
    'Ptomo23','Ptomo56','Ptomo89','Ptomo1112',...
    'Phase1','Phase2','Phase3','Phase4',...
    'Ptomo12','Ptomo45','Ptomo78','Ptomo1011',...
    'Phase5','Phase6','Phase7','Phase8',...
    'Ptomo34','Ptomo67','Ptomo910',...
    'Phase9','Phase10','Phase11','Phase12','Phase','Ptomo');

end
function check2Qreadout(measureQs,qubits)
maxRepeat=5;
repeatid=1;
F=0;
while F<0.99 && repeatid<maxRepeat
    disp(['check readout No.' num2str(repeatid)])
    data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0)
    F=data_taking.public.xmon.tuneup.checkreadout(measureQs{1}, measureQs{2});
    repeatid=repeatid+1;
end
end