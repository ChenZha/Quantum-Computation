% Ec = [0.31499,0.29211,0.375990,0.37603,0.36367];
% Ej = [19.9085,19.9085,19.9085,19.9085,19.9085];
% Ec = [0.2247,0.2255];
% EJ = [22.0296,22.5773];
Ec = 0.242130425754096;
Ej = 17.383923029086322;
f = 0;
N = 180;
[Ex,H] = E(Ec,Ej,f,N);
E01 = Ex(2)-Ex(1);
E12 = Ex(3)-Ex(2);
anham = E12-E01;
disp(E01);
disp(anham);
disp(sqrt(8*Ec*Ej)-Ec);
disp(Ec);

function [Ex,H] = E(Ec,Ej,f,N)
%%通过解矩阵得到Xmon的能级
H = 4*Ec.*diag([-N:N].^2)-Ej./2.*cos(pi*f).*(diag(ones(1,2*N),1)+diag(ones(1,2*N),-1));
Ex = eig(H);

end