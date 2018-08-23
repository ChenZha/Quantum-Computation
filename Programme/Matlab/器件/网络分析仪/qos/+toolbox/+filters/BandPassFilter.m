function y=BandPassFilter(x,f1,f3,fsl,fsh,rp,rs,Fs)
%��ͨ�˲�
%ʹ��ע�����ͨ��������Ľ�ֹƵ��������ʵ�ѡȡ��Χ�ǲ��ܳ��������ʵ�һ��
%����f1,f3,fs1,fsh,��ֵС�� Fs/2
%x:��Ҫ��ͨ�˲�������
% f 1��ͨ����߽�
% f 3��ͨ���ұ߽�
% fs1��˥����ֹ��߽�
% fsh��˥���ֹ�ұ߽�
%rp������Ʋ�DB������
%rs����ֹ��˥��DB������
%FS������x�Ĳ���Ƶ��
% f1=300;f3=500;%ͨ����ֹƵ��������
% fsl=200;fsh=600;%�����ֹƵ��������
% rp=0.1;rs=30;%ͨ����˥��DBֵ�������˥��DBֵ
% Fs=2000;%������
%
wp1=2*pi*f1/Fs;
wp3=2*pi*f3/Fs;
wsl=2*pi*fsl/Fs;
wsh=2*pi*fsh/Fs;
wp=[wp1 wp3];
ws=[wsl wsh];
%
% ����б�ѩ���˲�����
[n,wn]=cheb1ord(ws/pi,wp/pi,rp,rs);
[bz1,az1]=cheby1(n,rp,wp/pi);
% %�鿴����˲���������
% [h,w]=freqz(bz1,az1,256,Fs);
% h=20*log10(abs(h));
% figure;plot(w,h);title('������˲�����ͨ������');grid on;
y=filter(bz1,az1,x);
end