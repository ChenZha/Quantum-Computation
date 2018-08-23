%%
import sqc.op.physical.gate.XYArb
import sqc.op.physical.gate.X
import sqc.measure.*
import sqc.util.qName2Obj
import sqc.op.physical.sequenceSampleLogger

q1 = qName2Obj('q1');
XY1 = XYArb(q1,0,pi/3);
XY2 = XYArb(q1,0,2*pi/3);
XY3 = XYArb(q1,-pi/3,pi/4);

XY4 = X(q1);

p = XY1*XY2*XY3;
p.logSequenceSamples = true;
p.Run();
% p = XY4^2;
% p.Run();

sequenceSampleLogger.plot();
%%
import sqc.op.physical.gate.XYArb
import sqc.measure.*
import sqc.util.qName2Obj

q1 = qName2Obj('q1');
XY1 = XYArb(q1,-pi/3,pi/4);

p = XY1^4;
p.Run();
R = resonatorReadout(q1);
R();