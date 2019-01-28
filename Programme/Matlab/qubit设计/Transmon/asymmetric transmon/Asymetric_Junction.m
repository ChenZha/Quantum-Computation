%% 
func = CalFun();
%%
C = (89.19+9.8)*10^(-15);
R= 8000;
[Ex,~] = func .E_asym(func.C_E(C),func.R_E(R),8,0,50);
w_max_f = Ex(2)-Ex(1);
disp(['freq=',num2str(w_max_f)]);
%%
% ���㲻ͬa�µĵ��貨������Ƶ�ʲ������Լ����ڴ�ͨ���Դﵽ��Ƶ�ʷ�Χ

C= 90e-15;
R = 7300;
delta_R = 0.15*R;



a_list = 1:0.5:15;
fluc_list = [];
scope_list = [];
gap_list = [];

% [Ex,~] = func.E_asym(func.C_E(C),func.R_E(R-delta_R),1,0,50);
% w_max_f = Ex(2)-Ex(1);
% [Ex,~] = func.E_asym(func.C_E(C),func.R_E(R-delta_R),1,0.5,50);
% w_min_f = Ex(2)-Ex(1);
% scope = w_max_f-w_min_f;

for a = a_list
    [fluc,scope] = func.gap_fluc_scope(C,R,delta_R,a);
    fluc_list(end+1) = fluc;
    scope_list(end+1) = scope;
    gap_list(end+1) = fluc-scope;
end
    figure();
    plot(a_list,fluc_list,'*',a_list,scope_list,'+',a_list,gap_list,'o');hold on;
    legend('fluctuation' , 'scope' , 'gap');
%%
% ������������R���Լ�����a�������������R1 = a*R2
R = 7600;
a = 5;
R2 = R*(1+a)/a;
R1 = a*R2;
disp(['R1=',num2str(R1),',R2=',num2str(R2),',a=',num2str(a)]);

%%
% ��ĳ��a��,��ͬƵ����,б�ʵı仯
hbar=1.054560652926899e-034;h = hbar*2*pi;e = 1.60217662e-19;phi0 = h/2/e;
C= 86e-15;
R = 7400;

alpha = [1,3,5,7];
h = figure();ax = axes(h);
for a = alpha
    freq = [];
    slope = [];
    f = 0:0.005:0.25;
    for i = f
        [Ex,~] = func.E_asym(func.C_E(C),func.R_E(R),a,i,50);
        freq(end+1) = Ex(2)-Ex(1);
        slope(end+1) = func.freq_f_slope(C,R,a,i);
    end
    plot(ax,freq,slope,'DisplayName',num2str(a));hold on;
    
end
legend('show');
xlabel('Frequency');ylabel('slope')
%%
% ���㲻ͬ����a�µ�dephasing rate���պ�T2��ʩ�Ӵ�ͨ�ı仯,�Լ�dephasing rate��б�ʱ仯�Ĺ�ϵ
hbar=1.054560652926899e-034;h = hbar*2*pi;e = 1.60217662e-19;phi0 = h/2/e;
C= 86e-15;
R = 7400;
a = 6;

A = (1.4*10^(-6))^2;% ��ͨ����ǿ��
backround = 0.05;% ����(flux-independent noise)���µ�dephasing rate


f = -0.8:0.001:0.8;
rate = [];
T2 =  [];
Df = [];
freq = [];
for i = f
temp = func.dephsing_rate(C,R,a,A,i,backround);
rate(end+1) = temp;
T2(end+1) = 1/temp;

Df(end+1) = func.freq_f_slope(C,R,a,i);
[Ex,~] = func.E_asym(func.C_E(C),func.R_E(R),a,i,50);
freq(end+1) = Ex(2)-Ex(1);
end
% figure();plot(f,rate);title(['dephasing rate,a=',num2str(a)]);xlabel('\Phi/\Phi0');ylabel('\Gamma(\mus^{-1})')% dephasing rate ��flux �仯
figure();plot(f,T2);title(['T2,a=',num2str(a)]);xlabel('\Phi/\Phi0');ylabel('T2(\mus)')% T2��flux�仯
% figure();plot(Df,rate,'*');title(['dephasing rate,a=',num2str(a)]);xlabel('D_\Phi(GHz/Phi_0)');ylabel('\Gamma(\mus^{-1})')% dephasing rate ��slope �仯
figure();plot(f,freq);title(['Freq,a=',num2str(a)]);xlabel('\Phi/\Phi0');ylabel('freq(GHz)')% freq��flux�仯




