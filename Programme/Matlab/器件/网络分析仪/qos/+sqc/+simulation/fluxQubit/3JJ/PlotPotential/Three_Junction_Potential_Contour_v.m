clear all;
r1=0;
a=0.55;
b=0.43;
k=0;
bias=pi;
r2=-pi:0.005:pi;
r3=-pi:0.005:pi;
r3=r3/10;
for n=1:length(r2)
       U(n,:)=-((1+k)*cos(r1-r2(n)-r3)+(1-k)*cos(r1+r2(n)+r3)+a*cos(2*r2(n)+bias-r3/a))+(1+2*a)^2*(1-k^2)/(2*a*b*(1+2*a-k^2))*r3.^2;
end
figure();
contourf(r3/pi,r2/pi,U,35);
xlabel('\gamma_t (\pi)');
ylabel('\gamma_s (\pi)');
zlabel('Energy (E_J)');
title('Slice through \gamma_a = 0 of three-junction flux qubit Potential');