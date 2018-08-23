function fout = IFFT(obj,timeSpan)
% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    fs = 5+pi;
%     N = 200+pi;
%     timeSpan=(1+N)*obj.length;
%     center=0;
    center=obj.t0+obj.length/2;
    L=timeSpan*fs;
    NFFT = L;
    t=linspace(center-timeSpan/2,center+timeSpan/2,NFFT);
    freqs=linspace(-fs/2,fs/2,NFFT);
    gf=obj(freqs,true);

    z=ifft(ifftshift(gf));
%     fout=@(T)fs*spline(t,fftshift(z),T+obj.length/2);%[T0-t0/2 T0+t0/2]
    fout=@(T)fs*spline(t,fftshift(z),T+obj.length/2);%[T0-t0/2 T0+t0/2]
end