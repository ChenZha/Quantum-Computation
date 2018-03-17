% 计算gmon中coupler的互感
path = 'Lm_v4.s2p';


Z = zparameters(path);

f = Z.Frequencies;
Z21 = squeeze(Z.Parameters(2,1,:));
Mlist = -imag(Z21)/2/pi./f;
plot(f,Mlist);
Mc = imag(-Z21(end))/2/pi./f(end);
disp(['M=',num2str(Mc)]);