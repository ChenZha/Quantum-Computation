%%
import sqc.op.physical.*
import sqc.measure.*
import sqc.util.qName2Obj

q1 = qName2Obj('q9');
q2 = qName2Obj('q8');

CZ = gate.CZ(q1,q2);
I = gate.I(q1);
I.ln = CZ.length;
Z = gate.Z4p(q1);
% Z = op.Z_arbPhase(q1,pi/4);
X = gate.X(q1);

% p = CZ*X*CZ*X*CZ*X*CZ*X;
p = Z*X*Z*X*Z*X*Z*X;
p.Run();

% plot the waveforms to check

%% validate Z_arbPhase
q = qName2Obj('q1');
g1 = gate.Y2m(q);
g2 = gate.I(q);
g2.ln = 2;
phaseSet = 1;
g3 = gate.Rz(q,phaseSet);
proc = g1*g2*g3;
R = phase(q);
R.setProcess(proc);
phaseMeasured = R();
disp('<<<< validate arbitary z rotation >>>>');
disp(['phase set: ', num2str(phaseSet), ', phase measured: ', num2str(phaseMeasured)]);
%%
q1 = qName2Obj('q1');
q2 = qName2Obj('q2');
g1 = gate.H(q1);
g2 = gate.H(q2);
g1_ = gate.X2p(q1);
g2_ = gate.X2p(q2);
g3 = gate.Rz(q1,pi/2);
g4 = gate.Rz(q2,pi);
proc =(g1.*g2);
% proc1 = g3.*g4;
% proc2 = g1.*g2;
% proc = proc1*proc2;
proc.logSequenceSamples = true;
sl = sqc.op.physical.sequenceSampleLogger.GetInstance();
sl.clear();
proc.Run();
sl.plot();