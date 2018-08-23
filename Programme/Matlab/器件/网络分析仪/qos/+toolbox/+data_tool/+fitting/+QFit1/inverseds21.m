function [ invs21 ] = inverseds21( c,freq )
%INVERSES21 Summary of this function goes here
%   Detailed explanation goes here
f0 = c(1);
Qi = c(2);
Qc = c(3);
phi = c(4);
dx = (freq-f0)/f0;
invs21 = 1+exp(1i*phi)*Qi/Qc./(1+2*1i*Qi*dx);
end

