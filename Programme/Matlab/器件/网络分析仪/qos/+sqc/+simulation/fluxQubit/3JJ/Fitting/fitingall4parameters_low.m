
% Jc = x(1);  % kA/cm^2
% Cc = x(2);  % fF/um^2
% S = x(3);   % um^2
% alpha = x(4);

load('SpectrumLines_data.mat')
flux = linspace(-15,0,20)*1e-3+0.5;

matlabpool open 3
options = optimset('UseParallel','always');


%%
x0 = [0.2; 50; 0.2; 0.65];
lb = [0.1; 30; 0.10; 0.5];
ub = [0.4; 120; 0.4; 0.8]; 
[x,fval] = fmincon(@SpectrumLineErrorFcn_Jc_Cc_S_Alpaha_low,x0,[],[],[],[],lb,ub)
disp('SpectrumLineErrorFcn_Jc_Cc_S_Alpaha_low done')
try
    save('N1.mat','x');

    Jc = x(1);      % kA/cm^2
    Cc = x(2);      % fF/um^2
    S = x(3);       % um^2
    alpha = x(4);   %

    L = 30;  % pH
    kappa = 0;
    sigma = 0;
    FluxBias = x;
    nk = 5;
    nl = 10;
    nm = 3;

    N = length(flux);
    f01calc = zeros(1,N);
    f02calc = zeros(1,N);
    for ii = 1:N
        [E01,E02] = TriJFlxQbtdE(Jc,Cc,S,L,alpha,kappa,sigma,flux(ii),nk,nl,nm);
        f01calc(ii) = E01;
        f02calc(ii) = E02;
    end
    tmp = -flux(1:end-1);
    fluxbias = [flux,fliplr(tmp)];
    f01calc = [f01calc, fliplr(f01calc)];
    f02calc = [f02calc, fliplr(f02calc)];

    h = figure();
    plot(flux01,f01,'.b',flux02,f02,'.b');
    hold on;
    plot(fluxbias,f01calc,'-r',fluxbias,f02calc,'-r');
    save(h,'N1.fig');
catch
end


matlabpool close