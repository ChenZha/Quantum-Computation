phi = linspace(-0.21,0.21,50);
for i  = 1:50
    [g0,f0] = gcal(phi(i));
    g(i) = g0/10^6;
    f(i) = f0/10^9;
end
figure();plot(phi,g);xlabel('\Phi / \Phi_0');ylabel('g/MHz');
figure();plot(phi,f);xlabel('\Phi / \Phi_0');ylabel('f01/GHz');






function [g,f] = gcal(phi)
% phi为除以phi0后的值
hbar=1.054560652926899e-034;
h = hbar*2*pi;
e = 1.60217662e-19; 
phi0 = 2*pi*hbar/(2*e);

cg = 1.8*10^(-15);
cr = 376.43*10^(-15);
cq = 77*10^(-15);

fr = 5.1*10^9;
fc = 250*10^6;
f10 = 6.04*10^9;
fj = (f10+fc)^2/8.0/fc;
f = sqrt(8*fj*fc)*sqrt(cos(pi*phi))-fc;

g = cg/2.0/sqrt(cr*cq/(fr*f));

end