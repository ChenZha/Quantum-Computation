





R = [10900,10900,10900,10900,9800,9800,9800,8800,8800,8800];
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


% p = 0.01:0.001:1;
% t = Time(p);
% figure();plot(p,t);
% 
% 
% function t = Time(p)
% t = log10(1-0.99)./log10(1-p);
% end

% [f1,f2] = meshgrid(0:0.05:10*pi);
% u = U(f1,f2);
% figure();surf(f1,f2,u);
% 
% 
% 
% function u = U(f1,f2)
% u = -cos(f1)-cos(f2)-0.6*cos(pi-f1-f2);
% end
% 
% function [fs,fa] = Ca2(f1,f2)
% fs = (f1+f2)/2;
% fa = (f1-f2)/2;
% 
% end