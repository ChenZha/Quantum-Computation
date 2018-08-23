function HilightFile(obj,option)
    % option true/false, hilight/unhight

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
    if option && ~isempty(regexp(obj.datamarkstr{fileidx},'\[hi\d{0,1}\]','ONCE'))
        return;
    elseif ~option && isempty(regexp(obj.datamarkstr{fileidx},'\[hi\d{0,1}\]','ONCE'))
        return;
    end
    if option
        choice  = questdlg('Hilight this data file?','Confirm hilight','Yes','No','No');
    else
        choice  = questdlg('Unhilight this data file?','Confirm hilight','Yes','No','No');
    end
    if isempty(choice) || strcmp(choice, 'No')
        return;
    end
    if option && ~isempty(strfind(obj.datamarkstr{fileidx},'[ex]'))
        errordlg('Hidden data files can not be hilighted','Error!','modal'); 
        return;
    end

    if isempty(obj.datamarkstr{fileidx})
        obj.datamarkstr{fileidx} = '_';
    end
    if option
        obj.datamarkstr{fileidx} = [obj.datamarkstr{fileidx},'[hi]'];
    else
        obj.datamarkstr{fileidx} = regexprep(obj.datamarkstr{fileidx},'\[hi\d{0,1}\]','');
    end
    newfilename = [obj.fullnamesubmarkstr{fileidx}, obj.datamarkstr{fileidx},'.mat'];
    try
        movefile(obj.datafiles_full{fileidx},newfilename);
        obj.datafiles_full{fileidx} = newfilename;
        idx = strfind(newfilename,'\');
        obj.datafiles{fileidx} = newfilename(idx(end)+1:end);
        if option
            obj.hilighted = sort(unique([obj.hilighted,fileidx]));
        else
            obj.hilighted(obj.hilighted == fileidx) = [];
        end
    catch ME
        if option
            errordlg(['Unable to hilight data file due to: ', getReport(ME,'basic')],'Error!','modal');
        else
            errordlg(['Unable to unhilight data file due to: ', getReport(ME,'basic')],'Error!','modal');
        end
    end
end