function func = CalFun()
func.R_E = @R_E;
func.C_E = @C_E;
func.E_sym = @E_sym;
func.E_asym = @E_asym;
func.gap_fluc_scope = @gap_fluc_scope;
func.freq_f_slope = @freq_f_slope;
func.dephsing_rate = @dephsing_rate;
end

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

[Ex,~] = E_asym(C_E(C),R_E(R),a,0,50);
w_max_f = Ex(2)-Ex(1);
[Ex,~] = E_asym(C_E(C),R_E(R),a,0.5,50);
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