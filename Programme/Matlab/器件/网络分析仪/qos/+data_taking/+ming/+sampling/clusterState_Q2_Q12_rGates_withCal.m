function [Pxz,Pzx,Pxzz,Pzz]=clusterState_Q2_Q12_rGates_withCal(measureQs,Phase,numRunsPerTake,ms,docali,dosave,numTakes)
% data_taking.ming.sampling.clusterState_Q1_Q12_rGates_withCal(Ptomo34,Ptomo67,Ptomo910,Phase31,Phase32,Phase35,Phase38,Phase311,Phase312)

if nargin<=2
    numRunsPerTake=4;
    ms=[1 2 3];
    docali=true;
    dosave=true;
end
if nargin<6
    dosave=true;
end
if nargin<5
    docali=true;
end
if nargin<7
    numTakes=[];
end
import sqc.util.getQSettings
notes = '';

if dosave
hf = qes.ui.qosFigure(['clusterState ',measureQs{1},' ',measureQs{end}],false);
ax = axes('parent',hf);
end

opQs = {'q2','q3','q4','q5','q6','q7','q8','q9','q10','q11','q12'};
qubits=opQs;
[~,Minx]=ismember(measureQs,opQs);

path=['E:\data\20180216_12bit\sampling\' datestr(now,'yymmdd') '\cluster'];
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

M = [{'','Y2m','','Y2m','','Y2m','','Y2m','','Y2m',''};...
    {'Y2m','','Y2m','','Y2m','','Y2m','','Y2m','','Y2m'};...
    {'','Y2m','','','Y2m','','','Y2m','','','Y2m'};...
    {'','','','','','','','','','',''}];

circuitLayer1 = {'CZ','CZ','','CZ','CZ','','CZ','CZ','','CZ','CZ'};
circuitLayer2 = {'','','CZ','CZ','','CZ','CZ','','CZ','CZ',''};
circuitLayer3 = {'','CZ','CZ','','CZ','CZ','','CZ','CZ','',''};
circuitLayer4 = {'I(40)','I(40)','I(40)','I(40)','I(40)','I(40)','I(40)','I(40)','I(40)','I(40)','I(40)'};

circuits = [G1;circuitLayer1;circuitLayer2;circuitLayer3;circuitLayer4;GPhase];

stats = 2500;
measureType = 'Mzj'; % default 'Mzj', z projection

tic
Pxz=[];
Pzx=[];
Pzz=[];
Pxzz=[];
if isempty(numTakes)
    numTakes = round(max(1,1*(numel(measureQs)-9)));
end
for ii = 1:numTakes
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
    for mm=ms
        circuit=[circuits;M(mm,:)];
        Ei = [];
        for jj = 1:numRunsPerTake
            [result, singleShotEvents, sequenceSamples, ~] =...
                sqc.util.runCircuit(circuit,opQs,(measureQs),stats,measureType, false);
            if jj == 1
                Pi = result;
            else
                Pi = Pi + result;
            end
            Ei = [Ei,singleShotEvents];
        end
        P = Pi/numRunsPerTake;
        Events = Ei;
        Fidelities =  getQSettings('r_iq2prob_fidelity',(measureQs));
        
        if dosave
            datafile = [path,'\clusterState_',measureQs{1},'_',measureQs{end},'_L',num2str(mm),'_',datestr(now,'yymmddTHHMMSS'),'.mat'];
            save(datafile,'P','Events','Fidelities','circuit','sequenceSamples','notes','opQs','measureQs','numTakes','numRunsPerTake','ms','Phase','docali');
            try
                Pavg = P;
                bar(ax,Pavg);
                xlabel(ax,'state');
                ylabel(ax,'P');
                if mm==1
                    title(ax,[measureQs{1},' ',measureQs{end} ' ZXZXZXZXZXZX']);
                elseif mm==2
                    title(ax,[measureQs{1},' ',measureQs{end} ' XZXZXZXZXZXZ']);
                elseif mm==3
                    title(ax,[measureQs{1},' ',measureQs{end} ' XZZXZZXZZXZZ']);
                elseif mm==4
                    title(ax,[measureQs{1},' ',measureQs{end} ' ZZZZZZZZZZZZ']);
                end
            catch
                hf = qes.ui.qosFigure('',false);
                ax = axes('parent',hf);
            end
            drawnow;
            saveas(hf,replace(datafile,'.mat','.fig'))
        end
        if mm==1
            Pzx=[Pzx;P];
        elseif mm==2
            Pxz=[Pxz;P];
        elseif mm==3 
            Pxzz=[Pxzz;P];
        elseif mm==4
            Pzz=[Pzz;P];
        end
    end
end
toc

end
