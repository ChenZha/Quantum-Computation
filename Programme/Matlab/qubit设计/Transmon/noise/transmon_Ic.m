e = 1.60217662e-19; 
Ec = 0.505e9;
Ej = 10.6e9;

A = 1e-6;%AÒÑ¾­³ýÒÔIc
T2 = Ic(Ec,Ec,A);

disp(T2);

function T2 = Ic(Ec,Ej,A)
hbar=1.054560652926899e-034;
h = hbar*2*pi;
e = 1.60217662e-19; 
phi0 = 2*pi*hbar/(2*e);
E01 = sqrt(8*Ec*Ej)-Ec;
disp(E01);
% e1 = -h*Ec*2^9*sqrt(2/pi)*(Ej/2/Ec)^(5.0/4)*exp(-sqrt(8*Ej/Ec));
T2 = 2*hbar/A/h/E01;
end