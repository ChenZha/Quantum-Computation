q = 'q8';
    setQSettings('r_avg',2000); 
    tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);
    % tuneup.correctf01byRamsey('qubit',q,'robust',true,'gui',true,'save',true);
    setQSettings('r_avg',5000); 
    tuneup.correctf01byPhase('qubit',q,'delayTime',1e-6,'gui',true,'save',true);
    setQSettings('r_avg',2000);
    XYGate ={'X/2'};
    for jj = 1:numel(XYGate)
        tuneup.xyGateAmpTuner('qubit',q,'gateTyp',XYGate{jj},'AE',true,'AENumPi',41,'gui',true,'save',true);
    end
    tuneup.iq2prob_01('qubit',q,'numSamples',5e4,'gui',true,'save',true);
    
setQSettings('r_avg',5000);
data=ramsey('qubit',q,'mode','dp',... % available modes are: df01, dp and dz
      'time',[0:50:20000],'detuning',[2]*1e6,...
      'dataTyp','P','phaseOffset',0,'notes','','gui',true,'save',true);
  
spin_echo('qubit','q8','mode','dp',... % available modes are: df01, dp and dz
      'time',[0:50:20000],'detuning',[2]*1e6,...
      'notes','','gui',true,'save',true);

setQSettings('r_avg',5000);
T1_1('qubit',q,'biasAmp',[0],'biasDelay',20,'time',[20:250:3.2e4],... % [20:200:2.8e4]
      'gui',true,'save',true);

    setQSettings('r_avg',2000); 
    tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);
    % tuneup.correctf01byRamsey('qubit',q,'robust',true,'gui',true,'save',true);
    setQSettings('r_avg',5000); 
    tuneup.correctf01byPhase('qubit',q,'delayTime',1e-6,'gui',true,'save',true);
    setQSettings('r_avg',2000);
    XYGate ={'X/2'};
    for jj = 1:numel(XYGate)
        tuneup.xyGateAmpTuner('qubit',q,'gateTyp',XYGate{jj},'AE',true,'AENumPi',41,'gui',true,'save',true);
    end
    tuneup.iq2prob_01('qubit',q,'numSamples',5e4,'gui',true,'save',true);
    
setQSettings('r_avg',1500);
numGates = int16(unique(round(logspace(1,log10(300),25))));
[Pref,Pi] = randBenchMarking('qubit1',q,'qubit2',[],...
       'process','X/2','numGates',numGates,'numReps',60,...
       'gui',true,'save',true);
   

    setQSettings('r_avg',2000); 
    tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);
    % tuneup.correctf01byRamsey('qubit',q,'robust',true,'gui',true,'save',true);
    setQSettings('r_avg',5000); 
    tuneup.correctf01byPhase('qubit',q,'delayTime',1e-6,'gui',true,'save',true);
    setQSettings('r_avg',2000);
    XYGate ={'X/2'};
    for jj = 1:numel(XYGate)
        tuneup.xyGateAmpTuner('qubit',q,'gateTyp',XYGate{jj},'AE',true,'AENumPi',41,'gui',true,'save',true);
    end
    tuneup.iq2prob_01('qubit',q,'numSamples',5e4,'gui',true,'save',true);
    
setQSettings('r_avg',1500);
numGates = int16(unique(round(logspace(1,log10(300),25))));
[Pref,Pi] = randBenchMarking('qubit1',q,'qubit2',[],...
       'process','-X/2','numGates',numGates,'numReps',60,...
       'gui',true,'save',true);
   

    setQSettings('r_avg',2000); 
    tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);
    % tuneup.correctf01byRamsey('qubit',q,'robust',true,'gui',true,'save',true);
    setQSettings('r_avg',5000); 
    tuneup.correctf01byPhase('qubit',q,'delayTime',1e-6,'gui',true,'save',true);
    setQSettings('r_avg',2000);
    XYGate ={'X/2'};
    for jj = 1:numel(XYGate)
        tuneup.xyGateAmpTuner('qubit',q,'gateTyp',XYGate{jj},'AE',true,'AENumPi',41,'gui',true,'save',true);
    end
    tuneup.iq2prob_01('qubit',q,'numSamples',5e4,'gui',true,'save',true);
    
setQSettings('r_avg',1500);
numGates = int16(unique(round(logspace(1,log10(300),25))));
[Pref,Pi] = randBenchMarking('qubit1',q,'qubit2',[],...
       'process','Y/2','numGates',numGates,'numReps',60,...
       'gui',true,'save',true);
   

    setQSettings('r_avg',2000); 
    tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);
    % tuneup.correctf01byRamsey('qubit',q,'robust',true,'gui',true,'save',true);
    setQSettings('r_avg',5000); 
    tuneup.correctf01byPhase('qubit',q,'delayTime',1e-6,'gui',true,'save',true);
    setQSettings('r_avg',2000);
    XYGate ={'X/2'};
    for jj = 1:numel(XYGate)
        tuneup.xyGateAmpTuner('qubit',q,'gateTyp',XYGate{jj},'AE',true,'AENumPi',41,'gui',true,'save',true);
    end
    tuneup.iq2prob_01('qubit',q,'numSamples',5e4,'gui',true,'save',true);
    
setQSettings('r_avg',1500);
numGates = int16(unique(round(logspace(1,log10(300),25))));
[Pref,Pi] = randBenchMarking('qubit1',q,'qubit2',[],...
       'process','-Y/2','numGates',numGates,'numReps',60,...
       'gui',true,'save',true);
   

    setQSettings('r_avg',2000); 
    tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);
    % tuneup.correctf01byRamsey('qubit',q,'robust',true,'gui',true,'save',true);
    setQSettings('r_avg',5000); 
    tuneup.correctf01byPhase('qubit',q,'delayTime',1e-6,'gui',true,'save',true);
    setQSettings('r_avg',2000);
    XYGate ={'X/2'};
    for jj = 1:numel(XYGate)
        tuneup.xyGateAmpTuner('qubit',q,'gateTyp',XYGate{jj},'AE',true,'AENumPi',41,'gui',true,'save',true);
    end
    tuneup.iq2prob_01('qubit',q,'numSamples',5e4,'gui',true,'save',true);
    
setQSettings('r_avg',1500);
numGates = int16(unique(round(logspace(1,log10(300),25))));
[Pref,Pi] = randBenchMarking('qubit1',q,'qubit2',[],...
       'process','X','numGates',numGates,'numReps',60,...
       'gui',true,'save',true);
   

    setQSettings('r_avg',2000); 
    tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);
    % tuneup.correctf01byRamsey('qubit',q,'robust',true,'gui',true,'save',true);
    setQSettings('r_avg',5000); 
    tuneup.correctf01byPhase('qubit',q,'delayTime',1e-6,'gui',true,'save',true);
    setQSettings('r_avg',2000);
    XYGate ={'X/2'};
    for jj = 1:numel(XYGate)
        tuneup.xyGateAmpTuner('qubit',q,'gateTyp',XYGate{jj},'AE',true,'AENumPi',41,'gui',true,'save',true);
    end
    tuneup.iq2prob_01('qubit',q,'numSamples',5e4,'gui',true,'save',true);
    
setQSettings('r_avg',1500);
numGates = int16(unique(round(logspace(1,log10(300),25))));
[Pref,Pi] = randBenchMarking('qubit1',q,'qubit2',[],...
       'process','Y','numGates',numGates,'numReps',60,...
       'gui',true,'save',true);