function CaCouplingPlot(Ej,Ec,alpha,beta,kappa,sigma,Cc,Cr,Csh,wr,nk,nl,nm,nlevels)
% example:CaCouplingPlot(148e9,3.29e9,0.613,0,0,0,4.19e-15,150e-15,10.298e9,5,10,2,20);
parfor i=1:41
       [g,chi] = CaCoupling(Ej,Ec,alpha,beta,kappa,sigma,Cc,Cr,Csh,wr,0.48+(i-1)*0.001,nk,nl,nm,nlevels);
       g01(i) = g(1);g02(i) = g(2);g03(i) = g(3);g12(i) = g(4);g13(i) = g(5);
       chi01(i) = chi(1);chi12(i) = chi(2);chi21(i) = chi(3);
%         w1(i)=(EL(3)-EL(1))/(2*pi);w2(i)=(EL(5)-EL(3))/(2*pi);w3(i)=(EL(5)-EL(1))/(2*pi);w4(i)=(EL(5)-EL(1))/(2*pi)/2;
   end
%    delete(gcp('nocreate'));%¹Ø±ÕPool
   x=-0.02:0.1/100:0.02;
   figure;
   plot(x,g01/10^9,x,g02/10^9,'--',x,g03/10^9,':',x,g12/10^9,'-.',x,g13/10^9);
   legend('g_{01}','g_{02}','g_{03}','g_{12}','g_{13}')
%    xlabel('FluxBias');ylabel('ÆµÂÊv/Hz');
   figure;
   plot(x,chi01/10^9,x,chi12/10^9,'--',x,chi21/10^9,':');
   legend('\chi_{01}','\chi_{12}','\chi_{21}')
end