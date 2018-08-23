function [a, x0, sigma, y0, varargout] = gaussianFit(x,y,a0,x0,sigma0,y00)
% fit data x to a gaussian:
% y =  a*exp(-(x-x0)^2/(2*sigma^2)) + y0
%
% Yulin Wu, SC5,IoP,CAS. wuyulin@ssc.iphy.ac.cn/mail4ywu@gmail.com


    Coefficients(1) = a0;
    Coefficients(2) = x0;
    Coefficients(3) = sigma0;
    Coefficients(4) = y00;
    warning('off');
    [Coefficients,~,residual,~,~,~,J] = lsqcurvefit(@gaussian,Coefficients,x,y);
    warning('on');
    a = Coefficients(1);
    x0 = Coefficients(2);
    sigma = Coefficients(3);
    y0 = Coefficients(4);
    if nargout > 4
        varargout{1} = nlparci(Coefficients,residual,'jacobian',J);
    end
end
    

function y=gaussian(Coefficients,x)
a = Coefficients(1);
x0 = Coefficients(2);
sigma = Coefficients(3);
y0 = Coefficients(4);
y = a*exp(-(x-x0).^2/(2*sigma^2))+y0;
end
