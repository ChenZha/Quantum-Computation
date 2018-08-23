function qNames  = allQNames()
    % get name of all qubits
    
    % Yulin Wu, 2017
    
    qubits = sqc.util.loadQubits();
	numQs = numel(qubits);
	qNames = cell(1,numQs);
	for ii = 1:numQs
		qNames{ii} = qubits{ii}.name;
	end
end