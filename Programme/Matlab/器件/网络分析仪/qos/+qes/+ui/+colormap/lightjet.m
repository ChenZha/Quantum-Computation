function J = lightjet(m,rr)
% lightjet   A variation of jet
%
%   See also HSV, HOT, PINK, FLAG, COLORMAP, RGBPLOT.

%   Copyright Yulin Wu.
%   $Revision: 1.0 $  $Date: 2012/06/06$

if nargin < 1
   m = size(get(gcf,'colormap'),1);
end
n = ceil(1024/4);
u = [(1:1:n)/n ones(1,n-1) (n:-1:1)/n]';
g = ceil(n/2) - (mod(1024,4)==1) + (1:length(u))';
r = g + n;
b = g - n;
g(g>1024) = [];
r(r>1024) = [];
b(b<1) = [];
J = zeros(1024,3);
J(r,1) = u(1:length(r));
J(g,2) = u(1:length(g));
J(b,3) = u(end-length(b)+1:end);

if rr >0.4
    rr = 0.4;
end
N = ceil(rr*1024);
J(1024-N:1024,:)=[];
J(1:N,:)=[];

xin=linspace(0,1,m)';
xorg=linspace(0,1,size(J,1));

p(:,1)=interp1(xorg,J(:,1),xin,'linear');
p(:,2)=interp1(xorg,J(:,2),xin,'linear');
p(:,3)=interp1(xorg,J(:,3),xin,'linear');