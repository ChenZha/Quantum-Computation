function RefreshGUI(obj)
%

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com


    handles = obj.uihandles;
    if isempty(handles)
        return;
    end
    set(handles.xsliceax,'Visible','off');
    set(handles.ysliceax,'Visible','off');
    set(handles.cx,'Visible','off');
    set(handles.cy,'Visible','off');
    set(handles.cz,'Visible','off');
    if isfield(handles,'XYTraceBtn') % empty in startup
        set(handles.XYTraceBtn,'Value',0);
    end
    set(handles.mainax,'Position',handles.mainaxfullpos);
    set(handles.dataviewwin,'WindowButtonMotionFcn',[])
    hold(handles.xsliceax,'off');
    hold(handles.ysliceax,'off');
    
    if isempty(obj.previewfiles)
        InfoStr = ['Data file: ',10, 'Sample: ',10,'Measurement system: ',10, 'Operator: ',10, 'Time: '];
        set(handles.InfoDisp,'string',InfoStr);
        set(handles.NotesBox,'string','');
        hold(handles.mainax,'off');
        plot(handles.mainax,NaN,NaN);
        XLIM = get(handles.mainax,'XLim');
        YLIM = get(handles.mainax,'YLim');
        text('Parent',handles.mainax,'Position',[mean(XLIM),mean(YLIM)],'String','No data.',...
            'HorizontalAlignment','center','VerticalAlignment','middle',...
            'Color',[1,0,0],'FontSize',25,'FontWeight','bold');
        for ii = 1:length(handles.PreviewAX)
            praxbtndwnfcn = get(handles.PreviewAX(ii),'ButtonDownFcn');
            userdata = get(handles.PreviewAX(ii),'UserData');
            hold(handles.PreviewAX(ii),'off');
            set(handles.PreviewAX(ii),'Visible','off');
            plot(handles.PreviewAX(ii),NaN,NaN);
            set(handles.PreviewAX(ii),'XTick',[],'YTick',[]);
            XLIM = get(handles.PreviewAX(ii),'XLim');
            YLIM = get(handles.PreviewAX(ii),'YLim');
            text('Parent',handles.PreviewAX(ii),'Position',[mean(XLIM),mean(YLIM)],'String','Empty list',...
            'HorizontalAlignment','center','VerticalAlignment','middle',...
            'Color',[0.8,0.8,0.8],'FontSize',10,'FontWeight','bold');
            set(handles.PreviewAX(ii),'Visible','on','UserData',userdata,'ButtonDownFcn',praxbtndwnfcn);
        end
        return;
    end
    previewidx = find(obj.previewfiles == obj.currentfile,1);
    set(handles.fileidxdisp,'String',[num2str(obj.currentfile,'%0.0f'),...
        ' of ',num2str(length(obj.files2show),'%0.0f')]);
    if isempty(previewidx)
        error('Unexpected error.'); % if this happens, there are bugs
    end
    data = obj.loadeddata{previewidx};
    if isfield(data,'Config')
        table_data = qes.app.DataViewer.Config2TableData(data.Config);
        set(handles.InfoTable,'Data',table_data);
    end
    if ~obj.filedeleted(obj.files2show(obj.currentfile)) && ~isempty(data) &&...
            ((isfield(data,'Info') && ~ischar(data.Info)) ||...
            (isfield(data,'Config') && ~ischar(data.Config)))% disp info
        try
            datafile = obj.datafiles{obj.files2show(obj.currentfile)};
            Timestamp = obj.datatime(obj.files2show(obj.currentfile));
            if isfield(data,'Info') % old version data
                Info  = data.Info;
            else
                Config = isfield(data,'Config');
            end
            try
                if isfield(data,'Info') % old version data
                    InfoStr = ['Data file: ',datafile, 10,...
                        'Sample: ',Info.sample,10,...
                        'Measurement system: ',Info.measurementsystem,10,...
                        'User: ',Info.operator,10,...
                        'Time: ',datestr(Timestamp,'yyyy-mm-dd HH:MM:SS')];
                else
                    InfoStr = ['Data file: ',datafile, 10,...
                        'Sample: ',Config.sample,10,...
                        'Measurement system: ',Config.measurementsystem,10,...
                        'User: ',Config.user,10,...
                        'Time: ',datestr(Timestamp,'yyyy-mm-dd HH:MM:SS')];
                end
            catch % new version data format
                InfoStr = ['Data file: ',datafile, 10,...
                    'Time: ',datestr(Timestamp,'yyyy-mm-dd HH:MM:SS')];
            end
            set(handles.InfoDisp,'string',InfoStr);
            Notes = data.Notes;
            sz = size(Notes);
            if sz(1) > 1
                Notes_ = '';
                for ww = 1:sz(1)
                    tempstr = strtrim(Notes(ww,:));
                    tempstr((tempstr == 10) | (tempstr == 13)) = [];
                    if ~isempty(tempstr)
                        Notes_ = [Notes_,10,tempstr];
                    end
                end
                if Notes_(1) == 10
                    Notes_(1) = [];
                end
                Notes = Notes_;
            end
            set(handles.NotesBox,'string',Notes);
        catch ME
            datafile = obj.datafiles{obj.files2show(obj.currentfile)};
            InfoStr = ['Data file: ',datafile];
            set(handles.InfoDisp,'string',InfoStr);
            errordlg(['Error at displaying notes: ', 10,getReport(ME,'basic')],'Error!','modal');
        end
    else
        datafile = obj.datafiles{obj.files2show(obj.currentfile)};
        InfoStr = ['Data file: ',datafile];
        set(handles.InfoDisp,'string',InfoStr);
        set(handles.NotesBox,'string','');
    end
    if obj.plotfunc == 1
        if isfield(data,'Info') && ~ischar(data.Info) &&...
                isfield(data.Info,'plotfcn') && ~isempty(data.Info.plotfcn)
            if ischar(data.Info.plotfcn)
                PlotFcn = str2func(data.Info.plotfcn);
            elseif isa(data.Info.plotfcn,'function_handle')
                PlotFcn = data.Info.plotfcn;
            else
                PlotFcn = @qes.util.plotfcn.OneMeas_Def; % default
            end
        elseif isfield(data,'Config') && ~ischar(data.Config) &&...
                isfield(data.Config,'plotfcn') && ~isempty(data.Config.plotfcn)
            if ischar(data.Config.plotfcn)
                PlotFcn = str2func(data.Config.plotfcn);
            elseif isa(data.Config.plotfcn,'function_handle')
                PlotFcn = data.Config.plotfcn;
            else
                PlotFcn = @qes.util.plotfcn.OneMeas_Def; % default
            end
        else
            PlotFcn = @qes.util.plotfcn.OneMeas_Def; % default
        end
    else
        PlotFcn = str2func(['qes.util.plotfcn.',obj.availableplotfcns{obj.plotfunc}]);
    end
    centerax = ceil(length(handles.PreviewAX)/2);
    hold(handles.mainax,'off');
    try
        if ~obj.filedeleted(obj.files2show(obj.currentfile)) && ~isempty(data) &&...
                ((isfield(data,'Info') && ~ischar(data.Info)) ||...
                (isfield(data,'Config') && ~ischar(data.Config)))
            if isfield(data,'Info')
                if isfield(data.Info,'measurementnames') % to be compatible with a old bug.
                    measurementnames = data.Info.measurementnames; 
                elseif isfield(data.Info,'measurementname') % to be compatible with the old data verison.
                    measurementnames = data.Info.measurementname;
                else
                    measurementnames = '';
                end
            else
                if isfield(data.Config,'measurement_names') % to be compatible with a old bug.
                    measurementnames = data.Config.measurement_names; 
                else
                    measurementnames = {''};
                end
            end
            feval(PlotFcn,data.Data, data.SweepVals,data.ParamNames,...
                data.SwpMainParam,measurementnames,handles.mainax);
            colorbar('off','peer',handles.mainax);
            obj.uihandles.ColorBar = colorbar('peer',handles.mainax);
			if obj.resizable
				set(obj.uihandles.ColorBar,'Units','normalized','Position',handles.colorbarpos);
			else
				set(obj.uihandles.ColorBar,'Units','characters','Position',handles.colorbarpos);
			end
            set(handles.mainax,'Position',handles.mainaxfullpos);
        else
            plot(handles.mainax,NaN,NaN);
            XLIM = get(handles.mainax,'XLim');
            YLIM = get(handles.mainax,'YLim');
            if obj.filedeleted(obj.files2show(obj.currentfile))
                InfoStr = 'Data file deleted.';
            else
                InfoStr = 'No data or unsupported data format.';
            end
            text('Parent',handles.mainax,'Position',[mean(XLIM),mean(YLIM)],'String',InfoStr,...
                'HorizontalAlignment','center','VerticalAlignment','middle',...
                'Color',[1,0,0],'FontSize',25,'FontWeight','bold');
        end
    catch ME
        plot(handles.mainax,NaN,NaN);
        XLIM = get(handles.mainax,'XLim');
        YLIM = get(handles.mainax,'YLim');
        text('Parent',handles.mainax,'Position',[mean(XLIM),mean(YLIM)],'String','Unable to plot.',...
                'HorizontalAlignment','center','VerticalAlignment','middle',...
                'Color',[1,0,0],'FontSize',25,'FontWeight','bold');
        errordlg(['Plot data failed. The choosen  plot function can not handle the current data set. ',10,...
            getReport(ME,'basic')],'Error!','modal');
    end
    for ii = 0:centerax-1
        praxbtndwnfcn = get(handles.PreviewAX(centerax-ii),'ButtonDownFcn');
        userdata = get(handles.PreviewAX(centerax-ii),'UserData');
        set(handles.PreviewAX(centerax-ii),'Visible','off');
        if previewidx-ii > 0
            hold(handles.PreviewAX(centerax-ii),'off');
            if obj.filedeleted(obj.files2show(obj.previewfiles(previewidx-ii)))
                plot(handles.PreviewAX(centerax-ii),NaN,NaN);
                XLIM = get(handles.PreviewAX(centerax-ii),'XLim');
                YLIM = get(handles.PreviewAX(centerax-ii),'YLim');
                text('Parent',handles.PreviewAX(centerax-ii),'Position',...
                    [mean(XLIM),mean(YLIM)],'String','File deleted',...
                'HorizontalAlignment','center','VerticalAlignment','middle',...
                'Color',[1,0,0],'FontSize',10,'FontWeight','bold');
            else
                try
                    data = obj.loadeddata{previewidx-ii};
                    if (isfield(data,'Info') && ~ischar(data.Info)) ||...
                            isfield(data,'Config') && ~ischar(data.Config) % supported data format, data loaded successfully.
                        if isfield(data,'Info') &&  isfield(data.Info,'plotfcn') && ~isempty(data.Info.plotfcn)
                            if ischar(data.Info.plotfcn)
                                PlotFcn = str2func(data.Info.plotfcn);
                            elseif isa(data.Info.plotfcn,'function_handle')
                                PlotFcn = data.Info.plotfcn;
                            else
                                PlotFcn = @qes.util.plotfcn.OneMeas_Def; % default
                            end
                        elseif isfield(data,'Config') &&  isfield(data.Config,'plotfcn') && ~isempty(data.Config.plotfcn)
                            if ischar(data.Config.plotfcn)
                                PlotFcn = str2func(data.Config.plotfcn);
                            elseif isa(data.Config.plotfcn,'function_handle')
                                PlotFcn = data.Config.plotfcn;
                            else
                                PlotFcn = @qes.util.plotfcn.OneMeas_Def; % default
                            end
                        else
                            PlotFcn = @qes.util.plotfcn.OneMeas_Def; % default
                        end
                        if isfield(data,'Info')
                            if isfield(data.Info,'measurementnames') % to be compatible with a foremer bug.
                                measurementnames = data.Info.measurementnames; 
                            elseif isfield(data.Info,'measurementname') % to be compatible with the old data verison.
                                measurementnames = data.Info.measurementname;
                            else
                                measurementnames = '';
                            end
                        else
                            if isfield(data.Config,'measurement_names') % to be compatible with a foremer bug.
                                measurementnames = data.Config.measurement_names; 
                            else
                                measurementnames = '';
                            end
                        end
                        feval(PlotFcn,data.Data, data.SweepVals,data.ParamNames,data.SwpMainParam,...
                            measurementnames,handles.PreviewAX(centerax-ii),true);
                    else
                        plot(handles.PreviewAX(centerax-ii),NaN,NaN);
                        XLIM = get(handles.PreviewAX(centerax-ii),'XLim');
                        YLIM = get(handles.PreviewAX(centerax-ii),'YLim');
                        text('Parent',handles.PreviewAX(centerax-ii),'Position',...
                            [mean(XLIM),mean(YLIM)],'String','Plot fail.',...
                            'HorizontalAlignment','center','VerticalAlignment','middle',...
                            'Color',[1,0,0],'FontSize',10,'FontWeight','bold');
                    end
                catch ME  % in case of corrupted data
                    plot(handles.PreviewAX(centerax-ii),NaN,NaN);
                    XLIM = get(handles.PreviewAX(centerax-ii),'XLim');
                    YLIM = get(handles.PreviewAX(centerax-ii),'YLim');
                    text('Parent',handles.PreviewAX(centerax-ii),'Position',[mean(XLIM),mean(YLIM)],'String','Plot fail.',...
                        'HorizontalAlignment','center','VerticalAlignment','middle',...
                        'Color',[1,0,0],'FontSize',10,'FontWeight','bold');
    %                 errordlg(['Plot data failed. In most cases this due to the choosen plot function can not handle the current data set.'],'Error!','modal'); 
                end
            end
        else
            plot(handles.PreviewAX(centerax-ii),NaN,NaN);
            XLIM = get(handles.PreviewAX(centerax-ii),'XLim');
            YLIM = get(handles.PreviewAX(centerax-ii),'YLim');
            text('Parent',handles.PreviewAX(centerax-ii),'Position',[mean(XLIM),mean(YLIM)],'String','Head of list',...
                'HorizontalAlignment','center','VerticalAlignment','middle',...
                'Color',[0.8,0.8,0.8],'FontSize',10,'FontWeight','bold');
        end
        set(handles.PreviewAX(centerax-ii),'XTick',[],'YTick',[]);
        set(handles.PreviewAX(centerax-ii),'Visible','on','UserData',userdata,'ButtonDownFcn',praxbtndwnfcn);
    end
    hold(handles.PreviewAX(centerax),'on');
    XLIM = get(handles.PreviewAX(centerax),'XLim');
    YLIM = get(handles.PreviewAX(centerax),'YLim');
    dXLIM = XLIM(2)-XLIM(1);
    dYLIM = YLIM(2)-YLIM(1);
    XLIM(1) = XLIM(1)+0.95*dXLIM;
    XLIM(2) = XLIM(2)-0.95*dXLIM;
    YLIM(1) = YLIM(1)+0.95*dYLIM;
    YLIM(2) = YLIM(2)-0.95*dYLIM;
    line([XLIM(1),XLIM(2),XLIM(2),XLIM(1),XLIM(1)],[YLIM(1),YLIM(1),YLIM(2),YLIM(2),YLIM(1)],...
        'Color',[1,1,1],'LineWidth',4,'Parent',handles.PreviewAX(centerax));
    set(handles.PreviewAX(centerax),'XColor',[1,0,0],'YColor',[1,0,0],'LineWidth',6);
    hold(handles.PreviewAX(centerax),'off');
    NLoadedDataSets = length(obj.loadeddata);
    for ii = 1:centerax-1
        praxbtndwnfcn = get(handles.PreviewAX(centerax+ii),'ButtonDownFcn');
        userdata = get(handles.PreviewAX(centerax+ii),'UserData');
        set(handles.PreviewAX(centerax+ii),'Visible','off');
        hold(handles.PreviewAX(centerax+ii),'off');
        if previewidx+ii <= NLoadedDataSets
            if obj.filedeleted(obj.files2show(obj.previewfiles(previewidx+ii)))
                plot(handles.PreviewAX(centerax+ii),NaN,NaN);
                XLIM = get(handles.PreviewAX(centerax+ii),'XLim');
                YLIM = get(handles.PreviewAX(centerax+ii),'YLim');
                text('Parent',handles.PreviewAX(centerax+ii),'Position',[mean(XLIM),mean(YLIM)],'String','File deleted',...
                'HorizontalAlignment','center','VerticalAlignment','middle',...
                'Color',[1,0,0],'FontSize',10,'FontWeight','bold');
            else
                try
                    data = obj.loadeddata{previewidx+ii};
                    if (isfield(data,'Info') && ~ischar(data.Info)) ||...
                            isfield(data,'Config') && ~ischar(data.Config)  % supported data format, data loaded successfully.
                        if isfield(data,'Info') &&  isfield(data.Info,'plotfcn') && ~isempty(data.Info.plotfcn)
                            if ischar(data.Info.plotfcn)
                                PlotFcn = str2func(data.Info.plotfcn);
                            elseif isa(data.Info.plotfcn,'function_handle')
                                PlotFcn = data.Info.plotfcn;
                            else
                                PlotFcn = @qes.util.plotfcn.OneMeas_Def; % default
                            end
                        elseif isfield(data,'Config') &&  isfield(data.Config,'plotfcn') && ~isempty(data.Config.plotfcn)
                            if ischar(data.Config.plotfcn)
                                PlotFcn = str2func(data.Config.plotfcn);
                            elseif isa(data.Config.plotfcn,'function_handle')
                                PlotFcn = data.Config.plotfcn;
                            else
                                PlotFcn = @qes.util.plotfcn.OneMeas_Def; % default
                            end
                        else
                            PlotFcn = @qes.util.plotfcn.OneMeas_Def; % default
                        end
                        if isfield(data,'Info')
                            if isfield(data.Info,'measurementnames') % to be compatible with a foremer bug.
                                measurementnames = data.Info.measurementnames; 
                            elseif isfield(data.Info,'measurementname') % to be compatible with the old data verison.
                                measurementnames = data.Info.measurementname;
                            else
                                measurementnames = '';
                            end
                        else
                            if isfield(data.Config,'measurement_names') % to be compatible with a foremer bug.
                                measurementnames = data.Config.measurement_names; 
                            else
                                measurementnames = '';
                            end
                        end
                        feval(PlotFcn,data.Data, data.SweepVals,data.ParamNames,data.SwpMainParam,...
                            measurementnames,handles.PreviewAX(centerax+ii),true);
                    else
                        plot(handles.PreviewAX(centerax+ii),NaN,NaN);
                    XLIM = get(handles.PreviewAX(centerax+ii),'XLim');
                    YLIM = get(handles.PreviewAX(centerax+ii),'YLim');
                    text('Parent',handles.PreviewAX(centerax+ii),'Position',[mean(XLIM),mean(YLIM)],'String','Plot fail.',...
                        'HorizontalAlignment','center','VerticalAlignment','middle',...
                        'Color',[1,0,0],'FontSize',10,'FontWeight','bold');
                    end
                catch ME
                    plot(handles.PreviewAX(centerax+ii),NaN,NaN);
                    XLIM = get(handles.PreviewAX(centerax+ii),'XLim');
                    YLIM = get(handles.PreviewAX(centerax+ii),'YLim');
                    text('Parent',handles.PreviewAX(centerax+ii),'Position',[mean(XLIM),mean(YLIM)],'String','Plot fail.',...
                    'HorizontalAlignment','center','VerticalAlignment','middle',...
                    'Color',[1,0,0],'FontSize',10,'FontWeight','bold');
    %                 errordlg(['Plot data failed. In most cases this is due to the choosen plot function can not handle the current data set.'],'Error!','modal'); % errordlg can not parse hyperlinks.
                end
            end
        else
            plot(handles.PreviewAX(centerax+ii),NaN,NaN);
            XLIM = get(handles.PreviewAX(centerax+ii),'XLim');
            YLIM = get(handles.PreviewAX(centerax+ii),'YLim');
            text('Parent',handles.PreviewAX(centerax+ii),'Position',[mean(XLIM),mean(YLIM)],'String','End of list',...
                'HorizontalAlignment','center','VerticalAlignment','middle',...
                'Color',[0.8,0.8,0.8],'FontSize',10,'FontWeight','bold');
        end
        set(handles.PreviewAX(centerax+ii),'XTick',[],'YTick',[]);
        set(handles.PreviewAX(centerax+ii),'Visible','on','UserData',userdata,'ButtonDownFcn',praxbtndwnfcn);
    end
    for ii = 1:length(handles.PreviewAX)
        children = get(handles.PreviewAX(ii),'Children');
        for jj = 1:length(children)
            if ishghandle(children(jj))
                set(children(jj),'HitTest','off');
            end
        end
    end
end