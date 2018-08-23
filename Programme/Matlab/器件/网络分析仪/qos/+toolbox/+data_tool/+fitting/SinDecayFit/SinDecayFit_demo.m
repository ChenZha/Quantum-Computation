% This is a script to demonstrate the usage of 'SinDecayFit'
% To fit real data, use 'RabiOscDataFitting'

datafile = 'RabiOscTestData_Han_3.mat';

clc;
fulldatafile = fullfile(pwd,'testdata', datafile);
load(fulldatafile);
%%
[A,B,C,D,freq,td] = SinDecayFit(t,P);
if ischar(A)
    disp(A);
else
    fprintf('A = %f   B = %f   C = %f   D = %f   freq = %fMHz   td = %fnS\n ',A,B,C,D,freq*1000,td);
    figure();
    L = length(t);
    step = (t(end)-t(1))/L/50;       % 50 times sampling density
    tf = t(1):step:t(end);
    pf = SinusoidalDecay([A,B,C,D,freq,td],tf);
    plot(t,P,'bo','MarkerSize',8,'MarkerEdgeColor','b','MarkerFaceColor','b');
    hold on;
    plot(tf,pf,'r-','LineWidth',2);
    legend('data','fit');
    xlabel('t (ns)','FontSize',28);
    ylabel('P','FontSize',28);
    title(['Frequency: ',num2str(freq*1000,'%3.1f'),'MHz; td: ',num2str(td,'%4.1f'),'ns'],'FontSize',20)
    set(gcf,'Color',[1,1,1]);
    set(gca,'LineWidth',2,'FontSize',20);
end