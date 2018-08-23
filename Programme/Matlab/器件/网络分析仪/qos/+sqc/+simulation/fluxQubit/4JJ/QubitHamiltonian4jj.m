function K=QubitHamiltonian4jj(Ej1,Ej2,Ej3,Ej4,Ec,alpha,beta,f,nmax,ng1,ng2,ng3)
% H=QubitHamiltonian(Ej,Ec,alpha,f,nmax,ng1,ng2,ng3)
% Qubit Hamiltonian in the charge base
%    Ej - Josephson energy E_j=\frac{I_c \phi_0}{2 \pi}
%    Ec - charging energy E_c=\frac{e^2}{2 C}
%    alpha - relative size of the top junction compared to the left and right junctions
%    f - frustration f=\frac{B A}{\phi_0}
%    nmax - maximum number of cooper pairs on an island - charge states run from -nmax to nmax
%    ng1 - gate charge induced on island 1 (top left island)
%    ng2 - gate charge induced on island 2 (top left island)
%    ng3 - gate charge induced on island 3 (top left island)

% QubitHamiltonian 0.9.2  18.9.2001 © Hannes Majer (majer@qt.tn.tudelft.nl)


if nargin~=12 
   error('Incorrect number of input arguments.');
end

point = 2*nmax+1;  % number of charge states

Q=sparse(diag(linspace(-nmax,nmax,point)));  %make diagonal matrix [-nmax,-nmax+1,...,nmax]
Id=sparse(eye(point));

S=[alpha+beta+alpha*beta alpha*beta beta+alpha*beta; alpha*beta alpha+beta+alpha*beta alpha+alpha*beta;...
        beta+alpha*beta alpha+alpha*beta 1+alpha+beta+alpha*beta]/(alpha+beta+2*alpha*beta);  %1/C matrix

Q1=sparse(kron(Q-ng1*Id,kron(Id,Id)));
Q2=sparse(kron(Id,kron((Q-ng2*Id),Id)));
Q3=sparse(kron(Id,kron(Id,(Q-ng3*Id))));

K=4*Ec*(S(1,1)*Q1*Q1+2*S(1,2)*Q1*Q2+2*S(1,3)*Q1*Q3+S(2,2)*Q2*Q2+2*S(2,3)*Q2*Q3+S(3,3)*Q3*Q3); %charging energy  

Fp1=sparse(diag(ones(point-1,1),1));    %up-right off diagonal matrix with 1s 
Fm1=sparse(diag(ones(point-1,1),-1));   %bottom-left off diagonal matrix with 1s

K=K-Ej1/2*kron((Fp1+Fm1),kron(Id,Id));
K=K-Ej2/2*kron(Id,kron((Fp1+Fm1),Id));
K=K-beta*Ej3/2*(kron(Fm1,kron(Id,Fp1))+kron(Fp1,kron(Id,Fm1)));
K=K-alpha*Ej4/2*(kron(Id,kron(Fp1,Fm1))*exp(j*2*pi*f)+kron(Id,kron(Fm1,Fp1))*exp(-j*2*pi*f));
%K=K+nmax*Ej1*sparse(kron(Id,kron(Id,Id)));