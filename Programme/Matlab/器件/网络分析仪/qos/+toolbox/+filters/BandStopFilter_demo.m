function BandStopFilter_demo
%�����˲�������
fs=0.5e6;
t=(1:0.25e6)/fs;
y=sin(2*pi*5000*t)+sin(2*pi*18670*t)+sin(2*pi*50e3*t);
figure;
hua_fft(y,fs,1);
title('Original spectrum');
xlabel('f');
ylabel('amp');
z = BandStopFilter(y,15670,22670,17670,19670,-0.1,-30,fs);
figure;
hua_fft(z,fs,1);
title('Spectrum after filter');
xlabel('f');
ylabel('amp');
end


function hua_fft(y,fs,style,varargin)
%��style=1,����ֵ�ף���style=2,��������;��style=�����ģ���ô����ֵ�׺͹�����
%��style=1ʱ�������Զ�����2����ѡ����
%��ѡ�������������������Ҫ�鿴��Ƶ�ʶε�
%��һ������Ҫ�鿴��Ƶ�ʶ����
%�ڶ�������Ҫ�鿴��Ƶ�ʶε��յ�
%����style���߱���ѡ���������������뷢��λ�ô���
nfft= 2^nextpow2(length(y));%�ҳ�����y�ĸ���������2��ָ��ֵ���Զ��������FFT����nfft��
%nfft=1024;%��Ϊ����FFT�Ĳ���nfft
  y=y-mean(y);%ȥ��ֱ������
y_ft=fft(y,nfft);%��y�źŽ���DFT���õ�Ƶ�ʵķ�ֵ�ֲ�
y_p=y_ft.*conj(y_ft)/nfft;%conj()��������y�����Ĺ������ʵ���Ĺ������������
y_f=fs*(0:nfft/2-1)/nfft;
% T�任���Ӧ��Ƶ�ʵ�����
% y_p=y_ft.*conj(y_ft)/nfft;%conj()��������y�����Ĺ������ʵ���Ĺ������������
if style==1
    if nargin==3
        plot(y_f,2*abs(y_ft(1:nfft/2))/length(y));%matlab�İ����ﻭFFT�ķ���
        %ylabel('��ֵ');xlabel('Ƶ��');title('�źŷ�ֵ��');
        %plot(y_f,abs(y_ft(1:nfft/2)));%��̳�ϻ�FFT�ķ���
    else
        f1=varargin{1};
        fn=varargin{2};
        ni=round(f1 * nfft/fs+1);
        na=round(fn * nfft/fs+1);
        plot(y_f(ni:na),abs(y_ft(ni:na)*2/nfft));
    end

elseif style==2
            plot(y_f,y_p(1:nfft/2));
            %ylabel('�������ܶ�');xlabel('Ƶ��');title('�źŹ�����');
    else
        subplot(211);plot(y_f,2*abs(y_ft(1:nfft/2))/length(y));
        ylabel('��ֵ');xlabel('Ƶ��');title('�źŷ�ֵ��');
        subplot(212);plot(y_f,y_p(1:nfft/2));
        ylabel('�������ܶ�');xlabel('Ƶ��');title('�źŹ�����');
end
end