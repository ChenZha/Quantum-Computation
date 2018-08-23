%%
import sqc.op.physical.gate.CZ
import sqc.measure.*
import sqc.util.qName2Obj
import sqc.op.physical.sequenceSampleLogger

q1 = qName2Obj('q1');
q2 = qName2Obj('q2');
g = CZ(q1,q2);

g.logSequenceSamples = true;
g.Run();

sequenceSampleLogger.plot();
%%
sl = sequenceSampleLogger.GetInstance();
[~, ~, zSequenceSamples] = sl.get();
zSamples = zSequenceSamples{1};
zSamples = zSamples/max(zSamples);
figure();plot(zSamples);