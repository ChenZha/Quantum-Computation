setQSettings('spc_driveAmp',1000);
setQSettings('spc_sbFreq',700e6);

q = 'q12';
setQSettings('r_avg',700);
biasAmp = linspace(-0.5e4,3e4,100);
tuneup.iq2prob_01('qubits',q,'numSamples',1e4,'gui',true,'save',true);
tuneup.correctf01byPhase('qubits',q,'delayTime',1e-6,'gui',true,'save',true,'doCorrection',true,'iter',true);
tuneup.iq2prob_01('qubits',q,'numSamples',1e4,'gui',true,'save',true);
spectroscopy1_zpa_auto('qubit',q,'biasAmp',biasAmp,...
'swpInitf01',[],'swpInitBias',0,...
'swpBandWdth',30e6,'swpBandStep',0.2e6,...
'dataTyp','P','r_avg',700,'gui',true);

% q = 'q10';
% setQSettings('r_avg',700);
% tuneup.iq2prob_01('qubits',q,'numSamples',1e4,'gui',true,'save',true);
% tuneup.correctf01byPhase('qubits',q,'delayTime',1e-6,'gui',true,'save',true,'doCorrection',true,'iter',true);
% tuneup.iq2prob_01('qubits',q,'numSamples',1e4,'gui',true,'save',true);
% biasAmp = linspace(-3e4,1e4,70);
% spectroscopy1_zpa_auto('qubit',q,'biasAmp',biasAmp,...
% 'swpInitf01',[],'swpInitBias',0,...
% 'swpBandWdth',30e6,'swpBandStep',0.2e6,...
% 'dataTyp','P','r_avg',700,'gui',true);

q = 'q9';
setQSettings('r_avg',700);
tuneup.iq2prob_01('qubits',q,'numSamples',1e4,'gui',true,'save',true);
tuneup.correctf01byPhase('qubits',q,'delayTime',1e-6,'gui',true,'save',true,'doCorrection',true,'iter',true);
tuneup.iq2prob_01('qubits',q,'numSamples',1e4,'gui',true,'save',true);
biasAmp = linspace(-1e4,3e4,100);
spectroscopy1_zpa_auto('qubit',q,'biasAmp',biasAmp,...
'swpInitf01',[],'swpInitBias',0,...
'swpBandWdth',60e6,'swpBandStep',0.2e6,...
'dataTyp','P','r_avg',700,'gui',true);

q = 'q1';
setQSettings('r_avg',700);
tuneup.iq2prob_01('qubits',q,'numSamples',1e4,'gui',true,'save',true);
tuneup.correctf01byPhase('qubits',q,'delayTime',1e-6,'gui',true,'save',true,'doCorrection',true,'iter',true);
tuneup.iq2prob_01('qubits',q,'numSamples',1e4,'gui',true,'save',true);
biasAmp = linspace(-3e4,3e4,120);
spectroscopy1_zpa_auto('qubit',q,'biasAmp',biasAmp,...
'swpInitf01',[],'swpInitBias',0,...
'swpBandWdth',40e6,'swpBandStep',0.2e6,...
'dataTyp','P','r_avg',700,'gui',true);

q = 'q7';
setQSettings('r_avg',700);
tuneup.iq2prob_01('qubits',q,'numSamples',1e4,'gui',true,'save',true);
tuneup.correctf01byPhase('qubits',q,'delayTime',1e-6,'gui',true,'save',true,'doCorrection',true,'iter',true);
tuneup.iq2prob_01('qubits',q,'numSamples',1e4,'gui',true,'save',true);
biasAmp = linspace(-5000,3e4,100);
spectroscopy1_zpa_auto('qubit',q,'biasAmp',biasAmp,...
'swpInitf01',[],'swpInitBias',0,...
'swpBandWdth',30e6,'swpBandStep',0.2e6,...
'dataTyp','P','r_avg',700,'gui',true);

q = 'q5';
setQSettings('r_avg',700);
tuneup.iq2prob_01('qubits',q,'numSamples',1e4,'gui',true,'save',true);
tuneup.correctf01byPhase('qubits',q,'delayTime',1e-6,'gui',true,'save',true,'doCorrection',true,'iter',true);
tuneup.iq2prob_01('qubits',q,'numSamples',1e4,'gui',true,'save',true);
biasAmp = linspace(-3e4,1e4,100);
spectroscopy1_zpa_auto('qubit',q,'biasAmp',biasAmp,...
'swpInitf01',[],'swpInitBias',0,...
'swpBandWdth',30e6,'swpBandStep',0.2e6,...
'dataTyp','P','r_avg',700,'gui',true);


 q = 'q10';
tuneup.correctf01byPhase('qubits',q,'delayTime',1e-6,'gui',true,'save',true,'doCorrection',true,'iter',true);
tuneup.iq2prob_01('qubits',q,'numSamples',1e4,'gui',true,'save',true);
setQSettings('r_avg',1500);
biasAmp = linspace(-3e4,2e4,120);
% = ceil(unique(round(logspace(log10(20),log10(55e3),50))));
T1_1('qubit',q,'biasAmp',biasAmp,'biasDelay',20,'time',20:1200:58e3,... % [20:200:2.8e4]
      'gui',true,'save',true);
  
q = 'q9';
tuneup.correctf01byPhase('qubits',q,'delayTime',1e-6,'gui',true,'save',true,'doCorrection',true,'iter',true);
tuneup.iq2prob_01('qubits',q,'numSamples',1e4,'gui',true,'save',true);
setQSettings('r_avg',1500);
biasAmp = linspace(-1e4,3e4,120);
% = ceil(unique(round(logspace(log10(20),log10(55e3),50))));
T1_1('qubit',q,'biasAmp',biasAmp,'biasDelay',20,'time',20:1200:58e3,... % [20:200:2.8e4]
      'gui',true,'save',true);
  
q = 'q4';
tuneup.correctf01byPhase('qubits',q,'delayTime',1e-6,'gui',true,'save',true,'doCorrection',true,'iter',true);
tuneup.iq2prob_01('qubits',q,'numSamples',1e4,'gui',true,'save',true);
setQSettings('r_avg',1500);
biasAmp = linspace(-3e4,1e4,120);
% = ceil(unique(round(logspace(log10(20),log10(55e3),50))));
T1_1('qubit',q,'biasAmp',biasAmp,'biasDelay',20,'time',20:1200:58e3,... % [20:200:2.8e4]
      'gui',true,'save',true);
  
q = 'q3';
tuneup.correctf01byPhase('qubits',q,'delayTime',1e-6,'gui',true,'save',true,'doCorrection',true,'iter',true);
tuneup.iq2prob_01('qubits',q,'numSamples',1e4,'gui',true,'save',true);
setQSettings('r_avg',1500);
biasAmp = linspace(-3e4,1e4,120);
% = ceil(unique(round(logspace(log10(20),log10(55e3),50))));
T1_1('qubit',q,'biasAmp',biasAmp,'biasDelay',20,'time',20:1200:58e3,... % [20:200:2.8e4]
      'gui',true,'save',true);
  
  
  
q = 'q2';
tuneup.correctf01byPhase('qubits',q,'delayTime',1e-6,'gui',true,'save',true,'doCorrection',true,'iter',true);
tuneup.iq2prob_01('qubits',q,'numSamples',1e4,'gui',true,'save',true);
setQSettings('r_avg',1500);
biasAmp = linspace(-3e4,1e4,120);
% = ceil(unique(round(logspace(log10(20),log10(55e3),50))));
T1_1('qubit',q,'biasAmp',biasAmp,'biasDelay',20,'time',20:1200:58e3,... % [20:200:2.8e4]
      'gui',true,'save',true);
  
q = 'q1';
tuneup.correctf01byPhase('qubits',q,'delayTime',1e-6,'gui',true,'save',true,'doCorrection',true,'iter',true);
tuneup.iq2prob_01('qubits',q,'numSamples',1e4,'gui',true,'save',true);
setQSettings('r_avg',1500);
biasAmp = linspace(-3e4,2e4,120);
% = ceil(unique(round(logspace(log10(20),log10(55e3),50))));
T1_1('qubit',q,'biasAmp',biasAmp,'biasDelay',20,'time',20:1200:58e3,... % [20:200:2.8e4]
      'gui',true,'save',true);
