% %% 导入数据
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
%%%%% 幅度, 除第一个点和最后一个点数据幅度平均值
mag21_n = mag21/mean([mag21(1),mag21(end)]);
%%%%% 相位，减去第一个点和最后一个点数据相位的线性值
ang21_n  = ang21 - linspace(ang21(1),ang21(end),length(ang21));
S21_n = mag21_n.*(cos(ang21_n)+1i*sin(ang21_n));

%% plot
figure(); plot(freq,abs(S21_n),'.b');
xlabel('f'); ylabel('Normalized S_{21} Amplitude');
figure(); plot(freq,angle(S21_n),'.b'); 
xlabel('f'); ylabel('Normalized S_{21} Phase');
figure(); plot(real(S21_n),imag(S21_n),'.b'); pbaspect([1 1 1]);
xlabel('Re[S_{21}^{-1}]'); ylabel('Im[S_{21}^{-1}]');

%% 共振频率
% f0 = 6.628410050063775e+09;
f0 = 5.301872e+09;

%% 拟合 （远离共振点不符合模型，数据要去掉，否则影响拟合精度）
t1 = 30; % 去掉前面 t1 个点 
t2 = 30; % 去掉最后 t2 个点
[Qi, Qc] = FitQ((freq(1+t1:end-t2)-f0)/f0,1./S21_n(1+t1:end-t2),true);
clc;
Qi, Qc