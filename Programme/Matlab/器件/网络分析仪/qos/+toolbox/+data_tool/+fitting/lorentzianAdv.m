function [y]=lorentzianAdv(Coefficients,x)
y0 = Coefficients(1);
k1 = Coefficients(2);
k2 = Coefficients(3);
A = Coefficients(4);
w = Coefficients(5);
x0 = Coefficients(6);
y = y0+k1*x+k2*x.^2+(2*A/pi).*(w./(4*(x-x0).^2+w.^2));