%%
import sqc.util.qName2Obj;
import sqc.op.physical.*;
import sqc.util.getQSettings;
import sqc.util.setQSettings;

import qes.*
import qes.hwdriver.sync.*
QS = qSettings.GetInstance('D:\settings');
ustcaddaObj = ustcadda_v1.GetInstance();

setQSettings('r_avg',5000);

daChnlMap = [1,2,3,4,15,16,17,18,19,20,21,22,23,24,...
    25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44];

wavedata = 32768*ones(1,3e3);


Y = gate.Y2m(qName2Obj('q6'));
I = gate.I(qName2Obj('q6'));

zRect1 = op.zRect(qName2Obj('q1'));
zRect1.ln = 284;
zRect1.amp = 0;

zRect1 = gate.X(qName2Obj('q1'));

% h = figure();
% ax = axes(h);
hold on;
length = 10:100:2000;
numData = numel(length);
data = NaN(1,numData);
for ii = 1:numData

I.ln = length(ii);
p = Y*I;
% 
ustcaddaObj.SendWave(daChnlMap(5),wavedata);

% data_taking.public.util.setZDC('q1');

R = sqc.measure.phase(qName2Obj('q6'));
R.setProcess(p);
data(ii) = R();
plot(length,data,'-s');
drawnow;
end

% p1 = p*gate.Y2p(qd);
% p2 = p*gate.X2m(qd);
% R = sqc.measure.resonatorReadout(qd);
% R.delay = p1.length;
% p1.Run();
% d1 = R()
% p2.Run();
% d2 = R()

%%


%%

% chnls = [10,33,32,8,9];
% for ii = 1:numel(chnls)
%     ustcaddaObj.SendWave(daChnlMap(chnls(ii)),wavedata);
% end
p = Y*I;
R = sqc.measure.phase(qd);
R.setProcess(p);
d0 = R()

chnls = [10,8,9,32];
for ii = 1:numel(chnls)
    ustcaddaObj.SendWave(daChnlMap(chnls(ii)),wavedata);
end
p = Y*I;
R = sqc.measure.phase(qd);
R.setProcess(p);
d0 = R()