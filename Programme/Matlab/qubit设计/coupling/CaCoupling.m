function [g,chi] = CaCoupling(Ej,Ec,alpha,beta,kappa,sigma,Cc,Cr,Csh,wr,FluxBias,nk,nl,nm,nlevels)
% reprogrammming Wu yulin's programme
% example: [g,chi] = CaCoupling(148e9,3.29e9,0.613,0,0,0,4.19e-15,2000e-15,10.298e9,0.5,5,10,2,20);
% 对于Cc带入正常值
% Ej,Ec为频率值,单位为Hz，
% 输出的g也为频率值，单位为Hz
if nlevels > nk*nl*nm
    g = 'ERROR: nlevels > nk*nl*nm !';
else
if beta == 0
    beta = 1e-6;    % beta can not be zero !
end
[EL,SL] = CaFluxQubit(Ej,Ec,alpha,beta,kappa,sigma,Cc,Cr,Csh,FluxBias,nk,nl,nm,nlevels);
%% 参数

hbar=1.054560652926899e-034;
h = hbar*2*pi;
e = 1.60217662e-19;
% wr = wr*2*pi; 
phi0 = 2*pi*hbar/(2*e);PhiQ=2*pi*FluxBias; 
Ej = h*Ej;Ec = h*Ec;
C1 = e^2*(1+kappa)/(Ec*2);C2 = e^2*(1-kappa)/(Ec*2);C3 = e^2*alpha/(Ec*2);Cs = e^2*sigma/(Ec*2);
C3 = C3+Csh;
C = zeros(4,4);
C(1,1) = C1+Cs;C(2,2) = C2+Cs;C(3,3) = C3+Cc+Cs;C(4,4) = Cr+Cc;C(3,4) = -Cc;C(4,3) = -Cc;
S = [1,-1,-1,0;-1,-1,-1,0;0,2,-1/alpha,0;0,0,0,1];
C = S'*C*S;
M = 4*pi^2*inv(C)/phi0^2;
temp = Ej*(1+2*alpha)^2*(1-kappa^2)/(2*alpha*beta*(1+2*alpha-kappa^2));
m_t = 1/M(3,3);
omega_t = sqrt(2*temp/m_t);
%% 
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
							 H1 = -M(1,4)*hbar*k1*Kdelta(k1,k2)*Kdelta(l1,l2)*Kdelta(m2,m1)*1i*sqrt(wr*h/2/M(4,4));
                             H2 = -M(2,4)*hbar*l1*Kdelta(k1,k2)*Kdelta(l1,l2)*Kdelta(m2,m1)*1i*sqrt(wr*h/2/M(4,4));
                             H3 = M(3,4)*1i*sqrt((m_t*omega_t*hbar)/2)*(sqrt(m2+1)*Kdelta(m2+1,m1)-sqrt(m2)*Kdelta(m2-1,m1))*Kdelta(k1,k2)*Kdelta(l1,l2)*1i*sqrt(wr*h/2/M(4,4));
							 H(n1,n2)=H1+H2+H3;
                                % *1i*sqrt(wr*hbar/2/M(4,4))
							 end
						 end
				 	 end
				 end
			 end
		 end
     end
%%

psi0 = SL(:,2);psi1 = SL(:,3);psi2 = SL(:,6);psi3 = SL(:,7);
% norm(psi0)
g01 = abs(psi0'*H*psi1)/h;g02 = abs(psi0'*H*psi2)/h;g03 = abs(psi0'*H*psi3)/h;g12 = abs(psi1'*H*psi2)/h;g13 = abs(psi1'*H*psi3)/h;
g = [g01,g02,g03,g12,g13];
w01 = EL(3)-EL(2);w02 = EL(6)-EL(2);w12 = EL(6)-EL(3);w21 = EL(3)-EL(6);
chi01 = g01^2/(w01-wr);chi12 = g12^2/(w12-wr);chi21 = g12^2/(w21-wr);
chi = [chi01,chi12,chi21];
% 1i*sqrt(wr*hbar/2/M(4,4))

end


function f=Kdelta(x1,x2)
if x1==x2
    f=1;
else f=0;
end