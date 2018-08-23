function setQSettings(key,value,qNames)
% set value to key for qubit specified by qNames,
% if qNames not given, set key value of all qubits:

% setQSettings('r_fc',6.8e9,'q1'); % set r_fc of q1
% setQSettings('r_fc',6.8e9,{'q1','q3'}); % set r_fc of q1 and q3
% setQSettings('r_fc',6.8e9); % set r_fc of all qubits

% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    try
        QS = qes.qSettings.GetInstance();
    catch
        throw(MException('QOS_setQubitSettings:qSettingsNotCreated',...
			'qSettings not created: create the qSettings object, set user and select session first.'));
    end
    
    if nargin < 3
        qubits = sqc.util.loadQubits();
        numQs = numel(qubits);
        qNames = cell(1,numQs);
        for ii = 1:numQs
            qNames{ii} = qubits{ii}.name;
        end
    elseif ~iscell(qNames) % a single qubit name
        qNames = {qNames};
    end
    if ~iscell(key)
        key = {key};
    end
    for ii = 1:numel(qNames)
        QS.saveSSettings([qNames(ii),key],value);
    end
end