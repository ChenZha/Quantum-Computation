function [alpha,tau] = fitZRingPhase(delay,phase,zPulseLength,gateLn,offset,order,plotResult)
% 

% Copyright 2018 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com

    if nargin < 6
        order = 4;
    end
    if nargin < 7
        plotResult = true;
    end

    phase = unwrap(phase);
    phase = phase - phase(end);
    if mean(phase) < 0
        phase = - phase;
    end
    phase__ = [];
    chnl = 1;
    function D = fitFunc(x_)
        wv = qes.waveform.rect(zPulseLength, 1);
        DASequence = qes.waveform.DASequence(chnl,qes.waveform.sequence(wv));
        DASequence.xfrFunc = com.qos.waveform.XfrFuncShots(x_(1:order),x_(order+1:2*order));
    %     DASequence.padLength = 5e3;
        samples = DASequence.samples();
        samples = samples(1,:);
        t0 = zPulseLength+ceil(offset/2)+gateLn;
        samples = samples(t0+1:t0+max(delay)+1);
        samples = samples - samples(end);
        phase_ = fliplr(cumsum(fliplr(samples))); % assume linear zpa to f01 shift: zpa ring amplitude is very small
%         phase_ = phase_ - phase_(1);
        phase_ = phase_(delay+1);
%         phase_ = interp1(1:numel(phase_),phase_,linspace(1,numel(phase_),numel(phase)),'linear');
%         phase__ = phase(end)*phase_/phase_(end);
        ln = ceil(length(delay)/2);
        r = phase_(1:ln)./phase(1:ln);
        phase__ = phase_/mean(r);
        D = sum((phase - phase__).^2);
    end

    % tau  = (-log(log(td/10.67)/13.5)/6.326)^5; 
    switch order
        case 2
            x0 = [0.01,0.01,...
                 (-log(log(900/10.67)/13.5)/6.326)^5, (-log(log(90/10.67)/13.5)/6.326)^5,...
                ];
            LB = [-0.08,-0.08,...
                (-log(log(1400/10.67)/13.5)/6.326)^5,  (-log(log(300/10.67)/13.5)/6.326)^5,...
               ]; 
            UB = [0.08,0.08,...
                (-log(log(150/10.67)/13.5)/6.326)^5, (-log(log(40/10.67)/13.5)/6.326)^5,...
                ];
        case 3
            x0 = [0.01,0.01,0.01,...
                 (-log(log(1200/10.67)/13.5)/6.326)^5,  (-log(log(500/10.67)/13.5)/6.326)^5,  (-log(log(90/10.67)/13.5)/6.326)^5,...
                ];
            LB = [-0.08,-0.08,-0.08,...
                (-log(log(1600/10.67)/13.5)/6.326)^5,   (-log(log(1000/10.67)/13.5)/6.326)^5,    (-log(log(200/10.67)/13.5)/6.326)^5,...
               ];
            UB = [0.08,0.08,0.08,...
                (-log(log(700/10.67)/13.5)/6.326)^5,    (-log(log(100/10.67)/13.5)/6.326)^5,   (-log(log(40/10.67)/13.5)/6.326)^5,...
                ];
        case 4
            x0 = [0.01,0.01,0.01,0.01,...
                 (-log(log(1600/10.67)/13.5)/6.326)^5,  (-log(log(700/10.67)/13.5)/6.326)^5,  (-log(log(300/10.67)/13.5)/6.326)^5,  (-log(log(90/10.67)/13.5)/6.326)^5,...
                ];
            LB = [-0.05,-0.04,-0.03,-0.02,...
                (-log(log(2500/10.67)/13.5)/6.326)^5,   (-log(log(1200/10.67)/13.5)/6.326)^5,    (-log(log(500/10.67)/13.5)/6.326)^5,  (-log(log(150/10.67)/13.5)/6.326)^5,...
               ];
            UB = [0.05,0.04,0.03,0.02,...
                (-log(log(800/10.67)/13.5)/6.326)^5,    (-log(log(300/10.67)/13.5)/6.326)^5,   (-log(log(100/10.67)/13.5)/6.326)^5,  (-log(log(40/10.67)/13.5)/6.326)^5,...
                ];
        otherwise
            error('not supported');
    end
    
    options = optimset('Display','iter','MaxFunEvals',1000,'TolX',1e-6,'TolFun',1e-6);
    [x,fval,exitflag,output] = qes.util.fminsearchbnd(@fitFunc,x0,LB,UB,options);
    alpha = x(1:order);
    tau = x(order+1:2*order);
    if plotResult
        hf = qes.ui.qosFigure('Z pulse ring phase fit',false);
        ax = axes('parent',hf);
        plot(ax,delay,phase,'.r',delay,phase__,'-b');
        legend(ax, {'data','fit'});
        xlabel(ax,'delay (sample points)');
        ylabel(ax,'accumulalted phase(rad)');
        title(ax,['\alpha:[',num2str(alpha,'%0.4e, '),']',10,'\tau:[',num2str(tau,'%0.4e, '),']']);
    end
    
end