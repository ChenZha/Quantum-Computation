function ExportData(obj)
    idx = find(obj.previewfiles == obj.currentfile,1);
    if isempty(idx)
        return;
    end
    data = obj.loadeddata{idx};
    if isempty(data) || (isfield(data,'Info') && ischar(data.Info)) ||...
            (isfield(data,'Config') && ischar(data.Config))
        return;
    end
    h = figure('Visible','off');
    ax = axes('Parent',h);
    try
        if obj.plotfunc == 1
            if isfield(data,'Info') && isfield(data.Info,'plotfcn') &&...
                    ~isempty(data.Info.plotfcn) && ischar(data.Info.plotfcn) % old version data
                PlotFcn = str2func(data.Info.plotfcn);
            elseif isfield(data,'Config') && isfield(data.Config,'plotfcn') &&...
                    ~isempty(data.Config.plotfcn) && ischar(data.Config.plotfcn)
                PlotFcn = str2func(data.Config.plotfcn);
            else
                PlotFcn = @qes.util.plotfcn.OneMeas_Def; % default
            end
        else
            PlotFcn = str2func(['qes.util.plotfcn.',obj.availableplotfcns{obj.plotfunc}]);
        end
        [x,y,z] = feval(PlotFcn,data.Data, data.SweepVals,'',data.SwpMainParam,'',ax,true);
        if ~isempty(x)
            assignin('base','x',x);
        end
        if ~isempty(y)
            assignin('base','y',y);
        end
        if ~isempty(z)
            assignin('base','z',z);
        end
        msgbox('Data have been exported to base workspace as ''x'',''y''and''z''.','Export data','modal');
    catch
        assignin('base','Data',data.Data);
        % msgbox('Unable to extract data, make sure the selected plot function supports the currents data set and has data exportation functionality.','modal');
    end
    if isfield(data,'Info') % old version data
        Info = data.Info;
    else
        Config = data.Config;
    end
    if isfield(data,'Info')
        assignin('base','info',Info);
    else
        assignin('base','info',Config);
    end
    if isfield(data,'SwpData')
        SwpDataExist = false;
        for ii = 1:length(data.SwpData)
            if ~isempty(data.SwpData{ii})
                SwpDataExist = true;
                break;
            end
        end
        if SwpDataExist
            assignin('base','SwpData',data.SwpData);
        end
    end
    datafile = obj.datafiles_full{obj.files2show(obj.currentfile)};
    assignin('base','datafile',datafile);
    
    if ishghandle(h)
         delete(h);
    end
end