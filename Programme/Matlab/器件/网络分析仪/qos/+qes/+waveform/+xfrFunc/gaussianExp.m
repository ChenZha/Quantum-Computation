function xfrFunc = gaussianExp(bw,r,td)
% Yulin Wu, 17/08/04
% bw: 3dB suppression point
% a series of shots with exponential decay
% bw: array, bandwidth in unit of DA sampling frequency
% r: array, relative amplitude, this is what you should tune to find the callibration
% typically 0.05-0.03.
% td: array, the decay time constant, in unit of DA sampling interval,
% this is also what you should tune to find the callibration.
% gaussianExp is equivalent to com.qos.waveform.XfrFuncShots which
% generates the samples in frequency domain directly.

sigmaf = 2.0840*bw/sqrt(3);
sigma = 1/(2*pi*sigmaf);
assert(all(td>=1));
timeSpan = 10*max(td);
rs = 50;
t = -5*sigma:1/rs:timeSpan;
v = zeros(1,length(t));
for ii = 1:numel(r)
    v = v+r(ii)*exp(-t/td(ii));
end
v = v + exp(-t.^2/(2*sigma^2));
%figure();
% plot(t,v);

impr = qes.util.derivative(t,v);
% figure();plot(t,impr);

ind1 = find(impr>=0,1,'first');
t(1:ind1-1) = [];
impr(1:ind1-1) = [];
ind2 = find(impr<=0,1,'first');
t(1:ind2-1) = [];
impr(1:ind2-1) = [];

v = v(ind1+ind2-1:end);
v = v/max(v);
v = 1-v;
% figure();
% plot(t*1e9,v);

impr = qes.util.derivative(t,v);
% hold on;plotyy(t*1e9,v,t*1e9,impr);

IMPR_fa = fftshift(fft(impr));
IMPR_f = fftshift(qes.util.fftFreq(numel(t),rs));
IMPR_fa = IMPR_fa/max(abs(IMPR_fa));
ind = IMPR_f > 0.55 | IMPR_f < -0.55;
IMPR_f(ind) = [];
IMPR_fa(ind) = [];

[~,idx] = max(impr);
IMPR_fa = exp(2j*pi*IMPR_f*1.2*t(idx)).*IMPR_fa;

% hold on;plot(IMPR_f, real(IMPR_fa),'-');% hold on;plot(IMPR_f, imag(IMPR_fa),'-');
xfrFunc = com.qos.waveform.XfrFuncNumeric(IMPR_f,real(IMPR_fa),imag(IMPR_fa));

% fi = linspace(-0.5,0.5,100);
% fi = IMPR_f;
% fsamples = xfrFunc.samples_t(fi);
% fsamples = reshape(fsamples,2,[]);
% fsamples = fsamples(1,:)+1j*fsamples(2,:);
% 
% figure();plot(fi,real(IMPR_fa));
% hold on;plot(fi, abs(fsamples()),'-+r');

end