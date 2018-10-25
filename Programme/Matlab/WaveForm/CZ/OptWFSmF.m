function optx = OptWFSmF(tp,xi,xf)%最优化
tic;
% S = SwI(1.0866,tp,xi,xf)
f = @(lamda)SwI(lamda,tp,xi,xf);
% options = optimset('Display','iter','PlotFcns',@optimplotfval);
lamda0 = 1.0;
[x,val] = fminsearch(f,lamda0);
optx = [x,(xf-xi)/tp-x];
PlotPSD(x,tp,xi,xf);
toc;
end


function S = SwI(lamda,tp,xi,xf)%计算积分值
syms t w;
k = zeros(1,2);
k(1) = lamda;k(2) = (xf-xi)/tp-lamda;
dxitat = k(1)*(1-cos(2*pi*1*t/tp))+k(2)*(1-cos(2*pi*2*t/tp));%dΘ/dt
f = (dxitat)*exp(-1i*w*t);
Sw = (abs(int(f,t,0,tp)))^2;%PSD
Sw = matlabFunction(Sw);%转化为函数
wmin = 2.3*2*pi/tp;wmax = +inf;
S = integral(Sw,wmin,wmax);%PSD积分
end
% function S = SwI(lamda,w0,xi,xf)
% syms t w tp;
% xitat = lamda*(1-cos(2*pi*1*t/tp))+((xf-xi)/tp-lamda)*(1-cos(2*pi*2*t/tp));
% f = (xitat)*exp(-1i*w*t);
% Sw = (abs(int(f,t,0,tp)))^2;
% Sw = matlabFunction(Sw);
% Sw = @(tp)Sw(tp,w0);
% tpmin = 2.3*2*pi/w0;tpmax = +inf;
% S = integral(Sw,tpmin,tpmax);
% end


function PlotPSD(lamda,tp,xi,xf)
syms t w;
k = zeros(1,2);
k(1) = lamda;k(2) = (xf-xi)/tp-lamda;
dxitat = k(1)*(1-cos(2*pi*1*t/tp))+k(2)*(1-cos(2*pi*2*t/tp));%dΘ/dt
xitat = xi+int(dxitat,t);%Θ
f = dxitat*exp(-1i*w*t);
Sw = (abs(int(f,t,0,tp)))^2;%PSD

dxitat = matlabFunction(dxitat);
xitat = matlabFunction(xitat);
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
