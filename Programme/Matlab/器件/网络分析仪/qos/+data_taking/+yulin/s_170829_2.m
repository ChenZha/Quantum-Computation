qubits = {'q9','q8'};
for ii = 1:numel(qubits)
    q = qubits{ii};
    setQSettings('r_avg',2000,q);
    tuneup.correctf01byRamsey('qubit',q,'robust',true,'gui',true,'save',true);
    tuneup.xyGateAmpTuner('qubit',q,'gateTyp','X','AE',false,'gui',true,'save',true);
    tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);
    XYGate ={'X','X/2'};
    for jj = 1:numel(XYGate)
        tuneup.xyGateAmpTuner('qubit',q,'gateTyp',XYGate{jj},'AE',true,'AENumPi',41,'gui',true,'save',true);
    end
end


Q8 = sqc.util.qName2Obj('q8');
Q9 = sqc.util.qName2Obj('q9');
I1 = sqc.op.physical.gate.I(Q9);
I1.ln = 1;
I2 = sqc.op.physical.gate.I(Q8);
I2.ln = 1;
P = I1.*I2;
setQSettings('r_avg',5000,'q8');
setQSettings('r_avg',5000,'q9');
CZTomoData = Tomo_2QProcess('qubit1',Q9,'qubit2',Q8,...
'process',P,'reps',1,...
'notes','I, length = 0.5ns','gui',true,'save',true);

Q8 = sqc.util.qName2Obj('q8');
Q9 = sqc.util.qName2Obj('q9');
I1 = sqc.op.physical.gate.I(Q9);
I1.ln = 40;
I2 = sqc.op.physical.gate.I(Q8);
I2.ln = 40;
P = I1.*I2;
setQSettings('r_avg',5000,'q8');
setQSettings('r_avg',5000,'q9');
CZTomoData = Tomo_2QProcess('qubit1',Q9,'qubit2',Q8,...
'process',P,'reps',1,...
'notes','I, length = 20ns','gui',true,'save',true);

Q8 = sqc.util.qName2Obj('q8');
Q9 = sqc.util.qName2Obj('q9');
I1 = sqc.op.physical.gate.I(Q9);
I1.ln = 100;
I2 = sqc.op.physical.gate.I(Q8);
I2.ln = 100;
P = I1.*I2;
setQSettings('r_avg',5000,'q8');
setQSettings('r_avg',5000,'q9');
CZTomoData = Tomo_2QProcess('qubit1',Q9,'qubit2',Q8,...
'process',P,'reps',1,...
'notes','I, length = 50ns','gui',true,'save',true);

Q8 = sqc.util.qName2Obj('q8');
Q9 = sqc.util.qName2Obj('q9');
I1 = sqc.op.physical.gate.I(Q9);
I1.ln = 200;
I2 = sqc.op.physical.gate.I(Q8);
I2.ln = 200;
P = I1.*I2;
setQSettings('r_avg',5000,'q8');
setQSettings('r_avg',5000,'q9');
CZTomoData = Tomo_2QProcess('qubit1',Q9,'qubit2',Q8,...
'process',P,'reps',1,...
'notes','I, length = 100ns','gui',true,'save',true);

Q8 = sqc.util.qName2Obj('q8');
Q9 = sqc.util.qName2Obj('q9');
I1 = sqc.op.physical.gate.I(Q9);
I1.ln = 400;
I2 = sqc.op.physical.gate.I(Q8);
I2.ln = 400;
P = I1.*I2;
setQSettings('r_avg',5000,'q8');
setQSettings('r_avg',5000,'q9');
CZTomoData = Tomo_2QProcess('qubit1',Q9,'qubit2',Q8,...
'process',P,'reps',1,...
'notes','I, length = 200ns','gui',true,'save',true);