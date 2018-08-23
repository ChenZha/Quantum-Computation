%%
import data_taking.public.util.allQNames
import data_taking.public.util.setZDC
import data_taking.public.util.readoutFreqDiagram
import sqc.util.getQSettings
import sqc.util.setQSettings
import data_taking.public.xmon.*

import sqc.op.physical.*
import sqc.measure.*
import sqc.util.qName2Obj
import sqc.util.setQSettings
QS = qes.qSettings.GetInstance();
%%
data_taking.public.scripts.temp.GHZ
%%
controlQ = 'q9';
targetQ = 'q8';
% detuneQ = 'q6';

qubits = {controlQ,targetQ};
for ii = 1:numel(qubits)
    q = qubits{ii};
    setQSettings('r_avg',2000); 
    tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);
    tuneup.correctf01byRamsey('qubit',q,'robust',true,'gui',true,'save',true);
    XYGate ={'X/2'};
    for jj = 1:numel(XYGate)
        tuneup.xyGateAmpTuner('qubit',q,'gateTyp',XYGate{jj},'AE',true,'AENumPi',41,'gui',true,'save',true);
    end
    tuneup.iq2prob_01('qubit',q,'numSamples',5e4,'gui',true,'save',true);
end

setQSettings('r_avg',5000);
tuneup.czAmplitude('controlQ',controlQ,'targetQ',targetQ,'gui',true);
% tuneup.czPhaseTomo('controlQ',controlQ,'targetQ',targetQ);
sqc.measure.gateOptimizer.czOptPhase({controlQ,targetQ},4,20,1500, 50);

%%
controlQ = 'q7';
targetQ = 'q8';
detuneQ = 'q6';

qubits = {controlQ,targetQ};
for ii = 1:numel(qubits)
    q = qubits{ii};
    setQSettings('r_avg',2000); 
    tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);
    tuneup.correctf01byRamsey('qubit',q,'robust',true,'gui',true,'save',true);
    XYGate ={'X/2'};
    for jj = 1:numel(XYGate)
        tuneup.xyGateAmpTuner('qubit',q,'gateTyp',XYGate{jj},'AE',true,'AENumPi',41,'gui',true,'save',true);
    end
    tuneup.iq2prob_01('qubit',q,'numSamples',5e4,'gui',true,'save',true);
end

setQSettings('r_avg',5000);
tuneup.czAmplitude('controlQ',controlQ,'targetQ',targetQ,'gui',true);
% tuneup.czPhaseTomo('controlQ',controlQ,'targetQ',targetQ);
sqc.measure.gateOptimizer.czOptPhase({controlQ,targetQ},4,20,1500, 50);

%%
controlQ = 'q7';
targetQ = 'q6';
detuneQ = 'q8';

qubits = {controlQ,targetQ};
for ii = 1:numel(qubits)
    q = qubits{ii};
    setQSettings('r_avg',2000); 
    tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);
    tuneup.correctf01byRamsey('qubit',q,'robust',true,'gui',true,'save',true);
    XYGate ={'X/2'};
    for jj = 1:numel(XYGate)
        tuneup.xyGateAmpTuner('qubit',q,'gateTyp',XYGate{jj},'AE',true,'AENumPi',41,'gui',true,'save',true);
    end
    tuneup.iq2prob_01('qubit',q,'numSamples',5e4,'gui',true,'save',true);
end

setQSettings('r_avg',5000);
tuneup.czAmplitude('controlQ',controlQ,'targetQ',targetQ,'gui',true);
% tuneup.czPhaseTomo('controlQ',controlQ,'targetQ',targetQ);
sqc.measure.gateOptimizer.czOptPhase({controlQ,targetQ},4,20,1500, 50);

%%
controlQ = 'q5';
targetQ = 'q6';
detuneQ = 'q4';

qubits = {controlQ,targetQ};
for ii = 1:numel(qubits)
    q = qubits{ii};
    setQSettings('r_avg',2000); 
    tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);
    tuneup.correctf01byRamsey('qubit',q,'robust',true,'gui',true,'save',true);
    XYGate ={'X/2'};
    for jj = 1:numel(XYGate)
        tuneup.xyGateAmpTuner('qubit',q,'gateTyp',XYGate{jj},'AE',true,'AENumPi',41,'gui',true,'save',true);
    end
    tuneup.iq2prob_01('qubit',q,'numSamples',5e4,'gui',true,'save',true);
end

setQSettings('r_avg',5000);
tuneup.czAmplitude('controlQ',controlQ,'targetQ',targetQ,'gui',true);
% tuneup.czPhaseTomo('controlQ',controlQ,'targetQ',targetQ);
sqc.measure.gateOptimizer.czOptPhase({controlQ,targetQ},4,20,1500, 50);
%%
data_taking.public.scripts.temp.GHZ
%%
data_taking.public.scripts.qecc.qecc