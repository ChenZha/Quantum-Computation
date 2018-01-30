function CaFluxplot(Ej,Ec,alpha,beta,kappa,sigma,Cc,Cr,Csh,FluxBias,nk,nl,nm,nlevels,el,Var)
%     example:CaFluxplot(148e9,3.29e9,0.613,0,0,0,4.19e-15,150e-15,0,0.5,5,10,2,20,1,'Ej');
tic;
hbar=1.054560652926899e-034;
h = hbar*2*pi;
e = 1.60217662e-19;        
                 
%    parpool(3);
%%
if strcmpi(Var,'State') 
fa = -2*pi:4*pi/200:2*pi;
fs = -2*pi:4*pi/200:2*pi;
[fa,fs] = meshgrid(fa,fs);
[RS,P,S] = state(fa,fs,Ej,Ec,alpha,beta,kappa,sigma,Cc,Cr,Csh,FluxBias,nk,nl,nm,nlevels,el);
figure();pcolor(fa,fs,RS);
% figure();surf(fa,fs,P);
colorbar();
%%
elseif strcmpi(Var,'FluxBias') 
  w0 = zeros(1,41);w1 = zeros(1,41);w2 = zeros(1,41);w3 = zeros(1,41);
  w01 = zeros(1,41);w12 = zeros(1,41);w02 = zeros(1,41);wf = zeros(1,41);
  
  parfor i=1:41
      FluxBias = 0.48+(i-1)*0.001;
       [EL,~] = CaFluxQubit(Ej,Ec,alpha,beta,kappa,sigma,Cc,Cr,Csh,FluxBias,nk,nl,nm,nlevels);
%        w1(i)=EL(3)-EL(1);w2(i)=EL(5)-EL(3);w3(i)=EL(5)-EL(1);w4(i)=(EL(5)-EL(1))/2;
        w0(i)=EL(1);w1(i)=EL(3);w2(i)=EL(5);w3(i)=EL(7);
        w01(i) = w1(i)-w0(i);w12(i) = w2(i)-w1(i);w02(i) = w2(i)-w0(i);wf(i) = (w2(i)-w0(i))/2;
   end
   I = zeros(1,40);
   for i=1:40
       I(i) = (w01(i+1)-w01(i))*(2*e);
   end   
%    delete(gcp('nocreate'));%关闭Pool
   x=0.48:0.1/100:0.52;
   figure();
   plot(x,w0);hold on;plot(x,w1,'--');hold on;plot(x,w2,'-.');hold on;plot(x,w3,':');hold on;
   legend('\omega_{0}','\omega_{1}','\omega_{2}','\omega_{3}')
   xlabel('FluxBias');ylabel('频率v/Hz');
   figure();
   plot(x(1:40),I);hold on;
   xlabel('FluxBias');ylabel('Ip');
   figure();
   plot(x,w01);hold on;plot(x,w12,'--');hold on;plot(x,w02,'-.');hold on;plot(x,wf,':');hold on;
   legend('\omega_{01}','\omega_{12}','\omega_{02}','\omega_{02}/2')
   xlabel('FluxBias');ylabel('频率v/Hz');
%%
elseif strcmpi(Var,'Ej') 
      w1 = zeros(1,41);w2 = zeros(1,41);w3 = zeros(1,41);w4 = zeros(1,41);
  parfor i=1:41
      Ej = (68+(i-1)*4)*10^9;
       [EL,~] = CaFluxQubit(Ej,Ec,alpha,beta,kappa,sigma,Cc,Cr,Csh,FluxBias,nk,nl,nm,nlevels);
       w1(i)=EL(3)-EL(1);w2(i)=EL(5)-EL(3);w3(i)=EL(5)-EL(1);w4(i)=(EL(5)-EL(1))/2;
%         w1(i)=(EL(3)-EL(1))/(2*pi);w2(i)=(EL(5)-EL(3))/(2*pi);w3(i)=(EL(5)-EL(1))/(2*pi);w4(i)=(EL(5)-EL(1))/(2*pi)/2;
  end
%    delete(gcp('nocreate'));%关闭Pool
   x=68:4:228;
   figure;
   plot(x,w1);hold on;plot(x,w2,'--');hold on;plot(x,w3,'-.');hold on;plot(x,w4,':');hold on;
   legend('\omega_{01}','\omega_{12}','\omega_{02}','\omega_{02}/2')
   xlabel('Ej');ylabel('频率v/Hz');
%%
elseif strcmpi(Var,'Ec') 
    w1 = zeros(1,41);w2 = zeros(1,41);w3 = zeros(1,41);w4 = zeros(1,41);
    parfor i=1:41
        Ec = (1.19+(i-1)*0.1)*10^9;
       [EL,~] = CaFluxQubit(Ej,Ec,alpha,beta,kappa,sigma,Cc,Cr,Csh,FluxBias,nk,nl,nm,nlevels);
       w1(i)=EL(3)-EL(1);w2(i)=EL(5)-EL(3);w3(i)=EL(5)-EL(1);w4(i)=(EL(5)-EL(1))/2;
%         w1(i)=(EL(3)-EL(1))/(2*pi);w2(i)=(EL(5)-EL(3))/(2*pi);w3(i)=(EL(5)-EL(1))/(2*pi);w4(i)=(EL(5)-EL(1))/(2*pi)/2;
    end
%    delete(gcp('nocreate'));%关闭Pool
    x=1.19:0.1:5.19;
    figure;
    plot(x,w1);hold on;plot(x,w2,'--');hold on;plot(x,w3,'-.');hold on;plot(x,w4,':');hold on;
    legend('\omega_{01}','\omega_{12}','\omega_{02}','\omega_{02}/2')
    xlabel('Ec');ylabel('频率v/Hz');
%%
elseif strcmpi(Var,'alpha') 
          w1 = zeros(1,41);w2 = zeros(1,41);w3 = zeros(1,41);w4 = zeros(1,41);
  parfor i=1:41
      alpha = 0.4+(i-1)*0.0125;
       [EL,~] = CaFluxQubit(Ej,Ec,alpha,beta,kappa,sigma,Cc,Cr,Csh,FluxBias,nk,nl,nm,nlevels);
       w1(i)=EL(3)-EL(1);w2(i)=EL(5)-EL(3);w3(i)=EL(5)-EL(1);w4(i)=(EL(5)-EL(1))/2;
%         w1(i)=(EL(3)-EL(1))/(2*pi);w2(i)=(EL(5)-EL(3))/(2*pi);w3(i)=(EL(5)-EL(1))/(2*pi);w4(i)=(EL(5)-EL(1))/(2*pi)/2;
  end
%    delete(gcp('nocreate'));%关闭Pool
   x=0.4:0.0125:0.9;
   figure;
   plot(x,w1);hold on;plot(x,w2,'--');hold on;plot(x,w3,'-.');hold on;plot(x,w4,':');hold on;
   legend('\omega_{01}','\omega_{12}','\omega_{02}','\omega_{02}/2')
   xlabel('alpha');ylabel('频率v/Hz');
%%
elseif strcmpi(Var,'beta') 
          w1 = zeros(1,41);w2 = zeros(1,41);w3 = zeros(1,41);w4 = zeros(1,41);
  parfor i=1:41
      beta = 1e-6+(i-1)*1e-5;
       [EL,~] = CaFluxQubit(Ej,Ec,alpha,beta,kappa,sigma,Cc,Cr,Csh,FluxBias,nk,nl,nm,nlevels);
       w1(i)=EL(3)-EL(1);w2(i)=EL(5)-EL(3);w3(i)=EL(5)-EL(1);w4(i)=(EL(5)-EL(1))/2;
%         w1(i)=(EL(3)-EL(1))/(2*pi);w2(i)=(EL(5)-EL(3))/(2*pi);w3(i)=(EL(5)-EL(1))/(2*pi);w4(i)=(EL(5)-EL(1))/(2*pi)/2;
  end
%    delete(gcp('nocreate'));%关闭Pool
   x=1e-6:1e-5:4.01e-4;
   figure;
   plot(x,w1);hold on;plot(x,w2,'--');hold on;plot(x,w3,'-.');hold on;plot(x,w4,':');hold on;
   legend('\omega_{01}','\omega_{12}','\omega_{02}','\omega_{02}/2')
   xlabel('beta');ylabel('频率v/Hz');
%%   
elseif strcmpi(Var,'Cc') 
  w1 = zeros(1,41);w2 = zeros(1,41);w3 = zeros(1,41);w4 = zeros(1,41);
  parfor i=1:41
      Cc = (1.19+(i-1)*0.4)*10^(-15);
       [EL,~] = CaFluxQubit(Ej,Ec,alpha,beta,kappa,sigma,Cc,Cr,Csh,FluxBias,nk,nl,nm,nlevels);
       w1(i)=EL(3)-EL(1);w2(i)=EL(5)-EL(3);w3(i)=EL(5)-EL(1);w4(i)=(EL(5)-EL(1))/2;
%         w1(i)=(EL(3)-EL(1))/(2*pi);w2(i)=(EL(5)-EL(3))/(2*pi);w3(i)=(EL(5)-EL(1))/(2*pi);w4(i)=(EL(5)-EL(1))/(2*pi)/2;
  end
%    delete(gcp('nocreate'));%关闭Pool
   x=1.19:0.4:17.19;
   figure;
   plot(x,w1);hold on;plot(x,w2,'--');hold on;plot(x,w3,'-.');hold on;plot(x,w4,':');hold on;
   legend('\omega_{01}','\omega_{12}','\omega_{02}','\omega_{02}/2')
   xlabel('Cc');ylabel('频率v/Hz');   


%%    
elseif strcmpi(Var,'Csh') 
  w1 = zeros(1,41);w2 = zeros(1,41);w3 = zeros(1,41);w4 = zeros(1,41);
  parfor i=1:41
      Csh = (i-1)*1.25*10^(-15);
       [EL,~] = CaFluxQubit(Ej,Ec,alpha,beta,kappa,sigma,Cc,Cr,Csh,FluxBias,nk,nl,nm,nlevels);
       w1(i)=EL(3)-EL(1);w2(i)=EL(5)-EL(3);w3(i)=EL(5)-EL(1);w4(i)=(EL(5)-EL(1))/2;
%         w1(i)=(EL(3)-EL(1))/(2*pi);w2(i)=(EL(5)-EL(3))/(2*pi);w3(i)=(EL(5)-EL(1))/(2*pi);w4(i)=(EL(5)-EL(1))/(2*pi)/2;
  end
%    delete(gcp('nocreate'));%关闭Pool
   x=0:1.25:50;
   figure;
   plot(x,w1);hold on;plot(x,w2,'--');hold on;plot(x,w3,'-.');hold on;plot(x,w4,':');hold on;
   legend('\omega_{01}','\omega_{12}','\omega_{02}','\omega_{02}/2')
   xlabel('Csh');ylabel('频率v/Hz'); 
%%
end
toc;    
end

function [RS,P,S] = state(fa,fs,Ej,Ec,alpha,beta,kappa,sigma,Cc,Cr,Csh,FluxBias,nk,nl,nm,nlevels,el)
[~,SL] = CaFluxQubit(Ej,Ec,alpha,beta,kappa,sigma,Cc,Cr,Csh,FluxBias,nk,nl,nm,nlevels);
S = 0;
for k1=-nk:nk
	kk1=k1+nk+1;
	for l1=-nl:nl
		ll1=l1+nl+1;
		for m1=0:nm
			mm1=m1+1;
            n = (kk1-1)*(2*nl+1)*(nm+1)+(ll1-1)*(nm+1)+mm1;
            S = S + SL(n,el).*exp(-1i*k1*fa).*exp(-i*l1*fs)/2/pi;
        end
    end
end
P = angle(S);
RS = real(S);

end