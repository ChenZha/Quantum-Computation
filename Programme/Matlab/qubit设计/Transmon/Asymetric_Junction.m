%% 
% 计算不同a下的电阻波动导致频率波动，以及调节磁通可以达到的频率范围

% C= 86e-15;
% R = 7800;
% delta_R = 800;
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
R = 7800;
a = 3;
R2 = R*(1+a)/a;
R1 = a*R2;
disp(['R1=',num2str(R1)]);
disp(['R2=',num2str(R2)]);


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
