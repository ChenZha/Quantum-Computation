Ng=0.25:0.01:0.8;
L=length(Ng);
N1=[0 1];
N2=[0 1];
EL=zeros(L);
for ii=1:2
    for jj=1:2
        for kk=1:L
            EL(kk,:)=580*(Ng-N1(ii)).^2+671*(Ng(kk)-N2(jj))^2+95*N1(ii)*N2(jj);   %(Ng-N1(ii))*(Ng(kk)-N2(jj));
        end
        surf(Ng,Ng,EL);
        hold on;
    end
end
xlabel('Ng1');
ylabel('Ng2');