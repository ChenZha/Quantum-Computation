function CreateGUI_resizable(obj)
% create gui

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com
    OPSYSTEM = lower(system_dependent('getos'));
    if any([strfind(OPSYSTEM, 'microsoft windows xp'),...
            strfind(OPSYSTEM, 'microsoft windows Vista'),...
            strfind(OPSYSTEM, 'microsoft windows 7'),...
            strfind(OPSYSTEM, 'microsoft windows server 2008'),...
            strfind(OPSYSTEM, 'microsoft windows server 2003')])
        InfoDispHeight = 5; % characters
        SelectDataUILn = 30;
        panelpossize = [0,0,260,45];
        mainaxshift = 4;
    elseif any([strfind(OPSYSTEM, 'microsoft windows 10'),...
            strfind(OPSYSTEM, 'microsoft windows server 10'),...
            strfind(OPSYSTEM, 'microsoft windows server 2012')])
        InfoDispHeight = 6; % characters
        SelectDataUILn = 35;
        panelpossize = [0,0,258.5,45];
        mainaxshift = 5;
    else
        InfoDispHeight = 5; % characters
        SelectDataUILn = 30; % characters
        panelpossize = [0,0,260,45]; % characters
        mainaxshift = 4;
    end
    %     str = system_dependent('getwinsys');

	% import qes.ui.*

    BkGrndColor = [0.941   0.941   0.941];
    handles.dataviewwin = figure('Units','characters','MenuBar','none',...
        'ToolBar','none','NumberTitle','off','Name','QOS | Data Viewer',...
        'Resize','on','HandleVisibility','callback','Color',BkGrndColor,...
        'DockControls','off','Visible','off');
	warning('off');
    jf = get(handles.dataviewwin,'JavaFrame');
    jf.setFigureIcon(javax.swing.ImageIcon(...
        im2java(qes.ui.icons.qos1_32by32())));
    warning('on');
    ParentUnitOrig = get(handles.dataviewwin,'Units');
    %set(handles.dataviewwin,'Units','characters');
    ParentPosOrig = get(handles.dataviewwin,'Position');
    %set(handles.dataviewwin,'Position',[ParentPosOrig(1),ParentPosOrig(2),panelpossize(3),panelpossize(4)]);
    %set(handles.dataviewwin,'Units',ParentUnitOrig); % restore to original units.   
    handles.dataviewwin.Units='normalized';
    handles.basepanel=uix.Panel(...
        'Parent',handles.dataviewwin,...
        'Units','characters',...
        'Position',panelpossize,...
        'backgroundColor',BkGrndColor,...
        'Title','',...
        'BorderType','none',...
        'HandleVisibility','callback',...
        'visible','on',...
        'Tag','parameterpanel','DeleteFcn',{@GUIDeleteCallback});

    
    %

    handles.basepanel.Units='normalized';
    handles.dataviewwin.Position=[0 0 .8 .8];
    handles.basepanel.Position=[0 0 1 1];
    
    backgroundlayout=uix.Grid('parent',handles.basepanel,'UserData',obj);
    headlayout=uix.Grid('parent',backgroundlayout,'padding',6,'UserData',obj);
    footlayout=uix.Grid('parent',backgroundlayout,'padding',2,'UserData',obj);
    backgroundlayout.Heights=[-8 -0.75];
    %

    leftlayout=uix.Grid('parent',headlayout,'padding',2,'UserData',obj);
    midlayout=uix.Grid('parent',headlayout,'padding',2,'spacing',6,'UserData',obj);
    rightlayout=uix.Grid('parent',headlayout,'padding',2,'UserData',obj);
    headlayout.Widths=[-10 -5 -4];

    %
    footleftlayout=uix.Grid('parent',footlayout,'padding',2,'UserData',obj);
    footmidlayout=uix.Grid('parent',footlayout,'padding',2,'spacing',2,'UserData',obj);
    footrightlayout=uix.Grid('parent',footlayout,'padding',2,'UserData',obj);
    footlayout.Widths=[35 -1 35];

    
    %footlayout
    handles.PreviousPageBtn = uicontrol('Parent',footleftlayout,'Style','pushbutton','string','<<',...
        'FontSize',18,'FontUnits','points','Units','characters','Callback',{@PNPageBtnCallback,-1},...
        'Tooltip','Single click: backward one page; Double click: backward multiple pages.');
    handles.PreviewAX = zeros(1,2*obj.numpreview+1);
    for ii = 1:2*obj.numpreview+1
        handles.PreviewAX(ii) = axes('Parent',uix.Grid('parent',footmidlayout,'UserData',obj),'Visible','on','HandleVisibility','callback',...
            'XTick',[],'YTick',[],'Box','on','Units','characters','Position',[0 0 1 1],...
            'UserData',[obj.numpreview,ii],'ButtonDownFcn',{@PreviewAXClickCallback});
    end
    %     set(handles.PreviewAX(ceil(length(handles.PreviewAX)/2)),'XColor',[1,0,0],'YColor',[1,0,0],...
    %         'LineWidth',3,'ButtonDownFcn',{});
    handles.NextPageBtn = uicontrol('Parent',footrightlayout,'Style','pushbutton','string','>>',...
        'FontSize',18,'FontUnits','points','Units','characters','Callback',{@PNPageBtnCallback,+1},...
        'Tooltip','Single click: forward one page; Double click: forward multiple pages.');
   
    %leftlayout
%     axeslayout=uix.Panel(...
%         'Parent',leftlayout,...
%         'Units','normalized',...
%         'UserData',obj,...
%         'Title','',...
%         'BorderType','none',...
%         'HandleVisibility','callback',...
%         'visible','on');
    axeslayout=uicontainer('Parent', leftlayout,'Units','normalized','UserData',obj);
    axeslayout.Units='normalized';
    handles.axeslayout=axeslayout;
    %pos  = get(handles.PreviewAX(end),'Position');
    pos = [235 0.8 13 3.5];
    pos(1) = 12;
    pos(3) = 110;
    pos(2) = pos(2)+pos(4)+mainaxshift;
    pos(4) = panelpossize(4) - pos(2) - 2.5;
    mainaxfullpos = pos;
    handles.mainaxfullpos = mainaxfullpos;
    pos_ = pos;
    pos_(3) = 90;
    pos_(4) = 26;
    mainaxreducedpos = pos_;
    colorbarpos = [mainaxfullpos(1)+mainaxfullpos(3)+1,7.25,1.5,36];
    handles.colorbarpos = colorbarpos;
    pos_xs = pos_;
    pos_xs(2) = pos_xs(2)+pos_xs(4);
    pos_xs(4) = pos(2)+pos(4) - pos_xs(2);
    handles.xsliceax = axes('Parent',axeslayout,'Visible','on','HandleVisibility','callback',...
        'HitTest','off','XTick',[],'YTick',[],'Box','on','Units','normalized',...
        'Position',Unitsturning(pos_xs),'Visible','off');
    pos_ys = pos_;
    pos_ys(1) = pos_ys(1)+pos_ys(3);
    pos_ys(3) = pos(1)+pos(3) - pos_ys(1);
    handles.ysliceax = axes('Parent',axeslayout,'Visible','on','HandleVisibility','callback',...
        'HitTest','off','XTick',[],'YTick',[],'Box','on','Units','normalized',...
        'Position',Unitsturning(pos_ys),'Visible','off');
    handles.mainax = axes('Parent',axeslayout,'Visible','on','HandleVisibility','callback',...
        'HitTest','off','XTick',[],'YTick',[],'Box','on','Units','normalized',...
        'Position',Unitsturning(pos));
    linkaxes([handles.mainax,handles.xsliceax],'x');
    linkaxes([handles.mainax,handles.ysliceax],'y');
 
    pos_cz = pos_ys;
    pos_cz(1) = pos_cz(1) + 3;
    pos_cz(2) = pos_cz(2)+pos_cz(4)+2;
    pos_cz(3) = 30;
    pos_cz(4) = 1.5;
    handles.cz = uicontrol('Parent',axeslayout,'Style','text','string','z:',...
        'FontSize',12,'FontUnits','points','HorizontalAlignment','Left',...
        'Units','normalized','Position',Unitsturning(pos_cz),'Visible','off');

    pos_cy = pos_cz;
    pos_cy(2) = pos_cy(2)+pos_cy(4);
    handles.cy = uicontrol('Parent',axeslayout,'Style','text','string','y:',...
        'FontSize',12,'FontUnits','points','HorizontalAlignment','Left',...
        'Units','normalized','Position',Unitsturning(pos_cy),'Visible','off');

    pos_cx = pos_cy;
    pos_cx(2) = pos_cx(2)+pos_cx(4);
    handles.cx = uicontrol('Parent',axeslayout,'Style','text','string','x:',...
        'FontSize',12,'FontUnits','points','HorizontalAlignment','Left',...
        'Units','normalized','Position',Unitsturning(pos_cx),'Visible','off');

    mainaxfullpos = Unitsturning(mainaxfullpos);
    handles.mainaxfullpos = mainaxfullpos;
    mainaxreducedpos = Unitsturning(mainaxreducedpos);
    colorbarpos = Unitsturning(colorbarpos);
    handles.colorbarpos = colorbarpos;  
%     pos_xs = Unitsturning(pos_xs);
%     pos_ys = Unitsturning(pos_ys);
%     pos_cz = Unitsturning(pos_cz);
%     pos_cy = Unitsturning(pos_cy);
%     pos_cx = Unitsturning(pos_cx);
%     set(handles.xsliceax,'Units','characters');
%     set(handles.ysliceax,'Units','characters');
%     set(handles.mainax,'Units','characters');
%     set(handles.cz,'Units','characters');
%     set(handles.cy,'Units','characters');
%     set(handles.cx,'Units','characters');
    
    %midlayout
    midlayout1=uix.Grid('parent',midlayout,'spacing',2,'UserData',obj);
    midlayout2=uix.Grid('parent',midlayout,'spacing',2,'UserData',obj);
    midlayout3=uix.Grid('parent',midlayout,'spacing',6,'UserData',obj);
    midlayout4=uix.Grid('parent',midlayout,'spacing',2,'UserData',obj);
    midlayout.Heights=[118 30 -1 30];

    %midlayout1
    handles.DataFolderTitle = uicontrol('Parent',midlayout1,'Style','text','string','Data folder:',...
        'FontSize',10,'FontUnits','points','HorizontalAlignment','Left','Units','characters');
    handles.SelectDataTitle = uicontrol('Parent',midlayout1,'Style','text','string','Select data:',...
        'FontSize',10,'FontUnits','points','HorizontalAlignment','Left','Units','characters');
    handles.SelectPlotFcnitle = uicontrol('Parent',midlayout1,'Style','text','string','Plot fcn:',...
        'FontSize',10,'FontUnits','points','HorizontalAlignment','Left','Units','characters');
    handles.SelectfitFcnitle = uicontrol('Parent',midlayout1,'Style','text','string','Fit type:',...
        'FontSize',10,'FontUnits','points','HorizontalAlignment','Left','Units','characters');
    %
    handles.DataFolder = uicontrol('Parent',midlayout1,'Style','edit','string',obj.datadir,...
        'FontSize',10,'FontUnits','points','FontAngle','oblique','ForegroundColor',[0.5,0.5,1],...
        'BackgroundColor',[0.9,1,0.8],'HorizontalAlignment','Left','Units','characters');
    handles.SelectData = uicontrol('Parent',midlayout1,'Style','popupmenu','string','All|Exclude hidden|Highlighted',...
        'value',1,'FontSize',9,'FontUnits','points','HorizontalAlignment','Left',...
        'ForegroundColor',[0.5,0.5,1],'BackgroundColor',[0.9,1,0.8],'Units','characters','Callback',{@SelectDataCallback},...
        'Tooltip','Select the type of data to view.');
    handles.PlotFunction = uicontrol('Parent',midlayout1,'Style','popupmenu','string',obj.availableplotfcns,...
        'FontSize',9,'FontUnits','points','HorizontalAlignment','Left',...
        'ForegroundColor',[0.5,0.5,1],'BackgroundColor',[0.9,1,0.8],'Units','characters',...
        'Callback',{@SelectPlotFcnCallback},'Tooltip','Select the data plot fucntion.');
    handles.FitFunction = uicontrol('Parent',midlayout1,'Style','popupmenu','string',obj.availablefitfcns,...
        'FontSize',9,'FontUnits','points','HorizontalAlignment','Left',...
        'ForegroundColor',[0.5,0.5,1],'BackgroundColor',[0.9,1,0.8],'Units','characters',...
        'Tooltip','Select the data fit fucntion.');
    %
    midlayout1_9=uix.Grid('parent',midlayout1,'UserData',obj);
        handles.SelectFolderBtn = uicontrol('Parent',midlayout1_9,'Style','pushbutton','string','S',...
            'FontSize',10,'FontUnits','points',...
            'Units','characters','Callback',{@SelectFolderCallback},...
            'Tooltip','Select the data folder to view.');
        handles.RefreshFolderBtn = uicontrol('Parent',midlayout1_9,'Style','pushbutton','string','R',...
            'FontSize',10,'FontUnits','points',...
            'Units','characters','Callback',{@RefreshFolderCallback},...
            'Tooltip','Refresh the files in current folder.');
        handles.OpenFolderBtn = uicontrol('Parent',midlayout1_9,'Style','pushbutton','string','O',...
            'FontSize',10,'FontUnits','points',...
            'Units','characters','Callback',{@OpenFolderCallback},...
            'Tooltip','Open folder in explorer.');
    handles.SaveBtn = uicontrol('Parent',midlayout1,'Style','pushbutton','string','Save',...
        'FontSize',10,'FontUnits','points','ForegroundColor',[1,0,0],'Units','characters',...
        'Callback',{@SaveCallback},'Tooltip','Save changes to disk.');
    handles.DeleteBtn = uicontrol('Parent',midlayout1,'Style','pushbutton','string','Delete',...
        'FontSize',10,'FontUnits','points','ForegroundColor',[1,0,0],'Units','characters',...
        'Callback',{@DeleteCallback},'Tooltip','Delect the current data file from disk.');
    uix.Empty( 'Parent',midlayout1);
    %
    midlayout1.Heights=[-1 -1 -1 -1];
    midlayout1.Widths=[75 -1 100];

    %midlayout2
    handles.HideUnhideBtn = uicontrol('Parent',midlayout2,'Style','pushbutton','string','Hide +/-',...
        'FontSize',10,'FontUnits','points','Units','characters',...
        'Callback',{@HideCallback},'Tooltip','Hide the current data file.');
    handles.HighlightPlusBtn = uicontrol('Parent',midlayout2,'Style','togglebutton','string','Highlight +/- ',...
        'FontSize',10,'FontUnits','points','Units','characters',...
        'Callback',{@HighlightCallback},'Tooltip','Hilight the current data file.');
    handles.DataFitBtn = uicontrol('Parent',midlayout2,'Style','pushbutton','string','Data Fit',...
        'FontSize',10,'FontUnits','points','Units','characters',...
        'Callback',{@DataFit},'Tooltip','Fit the data.');
    handles.SaveFigBtn = uicontrol('Parent',midlayout2,'Style','pushbutton','string','Save Fig',...
        'FontSize',10,'FontUnits','points','Units','characters',...
        'Callback',{},'Tooltip','place holder.');
    
    %midlayout3
    InfoStr = ['Data file: ',10, 'Sample: ',10,'Measurement system: ',10, 'Operator: ',10, 'Time: '];
    handles.InfoDisp = uicontrol('Parent',midlayout3,'Style','text','string',InfoStr,...
        'BackgroundColor',[0.8,1,0.9],'FontAngle','oblique','ForegroundColor',[0.5,0.5,1],'Min',0,'Max',10,...
        'FontSize',10,'FontUnits','points','HorizontalAlignment','Left','Units','characters');
    handles.NotesBox = uicontrol('Parent',midlayout3,'Style','edit','string','',...
        'FontSize',10,'FontUnits','points','ForegroundColor',[0.5,0.5,1],'Min',0,'Max',10,...
        'BackgroundColor',[0.9,1,0.8],'HorizontalAlignment','Left','Units','characters',...
        'Tooltip','Edit notes.');
    midlayout3.Heights=[85 -1];

    %midlayout4
    handles.XYTraceBtn = uicontrol('Parent',midlayout4,'Style','toggle','string','XY Traces',...
        'FontSize',10,'FontUnits','points','Units','characters','Callback',@XYTrace,...
        'Value',0,'Tooltip','Show X and Y trace, 2D data only');
    handles.ExtractLineBtn = uicontrol('Parent',midlayout4,'Style','pushbutton','string','Trace Data',...
        'FontSize',10,'FontUnits','points','Units','characters','Callback',{@ExtractLine},...
        'Tooltip','Extract and plot X, Y or free trace data from 2D data');
    handles.ExportDataBtn = uicontrol('Parent',midlayout4,'Style','pushbutton','string','x,y,z->]',...
        'FontSize',10,'FontUnits','points','Units','characters','Callback',{@ExportDataCallback},...
        'Tooltip','Export data to workspace as x, y and z.');
    handles.fileidxdisp = uicontrol('Parent',midlayout4,'Style','text','string','',...
        'FontSize',10,'FontUnits','points','HorizontalAlignment','Left','Units','characters');
    midlayout4.Widths=[73 73 73 -1];
    

    handles.InfoTable = uitable('Parent',rightlayout,...
         'Data',[],...
         'ColumnName',{'Key','Value'},...
         'ColumnFormat',{'char','char'},...
         'ColumnEditable',[false,false],...
         'ColumnWidth',{145,145},...
         'RowName',[],...
         'Units','characters');
     
    handles.dataviewwin.Position=[0 0 .65 .55];
    movegui(handles.dataviewwin,'center');

    xdata = [];
    ydata = [];
    zdata = [];
    xline = [];
    yline = [];
    xhair = [];
    yhair = [];
    zdatamin = 0;
    zdatamax = 1;
    SliceYTick = [0,1];
    function wbmcb(src,evnt)
       cp = get(handles.mainax,'CurrentPoint');
       XLim = get(handles.mainax,'XLim');
       YLim = get(handles.mainax,'YLim');
       x_e = cp(1,1);
       y_e = cp(1,2);
       xrange = range(xdata);
       yrange = range(ydata);
       if x_e < min(xdata)-0.01*xrange || x_e > max(xdata)+0.01*xrange ||...
               y_e < min(ydata)-0.01*yrange || y_e > max(ydata)+0.01*yrange
           set(xline,'XData',NaN,'YData',NaN);
           set(yline,'XData',NaN,'YData',NaN);
           set(xhair,'XData',NaN,'YData',NaN);
           set(yhair,'XData',NaN,'YData',NaN);
           set(handles.cx,'String','');
           set(handles.cy,'String','');
           set(handles.cz,'String','');
       else
           if abs(x_e) < 1e3
               set(handles.cx,'String',['X: ',num2str(x_e)]);
           else
               set(handles.cx,'String',['X: ',num2str(x_e,'%0.4e')]);
           end
           if abs(y_e) < 1e3
               set(handles.cy,'String',['Y: ',num2str(y_e)]);
           else
               set(handles.cy,'String',['Y: ',num2str(y_e,'%0.4e')]);
           end
            [~,y_idx] = (min(abs(ydata - y_e)));
            y = zdata(:,y_idx);
           set(xline,'XData',xdata,'YData',y);
           y_ = y(~isnan(y));
           if ~isempty(y_)
               ymax = max(y);
               ymin = min(y);
               if ymax > ymin
                   yr = ymax - ymin;
                   yaxr = [ymin-0.1*yr,ymax+0.1*yr];
                   set(handles.xsliceax,'YLim',yaxr,'YTick',linspace(yaxr(1),yaxr(end),4),'YGrid','on');
               end
           end
           set(yhair,'XData',[x_e,x_e],'YData',[zdatamin,zdatamax]);
           [~,x_idx] = (min(abs(xdata - x_e)));
           x = zdata(x_idx,:);
           set(yline,'XData',x,'YData',ydata);
           x_ = x(~isnan(x));
           if ~isempty(x_)
               xmax = max(x);
               xmin = min(x);
               if xmax > xmin
                   xr = xmax - xmin;
                   xaxr = [xmin-0.1*xr,xmax+0.1*xr];
                   set(handles.ysliceax,'XLim',xaxr,'XTick',linspace(xaxr(1),xaxr(end),4),'XGrid','on');
               end
           end
           set(xhair,'XData',[zdatamin,zdatamax],'YData',[y_e,y_e]);
           z_e = zdata(x_idx,y_idx);
           if abs(y_e) < 1e3
               set(handles.cz,'String',['Z: ',num2str(z_e)]);
           else
               set(handles.cz,'String',['Z: ',num2str(z_e,'%0.4e')]);
           end
       end
       set(handles.xsliceax,'XLim',XLim,'Ylim',[zdatamin,zdatamax],'YTick',SliceYTick);
       set(handles.ysliceax,'YLim',YLim,'Xlim',[zdatamin,zdatamax],'XTick',SliceYTick);
       drawnow;
    end
    function XYTrace(src,entdata)
        obj = get(get(src,'Parent'),'UserData');
        if ~get(src,'Value')
            set(handles.xsliceax,'Visible','off');
            set(handles.ysliceax,'Visible','off');
            set(handles.mainax,'Position',mainaxfullpos);
            obj.uihandles.ColorBar = colorbar('peer',handles.mainax);
            set(obj.uihandles.ColorBar,'Units','characters','Position',colorbarpos);
            set(handles.dataviewwin,'WindowButtonMotionFcn',[])
            hold(handles.xsliceax,'off');
            hold(handles.ysliceax,'off');
            set(handles.cx,'Visible','off');
            set(handles.cy,'Visible','off');
            set(handles.cz,'Visible','off');
            return;
        end
        h = figure('Visible','off');
        ax = axes('Parent',h);
        try
            idx = find(obj.previewfiles == obj.currentfile,1);
            data = obj.loadeddata{idx};
            if obj.plotfunc == 1
                if isfield(data,'Info')  && isfield(data.Info,'plotfcn') && ~isempty(data.Info.plotfcn) &&...
                        (ischar(data.Info.plotfcn) ||...
                        isa(data.Info.plotfcn,'function_handle'))
                    if ischar(data.Info.plotfcn)
                        PlotFcn = str2func(data.Info.plotfcn);
                    else
                        PlotFcn = data.Info.plotfcn;
                    end
                elseif isfield(data,'Config')  && isfield(data.Config,'plotfcn') &&...
                        ~isempty(data.Config.plotfcn) && (ischar(data.Config.plotfcn) ||...
                        isa(data.Config.plotfcn,'function_handle'))
                    if ischar(data.Config.plotfcn)
                        PlotFcn = str2func(data.Config.plotfcn);
                    else
                        PlotFcn = data.Config.plotfcn;
                    end
                else
                    PlotFcn = @qes.util.plotfcn.OneMeas_Def; % default
                end
            else
                PlotFcn = str2func(['qes.util.plotfcn.',obj.availableplotfcns{obj.plotfunc}]);
            end
            [x,y,z] = feval(PlotFcn,data.Data, data.SweepVals,'',data.SwpMainParam,'',ax,true);
            delete(h);
        catch
            msgbox('Unable to extract data, make sure the selected plot function supports the currents data set and has data exportation functionality.','modal');
            if ishghandle(h)
                delete(h);
            end
            set(src,'Value',0);
            return;
        end
        if isempty(z)
            msgbox('Extract line data is for 3D data only.','modal');
            set(src,'Value',0);
            return;
        end
        if isempty(x) || isempty(y)
            msgbox('x data or y data empty.','modal');
            set(src,'Value',0);
            return;
        elseif any(isnan(x)) || any(isnan(y))
            msgbox('x data or y data contains empty data(NaN)','modal');
            set(src,'Value',0);
            return;
        end
        xdata = x;
        ydata = y;
        if isreal(z)
            zdata = z;
        else
            if ~isempty(strfind(obj.availableplotfcns{obj.plotfunc},'Phase')) ||...
                    ~isempty(strfind(obj.availableplotfcns{obj.plotfunc},'phase'))
                sz = size(z);
                z_ = NaN*zeros(sz);
                for ww = 1:sz(1)
                    z(ww,:) = fixunknowns_ln(z(ww,:));
                    ang = unwrap(angle(z(ww,:)));
                    z_(ww,:) = ang - linspace(ang(1),ang(end),length(ang));
                end
                zdata = z_;
            else
                zdata = abs(z);
            end
        end
        zdatamin = min(min(zdata));
        zdatamax = max(max(zdata));
        zr = zdatamax - zdatamin;
        SliceYTick = linspace(zdatamin+0.1*zr,zdatamax-0.1*zr,3);
        set(handles.xsliceax,'Visible','on');
        set(handles.ysliceax,'Visible','on');
        set(handles.cx,'Visible','on');
        set(handles.cy,'Visible','on');
        set(handles.cz,'Visible','on');
        set(handles.mainax,'Position',mainaxreducedpos);
        colorbar('off','peer',handles.mainax);
        XLim = get(handles.mainax,'XLim');
        YLim = get(handles.mainax,'YLim');
        hold(handles.xsliceax,'on');
        xline = plot(handles.xsliceax,NaN,NaN,...
            'Color',[0,0.3,1],'Marker','o','MarkerSize',3,'MarkerFaceColor',[0,0.3,1]);
        yhair = plot(handles.xsliceax,NaN,NaN,'Color',[0.8,0.8,0.8]);
        hold(handles.xsliceax,'off');
        set(handles.xsliceax,'XTick',[]);
        hold(handles.ysliceax,'on');
        yline = plot(handles.ysliceax,NaN,NaN,...
            'Color',[1,0.3,0],'Marker','o','MarkerSize',3,'MarkerFaceColor',[1,0.3,0]);
        xhair = plot(handles.ysliceax,NaN,NaN,'Color',[0.8,0.8,0.8]);
        hold(handles.ysliceax,'off');
        set(handles.ysliceax,'YTick',[]);
        set(handles.dataviewwin,'WindowButtonMotionFcn',@wbmcb)
        set(handles.mainax,'XLim',XLim,'YLim',YLim);
    end

    obj.uihandles = handles;
    set(handles.basepanel,'UserData',obj);
    obj.RefreshGUI();

    function SelectFolderCallback(src,entdata)
        persistent lastselecteddir
        if isempty(lastselecteddir) || ~exist(lastselecteddir,'dir')
            lastselecteddir = pwd;
        end
        obj = get(get(src,'Parent'),'UserData');
        handles = obj.uihandles;
        datadir = uigetdir(lastselecteddir,'Select the data folder');
        if ~ischar(datadir)
            return;
        end
        lastselecteddir  = datadir;
        set(handles.DataFolder,'String',datadir);
        obj.datadir = datadir;
%         OpenFolder(datadir,src,entdata);
        obj.RefreshGUI();
    end
    function RefreshFolderCallback(src,entdata)
        selection=get(handles.SelectData,'value');
        dirstr = get(handles.DataFolder,'String');
        if ~exist(dirstr,'dir')
            msgbox('Directory not exist!');
            return;
        end
        obj.datadir = dirstr;
%         OpenFolder(obj.datadir,src,entdata);
        
        obj.RefreshGUI();
        set(handles.SelectData,'value',selection)
        SelectDataCallback(src,entdata)
    end
    function OpenFolderCallback(src,entdata)
        winopen( get(handles.DataFolder,'String'))
    end
    function pos_normalized = Unitsturning(pos_characters)
        %only works in axeslayout
        %pos_normalized=[pos_characters(1),pos_characters(2)-4.3,pos_characters(3),pos_characters(4)];
        pos_normalized=[pos_characters(1)/134.0,(pos_characters(2)-4.3)/40.7,pos_characters(3)/134.0,pos_characters(4)/40.7];
        
    end

    set(handles.dataviewwin,'Visible','on');
end


function PNPageBtnCallback(src,entdata,NorP)
persistent lastFwdClick
persistent lastBkwdClick
obj = get(get(src,'Parent'),'UserData');
if NorP > 0
    if ~isempty(lastFwdClick) && now - lastFwdClick < 6.941e-06 % 0.6 second
        obj.NextN(100);
    else
        obj.NextPage();
    end
    lastFwdClick = now; 
    lastBkwdClick = [];
elseif NorP < 0
    if ~isempty(lastBkwdClick) && now - lastBkwdClick < 6.941e-06 % 0.6 second
        obj.NextN(-100);
    else
        obj.PreviousPage();
    end
    lastFwdClick = []; 
    lastBkwdClick = now;
end
end

function SelectPlotFcnCallback(src,entdata)
obj = get(get(src,'Parent'),'UserData');
handles = obj.uihandles;
selection = get(handles.PlotFunction,'value');
obj.plotfunc = selection;
end
function SaveCallback(src,entdata)
obj = get(get(src,'Parent'),'UserData');
obj.Save();
end
function HideCallback(src,entdata)
obj = get(get(src,'Parent'),'UserData');
obj.HideFile();
end
function HighlightCallback(src,entdata)
option=get(src,'Value');
obj = get(get(src,'Parent'),'UserData');
obj.HilightFile(option);
end
function SelectDataCallback(src,entdata)
obj = get(get(src,'Parent'),'UserData');
handles = obj.uihandles;
selection = get(handles.SelectData,'value');
obj.SelectData(selection);
obj.RefreshGUI();
end
function ExtractLine(src,entdata)
obj = get(get(src,'Parent'),'UserData');
obj.ExtractLine();
end
function PreviewAXClickCallback(src,entdata)
persistent clickcount
temp = get(src,'UserData');
if isempty(clickcount)
    clickcount = zeros(2,2*temp(1)+1);
end
clickcount(:,1:2*temp(1)+1~=temp(2)) = 0;
if clickcount(1,temp(2)) > 0 && now - clickcount(2,temp(2)) > 6.941e-06 % 0.6 second
    clickcount(1,temp(2)) = 0;
end
clickcount(1,temp(2)) = clickcount(1,temp(2)) + 1;
clickcount(2,temp(2)) = now;
if clickcount(1,temp(2)) < 2
    return;
end
clickcount(temp(2)) = 0;
obj = get(get(src,'Parent'),'UserData');
nextn = temp(2)-(temp(1)+1);
if nextn ~= 0
    obj.NextN(nextn);
else % double click on the current data figure to edit
    obj = get(get(src,'Parent'),'UserData');
    handles = obj.uihandles;
    h = figure('Units','normalized');
    warning('off');
    jf = get(h,'JavaFrame');
    jf.setFigureIcon(javax.swing.ImageIcon(...
    im2java(qes.ui.icons.qos1_32by32())));
    warning('on');
    hax_new = copyobj(handles.mainax,h);
    set(hax_new,'Units','normalized','Position',[0.12,0.12,0.8,0.8]);
end
end
function DeleteCallback(src,entdata)
obj = get(get(src,'Parent'),'UserData');
obj.DeleteFile();
end
function ExportDataCallback(src,entdata)
obj = get(get(src,'Parent'),'UserData');
obj.ExportData();
end

function GUIDeleteCallback(src,entdata)
end