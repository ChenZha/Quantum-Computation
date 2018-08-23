function [B,C,D,freq,td1,td2,varargout] = sinDecay4Ramsey(t,P,...
    B0,BBnd,...
    C0,CBnd,...
    D0,DBnd,...
    freq0,freqBnd,...
    td10,td1Bnd,...
    td20,td2Bnd)

% SinDecayFit fits curve P = P(t) with a Sinusoidal Decay function:
% P = B*(exp(-t/td)*(sin(2*pi*freq*t+D)+C));
%
% varargout{1}: ci, 5 by 2 matrix, ci(4,1) is the lower bound of 'freq',
% ci(5,2) is the upper bound of 'td',...
%
% Yulin Wu, SC5,IoP,CAS. mail4ywu@gmail.com
% $Revision: 1.1 $  $Date: 2012/10/18 $

Coefficients(1) = B0;
Coefficients(2) = C0;
Coefficients(3) = D0;
Coefficients(4) = freq0;
Coefficients(5) = td0;
lb = [BBnd(1),CBnd(1),DBnd(1),freqBnd(1),td1Bnd(1),td2Bnd(1)];
ub = [BBnd(2),CBnd(2),DBnd(2),freqBnd(2),td1Bnd(2),td2Bnd(2)];

[Coefficients,~,residual,~,~,~,J] = lsqcurvefit(@SinusoidalDecay,Coefficients,t,P,lb,ub);

B = Coefficients(1);
C =  Coefficients(2);
D = Coefficients(3);
freq = Coefficients(4);
td1 = Coefficients(5);
td2 = Coefficients(6);
if nargout > 5
    varargout{1} = nlparci(Coefficients,residual,'jacobian',J);
end

function [P]=SinusoidalDecay(Coefficients,t)
% Sinusoidal Decay
%
% Yulin Wu, SC5,IoP,CAS. wuyulin@ssc.iphy.ac.cn/mail4ywu@gmail.com
% $Revision: 1.0 $  $Date: 2012/03/28 $

B = Coefficients(1);
C = Coefficients(2);
D = Coefficients(3);
freq = Coefficients(4);
td1 = Coefficients(5);
td2 = Coefficients(6);
P = B*(exp(-(t/td1)-(t/td2).^2).*(sin(2*pi*freq*t+D)+C));