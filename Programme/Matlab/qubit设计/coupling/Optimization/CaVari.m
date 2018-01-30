function error = CaVari(Ej,Ec,alpha,beta,Cc,Csh,k,Imin,path)
%example:error = CaVari(148e9,3.29e9,0.513,1e-6,12.19e-15,30e-15,5,'data.txt')
kappa = 0;sigma = 0;Cr = 150e-15;nk = 5;nl = 10;nm = 2;nlevels = 20;
Ej = Ej*10^9;Ec = Ec*10^9;beta = beta*10^(-6);Cc = Cc*10^(-15);Csh = Csh*10^(-15);

if beta < 1e-6
    beta = 1e-6;    % beta can not be zero !
end
%% 
% fileID = fopen(path);
% input = textscan(fileID,'%f %f %f');
% I = input{1};
% V01 = input{2};
% V02 = input{3};
% fclose(fileID);
V01 = load(path,'Freq_P01');
V01 = V01.Freq_P01;
V02 = load(path,'Freq_P02');
V02 = V02.Freq_P02;
%%
% [~,idx] = min(V01);
% Imin = I(idx);
error = 0;len = length(V01);

parfor i = 1:len
    FluxBias = k*(i-Imin)+0.5;
    [EL,~] = CaFluxQubit(Ej,Ec,alpha,beta,kappa,sigma,Cc,Cr,Csh,FluxBias,nk,nl,nm,nlevels);
    if  V02(i) == 0
        error = error + abs(((EL(3)-EL(1))/10^9-V01(i)));
    else
        error = error + abs(((EL(3)-EL(1))/10^9-V01(i))) + abs(((EL(5)-EL(1))/2/10^9-V02(i)));
    end
    
end


error = error/len;
end