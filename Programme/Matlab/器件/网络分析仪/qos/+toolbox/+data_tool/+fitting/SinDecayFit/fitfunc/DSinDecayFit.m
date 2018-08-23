function [A,B1,C1,D1,freq1,td1,B2,C2,D2,freq2,td2] = DSinDecayFit(t,P,A0,B0,C0,D0,freq0,td0)
% SinDecayFit fits curve P = P(t) with a Sinusoidal Decay function:
% P = A +B1*(exp(-t/td1)*(sin(2*pi*freq1*t+D1)+C1))+B2*(exp(-t/td2)*(sin(2*pi*freq2*t+D2)+C2));
% t unit should be nano-second.
%
% Yulin Wu, SC5,IoP,CAS. mail4ywu@gmail.com
% $Revision: 1.0 $  $Date: 2012/10/18 $

    Coefficients(1) = A0;
    Coefficients(2) = B0;
    Coefficients(3) = C0;
    Coefficients(4) = D0;
    Coefficients(5) = freq0;
    Coefficients(6) = td0;
    
    Coefficients(7) = B0;
    Coefficients(8) = C0;
    Coefficients(9) = D0;
    Coefficients(10) = freq0;
    Coefficients(11) = td0;
    for ii = 1:10
        Coefficients = lsqcurvefit(@DSinusoidalDecay,Coefficients,t,P);
    end
    A = Coefficients(1);
    B1 = Coefficients(2);
    C1 =  Coefficients(3);
    D1 = Coefficients(4);
    freq1 = Coefficients(5);
    td1 = Coefficients(6);
    B2 = Coefficients(7);
    C2 =  Coefficients(8);
    D2 = Coefficients(9);
    freq2 = Coefficients(10);
    td2 = Coefficients(11);


function [P]=DSinusoidalDecay(Coefficients,t)
% Yulin Wu, SC5,IoP,CAS. wuyulin@ssc.iphy.ac.cn/mail4ywu@gmail.com
% $Revision: 1.0 $  $Date: 2012/03/28 $

A = Coefficients(1);
B1 = Coefficients(2);
C1 = Coefficients(3);
D1 = Coefficients(4);
freq1 = Coefficients(5);
td1 = Coefficients(6);
B2 = Coefficients(7);
C2 = Coefficients(8);
D2 = Coefficients(9);
freq2 = Coefficients(10);
td2 = Coefficients(11);
P = A +B1*(exp(-t/td1).*(sin(2*pi*freq1*t+D1)+C1))+B2*(exp(-t/td2).*(sin(2*pi*freq2*t+D2)+C2));