Ec = [0.2247,0.2255];
EJ = [22.0296,22.5773];
a = EJ./Ec;
w = w01(EJ,Ec);
% w = [5.99,5.79,5.72,5.89,6.00,5.78,5.85,5.84,5.95,6.04];

w = 6.201;
Ec = 0.3;

[Ej,a] = f(Ec,w);

function [Ej,a] = f(Ec,w)
Ej = (w+Ec).^2/8./Ec;
a = Ej./Ec;
end

function w = w01(Ej,Ec)
w = sqrt(8.*Ec.*Ej)-Ec;

end