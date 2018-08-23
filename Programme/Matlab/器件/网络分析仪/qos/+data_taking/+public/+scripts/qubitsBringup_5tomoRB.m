% tomography and randomized bnenchmarking
%%
for ii=7
q = qubits{ii};
setQSettings('r_avg',5000);
state = '|0>+|1>';
data = Tomo_1QState('qubit',q,'state',state,'gui',true,'save',true);
end
% rho = sqc.qfcns.stateTomoData2Rho(data);
% h = figure();bar3(real(rho));h = figure();bar3(imag(rho));
%%
q='q3';
setQSettings('r_avg',2000);
process = 'Y/2';
data = Tomo_1QProcess_animation('qubit',q,'process',process,'numPts',10,'notes','','save',true);
%%
gate = 'Y/2';
data = Tomo_1QProcess('qubit','q6','process',gate,'gui',true);
%%
setQSettings('r_avg',5000);
twoQStateTomoData = Tomo_2QState('qubit1','q1','qubit2','q2',...
  'state','|00>',...
 'notes','','gui',true,'save',true);
%%
gate = 'X/2';
data = Tomo_1QProcess('qubit','q1','process',gate,'gui',true);
%%
qubits = {'q7','q8','q9'};
setQSettings('r_avg',50000,qubits);
twoQStateTomoData = Tomo_mQState('qubits',qubits,...
  'state','1',...
 'notes','','gui',true,'save',true);
%%
CZTomoData = Tomo_2QProcess_incircuit('qubit1','q1','qubit2','q2','innerdelay',0,'withPre',true,'withTail',true,...
            'process','CZ','notes','','gui',true,'save',true);
        toolbox.data_tool.showprocesstomoCZ(CZTomoData)
%%
q = 'q1';
setQSettings('r_avg',1000);
numGates = int16(unique(round(logspace(1,log10(300),20))));
[Pref,Pgate] = randBenchMarking('qubit1',q,'qubit2',[],...
       'process','X/2','numGates',numGates,'numReps',60,...
       'gui',true,'save',true);   
[fidelity,h] = toolbox.data_tool.randBenchMarking(numGates, Pref, Pgate, 1, 'X/2');
%%
data_taking.public.xmon.tuneup.autoCalibration(qubits,1,3)
F=NaN(12,12);
theta1=F;
theta2=F;
for ii=1:12
    for jj=1:12
        if ii~=jj
            qc=qubits{ii};
            qt=qubits{jj};
            [F(ii,jj),theta]=data_taking.public.xmon.tuneup.checkreadout(qc,qt);
%             F(jj,ii)=F(ii,jj);
            theta1(ii,jj)=theta(1);
            theta2(ii,jj)=theta(2);
        end
    end
end
hf=figure;imagesc(1:12,1:12,F)
xlabel('qubit index')
ylabel('qubit index')
title('Two qubit |++> Fidelity')
saveas(hf,['E:\data\20180216_12bit\12bit++Fidelity_' datestr(now,'yymmddhhMMss') '.fig'])