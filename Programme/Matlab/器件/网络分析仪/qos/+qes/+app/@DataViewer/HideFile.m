function HideFile(obj)
    % 

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    if obj.readonly
        errordlg(['DataViewer running on read only mode.'],'Error!','modal');
        return;
    end
    if isempty(obj.currentfile)
        return;
    end
    fileidx = obj.files2show(obj.currentfile);
    if isempty(strfind(obj.datamarkstr{fileidx},'[ex]'))
        option = true;
    else
        option = false;
    end
    if option
        choice  = questdlg('Hide this data file?','Confirm hide','Yes','No','No');
    else
        choice  = questdlg('Unhide this data file?','Confirm unhide','Yes','No','No');
    end
    if isempty(choice) || strcmp(choice, 'No')
        return;
    end
    if option && ~isempty(regexp(obj.datamarkstr{fileidx},'\[hi\d{0,1}\]','ONCE'))
        errordlg(['Can not hide a hilighted datafile.'],'Error!','modal');
        return;
    end
    if isempty(obj.datamarkstr{fileidx})
        obj.datamarkstr{fileidx} = '_';
    end
    if option
        obj.datamarkstr{fileidx} = [obj.datamarkstr{fileidx},'[ex]'];
    else
        obj.datamarkstr{fileidx} = strrep(obj.datamarkstr{fileidx},'[ex]','');
    end
    newfilename = [obj.fullnamesubmarkstr{fileidx}, obj.datamarkstr{fileidx},'.mat'];
    try
        movefile(obj.datafiles_full{fileidx},newfilename);
        obj.datafiles_full{fileidx} = newfilename;
        idx = strfind(newfilename,'\');
        obj.datafiles{fileidx} = newfilename(idx(end)+1:end);
        if option
            obj.unhidden(obj.unhidden == fileidx) = [];
            obj.hilighted(obj.hilighted == fileidx) = [];
        else
            obj.unhidden = sort(unique([obj.unhidden,fileidx]));
        end
    catch ME
        if option
            errordlg(['Unable to hide data file due to: ', getReport(ME,'basic')],'Error!','modal');
            return;
        else
            errordlg(['Unable to unhide data file due to: ', getReport(ME,'basic')],'Error!','modal');
            return;
        end
    end
end