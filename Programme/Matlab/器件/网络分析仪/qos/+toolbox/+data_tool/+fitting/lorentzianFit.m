function [A, w, y0, x0, varargout] = lorentzianFit(x,y,y00,A0,w0,x00)
% fit data x to a lorentzian:
% y = y0 + (2*A/pi)*(w/(4*(x-x0)^2+w^2));
%
% Yulin Wu, SC5,IoP,CAS. wuyulin@ssc.iphy.ac.cn/mail4ywu@gmail.com


    Coefficients(1) = y00;
    Coefficients(2) = A0;
    Coefficients(3) = w0;
    Coefficients(4) = x00;
    warning('off');
    [Coefficients,~,residual,~,~,~,J] = lsqcurvefit(@Lorentzian,Coefficients,x,y);
    warning('on');
    y0 = Coefficients(1);
    A = Coefficients(2);
    w = Coefficients(3);
    x0 = Coefficients(4);
    if nargout > 4
        varargout{1} = nlparci(Coefficients,residual,'jacobian',J);
    end
end
    

function [y]=Lorentzian(Coefficients,x)
y0 = Coefficients(1);
A = Coefficients(2);
w = Coefficients(3);        % FWHM
x0 = Coefficients(4);
y = y0 + (2*A/pi).*(w./(4*(x-x0).^2+w.^2));
end
