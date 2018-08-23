clear all;
load('SpectrumLines_data.mat')
load('N2.mat')
xdata = linspace(-16,0,60);
fluxbias = xdata*1e-3 +0.5;  % unit flux quantum;
% matlabpool open 8


Jc = x(1);      % kA/cm^2
Cc = x(2);      % fF/um^2
S = x(3);       % um^2
alpha = x(4);   %

L = 30;  % pH
kappa = 0;
sigma = 0;
FluxBias = x;
nk = 10;
nl = 20;
nm = 4;

N = length(fluxbias);
f01calc = zeros(1,N);
f02calc = zeros(1,N);
parfor ii = 1:N
    [E01,E02] = TriJFlxQbtdE(Jc,Cc,S,L,alpha,kappa,sigma,fluxbias(ii),nk,nl,nm);
    f01calc(ii) = E01;
    f02calc(ii) = E02;
end
tmp = -xdata(1:end-1);
xdata = [xdata,fliplr(tmp)];
f01calc = [f01calc, fliplr(f01calc(1:end-1))];
f02calc = [f02calc, fliplr(f02calc(1:end-1))];

h = figure();
plot(flux01,f01,'.b',flux02,f02,'.b');
hold on;
plot(xdata,f01calc,'-r',xdata,f02calc,'-r');
xlabel('\Phi_q (m\Phi0)');
ylabel('f (GHz)');
saveas(h,'6258634524.fig');
saveas(h,'6258634524.png');

    