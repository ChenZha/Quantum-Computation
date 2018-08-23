function [P]=ExpDecay(Coefficients,t)

%
% Yulin Wu, SC5,IoP,CAS. wuyulin@ssc.iphy.ac.cn/mail4ywu@gmail.com
% $Revision: 1.0 $  $Date: 2012/04/08 $

    A = Coefficients(1);
    B = Coefficients(2);
    td = Coefficients(3);
    P = A +B*exp(-t/td);
end