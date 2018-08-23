import sqc.op.physical.gate.CZ
import sqc.measure.*
import sqc.util.qName2Obj
import sqc.measure.randBenchMarking_multiplexed
import sqc.op.physical.sequenceSampleLogger
numGates = 30;
% %%
% q1 = qName2Obj('q1');
% q2 = qName2Obj('q2');
% process = CZ(q1,q2);
% rb12 = sqc.measure.randBenchMarking_multiplexed({q1,q2}, process, numGates, 1, false);
% [gs12] = rb12.randGates();
% PR12 = gs12{1,1};
% for ii = 2:numGates
%     PR12 = PR12.noCopyTimes(gs12{1,ii});
% end
% PR12.logSequenceSamples = true;
% PR12.Run();
% sequenceSampleLogger.plot();
%%
q3 = qName2Obj('q3');
q2 = qName2Obj('q2');
process = CZ(q3,q2);
rb32 = sqc.measure.randBenchMarking_multiplexed({q3,q2}, process, numGates, 1, false);
[gs32] = rb32.randGates();
PR32 = gs32{1,1};
for ii = 2:numGates
    PR32 = PR32.noCopyTimes(gs32{1,ii});
end
PR32.logSequenceSamples = true;
sl = sequenceSampleLogger.GetInstance();
% sl.clear();
PR32.Run();
% sequenceSampleLogger.plot();

% %%
% q3 = qName2Obj('q3');
% q4 = qName2Obj('q4');
% process = CZ(q3,q4);
% rb34 = sqc.measure.randBenchMarking_multiplexed({q3,q4}, process, numGates, 1, false);
% [gs34] = rb34.randGates();
% PR34 = gs34{1,1};
% for ii = 2:numGates
%     PR34 = PR34.noCopyTimes(gs34{1,ii});
% end
% PR34.logSequenceSamples = true;
% sl = sequenceSampleLogger.GetInstance();
% sl.clear();
% PR34.Run();
% sequenceSampleLogger.plot();

% %%
% q5 = qName2Obj('q5');
% q4 = qName2Obj('q4');
% process = CZ(q5,q4);
% rb54 = sqc.measure.randBenchMarking_multiplexed({q5,q4}, process, numGates, 1, false);
% [gs54] = rb54.randGates();
% PR54 = gs54{1,1};
% for ii = 2:numGates
%     PR54 = PR54.noCopyTimes(gs54{1,ii});
% end
% PR54.logSequenceSamples = true;
% sl = sequenceSampleLogger.GetInstance();
% sl.clear();
% PR54.Run();
% sequenceSampleLogger.plot();

% %%
% q5 = qName2Obj('q5');
% q6 = qName2Obj('q6');
% process = CZ(q5,q6);
% rb56 = sqc.measure.randBenchMarking_multiplexed({q5,q6}, process, numGates, 1, false);
% [gs56] = rb56.randGates();
% PR56 = gs56{1,1};
% for ii = 2:numGates
%     PR56 = PR56.noCopyTimes(gs56{1,ii});
% end
% PR56.logSequenceSamples = true;
% sl = sequenceSampleLogger.GetInstance();
% sl.clear();
% PR56.Run();
% sequenceSampleLogger.plot();

%%
q7 = qName2Obj('q7');
q6 = qName2Obj('q6');
process = CZ(q7,q6);
rb76 = sqc.measure.randBenchMarking_multiplexed({q7,q6}, process, numGates, 1, false);
[gs76] = rb76.randGates();
PR76 = gs76{1,1};
for ii = 2:numGates
    PR76 = PR76.noCopyTimes(gs76{1,ii});
end
PR76.logSequenceSamples = true;
sl = sequenceSampleLogger.GetInstance();
% sl.clear();
PR76.Run();
% sequenceSampleLogger.plot();

% %%
% q7 = qName2Obj('q7');
% q8 = qName2Obj('q8');
% process = CZ(q7,q8);
% rb78 = sqc.measure.randBenchMarking_multiplexed({q7,q8}, process, numGates, 1, false);
% [gs78] = rb78.randGates();
% PR78 = gs78{1,1};
% for ii = 2:numGates
%     PR78 = PR78.noCopyTimes(gs78{1,ii});
% end
% PR78.logSequenceSamples = true;
% sl = sequenceSampleLogger.GetInstance();
% sl.clear();
% PR78.Run();
% sequenceSampleLogger.plot();

% %%
% q9 = qName2Obj('q9');
% q8 = qName2Obj('q8');
% process = CZ(q9,q8);
% rb98 = sqc.measure.randBenchMarking_multiplexed({q9,q8}, process, numGates, 1, false);
% [gs98] = rb98.randGates();
% PR98 = gs98{1,1};
% for ii = 2:numGates
%     PR98 = PR98.noCopyTimes(gs98{1,ii});
% end
% PR98.logSequenceSamples = true;
% sl = sequenceSampleLogger.GetInstance();
% sl.clear();
% PR98.Run();
% sequenceSampleLogger.plot();

% %%
% q9 = qName2Obj('q9');
% q10 = qName2Obj('q10');
% process = CZ(q9,q10);
% rb910 = sqc.measure.randBenchMarking_multiplexed({q9,q10}, process, numGates, 1, false);
% [gs910] = rb910.randGates();
% PR910 = gs910{1,1};
% for ii = 2:numGates
%     PR910 = PR910.noCopyTimes(gs910{1,ii});
% end
% PR910.logSequenceSamples = true;
% sl = sequenceSampleLogger.GetInstance();
% sl.clear();
% PR910.Run();
% sequenceSampleLogger.plot();

%%
q11 = qName2Obj('q11');
q10 = qName2Obj('q10');
process = CZ(q11,q10);
rb1110 = sqc.measure.randBenchMarking_multiplexed({q11,q10}, process, numGates, 1, false);
[gs1110] = rb1110.randGates();
PR1110 = gs1110{1,1};
for ii = 2:numGates
    PR1110 = PR1110.noCopyTimes(gs1110{1,ii});
end
PR1110.logSequenceSamples = true;
sl = sequenceSampleLogger.GetInstance();
% sl.clear();
PR1110.Run();
% sequenceSampleLogger.plot();

% sl = sequenceSampleLogger.GetInstance();
% sequenceSamples = sl.get(obj,{'q1'});

%%
numGates1 = 125;
%%
q1 = qName2Obj('q1');
process = X(q1);
rb1 = sqc.measure.randBenchMarking_multiplexed({q1}, process, numGates1, 1, false);
[gs1] = rb1.randGates();
PR1 = gs1{2,1};
for ii = 2:numGates1
    PR1 = PR1*process;
    PR1 = PR1.noCopyTimes(gs1{2,ii});
end
PR1.logSequenceSamples = true;
sl = sequenceSampleLogger.GetInstance();
% sl.clear();
PR1.Run();
sequenceSampleLogger.plot();
%%
q1 = qName2Obj('q5');
process = X(q1);
rb1 = sqc.measure.randBenchMarking_multiplexed({q1}, process, numGates1, 1, false);
[gs1] = rb1.randGates();
PR1 = gs1{2,1};
for ii = 2:numGates1
    PR1 = PR1*process;
    PR1 = PR1.noCopyTimes(gs1{2,ii});
end
PR1.logSequenceSamples = true;
sl = sequenceSampleLogger.GetInstance();
% sl.clear();
PR1.Run();
sequenceSampleLogger.plot();
%%
q1 = qName2Obj('q9');
process = X(q1);
rb1 = sqc.measure.randBenchMarking_multiplexed({q1}, process, numGates1, 1, false);
[gs1] = rb1.randGates();
PR1 = gs1{2,1};
for ii = 2:numGates1
    PR1 = PR1*process;
    PR1 = PR1.noCopyTimes(gs1{2,ii});
end
PR1.logSequenceSamples = true;
sl = sequenceSampleLogger.GetInstance();
% sl.clear();
PR1.Run();
sequenceSampleLogger.plot();