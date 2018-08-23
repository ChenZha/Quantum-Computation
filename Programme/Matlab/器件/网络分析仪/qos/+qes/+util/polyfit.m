function p = polyfit(x,y,n)
    % polyfit for very small x, very largy y
    
% Copyright 2016 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com

    xs = range(x);
    x = x/xs;
    y0 = mean(y);
    ys = range(y);
    y = (y-y0)/ys;
    p = polyfit(x,y,n);
    for ii = 1:n+1
        p(ii) = ys*p(ii)/xs^(n-ii+1);
    end
    p(end) = p(end) + y0;
end 
