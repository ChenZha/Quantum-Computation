%% 
% 计算不同a下的电阻波动导致频率波动，以及调节磁通可以达到的频率范围

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
% 给定并联电阻R，以及比例a，求出两个电阻R1 = a*R2
R = 7200;
a = 4;
R2 = R*(1+a)/a;
R1 = a*R2;
disp(['R1=',num2str(R1)]);
disp(['R2=',num2str(R2)]);

%%
% 计算不同比例a下的dephasing rateΓφ和T2随施加磁通的变化,以及dephasing rate随斜率变化的关系
% hbar=1.054560652926899e-034;h = hbar*2*pi;e = 1.60217662e-19;phi0 = h/2/e;
% C= 86e-15;
% R = 7400;
% a = 3;
% 
% A = (1.4*10^(-6))^2;% 磁通噪音强度
% backround = 0.05;% 背底(flux-independent noise)导致的dephasing rate
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
% % figure();plot(f,rate);title(['dephasing rate,a=',num2str(a)]);xlabel('\Phi/\Phi0');ylabel('\Gamma(\mus^{-1})')% dephasing rate 随flux 变化
% figure();plot(f,T2);title(['T2,a=',num2str(a)]);xlabel('\Phi/\Phi0');ylabel('T2(\mus)')% T2随flux变化
% % figure();plot(Df,rate,'*');title(['dephasing rate,a=',num2str(a)]);xlabel('D_\Phi(GHz/Phi_0)');ylabel('\Gamma(\mus^{-1})')% dephasing rate 随slope 变化
% figure();plot(f,freq);title(['Freq,a=',num2str(a)]);xlabel('\Phi/\Phi0');ylabel('freq(GHz)')% T2随flux变化


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
% 非对称结
d = (a-1)/(1+a);
H = 4*Ec.*diag([-N:N].^2)-Ej.*cos(pi.*f)*sqrt(1+d.^2.*tan(pi.*f).^2).*(diag(ones(1,2*N),1)+diag(ones(1,2*N),-1))./2;
Ex = eig(H);
end

function [fluc,scope] = gap_fluc_scope(C,R,delta_R,a)
%%设计值为C,R,R的波动为delta_R,Ej比例为a;求出电阻波动导致的频率波动范围fluc，以及在频率最高点(电阻最低点)调节频率，频率能调节的范围scope
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
% C,R,a参数下，不同f下的斜率
[Ex,~] = E_asym(C_E(C),R_E(R),a,f,50);
w1 = Ex(2)-Ex(1);
[Ex,~] = E_asym(C_E(C),R_E(R),a,f+0.00001,50);
w2 = Ex(2)-Ex(1);
slope = (w2-w1)/0.00001;
end
function rate = dephsing_rate(C,R,a,A,f,backround)
% C,R,a,A,backround参数下计算出的不同偏置f下的dephasing rate
hbar=1.054560652926899e-034;h = hbar*2*pi;e = 1.60217662e-19;phi0 = h/2/e;
Df = abs(freq_f_slope(C,R,a,f));
flux_noise = 2*pi*sqrt(A*abs(log(2*pi*1*10e-6)));
rate = (flux_noise.*Df)*10^3+backround;%+0.03*rand();
end

