function Chart(obj)
    % a private method

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

%     persistent lastxlimitrestore
%     if isempty(lastxlimitrestore)
%         lastxlimitrestore = 0;
%     end

    XLim = get(obj.temperatureax,'XLim');
    TempYLim = get(obj.temperatureax,'YLim');
    PresYLim = get(obj.pressureax,'YLim');
    x_ = obj.time(1:obj.dpoint,1);
    dispstartidx = find(x_>=XLim(1),1,'first');
    if isempty(dispstartidx)
        dispstartidx = Inf;
    end
    dispendidx = find(x_<=XLim(2),1,'last');
    if isempty(dispendidx)
        dispendidx = 0;
    end
    
%     if now -  lastxlimitrestore < 0.5/24 % keep zoomed x limits for half an hour.
%         XLim = get(obj.temperatureax,'XLim');
%         TempYLim = get(obj.temperatureax,'YLim');
%         PresYLim = get(obj.pressureax,'YLim');
%         x_ = obj.time(1:obj.dpoint,1);
%         dispstartidx = find(x_>=XLim(1),1,'first');
%         if isempty(dispstartidx)
%             dispstartidx = Inf;
%         end
%         dispendidx = find(x_<=XLim(2),1,'last');
%         if isempty(dispendidx)
%             dispendidx = 0;
%         end
%     else
%         XLim = [obj.time(1),obj.time(obj.dpoint)];
%         t = obj.temperature(:);
%         t = t(~isnan(t));
%         TempYLim = [min(t),max(t)];
%         if isempty(TempYLim)
%             TempYLim = [2e-3,350];
%         end
%         p = obj.pressure(:);
%         p = p(~isnan(p));
%         PresYLim = 1000*[min(p),max(p)];
%         if isempty(PresYLim)
%             PresYLim = [1e-5,5e3];
%         end
%         dispendidx = 1;
%         dispstartidx = obj.dpoint;
%         lastxlimitrestore = now;
%     end

    dispstep = 1;
    N = floor((dispendidx - dispstartidx)/dispstep/1000);
    if N > 1
        dispstep = N*dispstep;
    end
    dispidx = dispstartidx:dispstep:dispendidx;
    if length(dispidx) < 2
        return;
    end

    x = NaN*ones(length(obj.time(dispidx,1)),obj.numtempchnls);
    legendstrs = {};
    for ii =1:obj.numtempchnls
        x(:,ii) = obj.time(dispidx,1);
        
        
        if isnan(obj.temperature(obj.dpoint,ii))
            legendstrs{ii} = [obj.tempchnlnames{ii},'=>?'];
        elseif obj.temperature(obj.dpoint,ii) >= 1
            legendstrs{ii} = [obj.tempchnlnames{ii},'=>',num2str(obj.temperature(obj.dpoint,ii),'%0.1f'),'K'];
        else
            legendstrs{ii} = [obj.tempchnlnames{ii},'=>',num2str(1e3*obj.temperature(obj.dpoint,ii),'%0.1f'),'mK'];
        end
    end
    hold(obj.temperatureax,'off');
    plot(obj.temperatureax,x,obj.temperature(dispidx,:),'LineWidth',2);
    xlabel(obj.temperatureax,['Time, last updation: ',datestr(obj.time(obj.dpoint,1),'dd mmm HH:MM:SS')]);
    ylabel(obj.temperatureax,'Temperature');
    datetick(obj.temperatureax,'x','keeplimits');
%     set(obj.temperatureax,'YScal','log','XGrid','on','YTick',...
%         [5e-3,10e-3,20e-3,50e-3,100e-3,0.5,1,10,50,100,200,300],'YTickLabel',...
%         {'5mK','10mK','20mK','50mK','100mK','500mK','1K','10K','50K','100K','200K','300K'});
    set(obj.temperatureax,'YScal','log','XGrid','on','YTick',...
        [5e-3,10e-3,20e-3,50e-3,100e-3,0.5,1,10,50,100,200,300],'YTickLabel',...
        {'5mK','10mK','20mK','50mK','100mK','500mK','1K','10K','50K','100K','200K','300K'},...
        'YLim',TempYLim);
%             grid(obj.temperatureax,'on');
    legend(obj.temperatureax,legendstrs,'Location','NorthWest');

    x = NaN*ones(length(obj.time(dispidx,1)),obj.npreschls);
    legendstrs = {};
    for ii =1:obj.npreschls
        x(:,ii) = obj.time(dispidx,1);
        if ~isnan(obj.pressure(obj.dpoint,ii))
            str = num2str(1000*obj.pressure(obj.dpoint,ii),'%0.2e');
        else
            str = '?';
        end
        legendstrs{ii} = [obj.preschlnames{ii},'=>', str];
    end
    hold(obj.pressureax,'off');
    plot(obj.pressureax,x,1000*obj.pressure(dispidx,:),'LineWidth',2);
    xlabel(obj.pressureax,['Time, last updation: ',datestr(obj.time(obj.dpoint,1),'dd mmm HH:MM:SS')]);
    ylabel(obj.pressureax,'Pressure (mBar)');
    datetick(obj.pressureax,'x','keeplimits');
    set(obj.pressureax,'YScal','log','XGrid','on','YTick',...
        [1e-4,1e-2,1,100,1e4],'XLim',XLim,'YLim',PresYLim);
%             grid(obj.pressureax,'on');
    legend(obj.pressureax,legendstrs,'Location','NorthWest');
    drawnow;
end