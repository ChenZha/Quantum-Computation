clear all;
Ic1=1;
Ic2=1.0*Ic1;
Ic3=0.7*Ic1;
r3=0;
a=2*Ic3/(Ic1+Ic2);
b=0.01;
k=(Ic1-Ic2)/(Ic1+Ic2);
bias=pi;
r1=-pi:0.01:pi;
r2=r1;
figure;
for n=1:length(r2)
    U(n,:)=-((1+k)*cos(r1-r2(n)-r3)+(1-k)*cos(r1+r2(n)+r3)+a*cos(2*r2(n)+bias-r3/a))+(1+2*a)^2*(1-k^2)/(2*a*b*(1+2*a-k^2))*r3.^2;
end
contourf(r1/pi,r2/pi,U,35);
xlabel('\gamma_a (\pi)');
ylabel('\gamma_s (\pi)');
zlabel('Energy (E_J)');
title('Three-junction flux qubit Potential   ( Ic2=0.7Ic1  Ic3=0.4Ic1 \phi_e_x = \pi )');