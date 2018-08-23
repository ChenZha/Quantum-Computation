function q = qName2Obj(qName)
% creat the quantum object specified by qName

% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com
    
    qubits = [];
    try
        S = qes.qSettings.GetInstance();
    catch
        throw(MException('QOS_qName2Qubit:qSettingsNotCreated','qSettings not created.'));
    end
	qs = S.loadSSettings(qName);
	q = feval(str2func(['sqc.qobj.',qs.class]));

	metadata = metaclass(q);
	num_prop = numel(metadata.PropertyList);
	prop_names = cell(1,num_prop);
	for jj = 1:num_prop
		prop_names{jj} = metadata.PropertyList(jj).Name;
	end
	qs = rmfield(qs,{'type','class'});
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
	q.name = qName;
end