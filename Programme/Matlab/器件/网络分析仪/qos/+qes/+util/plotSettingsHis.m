function axs = plotSettingsHis(settingsRoot,settings,timeBounds,axs, plotChange)
%

% Copyright 2018 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com

    if nargin < 3 || isempty(timeBounds)
        timeBounds = [0,Inf];
    end
    if isempty(settings)
        return;
    end
    if ~iscell(settings{1})
        settings = {settings};
    end
    numSettings = numel(settings);
    if nargin < 5
        plotChange = false;
    end
    if nargin < 4 || isempty(axs)
        columns = 3;
        rows = ceil(numSettings/3);
        numAxes = columns*rows;
        hf = qes.ui.qosFigure('Settings His. Records',false);
        axH = 0.85/rows;
        axW = 0.95/columns;
        axs = nan(1,rows*columns);
        h = 0.06;
        for ii = 1:columns
            v = 0.085;
            for jj = 1:rows
                axs(rows*(ii-1)+jj) = axes('parent',hf,'Position',[h,v,0.85*axW,axH],'Visible','on','Box','on');
                v = v + axH;
            end
            h = h + axW;
        end
    else
        numAxes = numel(axs);
        if numAxes < numSettings
            error('number of axes not equal to number of qubits');
        end
    end
    linkaxes(axs,'x');
    XLim = [Inf,-Inf];
    for ii = 1:numSettings
        [s, r, t] = qes.util.loadSettings(settingsRoot,settings{ii},true);
        r(end+1) = s;
        t(end+1) = now;
        rmvInd = t < timeBounds(1) | t > timeBounds(2);
        r(rmvInd) = [];
        t(rmvInd) = [];
        if ~isempty(t)
            if plotChange
                r = r - r(1);
            end
            if isreal(r)
                plot(axs(ii),t,r,'-o','MarkerSize',2,'Color',qes.ui.randSColor(),'LineWidth',1);
            else
                plot(axs(ii),t,real(r),'-o','MarkerSize',2,'Color',qes.ui.randSColor(),'LineWidth',1);
                hold(axs(ii),'on');
                plot(axs(ii),t,imag(r),'-o','MarkerSize',2,'Color',qes.ui.randSColor(),'LineWidth',1);
                legend(axs(ii),{'real','imag'});
                hold(axs(ii),'off');
            end
        end
        YLabel = strrep(settings{ii}{1},'_','\_');
        for jj = 2:numel(settings{ii})
            YLabel = [YLabel,'.',strrep(settings{ii}{jj},'_','\_')];
        end
        if plotChange
            YLabel = ['\Delta ', YLabel];
        end
        ylabel(axs(ii),YLabel);
        if ~isempty(t)
            XLim(1) = min(XLim(1),t(1));
            XLim(2) = max(XLim(2),t(end));
        end
    end
    numXTicks = 5;
    xticks = linspace(XLim(1),XLim(2),numXTicks);
    xtickLabels = cell(1,numXTicks);
    for ii = 1:numXTicks
        xtickLabels{ii} = datestr(xticks,'dd-HH:MM');
    end
    
    for ii = 1:numSettings
        set(axs(ii),'XLim',XLim);
%         datetick(axs(ii),'x','dd-HH:MM','keeplimits');
        set(axs(ii),'XTick',xticks,'XTickLabel',xtickLabels);
    end

end