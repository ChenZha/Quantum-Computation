fa = -2*pi:4*pi/200:2*pi;
fs = -2*pi:4*pi/200:2*pi;
[fa,fs] = meshgrid(fa,fs);
u = potential(fa,fs);
% u = p(fa,fs);
figure();
pcolor(fa,fs,u);
colorbar();

function u = potential(fa,fs)
kappa = 0;
alpha = 0.613;
PhiQ = pi;
U(1,1)=0;		U(1,2)=(1-kappa)/2;			U(1,3)=0;		U(1,4)=(1+kappa)/2;		U(1,5)=0;
                        U(2,2)=0;                    U(2,3)=0;        U(2,4)=0;
U(3,1)=0;		U(3,2)=(1+kappa)/2;          U(3,3)=0;		U(3,4)=(1-kappa)/2 ;     U(3,5)=0;
U(2,1)=alpha*exp(1i*PhiQ)/2 ;			U(2,5)=alpha*exp(-1i*PhiQ)/2;

u = 0;
for i = 1:3
    for j = 1:5
        ii = i-2;
        jj = j-3;
        u = u-U(i,j)*exp(-1i*(ii*fa+jj*fs));
    end
end
u = real(u);
     

end
function u = p(fa,fs)
kappa = 0;
alpha = 0.8;
PhiQ = pi;
u = -(1+kappa)*cos(fa-fs)-(1-kappa)*cos(fa+fs)-alpha*cos(2*fs+PhiQ);
end