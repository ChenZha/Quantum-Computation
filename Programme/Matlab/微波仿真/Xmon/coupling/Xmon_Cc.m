%计算Xmon中耦合电容


path = 'Xmon_Cc.s2p';


Y = yparameters(path);

f = Y.Frequencies;
Y21 = squeeze(Y.Parameters(2,1,:));

Cc = mean(-imag(Y21)/2/pi./f);
disp(Cc);

