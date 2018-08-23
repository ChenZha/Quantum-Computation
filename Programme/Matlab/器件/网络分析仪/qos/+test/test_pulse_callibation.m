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
%%
padLength = 1000;
com.qos.waveform.Waveform.setPadLength(padLength);
%%
load('D:\data\20170721\impulseResponse_noFilter_1.mat');
wvSeq = [qes.waveform.rect(100,-1.5e4),qes.waveform.spacer(100)];
daSeq = qes.waveform.DASequence(wvSeq);

% numPad = 25;
% IMPR_NoFilter_fs100G_ = [zeros(1,numPad),IMPR_NoFilter_fs100G_1'];
% IMPR_NoFilter_fs5G_1 = IMPR_NoFilter_fs25G_1(1:5:end);
xfrFunc_imp = com.qos.waveform.XfrFuncNumeric(IMPR_NoFilter_fs25G_1,25e9/2e9);
xfrFunc_imp_iverse = xfrFunc_imp.inv();
xfrFuncGF = com.qos.waveform.XfrFuncFastGaussianFilter(0.15);
xfrFunc_c = xfrFunc_imp_iverse.add(xfrFuncGF);

f = linspace(-0.5,0.5,100);
yf = xfrFunc_imp.eval(f);
hold on;plot(f*2,yf(1:2:end),f*2,yf(2:2:end));
xlabel('GHz');

daSeq_c = qes.waveform.DASequence(wvSeq.copy());
daSeq_c.xfrFunc = xfrFunc_c;
%%
daChnl3.SendWave(daSeq,true);
daChnl3.Run(5e4);
pause(1);

osc.acquisitionmode='AVE';
osc.acquisitionnumavg=2;
data_nc=osc.getdata();
figure();plot(data_nc(:,1));
%%
daChnl3.SendWave(daSeq_c,true);
daChnl3.Run(5e4);
pause(1);
data_c=osc.getdata();

hold on;plot(data_c(:,1));
hold on;plot(zeros(1,size(data_c,1)),'k');
