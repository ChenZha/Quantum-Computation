function test = CaFit(path)
% kappa = 0;sigma = 0;Cr = 150e-15;nk = 5;nl = 10;nm = 2;nlevels = 20;
%% 

fileID = fopen(path);
input = textscan(fileID,'%f %f');
x = input{1};
y = input{2};
fclose(fileID);
%%

test0 = [70e9,1e9,0.5,0.0001,1.19e-15,0,4,1.9];
EL02(test0,1);
test=nlinfit(x,y,@EL02,test0);
%%
% test0 = [70,1,1.9];
% test=nlinfit(I,V,@myfun,test0);
end
function y = EL02(test,x)
    kappa = 0;sigma = 0;Cr = 150e-15;nk = 5;nl = 10;nm = 2;nlevels = 20;
    hbar=1.054560652926899e-034;
    h = hbar*2*pi;
    FluxBias = test(7)*(x-test(8))+0.5;
    [el,~] = CaFluxQubit(test(1),test(2),test(3),test(4),kappa,sigma,test(5),Cr,test(6),FluxBias,nk,nl,nm,nlevels);
    y = (el(5)-el(1))/10^9;
end
function y=myfun(a,x)
y=exp(x*a(1))./(1+(x*a(2)).^a(3));
end