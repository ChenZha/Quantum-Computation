function Err = SpectrumLineErrorFcn_Jc_Cc_S_Alpaha_low(p)

%     x = [0   -3.0400   -6.0800   -9.1200  -12.1600  -15.2000];
% %     y1 = [1.0712    5.2182   10.2069   15.1502   19.9511   24.2124];
% %     y2 = [20.4903   22.3517   24.1392   25.7463   26.9363];

%     x = [0   -3.0400   -6.0800   -9.1200  -12.1600  -15.2000];
%     y = [1.0712    5.2182   10.2069   15.1502   19.9511   24.2124,...
%         20.4903   22.3517   24.1392   25.7463   26.9363];
    
    x = [0          -6.0800         -12.1600  -15.2000]*1e-3+0.5;  % Phi_0
    y = [1.0712         10.2069         19.9511   24.2124,...
        20.4903         24.1392         26.9363];  % GHz
    
    Jc = p(1);      % kA/cm^2
    Cc = p(2);      % fF/um^2
    S = p(3);       % um^2
    alpha = p(4);   %
    
    L = 30;  % pH
    kappa = 0;
    sigma = 0;
    FluxBias = x;
    nk = 5;
    nl = 10;
    nm = 3;
    
    N = length(x);
    ycalc1 = zeros(1,N);
    ycalc2 = zeros(1,N);
    for ii = 1:N
        [E01,E02] = TriJFlxQbtdE(Jc,Cc,S,L,alpha,kappa,sigma,FluxBias(ii),nk,nl,nm);
         ycalc1(ii) = E01;
         ycalc2(ii) = E02;
    end
    ycalc = [ycalc1,ycalc2(1:end-1)];
    dy = ycalc-y;
    Err = sqrt(sum(dy.^2));
%     figure();
%     plot([x, x(1:end-1)],y,'xb',[x, x(1:end-1)],ycalc,'+r');
end

function [E01,E02] = TriJFlxQbtdE(Jc,Cc,S,L,alpha,kappa,sigma,FluxBias,nk,nl,nm)
    [Ej, Ec, beta] = EjEcBetaCalc(Jc,Cc,S,L,alpha);
    EL = TriJFlxQbtEL(Ej,Ec,alpha,beta,kappa,sigma,FluxBias,nk,nl,nm,6);
    E01 = (EL(3) + EL(4) - EL(1) - EL(2))/2;
    E02 = (EL(5) + EL(6) - EL(1) - EL(2))/2;
end

function [Ej, Ec, beta] = EjEcBetaCalc(Jc,Cc,S,L,alpha)
% 
%     Jc 1kA/cm^2
%     Cc fA/um^2
%     S um^2
%     L pH
%     alpha
    Ic = Jc*10*S;   % 1kA/cm^2 = 10 muA/mum^2
    C = Cc*S;
    FluxQuantum = 2.067833636e-15;
    PlanksConst = 6.626068e-34;
    ee = 1.602176e-19;
    Ej = Ic*1e-6*FluxQuantum/(2*pi)/PlanksConst/1e9;    % Unit: GHz.
    Ec = ee^2./(2*C*1e-15)/PlanksConst/1e9;  % Unit: GHz.
    beta = (2*pi/(2+1/alpha))*Ic*1e-6*L*1e-12/FluxQuantum;
end