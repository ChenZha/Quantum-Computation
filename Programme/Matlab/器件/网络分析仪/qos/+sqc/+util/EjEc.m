function EjEc(Ic,C)
% EjEc evaluates Ej, Ec and Ej/Ec from Ic and C.
% Units:
% Ic: muA; C: fF; 
FluxQuantum = 2.067833636e-15;
PlanksConst = 6.626068E-34;
ee = 1.602176e-19;
Ej = Ic*1e-6*FluxQuantum/(2*pi)/PlanksConst/1e9;    % Unit: GHz.
Ec = ee^2./(2*C*1e-15)/PlanksConst/1e9;  % Unit: GHz.
R = Ej/Ec;
disp('----------');
disp(['Ic = ', num2str(Ic), ' muA']);
disp(['C = ', num2str(C), ' fF']);
disp(' ')
disp(['Ej  -->  ', num2str(Ej), ' GHz']);
disp(['Ec  -->  ', num2str(Ec), ' GHz']);
disp(['Ej/Ec = ', num2str(R)]);
disp('----------');