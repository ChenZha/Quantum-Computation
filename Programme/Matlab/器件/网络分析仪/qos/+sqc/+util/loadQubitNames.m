function qNames = loadQubitNames()
% load all qubit names in selected session 
% examples:
% qNames = qes.util.loadQubitNames()

% Copyright 2016 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com
    
    qNames = [];
    try
        S = qes.qSettings.GetInstance();
    catch
        error('qSettings not created: create the qSettings object, set user and select session first(only need to do once).');
    end
    s = S.loadSSettings();
    if isempty(s)
        return;
    end
    fnames = fieldnames(s);
    num_fields = numel(fnames);
    qNames = {};
    for ii = 1:num_fields
        if ismember(fnames{ii},{'global','xTalk','data_path'}) ||...
                ~isstruct(s.(fnames{ii}))
            continue;
        end
        qs = s.(fnames{ii});
        if ~isfield(qs,'type') || ~strcmp(qs.type,'qubit') 
            continue;
        end
        if ~isfield(qs,'class')
            continue;
        end
        qNames(end+1) = fnames(ii);
    end
end