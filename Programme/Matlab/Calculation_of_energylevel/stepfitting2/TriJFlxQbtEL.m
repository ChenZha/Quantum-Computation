function EL = TriJFlxQbtEL(Ej,Ec,alpha,beta,kappa,sigma,FluxBias,nk,nl,nm,nlevels)
% 'TriJFlxQbtEL' calculates the three-junction flux qubit energy levels. 
% Based on the papar: Robertson et al., Phys. Rev. Letts. B 73, 174526 (2006). 
% Syntax
% Energy Level values = TriJFlxQbtEL(Ej,Ec,alpha,beta,kappa,sigma,FluxBias,nk,nl,nm,nlevels)
% Example:
% EL = TriJFlxQbtEL(50,1,0.63,0.15,0,0,0.5,5,10,2,20)
% Energy unit: The same as Ej and Ec.
% FluxBias unit:FluxQuantum
% nlevels: return the energy values of the lowest n energy levels.
% Author: Yulin Wu <mail2ywu@gmail.com>
% Date: 2009/5/6
% Revision:
% 2011/4/30
if nlevels > nk*nl*nm
    EL = 'ERROR: nlevels > nk*nl*nm !';
else
if beta == 0
    beta = 1e-6;    % beta can not be zero !
end
hbar=1.054560652926899e-034;
PhiQ=2*pi*FluxBias; 
M=zeros(3,3);       % M here is invert M in Phys. Rev. B 73, 174526 (2006), Eq.16.
tmp=1+2*alpha;
M(1,1)=1+sigma;
M(1,2)=kappa/tmp;
M(1,3)=2*alpha*kappa/tmp;
M(2,1)=M(1,2);
M(2,2)=((sigma+alpha)*(1+sigma)+2*alpha^2*(1-kappa^2+2*sigma+sigma^2))/(tmp^2*(alpha+sigma));
M(2,3)=2*alpha*(sigma+sigma^2+alpha*(kappa^2-sigma-sigma^2))/(tmp^2*(alpha+sigma));
M(3,1)=M(1,3);
M(3,2)=M(2,3);
M(3,3)=2*alpha^2*(2*alpha*(1+sigma)+1+4*sigma+3*sigma^2-kappa^2)/(tmp^2*(alpha+sigma));
M=4*Ec/(hbar^2*((1+sigma)^2-kappa^2))*M;
tmp1=2*Ej*alpha*(1-kappa^2)*((1+sigma)*(1+2*alpha+3*sigma)-kappa^2);
tmp2=Ec*beta*(1+2*alpha-kappa^2)*(alpha+sigma)*((1+sigma)^2-kappa^2);
omega_t=2*Ec/hbar*sqrt(tmp1/tmp2);
tmp1=hbar^2*(alpha+sigma)*((1+sigma^2)-kappa^2)*(1+2*alpha)^2;
tmp2=8*Ec*alpha^2*((1+sigma)*(1+2*alpha+3*sigma)-kappa^2);
m_t=tmp1/tmp2;
U{1,1}=[0 0];		U{1,2}=[(1-kappa)/2 i];			U{1,3}=[0 0];		U{1,4}=[(1+kappa)/2 -i];		U{1,5}=[0 0];
                        U{2,2}=[0 0];                    U{2,3}=[0 0];        U{2,4}=[0 0];
U{3,1}=[0 0];		U{3,2}=[(1+kappa)/2 i];          U{3,3}=[0 0];		U{3,4}=[(1-kappa)/2 -i];     U{3,5}=[0 0];
U{2,1}=[alpha*exp(i*PhiQ)/2 -i/alpha];			U{2,5}=[alpha*exp(-i*PhiQ)/2 i/alpha];
	 H=zeros((2*nk+1)*(2*nl+1)*(nm+1));
     for k1=-nk:nk
		 kk1=k1+nk+1;
		 for l1=-nl:nl
			 ll1=l1+nl+1;
			 for m1=0:nm
				 mm1=m1+1;
				 for k2=-nk:nk
					 kk2=k2+nk+1;
					 for l2=-nl:nl
						 ll2=l2+nl+1;
						 for m2=0:nm
							 mm2=m2+1;
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
			 end
		 end
     end
	 EL=eig(H);
EL(nlevels+1:end)=[];
end

function f=Kdelta(x1,x2)
if x1==x2
    f=1;
else f=0;
end
