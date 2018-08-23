wvLn = 3000;
tData = [zeros(1,1),-1e4*ones(1,wvLn),zeros(1,1)];
af_fft = fftshift(fft(tData));
fs_ideal = 2;
ieal_f = fftshift(qes.util.fftFreq(length(tData),fs_ideal));

% af_fft = exp(2j*pi)

figure();plot(tData);
figure();plot(ieal_f,abs(af_fft));

%%
load('D:\data\20170721\impulseResponse_noFilter_1.mat');
xfrFunc_imp = com.qos.waveform.XfrFuncNumeric(IMPR_NoFilter_fs25G_1,25e9/2e9,0,false);

f = linspace(-0.5,0.5,120);

xfrFuncData = (xfrFunc_imp.eval(f))';
xfrFuncData = xfrFuncData(1:2:end)+1j*xfrFuncData(2:2:end);
figure();plot(f,real(xfrFuncData));
%%
af_cal = af_fft./xfrFuncData;
% af_cal = af_fft;
figure();%plot(real(af_fft));
hold on;plot(real(af_cal));
%%
tData_c = ifft(fftshift(af_cal));
figure();plot(tData);hold on;plot(real(tData_c));

%%
ustcaddaObj.SendWave(3,tData+32768);
ustcaddaObj.runReps = 5e4;
ustcaddaObj.Run(false);

pause(3);

osc.acqlength = 20000;
osc.datastop=osc.acqlength;
osc.acquisitionmode='AVE';
osc.acquisitionnumavg=100;
stepResponse_biasTWithC = osc.getdata();
figure();plot(stepResponse_biasTWithC);
%%
data_fft = fftshift(fft(data_rect));
data_f = 25/2*linspace(-0.5,0.5,length(data_fft));
figure();plot(data_f,real(data_fft));

df = 1/length(tData);
f = -0.5:df:0.5-df;
xfrFuncData = interp1(data_f,data_fft,f);
hold on; plot(f,real(xfrFuncData));
%%
load('D:\data\20170721\osc_data_rect_fs25G.mat');
data_rect = [data_rect.',zeros(1,numel(data_rect)*9)];

fs = 25;
data_rect = data_rect - mean(data_rect(end-100:end));
figure();plot((0:numel(data_rect)-1)/fs/10, data_rect);
xlabel('ns');

data_rect_yf = fftshift(fft(data_rect));
data_rect_f = fftshift(qes.util.fftFreq(length(data_rect),fs*10));

idn = abs(data_rect_f) > 1;
data_rect_yf(idn) = 0;
data_rect_f(idn) = 0;

figure();plot(data_rect_f,abs(data_rect_yf));hold on;
plot(ieal_f,abs(af_fft)*max(abs(data_rect_yf))/max(abs(af_fft)));
xlabel('GHz');