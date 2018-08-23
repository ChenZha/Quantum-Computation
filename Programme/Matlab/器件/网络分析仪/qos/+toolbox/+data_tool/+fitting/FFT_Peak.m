function ft=FFT_Peak(t,data,fg)
if nargin<3
    fg=0;
end
t_step=t(2)-t(1);
ff=1/t_step;
L=length(t);
NFFT=2^nextpow2(L); 
Y=fft(data-mean(data),NFFT)/L;
f=ff/2*linspace(0,1,NFFT/2+1);
if fg
figure(100);plot(f,2*abs(Y(1:NFFT/2+1)));
xlabel('freq')
ylabel('amp')
end

[~,num]=max(abs(Y(1:NFFT/2+1)));
ft=f(num);
end