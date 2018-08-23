function [A,B,p,varargout] = RBFit(m,P,...
    A0,ABnd,...
    B0,BBnd,...
    p0,pBnd)
% fit randomized benchmarking data

if nargin < 3
    A0 = range(P);
    ABnd = [0.9*A0, 1.1];
    B0 = P(end);
    BBnd = [0, 1.1*B0];
    p0 = 0.97;
    pBnd = [0.5,1];
end

Coefficients(1) = A0;
Coefficients(2) = B0;
Coefficients(3) = p0;
lb = [ABnd(1),BBnd(1),pBnd(1)];
ub = [ABnd(2),BBnd(2),pBnd(2)];
[Coefficients,~,residual,~,~,~,J] = lsqcurvefit(@fitFunc,Coefficients,m,P,lb,ub);
A = Coefficients(1);
B =  Coefficients(2);
p = Coefficients(3);
if nargout > 3
    varargout{1} = nlparci(Coefficients,residual,'jacobian',J);
end


function y=fitFunc(Coefficients,x)

A = Coefficients(1);
B = Coefficients(2);
p = Coefficients(3);
y = A*p.^x+B;
