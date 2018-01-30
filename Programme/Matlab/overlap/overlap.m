T = 110;
N = 1024;
tlist = linspace(0,T,N);
D = wave(tlist);
% figure();plot(tlist,D);


f0 = fft(D);
f1 = fftshift(f0);
f = linspace(-N/T/2,N/T/2,N);
figure();plot(f,f1);



function D = wave(t)
Omega = 0.03332*2*pi/2;
    
delta = 10;

w_q = 5.22  * 2 * pi;
eta_q = -0.25 * 2 *pi;
D = (Omega*(exp(-(t-20).^2/2.0/6^2).*cos(t*w_q)+(t-20)./2/6^2/eta_q.*exp(-(t-20).^2/2.0/6^2).*cos(t*w_q-pi/2)));
D = D+(Omega*(exp(-(t-20-delta).^2/2.0/6^2).*cos(t*w_q)+(t-20-delta)/2/6^2/eta_q.*exp(-(t-20-delta).^2/2.0/6^2).*cos(t*w_q-pi/2)));

% D = cos(3*2*pi*t)+cos(3*2*pi*(t-3/12));


end