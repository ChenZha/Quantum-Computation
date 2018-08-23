function [result]=clusterStateTomo_Q2_Q12_rGates_withCal(measureQs,Phase,docali)
% data_taking.ming.sampling.clusterState_Q1_Q12_rGates_withCal(Ptomo34,Ptomo67,Ptomo910,Phase31,Phase32,Phase35,Phase38,Phase311,Phase312)

if nargin<3
    docali=true;
end
import sqc.util.getQSettings
notes = '';

% if dosave
% hf = qes.ui.qosFigure(['clusterStateTomo ',measureQs{1},' ',measureQs{end}],false);
% ax = axes('parent',hf);
% end

opQs = {'q2','q3','q4','q5','q6','q7','q8','q9','q10','q11','q12'};
qubits=opQs;
[~,Minx]=ismember(measureQs,opQs);

path=['E:\data\20180216_12bit\sampling\' datestr(now,'yymmdd') '\Tomo'];
if ~exist(path)
    mkdir(path)
end

    function rgz = ZRnd()
        rgz = sprintf('Rz(%0.6f)',(2*rand()-1)*pi);
    end

GPhase32=sprintf('Rz(%0.6f)',-Phase(1));
GPhase33=sprintf('Rz(%0.6f)',-Phase(2));
GPhase34=sprintf('Rz(%0.6f)',-Phase(3));
GPhase35=sprintf('Rz(%0.6f)',-Phase(4));
GPhase36=sprintf('Rz(%0.6f)',-Phase(5));
GPhase37=sprintf('Rz(%0.6f)',-Phase(6));
GPhase38=sprintf('Rz(%0.6f)',-Phase(7));
GPhase39=sprintf('Rz(%0.6f)',-Phase(8));
GPhase310=sprintf('Rz(%0.6f)',-Phase(9));
GPhase311=sprintf('Rz(%0.6f)',-Phase(10));
GPhase312=sprintf('Rz(%0.6f)',-Phase(11));
GPhase= {GPhase32,GPhase33,GPhase34,GPhase35,GPhase36,GPhase37,GPhase38,GPhase39,GPhase310,GPhase311,GPhase312};
% GPhase = {'','','','','','','','','','','',''};

G1 = {'','','','','','','','','','',''};
for ii=1:numel(Minx)
    G1{Minx(ii)}='Y2p';
end

circuitLayer1 = {'CZ','CZ','','CZ','CZ','','CZ','CZ','','CZ','CZ'};
circuitLayer2 = {'','','CZ','CZ','','CZ','CZ','','CZ','CZ',''};
circuitLayer3 = {'','CZ','CZ','','CZ','CZ','','CZ','CZ','',''};
circuitLayer4 = {'I(40)','I(40)','I(40)','I(40)','I(40)','I(40)','I(40)','I(40)','I(40)','I(40)','I(40)'};

circuits = [G1;circuitLayer1;circuitLayer2;circuitLayer3;circuitLayer4;GPhase];

stats = 3000;
measureType = 'Mstomop'; % default 'Mzj', z projection

tic
if docali
    maxRepeat=10;
    repeatid=1;
    F=0;
    while F<0.994 && repeatid<maxRepeat
        disp(['check readout No.' num2str(repeatid)])
        data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0)
        F=data_taking.public.xmon.tuneup.checkreadout(measureQs{1}, measureQs{2});
        repeatid=repeatid+1;
    end
end

[result, singleShotEvents, sequenceSamples, ~] =...
    sqc.util.runCircuit(circuits,opQs,(measureQs),stats,measureType, false);
Fidelities =  getQSettings('r_iq2prob_fidelity',(measureQs));

datafile = [path,'\clusterStateTomo_',measureQs{1},'_',measureQs{end},'_',datestr(now,'yymmddTHHMMSS'),'.mat'];
save(datafile,'result','singleShotEvents','Fidelities','circuits','sequenceSamples','notes','opQs','measureQs','Phase','docali');
%             try
%
%             catch
%                 hf = qes.ui.qosFigure('',false);
%                 ax = axes('parent',hf);
%             end
%             drawnow;
%             saveas(hf,replace(datafile,'.mat','.fig'))
toc

end
