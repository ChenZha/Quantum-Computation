function y=LowPassFilter(x,fp,fs,rp,rs,Fs)
% low pass filter
% x:��Ҫ��ͨ�˲�������
% fp��ͨ���ұ߽�
% fs��˥���ֹ�ұ߽�
% rp������Ʋ�DB������
% rs����ֹ��˥��DB������
% FS������x�Ĳ���Ƶ��

wp=2*fp/Fs;
ws=2*fs/Fs;
[N,wn]=buttord(wp,ws,rp,rs,'s');
[b,a]=butter(N,wn);

% % view filter
% freqz(b,a,512,Fs);

y=filter(b,a,x);
end