function FilteredSignal=BandStopFilter(Signal2Filter,f1,f3,fsl,fsh,rp,rs,SignalSampleRate)
%带阻滤波
%使用注意事项：通带或阻带的截止频率与采样率的选取范围是不能超过采样率的一半
%即，f1,f3,fs1,fsh,的值小于 Fs/2
%x:需要带通滤波的序列
% f 1：通带左边界
% f 3：通带右边界
% fs1：衰减截止左边界
% fsh：衰变截止右边界
%rp：最大纹波DB数设置
%rs：截止区衰减DB数设置
%FS：序列x的采样频率
% f1=300;f3=500;%通带截止频率上下限
% fsl=200;fsh=600;%阻带截止频率上下限
% rp=0.1;rs=30;%通带边衰减DB值和阻带边衰减DB值
% Fs=2000;%采样率
%
wp1=2*pi*f1/SignalSampleRate;
wp3=2*pi*f3/SignalSampleRate;
wsl=2*pi*fsl/SignalSampleRate;
wsh=2*pi*fsh/SignalSampleRate;
wp=[wp1 wp3];
ws=[wsl wsh];
[n,wn]=cheb1ord(ws/pi,wp/pi,-rp,-rs);
[bz1,az1]=cheby1(n,-rp,wp/pi,'stop');
% 查看设计滤波器的曲线
% [h,w]=freqz(bz1,az1,256,SignalSampleRate);
% h=20*log10(abs(h));
% figure;plot(w,h);title('所设计滤波器的通带曲线');grid on;
FilteredSignal=filter(bz1,az1,Signal2Filter);
end