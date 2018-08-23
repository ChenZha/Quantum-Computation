function phi = fit2QIdlePhase(Pm)
% chi = sqc.qfcns.processTomoData2Rho(Pm);

    function y = fitFunc(phi_)
        PIdeal = sqc.qfcns.IChiP(phi_);
        D = (real(PIdeal) - Pm).^2;
        y = sum(D(:));
    end
    
    phi = qes.util.fminsearchbnd(@fitFunc,[0,0],[-pi,-pi],[pi,pi]);

end