% transmon = Xmon(86e-15,8000);
% x = -1:0.001:1;
% level = zeros(length(x),5);
% for i = 1:length(x)
%     a = transmon.EL(x(i),50);
%     level(i,:) = a(1:5);
% end
% set(gca,'fontsize',15);
% figure();plot(x,level(:,1));hold on;
% plot(x,level(:,2));hold on;
% plot(x,level(:,3));hold on;
% plot(x,level(:,4));hold on;
% plot(x,level(:,5));hold on;
% 
% figure();plot(x,level(:,2)-level(:,1));hold on;
% plot(x,level(:,3)-level(:,2));hold on;
% plot(x,level(:,4)-level(:,3));hold on;
% plot(x,level(:,5)-level(:,4));hold on;


t = 0:0.001:3.5;
f = @(t) sin(2*pi*5*t).*(t>=1&t<2.5);
figure();plot(t,f(t));
figure();plot(t,fftshift(fft(f(t))));

