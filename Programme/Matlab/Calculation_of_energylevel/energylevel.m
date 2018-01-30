function EL=energylevel(Eca,Eja,Csh,alpha,FluxBias)
%%sample:energylevel(0.35,43,51,0.43,0.5)
e = 1.602*10^(-19);
h=6.626069311e-034;
Csh=Csh/10^6;
Ecb = alpha*Eca;
Eja = h*Eja;Ejb = Eja/alpha;
Cja = e*e/(2*h*Eca);Cjb = e*e/(2*h*Ecb);
faie = FluxBias+pi;
C=zeros(3);
C(1,1) = Cja+Cjb+Csh;C(1,2) = -Cja-Csh;     C(1,3) = 0;
C(2,1) = -Cja-Csh;   C(2,2) = Cja+Cjb+Csh;  C(2,3) = -Cjb;
C(3,1) = 0;          C(3,2) = -Cjb;         C(3,3) = Cjb;              %%电容的矩阵
C1=inv(C);      %%求逆
EC = zeros(3);EC = e*e/2*C1;
H = zeros(21*21);
for i = -10:10
    for j = -10:10
        for m = -10:10
            for n = -10:10          %%|i,j> |m,n>
                H1 = 0;H2 = 0;H3 = 0;
                for p = 1:3
                    for q = 1:3
                        test = EC(p,q);
                        switch p
                            case 1
                                test = test*i;
                            case 2
                                test = test*j;
                            case 3
                                test = test*(-i-j);
                        end
                        switch q
                            case 1
                                test = test*m;
                            case 2
                                test = test*n;
                            case 3
                                test = test*(-m-n);
                        end
                        H1 = H1+test;
                    end
                end  %%H1
                H1 = 4*H1*Kdelta(i,m)*Kdelta(j,n);
                
                m1=m+1;n1=n+1;
                m2=m-1;n2=n-1;
                if m1>10 || n1>10
                    H21=0;
                else
                    H21 = -Eja/2*exp(-1i*faie)*Kdelta(i,m1)*Kdelta(j,n1);
                end
                if m2<(-10) || n2<(-10)
                    H22=0;
                else
                    H22 = -Eja/2*exp(1i*faie)*Kdelta(i,m2)*Kdelta(j,n2);
                end
                H2 = Eja+H21+H22;       %%求H2
                
                if m1>10
                    H31=0;
                else
                    H31 = Kdelta(i,m1)*Kdelta(j,n)/2;
                end
                if m2<-10
                    H32=0;
                else
                    H32 = Kdelta(i,m2)*Kdelta(j,n)/2;
                end
                if n1>10
                    H33=0;
                else
                    H33 = Kdelta(i,m)*Kdelta(j,n1)/2;
                end
                if n2>10
                    H34=0;
                else
                    H34 = Kdelta(i,m)*Kdelta(j,n2)/2;
                end
                H3 = Ejb*(2-H31-H32-H33-H34);
                x = (i+10)*21+j+11;
                y = (m+10)*21+n+11;
                H(x,y) = H1+H2+H3;
            end
        end
    end
end

EL=eig(H);
EL=EL/h;
EL(5:end)=[];
end

    
        
                            
                        
function f=Kdelta(x1,x2)
if x1==x2
    f=1;
else f=0;
end
end