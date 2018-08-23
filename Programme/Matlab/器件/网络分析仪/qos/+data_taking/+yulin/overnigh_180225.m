qubits = {'q12','q11','q8','q7','q6','q5'};
for ii = 2:numel(qubits)
q = qubits{ii};
tuneup.correctf01byPhase('qubits',q,'delayTime',1e-6,'gui',true,'save',true,'doCorrection',true,'iter',true);
tuneup.iq2prob_01('qubits',q,'numSamples',1e4,'gui',true,'save',true);
setQSettings('r_avg',700);
biasAmp = linspace(-3e4,3e4,100);
spectroscopy1_zpa_auto('qubit',q,'biasAmp',biasAmp,...
    'swpInitf01',[],'swpInitBias',0,...
    'swpBandWdth',30e6,'swpBandStep',0.2e6,...
    'dataTyp','P','r_avg',700,'gui',true);
end

qubits = {'q12','q11','q8','q7','q6','q5'};
for ii = 1:numel(qubits)
    q = qubits{ii};
tuneup.correctf01byPhase('qubits',q,'delayTime',1e-6,'gui',true,'save',true,'doCorrection',true,'iter',true);
tuneup.iq2prob_01('qubits',q,'numSamples',1e4,'gui',true,'save',true);

setQSettings('r_avg',1500);
biasAmp = linspace(-3e4,3e4,120);
% = ceil(unique(round(logspace(log10(20),log10(55e3),50))));
T1_1('qubit',q,'biasAmp',biasAmp,'biasDelay',20,'time',20:1200:58e3,... % [20:200:2.8e4]
      'gui',true,'save',true);
end