function optx = OptWFSmBaF(tp,xi,xf)%最优化
tic;
%S = SwI(1.0866,tp,xi,xf)
f = @(lamda)SwI(lamda,tp,xi,xf);
% options = optimset('Display','iter','PlotFcns',@optimplotfval);
lamda0 = [1.1,-0.1];
[x,val] = fminsearch(f,lamda0);
optx = [x,(xf-xi)/2-x(1)];
PlotPSD(x,tp,xi,xf);
toc;
end


function S = SwI(lamda,tp,xi,xf)
syms t w;
k = zeros(1,3);
k(1) = lamda(1);k(2) = lamda(2);k(3) = (xf-xi)/2-lamda(1);
xita = xi+k(1)*(1-cos(2*pi*1*t/tp))+k(2)*(1-cos(2*pi*2*t/tp))+k(3)*(1-cos(2*pi*3*t/tp));%Θ
dxitat = diff(xita,t);%dΘ/dt
f = dxitat*exp(-1i*w*t);
Sw = (abs(int(f,t,0,tp)))^2;%PSD
Sw = matlabFunction(Sw);
wmin = 3.2*2*pi/tp;wmax = +inf;
S = integral(Sw,wmin,wmax);%PSD积分
end

function PlotPSD(lamda,tp,xi,xf)
syms t w;
k = zeros(1,3);
k(1) = lamda(1);k(2) = lamda(2);k(3) = (xf-xi)/2-lamda(1);
xitat = xi+k(1)*(1-cos(2*pi*1*t/tp))+k(2)*(1-cos(2*pi*2*t/tp))+k(3)*(1-cos(2*pi*3*t/tp));%Θ
dxitat = diff(xitat,t);%dΘ/dt
f = dxitat*exp(-1i*w*t);
Sw = (abs(int(f,t,0,tp)))^2;

xitat = matlabFunction(xitat);
dxitat = matlabFunction(dxitat);
Sw = matlabFunction(Sw);

subplot(2,2,1);
t = 0:tp/100:tp;
plot(t/tp,dxitat(t));hold on;
xlabel('t/tp');ylabel('d\Theta/dt');

subplot(2,2,2);
t = 0:tp/100:tp;
plot(t/tp,xitat(t));hold on;
xlabel('t/tp');ylabel('\Theta');

subplot(2,2,3);
t = 0:tp/100:tp;
plot(t/tp,1./tan(xitat(t)));hold on;
xlabel('t/tp');ylabel('H_{z}/H_{x}');

subplot(2,2,4);
w = 0:6*2*pi/tp/400:6*2*pi/tp;
plot(w*tp/2/pi,log10(Sw(w)));hold on;
set(gca,'YLim',[-7 0]);
xlabel('t_{p}\omega_{x}/2\pi');ylabel('S(\omega_{0})');
end