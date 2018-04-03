freq = [4.43734 , 4.43911 , 4.43789 , 4.42453 , 4.41232 , 4.39646 , 4.37685 , 4.35346 , 4.35394 , 4.32687 , 4.29589 , 4.261 , 4.22234 , 4.17931 , 4.13242 , 4.08083];
label = [443734 , 443911 , 443789 , 442453 , 441232 , 439646 , 437685 , 435346 , 435394 , 432687 , 429589 , 4261 , 422234 ,  417931 , 413242 , 408083];
T_ini = [13,14,18.8,8.4,6.56,5.85,4.76,3.59,3.84,3.48,2.98,2.94,2.61,2.16,1.845,1.61];
file_path = '.\T2_f\';
T2 = zeros(1,length(freq));% T1φ
Tf = zeros(1,length(freq));% T2φ
err = zeros(1,length(freq));
%% 导入数据进行拟合
for i = 1:length(freq)
    data_1 = load(strcat(file_path,'q2_',num2str(label(i)),'_1_.mat'));
    data_2 = load(strcat(file_path,'q2_',num2str(label(i)),'_2_.mat'));
    beta = [T_ini(i)*2000 , (T_ini(i)+4)*2000];
    [~,t2_expect_1,tf_expect_1,~ , val_1]=fit_ramsey_plus(data_1.SweepVals{1,2}{1,1} , data_1.Data{1,1} , beta);
    [~,t2_expect_2,tf_expect_2,~ , val_2]=fit_ramsey_plus(data_2.SweepVals{1,2}{1,1}  , data_2.Data{1,1} , beta);
    T2(i) = (t2_expect_1+t2_expect_2)/2;
    Tf(i) = (tf_expect_1+tf_expect_2)/2;
    err(i) = (val_1+val_2)/2;
    
end
%% 处理实验数据
loc1 = find(T2>50);
loc2 = find(Tf>50);
location = sort([loc1,loc2]);
T2(location) = [];
Tf(location) = [];
err(location) = [];
freq(location) = [];
delta = max(freq)+0.001-freq;
figure();plot(delta , err);title('error');xlabel('frequency(GHz)');ylabel('error');



%% 对比特的Ej，Ec进行拟合
anhamc = -0.2;
E01 = 4.4379;
func = @(x) deviation(x(1),x(2),anhamc,E01);
x0 = [0.2 , 20];
lb = [0.12,12];
ub = [0.3,25];
A = [];
b = [];
Aeq = [];
beq = [];
nonlcon = [];
options = optimset('Display','off');
[x,val] = fmincon(func,x0,A,b,Aeq,beq,lb,ub,nonlcon,options);

OptEc = x(1);
OptEj = x(2);



%% 参数
hbar=1.054560652926899e-034;
h = hbar*2*pi;
phi0 = 2.067833636e-15;
fc = OptEc;
fj = OptEj;
%% 拟合




figure();plot(delta , T2);title(['T1φ,']);%xlabel('frequency(GHz)');ylabel('T1φ(us)');hold on;plot(delta,func(beta,delta));

func = @(b,x) T2fit(b,x,fj,fc);
% figure();plot(delta,func([3,1, 0],delta));
[beta,R,J,CovB,MSE,ErrorModelInfo] = nlinfit(delta,Tf,func,[3,1,0]);
figure();plot(delta , Tf,'*');title(['T2φ,','parameter=',num2str(beta)]);xlabel('frequency(GHz)');ylabel('T2φ(us)');hold on;plot(delta,func(beta,delta));

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
%     T2 = b(1)./(sensitivity(fj,fc,phi)).^b(2)+b(3);
    T2 = b(1)*exp(-b(2)*delta)+b(3);
end

function T1 = T1fit(b,delta,fj,fc)
%拟合Tφ1函数
    f = frequency(fj,fc,0);
    phi = freq2phi(fj,fc , f-delta);
    T1 = b(1)./(sensitivity(fj,fc,phi))+b(2);
end

function [Ex,H] = E(Ec,Ej,f,N)
%矩阵方法计算能级
H = 4*Ec.*diag([-N:N].^2)-Ej/2.*cos(pi*f).*(diag(ones(1,2*N),1)+diag(ones(1,2*N),-1));
Ex = eig(H);

end

function delta = deviation(Ec,Ej,anhamc,E01c)
[Ex,~] = E(Ec,Ej,0,60);
E01 = Ex(2)-Ex(1);
E12 = Ex(3)-Ex(2);
anham = E12-E01;%负数

delta = abs(anham-anhamc)+ abs(E01-E01c);
end
