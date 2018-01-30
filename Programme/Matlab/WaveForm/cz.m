amp = 1;
thf = 0.55*pi/2;
thi = 0.05;
lam2 = -0.18;
lam3 = 0.04;
resolution = 1024;

ti=linspace(0,1,resolution);
han2 = (1-lam3)*(1-cos(2*pi*ti))+lam2*(1-cos(4*pi*ti))+lam3*(1-cos(6*pi*ti));
thsl=thi+(thf-thi)*han2/max(han2);
% x = 1./tan(thsl);
% x = x-x(1);
% figure();plot(ti,-1*x);title('No interp');
tlu=cumsum(sin(thsl))*ti(2);%t(¦Ó)
% tlu=cumsum(cos(thsl))*ti(2);%t(¦Ó)
tlu(1);
tlu=tlu-tlu(1);
ti=linspace(0, tlu(end), resolution);
th=interp1(tlu,thsl,ti,'linear', 0);%¦È(t)
th=1./tan(th);
th=th-th(1);
min(th);
th=th/min(th);
figure();plot(ti,th);title('interp');
b = besselj(0,(2.4048*0.2*2*pi-2.4048*0.2*2*pi*th)./0.2/2/pi);
figure();plot(ti,b);
