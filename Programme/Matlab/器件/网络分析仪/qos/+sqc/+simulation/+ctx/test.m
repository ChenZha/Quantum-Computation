FluxQuantum = 2.067833636e-15;
PlanksConst = 6.626068E-34;
ee = 1.602176e-19;

% 0.280 uA -> junction resistance 1kOhm
KRI = 0.280e-6;

R = 6.5e3;
Ic = KRI/(R/1e3);
C = 70e-15;

Ej = Ic*FluxQuantum/(2*pi)/PlanksConst/1e9    % Unit: GHz.
Ec = (2*ee)^2./(2*C)/PlanksConst/1e9  % Unit: GHz.
f01_est = sqrt(8*Ej*Ec/4)
    
%%
x = linspace(0,pi/2,30);
EL = sqc.simulation.ctx.XMonELModulation(Ej,Ec,x);
EL = [flipud(EL);EL];
figure();
plot([fliplr(-x),x]/(pi/2)/2,diff(EL,1,2));
xlabel('flux bias/\Phi_0');
ylabel('GHz');
legend({'f01','f12'})