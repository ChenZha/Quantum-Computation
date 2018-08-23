function [ c,dc ] = qfit1( freq,s21, plotfit)
%QFIT1 Summary of this function goes here
%   Detailed explanation goes here

c0 = c0estimate(freq,s21);
f00 = c0(1);
Qi0 = c0(2);
% Qi0 = 2e4;
Qc0 = c0(3);
% Qc0 = 0.6e4;
phi0 = c0(4);
% phi0 = 10;


Q0 = Qi0*Qc0/(Qi0+Qc0);
df =f00/Q0;

lfreq = f00-df*10;
lQi = 100;
lQc = 100;
lphi = phi0-pi/4;
lb = [lfreq,lQi,lQc,lphi];
    
ufreq = f00+df*10;
uQi = 1e8;
uQc = 1e8;
uphi = phi0+pi/4;
ub = [ufreq,uQi,uQc,uphi];

[istart,iend] = centerdata(freq,f00,df);
fun = @(c)fittingfun(c,freq(istart:iend),s21(istart:iend));
options = optimoptions(@lsqnonlin,'MaxFunEvals',1e9);
[c,resnorm,residual,exitflag,output,lamda,jacobian] = ...
    lsqnonlin(fun,c0,lb,ub,options);
ci = nlparci(c,residual,'jacobian',jacobian);
dc = (ci(:,2)-ci(:,1))./2;

if plotfit
    plotfittingdata(freq,s21,c)
end
end

function [] = plotfittingdata(freq,s21,c)
fitteds21 = 1./invs21( c,freq );

figure();plot(real(1./s21),imag(1./s21),'o');
hold on
plot(real(1./fitteds21),imag(1./fitteds21),'LineWidth',2.25,'color','r');
title('Smith of S21^{-1}');
xlabel('Re[S_{21}^{-1}]'); ylabel('Im[S_{21}^{-1}]');

figure();
plot(freq*1e-9,log10(abs(s21))*20,'o');
hold on
plot(freq*1e-9,log10(abs(fitteds21))*20','LineWidth',2.25,'color','r');
title('Amplitude of S21');
xlabel('Frequency(GHz)');
ylabel('S21(dB)');

figure();
plot(freq*1e-9,angle(s21),'o');
hold on
plot(freq*1e-9,angle(fitteds21)','LineWidth',2.25,'color','r');
title('Phase of S21');
xlabel('Frequency(GHz)');
ylabel('\angleS21(dB)');
end

function [istart,iend] = centerdata(freq,f0,df)
fstart = f0-df*20;
fstop = f0+df*20;
nfreq = length(freq);
if freq(1)>fstart
    istart = 1;
else
    for ii = 1:nfreq
        if freq(ii)>=fstart
            istart = ii-1;
            istart = max(istart,1);
        end
    end
end

if freq(end)<fstop
    iend = nfreq;
else
    for ii = istart:nfreq
        if freq(ii)>=fstop
            iend = ii;
        end
    end
end
end

function [ c0 ] = c0estimate( freq,s21 )
invs21 = 1./s21;
[M,I] = min(abs(s21));
f0 = freq(I);

phi = angle(invs21(I)-1);

y1 = abs(1-s21).^2;
y_1 = abs(invs21-1).^2;

[index1,index2] = search3db(y1);
if index1>0 && index2>0
    Qc = (freq(index2)+freq(index1))/(freq(index2)-freq(index1))/4;
else
    Qc = (freq(end)-freq(1))/10/f0;
end

[index1,index2] = search3db(y_1);
if index1>0 && index2>0
    Qi = (freq(index2)+freq(index1))/(freq(index2)-freq(index1))/4;
else
    Qi = (freq(end)-freq(1))/10;
end

c0 = [f0,Qi,Qc,phi];
end

function [index1,index2] = search3db(y)
y = y/max(y);
da = 0.1;
half = 0.2;
a = half+da;
n = length(y);
index1 = 0;
index2 = 0;
for ii = 1:n
    if y(ii)>half
        index1 = ii;
        break;
    end
end
if index1>0
    tempindex = 0;
    for ii = index1+1:n
        if y(ii)>a
            tempindex = ii;
            break;
        end
    end
    
    if tempindex>0
        for ii = tempindex+1:n
            if y(ii)<half
                index2 = ii;
                break;
            end
        end
    end
end
end

function [f] = fittingfun(c,freq,s21)
y = [real(invs21(c,freq)) imag(invs21(c,freq))];
y0 = [real(1./s21) imag(1./s21)];
f = y-y0;
end

function [ invs21 ] = invs21( c,freq )
%INVERSES21 Summary of this function goes here
%   Detailed explanation goes here
f0 = c(1);
Qi = c(2);
Qc = c(3);
phi = c(4);
dx = (freq-f0)/f0;
invs21 = 1+exp(1i*phi)*Qi/Qc./(1+2*1i*Qi*dx);
end
