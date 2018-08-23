function [Phase,Fcz,Fpp]=analyseCZTomo_Q2_Q12(path)
% [Phase,Fcz,Fpp]=data_taking.ming.sampling.analyseCZTomo(path)

if nargin<1
    path='E:\data\20180216_12bit\sampling\180518\Tomo\CZTomo_Q1_Q12_180518T100634.mat';
end

load(path);
[PhaseA(1),PhaseB(1),Fcz(1),Fpp(1)] = toolbox.data_tool.fitting.fitCZQPhase(Ptomo23);
[PhaseA(2),PhaseB(2),Fcz(2),Fpp(2)] = toolbox.data_tool.fitting.fitCZQPhase(Ptomo34);
[PhaseA(3),PhaseB(3),Fcz(3),Fpp(3)] = toolbox.data_tool.fitting.fitCZQPhase(Ptomo45);
[PhaseA(4),PhaseB(4),Fcz(4),Fpp(4)] = toolbox.data_tool.fitting.fitCZQPhase(Ptomo56);
[PhaseA(5),PhaseB(5),Fcz(5),Fpp(5)] = toolbox.data_tool.fitting.fitCZQPhase(Ptomo67);
[PhaseA(6),PhaseB(6),Fcz(6),Fpp(6)] = toolbox.data_tool.fitting.fitCZQPhase(Ptomo78);
[PhaseA(7),PhaseB(7),Fcz(7),Fpp(7)] = toolbox.data_tool.fitting.fitCZQPhase(Ptomo89);
[PhaseA(8),PhaseB(8),Fcz(8),Fpp(8)] = toolbox.data_tool.fitting.fitCZQPhase(Ptomo910);
[PhaseA(9),PhaseB(9),Fcz(9),Fpp(9)] = toolbox.data_tool.fitting.fitCZQPhase(Ptomo1011);
[PhaseA(10),PhaseB(10),Fcz(10),Fpp(10)] = toolbox.data_tool.fitting.fitCZQPhase(Ptomo1112);

PhaseA=[PhaseA,PhaseB(end)];
PhaseB=[PhaseA(1),PhaseB];
Phase=(PhaseA+PhaseB)/2+pi*(abs(PhaseB-PhaseA)>pi);

tt=split(path,'\');
tt=tt(end);
h=figure;subplot(2,1,1);plot(1:10,Fcz,'ob',1:10,Fpp,'or');legend('CZ Fidelity','|++> Fidelity','location','best');xlabel('CZ sets');ylabel('Fidelity');title(tt)
subplot(2,1,2);plot(1:11,Phase,'*',1:11,PhaseA,'^',1:11,PhaseB,'v');legend('Phase average','Phase from CZ1', 'Phase from CZ2','location','best');xlabel('qubits #');ylabel('Phase');axis tight
saveas(h,replace(path,'.mat','.fig'))
end