%%
% g3 = sqc.wv.gaussian(30);
% % g3 = [qes.waveform.spacer(10),copy(g3)];

g1 = sqc.wv.gaussian(20);
g2 = sqc.wv.gaussian(80);
g3 = sqc.wv.gaussian(30);
% g3 = [g1,g2,g3];
% g3 = [copy(g3),copy(g3)];

n2p = nextpow2(g3.length)+1;
numpts = 2^n2p;
fs = 1;
timeSpan = numpts/fs;
% calculate frequency domain sample by fft on time domain samples
t = linspace(g3.t0+g3.length/2 - timeSpan/2, ...
    g3.t0+g3.length/2 + timeSpan/2 - 1/fs, numpts);
samples = g3(t);
freqs = fs*(-numpts/2:numpts/2-1)/numpts;
s_fft = fft(samples);
padLn = (timeSpan - g3.length)/2;
s_fft = fftshift(s_fft)*exp(1j*2*pi*freqs*(padLn))/fs;
% calculate frequency domain sample by freqFunc directly
s_direct = g3(freqs,true);
% check they are equal
figure();plot(freqs, real(s_fft), freqs, real(s_direct));
legend({'Re: fft off time domain samples','Re: freqFunc'});
figure();plot(freqs, imag(s_fft), freqs, imag(s_direct));
legend({'Im: fft off time domain samples','Im: freqFunc'});
%%
g3 = sqc.wv.gaussian(16);
g3.df = 0.05;
%g3 = [qes.waveform.spacer(20),copy(g3)];

n2p = nextpow2(g3.length)+1;
numpts = 2^n2p;
fs = 1;
timeSpan = numpts/fs;

% calculate frequency domain sample by fft on time domain samples

t = linspace(g3.t0+g3.length/2 - timeSpan/2, ...
    g3.t0+g3.length/2 + timeSpan/2 - 1/fs, numpts);

df = fs/numpts;
freqs = [0:df:fs/2-df, -fs/2:df:-df];
samples = g3(freqs,true);
padLn = (timeSpan - g3.length)/2;
s_fft = ifft(samples.*exp(-1j*2*pi*freqs*(padLn)))*fs;
s_direct = g3(t);
figure();plot(t, real(s_fft),'-+', t, real(s_direct),'-s');
legend({'Re: fft off freq domain samples','Re: timeFunc'});

%%
g3 = sqc.wv.gaussian0(40);
g3.t0 = g3.length/2;

n2p = nextpow2(g3.length)+1;
numpts = 2^n2p;
fs = 1;
timeSpan = numpts/fs;

% calculate frequency domain sample by fft on time domain samples

t = linspace(- timeSpan/2,timeSpan/2 - 1/fs, numpts);

df = fs/numpts;
freqs = [0:df:fs/2-df, -fs/2:df:-df];
samples = g3(freqs,true);
s_fft = ifft(samples)*fs;
s_direct = g3(t);
figure;plot(t, real(s_fft),'-+', t, real(s_direct),'-s');
legend({'Re: fft off freq domain samples','Re: timeFunc'});

%%
g3 = sqc.wv.rect(56);
g3.overshoot = 1;

n2p = nextpow2(g3.length)+1;
numpts = 2^n2p;
fs = 1;
timeSpan = numpts/fs;

% calculate frequency domain sample by fft on time domain samples

t = linspace(g3.t0+g3.length/2 - timeSpan/2, ...
    g3.t0+g3.length/2 + timeSpan/2 - 1/fs, numpts);

df = fs/numpts;
freqs = [0:df:fs/2-df, -fs/2:df:-df];
samples = g3(freqs,true);
padLn = (timeSpan - g3.length)/2;
s_fft = ifft(samples.*exp(-1j*2*pi*freqs*(padLn)))*fs;
s_direct = g3(t);
figure();plot(t, real(s_fft),'-+', t, real(s_direct),'-s');
legend({'Re: fft off freq domain samples','Re: timeFunc'});

%%
g3 = sqc.wv.flattop(56);
g3.gaus_w = 5;
g3.overshoot = 0;
g3.df = 0.00;

n2p = nextpow2(g3.length)+1;
numpts = 2^n2p;
fs = 1;
timeSpan = numpts/fs;

% calculate frequency domain sample by fft on time domain samples

t = linspace(g3.t0+g3.length/2 - timeSpan/2, ...
    g3.t0+g3.length/2 + timeSpan/2 - 1/fs, numpts);

df = fs/numpts;
freqs = [0:df:fs/2-df, -fs/2:df:-df];
samples = g3(freqs,true);
padLn = (timeSpan - g3.length)/2;
s_fft = ifft(samples.*exp(-1j*2*pi*freqs*(padLn)))*fs;
s_direct = g3(t);
figure();plot(t, real(s_fft),'-+', t, real(s_direct),'-s');
legend({'Re: fft off freq domain samples','Re: timeFunc'});
%%
g3 = sqc.wv.gaussian(16);
g3.df = 0.05;
g4 = [qes.waveform.spacer(20),copy(g3)];

n2p = nextpow2(g4.length)+1;
numpts = 2^n2p;
fs = 1;
timeSpan = numpts/fs;

% calculate frequency domain sample by fft on time domain samples
t = linspace(g4.t0+g4.length/2 - timeSpan/2, ...
    g4.t0+g4.length/2 + timeSpan/2 - 1/fs, numpts);

df = fs/numpts;
freqs = [0:df:fs/2-df, -fs/2:df:-df];
samples = g4(freqs,true);
padLn = (timeSpan - g4.length)/2;
s_fft = ifft(samples.*exp(-1j*2*pi*freqs*(padLn)))*fs;
s_direct = g4(t);
figure();plot(t, real(s_fft),'-+', t, real(s_direct),'-s');
legend({'Re: fft off freq domain samples','Re: timeFunc'});

numpts = 32;
timeSpan = numpts/fs;
t = linspace(20+g3.length/2 - timeSpan/2, ...
    20+g3.length/2 + timeSpan/2 - 1/fs, numpts);

df = fs/numpts;
freqs = [0:df:fs/2-df, -fs/2:df:-df];
samples = g4(freqs,true);
padLn = (timeSpan - g3.length)/2;
s_fft = ifft(samples.*exp(-1j*2*pi*freqs*(padLn)))*fs;
hold on;plot(t, real(s_fft),'-^');
%%
%%
g3 = sqc.wv.gaussian(16);
g3.df = 0.05;
g3.t0 = 20e3;

n2p = nextpow2(g3.length)+6;
numpts = 2^n2p;
fs = 10;
timeSpan = numpts/fs;

% calculate frequency domain sample by fft on time domain samples
t = linspace(g3.t0+g3.length/2 - timeSpan/2, ...
    g3.t0+g3.length/2 + timeSpan/2 - 1/fs, numpts);

df = fs/numpts;
freqs = [0:df:fs/2-df, -fs/2:df:-df];
samples = g3(freqs,true);

hold on; plot(real(samples));

padLn = (timeSpan - g3.length)/2;
padLn = 0;
s_fft = ifft(samples.*exp(-1j*2*pi*freqs*(padLn)))*fs;
s_fft = ifftshift(s_fft);
s_direct = g3(t);
% figure();plot(t, real(s_fft),'-+', t, real(s_direct),'-s');
% legend({'Re: fft off freq domain samples','Re: timeFunc'});
%%
x = [0,1,2,3,3,2,1,0];
ifft(x)