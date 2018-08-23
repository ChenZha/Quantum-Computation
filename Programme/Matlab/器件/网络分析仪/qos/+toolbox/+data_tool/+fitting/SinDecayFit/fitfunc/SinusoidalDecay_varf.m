function [P]=SinusoidalDecay_varf(Coefficients,t,t0)
% Sinusoidal Decay
% Parameter estimation:
% A: value of P at large x: P(end) or mean(P(end-##,end))
% B: max(P) - min(P)
% C: A - (max(P) + min(P))/2
% D: 0
% freq: use fft to detect
% td: ...
%
% Yulin Wu, SC5,IoP,CAS. wuyulin@ssc.iphy.ac.cn/mail4ywu@gmail.com
% $Revision: 1.0 $  $Date: 2012/03/28 $

A = Coefficients(1);
B = Coefficients(2);
C = Coefficients(3);
D = Coefficients(4);
freq = Coefficients(5);
td = Coefficients(6);
varf = Coefficients(7);
P = A +B*(exp(-t/td).*(sin(2*pi*(freq+varf.*(t-t0)).*t+D)+C));