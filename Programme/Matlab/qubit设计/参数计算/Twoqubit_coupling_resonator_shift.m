wrb = 5.585*10^9;
% w01 = 6.031*10^9;
w101 = wrb+0.264*10^9;
w201 = wrb+0.285*10^9;

g101 = 0.0209*10^9;
g201 = 0.0198*10^9;

w112 = w101-0.245*10^9;
w212 = w201-0.244*10^9;

g112 = sqrt(2)*g101;
g212 = sqrt(2)*g201;

lamda1 = g101^2/(w101-wrb);
lamda2 = g201^2/(w201-wrb);

delta1 = w112-(wrb+lamda1+lamda2);
delta2 = w212-(wrb+lamda1+lamda2);

H = zeros(3);
H(1,1) = delta1;H(1,3) = g112;H(2,2) = delta2;H(2,3) = g212;H(3,1) = g112;H(3,2) = g212;

% p = (-3*(g112^2+g212^2-delta1*delta2)-(delta1+delta2)^2)/3;
% q = g112^2*delta2+g212^2*delta1-delta1*delta2-(delta1+delta2)*(g112^2+g212^2-delta1*delta2)/3+2*(delta1+delta2)^3/27;
% h = (-1+sqrt(3)*1j)/2;
% lamda = sqrt((q/2)^2+(p/3)^3);

% E1 = (-q/2+lamda)^(1/3)+(-q/2-lamda)^(1/3)+(delta1+delta2)/3;
% E2 = h*(-q/2+lamda)^(1/3)+h^2*(-q/2-lamda)^(1/3)+(delta1+delta2)/3;
% E3 = h^2*(-q/2+lamda)^(1/3)+h*(-q/2-lamda)^(1/3)+(delta1+delta2)/3;
E = eig(H);
E1 = E(1)+wrb+lamda1+lamda2;
E2 = E(2)+wrb+lamda1+lamda2;
E3 = E(3)+wrb+lamda1+lamda2;

y = 0.004*10^9;
y1 = wrb-lamda1-lamda2+y-E1;
y2 = wrb-lamda1-lamda2+y-E2;
y3 = wrb-lamda1-lamda2+y-E3;

N1 = (1+(E1*(E1-delta1)-g112^2)^2/(g112*g212)^2+(E1-delta1)^2/g112^2)^(-1/2);
N2 = (1+(E2*(E2-delta1)-g112^2)^2/(g112*g212)^2+(E2-delta1)^2/g112^2)^(-1/2);
N3 = (1+(E3*(E3-delta1)-g112^2)^2/(g112*g212)^2+(E3-delta1)^2/g112^2)^(-1/2);

omega = 0.002*10^9;
omega1 = 0.0012*10^9;
omega2 = 0.0012*10^9;
shift = N1^2*(abs(omega1+(E1*(E1-delta1)-g112^2)/(g112*g212)*omega2+(E1-delta1)/g112*omega))^2+N2^2*(abs(omega1+(E2*(E2-delta1)-g112^2)/(g112*g212)*omega2+(E2-delta1)/g112*omega))^2+N3^2*(abs(omega1+(E3*(E3-delta1)-g112^2)/(g112*g212)*omega2+(E3-delta1)/g112*omega))^2;