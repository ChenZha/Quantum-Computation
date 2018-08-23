
% TCPBEL4 calculates the eigen values and eigen states of two
% capacitively coupled charge qubits by expanding to the basis:
% { |00> |10> |01> |11> }.
% See TCPBEL for detailed description.
% Example:
% EnergyLevel=TCPBEL(1,1,0.2,0.2,0.3,0.5,0.01);
% Author: Yulin Wu
% Date: 2009/8/14
% Email: mail4ywu@gmail.com


function [EL, varargout]=TCPBEL4(Ec1,Ec2,Em,Ej1,Ej2,Ng1,Ng2)
if nargout>2
    error('Too many output arguments !');
elseif nargin>7
    error('Too many input arguments !');
end
H=zeros(4);
for n=1:4
    N1=ceil(n/2)-1;
    N2=rem(n,2)-1;
    if N2 == -1
        N2=1;
    end
    H(n,n)=Ec1*(N1-Ng1)^2+Ec2*(N2-Ng2)^2+Em*(N1-Ng1)*(N2-Ng2);    % -Em*N1*N2;
end
for n1=1:2
    n2=n1+2;
    H(n1,n2)=-Ej1/2;
    H(n2,n1)=-Ej1/2;
end
for n1=1:4
    if mod(n1,2)~=0
        n2=n1+1;
        H(n1,n2)=-Ej2/2;
        H(n2,n1)=-Ej2/2;
    end
end
[varargout{1} E]=eig(H);
EL=E*ones(4,1);
