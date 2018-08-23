
  
q = 'q12';
tuneup.correctf01byPhase('qubits',q,'delayTime',1e-6,'gui',true,'save',true,'doCorrection',true,'iter',true);
tuneup.iq2prob_01('qubits',q,'numSamples',1e4,'gui',true,'save',true);
setQSettings('r_avg',1500);
biasAmp = linspace(-3e4,2e4,120);
% = ceil(unique(round(logspace(log10(20),log10(55e3),50))));
T1_1('qubit',q,'biasAmp',biasAmp,'biasDelay',20,'time',20:1200:58e3,... % [20:200:2.8e4]
      'gui',true,'save',true);
  
  
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
biasAmp = linspace(-2e4,3e4,120);
% = ceil(unique(round(logspace(log10(20),log10(55e3),50))));
T1_1('qubit',q,'biasAmp',biasAmp,'biasDelay',20,'time',20:1200:58e3,... % [20:200:2.8e4]
      'gui',true,'save',true);
  
q = 'q7';
tuneup.correctf01byPhase('qubits',q,'delayTime',1e-6,'gui',true,'save',true,'doCorrection',true,'iter',true);
tuneup.iq2prob_01('qubits',q,'numSamples',1e4,'gui',true,'save',true);
setQSettings('r_avg',1500);
biasAmp = linspace(-3e4,1e4,120);
% = ceil(unique(round(logspace(log10(20),log10(55e3),50))));
T1_1('qubit',q,'biasAmp',biasAmp,'biasDelay',20,'time',20:1200:58e3,... % [20:200:2.8e4]
      'gui',true,'save',true);