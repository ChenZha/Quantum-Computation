function DeleteFile(obj)
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
    option  = questdlg('Delete data file from disk?','Confirm Delete','Yes','No','No');
    if isempty(option) || strcmp(option, 'No')
        return;
    end
    if ~isempty(regexp(obj.datamarkstr{fileidx},'\[hi\d{0,1}\]','ONCE'))
        errordlg(['Can not delete a hilighted datafile.'],'Error!','modal');
        return;
    end
    try
        delete(obj.datafiles_full{fileidx});
    catch ME
        errordlg(['Unable to delete data file due to: ', getReport(ME,'basic')],'Error!','modal'); % errordlg can not parse hyperlinks.
        return;
    end
    % 1, deleted flag is turned to true;
    % 2, datafiles_full, datafiles are kept unchanged;
    % 3, file idx of delete file is removed from file lists 
    
    % deleted flag is turned to true
    obj.filedeleted(fileidx) = true;
    % remove file idx from file lists
    obj.allfiles(obj.allfiles == fileidx) = [];
    obj.unhidden(obj.unhidden == fileidx) = [];
    obj.hilighted(obj.hilighted == fileidx) = [];
    obj.RefreshGUI();
end

