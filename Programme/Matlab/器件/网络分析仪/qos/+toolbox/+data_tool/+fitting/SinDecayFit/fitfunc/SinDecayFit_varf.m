function [A,B,C,D,freq,td,varf, varargout] = SinDecayFit_varf(t,P,varargin)
% SinDecayFit fits curve P = P(t) with a Sinusoidal Decay function:
% P = A +B*(exp(-t/td)*(sin(2*pi*(freq+vf*t)*t+D)+C));
% t unit should be nano-second.
% Original data length should not less than 20 (length(t)>20)
%
% A function call returns the following fitting Coefficients:
% A,B,C,D,freq,td OR 'error message'.
% optional output: 95% confidence interval of Coefficients
%
% varargin{1}: MINIMUM oscillation circles P has (LeastOscN). If not specifid,
% the programme sets it to 6. 
% Note: the bigger the value of 'LeastOscN', the less likely for the fitting
% to fail, but make sure it dose not exceed the REAL oscillation circles P
% has, for example: 
% If you can clearly see that there is more than 30 oscillation circles and
% the exact oscillation circle number is less than 150:
% [A,B,C,D,freq,td] = SinDecayFit(t,P);
% Default, alright for most cases
% [A,B,C,D,freq,td] = SinDecayFit(t,P,2);
% very likely to fail
% [A,B,C,D,freq,td] = SinDecayFit(t,P,30);
% most likey to be successful
% [A,B,C,D,freq,td] = SinDecayFit(t,P,160);
% may fail
%
% varargin{2}, initial value of oscillation frequency, if auto fitting
% failed, specify this value(as close to the real oscillation frequency
% value as possible). In this case, value of varargin{1} will not
% be used, given any value will be alright
%
% varargin{3}, initial value of decay time, if fitting still fail when
% initial value of oscillation frequency is given, specify this value(
% as close to the real decay time value as possible).
%
% varargin{4}, initial value A
% varargin{5}, initial value B
% varargin{6}, initial value C
% varargin{7}, initial value D
%
% varargout{1}: ci, 6 by 2 matrix, ci(5,1) is the lower bound of 'freq',
% ci(6,2) is the upper bound of 'td',...
%
% Yulin Wu, SC5,IoP,CAS. mail4ywu@gmail.com
% $Revision: 1.1 $  $Date: 2012/10/18 $


    function [P1]=SinusoidalDecay(Coefficients,t1)
        A1 = Coefficients(1);
        B1 = Coefficients(2);
        C1 = Coefficients(3);
        D1 = Coefficients(4);
        freq1 = Coefficients(5);
        td1 = Coefficients(6);
        vf1 = Coefficients(7);
        P1 = A1 +B1*(exp(-t1/td1).*(sin(2*pi*(freq1+vf1*(t1-t0)).*t1+D1)+C1));
    end

    L = length(t);
    if L <= 15           % data dense enoughe
        A = 'Not enough data points, unable to do fitting!';
        B = A;
        C = A;
        D = A;
        freq = A;
        td = A;
        varf = A;
        if nargout > 6
            varargout{1} = A;
        end
        return;
    end
    
    t0 = t(1);
    
    A0 = NaN;
    B0 = NaN;
    C0 = NaN;
    D0 = NaN;
    freq0 = NaN;
    td0 = NaN;
    LeastOscN = 6;
    if nargin > 2
        temp = varargin{1};
        LeastOscN = temp;
    end
    if nargin > 3
        temp = varargin{2};
        if ~isempty(temp)
            freq0 = temp;
        end
    end
    if nargin > 4
        temp = varargin{3};
        if ~isempty(temp)
            td0 = temp;
        end
    end
    if nargin > 5
        A0 = varargin{4};
    end
    if nargin > 6
        B0 = varargin{5};
    end
    if nargin > 7
        C0 = varargin{6};
    end
    if nargin > 8
        D0 = varargin{7};
    end
    if L<40
        NSegs = 4;
    elseif L<100
        NSegs = 6;
    elseif L< 200
        NSegs = 8;
    else
        NSegs = 12;
    end
    NperSeg = ceil(L/NSegs);
    if isnan(A0)
        A0 = mean(P(end-NperSeg+1:end));
    end
    if isnan(B0)
        B0 = max(P) - min(P);
    end
    if isnan(C0)
        C0 = A0 - (max(P) + min(P))/2;
    end
    if isnan(D0)
        D0 = 0;
    end
    if isnan(td0)
        td0 = t(end)/2;
    end
    if isnan(freq0)
        idx1 = NperSeg+1;
        idx2 = L;
        for ii = 1:NSegs-1
            idx2 = idx1+NperSeg-1;
            if idx2 <= L && (max(P(idx1:idx2)) - min(P(idx1:idx2))) < B0/5
                td0 = t(idx2)/2;
                break;
            end
            idx1 = idx2;
        end
        FreqLB = max([40e-3, LeastOscN/(t(min(idx2,L))-t(1))]);
        FreqHB = min([0.5, (1/(t(2)-t(1)))/2]);
        [Frequency,Amp] = FFTSpectrum(t,P);
        Lf = length(Amp);
        if Lf < 50
            Amp = smooth(Amp,3);
        elseif Lf < 150
            Amp = smooth(Amp,5);
        elseif  Lf < 300
            Amp = smooth(Amp,7);
        else
            Amp = smooth(Amp,9);
        end
        for ii = 1:length(Frequency);
            if Frequency(ii)>FreqLB
                if ii>1
                    Frequency(1:ii-1)=[]; 
                    Amp(1:ii-1)=[];
                end
                break;
            end
        end
        for ii = 1:length(Frequency);
            if Frequency(ii)>FreqHB
                Frequency(ii:end)=[]; 
                Amp(ii:end)=[];
                break;
            end
        end
        [~,idx]=max(Amp);
        freq0 = Frequency(idx);
    end
    Coefficients(1) = A0;
    Coefficients(2) = B0;
    Coefficients(3) = C0;
    Coefficients(4) = D0;
    Coefficients(5) = freq0;
    Coefficients(6) = td0;
    varf0 =  0.3*freq0/(t(end)-t(1));
    Coefficients(7) = varf0;
    lb = [A0*0.7,C0*0.7,-pi,freq0*0.7,td0*0.8*0.7,varf0*0.7];
    ub = [A0/0.7,C0/0.7,+pi,freq0/0.7,td0/0.8/0.7,varf0/0.7];
    for ii = 1:3
%         [Coefficients,~,residual,~,~,~,J] = lsqcurvefit(@SinusoidalDecay,Coefficients,t,P);
        [Coefficients,~,residual,~,~,~,J] = lsqcurvefit(@SinusoidalDecay,Coefficients,t,P,lb,ub);
    end
    A = Coefficients(1);
    B = Coefficients(2);
    C =  Coefficients(3);
    D = Coefficients(4);
    freq = Coefficients(5);
    td = Coefficients(6);
    varf = Coefficients(7);
    if nargout > 7
        varargout{1} = nlparci(Coefficients,residual,'jacobian',J);
    end
end