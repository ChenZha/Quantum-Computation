function saveSettings(spath, field, value)
% save settings
% examples:
% s = qes.util.saveSettings('F:\program\qes_settings',{'yulin','session1','q2','r_delay'},value)
% s = qes.util.saveSettings('F:\program\qes_settings',{'yulin.session1.q2.r_delay'},value)

% Copyright 2016 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com


    if isempty(field)
        error('saveSettings:noField','field must be specified in saving settings value.');
    end
%     if ~iscell(field)
%         if ~ischar(field)
%             error('saveSettings:invalidInput','fileds should be a cell array of char strings or a char string.');
%         else
%             if strcmp('name',field)
%                 error('saveSettings:invalidInput','the value of filed ''name'' is of critical importance thus not allowed to be changed by saveSettings.');
%             end
%             field = {field};
%         end
%     elseif strcmp('name',field{end})
%         error('saveSettings:invalidInput','the value of filed ''name'' is of critical importance thus not allowed to be changed by saveSettings.');
%     end
    
    settings_exists = false;
    isJson = false;
    while true
        s = regexp(field{end},'[^\)\}]\.'); % handles cases like 'yulin.session1.q2.fieldName(2)' or 'yulin.session1.q2.fieldName{3}'
        if numel(s) > 1
            fe = field{end};
            field{end} = fe(1:s(1));
            field{end+1} = fe(s(1)+2:end);
        else
            break;
        end
    end
 
    numFields = numel(field);
    fileinfo = dir(spath);
    numFiles = numel(fileinfo);
    if ~settings_exists && numFiles == 1 % todo, if field not exist, add it
        
        return;
    end
    for ii = 1:numFiles
        if strcmp(fileinfo(ii).name,'.') || strcmp(fileinfo(ii).name,'..')
            continue;
        end
        if fileinfo(ii).isdir && strcmp(fileinfo(ii).name,field{1})
            field(1) = [];
            qes.util.saveSettings(fullfile(spath,fileinfo(ii).name),field,value);
            return;
        end
        if fileinfo(ii).isdir || length(fileinfo(ii).name) < 5 || ~strcmp(fileinfo(ii).name(end-2:end),'key')
            continue;
        end

        fname = fileinfo(ii).name(1:end-4);
        if length(field{1}) >= length(fname) && strcmp(fname,field{1}(1:length(fname)))
            field_ = {};
            hisFileName = '';
            for uu = 1:numel(field)
                field_ = [field_, strsplit(field{uu},'.')];
                hisFileName = [hisFileName,'.',field{uu}];
            end
            hisFileName(1) = [];
            qes.util.saveJson(fullfile(spath,fileinfo(ii).name),field_,value);
            
            % regist old_value to history
            try
                old_value = qes.util.loadSettings(spath, field);
            catch ME
                if strcmp(ME.identifier,'loadSettings:invalidInput')
                    warning('saveSettings:addNewField','field %s not found, this field will be add into the setttings.', field{1});
                else
                    rethrow(ME);
                end
            end
            try
                if strcmp(class(old_value),class(value))
                    sz_o = size(old_value);
                    sz_n = size(value);
                    if length(sz_o) == length(sz_n) && all(sz_o == sz_n) && all(old_value == value) % case of cell is neglected
                        return;
                    end
                end
            catch
            end
        
            history_dir = fullfile(spath,'_history');
            if ~exist(history_dir,'dir')
                mkdir(history_dir);
            end
            history_file = fullfile(history_dir,[hisFileName,'.his']);
            try
                if ~exist(history_file,'file') ||...
                        numel(dir(history_file)) > 1 % a folder
                    fid = fopen(history_file,'w');
                else
                    fid = fopen(history_file,'a+');
                end
                if ischar(old_value)
                    fprintf(fid,'%s\t%s\r\n',datestr(now,'yyyy-mm-dd_HH:MM:SS:FFF'),old_value);
                elseif isnumeric(old_value)
                    if iscolumn(old_value)
                        old_value = old_value.';
                    end
                    if numel(old_value) > 1
                        fprintf(fid,'%s\t%s\r\n',datestr(now,'yyyy-mm-dd_HH:MM:SS:FFF'),num2str(old_value)); 
                    elseif isreal(old_value)
                        fprintf(fid,'%s\t%0.6e\r\n',datestr(now,'yyyy-mm-dd_HH:MM:SS:FFF'),old_value);
                    else
                        fprintf(fid,'%s\t%0.6e%+0.6ej\r\n',datestr(now,'yyyy-mm-dd_HH:MM:SS:FFF'),real(old_value),imag(old_value));
                    end
                end
                fclose(fid);
            catch
                warning('log old value to history file failed');
            end
        elseif numFields == 1
            ln_field = numel(field{1});
            if length(fileinfo(ii).name)-3 >= ln_field &&...
                    strcmp(fileinfo(ii).name(1:ln_field),field{1})
                switch fileinfo(ii).name(ln_field+1)
                    case '@'
                        if ~ischar(value)
                            error('saveSettings:invalidInput','value type of the current settings field is char string, %s given.', class(value));
                        end
                        newfilename = [field{1},'@',value,'.key'];
                        try
                            movefile(fullfile(spath,fileinfo(ii).name),fullfile(spath,newfilename));
                        catch ME
%                             warning(ME.message);
                        end
                        % register old_value to history
                        try
                            old_value = qes.util.loadSettings(spath, field);
                            settings_exists = true;
                        catch ME
                            if strcmp(ME.identifier,'loadSettings:invalidInput')
                                warning('saveSettings:addNewField','field %s not found, this field will be add into the setttings.', field{1});
                            else
                                rethrow(ME);
                            end
                        end
                        try
                            if strcmp(class(old_value),class(value))
                                sz_o = size(old_value);
                                sz_n = size(value);
                                if length(sz_o) == length(sz_n) && all(sz_o == sz_n) && all(old_value == value) % case of cell is neganected
                                    return;
                                end
                            end
                        catch
                        end
                        history_dir = fullfile(spath,'_history');
                        if ~exist(history_dir,'dir')
                            mkdir(history_dir);
                        end
                        history_file = fullfile(history_dir,[field{1},'.his']);
                        try
                            if ~exist(history_file,'file') ||...
                                    numel(dir(history_file)) > 1 % a folder
                                fid = fopen(history_file,'w');
                            else
                                fid = fopen(history_file,'a+');
                            end
                            fprintf(fid,'%s\t%s\r\n',datestr(now,'yyyy-mm-dd_HH:MM:SS:FFF'),old_value);
                            fclose(fid);
                        catch
                            warning('log old value to history file failed');
                        end
                        return;
                    case '=' % in case of numeric settings value, we allow the caller to convert the numeric value to a string, this is usefull since
                        % only the caller knows how much number of digits to
                        % use in converting to char string.
                        if ~isnumeric(value) && ~islogical(value)
                            if ~ischar(value)
                                error('saveSettings:invalidInput',...
                                	'value type of the current settings field is numeric, %s given.', class(value));
                            else
                                value = regexprep(value,'\s+','');
                                if ~ismember(value,{'true','True','false','False',''})
                                    value = regexprep(value,',\.',',0\.');
                                    value = regexprep(value,'\[\.','[0\.');
                                    if any(isnan(str2num(value))) &&... % do not use str2double
                                        isempty(regexp(regexprep(value,'[eE][-\+]\d+',''),...
                                            '[(\d+(\.\d+){0,1},)*(\d+(\.\d+){0,1}])', 'once'))
                                        error('saveSettings:invalidInput',...
                                             'value type of the current settings field is numeric, %s given.', value);
                                    end
                                    value = regexprep(value,'[\[\]]','');
                                end
                            end
                        end
                        if ~ischar(value) % if not converted to char string already by caller.
                            str = '';
                            for ww = 1:numel(value)
                                str = [str,',',qes.util.num2strCompact(value(ww))];
                            end
                            value = str(2:end);
                        end
                        newfilename = [field{1},'=',value,'.key'];
                        try
                            movefile(fullfile(spath,fileinfo(ii).name),fullfile(spath,newfilename));
                        catch ME
                            % pass, in case of setting to the current value
%                             warning(ME.message);
                        end
                        % log old_value to history
                        try
                            old_value = qes.util.loadSettings(spath, field);
                            settings_exists = true;
                        catch ME
                            if strcmp(ME.identifier,'loadSettings:invalidInput')
                                warning('saveSettings:addNewField','field %s not found, this field will be add into the setttings.', field{1});
                            else
                                rethrow(ME);
                            end
                        end
                        try
                            if strcmp(class(old_value),class(value))
                                sz_o = size(old_value);
                                sz_n = size(value);
                                if length(sz_o) == length(sz_n) && all(sz_o == sz_n) && all(old_value == value) % case of cell is neglected
                                    return;
                                end
                            end
                        catch
                        end
                        history_dir = fullfile(spath,'_history');
                        if ~exist(history_dir,'dir')
                            mkdir(history_dir);
                        end
                        history_file = fullfile(history_dir,[field{1},'.his']);
                        try
                            if ~exist(history_file,'file') ||...
                                    numel(dir(history_file)) > 1 % a folder
                                fid = fopen(history_file,'w');
                            else
                                fid = fopen(history_file,'a+');
                            end
                            if iscolumn(old_value)
                                old_value = old_value.';
                            end
                            if numel(old_value) > 1
                               fprintf(fid,'%s\t%s\r\n',datestr(now,'yyyy-mm-dd_HH:MM:SS:FFF'),num2str(old_value)); 
                            elseif isreal(old_value)
                                fprintf(fid,'%s\t%0.6e\r\n',datestr(now,'yyyy-mm-dd_HH:MM:SS:FFF'),old_value);
                            else
                                fprintf(fid,'%s\t%0.6e%+0.6ej\r\n',datestr(now,'yyyy-mm-dd_HH:MM:SS:FFF'),real(old_value),imag(old_value));
                            end
                            fclose(fid);
                        catch
                            warning('log old value to history file failed');
                        end
                        return;
                end
            end
        end
    end
end