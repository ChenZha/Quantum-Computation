function freqr=getCZfreqs()
% freqr=data_taking.public.xmon.tuneup.getCZfreqs

allQs = {'q1','q2','q3','q4','q5','q6','q7','q8','q9','q10','q11','q12'};
czQSets = {{'q1','q2'},...
    {'q3','q2'},...
    {'q3','q4'},...
    {'q5','q4'},...
    {'q5','q6'},...
    {'q7','q6'},...
    {'q7','q8'},...
    {'q9','q8'},...
    {'q9','q10'},...
    {'q11','q10'},...
    {'q11','q12'},...
    };

f01=sqc.util.getQSettings('f01',allQs);
freqr=num2cell(f01',1);

QS = qes.qSettings.GetInstance();

for ii=1:numel(czQSets)
    czQSet = czQSets{ii};
    aczSettingsKey = sprintf('%s_%s',czQSet{1},czQSet{2});
    scz = QS.loadSSettings({'shared','g_cz',aczSettingsKey});
    qubitsincz=scz.qubits;
    freqs=[scz.amp,scz.detuneFreq];
    qubitsincz=qubitsincz(1:numel(freqs));
    [~,loc]=ismember(qubitsincz,allQs);
    for jj=1:numel(loc)
        	freqr{loc(jj)}=[freqr{loc(jj)},f01(loc(jj))+freqs(jj)];
    end
end

for ii=1:numel(freqr)
    freqr{ii}=unique(freqr{ii});
end

end