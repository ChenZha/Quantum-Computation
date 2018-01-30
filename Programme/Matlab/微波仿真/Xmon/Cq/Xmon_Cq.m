% 计算Xmon中几何电容
path = 'Xmon_Cq.s1p';


Y = yparameters(path);

f = Y.Frequencies;
Y11 = squeeze(Y.Parameters(1,1,:));

Cq = mean(imag(Y11)/2/pi./f);
disp(Cq);