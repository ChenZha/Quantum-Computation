% %% ��������
% [filename,path] = uigetfile('*.s?p','Select a Touchstone(*.s1p, *.s2p, *.s3p,...) datafile:');
% [freq, data, freq_noise, data_noise, Zo] = SXPParse(fullfile(path,filename));
% S21 = data(2,1,:);
%%

S21 = z(end,:);
S21 = S21(:)';
ang21 = unwrap(angle(S21));
mag21 = abs(S21);
freq = y;
%% normalize
%%%%% ����, ����һ��������һ�������ݷ���ƽ��ֵ
mag21_n = mag21/mean([mag21(1),mag21(end)]);
%%%%% ��λ����ȥ��һ��������һ����������λ������ֵ
ang21_n  = ang21 - linspace(ang21(1),ang21(end),length(ang21));
S21_n = mag21_n.*(cos(ang21_n)+1i*sin(ang21_n));

%% plot
figure(); plot(freq,abs(S21_n),'.b');
xlabel('f'); ylabel('Normalized S_{21} Amplitude');
figure(); plot(freq,angle(S21_n),'.b'); 
xlabel('f'); ylabel('Normalized S_{21} Phase');
figure(); plot(real(S21_n),imag(S21_n),'.b'); pbaspect([1 1 1]);
xlabel('Re[S_{21}^{-1}]'); ylabel('Im[S_{21}^{-1}]');

%% ����Ƶ��
% f0 = 6.628410050063775e+09;
f0 = 5.301872e+09;

%% ��� ��Զ�빲��㲻����ģ�ͣ�����Ҫȥ��������Ӱ����Ͼ��ȣ�
t1 = 30; % ȥ��ǰ�� t1 ���� 
t2 = 30; % ȥ����� t2 ����
[Qi, Qc] = FitQ((freq(1+t1:end-t2)-f0)/f0,1./S21_n(1+t1:end-t2),true);
clc;
Qi, Qc