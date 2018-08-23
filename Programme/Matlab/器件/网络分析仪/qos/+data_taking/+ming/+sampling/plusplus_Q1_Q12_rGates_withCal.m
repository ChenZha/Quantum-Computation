function [Px,Py,Pz]=plusplus_Q1_Q12_rGates_withCal(measureQs,numRunsPerTake,dosave)
% data_taking.ming.sampling.plusplus_Q1_Q12_rGates_withCal(qubits,10)

if nargin<3
    dosave=true;
end

import sqc.util.getQSettings
notes = '';

if dosave
    hf = qes.ui.qosFigure(['plusplusState ',measureQs{1},' ',measureQs{end}],false);
    ax = axes('parent',hf);
end

opQs = {'q1','q2','q3','q4','q5','q6','q7','q8','q9','q10','q11','q12'};
qubits=opQs;

path=['E:\data\20180216_12bit\sampling\' datestr(now,'yymmdd') '\plusplus'];
if ~exist(path)
    mkdir(path)
end

G1 = {'Y2p','Y2p','Y2p','Y2p','Y2p','Y2p','Y2p','Y2p','Y2p','Y2p','Y2p','Y2p'};

M = [{'Y2m','Y2m','Y2m','Y2m','Y2m','Y2m','Y2m','Y2m','Y2m','Y2m','Y2m','Y2m'};...
    {'X2p','X2p','X2p','X2p','X2p','X2p','X2p','X2p','X2p','X2p','X2p','X2p'};...
    {'','','','','','','','','','','',''}];

G2 = {'I(40)','I(40)','I(40)','I(40)','I(40)','I(40)','I(40)','I(40)','I(40)','I(40)','I(40)','I(40)'};

circuits = G1;

stats = 2500;
measureType = 'Mstomop'; % default 'Mzj', z projection

tic
P=[];
for ii=1:numel(measureQs)
    for jj = 1:numRunsPerTake
        [result] =...
            sqc.util.runCircuit(circuits,opQs,{measureQs{ii}},stats,measureType, false);
        if jj == 1
            Pi = result(:,1);
        else
            Pi = Pi + result(:,1);
        end
    end
    P(:,ii) = Pi/numRunsPerTake;
end
Fidelities =  getQSettings('r_iq2prob_fidelity',measureQs);

measureType='Mzj';
for ii=1:3
    for jj = 1:numRunsPerTake
        [result] =...
            sqc.util.runCircuit([circuits;M(ii,:)],opQs,measureQs,stats,measureType, false);
        if jj == 1
            Pi = result;
        else
            Pi = Pi + result;
        end
    end
    if ii==1
        Px(:) = Pi/numRunsPerTake;
    elseif ii==2
        Py(:) = Pi/numRunsPerTake;
    else
        Pz(:) = Pi/numRunsPerTake;
    end
end

Pildeal=[1,0.5,0.5];

for ii=1:numel(measureQs)
    F(ii)= fidelity(P(:,ii),Pildeal);
end

if dosave
    datafile = [path,'\plusplusState_',measureQs{1},'_',measureQs{end},'_',datestr(now,'yymmddTHHMMSS'),'.mat'];
    save(datafile,'P','Fidelities','circuits','notes','opQs','measureQs','numRunsPerTake','Px','Py','Pz','F');
    try
        bar(ax,F);
        xlabel(ax,'Qubits index');
        ylabel(ax,'++ Fidelity');
    catch
        hf = qes.ui.qosFigure('',false);
        ax = axes('parent',hf);
    end
    drawnow;
    saveas(hf,replace(datafile,'.mat','.fig'))
end
toc

end
function [F] = fidelity(P1,P2)

rho=[1-P1(3),(P1(1)-0.5)-1i*(P1(2)-0.5);(P1(1)-0.5)+1i*(P1(2)-0.5),P1(3)];
rho2=[1-P2(3),(P2(1)-0.5)-1i*(P2(2)-0.5);(P2(1)-0.5)+1i*(P2(2)-0.5),P2(3)];

m = rho*rho2;
F = trace(m);
F = sqrt(real(F));
end