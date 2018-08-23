% Generate test data for 'SinDecayFit_main'
clc;
RabiFreq = 0.1;  % GHz
T = 1/RabiFreq;  % Oscillation period
step = T/3;       % sampling rate: 3 per period
TimeRange = 800;    % nS
tf = 0:step/50:TimeRange;
t = 0:step:TimeRange;
t = t';
Pf = SinusoidalDecay([A,B,C,D,0.1,300],tf);
P = SinusoidalDecay([A,B,C,D,0.1,300],t);
P = P + 0.1*B*randn(size(t));
figure();
plot(tf,Pf,'r-',t,P,'bo');
xlabel('t (nS)','FontSize',12);
ylabel('P','FontSize',12);
legend('Embedded signal','Signal corrupted by zero-mean random noise')
set(gcf,'Color',[1,1,1]);
    