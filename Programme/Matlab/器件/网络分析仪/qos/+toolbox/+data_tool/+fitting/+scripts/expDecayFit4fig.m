function expDecayFit4fig()
% Fit exponential decay data by load the figure file in which the data is
% plotted. Fit results are displayed in the cmd window and plotted on to the the figure. 
% How to use: just run this funciton, no input arguments needed.

%
% Yulin Wu, SC5,IoP,CAS. wuyulin@ssc.iphy.ac.cn/mail4ywu@gmail.com
% $Revision: 1.0 $  $Date: 2012/04/08 $

    import toolbox.data_tool.fitting.*

    persistent lastselecteddir % last direction selection is remembered
    if isempty(lastselecteddir) || ~exist(lastselecteddir,'dir')
        Datafile = fullfile(pwd,'*.fig');
    else
        Datafile = fullfile(lastselecteddir,'*.fig');
    end
    [FileName,PathName,~] = uigetfile(Datafile,'Select the fig to fit:');
    if ischar(PathName) && isdir(PathName)
        lastselecteddir = PathName;
    end
    datafig = fullfile(PathName,FileName);
    if ~exist(datafig,'file')
        return;
    end
    h = openfig(datafig);
    figure(h);
    ln = findobj(gca,'type','line');
    if isempty(ln)
        title('No data found in figure.');
        return;
    elseif length(ln) > 1
        title('More than two data sets found, trying to fit the first.');
    end
    x = get(ln(1),'XData');
    y = get(ln(1),'YData');

    if length(x)<3 || x(1)+x(end) == 0
        title('Data length too short.');
        return;
    end
    [A,B,xd] = expDecayFit(x,y);
    L = length(x);
    step = (x(end)-x(1))/L/50;       % 50 times sampling density
    xf = x(1):step:x(end);
    yf = expDecay([A,B,xd],xf);
    home;
    fprintf('y = A +B*exp(-x/xd)\n');
    fprintf('A = %f   B = %f  td = %f\n ',A,B,xd);
    hold(gca,'on');
    xlimit = get(gca,'XLim');
    ylimit = get(gca,'YLim');
    plot(x,y,'bo','MarkerSize',8,'MarkerEdgeColor','b','MarkerFaceColor','b');
    plot(xf,yf,'r-','LineWidth',2);
    legend('data','fit');
    xlabel('x','FontSize',28);
    ylabel('y','FontSize',28);
    ylim([0.6,0.9]);
    title(['xd: ',num2str(xd,'%4.1f'),''],'FontSize',20)
    set(gca,'XLim',xlimit);
    set(gca,'YLim',ylimit);
    set(gcf,'Color',[1,1,1]);
end

function [P]=ExpDecay(Coefficients,t)

    %
    % Yulin Wu, SC5,IoP,CAS. mail4ywu@gmail.com
    % $Revision: 1.0 $  $Date: 2012/04/08 $
    A = Coefficients(1);
    B = Coefficients(2);
    td = Coefficients(3);
    P = A +B*exp(-t/td);
end