%%
% data_taking.public.scripts.temp.GHZ
import sqc.op.physical.*
import sqc.measure.*
import sqc.util.qName2Obj
import sqc.util.setQSettings
QS = qes.qSettings.GetInstance();
%%
% qubits = {'q9','q8'};
% qubits = {'q8','q7'};
qubits = {'q4','q5'};
% qubits = {'q5','q6'};
gateMat = {'Y2p','Y2m';
            'CZ','CZ';
            'I','Y2p'};
for ii = 1:numel(qubits)
    qubits{ii} = qName2Obj(qubits{ii});
end
numReps = 1;
r_avg = 5000;
setQSettings('r_avg',r_avg);
for ii = 1:numReps
p = gateParser.parse(qubits,gateMat);
p.Run();
R = resonatorReadout(qubits);
R.delay = p.length;
if ii == 1
    data = R();
else
    data = data + R();
end
end
data = data/numReps;

hf = figure();bar(data);
% QS = qes.qSettings.GetInstance();
% dataSvName = fullfile(QS.loadSSettings('data_path'),...
%                 ['GHZ_',datestr(now,'yymmddTHHMMSS'),...
%                 num2str(ceil(99*rand(1,1)),'%0.0f'),'_.fig']);
% saveas(hf,dataSvName);

%%
qubits = {'q4','q5','q6'};
% qubits = {'q9','q8','q7'};
% gateMat = {'Y2p','Y2m','I';
%             'CZ','CZ','I';
%             'I','Y2p','I';
%             'I','I','Y2m';
%             'I','CZ','CZ';
%             'I','I','Y2p'};
        
gateMat = {'Y2p','Y2m','I';
            'CZ','CZ','I';
            'I','Y2p','Y2m';
            'I','CZ','CZ';
            'I','I','Y2p'};
        
for ii = 1:numel(qubits)
    qubits{ii} = qName2Obj(qubits{ii});
end

numReps = 2;        
r_avg = 3000;
setQSettings('r_avg',r_avg);
for ii = 1:numReps
    ii
    p = gateParser.parse(qubits,gateMat);
    p.logSequenceSamples = true;
    p.Run();
    R = resonatorReadout(qubits);
    R.delay = p.length;
    if ii == 1
        data = R();
    else
        data = data + R();
    end
end
data = data/numReps;

hf = figure();bar(data);
% QS = qes.qSettings.GetInstance();
% dataSvName = fullfile(QS.loadSSettings('data_path'),...
%                 ['GHZ_',datestr(now,'yymmddTHHMMSS'),...
%                 num2str(ceil(99*rand(1,1)),'%0.0f'),'_.fig']);
% saveas(hf,dataSvName);
waveformLogger = sqc.op.physical.sequenceSampleLogger.GetInstance();
waveformLogger.plot();
%%
qubits = {'q9','q8','q7','q6'};
gateMat = {'Y2p','Y2m','I','I';
            'CZ','CZ','I','I';
            'I','Y2p','I','I';
            'I','I','Y2m','I';
            'I','CZ','CZ','I';
            'I','I','Y2p','I';
            'I','I','I','Y2m';
            'I','I','CZ','CZ';
            'I','I','I','Y2p'};

numReps = 5;        
setQSettings('r_avg',r_avg);
for ii = 1:numReps
p = gateParser.parse(qubits,gateMat);
p.Run();
R = resonatorReadout(qubits);
R.delay = p.length;
if ii == 1
    data = R();
else
    data = data + R();
end
end
data = data/numReps;

hf = figure();bar(data);
QS = qes.qSettings.GetInstance();
dataSvName = fullfile(QS.loadSSettings('data_path'),...
                ['GHZ_',datestr(now,'yymmddTHHMMSS'),...
                num2str(ceil(99*rand(1,1)),'%0.0f'),'_.fig']);
saveas(hf,dataSvName);

%%
qubits = {'q9','q8','q7','q6','q5'};
gateMat = {'Y2p','Y2m','I','I','I';
            'CZ','CZ','I','I','I';
            'I','Y2p','I','I','I';
            'I','I','Y2m','I','I';
            'I','CZ','CZ','I','I';
            'I','I','Y2p','I','I';
            'I','I','I','Y2m','I';
            'I','I','CZ','CZ','I'
            'I','I','I','Y2p','I';
            'I','I','I','I','Y2m';
            'I','I','I','CZ','CZ';
            'I','I','I','I','Y2p'};

numReps = 10;
r_avg = 20000;
setQSettings('r_avg',r_avg);
for ii = 1:numReps
p = gateParser.parse(qubits,gateMat);
p.Run();
R = resonatorReadout(qubits);
R.delay = p.length;
if ii == 1
    data = R();
else
    data = data + R();
end
end
data = data/numReps;

hf = figure();bar(data);
QS = qes.qSettings.GetInstance();
dataSvName = fullfile(QS.loadSSettings('data_path'),...
                ['GHZ_',datestr(now,'yymmddTHHMMSS'),...
                num2str(ceil(99*rand(1,1)),'%0.0f'),'_.fig']);
saveas(hf,dataSvName);