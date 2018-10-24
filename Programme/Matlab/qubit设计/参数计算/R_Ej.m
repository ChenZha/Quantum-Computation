% R = [10900,10900,10900,10900,9800,9800,9800,8800,8800,8800];
R = [750];
Ej = E(R);
function Ej = E(R)
hbar=1.054560652926899e-034;
h = hbar*2*pi;
e = 1.60217662e-19; 
I0 = 280e-9;
R0 = 1000;
I = I0*R0./R;
Ej = I*hbar/2/e/h/10^9;

end