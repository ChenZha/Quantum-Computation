matlabpool open 4
options = optimset('UseParallel','always');
x0 = [0.2; 50; 0.2; 0.65];
lb = [0.1; 30; 0.10; 0.5];
ub = [0.4; 120; 0.4; 0.8]; 
[x,fval] = fmincon(@SpectrumLineErrorFcn_Jc_Cc_S_Alpaha_high,x0,[],[],[],[],lb,ub)
save('FitParameters.mat','x');
disp('SpectrumLineErrorFcn_Jc_Cc_S_Alpaha_high done')
matlabpool close