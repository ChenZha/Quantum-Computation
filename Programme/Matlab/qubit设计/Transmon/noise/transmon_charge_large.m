e = 1.60217662e-19; 
Ec = 0.35e9;
Ej = 30e9;
A = 1e-4;
T2 = charge_large(Ec,Ej,A);
disp(T2);

function T2 = charge_large(Ec,Ej,A)
hbar=1.054560652926899e-034;
h = hbar*2*pi;
e = 1.60217662e-19; 
phi0 = 2*pi*hbar/(2*e);

e1 = -h*Ec*2^9*sqrt(2/pi)*(Ej/2/Ec)^(5.0/4)*exp(-sqrt(8*Ej/Ec));
T2 = 4*hbar*exp(2)/pi/abs(e1);
end