function CreateGUI(obj)
    %

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    AlertSchemeOptions = {'Idle','Base Temperature','Warming up','Cooling down','No Alert'};
    choice = questdlg_multi(AlertSchemeOptions, 'Alert options', 'No Alert', 'Select an alert scheme:');
    if isempty(choice)
        obj.process = length(AlertSchemeOptions);
    else
        obj.process = choice;
    end
    BkGrndColor = [0.941   0.941   0.941];
    if isempty(obj.parent) || ~ishghandle(obj.parent)
        obj.parent = figure('NumberTitle','off','MenuBar','none','Toolbar','none',...
            'Name',['QOS | Dilution Fridge | ', obj.fridgeobj.name],...
            'HandleVisibility','callback','Color',BkGrndColor,...
            'CloseRequestFcn',{@ExitCbk},'UserData',obj,'DockControls','off','Visible','off');
        tb = uitoolbar(obj.parent);
        uitoggletool(tb,'CData',icons.ZoomIn,'TooltipString','Zoom In','ClickedCallback','putdowntext(''zoomin'',gcbo)');
        uitoggletool(tb,'CData',icons.ZoomOut,'TooltipString','Zoom Out','ClickedCallback','putdowntext(''zoomout'',gcbo)');
        uipushtool(tb,'CData',icons.DoubleArrow,'TooltipString','Restore Axes Range','ClickedCallback',{@RestoreAxesRange},'UserData',obj);
        uitoggletool(tb,'CData',icons.Datatip,'TooltipString','Data Cursor','ClickedCallback','putdowntext(''datatip'',gcbo)','Separator','on');
        movegui(obj.parent,'center');
    else
        return;
    end
    ParentUnitOrig = get(obj.parent,'Units');
    set(obj.parent,'Units','characters');
    ParentPosOrig = get(obj.parent,'Position');
    panelpossize = [0,0,200,47];
    set(obj.parent,'Position',[ParentPosOrig(1),ParentPosOrig(2),panelpossize(3),panelpossize(4)]);
    set(obj.parent,'Units',ParentUnitOrig); % restore to original units.
    handles.basepanel = uipanel(...
        'Parent',obj.parent,...
        'Units','characters',...
        'Position',panelpossize,...
        'backgroundColor',BkGrndColor,...
        'Title','',...
        'BorderType','none',...
        'HandleVisibility','callback',...
        'visible','on',...
        'Tag','parameterpanel','DeleteFcn',{@GUIDeleteCallback});
    movegui(obj.parent,'center');
    
    pos = [13,3.5,120,19];
    if obj.time(1)<obj.time(obj.dpoint)
        xlimits = [obj.time(1),obj.time(obj.dpoint)];
    else
        xlimits = [now-2,now+0.5];
    end
    obj.temperatureax = axes('Parent',obj.parent,...
        'Units','characters','Position',pos,...
            'Box','on','Units','characters','YScal','log',...
            'XLim',xlimits,'YLim',[5e-3,400]);
    pos = [12,4,120,19];
    pos(2) = 26;
    obj.pressureax = axes('Parent',obj.parent,...
        'Units','characters','Position',pos,...
            'Box','on','Units','characters','YScal','log',...
            'XLim',xlimits,'YLim',[10e-4,10e4]);
    linkaxes([obj.temperatureax,obj.pressureax],'x');

    pos = [137,44,20,1.5];
    handles.EnableBtn = uicontrol('Parent',handles.basepanel,'Style','togglebutton','string','Enable',...
        'Min',0,'Max',1,'Value',0,'FontSize',10,'FontUnits','points','Units','characters',...
        'Position',pos,'Callback',{@EnableBtnCallback},...
        'Tooltip','Enable or disable control panel.');
    pos_ = pos;
    pos_(1) = pos(1)+pos(3)+2;
    handles.AlarmBtn = uicontrol('Parent',handles.basepanel,'Style','togglebutton','string','Test/Stop Alarm',...
        'Min',0,'Max',1,'Value',0,'FontSize',10,'FontUnits','points','Units','characters',...
        'Position',pos_,'Callback',{@TestStopAlarm},...
        'Tooltip','Test alarm or stop alarm.');
    
    pos = [137,42,20,1];
    handles.SetProcessTitle = uicontrol('Parent',handles.basepanel,'Style','text','string','Alert scheme',...
        'FontSize',10,'FontUnits','points','HorizontalAlignment','Left','Units','characters','Position',pos,...
        'Tooltip','Select a emergency alert scheme.');
    pos(1) = pos(1)+pos(3)+1;
    pos(3) = 35;
    handles.Process = uicontrol('Parent',handles.basepanel,'Style','popupmenu',...
        'string',AlertSchemeOptions,...
        'FontSize',9,'FontUnits','points','HorizontalAlignment','Left',...
        'ForegroundColor',[0.5,0.5,1],'BackgroundColor',[0.9,1,0.8],'Units','characters','Position',pos,...
        'Callback',{@SelectProcessCallback},'Tooltip','Select a emergency alert scheme.','Enable','off');
    set(handles.Process,'value',obj.process);
    
    pos = get(handles.SetProcessTitle,'Position');
    pos(2) = pos(2) - 1.5;
    handles.SetNotIntTitle = uicontrol('Parent',handles.basepanel,'Style','text','string','Notification interval',...
        'FontSize',10,'FontUnits','points','HorizontalAlignment','Left','Units','characters','Position',pos,...
        'Tooltip','Select the notification iterval.');
    pos(1) = pos(1)+pos(3)+1;
    pos(3) = 35;
    handles.SetNotInt = uicontrol('Parent',handles.basepanel,'Style','popupmenu',...
        'string',{'30 minutes','1 hour','2 hours','3 hours','4 hours','never except emergency'},...
        'FontSize',9,'FontUnits','points','HorizontalAlignment','Left','Value',2,...
        'ForegroundColor',[0.5,0.5,1],'BackgroundColor',[0.9,1,0.8],'Units','characters','Position',pos,...
        'Callback',{@SelectNotIntervalCallback},'Tooltip','Set the current process.','Enable','off');
    pos_ = get(handles.SetNotIntTitle,'Position');
    pos_(2) = pos_(2) - 26.5;
    pos_(3) = pos(1)+pos(3)-pos_(1);
    pos_(4) = 25;
    handles.InfoDisp = uicontrol('Parent',handles.basepanel,'Style','text',...
        'string',[datestr(obj.time(obj.dpoint,1),'dd mmm HH:MM:SS'),10,'Monitor started.'],...
        'FontSize',10,'FontUnits','points','HorizontalAlignment','Left','Units','characters','Position',pos_,...
        'Min',0,'Max',3,'Tooltip','Latest actions.');
    
    if obj.notifyinterval < 45
        set(handles.SetNotInt,'value',1);
        obj.notifyinterval = 30;
    elseif obj.notifyinterval < 90
        set(handles.SetNotInt,'value',2);
        obj.notifyinterval = 60;
    elseif obj.notifyinterval < 150
        set(handles.SetNotInt,'value',3);
        obj.notifyinterval = 120;
    elseif obj.notifyinterval < 210
        set(handles.SetNotInt,'value',4);
        obj.notifyinterval = 180;
    elseif obj.notifyinterval < 500
        set(handles.SetNotInt,'value',5);
        obj.notifyinterval = 240;
    else
        set(handles.SetNotInt,'value',6);
        obj.notifyinterval = Inf;
    end
    pvflag = hvar;
    pvflag.x = false;
    handles.pvflag = pvflag;
    obj.uihandles = handles;
    set(handles.basepanel,'UserData',obj);
    obj.Chart();
    set(obj.parent,'Visible','on');
end

function EnableBtnCallback(src,entdata)
    obj = get(get(src,'Parent'),'UserData');
    handles = obj.uihandles;
    % to do: add password validation
    if get(handles.EnableBtn,'Value');
        PasswordValidation(obj.password,handles.pvflag,['QES | ',obj.fridgeobj.name]);
        if ~handles.pvflag.x
            set(handles.EnableBtn,'Value',get(handles.EnableBtn,'Min'));
            return;
        end
        set(handles.EnableBtn,'String','Disable');
        set(handles.Process,'Enable','on');
        set(handles.SetNotInt,'Enable','on');
    else
        set(handles.EnableBtn,'String','Enable');
        set(handles.Process,'Enable','off');
        set(handles.SetNotInt,'Enable','off');
    end
end

function TestStopAlarm(src,entdata)
    obj = get(get(src,'Parent'),'UserData');
    if ~isempty(obj.alarmobj) && isobject(obj.alarmobj) && isvalid(obj.alarmobj)
        switch obj.alarmobj.Running
            case 'on'
                stop(obj.alarmobj);
                oldinfostr = get(obj.uihandles.InfoDisp,'String');
                oldinfostr = TrimNotes(oldinfostr);
                oldinfostr = oldinfostr(:)';
                newinfostr = [datestr(obj.time(obj.dpoint,1),'dd mmm HH:MM:SS'),10,'Stop alarm',10,oldinfostr];
            case 'off'
                start(obj.alarmobj);
                oldinfostr = get(obj.uihandles.InfoDisp,'String');
                oldinfostr = TrimNotes(oldinfostr);
                oldinfostr = oldinfostr(:)';
                newinfostr = [datestr(obj.time(obj.dpoint,1),'dd mmm HH:MM:SS'),10,'Start alarm',10,oldinfostr];
        end
        if length(newinfostr) > 1024;
            newinfostr(1024:end) = [];
        end
        set(obj.uihandles.InfoDisp,'String',newinfostr);
    end
end

function SelectProcessCallback(src,entdata)
    obj = get(get(src,'Parent'),'UserData');
    handles = obj.uihandles;
    % to do: add password validation
    selection = get(handles.Process,'Value');
    obj.process = selection;
end

function SelectNotIntervalCallback(src,entdata)
    obj = get(get(src,'Parent'),'UserData');
    handles = obj.uihandles;
    % to do: add password validation
    notifyinterval = get(handles.SetNotInt,'value');
    switch notifyinterval
        case 1
            obj.notifyinterval = 30;
        case 2
            obj.notifyinterval = 60;
        case 3
            obj.notifyinterval = 120;
        case 4
            obj.notifyinterval = 180;
        case 5
            obj.notifyinterval = 240;
        case 6
            obj.notifyinterval = Inf;
    end
end

function RestoreAxesRange(src,entdata)
    obj = get(src,'UserData');
    obj.RestoreAxesRange();
end

function GUIDeleteCallback(src,entdata)

end

function ExitCbk(src,entdata)
    obj = get(src,'UserData');
    pvflag = hvar;
    pvflag.x = false;
    PasswordValidation(obj.password,pvflag,['QES | ',obj.fridgeobj.name]);
    if ~pvflag.x
        return;
    end
    obj.delete();
    delete(src);
end

