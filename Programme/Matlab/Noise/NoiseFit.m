function [beta,t,p] = NoiseFit(path)
%%
fileID = fopen(path);
input = textscan(fileID,'%f %f');
t = input{1};
p = power(10,input{2});%输入的是取完log10的结果，要进行10^x的变换
fclose(fileID);
plot(t,p);hold on;
plot(t,exp(2.2479*(exp(-t/17.8245)-1)).*exp(-t/44.1085));hold on;
%%
beta0 = [2.0,20,50];
modulefun = @noise;
beta = nlinfit(t,p,modulefun,beta0);
end
function p = noise(b,t)
nqp =b(1);T1qp = b(2);T1r = b(3);
p = exp(nqp*(exp(-t/T1qp)-1)).*exp(-t/T1r);
end