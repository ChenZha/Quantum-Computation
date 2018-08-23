function EL = XMonELModulation(Ej0,Ec0,x)
%     Ej0 = 6/0.4;
%     Ec0 = 4*Ej0/50;
%     x = linspace(0,pi/2,30);
%     EL = XMonELModulation(Ej0,Ec0,x);
%     EL = [flipud(EL);EL];
%     figure();
%     plot([fliplr(-x),x],EL);
%     figure();
%     plot([fliplr(-x),x],diff(EL,1,2));

    N = length(x);
    Ej = Ej0*abs(cos(x));
    EL= NaN*ones(N,3);
    for ii = 1:length(x)
        el=sqc.simulation.ctx.CPBEL(Ec0,Ej(ii),0);
        el = el - el(1);
        EL(ii,:) = el(1:3);
    end
end