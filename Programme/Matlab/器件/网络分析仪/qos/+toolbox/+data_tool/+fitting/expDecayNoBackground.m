function [P]=ExpDecay_NoBackground(Coefficients,t)

%
% Yulin Wu, SC5,IoP,CAS. wuyulin@ssc.iphy.ac.cn/mail4ywu@gmail.com
% $Revision: 1.0 $  $Date: 2012/04/08 $

    B = Coefficients(1);
    td = Coefficients(2);
    P = B*exp(-t/td);
end