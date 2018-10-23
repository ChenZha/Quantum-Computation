C= 86e-15;
R = 7800;

Rc = 0.2*R:1:1.8*R;
fc = []; 
for i = Rc
    [Ex,~] = E(C_E(C),R_E(i),0,50);
    fc(end+1) = Ex(2)-Ex(1);
end
figure();plot(Rc-R , fc*R)
    

% [fmin,fmax,fex] = f_min_max(C,R);



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
function [Ex,H] = E(Ec,Ej,f,N)

H = 4*Ec.*diag([-N:N].^2)-Ej/2.*cos(pi*f).*(diag(ones(1,2*N),1)+diag(ones(1,2*N),-1));
Ex = eig(H);

end
function [fmin,fmax,fex] = f_min_max(C,R)

end
