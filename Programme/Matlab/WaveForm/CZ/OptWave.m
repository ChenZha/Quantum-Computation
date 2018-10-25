function opt = OptWave(thi,thf)
tic;
f = @(lamda)SwI(lamda,thi,thf);
% options = optimset('Display','iter','PlotFcns',@optimplotfval);
lamda0 = [0.04,-0.18];
[x,val] = fminsearch(f,lamda0);
% optx = [x,(xf-xi)/2-x(1)];
% PlotPSD(x,tp,xi,xf);
toc;
end

function S = SwI(lamda,thi,thf)
resolution = 1024;
k = zeros(1,3);
k(1) = 1-lamda(1);k(2) = lamda(2);k(3) = lamda(1);
ti=linspace(0,1,resolution);
han2 = k(1)*(1-cos(2*pi*ti))+k(2)*(1-cos(4*pi*ti))+k(3)*(1-cos(6*pi*ti));
thsl=thi+(thf-thi)*han2/max(han2);

dthsh = diff(thsl)./diff(ti);
CalP = @(w) CalPs(dthsh,ti,w);
CalP(1:10)
% wmin = 3.2*2*pi;wmax = +inf;
% S = integral(CalP,wmin,wmax);%PSD»ý·Ö

end
function P = CalPs(dthsh,ti,w)
Int = sum(dthsh.*exp(-1i*w.*ti(1:end-1)).*ti(2));
P = (abs(Int)).^2;
end