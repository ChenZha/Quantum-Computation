function [ err ] = ErrFunc1( xdatas,ydatas,calculatedDatas )
%ERRFUNC1 Summary of this function goes here
%   Detailed explanation goes here
n = length(xdatas);
err = 0;
for ii = 1:n
    xdata = xdatas{ii};
    nxdata = length(xdata);
    ydata = ydatas{ii};
    for jj = 1:nxdata
        x = xdata(jj);
        y = ydata(jj);
        calculatedData = calculatedDatas{ii};
        [mostClosedx,indexx] = min(abs(calculatedData(1,:)-x));
        err = err+(mostClosedx-x).^2+((calculatedData(2,indexx)-y)/y).^2;
    end
end

end

