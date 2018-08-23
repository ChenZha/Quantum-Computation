function [P]=SinusoidalDecayNoTilt(Coefficients,t)
% Sinusoidal Decay
%
% Yulin Wu, SC5,IoP,CAS. wuyulin@ssc.iphy.ac.cn/mail4ywu@gmail.com
% $Revision: 1.0 $  $Date: 2012/03/28 $

B = Coefficients(1);
C = Coefficients(2);
D = Coefficients(3);
freq = Coefficients(4);
td = Coefficients(5);
P = B*(exp(-(t/td)).*(sin(2*pi*freq*t+D)+C));