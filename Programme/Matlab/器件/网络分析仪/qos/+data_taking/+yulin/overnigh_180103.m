qubits = {'q1','q3','q7','q9'};
for ii = 1:numel(qubits)
    q = qubits{ii};
    
tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);
tuneup.correctf01byPhase('qubits',q,'delayTime',1e-6,'gui','true','save',true);
tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);

setQSettings('r_avg',3000);
ramsey('qubit',q,'mode','dp',... % available modes are: df01, dp and dz
      'time',[20:50:12e3],'detuning',[2]*1e6,...
      'dataTyp','P','phaseOffset',0,'notes','','gui',true,'save',true);
spin_echo('qubit',q,'mode','dp',... % available modes are: df01, dp and dz
      'time',[0:50:20e3],'detuning',[2]*1e6,...
      'notes','','gui',true,'save',true);
  
tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);
setQSettings('r_avg',2000);
% bias = sqc.util.detune2zpa(q,-200e6)
bais = -2000:300:3e4;
T1_1('qubit',q,'biasAmp',bais,'biasDelay',20,'time',[20:500:28e3],... % [20:200:2.8e4]
      'gui',true,'save',true);
end
%%
q = 'q2';
tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);
tuneup.correctf01byPhase('qubits',q,'delayTime',1e-6,'gui','true','save',true);
tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);

setQSettings('r_avg',5000);
ramsey('qubit',q,'mode','dp',... % available modes are: df01, dp and dz
      'time',[20:50:12e3],'detuning',[2]*1e6,...
      'dataTyp','P','phaseOffset',0,'notes','','gui',true,'save',true);
spin_echo('qubit',q,'mode','dp',... % available modes are: df01, dp and dz
      'time',[0:50:20e3],'detuning',[2]*1e6,...
      'notes','','gui',true,'save',true);
  
tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);
setQSettings('r_avg',2000);
% bias = sqc.util.detune2zpa(q,-200e6)
bais = -1.5e4:300:1.5e4;
T1_1('qubit',q,'biasAmp',bais,'biasDelay',20,'time',[20:500:28e3],... % [20:200:2.8e4]
      'gui',true,'save',true);
  %%
q = 'q4';
tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);
tuneup.correctf01byPhase('qubits',q,'delayTime',1e-6,'gui','true','save',true);
tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);

setQSettings('r_avg',5000);
ramsey('qubit',q,'mode','dp',... % available modes are: df01, dp and dz
      'time',[20:25:10e3],'detuning',[2]*1e6,...
      'dataTyp','P','phaseOffset',0,'notes','','gui',true,'save',true);
spin_echo('qubit',q,'mode','dp',... % available modes are: df01, dp and dz
      'time',[0:50:20e3],'detuning',[2]*1e6,...
      'notes','','gui',true,'save',true);
  
tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);
setQSettings('r_avg',2000);
% bias = sqc.util.detune2zpa(q,-200e6)
bais = -2e4:300:3e4;
T1_1('qubit',q,'biasAmp',bais,'biasDelay',20,'time',[20:500:28e3],... % [20:200:2.8e4]
      'gui',true,'save',true);
  
  %%
q = 'q5';
tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);
tuneup.correctf01byPhase('qubits',q,'delayTime',0.7e-6,'gui','true','save',true);
tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);

setQSettings('r_avg',5000);
ramsey('qubit',q,'mode','dp',... % available modes are: df01, dp and dz
      'time',[20:25:10e3],'detuning',[2]*1e6,...
      'dataTyp','P','phaseOffset',0,'notes','','gui',true,'save',true);
spin_echo('qubit',q,'mode','dp',... % available modes are: df01, dp and dz
      'time',[0:50:20e3],'detuning',[2]*1e6,...
      'notes','','gui',true,'save',true);
  
tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);
setQSettings('r_avg',2000);
% bias = sqc.util.detune2zpa(q,-200e6)
bais = -1.5e4:300:3e4;
T1_1('qubit',q,'biasAmp',bais,'biasDelay',20,'time',[20:500:28e3],... % [20:200:2.8e4]
      'gui',true,'save',true);