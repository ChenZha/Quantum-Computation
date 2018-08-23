function [Phase,Fcz,Fpp]=analyseCZTomo_Q1_Q12(path)
% [Phase,Fcz,Fpp]=data_taking.ming.sampling.analyseCZTomo_Q1_Q12(path)

if nargin<1
    path='E:\data\20180216_12bit\sampling\180526\Tomo\CZTomo_Q1_Q12_180525T221919.mat';
end

load(path);
[PhaseA(1),PhaseB(1),Fcz(1),Fpp(1)] = toolbox.data_tool.fitting.fitCZQPhase(Ptomo12);
[PhaseA(2),PhaseB(2),Fcz(2),Fpp(2)] = toolbox.data_tool.fitting.fitCZQPhase(Ptomo23);
[PhaseA(3),PhaseB(3),Fcz(3),Fpp(3)] = toolbox.data_tool.fitting.fitCZQPhase(Ptomo34);
[PhaseA(4),PhaseB(4),Fcz(4),Fpp(4)] = toolbox.data_tool.fitting.fitCZQPhase(Ptomo45);
[PhaseA(5),PhaseB(5),Fcz(5),Fpp(5)] = toolbox.data_tool.fitting.fitCZQPhase(Ptomo56);
[PhaseA(6),PhaseB(6),Fcz(6),Fpp(6)] = toolbox.data_tool.fitting.fitCZQPhase(Ptomo67);
[PhaseA(7),PhaseB(7),Fcz(7),Fpp(7)] = toolbox.data_tool.fitting.fitCZQPhase(Ptomo78);
[PhaseA(8),PhaseB(8),Fcz(8),Fpp(8)] = toolbox.data_tool.fitting.fitCZQPhase(Ptomo89);
[PhaseA(9),PhaseB(9),Fcz(9),Fpp(9)] = toolbox.data_tool.fitting.fitCZQPhase(Ptomo910);
[PhaseA(10),PhaseB(10),Fcz(10),Fpp(10)] = toolbox.data_tool.fitting.fitCZQPhase(Ptomo1011);
[PhaseA(11),PhaseB(11),Fcz(11),Fpp(11)] = toolbox.data_tool.fitting.fitCZQPhase(Ptomo1112);

PhaseA=[PhaseA,PhaseB(end)];
PhaseB=[PhaseA(1),PhaseB];
Phase=(PhaseA+PhaseB)/2+pi*(abs(PhaseB-PhaseA)>pi);

tt=split(path,'\');
tt=tt(end);
h=figure;subplot(2,1,1);plot(1:11,Fcz,'ob',1:11,Fpp,'or');legend('CZ Fidelity','|++> Fidelity','location','best');xlabel('CZ sets');ylabel('Fidelity');title(tt)
subplot(2,1,2);plot(1:12,Phase,'*',1:12,PhaseA,'^',1:12,PhaseB,'v');legend('Phase average','Phase from CZ1', 'Phase from CZ2','location','best');xlabel('qubits #');ylabel('Phase');axis tight
saveas(h,replace(path,'.mat','.fig'))
h2=figure;
ax = axes('parent',h2);
for ii=1:11
fczall(ii)=prod(Fcz(12-ii:11));
fppall(ii)=prod(Fpp(12-ii:11));
end
plot(ax,2:12,fczall,'-.',2:12,fppall,'--')
saveas(h2,replace(path,'.mat','2.fig'))
h3=figure;
ax = axes('parent',h3);
bar(ax,Fcz);
xticklabels({'Q1Q2','Q3Q2','Q3Q4','Q5Q4','Q5Q6','Q7Q6','Q7Q8','Q9Q8','Q9Q10','Q11Q10','Q11Q12'})
ylabel('CZ Gate fidelity')
h4=figure;
ax = axes('parent',h4);
bar(ax,Fpp);
xticklabels({'Q1Q2','Q3Q2','Q3Q4','Q5Q4','Q5Q6','Q7Q6','Q7Q8','Q9Q8','Q9Q10','Q11Q10','Q11Q12'})
ylabel('Initial state |++> fidelity')
end