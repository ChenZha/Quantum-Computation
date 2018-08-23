function para=T1_fit_1(x,y,beta0)
modelfun=@(a,x)(a(1)*exp(-x/a(2)));
para=nlinfit(x,y,modelfun,beta0);

figure;
scatter(x,y);
hold on;
plot(x,para(1)*exp(-x/para(2)));
title(['t1:',num2str(para(2)/2000),'us   ',num2str(para(1)),'exp(-x/',num2str(para(2)),')'])
end



