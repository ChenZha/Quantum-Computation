
% This MATLAB function calculats the lowest energy levels of two
% capacitively coupled Cooper Pair Boxes (CPBs). TCPBEL returns 
% the lowest M energy level values as an array EL an eigen vectors
% as an Matrix (the nth column is the eign vecotr of eign value
% EL(n)).
% Function call and Meaning of arguments:
% EnergyLevel=TCPBEL(Ec1,Ec2,Em,Ej1,Ej2,Ng1,Ng2);
% EnergyLevel=TCPBEL(Ec1,Ec2,Em,Ej1,Ej2,Ng1,Ng2,M);
% [EnergyLevel EignV]=TCPBEL(Ec1,Ec2,Em,Ej1,Ej2,Ng1,Ng2);
% Ec1=(2e)^2/C_{1\sigma}, Ec1=(2e)^2/C_{2\sigma}, the Cooper Pair
% Coulomb energys of the two CPBs;
% Ej1, Ej2, the Josephson Energys;
% Em=4e^{2}Cm/(C_{1\sigma}C_{2\sigma}-C_{M}^{2}), the coupling
% energy. Cm is the coupling capacitor;
% Ng1=Cg1Vg1/2e, Ng2=Cg2Vg2/2e, the Charge Biases; 
% M, expand to (2*M+1)*(2*M+1) terms in the charge basis, M>=2 !
% M is not neccesary in the function call, if not specified,
% the default value (10) will be assigned to M.
% Example:
% EnergyLevel=TCPBEL(1,1,0.2,0.2,0.3,0.5,0.01);
% Author: Yulin Wu
% Date: 2009/8/14
% Email: mail4ywu@gmail.com

function [EL, varargout]=TCPBEL(Ec1,Ec2,Em,Ej1,Ej2,Ng1,Ng2,varargin)
M=10;   % Expand to 21*21 terms in the charge basis by default.
if nargout>2
    error('Too many output arguments !');
elseif nargin>8
    error('Too many input arguments !');
elseif nargin>7
        M=varargin;
        if M<2
            error('Bad input argument value !');
        end
end
NBV=2*M+1;
MtrxDim=NBV^2;
H=zeros(MtrxDim);
for n=1:MtrxDim
    N1=ceil(n/NBV)-M-1;
    N2=rem(n,NBV)-M-1;
    if N2 == -M-1
        N2=M;
    end
    H(n,n)=Ec1*(N1-Ng1)^2+Ec2*(N2-Ng2)^2+Em*(N1-Ng1)*(N2-Ng2);    % -Em*N1*N2;
end
for n1=1:MtrxDim-NBV
    n2=n1+NBV;
    H(n1,n2)=-Ej1/2;
    H(n2,n1)=-Ej1/2;
end
for n1=1:MtrxDim
    if mod(n1,NBV)~=0
        n2=n1+1;
        H(n1,n2)=-Ej2/2;
        H(n2,n1)=-Ej2/2;
    end
end
[EigV E]=eig(H);
EL=E*ones(MtrxDim,1);
EL(M+1:MtrxDim)=[];
EigV(:,M+1:MtrxDim)=[];
varargout{1}=EigV(:,1:M);
