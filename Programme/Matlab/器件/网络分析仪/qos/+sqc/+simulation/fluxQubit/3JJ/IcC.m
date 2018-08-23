function IcC(Ej,Ec)
% IcC Calculates Ic, C from Ej,Ec.
% Units:
% Ej: GHz; Ec: GHz.
FluxQuantum = 2.067833636e-15;
PlanksConst = 6.626068e-34;
ee = 1.602176e-19;
Ic = 2*pi*PlanksConst*1e9*Ej/FluxQuantum/1e-9; % Unit: nA.
C = ee^2./(2*PlanksConst*1e9*Ec)/1e-15;  % Unit: fF.
disp(['Ic = ', num2str(Ic), 'nA; C = ', num2str(C), 'fF']);