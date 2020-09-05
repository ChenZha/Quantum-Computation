% 计算Xmon中几何电容
path = 'V6.s10';


Y = yparameters(path);

f = Y.Frequencies;
Y11 = squeeze(Y.Parameters(2,9,:));
Cqlist = imag(Y11)/2/pi./f;
% plot(f,Cqlist);
% Cq = imag(Y11(1))/2/pi./f(1);
Cq = mean(Cqlist);
disp(['Cq=',num2str(Cq)]);
