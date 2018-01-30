tic;
% f = @(t)10+3*sin(2*pi*30*t)+5*sin(2*pi*60*t)+9*sin(2*pi*120*t);
f = @(t) 0.*(t>=0&t<1)+sin(2*pi*5*t).*(t>=1&t<2.5)+0.*(t>=2.5&t<4);
% f = @(t) exp(-(t-6).^2/2/(0.01^2));
fs = 300;
N = 4096;
t = linspace(0,N/fs,N);
s = f(t);
y0 = fft(s);
y1 = fftshift(y0);
y1 = y1/N*2;%Ҫ����N/2���Ա�֤����
y1(1) = y1(1)/2;

freq0 = linspace(0,fs,N);
freq1 = linspace(-fs/2,fs/2,N);

subplot(2,3,1);
plot(t,s);hold on;
xlabel('t');
title('ԭʼ�ź�');

subplot(2,3,2);
plot(freq0,abs(y0));hold on;
xlabel('freq');
title('FFT ģֵ');

subplot(2,3,3);
plot(freq0,phase(y0));hold on;
xlabel('freq');
title('FFT ��λ');

subplot(2,3,4);
plot(freq1,abs(y1));hold on;
xlabel('freq');
title('����-Ƶ������ͼ');

subplot(2,3,5);
plot(freq1,phase(y1));hold on;
xlabel('freq');
title('��λ-Ƶ������ͼ');

toc;