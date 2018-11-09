%% 
% ���㲻ͬa�µĵ��貨������Ƶ�ʲ������Լ����ڴ�ͨ���Դﵽ��Ƶ�ʷ�Χ

% C= 86e-15;
% R = 7400;
% delta_R = 370;


% 
% a_list = 1:0.5:15;
% fluc_list = [];
% scope_list = [];
% gap_list = [];
% 
% [Ex,~] = E_asym(C_E(C),R_E(R-delta_R),1,0,50);
% w_max_f = Ex(2)-Ex(1);
% [Ex,~] = E_asym(C_E(C),R_E(R-delta_R),1,0.5,50);
% w_min_f = Ex(2)-Ex(1);
% scope = w_max_f-w_min_f;
% 
% for a = a_list
%     [fluc,scope] = gap_fluc_scope(C,R,delta_R,a);
%     fluc_list(end+1) = fluc;
%     scope_list(end+1) = scope;
%     gap_list(end+1) = fluc-scope;
% end
%     figure();
%     plot(a_list,fluc_list,'*',a_list,scope_list,'+',a_list,gap_list,'o');hold on;
%     legend('fluctuation' , 'scope' , 'gap');
%%
% ������������R���Լ�����a�������������R1 = a*R2
R = 7200;
a = 4;
R2 = R*(1+a)/a;
R1 = a*R2;
disp(['R1=',num2str(R1)]);
disp(['R2=',num2str(R2)]);

%%
% ���㲻ͬ����a�µ�dephasing rate���պ�T2��ʩ�Ӵ�ͨ�ı仯,�Լ�dephasing rate��б�ʱ仯�Ĺ�ϵ
% hbar=1.054560652926899e-034;h = hbar*2*pi;e = 1.60217662e-19;phi0 = h/2/e;
% C= 86e-15;
% R = 7400;
% a = 3;
% 
% A = (1.4*10^(-6))^2;% ��ͨ����ǿ��
% backround = 0.05;% ����(flux-independent noise)���µ�dephasing rate
% 
% 
% f = -0.8:0.001:0.8;
% rate = [];
% T2 =  [];
% Df = [];
% freq = [];
% for i = f
% temp = dephsing_rate(C,R,a,A,i,backround);
% rate(end+1) = temp;
% T2(end+1) = 1/temp;
% 
% Df(end+1) = freq_f_slope(C,R,a,i);
% [Ex,~] = E_asym(C_E(C),R_E(R),a,i,50);
% freq(end+1) = Ex(2)-Ex(1);
% end
% % figure();plot(f,rate);title(['dephasing rate,a=',num2str(a)]);xlabel('\Phi/\Phi0');ylabel('\Gamma(\mus^{-1})')% dephasing rate ��flux �仯
% figure();plot(f,T2);title(['T2,a=',num2str(a)]);xlabel('\Phi/\Phi0');ylabel('T2(\mus)')% T2��flux�仯
% % figure();plot(Df,rate,'*');title(['dephasing rate,a=',num2str(a)]);xlabel('D_\Phi(GHz/Phi_0)');ylabel('\Gamma(\mus^{-1})')% dephasing rate ��slope �仯
% figure();plot(f,freq);title(['Freq,a=',num2str(a)]);xlabel('\Phi/\Phi0');ylabel('freq(GHz)')% T2��flux�仯


%%
function Ej = R_E(R)
hbar=1.054560652926899e-034;
h = hbar*2*pi;
e = 1.60217662e-19; 
I0 = 280e-9;
R0 = 1000;
I = I0*R0./R;
Ej = I*hbar/2/e/h/10^9;
end
function Ec = C_E(C)
hbar=1.054560652926899e-034;
h = hbar*2*pi;
e = 1.60217662e-19; 
Ec = e^2./2./C/h/10^9;
end
function [Ex,H] = E_sym(Ec,Ej,f,N)
H = 4*Ec.*diag([-N:N].^2)-Ej.*cos(pi*f).*(diag(ones(1,2*N),1)+diag(ones(1,2*N),-1))./2;
Ex = eig(H);
end

function [Ex,H] = E_asym(Ec,Ej,a,f,N)
% �ǶԳƽ�
d = (a-1)/(1+a);
H = 4*Ec.*diag([-N:N].^2)-Ej.*cos(pi.*f)*sqrt(1+d.^2.*tan(pi.*f).^2).*(diag(ones(1,2*N),1)+diag(ones(1,2*N),-1))./2;
Ex = eig(H);
end

function [fluc,scope] = gap_fluc_scope(C,R,delta_R,a)
%%���ֵΪC,R,R�Ĳ���Ϊdelta_R,Ej����Ϊa;������貨�����µ�Ƶ�ʲ�����Χfluc���Լ���Ƶ����ߵ�(������͵�)����Ƶ�ʣ�Ƶ���ܵ��ڵķ�Χscope
[Ex,~] = E_asym(C_E(C),R_E(R+delta_R),a,0,50);
w_min_R = Ex(2)-Ex(1);

[Ex,~] = E_asym(C_E(C),R_E(R-delta_R),a,0,50);
w_max_R = Ex(2)-Ex(1);
fluc = w_max_R-w_min_R;

[Ex,~] = E_asym(C_E(C),R_E(R-delta_R),a,0,50);
w_max_f = Ex(2)-Ex(1);
[Ex,~] = E_asym(C_E(C),R_E(R-delta_R),a,0.5,50);
w_min_f = Ex(2)-Ex(1);
scope = w_max_f-w_min_f;
end
function slope = freq_f_slope(C,R,a,f)
% C,R,a�����£���ͬf�µ�б��
[Ex,~] = E_asym(C_E(C),R_E(R),a,f,50);
w1 = Ex(2)-Ex(1);
[Ex,~] = E_asym(C_E(C),R_E(R),a,f+0.00001,50);
w2 = Ex(2)-Ex(1);
slope = (w2-w1)/0.00001;
end
function rate = dephsing_rate(C,R,a,A,f,backround)
% C,R,a,A,backround�����¼�����Ĳ�ͬƫ��f�µ�dephasing rate
hbar=1.054560652926899e-034;h = hbar*2*pi;e = 1.60217662e-19;phi0 = h/2/e;
Df = abs(freq_f_slope(C,R,a,f));
flux_noise = 2*pi*sqrt(A*abs(log(2*pi*1*10e-6)));
rate = (flux_noise.*Df)*10^3+backround;%+0.03*rand();
end

