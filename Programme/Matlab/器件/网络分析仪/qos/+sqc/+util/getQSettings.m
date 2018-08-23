function v = getQSettings(key,qNames)
% get value to key for qubit specified by qNames
% if qName not given, get key value of all qubits:

% v = getQSettings('r_freq','q1'); % get r_freq of q1
% v = getQSettings('r_freq',{'q1','q3'}); % get r_freq of q1 and q3
% v = getQSettings('r_freq'); % get r_freq of all qubits

% in case of numeric key value, v is a numeric array with size(v,1) equals
% number of qubits, v(n,:) is the key value of the nth qubit.

% in case of non numeric key value, v is a cell, v{n} is the key value of the nth qubit.

% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    try
        QS = qes.qSettings.GetInstance();
    catch
        throw(MException('QOS_setQubitSettings:qSettingsNotCreated',...
			'qSettings not created: create the qSettings object, set user and select session first.'));
    end
    if ~iscell(key)
        key = {key};
    end
    
    if nargin < 2
        qubits = sqc.util.loadQubits();
        numQs = numel(qubits);
        qNames = cell(1,numQs);
        for ii = 1:numQs
            qNames{ii} = qubits{ii}.name;
        end
    elseif ~iscell(qNames) % a single qubit name
        qNames = {qNames};
    end
    numQs = numel(qNames);
    s = QS.loadSSettings([qNames(1),key]);
    if isnumeric(s)
        v = s(:).';
        for ii = 2:numQs
            s = QS.loadSSettings([qNames(ii),key]);
            v = [v;s(:).'];
        end
    else
        v = {s};
        for ii = 2:numQs
            s = QS.loadSSettings([qNames(ii),key]);
            v = [v;{s}];
        end
    end
    if numQs == 1 && iscell(v)
        v = v{1};
    end
end