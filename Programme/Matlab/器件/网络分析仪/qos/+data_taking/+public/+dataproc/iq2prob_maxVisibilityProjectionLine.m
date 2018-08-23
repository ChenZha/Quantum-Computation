function [rPoint, ang, threshold, polarity, hf,axs] =...
			iq2prob_maxVisibilityProjectionLine(iq_raw_0,iq_raw_1,auto)
% iq2prob_maxVisibilityProjectionLine: finds the raw iq
% projection line which produces the maximum state probability visibility

% Yulin Wu, 2016/12/29

    import qes.*
    import sqc.*
    import sqc.op.physical.*

    num_samples = numel(iq_raw_0);
    
    if nargin < 3 % in case of auto, data will not be shown and automatically update settings without requesting use decision.
        auto = false;
    end
    if num_samples < 1e4
        warning('num_samples too small.');
    end

    iq_raw_1_mean = mean(iq_raw_1);
    iq_raw_0_mean = mean(iq_raw_0);

    if ~auto
        hf = qes.ui.qosFigure('IQ Raw',true);
        ax1 = subplot(2,2,[1,3],'Parent',hf);
        ax2 = subplot(2,2,2,'Parent',hf);
        ax3 = subplot(2,2,4,'Parent',hf);
        hf.UserData = ax1;
    else
        hf = [];
    end

    threshold = NaN;
    polarity = NaN;
    if num_samples < 2e4
        nBins = 50;
    else
        nBins = 100;
    end
    nEval = 0;
    nEval4plot = [];
    v4plot = [];
    count = 0;
    function inv_v = invVisibility(coef)
        c_r = coef(1);
        c_i = coef(2);
        c_ref = c_r+1j*c_i;
        a = coef(3);
        e1 = real((iq_raw_1-c_ref)*exp(-1j*a));
        e0 = real((iq_raw_0-c_ref)*exp(-1j*a));
        x_0 = min(min(e1),min(e0));
        x_1 = max(max(e1),max(e0));
        binSize = abs(x_0 - x_1)/nBins;
        binEdges = x_0-binSize/2:binSize:x_1+binSize/2;
        p1 = histcounts(e1,binEdges)/num_samples;
        p0 = histcounts(e0,binEdges)/num_samples;
        dcp = cumsum(p1) - cumsum(p0);
        [v, cidx] = max(abs(dcp));
        threshold = binEdges(cidx)+binSize/2;
        if dcp(cidx) <= 0
            polarity = 1;
        else
            polarity = -1;
        end
        inv_v = 1/v;
        if polarity > 0
			F00 = mean((iq_raw_0 - c_ref)*exp(-1j*a)< threshold);
            F11 = mean((iq_raw_1 - c_ref)*exp(-1j*a)> threshold);
        else
			F01 = mean((iq_raw_0 - c_ref)*exp(-1j*a)> threshold);
            F11 = mean((iq_raw_1 - c_ref)*exp(-1j*a)< threshold);
        end
        nEval = nEval +1;
        if ~auto
            x = binEdges(1:end-1)+binSize/2;
            try 
                if count == 5
                    plot(ax1,iq_raw_0,'b.','MarkerSize',4);
                    hold(ax1,'on');
                    plot(ax1,iq_raw_1,'r.','MarkerSize',4);
                    XL = get(ax1,'XLim');
                    YL = get(ax1,'YLim');
                    legend(ax1,{'|0>','|1>'},'Location','southeast');
                    pline_points = [c_r+1j*c_i - 5*binSize*nBins*exp(1j*a),c_r+1j*c_i + 5*binSize*nBins*exp(1j*a)];
                    plot(ax1,real(pline_points),imag(pline_points),'--','Color',[0,1,1],'LineWidth',2);
                    set(ax1,'PlotBoxAspectRatio',[1,1,1],'XLim',XL,'YLim',YL,...
                        'PlotBoxAspectRatio',[1,1,1],...
                        'DataAspectRatio',[1,1,1],'PlotBoxAspectRatio',[1,1,1]);
                    xlabel(ax1,'I');
                    ylabel(ax1,'Q');
                    title(ax1,['F_{0->0}: ',num2str(F00,'%0.2f'),', F_{1->1}: ',num2str(F11,'%0.2f')],...
                        'FontWeight','normal','FontSize',11);
                    hold(ax1,'off');

                    plot(ax2,x,p0,'b-',x,p1,'r-');
                    hold(ax2,'on');
                    plot(ax2,[threshold,threshold],get(ax2,'YLim'),'--','Color',[0.4,0.4,0.4]);
                    hold(ax2,'off');
                    legend(ax2,{'|0>','|1>'},'Location','southeast');
                    xlabel(ax2,'dashed line in the left plot');
                    ylabel(ax2,'distribution');
                    nEval4plot = [nEval4plot, nEval];
                    v4plot = [v4plot,v];
                    plot(ax3,nEval4plot,v4plot,'-');
        %             set(ax3,'YLim',[0,1]);
                    xlabel(ax3,'nth evaluation');
                    ylabel(ax3,'visibilty(P_{1->1}-P_{0->1})');
                    drawnow;
                    
                    count = 0;
                end
                count = count +1;
            catch
                % we need to go on even if the plot is closed by user
            end
        end
    end

    theta10 = angle(iq_raw_1_mean - iq_raw_0_mean);
    rmm = minmax(real(iq_raw_0));
    imm = minmax(imag(iq_raw_0));
    tol_iq = max(diff(rmm),diff(imm))*1e-4;
    tol_a = 0.1/2*pi;
    xsol = qes.util.fminsearchbnd(@invVisibility,[real(iq_raw_0_mean),imag(iq_raw_0_mean),theta10],...
        [rmm(1),imm(1),theta10-pi/2],[rmm(2),imm(2),theta10+pi/2],optimset('Display','off','MaxIter',15));

    rPoint = xsol(1)+1j*xsol(2);
    ang = xsol(3);
    axs = [];
    if ~auto
        axs = [ax1,ax2,ax3];
    end
end