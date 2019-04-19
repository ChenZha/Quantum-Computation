%% parameter
s=4*10^-6;
w=2*10^-6;
Cc=3.269e-15;
Cq=102.3*10^-15;
fq=5.0616*10^9;
clight=2.99792*10^8;
fr=6.5*10^9;
%%
E=10.4;
Eeff=(1+E)/2.0;
l=clight/4/fr/sqrt(Eeff);

Ls=0;
K0=s/(s+2*w);
K_0=sqrt(1-K0^2);
K00=ellipke(K0)/ellipke(K_0);

E0=8.854187*10^-12;
u0=12.56637*10^-7;
Lm=u0/(4*K00);
C=4*E0*Eeff*K00;
L=Lm+Ls/s;
Z0=sqrt(L/C);
f02=1/(4*l*sqrt(L*C));
Ct=1/8/fr/Z0;
Lt=L*l;
output=Cc*sqrt(fr*fq)/2/sqrt(Ct*Cq);
disp(['Coupling=',num2str(output/10^6)]);