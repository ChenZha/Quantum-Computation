function specplot(Ej,Ec,alpha,beta,kappa,sigma,nk,nl,nm,nlevels,func)
%     example:specplot(148,3.29,0.613,0,0,0,5,10,2,20,@TriJFlxQbtEL);
%     [a1,a2] = textread('data.txt','%f%f','headerlines',4);a1=a1-141;a1=a1/750;
%     [b1,b2] = textread('data2.txt','%f%f','headerlines',4);b1=b1-141;b1=b1/750;
%     [d1,d2] = textread('data3.txt','%f%f','headerlines',4);d1=d1-141;d1=d1/750;
%     plot(a1,a2,b1,b2,d1,d2);
%     hold on;
                 
   parpool(3);

    
   parfor i=1:41
       [EL,SL] = func(Ej,Ec,alpha,beta,kappa,sigma,0.48+(i-1)*0.001,nk,nl,nm,nlevels);
       w1(i)=EL(3)-EL(1);w2(i)=EL(5)-EL(3);w3(i)=EL(5)-EL(1);w4(i)=(EL(5)-EL(1))/2;
%        w1(i)=(EL(3)-EL(1))/(2*pi);w2(i)=(EL(5)-EL(3))/(2*pi);w3(i)=(EL(5)-EL(1))/(2*pi);w4(i)=(EL(5)-EL(1))/(2*pi)/2;
   end
   delete(gcp('nocreate'));%¹Ø±ÕPool
   x=-0.02:0.1/100:0.02;
   figure;
   plot(x,w1);hold on;
   plot(x,w2,'--');hold on;
   plot(x,w3,'-.');hold on;
   plot(x,w4,':');hold on;
   legend('\omega_{01}','\omega_{12}','\omega_{02}','\omega_{02}/2')
   xlabel('FluxBias');
   ylabel('ÆµÂÊv/GHz');
end
