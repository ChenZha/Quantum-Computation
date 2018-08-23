%%
import sqc.util.qName2Obj;
import sqc.op.physical.*;
import sqc.util.getQSettings;
import sqc.util.setQSettings;

setQSettings('r_avg',5000);

Y2m = gate.Y2m(qName2Obj('q6'));
Y2p = gate.Y2p(qName2Obj('q6'));
I = gate.I(qName2Obj('q6'));
I.ln = 284;
zRect = op.zRect(qName2Obj('q1'));
zRect.ln = I.ln;
zRect.amp = 0;

p1 = Y2m*I*Y2p;
p2 = Y2m*zRect*Y2p;

R = sqc.measure.resonatorReadout(qd);
R.delay = p1.length;

p1.Run();
d1 = R()
p2.Run();
d2 = R()
