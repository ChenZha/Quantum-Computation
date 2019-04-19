%计算Xmon中耦合电容


path = 'q-r2.s2p';


Y = yparameters(path);

f = Y.Frequencies;
Y21 = squeeze(Y.Parameters(2,1,:));
Cclist = -imag(Y21)/2/pi./f;
% plot(f,Cclist);
Cc = -imag(Y21(1))/2/pi./f(1);
disp(['Cc=',num2str(Cc)]);


%% 计算比特间耦合强度
fq1 = 4.884e9;
fq2 = 4.751e9;
Cq1 = 102.3e-15;
Cq2 = 108.9e-15;
Cc = 0.498e-15;

coupling = 0.5*Cc/sqrt((Cq1+Cc)*(Cq2+Cc))*sqrt(fq1*fq2)/10^6;
disp(['g=',num2str(coupling)])