% 计算Xmon中几何电容
path = 'Cq2.s1p';


Y = yparameters(path);

f = Y.Frequencies;
Y11 = squeeze(Y.Parameters(1,1,:));
Cqlist = imag(Y11)/2/pi./f;
% plot(f,Cqlist);
Cq = imag(Y11(1))/2/pi./f(1);
disp(['Cq=',num2str(Cq)]);
