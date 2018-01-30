% Ec = [0.31499,0.29211,0.375990,0.37603,0.36367];
% Ej = [19.9085,19.9085,19.9085,19.9085,19.9085];
Ec = 0.4121;
Ej = 12.758842590155100;
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

H = 4*Ec.*diag([-N:N].^2)-Ej./2.*cos(pi*f).*(diag(ones(1,2*N),1)+diag(ones(1,2*N),-1));
Ex = eig(H);

end