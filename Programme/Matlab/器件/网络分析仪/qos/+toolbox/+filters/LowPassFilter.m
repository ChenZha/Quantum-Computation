function y=LowPassFilter(x,fp,fs,rp,rs,Fs)
% low pass filter
% x:需要带通滤波的序列
% fp：通带右边界
% fs：衰变截止右边界
% rp：最大纹波DB数设置
% rs：截止区衰减DB数设置
% FS：序列x的采样频率

wp=2*fp/Fs;
ws=2*fs/Fs;
[N,wn]=buttord(wp,ws,rp,rs,'s');
[b,a]=butter(N,wn);

% % view filter
% freqz(b,a,512,Fs);

y=filter(b,a,x);
end