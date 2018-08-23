wvLength = 100;
wvRect = qes.waveform.rect(wvLength,-1.5e4);
freqSamples = wvRect.freqSamples();

timeSamples = wvRect.samples();
ta = timeSamples(1,1:wvLength+padLength);
t = (0:length(ta)-1)*0.5;

fa = fftshift(freqSamples(1,:))+1j*fftshift(freqSamples(2,:));
f = 2*linspace(-0.5,0.5,length(fa));
figure();axf = axes();
plot(axf,f,real(fa),'-b',f,imag(fa),'--b',f,abs(fa),'-k');
xlabel('frequency(GHz)');
title('frequency domain');

figure();axt = axes();
plot(axt,t,ta);
xlabel('time(ns)');
title('time domain samples');
%%
wvRect_c1 = qes.waveform.rect(wvLength,-1.5e4);

xfrFunc_lp = com.qos.waveform.XfrFuncFastGaussianFilter(0.13);

load('D:\data\20170721\impulseResponse_noFilter_1.mat');
xfrFunc_imp = com.qos.waveform.XfrFuncNumeric(IMPR_NoFilter_fs25G_1,25e9/2e9,0,false);
xfrFunc_imp_iverse = xfrFunc_imp.inv();

xfrFunc = xfrFunc_lp.add(xfrFunc_imp_iverse);

wvRect_c1.xfrFunc = xfrFunc;
freqSamples_c1 = wvRect_c1.freqSamples();

fa_c1 = fftshift(freqSamples_c1(1,:))+1j*fftshift(freqSamples_c1(2,:));
f_c1 = 2*linspace(-0.5,0.5,length(fa_c1));

timeSamples_c1 = wvRect_c1.samples();
ta_c1 = timeSamples_c1(1,1:wvLength+padLength);
t_c1 = (0:length(ta)-1)*0.5;

hold(axf,'on'); 
plot(axf,f_c1,real(fa_c1),'-r',f_c1,imag(fa_c1),'--r',f_c1,abs(fa_c1),'-m');

hold(axt,'on');
plot(axt,t_c1,ta_c1);

%%
% figure();axt = axes();
% 
% xfrFunc_imp = com.qos.waveform.XfrFuncNumeric(IMPR_NoFilter_fs25G_1,25e9/2e9,0);
% xfrFunc_imp_iverse = xfrFunc_imp.inv();
% % xfrFunc_imp_iverse = xfrFunc_imp;
% 
% f = linspace(-0.5,0.5,100);
% fa = xfrFunc_imp_iverse.eval(f);
% plot(f,fa(1:2:end));



