function [y0, A, w, x0, varargout] = lorentzianPkFit(x,y,varargin)
% LorentzianPkFit fits Lorentzian shaped peak/dip (single peak/dip)
% y = y0 + (2*A/pi)*(w/(4*(x-x0)^2+w^2));
% Original data length should not less than 20 (length(x)>20)
%
% A function call returns the following fitting Coefficients:
% y0, A, w(FWHM), x0(Peak position) OR 'error message'.
% optional output: 95% confidence interval of Coefficients
%
% Yulin Wu, SC5,IoP,CAS. wuyulin@ssc.iphy.ac.cn/mail4ywu@gmail.com
% $Revision: 1.0 $  $Date: 2012/03/29 $

% convert to colon to avoid shape mismatch(1*N and N*1 for example)

assert(numel(x)==numel(y));

x = x(:);
y = y(:);

y00 = NaN;
A0 = NaN;
w0 = NaN;
x00 = NaN;
L = length(x);
if L < 20
    y0 = 'Unable to do fitting for the present set of data!';
    A = y0;
    w = y0;
    x0 = y0;
    if nargout > 4
        varargout{1} = y0;
    end
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
    if L < 40
        ys = y;
    elseif L < 100
        ys = smooth(y,3);
    else
        ys = smooth(y,5);
    end
    if isnan(y00)
        if L < 40
            y00 = ys(1);
        elseif L < 100
            y00 = ys(2);
        else
            y00 = ys(3);
        end
    end
    CoarseBkgrnd = y00;
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
    
    if isnan(A0)
        A0 = pi*w0*AMP/2;
    end
    Coefficients(1) = y00;
    Coefficients(2) = A0;
    Coefficients(3) = w0;
    Coefficients(4) = x00;
    for ii = 1:1
        [Coefficients,~,residual,~,~,~,J] = lsqcurvefit(@Lorentzian,Coefficients,x,y);
    end
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
