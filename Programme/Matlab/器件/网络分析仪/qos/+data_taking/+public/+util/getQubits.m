function varargout  = getQubits(args,qNameFields)
    % get qubit by name, if name is qubit object already, the object itself is returned
    
    % Yulin Wu, 2017/1/4
    
    qubits = sqc.util.loadQubits();
    num_fields = numel(qNameFields);
    for ii = 1:num_fields
        if ~isfield(args,qNameFields{ii}) || ~qes.util.ismember(args.(qNameFields{ii}),qubits)
            ME = MException('getQubits:inValidInput',...
				sprintf('%s is not specified or not one of the selected qubits.',qNameFields{ii}));
            ME.throwAsCaller();
        end
		if isa(args.(qNameFields{ii}),'sqc.qobj.qobject')
			% if it is a qubit object already, return the qubit object, 
			% do not return the qubit object in qubits! important!
			varargout{ii} = args.(qNameFields{ii});
		else
			varargout{ii} = qubits{qes.util.find(args.(qNameFields{ii}),qubits)};
		end
    end
end