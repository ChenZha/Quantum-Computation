function v = FFT(obj,f)
% for waveforms whos frequency function dose not have a analytical form,
% use FFT to calculate the frequency values numerically from time domain
% function.

% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    UPSAMPLE = 100;
    padln = round(0*obj.length);
    t = linspace(obj.t0-padln,obj.t0+obj.length - 1+padln,UPSAMPLE*(obj.length+2*padln));
    NFFT = 2^nextpow2(numel(t));
    
    vt = obj(t);
    
    vi = fftshift(fft(vt,NFFT));
    
    fcn = @(x)exp(-x.^2);
    fcn = @(x)sin(sqrt(x*6));
    
    f_ = 5*[linspace(0,0.5,NFFT/2),fliplr(linspace(0,0.5,NFFT/2))];
    vi = fcn(f_)+1j*fcn(f_);
    vi = fcn(f_);
    f_ = 5*linspace(0,0.5,NFFT);
%     figure();plot(real(vi));
    % vi = fft(obj(t),NFFT);
    f = linspace(0,2.5,NFFT*10);
    if ~isempty(obj.df)
         v = exp(-1j*obj.phase)*interp1(UPSAMPLE*linspace(-0.5,0.5,NFFT),vi,f-obj.df,'spline');
    else
%         v = interp1(UPSAMPLE*linspace(-0.5,0.5,NFFT),vi,f,'spline');
        v = interp1(f_,vi,f,'spline');
    end
    
end