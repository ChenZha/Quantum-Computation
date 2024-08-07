%利用拟合的方式计算f0，Qi，Qc
% function Q = QFit(path )
% 先利用Qcal计算，将计算结果作为Q0，然后进行拟合 
% 两种方式，一种nlinfit，一种fmincon 
%% 读取数据

 
% if (nargin<1)
        path = 'RO_1.s2p';
% end

ckt=read(rfdata.data, path);
f = reshape(ckt.Freq,1,length(ckt.Freq));
S = ckt.S_Parameters;
S_21 = reshape(S(2,1,:),1,length(S(2,1,:)));
% figure();plot(f,20*log10(abs(S_21)));xlabel('Freq/GHz');ylabel('Mag(dB)');
% figure();plot(f,angle(S_21));xlabel('Freq/GHz');ylabel('Ang(dB)');
S_21 = 1./S_21-1;%求S21^(-1)-1
%%
% figure();plot(f,20*log10(abs(S_21)));xlabel('Freq/GHz');ylabel('Mag(dB)');
figure();plot(S_21,'b');xlabel('Re(S_{21}^{-1})');ylabel('Im(S_{21}^{-1})');hold on;

% nlinfit
Q0 = [10e+05,1e+04,0.01,6.662e+09];
modulefun = @S21;
Q = nlinfit(f,S_21,modulefun,Q0);



% fmincon
% modulefun = @(b)deviation(b,S_21,f);
% A = [];b = [];Aeq = [];beq = [];
% lb = [10000,1000,0,6.7e+9];
% ub = [2000000,200000,pi/2,6.8e+9];
% 
% Q0 = [9e+05,1e+04,0.01,6.78e+09];
% 
% Q,val = fminsearch(modulefun,Q0);
% disp(val)


s = S21(Q,f(1:2:end));
plot(s,'r*');
disp(['Qi=',num2str(Q(1))]);
disp(['Qc=',num2str(Q(2))]);
disp(['phi=',num2str(Q(3))]);
disp(['f0=',num2str(Q(4))]);
% end


function p = S21(b,f)
Qi =b(1);Qc = b(2);phi = b(3);f0 = b(4);
p = Qi/Qc*exp(1i*phi)./(1+2*1i*Qi*(f-f0)/f0);
end


function e = deviation(b,S_21,f)
error = S_21-S21(b,f);
e = sum(abs(error));
end