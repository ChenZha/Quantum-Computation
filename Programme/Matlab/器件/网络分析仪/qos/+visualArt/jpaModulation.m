function jpaModulation()
    load('D:\170502_demo\jpa_modulation.mat');
    hf = qes.ui.qosFigure('JPA Modulation',false);
    set(hf,'ToolBar','none','MenuBar','none','Position',[100,100,1200,700]);
    ax = axes('Parent',hf);
%     imagesc(x,y/1e9,z,'Parent',ax);
    surf(x,y/1e9,z,'Parent',ax);
    shading interp 
    set(ax,'YDir','normal');
    xlabel('JPA Bias Voltage(V)');
    ylabel('Signal Frequency(GHz)');
    colormap(qes.ui.colormap.haxby(128));
    view(ax,-25,80);
    az = [-35:0.3:-15,-15:-0.3:-35];
    r = linspace(0.3,1,numel(az));
    zlim = [0,max(max(z))];
    swpsz = [100,200];
    lo = qes.util.looper(1:swpsz(1),1:swpsz(1));
    totalSteps = swpsz(1)*swpsz(2);
    startTime = now;
    while 1
    for ii = 1:numel(az)
        noise =  0.15*range(z(:))*rand(size(z));
        surf(x,y/1e9,z*r(ii)+noise*(1-0.9*r(ii)),'Parent',ax);
        shading interp 
        set(ax,'YDir','normal','ZLim',zlim);
        xlabel('JPA Bias Voltage(V)');
        ylabel('Signal Frequency(GHz)');
        colormap(qes.ui.colormap.haxby(128));
        % view(ax,az(ii),80);
        view(ax,-25,80);
        drawnow;
        if lo.isDone
            startTime = now;
            lo = qes.util.looper(1:swpsz(1),1:swpsz(1));
        end
        TimeTaken = now - startTime;
        swpidxs = cell2mat(lo());
        if isempty(swpidxs)
            continue;
        end
        stepsDone = (swpidxs(1)-1)*swpsz(1)+swpidxs(2);
        progress = stepsDone/totalSteps;
        str2 = [num2str(100*progress,'%0.0f'),'%,'];
        TimeLeft = (totalSteps - stepsDone)/stepsDone*TimeTaken*24; % in hours
        hh = floor(TimeLeft);
        mm = round(60*mod(TimeLeft,1));
        ss = round(60*mod(60*TimeLeft,1));
        disp(sprintf(...
            'Experiment[JPA Modulation] Sweep 1: %d of %d | Sweep 2: %d of %d',...
            swpidxs(1),swpsz(1),swpidxs(2),swpsz(2)));
        disp(['Running: ',str2,'    ',...
            num2str(hh,'%0.0f'),'hr ',num2str(mm,'%0.0f'),'min ',num2str(ss,'%0.0f'),'sec left.']);
        pause(0.05);
    end
    end
end