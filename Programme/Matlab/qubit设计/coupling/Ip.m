
Ej = 248e9;
Ec = 3.29e9;
alpha = 0.813;
beta = 0;
kappa = 0;
sigma = 0;
Cc = 4.19e-15;
Cr = 150e-15;
Csh = 0;
FluxBias = 0.49;
nk = 5;nl = 10;nm = 2;nlevels = 20;
fa = 2*acos(1/2/alpha);
fun = @(fs) state(fa,fs,Ej,Ec,alpha,beta,kappa,sigma,Cc,Cr,Csh,FluxBias,nk,nl,nm,nlevels);
result = integral(fun,-2*pi,2*pi);
disp(result);



function S = state(fa,fs,Ej,Ec,alpha,beta,kappa,sigma,Cc,Cr,Csh,FluxBias,nk,nl,nm,nlevels)

[~,SL] = CaFluxQubit(Ej,Ec,alpha,beta,kappa,sigma,Cc,Cr,Csh,FluxBias,nk,nl,nm,nlevels);
S1 = 0;
S2 = 0;
for k1=-nk:nk
	kk1=k1+nk+1;
	for l1=-nl:nl
		ll1=l1+nl+1;
		for m1=0:nm
			mm1=m1+1;
            n = (kk1-1)*(2*nl+1)*(nm+1)+(ll1-1)*(nm+1)+mm1;
            S1 = S1 + SL(n,1).*exp(-1i*k1*fa).*exp(-1i*l1*fs)/2/pi;
            S2 = S2 + SL(n,1).*exp(-1i*k1*fa).*exp(-1i*l1*fs)/2/pi;
        end
    end
end
S = conj(S1).*sin(2*fs+pi).*(S2);

end