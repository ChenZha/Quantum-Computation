function [y]=lorentzian(Coefficients,x)
y0 = Coefficients(1);
A = Coefficients(2);
w = Coefficients(3);
x0 = Coefficients(4);
y = y0+(2*A/pi).*(w./(4*(x-x0).^2+w.^2));