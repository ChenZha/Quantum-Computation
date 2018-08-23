function [Qi,Qc,varargout] = FitQ(df,invs21,plotfilt)
    % fit internal quality factors(Qi) and coupling quality factors(Qc) of
    % a resonator from its normalized transmission invs21 = 1/S21.
    % df = (f-f0)/f0 is the normalized frequency, f0 is the resonance
    % frequency.
    % plotfilt: true/false, optional, plot data or not.
    % based on Applied Physics Letters 100(11):113510.
    
% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    Coefficients(1) = 2;
    Coefficients(2) = 100;
    for ii = 1:5
        [Coefficients,~,residual,~,~,~,J] = lsqcurvefit(@InvS21,Coefficients,df,invs21);
    end
    Qi = Coefficients(2)/(1i*2);
    Qc = abs(Qi/Coefficients(1));
    if nargout > 4
        varargout{1} = nlparci(Coefficients,residual,'jacobian',J);
    end
    %% plot
    if nargin == 2 || ~plotfilt
        return;
    end
    figure(); plot(real(invs21),imag(invs21),'ob','LineWidth',2); hold on;
    invs21f = InvS21(Coefficients,df);
    plot(real(invs21f),imag(invs21f),'-r','LineWidth',2); pbaspect([1 1 1]);
    xlabel('Re[S_{21}^{-1}]'); ylabel('Im[S_{21}^{-1}]'); legend({'data','fit'});
    figure(); plot(df,mag2db(abs(1./invs21)),'ob','LineWidth',2); hold on;
    plot(df,mag2db(1./invs21f),'-r','LineWidth',2);
    xlabel('(f - f_0)/f0'); ylabel('S_{21} Amplitude (dB)'); legend({'data','fit'});
    figure(); plot(df,angle(1./invs21),'ob','LineWidth',2); hold on;
    plot(df,angle(1./invs21f),'-r','LineWidth',2);
    xlabel('(f - f_0)/f0'); ylabel('S_{21} Phase'); legend({'data','fit'});
end

function IS = InvS21(Coefficients,x)
    a = Coefficients(1);
    b = Coefficients(2);
    IS = 1+a./(1+b*x);
end