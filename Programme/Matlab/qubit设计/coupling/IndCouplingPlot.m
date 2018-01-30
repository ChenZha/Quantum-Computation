function IndCouplingPlot(Ej,Ec,alpha,Lq,kappa,sigma,ML,Cr,Csh,wr,FluxBias,nk,nl,nm,nlevels,Var)
% example:IndCouplingPlot(148e9,3.29e9,0.613,50e-12,0,0,8.9e-12,150e-15,0,13.8e9,0.5,5,10,2,20,'alpha');
%%
if strcmpi(Var,'FluxBias') 
  parfor i=1:41
       FluxBias = 0.48+(i-1)*0.001;
       [g,chi] = IndCoupling(Ej,Ec,alpha,Lq,kappa,sigma,ML,Cr,Csh,wr,FluxBias,nk,nl,nm,nlevels);
       g01(i) = g(1);g02(i) = g(2);g03(i) = g(3);g12(i) = g(4);g13(i) = g(5);
       chi01(i) = chi(1);chi12(i) = chi(2);chi21(i) = chi(3);
%         w1(i)=(EL(3)-EL(1))/(2*pi);w2(i)=(EL(5)-EL(3))/(2*pi);w3(i)=(EL(5)-EL(1))/(2*pi);w4(i)=(EL(5)-EL(1))/(2*pi)/2;
   end
%    delete(gcp('nocreate'));%关闭Pool
   x=-0.02:0.1/100:0.02;
   figure;
   plot(x,g01/10^9,x,g02/10^9,'--',x,g03/10^9,':',x,g12/10^9,'-.',x,g13/10^9);
   legend('g_{01}','g_{02}','g_{03}','g_{12}','g_{13}')
%    xlabel('FluxBias');ylabel('频率v/GHz');
   figure;
   plot(x,chi01/10^6,x,chi12/10^6,'--',x,chi21/10^6,':');
   legend('\chi_{01}','\chi_{12}','\chi_{21}')

%%
elseif strcmpi(Var,'Ej') 
     parfor i=1:41
       Ej = (68+(i-1)*4)*10^9;
       [g,chi] = IndCoupling(Ej,Ec,alpha,Lq,kappa,sigma,ML,Cr,Csh,wr,FluxBias,nk,nl,nm,nlevels);
       g01(i) = g(1);g02(i) = g(2);g03(i) = g(3);g12(i) = g(4);g13(i) = g(5);
       chi01(i) = chi(1);chi12(i) = chi(2);chi21(i) = chi(3);
%         w1(i)=(EL(3)-EL(1))/(2*pi);w2(i)=(EL(5)-EL(3))/(2*pi);w3(i)=(EL(5)-EL(1))/(2*pi);w4(i)=(EL(5)-EL(1))/(2*pi)/2;
   end
%    delete(gcp('nocreate'));%关闭Pool
   x=68:4:228;
   figure;
   plot(x,g01/10^9,x,g02/10^9,'--',x,g03/10^9,':',x,g12/10^9,'-.',x,g13/10^9);
   legend('g_{01}','g_{02}','g_{03}','g_{12}','g_{13}')
%    xlabel('FluxBias');ylabel('频率v/GHz');
   figure;
   plot(x,chi01/10^6,x,chi12/10^6,'--',x,chi21/10^6,':');
   legend('\chi_{01}','\chi_{12}','\chi_{21}')
%%
elseif strcmpi(Var,'Ec') 
    parfor i=1:41
       Ec = (1.19+(i-1)*0.1)*10^9;
       [g,chi] = IndCoupling(Ej,Ec,alpha,Lq,kappa,sigma,ML,Cr,Csh,wr,FluxBias,nk,nl,nm,nlevels);
       g01(i) = g(1);g02(i) = g(2);g03(i) = g(3);g12(i) = g(4);g13(i) = g(5);
       chi01(i) = chi(1);chi12(i) = chi(2);chi21(i) = chi(3);
%         w1(i)=(EL(3)-EL(1))/(2*pi);w2(i)=(EL(5)-EL(3))/(2*pi);w3(i)=(EL(5)-EL(1))/(2*pi);w4(i)=(EL(5)-EL(1))/(2*pi)/2;
   end
%    delete(gcp('nocreate'));%关闭Pool
    x=1.19:0.1:5.19;
   figure;
   plot(x,g01/10^9,x,g02/10^9,'--',x,g03/10^9,':',x,g12/10^9,'-.',x,g13/10^9);
   legend('g_{01}','g_{02}','g_{03}','g_{12}','g_{13}')
%    xlabel('FluxBias');ylabel('频率v/GHz');
   figure;
   plot(x,chi01/10^6,x,chi12/10^6,'--',x,chi21/10^6,':');
   legend('\chi_{01}','\chi_{12}','\chi_{21}')
%%
elseif strcmpi(Var,'alpha') 
   parfor i=1:41
       alpha = 0.4+(i-1)*0.0125;
       [g,chi] = IndCoupling(Ej,Ec,alpha,Lq,kappa,sigma,ML,Cr,Csh,wr,FluxBias,nk,nl,nm,nlevels);
       g01(i) = g(1);g02(i) = g(2);g03(i) = g(3);g12(i) = g(4);g13(i) = g(5);
       chi01(i) = chi(1);chi12(i) = chi(2);chi21(i) = chi(3);
%         w1(i)=(EL(3)-EL(1))/(2*pi);w2(i)=(EL(5)-EL(3))/(2*pi);w3(i)=(EL(5)-EL(1))/(2*pi);w4(i)=(EL(5)-EL(1))/(2*pi)/2;
   end
%    delete(gcp('nocreate'));%关闭Pool
   x=0.4:0.0125:0.9;
   figure;
   plot(x,g01/10^9,x,g02/10^9,'--',x,g03/10^9,':',x,g12/10^9,'-.',x,g13/10^9);
   legend('g_{01}','g_{02}','g_{03}','g_{12}','g_{13}')
%    xlabel('FluxBias');ylabel('频率v/GHz');
   figure;
   plot(x,chi01/10^6,x,chi12/10^6,'--',x,chi21/10^6,':');
   legend('\chi_{01}','\chi_{12}','\chi_{21}')
%%   
elseif strcmpi(Var,'Lq') 
  parfor i=1:41
       Lq = (10+(i-1)*2)*10^(-12);
       [g,chi] = IndCoupling(Ej,Ec,alpha,Lq,kappa,sigma,ML,Cr,Csh,wr,FluxBias,nk,nl,nm,nlevels);
       g01(i) = g(1);g02(i) = g(2);g03(i) = g(3);g12(i) = g(4);g13(i) = g(5);
       chi01(i) = chi(1);chi12(i) = chi(2);chi21(i) = chi(3);
%         w1(i)=(EL(3)-EL(1))/(2*pi);w2(i)=(EL(5)-EL(3))/(2*pi);w3(i)=(EL(5)-EL(1))/(2*pi);w4(i)=(EL(5)-EL(1))/(2*pi)/2;
   end
%    delete(gcp('nocreate'));%关闭Pool
   x=10:2:90;
   figure;
   plot(x,g01/10^9,x,g02/10^9,'--',x,g03/10^9,':',x,g12/10^9,'-.',x,g13/10^9);
   legend('g_{01}','g_{02}','g_{03}','g_{12}','g_{13}')
%    xlabel('FluxBias');ylabel('频率v/GHz');
   figure;
   plot(x,chi01/10^6,x,chi12/10^6,'--',x,chi21/10^6,':');
   legend('\chi_{01}','\chi_{12}','\chi_{21}')

%%
elseif strcmpi(Var,'ML') 
  parfor i=1:41
       ML = (1+(i-1)*0.3)*10^(-12);
       [g,chi] = IndCoupling(Ej,Ec,alpha,Lq,kappa,sigma,ML,Cr,Csh,wr,FluxBias,nk,nl,nm,nlevels);
       g01(i) = g(1);g02(i) = g(2);g03(i) = g(3);g12(i) = g(4);g13(i) = g(5);
       chi01(i) = chi(1);chi12(i) = chi(2);chi21(i) = chi(3);
%         w1(i)=(EL(3)-EL(1))/(2*pi);w2(i)=(EL(5)-EL(3))/(2*pi);w3(i)=(EL(5)-EL(1))/(2*pi);w4(i)=(EL(5)-EL(1))/(2*pi)/2;
   end
%    delete(gcp('nocreate'));%关闭Pool
   x=1:0.3:13;
   figure;
   plot(x,g01/10^9,x,g02/10^9,'--',x,g03/10^9,':',x,g12/10^9,'-.',x,g13/10^9);
   legend('g_{01}','g_{02}','g_{03}','g_{12}','g_{13}')
%    xlabel('FluxBias');ylabel('频率v/GHz');
   figure;
   plot(x,chi01/10^6,x,chi12/10^6,'--',x,chi21/10^6,':');
   legend('\chi_{01}','\chi_{12}','\chi_{21}')
%%    
elseif strcmpi(Var,'Csh') 
  parfor i=1:41
       Csh = (i-1)*1.25*10^(-15);
       [g,chi] = IndCoupling(Ej,Ec,alpha,Lq,kappa,sigma,ML,Cr,Csh,wr,FluxBias,nk,nl,nm,nlevels);
       g01(i) = g(1);g02(i) = g(2);g03(i) = g(3);g12(i) = g(4);g13(i) = g(5);
       chi01(i) = chi(1);chi12(i) = chi(2);chi21(i) = chi(3);
%         w1(i)=(EL(3)-EL(1))/(2*pi);w2(i)=(EL(5)-EL(3))/(2*pi);w3(i)=(EL(5)-EL(1))/(2*pi);w4(i)=(EL(5)-EL(1))/(2*pi)/2;
   end
%    delete(gcp('nocreate'));%关闭Pool
   x=0:1.25:50;
   figure;
   plot(x,g01/10^9,x,g02/10^9,'--',x,g03/10^9,':',x,g12/10^9,'-.',x,g13/10^9);
   legend('g_{01}','g_{02}','g_{03}','g_{12}','g_{13}')
%    xlabel('FluxBias');ylabel('频率v/GHz');
   figure;
   plot(x,chi01/10^6,x,chi12/10^6,'--',x,chi21/10^6,':');
   legend('\chi_{01}','\chi_{12}','\chi_{21}')
%%
end