qubits = {'q9','q8'};
for ii = 1:numel(qubits)
    q = qubits{ii};
    setQSettings('r_avg',2000,q);
    tuneup.correctf01byRamsey('qubit',q,'robust',true,'gui',true,'save',true);
    tuneup.xyGateAmpTuner('qubit',q,'gateTyp','X','AE',false,'gui',true,'save',true);
    tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);
    XYGate ={'X','X/2'};
    for jj = 1:numel(XYGate)
        tuneup.xyGateAmpTuner('qubit',q,'gateTyp',XYGate{jj},'AE',true,'AENumPi',21,'gui',true,'save',true);
    end
end

setQSettings('r_avg',1000,'q8');
setQSettings('r_avg',1000,'q9');
acz_ampLength('controlQ','q9','targetQ','q8',...
       'dataTyp','Phase',...
       'czLength',[70:2:140],'czAmp',[2.65e4:50:2.85e4],'cState','1',...
       'notes','','gui',true,'save',true);
   
qubits = {'q9','q8'};
for ii = 1:numel(qubits)
    q = qubits{ii};
    setQSettings('r_avg',2000,q);
    tuneup.correctf01byRamsey('qubit',q,'robust',true,'gui',true,'save',true);
    tuneup.xyGateAmpTuner('qubit',q,'gateTyp','X','AE',false,'gui',true,'save',true);
    tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);
    XYGate ={'X','X/2'};
    for jj = 1:numel(XYGate)
        tuneup.xyGateAmpTuner('qubit',q,'gateTyp',XYGate{jj},'AE',true,'AENumPi',21,'gui',true,'save',true);
    end
end

setQSettings('r_avg',1000,'q8');
setQSettings('r_avg',1000,'q9');
acz_ampLength('controlQ','q9','targetQ','q8',...
       'dataTyp','Phase',...
       'czLength',[70:2:140],'czAmp',[2.65e4:50:2.85e4],'czDelay',20,'cState','0',...
       'notes','','gui',true,'save',true);
   
%%
qubits = {'q9','q8'};
for ii = 1:numel(qubits)
    q = qubits{ii};
    setQSettings('r_avg',2000,q);
    tuneup.correctf01byRamsey('qubit',q,'robust',true,'gui',true,'save',true);
    tuneup.xyGateAmpTuner('qubit',q,'gateTyp','X','AE',false,'gui',true,'save',true);
    tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);
    XYGate ={'X','X/2'};
    for jj = 1:numel(XYGate)
        tuneup.xyGateAmpTuner('qubit',q,'gateTyp',XYGate{jj},'AE',true,'AENumPi',21,'gui',true,'save',true);
    end
end

setQSettings('r_avg',1000,'q8');
setQSettings('r_avg',1000,'q9');
acz_ampLength('controlQ','q9','targetQ','q8',...
       'dataTyp','Phase',...
       'czLength',[60:2:200],'czAmp',[2.5e4:100:2.9e4],'czDelay',20,'cState','1',...
       'notes','','gui',true,'save',true);
   
qubits = {'q9','q8'};
for ii = 1:numel(qubits)
    q = qubits{ii};
    setQSettings('r_avg',2000,q);
    tuneup.correctf01byRamsey('qubit',q,'robust',true,'gui',true,'save',true);
    tuneup.xyGateAmpTuner('qubit',q,'gateTyp','X','AE',false,'gui',true,'save',true);
    tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);
    XYGate ={'X','X/2'};
    for jj = 1:numel(XYGate)
        tuneup.xyGateAmpTuner('qubit',q,'gateTyp',XYGate{jj},'AE',true,'AENumPi',21,'gui',true,'save',true);
    end
end

setQSettings('r_avg',1000,'q8');
setQSettings('r_avg',1000,'q9');
acz_ampLength('controlQ','q9','targetQ','q8',...
       'dataTyp','Phase',...
       'czLength',[60:2:200],'czAmp',[2.5e4:100:2.9e4],'czDelay',20,'cState','0',...
       'notes','','gui',true,'save',true);