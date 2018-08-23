function [center0, center1, F00,F11,hf,axs,width] =...
    iq2prob_means(iq_raw_0,iq_raw_1,auto)
% iq2prob_centers: finds raw iq centers(where probability of distribution is maximum)
% F00: the probability of |0> correctly measured as |0>
% F11: the probability of |1> correctly measured as |0>
% F01: the probability of |0> erroneously measured as |1>
% F10: the probability of |1> erroneously measured as |0>
% define:
% F = [F00,F10; F01,F11],
% Pm = [Pm0; Pm1]; % the measured probability
% for a state
% S = a|0> + b|1>;
% P = [P0; P1] = [abs(a)^2; abs(b)^2]; %|0>, |1> state probabilities
% by definition:
% Pm = F*[P0; P1];
% we have:
% P = inv(F)*Pm;

% Yulin Wu, 2017

if nargin < 3 % in case of auto, data will not be shown and automatically update settings without requesting use decision.
    auto = false;
end

mean0=mean(iq_raw_0);
mean1=mean(iq_raw_1);
N=length(iq_raw_0);
F00=0;
F11=0;
for ii=1:N
    if(abs(iq_raw_0(ii)-mean0)<abs(iq_raw_0(ii)-mean1))
        F00=F00+1;
    end
    if(abs(iq_raw_1(ii)-mean1)<abs(iq_raw_1(ii)-mean0))
        F11=F11+1;
    end
end
F00=F00/N;
F11=F11/N;
center0=mean0;
center1=mean1;
theta10 = angle(mean1 - mean0);

e0r = real(iq_raw_0);
e0r_ = abs(e0r - mean(e0r));
width_r = 2*std(e0r_);
outlierInd_r = e0r_ > width_r;
e0i = imag(iq_raw_0);
e0i_ = abs(e0i - mean(e0i));
width_i = 2*std(e0i_);
outlierInd_i = e0i_ > width_i;
outlierInd = outlierInd_r | outlierInd_i;

width = (width_r+width_i)/2;

if ~auto
    hf = qes.ui.qosFigure('IQ Raw',true);
    ax1 = subplot(2,2,[1,3],'Parent',hf);
    ax2 = subplot(2,2,2,'Parent',hf);
    ax3 = subplot(2,2,4,'Parent',hf);
    hf.UserData = ax1;
    
    num_samples = numel(iq_raw_0);
    threshold = NaN;
    polarity = NaN;
    if num_samples < 2e4
        nBins = 50;
    else
        nBins = 100;
    end
    nEval4plot = [];
    v4plot = [];
    count = 0;
    
    e1 = real(iq_raw_1*exp(-1j*theta10));
    e0 = real(iq_raw_0*exp(-1j*theta10));
    x_0 = min(min(e1),min(e0));
    x_1 = max(max(e1),max(e0));
    binSize = abs(x_0 - x_1)/nBins;
    binEdges = x_0-binSize/2:binSize:x_1+binSize/2;
    p1 = histcounts(e1,binEdges)/num_samples;
    p0 = histcounts(e0,binEdges)/num_samples;
    dcp = cumsum(p1) - cumsum(p0);
    [v, cidx] = max(abs(dcp));
    threshold = binEdges(cidx)+binSize/2;
    x = binEdges(1:end-1)+binSize/2;
    
    plot(ax1,iq_raw_0,'b.','MarkerSize',4);
    hold(ax1,'on');
    plot(ax1,iq_raw_1,'r.','MarkerSize',4);
    XL = get(ax1,'XLim');
    YL = get(ax1,'YLim');
    legend(ax1,{'|0>','|1>'},'Location','southeast');
    % pline_points = [c_r+1j*c_i - 5*binSize*nBins*exp(1j*a),c_r+1j*c_i + 5*binSize*nBins*exp(1j*a)];
    % plot(ax1,real(pline_points),imag(pline_points),'--','Color',[0,1,1],'LineWidth',2);
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
    plot(ax3,F00+F11-1,'-*');
    %             set(ax3,'YLim',[0,1]);
    xlabel(ax3,'nth evaluation');
    ylabel(ax3,'visibilty(P_{1->1}-P_{0->1})');
    title(num2str(F00+F11-1));
    drawnow;
    
    axs = [ax1,ax2,ax3];
    
    try
        hold(axs(1),'on');
        plot(axs(1),center0,'+','Color','w','MarkerSize',15,'LineWidth',1);
        plot(axs(1),center1,'+','Color','g','MarkerSize',15,'LineWidth',1);
        hold(axs(1),'off');
    catch
    end
    
else
    hf = [];
    axs=[];
end
end