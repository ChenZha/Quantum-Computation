function qubits = loadQubits()
% load all qubits in selected session 
% examples:
% qubits = qes.util.loadQubits()

% Copyright 2016 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com
    
    qubits = [];
    try
        S = qes.qSettings.GetInstance();
    catch
        throw(MException('QOS_loadQubits:qSettingsNotCreated',...
			'qSettings not created: create the qSettings object, set user and select session first.'));
    end
    s = S.loadSSettings();
    if isempty(s)
        return;
    end
    fnames = fieldnames(s);
    num_fields = numel(fnames);
    qubits = {};
    for ii = 1:num_fields
        if ismember(fnames{ii},{'shared','public','data_path'}) ||...
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
        q = feval(str2func(['sqc.qobj.',qs.class]));
        metadata = metaclass(q);
        num_prop = numel(metadata.PropertyList);
        prop_names = cell(1,num_prop);
        for jj = 1:num_prop
            prop_names{jj} = metadata.PropertyList(jj).Name;
        end
        qs = rmfield(qs,'type');
        qs = rmfield(qs,'class');
        fn = fieldnames(qs);
        for jj = 1:numel(fn)
            idx = find(strcmp(fn{jj},prop_names));
            if ~isempty(idx)
                if ~strcmpi(metadata.PropertyList(idx).SetAccess, 'Public')
                    continue;
                end
            else
                addprop(q,fn{jj});
            end
            q.(fn{jj}) = qs.(fn{jj});
        end
        q.name = fnames{ii};
        qubits{end+1} = q;
    end
end