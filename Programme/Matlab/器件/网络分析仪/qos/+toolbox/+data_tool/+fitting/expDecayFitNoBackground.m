function [B,td,varargout] = ExpDecayFit_NoBackground(t,P,varargin)
% ExpDecayFit fits curve P = P(t) with Decay function:
% P = B*exp(-t/td);
%
% optional output: 95% confidence interval of Coefficients
%
% Yulin Wu, SC5,IoP,CAS. wuyulin@ssc.iphy.ac.cn/mail4ywu@gmail.com
% $Revision: 1.0 $  $Date: 2012/04/08 $

    B0 = P(1) -P(end);
    td0 = t(end)-t(1)/2;

    Coefficients(1) = B0;
    Coefficients(2) = td0;
    
    if nargin > 2
        Coefficients(1) = varargin{1};
    end
    if nargin > 3
        Coefficients(2) = varargin{2};
    end
    lb  = [];
    ub  = [];
    if nargin > 5
        lb  = varargin{3};
        ub  = varargin{4};
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
    B = Coefficients(1);
    td =  Coefficients(2);
    if nargout > 2
        varargout{1} = nlparci(Coefficients,residual,'jacobian',J);
    end
    



function [P]=ExpDecay(Coefficients,t)
%
% Yulin Wu, SC5,IoP,CAS. wuyulin@ssc.iphy.ac.cn/mail4ywu@gmail.com
% $Revision: 1.0 $  $Date: 2012/04/08 $
B = Coefficients(1);
td = Coefficients(2);
P = B*exp(-t/td);