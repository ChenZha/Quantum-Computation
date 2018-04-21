% x = linspace(0,2*pi,100);
% plot(x,cg(x));hold on;
% 
% function g = cg(x)
%     hbar=1.054560652926899e-034;
%     h = hbar*2*pi;
%     e = 1.60217662e-19;
%     phi0 = 2*pi*hbar/(2*e);
%     LJ = 9e-9;
%     Lg = 200e-12;
%     I0 = 700e-9;
%     Lc = phi0/2/pi/I0;
%     w0 = 5.67e9;
%     
%     
%     g = -w0/2*Lg/(Lg+LJ)*Lg./(2*Lg+Lc./cos(x))/10^6;
% end
 
