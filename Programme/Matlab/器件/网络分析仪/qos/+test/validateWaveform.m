%% 18-03-05
wv = qes.waveform.flattop(100,1, 5);

seq = qes.waveform.sequence(wv);

chnl = 1;
DASequence = qes.waveform.DASequence(chnl,seq);

s = struct();
s.type = 'function';
s.funcName = 'qes.waveform.xfrFunc.gaussianExp';
s.bandWidht = 0.25;
s.r = [0.021,-0.012,0.009,0.005]; 
s.td = [900,400,150,60]; 
xfrFunc = qes.util.xfrFuncBuilder(s);
xfrFunc_inv = xfrFunc.inv();
xfrFunc_lp = com.qos.waveform.XfrFuncFastGaussianFilter(0.13);
xfrFunc_f = xfrFunc_lp.add(xfrFunc_inv);

% xfrFunc = com.qos.waveform.XfrFuncShots(0.05,200);
% xfrFunc_f = xfrFunc.inv();

DASequence.xfrFunc = xfrFunc_f;

samples = DASequence.samples();
samples = samples(1,:);
figure();plot(samples);

% old version:
% %%
% padLength = 100;
% com.qos.waveform.Waveform.setPadLength(padLength);
% %%
% % validate waveform phase
% g1 = qes.waveform.gaussian(400,1);
% g2 = qes.waveform.gaussian(600,1);
% g3 = qes.waveform.gaussian(200,1);
% 
% gc1 = [g1,g2];
% gc = [0.5*gc1,g3,g1];
% 
% % gc = 0.5*gc;
% 
% gc.carrierFrequency = 0.1;
% v = gc.samples();
% t = 0:size(v,2)-1;
% figure();plot(t,v(1,:));
% gc1.delete;
% gc.delete;
% %%
% g1 = qes.waveform.rect(100,1);
% gc = [qes.waveform.sequence(),g1];
% gFilter = com.qos.waveform.XfrFuncGaussianFilter(0.05);
% % gc.xfrFunc = gFilter.inv();
% gc.xfrFunc = gFilter;
% 
% % gc.carrierFrequency = 0.1;
% v = gc.samples();
% t = 0:size(v,2)-1;
% figure();plot(t-padLength,v(1,:));
% gc.delete;
% %%
% cacheSize = com.qos.waveform.Waveform.getCacheSize()
% %%
% g1 = qes.waveform.rr_ring(1000, 1, 10, 1, 100);
% gc = [qes.waveform.sequence(),g1];
% gc.carrierFrequency = 0.05;
% v = gc.samples();
% t = 0:size(v,2)-1;
% figure();plot(t-padLength,v(1,:)); %% carrierFrequency to be tested in 
% 
% %% derivative waveform
% df = 0.05;
% g1 = qes.waveform.gaussian(100,1);
% gc = [qes.waveform.sequence(),g1];
% v = gc.samples();
% 
% g1d = g1.deriv();
% gcd = [qes.waveform.sequence(),g1d];
% gcd.carrierFrequency = 0;
% vd = gcd.samples();
% t = 0:size(v,2)-1;
% figure();plot(t-padLength,v(1,:),...
%     t-padLength,vd(1,:)); %% carrierFrequency to be tested in 
% 
% %%
% g = qes.waveform.acz(100);
% t = -10:0.2:110;
% figure();plot(t,g(t));


