function NeuNetExm()
%%
t=[0 3.9 4.1 7.3 8.4 13.1 14.8 16.4 17.7 19 19.7 20.3 21.2 24.5 26.3 27.8 28.9 29 29.8 31.1 32.8 33.5 34.5 35.6 36.2 37.6 37.8 38.7 39.4 40.3 41 41.4 42.5 43.9 45 45.7 46.9 47.8 49 49.4 51.4 53 54 55.6 56.9 57.5 58.9 ];
R=[100.16 101.87 101.97 102.99 103.43 105.23 105.89 106.54 107.01 107.52 107.77 108.01 108.39 109.64 110.33 110.90 111.32 111.41 111.86 112.53 112.63 113.10 113.52 113.94 114.39 114.52 114.92 115.26 115.87 115.90 116.27 116.96 117.32 117.71 118.13 118.34 118.62 118.96 119.59 120.20 120.68 121.33 121.90 122.17 122.94 123.27 123.85];

subplot(2,2,1);plot(t,R,'r*'); hold on; 
% R=0.0002*t^2+0.3676*t+100.3780;
plot(t,0.0002*t.^2+0.3676*t+100.3780,':');   %绘制不含噪声的余弦曲线 
legend('训练样本','正确的曲线')
title('样本数据');

p=polyfit(t,R,2)
y1=polyval(p,t);
subplot(223),plot(t,R,'r*',t,0.0002*t.^2+0.3676*t+100.3780,'b:',t,y1,'g');
legend('训练样本','正确的曲线','拟合曲线'),grid;
% xlabel(sprintf('多项式:y=%.2fx^2+%.2fx+%.2f',p(1),p(2),p(3)));
% pretty(poly2sym(p))
 xlabel(sprintf('多项式:%s',poly2str(p,'x')));
title('最小二乘法的多项式拟合');

net=newff(minmax(t),[20,1],{'tansig','purelin'}); %创建一个新的前向神经网络 
net.trainFcn='trainlm'; %设置训练方法及参数 
net.trainParam.epochs=500; 
net.trainParam.goal=1e-6; 
net=init(net);%初始化网络 

[net,tr]=train(net,t,R); %调用相应算法训练BP网络 

A=sim(net,t); %对BP网络进行仿真 
E=R-A; %计算仿真误差 
MSE=mse(E);%均方误差 

subplot(224);plot(t,R,'*r',t,0.0002*t.^2+0.3676*t+100.3780,'b:',t,A,'g'); %绘制拟合结果曲线 
legend('训练样本*','真实曲线','拟合曲线');
xlabel(sprintf('均方误差（MSE）：%e',MSE));
title('神经网络拟合');


end
