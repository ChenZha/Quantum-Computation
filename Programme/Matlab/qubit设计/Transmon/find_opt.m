function find_opt(Cq1,R1,anhamc,E01c)
%%在Cq1(F)和R1(Ω)附近寻找最符合anhamc和E01c的Cq和R的值
%单位都是GHz
Ec1 = C_E(Cq1);
Ej1 = R_E(R1);

func = @(x) deviation(x(1),x(2),anhamc,E01c);
x0 = [Ec1,Ej1];
lb = [0.999*Ec1,0.5*Ej1];
ub = [1.001*Ec1,1.5*Ej1];
A = [];
b = [];
Aeq = [];
beq = [];
nonlcon = [];
options = optimset('Display','iter');
[x,~] = fmincon(func,x0,A,b,Aeq,beq,lb,ub,nonlcon,options);

OptEc = x(1);
OptEj = x(2);
X = ['OptEc=',num2str(OptEc)];
disp(X);
X = ['OptEj=',num2str(OptEj)];
disp(X);
Cq = E_C(OptEc);
R = E_R(OptEj);
X = ['Cq=',num2str(Cq)];
disp(X);
X = ['R=',num2str(R)];
disp(X);

[Ex,~] = E(OptEc,OptEj,0,60);
E01 = Ex(2)-Ex(1);
E12 = Ex(3)-Ex(2);
anham = E12-E01;

X = ['E01=',num2str(E01)];
disp(X);
X = ['anham=',num2str(anham)];
disp(X);

end


function Ec = C_E(C)
hbar=1.054560652926899e-034;
h = hbar*2*pi;
e = 1.60217662e-19; 
Ec = e^2./2./C/h/10^9;
end
function Cq = E_C(Ec)
hbar=1.054560652926899e-034;
h = hbar*2*pi;
e = 1.60217662e-19; 
Cq = e^2./2./Ec/h/10^9;
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
function R = E_R(Ej)
hbar=1.054560652926899e-034;
h = hbar*2*pi;
e = 1.60217662e-19; 
I0 = 280e-9;
R0 = 1000;

I = Ej*h*10^9*2*e/hbar;
R = I0*R0./I;
end

function [Ex,H] = E(Ec,Ej,f,N)

H = 4*Ec.*diag([-N:N].^2)-Ej/2.*cos(pi*f).*(diag(ones(1,2*N),1)+diag(ones(1,2*N),-1));
Ex = eig(H);

end

function delta = deviation(Ec,Ej,anhamc,E01c)
[Ex,~] = E(Ec,Ej,0,100);
E01 = Ex(2)-Ex(1);
E12 = Ex(3)-Ex(2);
anham = E12-E01;%负数

delta = abs(anham-anhamc)*10+ abs(E01-E01c);
end