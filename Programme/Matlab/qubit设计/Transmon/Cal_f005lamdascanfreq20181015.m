s=8*10^-6;
w=8*10^-6;
J0=3*10^6;
Cc1=3.6*10^-15;
Cc2=3.6*10^-15;
Cq1=87.783*10^-15;
Cq2=88.081*10^-15;
fq1=5.45*10^9;
fq2=5.6*10^9;
clight=2.99792*10^8;
%l=10015.524*10^-6;
f0out=[];
g1out=[];
g2out=[];
Jout=[];
f = 5*10^9:0.0001*10^9:9*10^9;
for f0=f
l=clight/2/f0*sqrt(2/11.4);
e=10.4;
Ls=0;
K0=s/(s+2*w);
  K_0=sqrt(1-K0^2);
  K00=ellipke(K0)/ellipke(K_0);
  %if(K0<=0.7)
  %K00=pi/(log(2*(1+sqrt(K_0)/(1-sqrt(K_0)))));
  %else
  %K00=(log(2*(1+sqrt(K0)/(1-sqrt(K0)))))/pi;
  %end
  Ee=(1+e)/2.0;
  E0=8.854187*10^-12;
  u0=12.56637*10^-7;
  Lm=u0/(4*K00);
  C=4*E0*Ee*K00;
  L=Lm+Ls/s;
  %L=Lm+6.764*10^-7;
  Z0=sqrt(L/C);
  f02=1/(2*l*sqrt(L*C));
  %Ct=C*l/2;
  Ct=1/4/f0/Z0;
  Lt=L*l;
%g=2*1.602177*(10^-19)*1.949/(1.949+77.596)*sqrt(4*pi*pi*f0/(6.626069*(10^-34)/C/l));
%output=g/2/pi;
delta1=fq1-f0;
delta2=fq2-f0;
%g1=40*10^6;
%g2=40*10^6;
g1=Cc1*sqrt(f0*fq1)/2/sqrt(Ct*Cq1);
g2=Cc2*sqrt(f0*fq2)/2/sqrt(Ct*Cq2);
J=abs(g1*g2*(1/delta1+1/delta2)/2);
if abs(J)<1e7
    f0out(end+1) = f0;
    Jout(end+1) = J;
end

    if abs(J-J0)<0.001*10^6
        f0opt=f0;
        g1opt=g1;
        g2opt=g2;
        Jopt=J;
    end
end
% figure();plot(f0out,Jout);
disp([f0opt,g1opt,g2opt,Jopt]);