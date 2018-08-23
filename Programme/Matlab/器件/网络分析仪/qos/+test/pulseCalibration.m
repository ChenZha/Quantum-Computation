%%
cd D:\QOS1.1\qos;
rmpath(genpath('D:\QOS\qos'));
addpath('D:\QOS1.1\qos\dlls');
clc
app.RE
%% Oscilloscope
osc = qes.qHandle.FindByClassProp('qes.hwdriver.hardware',...
                        'name','oscilloscope_dpo70404');
da = qes.qHandle.FindByClassProp('qes.hwdriver.hardware',...
                        'name','da_ustc_1');
daChnl3 = da.GetChnl(3);
padLength = 1000;
com.qos.waveform.Waveform.setPadLength(padLength);
%%
dc = qes.waveform.dc(1,-1.5e4);
gc = [dc,qes.waveform.spacer(100)];
wvData = gc.samples();
% figure();plot(wvData(1,:));
%%
osc.acquisitionmode='AVE';
osc.acqlength = 10000;
osc.datastop=osc.acqlength;
osc.acquisitionnumavg=100;
gcd = qes.waveform.DASequence(gc);
daChnl3.SendWave(gcd,true);
daChnl3.Run(5e4);
pause(5);
data=osc.getdata();%wait_trigger

fs = 1;
y4plot = data(:,1);
t = linspace(0,1e9*length(y4plot)/fs,length(y4plot));
figure();plot(y4plot);
%%

% load('D:\data\20170721\impulseResponse_mini_biasT_12_5G.mat');
% fs = 12.5e9;
wvSeq = [qes.waveform.rect(200,-1.5e4),qes.waveform.spacer(100)];
daSeq = qes.waveform.DASequence(wvSeq);
%%
load('D:\data\20170721\stepResponse_fs25G.mat');
% stepResponse_45MFilter_fs25G = smooth(stepResponse_45MFilter_fs25G,5);
% stepResponse_45MFilter_fs25G = smooth(stepResponse_45MFilter_fs25G,9);
fs_da = 2e9;
fs_osc = 25e9/fs_da;
t = (0:length(stepResponse_fs25G)-1)/fs_osc;
impr = qes.util.derivative(t,stepResponse_fs25G);
figure();plot(t,impr);

IMPR_fa = fftshift(fft(impr));
IMPR_f = fftshift(qes.util.fftFreq(numel(t),fs_osc));
% IMPR_fa = exp(2j*pi*IMPR_f*25.545).*IMPR_fa;
IMPR_fa = exp(2j*pi*IMPR_f*4.67).*IMPR_fa;
ind = abs(IMPR_f)>0.55;
IMPR_f(ind) = [];
IMPR_fa(ind) = [];
            figure();plot(IMPR_f,real(IMPR_fa));
                IMPR_fa = IMPR_fa./sinc(IMPR_f);
            hold on;plot(IMPR_f,real(IMPR_fa));
%%
% xfrFunc_flat = com.qos.waveform.XfrFuncFlat(0.1); %0.13
xfrFunc_lp = com.qos.waveform.XfrFuncFastGaussianFilter(0.13); %0.13
xfrFunc_imp = com.qos.waveform.XfrFuncNumeric(IMPR_f,real(IMPR_fa),imag(IMPR_fa));
f_ = linspace(-0.5,0.5,100);
%             IMPR_fa_ = (xfrFunc_imp.eval(f_)).';
%             figure();plot(f_,IMPR_fa_(1:2:end));

xfrFunc_imp_iverse = xfrFunc_imp.inv();
%             IMPR_fa_ = (xfrFunc_imp_iverse.eval(f_)).';
%             figure();plot(f_,IMPR_fa_(1:2:end));

xfrFunc = xfrFunc_lp.add(xfrFunc_imp_iverse);
% xfrFunc = xfrFunc_lp;
% xfrFunc = com.qos.waveform.XfrFuncGaussianFilter(0.13);
            IMPR_fa_ = (xfrFunc.eval(f_)).';
            figure();plot(f_,IMPR_fa_(1:2:end));

% xfrFunc_x = linspace(0,0.5,51);
% xfrFunc_fit = @(x) -2.6955e+06*x.^10 + 6.6015e+06*x.^9 - 6.788e+06*x.^8 + 3.7937e+06*x.^7 - 1.2445e+06*x.^6 + 2.4056e+05*x.^5 - 25786*x.^4 + 1317.8*x.^3 - 41.675*x.^2 + 2.5854*x + 1.0005;           
            
daSeq_c = qes.waveform.DASequence(wvSeq.copy());
daSeq_c.xfrFunc = xfrFunc;
            wvSamples = daSeq_c.samples();
            figure();plot(wvSamples(1,:));
%%            
daSeq_c = qes.waveform.DASequence(wvSeq.copy());
            wvSamples = daSeq_c.samples();
            hold on;plot(wvSamples(1,:));

%% bias T
wvSeq = [qes.waveform.rect(200,-1.5e4),qes.waveform.spacer(100)];
daSeq = qes.waveform.DASequence(wvSeq);

load('D:\data\20170721\stepResponse_biasTWithC.mat');
fs_da = 2e9;
fs_osc = 25e9/fs_da;
t = (0:length(stepResponse_biasTWithC)-1)/fs_osc;
impr = qes.util.derivative(t,stepResponse_biasTWithC);
figure();plot(t,impr);

IMPR_fa = fftshift(fft(impr));
IMPR_f = fftshift(qes.util.fftFreq(numel(t),fs_osc));
% IMPR_fa = exp(2j*pi*IMPR_f*25.545).*IMPR_fa;
IMPR_fa = exp(2j*pi*IMPR_f*4.67).*IMPR_fa;
ind = abs(IMPR_f)>0.55;
IMPR_f(ind) = [];
IMPR_fa(ind) = [];
            figure();plot(IMPR_f,abs(IMPR_fa));
                 IMPR_fa = IMPR_fa./sinc(IMPR_f);
%             hold on;plot(IMPR_f,real(IMPR_fa));

% ind = abs(IMPR_fa) < 0.3;
% ind(ind) = [];

% xfrFunc_flat = com.qos.waveform.XfrFuncFlat(0.1); %0.13
xfrFunc_lp = com.qos.waveform.XfrFuncFastGaussianFilter(0.07); %0.13
xfrFunc_imp = com.qos.waveform.XfrFuncNumeric(IMPR_f,real(IMPR_fa),imag(IMPR_fa));
f_ = linspace(-0.5,0.5,100);
%             IMPR_fa_ = (xfrFunc_imp.eval(f_)).';
%             figure();plot(f_,IMPR_fa_(1:2:end));

xfrFunc_imp_iverse = xfrFunc_imp.inv();
%             IMPR_fa_ = (xfrFunc_imp_iverse.eval(f_)).';
%             figure();plot(f_,IMPR_fa_(1:2:end));

xfrFunc = xfrFunc_lp.add(xfrFunc_imp_iverse);
% xfrFunc = xfrFunc_lp;
            IMPR_fa_ = (xfrFunc.eval(f_)).';
            figure();plot(f_,IMPR_fa_(1:2:end));

xfrFunc_x = linspace(0,0.5,51);
xfrFunc_fit = @(x) -2.6955e+06*x.^10 + 6.6015e+06*x.^9 - 6.788e+06*x.^8 + 3.7937e+06*x.^7 - 1.2445e+06*x.^6 + 2.4056e+05*x.^5 - 25786*x.^4 + 1317.8*x.^3 - 41.675*x.^2 + 2.5854*x + 1.0005;           
            
daSeq_c = qes.waveform.DASequence(wvSeq.copy());
daSeq_c.xfrFunc = xfrFunc;
            wvSamples = daSeq_c.samples();
            figure();plot(wvSamples(1,:));
%%
daChnl3.SendWave(daSeq,true);
daChnl3.Run(5e4);
pause(3);

osc.acqlength = 20000;
osc.datastop=osc.acqlength;
osc.acquisitionmode='AVE';
osc.acquisitionnumavg=50;
data_nc=osc.getdata();
t = [0:numel(data_nc(:,1))-1]/25;
figure();plot(t,data_nc(:,1),'b');
xlabel('Time (ns)');
%%
daChnl3.SendWave(daSeq_c,true);
daChnl3.Run(5e4);
pause(3);

osc.acqlength = 20000;
osc.datastop=osc.acqlength;
osc.acquisitionmode='AVE';
osc.acquisitionnumavg=50;
data_c=osc.getdata();

hold on;plot(t,1.0612*data_c(:,1),'r');
