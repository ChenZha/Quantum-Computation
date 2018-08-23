load('D:\data\20170721\stepResponse_fs25G.mat');

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
td1=360e-9;td2=10e-9;amp1=1;amp2=0.007;fs = 2e9;

t = 0:0.1/fs:10*td2;

a1 = amp1*exp(-t/td1);
a2 = amp2*exp(-t/td2);
v = 1-a1-a2;
impr = qes.util.derivative(t,v);

            figure();plot(t,impr);
IMPR_fa = fftshift(fft([impr,zeros(1,1000)]));
            figure();plot(real(IMPR_fa));
            
%%
import qes.waveform.*

lowPassFilterSettings0 = struct('type','function',...
            'funcName','com.qos.waveform.XfrFuncFastGaussianFilter',...
            'bandWidth',0.130);

lowPassFilter = qes.util.xfrFuncBuilder(lowPassFilterSettings0);
xfrFunc_ = qes.util.xfrFuncBuilder(...
    struct('type','function',...
    'funcName','qes.waveform.xfrFunc.gaussianExp',...
    'bandWidth',0.25,...
    'rAmp',[0.5],...
    'td',[800]));
xfrFunc = lowPassFilter.add(xfrFunc_.inv());
f = -0.5:0.005:0.5;
xfrFuncSamples = xfrFunc.samples_t(f);
figure();
plot(f,xfrFuncSamples(1:2:end));

wvLn = 100;

zwv_0 = flattop(wvLn,1,5);
zwv0 = DASequence(1,sequence(zwv_0));
zwv_1 = flattop(wvLn,1,5);
zwv1 = DASequence(2,sequence(zwv_1));

s0 = zwv0.samples();
figure();plot(s0(1,:));

zwv1.xfrFunc = xfrFunc;
zwv1.padLength = 512;
hold on;
s1 = zwv1.samples();
plot(s1(1,:));

%%
lowPassFilterSettings0 = struct('type','function',...
            'funcName','com.qos.waveform.XfrFuncFastGaussianFilter',...
            'bandWidth',0.130);

lowPassFilter = qes.util.xfrFuncBuilder(lowPassFilterSettings0);
xfrFunc_ = qes.util.xfrFuncBuilder(...
    struct('type','function',...
    'funcName','qes.waveform.xfrFunc.gaussianExp',...
    'bandWidth',0.25,...
    'rAmp',[0.0],...
    'td',[800]));
xfrFunc = lowPassFilter.add(xfrFunc_.inv());

q8 = sqc.util.qName2Obj('q8');
q9 = sqc.util.qName2Obj('q9');
da = qes.qHandle.FindByClassProp('qes.hwdriver.hardware',...
             'name',q8.channels.z_pulse.instru);
z_daChnl = da.GetChnl(q8.channels.z_pulse.chnl);
z_daChnl.xfrFunc = xfrFunc;

CZ = sqc.op.physical.gate.CZ(q9,q8);
CZ.Run();

