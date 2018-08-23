function ExtractLine(obj)
%

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

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
        if ~isreal(z)
            z = abs(z);
        end
    catch
        qes.ui.msgbox('Unable to extract data, make sure the selected plot function supports the currents data set and has data exportation functionality.');
        if ishghandle(h)
            delete(h);
        end
        return;
    end
    if isempty(z)
        qes.ui.msgbox('Extract line data is for 3D data only.','modal');
        return;
    end
    if isempty(x) || isempty(y)
        qes.ui.msgbox('x data or y data empty.','modal');
        return;
    elseif any(isnan(x)) || any(isnan(y))
        qes.ui.msgbox('x data or y data contains empty data(NaN)','modal');
        return;
    end
    choice  = questdlg('Select mode:','','Horizontal','Vertical','Free line','Horizontal');
    if isempty(choice) || strcmp(choice, 'Horizontal') || strcmp(choice, 'Vertical')
        set(obj.uihandles.mainax,'HandleVisibility','on');
        axes(obj.uihandles.mainax);
        try
            cp = qes.app.DataViewer.Ginput(1);
        catch
            set(obj.uihandles.mainax,'HandleVisibility','callback');
            return;
        end
%         cp = get(obj.uihandles.mainax,'CurrentPoint');
        x_e = cp(1,1);
        y_e = cp(1,2);
        xrange = range(x);
        yrange = range(y);
        if (isempty(choice) || strcmp(choice, 'Horizontal')) && (x_e < min(x)-0.05*xrange || x_e > max(x)+0.05*xrange)
            qes.ui.msgbox('Out of data range, click within the data range to extract.','modal');
            return;
        elseif y_e < min(y)-0.05*yrange || y_e > max(y)+0.05*yrange
            qes.ui.msgbox('Out of data range, click within the data range to extract.','modal');
            return;
        end
        if isempty(choice) || strcmp(choice, 'Horizontal')
            [~,y_idx] = (min(abs(y - y_e)));
            choice  = questdlg('Where to plot horizontal line data?',...
                'Plot options','A new plot','Append to the current axes(if exists)','A new plot');
            if ~isempty(choice) && strcmp(choice, 'A new plot')
                h1 = qes.ui.qosFigure('Horizontal Trace',false);
                warning('off');
                jf = get(h1,'JavaFrame');
                jf.setFigureIcon(javax.swing.ImageIcon(...
                im2java(qes.ui.icons.qos1_32by32())));
                warning('on');
                ha1 = axes('Parent',h1);
            else
                qes.ui.msgbox('Raise the axis to add the plot to the front by cliking on it.');
                pause(5);
                ha1 = gca();
                hold(ha1,'on');
            end
            plot(ha1,x,z(:,y_idx));
            xlabel(ha1,'x');
            ylabel(ha1,'z');
            title(ha1,'horizontal line data, data also exported to base workspace as ''x_{ex}'',''z_{ex}''',...
                'FontSize',10,'FontWeight','normal');
            assignin('base','x_ex',x);
            assignin('base','x_ex',z(:,y_idx));
        else
            [~,x_idx] = (min(abs(x - x_e)));
            choice  = questdlg('Where to plot vertical line data?','Plot options',...
                'A new plot','Append to the current axes(if exists)','A new plot');
            if ~isempty(choice) && strcmp(choice, 'A new plot')
                h2 = qes.ui.qosFigure('Vertical Trace',false);
                warning('off');
                jf = get(h2,'JavaFrame');
                jf.setFigureIcon(javax.swing.ImageIcon(...
                im2java(qes.ui.icons.qos1_32by32())));
                warning('on');
                warning('off');
                jf = get(h2,'JavaFrame');
                jf.setFigureIcon(javax.swing.ImageIcon(...
                im2java(qes.ui.icons.qos1_32by32())));
                warning('on');
                ha2 = axes('Parent',h2);
            else
                qes.ui.msgbox('Raise the axis to add the plot to the front by cliking on it.');
                pause(3);
                ha2 = gca;
                hold(ha2,'on');
            end
            plot(ha2,y,z(x_idx,:));
            xlabel(ha2,'y');
            ylabel(ha2,'z');
            title(ha2,'vertical line data, data exported to base workspace as ''y_{ex}'',''z_{ex}''',...
                'FontSize',10,'FontWeight','normal');
            assignin('base','y_ex',y);
            assignin('base','z_ex',z(x_idx,:));
        end
    else % free line
        SelectFreeLineData(obj,x,y,z);
    end
end
function SelectFreeLineData(obj,data_x,data_y,data_z)
    %
    choice  = questdlg('Choose line color:','Line color','Black','White','Red','Black');
    if ~isempty(choice) && strcmp(choice, 'Black')
        Color = [0,0,0];
    elseif strcmp(choice, 'White')
        Color = [1,1,1];
    elseif  strcmp(choice, 'Red')
        Color = [1,0,0];
    end
    spts = [];
    set(obj.uihandles.dataviewwin,'WindowButtonDownFcn',@wbdcb);
    ah = axes('Parent',get(obj.uihandles.mainax,'Parent'),...
        'XLim',get(obj.uihandles.mainax,'XLim'),...
        'YLim',get(obj.uihandles.mainax,'YLim'),...
        'YTick',[],'YTick',[],'Box','on',...
        'Color','none',...
        'Unit',get(obj.uihandles.mainax,'Unit'),...
        'UserData',spts); % 'DrawMode','fast',
    set(ah,'Position',get(obj.uihandles.mainax,'Position'));
    set(obj.uihandles.mainax,'UserData',spts);
    linkaxes([obj.uihandles.mainax,ah],'xy');
%     hold(ah,'on');
    x_e = [];
    y_e = [];
   function wbdcb(src,evnt)
      if strcmp(get(src,'SelectionType'),'normal')       
         cp = get(ah,'CurrentPoint');
         x = cp(1,1);
         y = cp(1,2);
         hl = line('Parent',ah,'XData',x,'YData',y,...
             'Marker','.','Color',Color,'LineStyle','--');
         drawnow;
         set(src,'WindowButtonMotionFcn',@wbmcb);
         x_e = [x_e,x];
         y_e = [y_e,y];
         set(obj.uihandles.mainax,'UserData',[get(obj.uihandles.mainax,'UserData');cp]);
      elseif strcmp(get(src,'SelectionType'),'alt')
         set(src,'WindowButtonMotionFcn','');
         set(obj.uihandles.dataviewwin,'WindowButtonDownFcn','');
         delete(ah);
         if length(x_e) < 2
             errordlg('Select at least two data points!','Error!','modal');
             return;
         end
         xdatarange = range(data_x);
         ydatarange = range(data_y);
         x_e_r = (x_e - min(data_x))/xdatarange;
         y_e_r = (y_e - min(data_y))/ydatarange;
         D = sqrt(diff(x_e_r).^2+diff(y_e_r).^2);
         if sum(D)== 0 
             errordlg('Select at least two different data points!','Error!','modal');
             return;
         end
         DD  = sqrt(2);
         ND = max(numel(data_x),numel(data_x));
         x_e_u = [];
         y_e_u = [];
         for ww = 1:numel(x_e)-1
             R = max(ND*D(ww)/DD,1);
             temp = linspace(x_e(ww),x_e(ww+1),R+1);
             x_e_u = [x_e_u,temp(1:end-1)];
             temp = linspace(y_e(ww),y_e(ww+1),R+1);
             y_e_u = [y_e_u,temp(1:end-1)];
         end
         zi = interp2(data_x,data_y,data_z',x_e_u,y_e_u);
         h2 = qes.ui.qosFigure('Freeline Trace',false);
         set(h2,'Position',[123   246   950   420]);
         hax_new = copyobj(obj.uihandles.mainax,h2);
         set(hax_new,'Units','normalized','Position',[0.08,0.12,0.40,0.8]);
         hold(hax_new,'on');
         line('Parent',hax_new,'XData',x_e,'YData',y_e,...
             'Marker','.','Color',Color,'LineStyle','none');
         line('Parent',hax_new,'XData',x_e_u,'YData',y_e_u,...
             'Marker','none','Color',Color,'LineStyle',':');
         hold(hax_new,'off');
         colorbar('peer',hax_new);
         hax_line = axes('Parent',h2,'Units','normalized','Position',[0.58,0.12,0.4,0.8]);
         plot(hax_line,1:length(zi),zi);
         xlabel(hax_line,['idx of selected points, up sampled ',num2str(R,'%0.0f'),' times']);
         ylabel(hax_line,'z');
         title(hax_line,{'extrated free line data,', 'data exported to base workspace as: ''x_{ex}'',''y_{ex}'',''z_{ex}'''},...
             'FontSize',10,'FontWeight','normal');
         assignin('base','x_ex',x_e_u);
         assignin('base','y_ex',y_e_u);
         assignin('base','z_ex',zi);
      end
      function wbmcb(src,evnt)
         cp = get(ah,'CurrentPoint');  
         xdat = [x,cp(1,1)];
         ydat = [y,cp(1,2)];
         set(hl,'XData',xdat,'YData',ydat);
      end  
   end
end