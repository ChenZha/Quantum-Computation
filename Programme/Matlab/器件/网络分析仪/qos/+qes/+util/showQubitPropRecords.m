function showQubitPropRecords(prop,timeBounds,plotChange)
% qes.util.showQubitPropRecords('zdc_amp',[now-2, now],true)

% Copyright 2018 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com

    if nargin < 2 || isempty(timeBounds)
        timeBounds = [0,Inf];
    end
    if nargin < 3
        plotChange = false;
    end
    
    try
        QS = qes.qSettings.GetInstance();
    catch
        throw(MException('QOS_showQubitPropRecords:qSettingsNotCreated','qSettings not created.'));
    end
    qubits = sqc.util.loadQubits();
    numQs = numel(qubits);
    settings = cell(1,numQs);
    for ii = 1: numQs
        settings{ii} = {qubits{ii}.name,prop};
    end
    qes.util.plotSettingsHis(fullfile(QS.root,QS.user,QS.session),settings,timeBounds,[],plotChange);
end