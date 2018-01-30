
gama = 20:1:200;
D = 1:0.01:2;
% [gama,D] = meshgrid(gama,D);
T = trans(gama);
figure();plot(gama,T)
% figure();pcolor(gama,D,T);colorbar();
function T = trans(chi)
D = 10;
gama = 10;
% chi = 20;
h = 5;
a = D./chi;
k1 = sqrt(gama);
k2 = sqrt(gama-chi);
k3 = sqrt(gama-h);
kappa =sqrt(chi-gama);

T = 4*k3./k1./((1+k3./k1).^2.*cosh(kappa.*a).^2+(kappa./k1-k3./kappa).^2.*sinh(kappa.*a).^2);


end