function TriJEGap4EcAlpha(Ej,Ec,alpha)
% Ec,alpha: array
clc;
FluxQuantum = 2.067833636e-15;
PlanksConst = 6.626068E-34;
ee = 1.602176e-19;
N1 = length(Ec);
N2 = length(alpha);
if N2<2
    error('alpha is not an array, impossible to plot a curve !')
end
EGap = zeros(N1,N2);
disp('Calculating, please wait ...');
matlabpool;
figure(int32(1e5*rand()));
for jj = 1:N1
parfor ii = 1:N2
        EL = TriJFlxQbtEL(Ej,Ec(jj),alpha(ii),0,0,0,0.5,10,20,1,4);  % since beta = 0;
        EGap(jj,ii) = (EL(3) + EL(4) - EL(2) -EL(1))/2;
end
hold on;
plot(alpha,EGap(jj,:));
xlabel('\alpha');
ylabel('\Delta (GHz)');
end
matlabpool close;
clc;
YMAX = max(EGap);
axis([min(alpha),max(alpha),0,YMAX]);



