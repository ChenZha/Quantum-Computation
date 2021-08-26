%% Kelly数据
A1 = importdata('Tφ1.txt');delta_1 = 5.239e9-A1(:,1)*10^9;T_1 = A1(:,2)*10^(-6);
A2 = importdata('Tφ2.txt');delta_2 = 5.239e9-A2(:,1)*10^9;T_2 = A2(:,2)*10^(-6);
figure();plot(delta_1,T_1);hold on;plot(delta_2,T_2);
%% 参数
hbar=1.054560652926899e-034;
h = hbar*2*pi;
phi0 = 2.067833636e-15;
fc = 0.20491e9;
fj = 18.1288e9;
%%
% f = [4.43734,4.43911,4.4379,4.42453,4.4124,4.39645,4.37686,4.35355,4.354,4.32685,4.29595,4.261056,4.2224,4.17945,4.13265,4.0819]*10^9;
% T_2 = [13,14,18.8,8.4,6.56,5.85,4.76,3.59,3.84,3.48,2.98,2.94,2.61,2.16,1.845,1.61]*10^(-6);
% delta_2 = 4.43912e9-f;

%% 拟合

func = @(b,x) T2fit(b,x,fj,fc);
figure();plot(delta_2,func([3e-6,1e-14 , 0],delta_2));
[beta,R,J,CovB,MSE,ErrorModelInfo] = nlinfit(delta_2,T_2,func,[3e-6,1e-14 , 0]);
figure();plot(delta_2,T_2);hold on;plot(delta_2,func(beta,delta_2));

% func = @(b,x) T1fit(b,x,fj,fc);
% figure();plot(delta_1,func([1,0],delta_1));

function f = frequency(fj,fc,phi)
%计算偏置下频率
    f = sqrt(8.*fj.*fc).*sqrt(cos(pi*phi))-fc;
end

function sen = sensitivity(fj,fc , phi)
%计算偏置下对磁通的敏感度
    sen = abs(sqrt(2.*fj.*fc)*pi.*sin(pi*phi)./sqrt(cos(pi*phi)));
end

function phi = freq2phi(fj,fc , freq)
%通过工作点频率找偏置磁通
    phi = acos(((freq+fc)./sqrt(8.*fj.*fc)).^2)/pi;
end

function T2 = T2fit(b,delta,fj,fc)
%拟合Tφ2函数
    f = frequency(fj,fc,0);
    phi = freq2phi(fj,fc , f-delta);
%     T2 = b(1)./sensitivity(fj,fc,phi)+b(2);
    T2 = b(1)*exp(-b(2)*delta)+b(3);
end

function T1 = T1fit(b,delta,fj,fc)
%拟合Tφ1函数
    f = frequency(fj,fc,0);
    phi = freq2phi(fj,fc , f-delta);
    T1 = b(1)./(sensitivity(fj,fc,phi)).^2+b(2);
end