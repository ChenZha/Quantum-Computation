import data_taking.public.xmon.*
allQs = {'q1','q2','q3','q4','q5','q6','q7','q8','q9','q10','q11','q12'};
% czQSet: {'aczQ','otherQ','dynamicPhaseQ1','dynamicPhaseQ2',...} % 'aczQ'
% and 'otherQ' dynamic phases are corrected by default, no need to add
% them as dynamicPaseQs
czQSets = {{'q1','q2','q3','q4','q5','q6','q7','q8','q9','q10','q11','q12'},... 
           {'q3','q2','q1','q4','q5','q6','q7','q8','q9','q10','q11','q12'},...
           {'q3','q4','q1','q2','q5','q6','q7','q8','q9','q10','q11','q12'},...
           {'q5','q4','q1','q2','q3','q6','q7','q8','q9','q10','q11','q12'},...
           {'q5','q6','q1','q2','q3','q4','q7','q8','q9','q10','q11','q12'},... 
           {'q7','q6','q1','q2','q3','q4','q5','q8','q9','q10','q11','q12'},...
           {'q7','q8','q1','q2','q3','q4','q5','q6','q9','q10','q11','q12'},...
           {'q9','q8','q1','q2','q3','q4','q5','q6','q7','q10','q11','q12'},...
           {'q9','q10','q1','q2','q3','q4','q5','q6','q7','q8','q11','q12'},... 
           {'q11','q10','q1','q2','q3','q4','q5','q6','q7','q8','q9','q12'},...
           {'q11','q12','q1','q2','q3','q4','q5','q6','q7','q8','q9','q10'},...
          };
numCZs = struct(); numCZs.q1 = 10; numCZs.q2 = 10; numCZs.q3 = 10;
numCZs.q4 = 10; numCZs.q5 = 10; numCZs.q6 = 10; numCZs.q7 = 10;
numCZs.q8 = 10; numCZs.q9 = 10;numCZs.q10 = 10; numCZs.q11 = 10; numCZs.q12 = 10;

tStart = now;
% for ii = 1:numel(allQs)
%     q = allQs{ii};
%     setQSettings('r_avg',2000); 
%     tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);
%     % tuneup.correctf01byRamsey('qubit',q,'robust',true,'gui',true,'save',true);
%     setQSettings('r_avg',5000); 
%     tuneup.correctf01byPhase('qubit',q,'delayTime',1e-6,'gui',true,'save',true);
%     setQSettings('r_avg',2000); 
%     tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);
%     XYGate ={'X/2'};
%     for jj = 1:numel(XYGate)
%         tuneup.xyGateAmpTuner('qubit',q,'gateTyp',XYGate{jj},'AE',true,'AENumPi',41,'gui',true,'save',true);
%     end
%     tuneup.iq2prob_01('qubit',q,'numSamples',5e4,'gui',true,'save',true);
% end

setQSettings('r_avg',1000);
for ii = 2:numel(czQSets)
    czQSet = czQSets{ii};
    tuneup.czAmplitude('controlQ',czQSet{1},'targetQ',czQSet{2},'largeRange',false,'repeatIfOutOfBoundButClose',true,'gui',true);
    tuneup.czPhaseTomo('controlQ',czQSet{1},'targetQ',czQSet{2});
    % sqc.measure.gateOptimizer.czOptPhase({czQSet{1},czQSet{2}},4,20,1500, 50);
    tuneup.czDynamicPhase_parallel('controlQ',czQSet{1},'targetQ',czQSet{2},'dynamicPhaseQs',{czQSet{3:end}},...
        'numCZs',numCZs.(czQSet{jj}),'PhaseTolerance',0.03,...
        'gui','true','save',true);
end
timeTaken = (now - tStart)*24
%% measure dynamic phase
import sqc.util.qName2Obj;
import sqc.op.physical.*;

controlQ = 'q1';
targetQ = 'q2';
dynamicPhaseQ = 'q3';
setQSettings('r_avg',5000);

qc = qName2Obj(controlQ);
qt = qName2Obj(targetQ);
qd = qName2Obj(dynamicPhaseQ);
Y = gate.Y2m(qd);
CZ = gate.CZ(qc,qt);

numCZs = 1:10;
data = NaN(1,numel(numCZs));
h = figure();
ax = axes(h);
for ii = numCZs
    p = Y*(CZ^ii);
    R = sqc.measure.phase(qd);
    R.setProcess(p);
    data(ii) = R();
    plot(numCZs,data,'-s');
    drawnow;
end
hold off;
plot(numCZs,unwrap(data),'-s');
%%
import sqc.util.qName2Obj;
import sqc.op.physical.*;

controlQ = 'q7';
targetQ = 'q8';
dynamicPhaseQ = 'q6';
setQSettings('r_avg',5000);

aczSettings = sqc.qobj.aczSettings(sprintf('%s_%s',controlQ,targetQ));
aczSettings.load();

detuneFreq = aczSettings.detuneFreq;

qc = qName2Obj(controlQ);
qt = qName2Obj(targetQ);
qd = qName2Obj(dynamicPhaseQ);
qc.aczSettings(end+1) = aczSettings;
qt.aczSettings(end+1) = aczSettings;

Y = gate.Y2p(qd);

numData = 30;
DATA = NaN(1,numData);
h = figure();
ax = axes(h);
for ii = 1:numData
aczSettings.detuneFreq = detuneFreq;
aczSettings.dynamicPhase(3) = -4.9032-0.3286;

CZ = gate.CZ(qc,qt);

p = Y*CZ;
R = sqc.measure.phase(qd);
R.setProcess(p);
d1 = R();

aczSettings.detuneFreq = 0;
aczSettings.dynamicPhase(3) = 0;
CZ = gate.CZ(qc,qt);
p = Y*CZ;
R.setProcess(p);
d0 = R();

DATA(ii) = d1 - d0;
plot(DATA,'-s');
drawnow;
end
%%
import sqc.util.qName2Obj;
import sqc.op.physical.*;

controlQ = 'q9';
targetQ = 'q8';
dynamicPhaseQ = 'q6';
setQSettings('r_avg',5000);

aczSettings = sqc.qobj.aczSettings(sprintf('%s_%s',controlQ,targetQ));
aczSettings.load();

aczamp = aczSettings.amp;
meetUpDetuneFreq = aczSettings.meetUpDetuneFreq;
detuneFreq = aczSettings.detuneFreq;

qc = qName2Obj(controlQ);
qt = qName2Obj(targetQ);
qd = qName2Obj(dynamicPhaseQ);
qc.aczSettings(end+1) = aczSettings;
qt.aczSettings(end+1) = aczSettings;

Y = gate.Y2p(qd);
I = gate.I(qd);

numData = 10;
DATA = NaN(1,numData);
DATA0 = NaN(1,numData);
h = figure();
ax = axes(h);
for ii = 1:1
% aczSettings.amp = aczamp;
% aczSettings.meetUpDetuneFreq = meetUpDetuneFreq;
% % aczSettings.detuneFreq = detuneFreq;
% % aczSettings.dynamicPhase(3) = 0;
% CZ = gate.CZ(qc,qt);
% p = Y*CZ;
% R = sqc.measure.phase(qd);
% R.setProcess(p);
% d1 = R();

d1 = 0;

aczSettings.amp = 0;
aczSettings.meetUpDetuneFreq = 0;
% aczSettings.detuneFreq = 0;
% aczSettings.dynamicPhase(3) = 0;
aczSettings.dynamicPhase = [0,0];
% CZ = gate.CZ(qc,qt);
% p = Y*CZ;

I.ln = CZ.length;
p = Y*I;

R = sqc.measure.phase(qd);
R.setProcess(p);
d0 = R();

DATA(ii) = d1;
DATA0(ii) = d0;

plot(DATA-DATA0,'-sg');
hold on;
plot(DATA,'--sr');
plot(DATA0,'--ob');

% DATA(ii) = d1;
% DATA0(ii) = d0;
% plot(DATA,'-sr');
% hold on;
% plot(DATA0,'-ob');
% hold off;
drawnow;
end
























    
% setQSettings('r_avg',5000);
% % czDetuneQPhaseTomo('controlQ',controlQ,'targetQ',targetQ,'dynamicPhaseQ',dynamicPhaseQ,...
% %       'phase',[-pi:2*pi/20:pi],'numCZs',1,... % [-pi:2*pi/20:pi]
% %       'notes','','gui',true,'save',true);
% 
% phase = [-1.5*pi:2*pi/6:1.5*pi];
% data_taking.public.xmon.tuneup.czDetuneQPhaseFit('controlQ',controlQ,'targetQ',targetQ,'dynamicPhaseQ',dynamicPhaseQ,...
%     'phase',phase,'numCZs',1,'gui',true);