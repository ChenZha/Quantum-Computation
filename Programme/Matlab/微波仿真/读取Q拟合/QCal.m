%利用计算的方法计算腔的f0，Qc，以及qubit的Qi
% function  [f0,Qi,Qc] = QCal(path)
% 
% if (nargin<1)
        path = 'RO_3_V2.s2p';
% end

ckt=read(rfdata.data, path);
f = reshape(ckt.Freq,1,length(ckt.Freq));
S = ckt.S_Parameters;
S_21 = reshape(S(2,1,:),1,length(S(2,1,:)));
%%
S_21= 1./S_21-1;%求S21^(-1)-1
figure();plot(S_21,'b');xlabel('Re(S_{21}^{-1})');ylabel('Im(S_{21}^{-1})');hold on;
%%
[smax,arg] = max(abs(S_21));
f0 = f(arg);
Sl =  S_21(1:arg-1) ; Sr = S_21(arg+1:end);
fl =  f(1:arg-1) ; fr = f(arg+1:end);

[slmin,argl] = min(abs(abs(Sl)-smax/sqrt(2)));
dl = abs(Sl)-smax/sqrt(2);
fl = fl(argl);%左侧的-3dB点

[srmin,argr] = min(abs(abs(Sr)-smax/sqrt(2)));
dr = abs(Sr)-smax/sqrt(2);
fr = fr(argr);%右侧的-3dB点

deltaf = fr-fl;%半高宽
%%
%calulation
Qical = f0/deltaf;
Qccal = Qical/smax;
phi = phase(S_21(arg));
Qcal = [Qical,Qccal,phi,f0];
s = S21(Qcal,f(1:2:end));
plot(s,'gs');hold on;
disp('Calculation')
disp(['Qi=',num2str(Qcal(1))]);
disp(['Qc=',num2str(Qcal(2))]);
disp(['phi=',num2str(Qcal(3))]);
disp(['f0=',num2str(Qcal(4)/10^9)]);
% end

%%
%Fit

modulefun = @S21;
options = optimset('MaxIter',2000);
Qfit = nlinfit(f,S_21,modulefun,Qcal,options);

% fmincon
% modulefun = @(b)deviation(b,S_21,f);
% A = [];b = [];Aeq = [];beq = [];
% lb = [Qcal(1)*0.7,Qcal(2)*0.7,Qcal(3)*0.4,Qcal(4)-20e6];
% ub = [Qcal(1)*1.3,Qcal(2)*1.3,Qcal(3)*1.7,Qcal(4)+20e6];
% options = optimset('MaxFunEvals',2000,'MaxIter',2000);
% [Qfit,val] = fminsearch(modulefun,Qcal,options);
% disp(val)

s = S21(Qfit,f(1:2:end));
plot(s,'r*');hold on;
disp('Fitting')
disp(['Qi=',num2str(Qfit(1))]);
disp(['Qc=',num2str(Qfit(2))]);
disp(['phi=',num2str(Qfit(3))]);
disp(['f0=',num2str(Qfit(4)/10^9)]);



function p = S21(b,f)
Qi =b(1);Qc = b(2);phi = b(3);f0 = b(4);
p = Qi/Qc*exp(1i*phi)./(1+2*1i*Qi*(f-f0)/f0);
end
function e = deviation(b,S_21,f)
error = S_21-S21(b,f);
e = sum(abs(error));
end