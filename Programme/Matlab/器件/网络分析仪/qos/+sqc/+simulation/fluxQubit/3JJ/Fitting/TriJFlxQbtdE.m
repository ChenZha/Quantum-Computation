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