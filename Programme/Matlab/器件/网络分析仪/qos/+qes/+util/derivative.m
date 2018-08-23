function deriv = derivative(x,y)
% Yulin Wu, 17/08/01

    assert(numel(x) == numel(y) & numel(x) > 1);
    n = length(x);
    deriv=zeros(1,n);
    for k = 1:n
        if k==1
            deriv(k)= (y(k+1)-y(k))/(x(k+1)-x(k));
        elseif k==n
            deriv(k)=(y(k)-y(k-1))/(x(k)-x(k-1));
        else
            deriv(k)=(y(k+1)-y(k-1))/(x(k+1)-x(k-1));
        end
    end
end