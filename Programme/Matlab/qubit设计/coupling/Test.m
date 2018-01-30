function [EL,SL] = Test(Ej,Ec,alpha,beta,kappa,sigma,Cc,Cr,Csh,FluxBias,nk,nl,nm,nlevels)
% reprogrammming Wu yulin's programme
% example : [EL1,SL1] = Test(148e9,3.29e9,0.613,0,0,0,4.19e-15,150e-15,0,0.5,5,10,2,20);
% 对于Cc带入正常值
% Ej,Ec为频率值,单位为Hz，
% 输出的EL也为频率值，单位为Hz
if nlevels > nk*nl*nm
    EL = 'ERROR: nlevels > nk*nl*nm !';
else
if beta == 0
    beta = 1e-6;    % beta can not be zero !
end
tic;
hbar=1.054560652926899e-034;
h = hbar*2*pi;
e = 1.60217662e-19; 
phi0 = 2*pi*hbar/(2*e);PhiQ=2*pi*FluxBias; 
Ej = h*Ej;Ec = h*Ec;%
C1 = e^2*(1+kappa)/(Ec*2);C2 = e^2*(1-kappa)/(Ec*2);C3 = e^2*alpha/(Ec*2);Cs = e^2*sigma/(Ec*2);
C3 = C3+Csh;
C = zeros(4,4);
C(1,1) = C1+Cs;C(2,2) = C2+Cs;C(3,3) = C3+Cc+Cs;C(4,4) = Cr+Cc;C(3,4) = -Cc;C(4,3) = -Cc;
S = [1,-1,-1,0;-1,-1,-1,0;0,2,-1/alpha,0;0,0,0,1];
C = S'*C*S;
M = 4*pi^2*inv(C)/phi0^2;
% Mq = M(1:3,1:3)

% tmp1=2*Ej*alpha*(1-kappa^2)*((1+sigma)*(1+2*alpha+3*sigma)-kappa^2);
% tmp2=Ec*beta*(1+2*alpha-kappa^2)*(alpha+sigma)*((1+sigma)^2-kappa^2);
% omega_t=2*Ec/hbar*sqrt(tmp1/tmp2);
% tmp1=hbar^2*(alpha+sigma)*((1+sigma^2)-kappa^2)*(1+2*alpha)^2;
% tmp2=8*Ec*alpha^2*((1+sigma)*(1+2*alpha+3*sigma)-kappa^2);
% m_t=tmp1/tmp2;
temp = Ej*(1+2*alpha)^2*(1-kappa^2)/(2*alpha*beta*(1+2*alpha-kappa^2));
m_t = 1/M(3,3);
omega_t = sqrt(2*temp/m_t);
U{1,1}=[0 0];		U{1,2}=[(1-kappa)/2 i];			U{1,3}=[0 0];		U{1,4}=[(1+kappa)/2 -i];		U{1,5}=[0 0];
                        U{2,2}=[0 0];                    U{2,3}=[0 0];        U{2,4}=[0 0];
U{3,1}=[0 0];		U{3,2}=[(1+kappa)/2 i];          U{3,3}=[0 0];		U{3,4}=[(1-kappa)/2 -i];     U{3,5}=[0 0];
U{2,1}=[alpha*exp(i*PhiQ)/2 -i/alpha];			U{2,5}=[alpha*exp(-i*PhiQ)/2 i/alpha];
	 H=zeros((2*nk+1)*(2*nl+1)*(nm+1));
dim1 =  (nm+1);dim2 =  (2*nl+1)*(nm+1);dim3 =   (2*nk+1)*(2*nl+1)*(nm+1); 
length = dim3-1;
for ii = 0:length
    kk1 = floor(ii/dim2)+1;
    ll1 = floor(mod(ii,dim2)/dim1)+1;
    mm1 = mod(mod(ii,dim2),dim1)+1;
    k1 = kk1-1-nk;
    l1 = ll1-1-nl;
    m1 = mm1-1;
	for j = 0:length
        kk2 = floor(j/dim2)+1;
        ll2 = floor(mod(j,dim2)/dim1)+1;
        mm2 = mod(mod(j,dim2),dim1)+1;
        k2 = kk2-1-nk;
        l2 = ll2-1-nl;
        m2 = mm2-1;
                 n1=(kk1-1)*(2*nl+1)*(nm+1)+(ll1-1)*(nm+1)+mm1;
                 n2=(kk2-1)*(2*nl+1)*(nm+1)+(ll2-1)*(nm+1)+mm2;
                 if n2<n1
                     H(n1,n2)=conj(H(n2,n1));
                 else
                 H1=hbar^2*(k1^2*M(1,1)/2+k1*l1*M(1,2)+l1^2*M(2,2)/2)*Kdelta(k1,k2)*Kdelta(l1,l2)*Kdelta(m1,m2);
                 H2=-i*sqrt((m_t*omega_t*hbar^3)/2)*(M(1,3)*k1+M(2,3)*l1)*Kdelta(k1,k2)*Kdelta(l1,l2)*(sqrt(m2+1)*Kdelta(m2+1,m1)-sqrt(m2)*Kdelta(m2-1,m1));
                 tmp1=0;
                 for p=-1:1
                         row=p+2;
                        for q=-2:2
                             cln=q+3;
                            if k1==p+k2 && l1==q+l2 && U{row,cln}(1)~=0 
                                cc=U{row,cln}(2);
                                tmp=0;
                                tmp2=sqrt(hbar/(2*m_t*omega_t))*cc;
                                for jj=0:min(m1,m2)
                                    tmp=tmp+factorial(jj)*nchoosek(m1,jj)*nchoosek(m2,jj)*(tmp2)^(m1+m2-2*jj);
                                end
                                tmp=tmp*(factorial(m1)*factorial(m2))^(-0.5)*exp(tmp2^2/2);
                                tmp1=tmp1+U{row,cln}(1)*tmp;
                            end
                        end
                 end
                 H3=-Ej*tmp1;
                 H4=(m1+0.5)*hbar*omega_t*Kdelta(k1,k2)*Kdelta(l1,l2)*Kdelta(m1,m2);
                 H(n1,n2)=H1+H2+H3+H4;
                 end
    end
end
end

	 [V,D]=eig(H);
     SL = V(:,1:nlevels);
     EL = eig(H)/h;
     EL(nlevels+1:end)=[];
     toc;
end

function f=Kdelta(x1,x2)
if x1==x2
    f=1;
else f=0;
end
end