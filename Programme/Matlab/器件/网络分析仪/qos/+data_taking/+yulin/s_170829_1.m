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
CZ = sqc.op.physical.gate.CZ(Q9,Q8);
P = CZ;
setQSettings('r_avg',5000,'q8');
setQSettings('r_avg',5000,'q9');
CZTomoData = Tomo_2QProcess('qubit1',Q9,'qubit2',Q8,...
'process',P,'reps',1,...
'notes','CZ, no xy phase shift','gui',true,'save',true);

Q8 = sqc.util.qName2Obj('q8');
Q9 = sqc.util.qName2Obj('q9');
CZ = sqc.op.physical.gate.CZ(Q9,Q8);
P = CZ^2;
setQSettings('r_avg',5000,'q8');
setQSettings('r_avg',5000,'q9');
CZTomoData = Tomo_2QProcess('qubit1',Q9,'qubit2',Q8,...
'process',P,'reps',1,...
'notes','CZ^2, no xy phase shift','gui',true,'save',true);

Q8 = sqc.util.qName2Obj('q8');
Q9 = sqc.util.qName2Obj('q9');
CZ = sqc.op.physical.gate.CZ(Q9,Q8);
P = CZ^3;
setQSettings('r_avg',5000,'q8');
setQSettings('r_avg',5000,'q9');
CZTomoData = Tomo_2QProcess('qubit1',Q9,'qubit2',Q8,...
'process',P,'reps',1,...
'notes','CZ^3, no xy phase shift','gui',true,'save',true);

Q8 = sqc.util.qName2Obj('q8');
Q9 = sqc.util.qName2Obj('q9');
CZ = sqc.op.physical.gate.CZ(Q9,Q8);
P = CZ^4;
setQSettings('r_avg',5000,'q8');
setQSettings('r_avg',5000,'q9');
CZTomoData = Tomo_2QProcess('qubit1',Q9,'qubit2',Q8,...
'process',P,'reps',1,...
'notes','CZ^4, no xy phase shift','gui',true,'save',true);

Q8 = sqc.util.qName2Obj('q8');
Q9 = sqc.util.qName2Obj('q9');
CZ = sqc.op.physical.gate.CZ(Q9,Q8);
P = CZ^5;
setQSettings('r_avg',5000,'q8');
setQSettings('r_avg',5000,'q9');
CZTomoData = Tomo_2QProcess('qubit1',Q9,'qubit2',Q8,...
'process',P,'reps',1,...
'notes','CZ^5, no xy phase shift','gui',true,'save',true);

Q8 = sqc.util.qName2Obj('q8');
Q9 = sqc.util.qName2Obj('q9');
CZ = sqc.op.physical.gate.CZ(Q9,Q8);
P = CZ^6;
setQSettings('r_avg',5000,'q8');
setQSettings('r_avg',5000,'q9');
CZTomoData = Tomo_2QProcess('qubit1',Q9,'qubit2',Q8,...
'process',P,'reps',1,...
'notes','CZ^6, no xy phase shift','gui',true,'save',true);

Q8 = sqc.util.qName2Obj('q8');
Q9 = sqc.util.qName2Obj('q9');
CZ = sqc.op.physical.gate.CZ(Q9,Q8);
P = CZ^7;
setQSettings('r_avg',5000,'q8');
setQSettings('r_avg',5000,'q9');
CZTomoData = Tomo_2QProcess('qubit1',Q9,'qubit2',Q8,...
'process',P,'reps',1,...
'notes','CZ^7, no xy phase shift','gui',true,'save',true);
%%
Q8 = sqc.util.qName2Obj('q8');
Q9 = sqc.util.qName2Obj('q9');
CZ = sqc.op.physical.gate.CZ(Q9,Q8);
I1 = sqc.op.physical.gate.I(Q9);
I1.ln = 40;
P = CZ*I1;
setQSettings('r_avg',5000,'q8');
setQSettings('r_avg',5000,'q9');
CZTomoData = Tomo_2QProcess('qubit1',Q9,'qubit2',Q8,...
'process',P,'reps',1,...
'notes','CZ+Idle40','gui',true,'save',true);

Q8 = sqc.util.qName2Obj('q8');
Q9 = sqc.util.qName2Obj('q9');
CZ = sqc.op.physical.gate.CZ(Q9,Q8);
I1 = sqc.op.physical.gate.I(Q9);
I1.ln = 80;
P = CZ*I1;
setQSettings('r_avg',5000,'q8');
setQSettings('r_avg',5000,'q9');
CZTomoData = Tomo_2QProcess('qubit1',Q9,'qubit2',Q8,...
'process',P,'reps',1,...
'notes','CZ+Idle80','gui',true,'save',true);

Q8 = sqc.util.qName2Obj('q8');
Q9 = sqc.util.qName2Obj('q9');
CZ = sqc.op.physical.gate.CZ(Q9,Q8);
I1 = sqc.op.physical.gate.I(Q9);
I1.ln = 120;
P = CZ*I1;
setQSettings('r_avg',5000,'q8');
setQSettings('r_avg',5000,'q9');
CZTomoData = Tomo_2QProcess('qubit1',Q9,'qubit2',Q8,...
'process',P,'reps',1,...
'notes','CZ+Idle120','gui',true,'save',true);

Q8 = sqc.util.qName2Obj('q8');
Q9 = sqc.util.qName2Obj('q9');
CZ = sqc.op.physical.gate.CZ(Q9,Q8);
I1 = sqc.op.physical.gate.I(Q9);
I1.ln = 160;
P = CZ*I1;
setQSettings('r_avg',5000,'q8');
setQSettings('r_avg',5000,'q9');
CZTomoData = Tomo_2QProcess('qubit1',Q9,'qubit2',Q8,...
'process',P,'reps',1,...
'notes','CZ+Idle160','gui',true,'save',true);


Q8 = sqc.util.qName2Obj('q8');
Q9 = sqc.util.qName2Obj('q9');
CZ = sqc.op.physical.gate.CZ(Q9,Q8);
I1 = sqc.op.physical.gate.I(Q9);
I1.ln = 200;
P = CZ*I1;
setQSettings('r_avg',5000,'q8');
setQSettings('r_avg',5000,'q9');
CZTomoData = Tomo_2QProcess('qubit1',Q9,'qubit2',Q8,...
'process',P,'reps',1,...
'notes','CZ+Idle200','gui',true,'save',true);

%%
Q8 = sqc.util.qName2Obj('q8');
Q9 = sqc.util.qName2Obj('q9');
X2p1 = sqc.op.physical.gate.X2p(Q9);
X2p2 = sqc.op.physical.gate.X2p(Q8);
P = (X2p1.*X2p2);
setQSettings('r_avg',5000,'q8');
setQSettings('r_avg',5000,'q9');
CZTomoData = Tomo_2QProcess('qubit1',Q9,'qubit2',Q8,...
'process',P,'reps',1,...
'notes','X/2,X/2','gui',true,'save',true);

Q8 = sqc.util.qName2Obj('q8');
Q9 = sqc.util.qName2Obj('q9');
X2p1 = sqc.op.physical.gate.X2p(Q9);
X2p2 = sqc.op.physical.gate.X2p(Q8);
I1 = sqc.op.physical.gate.I(Q9);
I1.ln = 100;
P = (X2p1.*X2p2)*I1;
setQSettings('r_avg',5000,'q8');
setQSettings('r_avg',5000,'q9');
CZTomoData = Tomo_2QProcess('qubit1',Q9,'qubit2',Q8,...
'process',P,'reps',1,...
'notes','X/2,X/2+Idle100','gui',true,'save',true);

Q8 = sqc.util.qName2Obj('q8');
Q9 = sqc.util.qName2Obj('q9');
X2p1 = sqc.op.physical.gate.X2p(Q9);
X2p2 = sqc.op.physical.gate.X2p(Q8);
I1 = sqc.op.physical.gate.I(Q9);
I1.ln = 200;
P = (X2p1.*X2p2)*I1;
setQSettings('r_avg',5000,'q8');
setQSettings('r_avg',5000,'q9');
CZTomoData = Tomo_2QProcess('qubit1',Q9,'qubit2',Q8,...
'process',P,'reps',1,...
'notes','X/2,X/2+Idle200','gui',true,'save',true);

Q8 = sqc.util.qName2Obj('q8');
Q9 = sqc.util.qName2Obj('q9');
X2p1 = sqc.op.physical.gate.X2p(Q9);
X2p2 = sqc.op.physical.gate.X2p(Q8);
I1 = sqc.op.physical.gate.I(Q9);
I1.ln = 300;
P = (X2p1.*X2p2)*I1;
setQSettings('r_avg',5000,'q8');
setQSettings('r_avg',5000,'q9');
CZTomoData = Tomo_2QProcess('qubit1',Q9,'qubit2',Q8,...
'process',P,'reps',1,...
'notes','X/2,X/2+Idle300','gui',true,'save',true);


% Q8 = sqc.util.qName2Obj('q8');
% Q9 = sqc.util.qName2Obj('q9');
% I1 = sqc.op.physical.gate.I(Q9);
% I1.ln = 130;
% I2 = sqc.op.physical.gate.I(Q8);
% I2.ln = 130;
% P = I1.*I2;
% setQSettings('r_avg',5000,'q8');
% setQSettings('r_avg',5000,'q9');
% CZTomoData = Tomo_2QProcess('qubit1',Q9,'qubit2',Q8,...
% 'process',P,'reps',1,...
% 'notes','Idle gate of the same length with ','gui',true,'save',true);