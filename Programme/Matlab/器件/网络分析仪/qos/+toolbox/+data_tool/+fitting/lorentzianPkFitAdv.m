function [y0, k1, k2, A, w, x0, varargout] = lorentzianPkFitAdv(x,y,varargin)
% LorentzianPkFit_Adv fits Lorentzian shaped peak/dip (single peak/dip) with a
% linear or almost linear background using the following model:
% y = y0 + k1*x + k2*x^2 + (2*A/pi)*(w/(4*(x-x0)^2+w^2));
% Original data length should not less than 20 (length(x)>20)
%
% A function call returns the following fitting Coefficients:
% y0, k1, k2, A, w(FWHM), x0(Peak position) OR 'error message'.
%
% Yulin Wu, SC5,IoP,CAS. wuyulin@ssc.iphy.ac.cn/mail4ywu@gmail.com
% $Revision: 1.0 $  $Date: 2012/03/29 $

assert(numel(x)==numel(y));

r = range(x);
c = mean(x);
x = (x-c)/r;

y00 = NaN;
k10 = NaN;
k20 = NaN;
A0 = NaN;
w0 = NaN;
x00 = NaN;
L = length(x);
if L < 10
    y0 = 'Unable to do fitting for the present set of data!';
    k1 = y0;
    k2 = y0;
    A = y0;
    w = y0;
    x0 = y0;
else
    if nargin > 2
        x00 = varargin{1};
    end
    if nargin > 3
        A0 = varargin{2};
    end
    if nargin > 4
        w0 = varargin{3};
    end
    if nargin > 5
        y00 = varargin{4};
    end
    if nargin > 6
        k10 = varargin{5};
    end
    if nargin > 7
        k20 = varargin{6};
    end
    if L < 25
        ys = y;
    elseif L < 50
        ys = smooth(y,3);
    else
        ys = smooth(y,5);
    end
    if isnan(y00) || isnan(k10)
        if L < 25
            k10 = (ys(end) - ys(1))/(x(end) - x(1));
            y00 = ys(1) - k10*x(1);
        elseif L < 50
            k10 = (ys(end-1) - ys(2))/(x(end-1) - x(2));
            y00 = ys(2) - k10*x(2);
        else
            k10 = (ys(end-2) - ys(3))/(x(end-2) - x(3));
            y00 = ys(3) - k10*x(3);
        end
    end
   if isnan(k20)
        k20 = 0;
   end
    CoarseBkgrnd = y00+k10*x;
    CoarsePk = reshape(ys,1,[]) - CoarseBkgrnd;
    if sum(CoarsePk) < 0      % is dip
        [AMP, idx] = min(CoarsePk);
    else
        [AMP, idx] = max(CoarsePk);
    end
    if isnan(x00)
        x00 = x(idx);
    end
    jj = 1;
    temp = abs(AMP);
    if L - idx > L/2
        while 1
            if idx+jj >= L || abs(CoarsePk(idx+jj)) < temp/2
                if isnan(w0)
                    w0 = 2*(x(idx+jj)-x00);
                end
                break;
            end
            jj = jj+1;
        end
    else
        while 1
            if idx-jj <= 1 || abs(CoarsePk(idx-jj)) < temp/2
                if isnan(w0)
                    w0 = 2*(x00-x(idx-jj));
                end
                break;
            end
            jj = jj+1;
        end
    end
    w0 = abs(w0); % just in case
    if isnan(w0)
        w0 = range(x)/5;
    end
    if isnan(A0)
        A0 = pi*w0*AMP/2;
    end
    Coefficients(1) = y00;
    Coefficients(2) = k10;
    Coefficients(3) = k20;
    Coefficients(4) = A0;
    Coefficients(5) = w0;
    Coefficients(6) = x00;
    for ii = 1:1
        [Coefficients,~,residual,~,~,~,J] = lsqcurvefit(@Lorentzian_Adv,Coefficients,x,y);
    end
    y0 = Coefficients(1);
    k1_ = Coefficients(2);
    k2_ = Coefficients(3);
    A = Coefficients(4);
    w = Coefficients(5);
    x0 = Coefficients(6);
    
    y0 = y0 - k1_*c/r+k2_*c^2/r^2;
    k1 = k1_/r-2*c*k2_/r^2;
    k2 = k2_/r^2;
    A = r*A;
    w = r*w;
    x0 = c+r*x0;
    if nargout > 6
        varargout{1} = nlparci(Coefficients,residual,'jacobian',J);
    end
end
    

function [y]=Lorentzian_Adv(Coefficients,x)
y0 = Coefficients(1);
k1 = Coefficients(2);
k2 = Coefficients(3);
A = Coefficients(4);
w = Coefficients(5);        % FWHM
x0 = Coefficients(6);
y = y0+k1*x+k2*x.^2+(2*A/pi).*(w./(4*(x-x0).^2+w.^2));
