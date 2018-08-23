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
%%
% osc.horizontalposition=0;
% osc.horizontalscale=1.0000e-08;
% osc.acqlength = 1024;
% osc.datastop=osc.acqlength;
% %
% osc.acquisitionmode='AVE';
% osc.acquisitionnumavg=10;
% %osc.acquisitionmode='SAM';
% osc.datasource='ch1,ch2,ch3,ch4';
% datanow=osc.getdatanow();
% data=osc.getdata();%wait_trigger
%%
padLength = 500;
com.qos.waveform.Waveform.setPadLength(padLength);
%%
dc = qes.waveform.dc(100,-1.5e4);
% dc = qes.waveform.dc(1,-3e4);
gc = [dc,qes.waveform.spacer(100)];
wvData = gc.samples();
figure();plot(wvData(1,:));
%%
daChnl3 = da.GetChnl(3);
%%
osc.acquisitionmode='AVE';
osc.acquisitionnumavg=100;
gcd = qes.waveform.DASequence(gc);
daChnl3.SendWave(gcd,true);
daChnl3.Run(5e4);
pause(5);
data=osc.getdata();%wait_trigger

fs = 6.25e9;
y4plot = data(:,1);
t = linspace(0,1e9*length(y4plot)/fs,length(y4plot));
figure();plot(t,y4plot);
%%

