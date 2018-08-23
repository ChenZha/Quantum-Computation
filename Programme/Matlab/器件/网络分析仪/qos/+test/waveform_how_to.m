%% 18-03-05
% [step 1] create the waveforms
wv1 = qes.waveform.flattop(100,1, 5);
wv2 = qes.waveform.spacer(200);
wv3 = qes.waveform.gaussian(50,1);
wv4 = qes.waveform.cos(30,1.5);

% [step 2] make a sequence
seq = qes.waveform.sequence(wv1);
seq = [seq,wv2,wv3,wv4];

% [step 3] make a DA sequence and mount calibration settings,
% Note: calibration settings are hardware channel specific, that's why they
% can not be set at step 1 or step 2: while a sequence may be used anyhere,
% even shared between channels, a DASequence is bounded to a specific
% hardware channel.
chnl = 1;
DASequence = qes.waveform.DASequence(chnl,seq);
% set transfer funciton, in production, it is done like this:
% DASequence.xfrFunc = TheDAChannel.xfrFunc;
% DASequence.padLength = TheDAChannel.padLength;
% the following is just for this demo
%         s = struct();
%         s.type = 'function';
%         s.funcName = 'qes.waveform.xfrFunc.gaussianExp';
%         s.bandWidht = 0.25;
%         s.r = [0.021,-0.012,0.009,0.005]; 
%         s.td = [900,400,150,60]; 
%         xfrFunc = qes.util.xfrFuncBuilder(s);
%         xfrFunc_inv = xfrFunc.inv();
%         xfrFuncLPF = com.qos.waveform.XfrFuncFastGaussianFilter(0.13);
%         xfrFunc_f = xfrFuncLPF.add(xfrFunc_inv);
        % or
%         xfrFunc = com.qos.waveform.XfrFuncShots([0.02,0.005],[1200,300]);
        xfrFunc = com.qos.waveform.XfrFuncShots(0.04,300);
        xfrFunc_f = xfrFunc;
%         xfrFunc_f = xfrFunc.inv();

        DASequence.xfrFunc = xfrFunc_f;
        
% [step 4] calculate time samples
samples = DASequence.samples();
IorQ = 1; % 1 for I, 2 for Q
samples = samples(IorQ,:);
figure();plot(samples);

%% 
% numeric waveform test
modelSamples = [0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0];
wv1 = qes.waveform.numericT(100,2,modelSamples);
% make a sequence
seq = qes.waveform.sequence(wv1);

% make a DA sequence and mount calibration settings,
% calibration settings are hardware specific
chnl = 1;
DASequence = qes.waveform.DASequence(chnl,seq);

samples = DASequence.samples();
IorQ = 1; % 1 for I, 2 for Q
samples = samples(IorQ,:);
figure();plot(samples);
%%
wv1 = qes.waveform.flattop(20000,1, 5);
seq = qes.waveform.sequence(wv1);
chnl = 9;
DASequence = qes.waveform.DASequence(chnl,seq);
% DASequence.padLength = 2e4;
%         s = struct();
%         s.type = 'function';
%         s.funcName = 'qes.waveform.xfrFunc.gaussianExp';
%         s.bandWidht = 0.25;
%         s.r = [0.03]; 
%         s.td = [500]; 
%         xfrFunc = qes.util.xfrFuncBuilder(s);
%         xfrFunc_inv = xfrFunc.inv();

%         xfrFunc = com.qos.waveform.XfrFuncShots([-0.025, -0.01],[0.2e-4, 10e-4]); % 5e-4, td~ 500pts
        
        xfrFunc = com.qos.waveform.XfrFuncShots(0.05,5e-3); %5e-2, td~18pts, 5e-4, td~ 500pts,5e-5, td~3400pts
        xfrFunc_inv = xfrFunc.inv();

        xfrFuncLPF = com.qos.waveform.XfrFuncFastGaussianFilter(0.13);
        xfrFunc_f = xfrFuncLPF.add(xfrFunc_inv);
        
        DASequence.xfrFunc = xfrFunc_f;

samples = DASequence.samples();
IorQ = 1; % 1 for I, 2 for Q
samples = samples(IorQ,:);
hold on;plot(samples);
%%
x = [5e-5,1e-4,2e-4,5e-4,7.5e-4,1e-3,2.5e-3,5e-3,1e-2];
y = [3400,1700,860,350,245,185,82,47,20];

[5e-2,2.5e-2,1e-2,7.25e-3]
[17.5,20,37];
%%
        s = struct();
        s.type = 'function';
        s.funcName = 'qes.waveform.xfrFunc.gaussianExp';
        s.bandWidht = 0.25;
        s.r = [0.05]; 
        s.td =[500]; 
        xfrFunc = qes.util.xfrFuncBuilder(s);
        xfrFunc_inv = xfrFunc.inv();
        xfrFuncLPF = com.qos.waveform.XfrFuncFastGaussianFilter(0.13);
        xfrFunc_f = xfrFuncLPF.add(xfrFunc_inv);
        DASequence.xfrFunc = xfrFunc_f;
fi = qes.util.fftFreq(5001,1);
% fi = linspace(-0.5,0.5,1001);
fsamples = xfrFunc.samples_t(fi);
fsamples = reshape(fsamples,2,[]);
fsamples = fsamples(1,:)+1j*fsamples(2,:);

hold on;plot(fi,real(fsamples),'-');
%%
q = 'q9';
figure();
ax =axes();
for x = 0.5
thf = 0.864; % 1.4083
thi =  0.05;
lam2 = -0.18;
lam3 = 0.04;

zpa2f01 = getQSettings('zpls_amp2f01',q);
maxF01 = polyval(zpa2f01,roots(polyder(zpa2f01)));
k = 1/sqrt(-zpa2f01(1));
xShift = sqc.util.zpa2f01XShift(sqc.util.qName2Obj(q));
if xShift > 0
    k = -k;
end
amp = 1;
% amp = -5.7044e+08;
ampInDetune = false;
f01 = getQSettings('f01',q);

% [step 1] create the waveforms
wv1 = qes.waveform.acz(100, amp, thf, thi, lam2, lam3,ampInDetune, f01,maxF01,k);
% [step 2] make a sequence
seq = qes.waveform.sequence(wv1);
% [step 3] make a DA sequence and mount calibration settings,
% Note: calibration settings are hardware channel specific, that's why they
% can not be set at step 1 or step 2: while a sequence may be used anyhere,
% even shared between channels, a DASequence is bounded to a specific
% hardware channel.
chnl = 9;
DASequence = qes.waveform.DASequence(chnl,seq);
% s = struct();
%         s.type = 'function';
%         s.funcName = 'qes.waveform.xfrFunc.gaussianExp';
%         s.bandWidht = 0.25;
%         s.r = [0.014,0.007,0.01]; 
%         s.td = [1200,500,100]; 
%         xfrFunc = qes.util.xfrFuncBuilder(s);
%         xfrFunc_inv = xfrFunc.inv();
%         xfrFuncLPF = com.qos.waveform.XfrFuncFastGaussianFilter(0.13);
%         xfrFunc_f = xfrFuncLPF.add(xfrFunc_inv);
%         % or
%         % xfrFunc = com.qos.waveform.XfrFuncShots([0.02,0.005],[1200,300]);
%         % xfrFunc_f = xfrFunc.inv();
% 
%         DASequence.xfrFunc = xfrFunc_f;

% [step 4] calculate time samples
samples = DASequence.samples();
IorQ = 1; % 1 for I, 2 for Q
samples = samples(IorQ,:);
hold on;
plot(ax,samples);
end
