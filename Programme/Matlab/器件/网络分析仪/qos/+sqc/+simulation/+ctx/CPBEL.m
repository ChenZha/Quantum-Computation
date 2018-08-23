
% CPBEL calculats the lowest energy levels of a
% Cooper Pair Box (CPB), Transmon and Xmon. CPBEL returns the lowest M energy level
% values as an array EL and eigen vectors as an Matrix (the nth
% column is the eign vecotr of eign value EL(n)).
% EnergyLevel=CPBEL(Ec,Ej,Ng); EnergyLevel=CPBEL(Ec,Ej,Ng,phi);
% EnergyLevel=CPBEL(Ec,Ej,Ng,phi,dEj);
% EnergyLevel=CPBEL(Ec,Ej,Ng,phi,dEj,M).
% [EnergyLevel EignV]=CPBEL(Ec,Ej,Ng);
% Ec=(2e)^2/(2C), the Cooper Pair Coulomb energy;
% Ej, Josephson Energy, Ej=Ej1+Ej2 for split CPB(junction substituted by a SQUID);
% Ng=CgVg/2e, Charge Bias, for Transmon and Xmon, energy level is charge
% insensative, Ng can be any value.
% dEj=Ej1-Ej2, dEj=0 for single junction CPB;
% M, expand to 2*M+1 terms in the charge basis, M>=2 !
% phi,M are not neccesary in the function call, if not specified,
% default values will be used.
% Example:
% EnergyLevel=CPBEL(1,0.5,0.5)
% Author: Yulin Wu
% Date: 2009/7/14
% Email: mail4ywu@gmail.com

function [EL, varargout]=CPBEL(Ec,Ej,Ng,varargin)
% Hamiltonian
% H = Ec*(N-Ng)^2 + Ej*cos(phi)

phi=0;  % By default,assume No flux bias (CPB or zero flux for split CPB),
dEj=0;  % No asymmetry,
M=25;   % and expand to 51 terms in the charge basis.
if nargin == 2  % Transmon or Xmon, charge insensative
    Ng = 0;
end
if nargin>6
    error('Too many input arguments !');
elseif nargout>2
    error('Too many output arguments !');
elseif nargin>3
    phi=varargin{1};
	if nargin>4
        dEj=varargin{2};
    end
    if nargin>5
        M=varargin{3};
        if M<2
            error('Bad input argument value !');
        end
    end
end
H=zeros(2*M+1);
for N=-M:M
    n=N+M+1;
    H(n,n)=Ec*(N-Ng)^2;
    if N<M
        H(n,n+1)=-(Ej*cos(phi/2)-1i*dEj*sin(phi/2))/2;
        H(n+1,n)=-(Ej*cos(phi/2)+1i*dEj*sin(phi/2))/2;
    end
end
[EigV, E]=eig(H);
EL=E*ones(2*M+1,1);
EL(M+1:2*M+1)=[];
EigV(:,M+1:2*M+1)=[];
varargout{1}=EigV(:,1:M);
