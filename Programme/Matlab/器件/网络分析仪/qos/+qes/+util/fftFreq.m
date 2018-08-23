function f = fftFreq(n,fs)

    f = zeros(1,n);
    if mod(n,2)
        f(1:(n-1)/2+1) = 0:(n-1)/2;
        f((n-1)/2+2:n) = -(n-1)/2:1:-1;
    else
        f(1:n/2) = 0:n/2-1;
        f(n/2+1:n) = -n/2:1:-1;
    end
    f = f*fs/n;
end