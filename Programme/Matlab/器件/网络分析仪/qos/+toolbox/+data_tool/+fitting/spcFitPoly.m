function p = spcFitPoly(x,y,z,order)
nr = length(x);
nc = length(y);
z(isnan(z))=mean(z(~isnan(z)));
f01 = NaN(1,nr);
for ii = 1:nr
    [~,ind] = max(z(ii,:));
    f01(ii) = y(ind);
end
figure();
imagesc(x,y,z.');
hold on;
plot(x,f01,'r+');
set(gca,'YDir','normal');

p = polyfit(x,f01,order);

xf = linspace(x(1),x(end),50);
yf = polyval(p,xf);
plot(xf,yf,'r');

end