%计算有厚度的线路参数
t = 250e-9;
S = 4.0e-6;
W = 2.0e-6;
er = 9.4;
a = S/2;
b = S/2+W;

e0 = 8.85 * 10^(-12);
nu = 4*pi*10^(-7);
ef = (1+er)/2;

k0 = S/(S+2*W);
k1 = sqrt(1-k0^2);
d = 2*t/pi;
u1t = a+d/2+3*log(2)/2*d-d/2*log(d/a)+d/2*log((b-a)/a+b);
u2t = b-d/2-3*log(2)/2*d+d/2*log(d/b)-d/2*log((b-a)/a+b);
k0t = u1t/u2t;
k1t = sqrt(1-k0t^2);

C = e0*2*ellipke(k0t)/ellipke(k1t)+er*e0*2*ellipke(k0)/ellipke(k1);

t = t/2;
d = 2*t/pi;
u1t = a+d/2+3*log(2)/2*d-d/2*log(d/a)+d/2*log((b-a)/a+b);
u2t = b-d/2-3*log(2)/2*d+d/2*log(d/b)-d/2*log((b-a)/a+b);
k0t = u1t/u2t;
k1t = sqrt(1-k0t^2);

L = nu*ellipke(k1t)/ellipke(k0t)/4;

Z0 = sqrt(L/C);
fprintf('Cl = %f pF\n',C*10^12);
fprintf('Ll = %f nH\n',L*10^9);
fprintf('Z0 = %f \n',Z0);

