% 计算gmon中coupler的自感
path = 'Lc.s1p';


Y = yparameters(path);

f = Y.Frequencies;
Y11 = squeeze(Y.Parameters(1,1,:));
Llist = imag(1./Y11)/2/pi./f;
plot(f,Llist);
Lq = imag(1./Y11(end))/2/pi./f(end);
disp(['L=',num2str(Lq)]);