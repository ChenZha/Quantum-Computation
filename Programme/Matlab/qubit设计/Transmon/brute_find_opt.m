M = 501;
N = 501;
Cq = linspace(70e-15,75e-15,M);
R = linspace(7000,7500,N);
Ec = C_E(Cq);Ej = R_E(R);
z = ones(1,M*N);
anhamc = -0.3;
E01c = 6.201;
parfor i = 0:M*N-1
    m = (floor(i/N))+1;
    n = mod(i,N)+1;
    delta = deviation(Ec(m),Ej(n),anhamc,E01c);
%     if delta<0.5e-3
        
        z(i+1) = delta;
%     end
end
z = reshape(z,N,M);

figure();pcolor(Cq,R,z);
colorbar();

mz = min(min(z));
[x,y] = find(z==mz);
disp(mz);
disp(Cq(x));
disp(R(y));

    


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
[Ex,~] = E(Ec,Ej,0,60);
E01 = Ex(2)-Ex(1);
E12 = Ex(3)-Ex(2);
anham = E12-E01;

delta = abs(anham-anhamc)%+ abs(E01-E01c);
end