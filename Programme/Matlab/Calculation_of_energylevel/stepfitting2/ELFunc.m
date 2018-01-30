function [ data ] = ELFunc( x,c )
%ELFUNC Summary of this function goes here
%   Detailed explanation goes here
%   c = [Ej,Ec,alpha,beta,kappa,sigma]
nEL = length(x);
Ej = c(1);
Ec = c(2);
alpha = c(3);
beta = c(4);
kappa = c(5);
sigma = c(6);
nk = 5;
nl = 10;
nm = 2;
nlevels = (nEL+1)*2;
Fluxbiases = ranking(x);
nFluxbiases = length(Fluxbiases);
ELs = zeros(nlevels,nFluxbiases);
for ii = 1:nFluxbiases
    Fluxbias = Fluxbiases(ii);
    EL = TriJFlxQbtEL(Ej,Ec,alpha,beta,kappa,sigma,Fluxbias,nk,nl,nm,nlevels);
    ELs(:,ii) = EL;
end
data = cell(1:nEL);
E0 = (ELs(1,:)+ELs(2,:))/2;
for ii = 1:nEL
    Ei = (ELs(ii*2+1,:)+ELs(ii*2+2,:))/2-E0;
    data{ii} = [Fluxbiases;
        Ei];
end
end

function Fluxbiases = ranking(x)
Fluxbiases = [];
nx = length(x);
for ix = 1:nx
    nnx = length(x{ix});
    for iix = 1:nnx
        nf = length(Fluxbiases);
        currentx = x{ix}(iix);
        if nf ==0
            Fluxbiases = currentx;
        else
            for iif = 1:nf+1
                if iif == nf+1
                    Fluxbiases = [Fluxbiases currentx];
                elseif currentx < Fluxbiases(iif)
                    Fluxbiases = [Fluxbiases(1:iif-1) currentx Fluxbiases(iif:end)];
                elseif currentx == Fluxbiases(iif)
                    break;
                else
                end
            end
        end
    end
end
end
