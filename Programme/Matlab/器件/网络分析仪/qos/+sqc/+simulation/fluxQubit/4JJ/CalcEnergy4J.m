function [result,time]=CalcEnergy4J(Ej1_v,Ej2_v,Ej3_v,Ej4_v,Ec_v,alpha_v,beta_v,f_v,nmax_v,ng1_v,ng2_v,ng3_v,nelevels)
% [result,time]=CalcEnergy(Ej,Ec,alpha,f,nmax,ng1,ng2,nelevels)
%     Ej - Josephson energy E_j=\frac{I_c \phi_0}{2 \pi}
%     Ec - charging energy E_c=\frac{e^2}{2 C}
%     alpha - relative size of the top junction compared to the left and right junctions
%     f - frustration f=\frac{B A}{\phi_0}
%     nmax - maximum number of cooper pairs on an island - charge states run from -nmax to nmax
%     ng1 - gate charge induced on island 1 (top left island)
%     ng2 - gate charge induced on island 2 (top right island)
%     nelevels - number of lowest energy levels
%
% all input parameters (beside nelevels) can also be given as vectors.
%
%    result has the form: Ej, Ec, alpha, f, nmax, ng1, ng2, E0, E1, E2, ...
%    time hast the form:  expired time (sec), percentage done
%
% Example:
%    [result,time]=CalcEnergy(1,1/80,0.8,[0.45:0.001:0.5],6,0,0,5);
%    plot(result(4,:),result(8:12,:),'.');
%
% CalcEnergy 1.0  2.10.2001 ? Hannes Majer (majer@qt.tn.tudelft.nl)

result=[];
table=[];
time=[];

Ej1_n=length(Ej1_v);
Ej2_n=length(Ej2_v);
Ej3_n=length(Ej3_v);
Ej4_n=length(Ej4_v);
Ec_n=length(Ec_v);
alpha_n=length(alpha_v);
beta_n=length(beta_v);
f_n=length(f_v);
nmax_n=length(nmax_v);
ng1_n=length(ng1_v);
ng2_n=length(ng2_v);
ng3_n=length(ng3_v);

wb = waitbar(0,'Please wait...');
tic;

for Ej1_c=1:Ej1_n
   Ej1=Ej1_v(Ej1_c);
   for Ec_c=1:Ec_n
      Ec=Ec_v(Ec_c);
      for alpha_c=1:alpha_n
         alpha=alpha_v(alpha_c);
         for beta_c=1:beta_n
             beta=beta_v(beta_c);
             for f_c=1:f_n
                 f=f_v(f_c);
                 for nmax_c=1:nmax_n
                     nmax=nmax_v(nmax_c);
                     for ng1_c=1:ng1_n
                         ng1=ng1_v(ng1_c);
                         for ng2_c=1:ng2_n
                             ng2=ng2_v(ng2_c);
                             for ng3_c=1:ng3_n
                                 ng3=ng3_v(ng3_c)
                                 for Ej2_c=1:Ej2_n
                                     Ej2=Ej2_v(Ej2_c);
                                     for Ej3_c=1:Ej3_n
                                         Ej3=Ej3_v(Ej3_c);
                                         for Ej4_c=1:Ej4_n
                                             Ej4=Ej4_v(Ej4_c);
                                             % disp(['Ej = 'num2str(Ej) ' Ec = 'num2str(Ec) ' alpha = ' num2str(alpha) ' f = ' num2str(f) ' nmax = ' num2str(nmax) ' ng1 = ' num2str(ng1) ' ng2 = ' num2str(ng2)])
                                             K=QubitHamiltonian4jj(Ej1,Ej2,Ej3,Ej4,Ec,alpha,beta,f,nmax,ng1,ng2,ng3);
                                             %dHdEj101sq=Nondiagonal4jj_Ej1(Ej1,Ej2,Ej3,Ej4,Ec,alpha,beta,f,nmax,ng1,ng2,ng3);
                                             %dHdEj201sq=Nondiagonal4jj_Ej2(Ej1,Ej2,Ej3,Ej4,Ec,alpha,beta,f,nmax,ng1,ng2,ng3);
                                             %dHdEj301sq=Nondiagonal4jj_Ej3(Ej1,Ej2,Ej3,Ej4,Ec,alpha,beta,f,nmax,ng1,ng2,ng3);
                                            % dHdEj401sq=Nondiagonal4jj_Ej4(Ej1,Ej2,Ej3,Ej4,Ec,alpha,beta,f,nmax,ng1,ng2,ng3);
                                             %dHdng101sq=Nondiagonal4jj_ng1(Ej1,Ej2,Ej3,Ej4,Ec,alpha,beta,f,nmax,ng1,ng2,ng3);
                                             %dHdng201sq=Nondiagonal4jj_ng2(Ej1,Ej2,Ej3,Ej4,Ec,alpha,beta,f,nmax,ng1,ng2,ng3);
                                            % dHdng301sq=Nondiagonal4jj_ng3(Ej1,Ej2,Ej3,Ej4,Ec,alpha,beta,f,nmax,ng1,ng2,ng3);
                                            % dHdnf01sq=Nondiagonal4jj_nf(Ej1,Ej2,Ej3,Ej4,Ec,alpha,beta,f,nmax,ng1,ng2,ng3);
                                             %dHdnf12sq=Nondiagonal4jj_nf_12(Ej1,Ej2,Ej3,Ej4,Ec,alpha,beta,f,nmax,ng1,ng2,ng3);
                                             %dHdnf02sq=Nondiagonal4jj_nf_02(Ej1,Ej2,Ej3,Ej4,Ec,alpha,beta,f,nmax,ng1,ng2,ng3);
                                             elevels=eigs(K,8,-10000);
                                             elevels=sort(elevels);
                                             EnergyLevels=elevels(1:nelevels);
                                             E01=elevels(2)-elevels(1);
                                             %E02=elevels(3)-elevels(1);
                                             %result=[result [Ej4;f;ng3;E01;dHdEj401sq;dHdng301sq;dHdnf01sq;]];
                                             %result=[result [Ej4;E01]];
                                             result=[result [f;E01;elevels(1);elevels(2);elevels(3);elevels(4);elevels(5);elevels(6)]];
                                             %result=[result [E01;E02]];
                                             %table(alpha_c,beta_c)=E01;
                                             result_igor=result';
                                             save result080218b.out result_igor -ASCII;%File name?
                                             %save table061019a.out table -ASCII;%File name?
                                             counter=ng2_c;
                                             counter=counter + (ng1_c-1)*ng2_n;
                                             counter=counter + (nmax_c-1)*ng2_n*ng1_n;
                                             counter=counter + (f_c-1)*nmax_n*ng2_n*ng1_n;
                                             counter=counter + (alpha_c-1)*f_n*nmax_n*ng2_n*ng1_n;
                                             counter=counter + (Ec_c-1)*alpha_n*f_n*nmax_n*ng2_n*ng1_n;
                                             counter=counter + (Ej1_c-1)*Ec_n*alpha_n*f_n*nmax_n*ng2_n*ng1_n;
                                             done=counter/(Ej1_n*Ec_n*alpha_n*f_n*nmax_n*ng2_n*ng1_n);
                                                waitbar(done);
                                             time=[time [toc;done]];
                                             ttg=round(toc/done-toc);
                                             disp([num2str(done*100,'%0.1f') '% done, ' num2str(floor(ttg/60)) ' minutes ' num2str(rem(ttg,60)) ' seconds to go']);
                                             disp(' ');
                                         end
                                     end
                                 end
                             end
                         end
                     end
                 end
             end
         end
     end
 end
end
close(wb)

%D1=6.7;
%D2=17.5;
%E1=1165;
%E2=835
%E01_2l=(D1^2*f_v./f_v+E1^2*(f_v-0.5*f_v./f_v).^2).^0.5;
%E02_2l=2*(D2^2*f_v./f_v+E2^2*(f_v-0.5*f_v./f_v).^2).^0.5;
%plot(Ej4_v,result(2,:),'r.');
%hold on
%plot(f_v,E01_2l,f_v,E02_2l);
%hold off