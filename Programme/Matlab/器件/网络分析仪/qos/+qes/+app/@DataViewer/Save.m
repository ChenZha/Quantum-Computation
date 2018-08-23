function Save(obj)
%

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    if obj.readonly
        errordlg(['DataViewer running on read only mode.'],'Error!','modal');
        return;
    end
    handles = obj.uihandles;
    if isempty(handles)
        return;
    end
    if isempty(obj.currentfile)
        return;
    end
    if obj.filedeleted(obj.files2show(obj.currentfile))
        errordlg(['This data file has been deleted.'],'Error!','modal');
        return;
    end
    choice  = questdlg('Save changes?','Confirm save','Yes','No','No');
    if isempty(choice) || strcmp(choice, 'No')
        return;
    end
    idx = find(obj.previewfiles == obj.currentfile,1);
    data = obj.loadeddata{idx};
    Data = data.Data;
    SweepVals = data.SweepVals;
    ParamNames = data.ParamNames;
    SwpMainParam = data.SwpMainParam;
    Notes = get(handles.NotesBox,'String');
    if isfield(data,'Info') % old version data
        Info = data.Info;
        if ischar(Info) % old version data
            Info = 'empty';
        end
        if ~ischar(Info) && obj.plotfunc > 1
            Info.plotfcn = str2func(['qes.util.plotfcn.',obj.availableplotfcns{obj.plotfunc}]);
        end
    else
        Config = data.Config;
        if ischar(Config)
            Config = 'empty';
        end
        if ~ischar(Config) && obj.plotfunc > 1
            Config.plotfcn = str2func(['qes.util.plotfcn.',obj.availableplotfcns{obj.plotfunc}]);
        end
    end

    if isfield(obj.loadeddata{idx},'Info') % old version data
        obj.loadeddata{idx}.Info = Info;
    else
        obj.loadeddata{idx}.Config = Config;
    end
    obj.loadeddata{idx}.Notes = Notes;
    datafile = obj.datafiles_full{obj.files2show(obj.currentfile)};
    try
        if exist('Info','var') % old version data
            save(datafile,'SweepVals','ParamNames','SwpMainParam','Data','Notes','Info','-v7.3');
        else
            save(datafile,'SweepVals','ParamNames','SwpMainParam','Data','Notes','Config','-v7.3');
        end
    catch ME
        errordlg(['Save failed due to: ', getReport(ME,'basic')],'Error!','modal');
        return;
    end
end