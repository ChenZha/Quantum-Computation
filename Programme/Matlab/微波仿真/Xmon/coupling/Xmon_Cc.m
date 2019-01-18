%计算Xmon中耦合电容


path = 'Cc_Q3.s2p';


Y = yparameters(path);

f = Y.Frequencies;
Y21 = squeeze(Y.Parameters(2,1,:));
Cclist = -imag(Y21)/2/pi./f;
% plot(f,Cclist);
Cc = -imag(Y21(1))/2/pi./f(1);
disp(['Cc=',num2str(Cc)]);


%% 计算比特间耦合强度
fq1 = 4.94e9;
fq2 = 4.94e9;
Cq1 = 86e-15;
Cq2 = 86e-15;
Cc = 0.4e-15;

coupling = 0.5*Cc/sqrt((Cq1+Cc)*(Cq2+Cc))*sqrt(fq1*fq2)/10^6;
disp(['g=',num2str(coupling)])