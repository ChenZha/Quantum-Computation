function freq = freqFinder(x,y,freqLB,freqUP)

    A = range(y);
    C = mean(y);
    function y_ = fitFunc(f)
        kernel = A*cos(2*pi*f*x)+C;
        y_ = 1./abs(mean(kernel.*y));
    end

    freq = qes.util.fminsearchbnd(@fitFunc,(freqLB+freqUP)/2,freqLB,freqUP);
    
end