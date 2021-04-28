%计算平面线路参数

S = 4.0 * 10^(-6);
W = 2.0 * 10^(-6);
er = 9.4;


e0 = 8.85 * 10^(-12);
nu = 4*pi*10^(-7);
ef = (1+er)/2;
k0 = S/(S+2*W);
k1 = sqrt(1-k0^2);

Cl = 4*e0*ef*ellipke(k0)/ellipke(k1);
Ll = nu/4*ellipke(k1)/ellipke(k0);
Z0 = sqrt(Ll/Cl);
fprintf('Cl = %f pF\n',Cl*10^12);
fprintf('Ll = %f nH\n',Ll*10^9);
fprintf('Z0 = %f \n',Z0);


