function optx = OptWFArF(tp,xi,xf)
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


function S = SwI(lamda,tp,xi,xf)
syms t w;
k = zeros(1,2);
k(1) = lamda;k(2) = (xf-xi)/tp-lamda;
dxitatao = k(1)*(1-cos(2*pi*1*t/tp))+k(2)*(1-cos(2*pi*2*t/tp));
f = (dxitatao)*exp(-1i*w*t);%以t,w为自变量
Sw = (abs(int(f,t,0,tp)))^2;%以w为自变量
Sw = matlabFunction(Sw);
wmin = 2.3*2*pi/tp;wmax = +inf;
S = integral(Sw,wmin,wmax);
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
syms t q wx ;
k = zeros(1,2);
k(1) = lamda;k(2) = (xf-xi)/tp-lamda;
dxitatao = k(1)*(1-cos(2*pi*1*q/tp))+k(2)*(1-cos(2*pi*2*q/tp));
xitatao = xi+int(dxitatao,q);
f = dxitatao*exp(-1i*wx*q);
Sw = (abs(int(f,q,0,tp)))^2;
sinxitatao = sin(xitatao);

dxitatao = matlabFunction(dxitatao);%函数
xitatao = matlabFunction(xitatao);
sinxitatao = matlabFunction(sinxitatao);
Sw = matlabFunction(Sw);

tao = 0:tp/100:tp;%数列
st = length(tao);
Lttao = zeros(1,st);
for i = 1:st
    Lttao(i) = integral(sinxitatao,0,tao(i));
end    
Lxitatao = xitatao(t);
Lxitat = interp1(Lttao,Lxitatao,tao);
Ldxitat = diff(Lxitat);



subplot(2,2,1);
tn = t(1:end-1);
plot(tn/tp,Ldxitat);hold on;
xlabel('t/tp');ylabel('d\Theta/dt');

subplot(2,2,2);
t = 0:tp/100:tp;
plot(t/tp,Lxitatao);hold on;
xlabel('t/tp');ylabel('\Theta');

subplot(2,2,3);
t = 0:tp/100:tp;
plot(t/tp,1./tan(Lxitat));hold on;
xlabel('t/tp');ylabel('H_{z}/H_{x}');

subplot(2,2,4);
w = 0:6*2*pi/tp/400:6*2*pi/tp;
plot(w*tp/2/pi,log10(Sw(w)));hold on;
set(gca,'YLim',[-7 0]);
xlabel('t_{p}\omega_{x}/2\pi');ylabel('S(\omega_{0})');
end