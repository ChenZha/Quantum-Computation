wrb = 5.585*10^9;
% w01 = 6.031*10^9;
w01 = wrb+0.264*10^9;
g01 = 0.0198*10^9;
w12 = w01-0.244*10^9;
g12 = sqrt(2)*g01;
lamda = g01^2/(w01-wrb);
delta = w12-(wrb+lamda);
xita = atan(2*g12/delta);
E1 = wrb+lamda+(delta+sqrt(4*g12^2+delta^2))/2;
E2 = wrb+lamda+(delta-sqrt(4*g12^2+delta^2))/2;
y = 0.004*10^9;
y1 = wrb-lamda+y-E1;
y2 = wrb-lamda+y-E2;
omega1 = 0.001*10^9*sqrt(7);
omega2 = omega1*0.6;
shift = (omega2*cos(xita/2)+omega1*sin(xita/2))^2/y1 + (omega2*sin(xita/2)-omega1*cos(xita/2))^2/y2;