%计算Xmon中耦合电容


path = 'Xmon_Cc.s2p';


Y = yparameters(path);

f = Y.Frequencies;
Y21 = squeeze(Y.Parameters(2,1,:));
Cclist = -imag(Y21)/2/pi./f;
% plot(f,Cclist);
Cc = -imag(Y21(1))/2/pi./f(1);
disp(['Cc=',num2str(Cc)]);

