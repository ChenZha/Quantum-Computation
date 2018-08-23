function [A,B,td,varargout] = ExpDecayFit(t,P,varargin)
% ExpDecayFit fits curve P = P(t) with Decay function:
% P = A +B*exp(-t/td);
%
% optional output: 95% confidence interval of Coefficients
%
% Yulin Wu, SC5,IoP,CAS. wuyulin@ssc.iphy.ac.cn/mail4ywu@gmail.com
% $Revision: 1.0 $  $Date: 2012/04/08 $

    A0 = P(end);
    B0 = P(1) -P(end);
    td0 = t(end)-t(1)/2;
    
    Coefficients(1) = A0;
    Coefficients(2) = B0;
    Coefficients(3) = td0;
    
    if nargin > 2
        Coefficients(1) = varargin{1};
    end
    if nargin > 3
        Coefficients(2) = varargin{2};
    end
    if nargin > 4
        Coefficients(3) = varargin{3};
    end
    lb  = [];
    ub  = [];
    if nargin > 5
        lb  = varargin{4};
        ub  = varargin{5};
    end
    
    for ii = 1:3
        % admonition:
        % lsqcurvefit is more robust than nlinfit, nlinfit produces erros
        % for some data set.
        if ~isempty(lb) && ~isempty(ub)
            [Coefficients,~,residual,~,~,~,J] = lsqcurvefit(@ExpDecay,Coefficients,t(:),P(:),lb,ub);
        else
            [Coefficients,~,residual,~,~,~,J] = lsqcurvefit(@ExpDecay,Coefficients,t(:),P(:));
        end
        % [Coefficients, residual, J,~,~,~] =  nlinfit(t,P,@ExpDecay,Coefficients);
    end
    A = Coefficients(1);
    B = Coefficients(2);
    td =  Coefficients(3);
    if nargout > 3
        varargout{1} = nlparci(Coefficients,residual,'jacobian',J);
    end
    



function [P]=ExpDecay(Coefficients,t)
%
% Yulin Wu, SC5,IoP,CAS. wuyulin@ssc.iphy.ac.cn/mail4ywu@gmail.com
% $Revision: 1.0 $  $Date: 2012/04/08 $
A = Coefficients(1);
B = Coefficients(2);
td = Coefficients(3);
P = A +B*exp(-t/td);