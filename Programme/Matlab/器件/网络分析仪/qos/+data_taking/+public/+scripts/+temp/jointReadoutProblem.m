% import sqc.op.physical.*
% 
% q7 = sqc.util.qName2Obj('q7');
% q8 = sqc.util.qName2Obj('q8');
% q9 = sqc.util.qName2Obj('q9');
% X7 = sqc.op.physical.gate.Y2p(q7);
% X8 = sqc.op.physical.gate.Y2p(q8);
% X9 = sqc.op.physical.gate.Y2p(q9);
% R = sqc.measure.resonatorReadout({q7,q8,q9});
% 
% hf = figure();
% ax = axes();
% 
% NReps = 100;
% Data = NaN(1,NReps);
% for ii = 1:NReps
%     X.Run();
%     Data(ii) = R();
%     plot(ax,Data);
%     drawnow;
% end

%%
import sqc.op.physical.*

q7 = sqc.util.qName2Obj('q7');
q8 = sqc.util.qName2Obj('q8');
q9 = sqc.util.qName2Obj('q9');
X7 = sqc.op.physical.gate.Y2p(q7);
X8 = sqc.op.physical.gate.Y2p(q8);
X9 = sqc.op.physical.gate.X(q9);
R = sqc.measure.resonatorReadout({q7,q8,q9});
R.delay = 500;

hf = figure();
ax = axes();

NReps = 10;
Data = NaN(3,NReps);
for ii = 1:NReps
    X7.Run();
    % X8.Run();
    % X9.Run();
    data = R();
    Data(1,ii) = sum(data([2,4,6,8]));
    Data(2,ii) = sum(data([3,4,7,8]));
    Data(3,ii) = sum(data([5,6,7,8]));
    plot(ax,Data.');
    drawnow;
end

%%
import sqc.op.physical.*

q7 = sqc.util.qName2Obj('q7');
q8 = sqc.util.qName2Obj('q8');
q9 = sqc.util.qName2Obj('q9');

R = sqc.measure.resonatorReadout({q7,q8,q9});
R.delay = 300;

hf = figure();
ax = axes();

q7f01 = 5.22713e09-200e6:5e6:5.22713e09+200e6;
Data = NaN(3,numel(q7f01));
for ii = 1:numel(q7f01)
    q7.f01 = q7f01(ii);
    X7 = sqc.op.physical.gate.Y2p(q7);
    X7.Run();
    data = R();
    Data(1,ii) = sum(data([2,4,6,8]));
    Data(2,ii) = sum(data([3,4,7,8]));
    Data(3,ii) = sum(data([5,6,7,8]));
    plot(ax,q7f01,Data.');
    legend({'q7','q8','q9'});
    drawnow;
end

%%
import sqc.op.physical.*

q7 = sqc.util.qName2Obj('q7');
q8 = sqc.util.qName2Obj('q8');
q9 = sqc.util.qName2Obj('q9');

R = sqc.measure.resonatorReadout({q7,q8,q9});
R.delay = 300;

hf = figure();
ax = axes();

NReps = 10;


q7f01 = 5.22713e09-200e6:5e6:5.22713e09+200e6;
Data = NaN(3,numel(q7f01));
for ii = 1:numel(q7f01)
    q9.f01 = q7f01(ii);
    X7 = sqc.op.physical.gate.Y2p(q9);
    X7.Run();
    data = R();
    Data(1,ii) = sum(data([2,4,6,8]));
    Data(2,ii) = sum(data([3,4,7,8]));
    Data(3,ii) = sum(data([5,6,7,8]));
    legend({'q7','q8','q9'});
    plot(ax,q7f01,Data.');
    drawnow;
end
%%
import sqc.op.physical.*

q7 = sqc.util.qName2Obj('q7');
q8 = sqc.util.qName2Obj('q8');
q9 = sqc.util.qName2Obj('q9');

hf = figure();
ax = axes();

NReps = 10;

q9ramp = 0:100:5000;
Data = NaN(3,numel(q9ramp));
for ii = 1:numel(q9ramp)
    q9.r_amp = q9ramp(ii);
    q9.f01 = 5.177e9;
    q9.r_freq = getQSettings('r_freq','q9')+100e6;
    R = sqc.measure.resonatorReadout({q7,q8,q9});
    R.delay = 300;
    X7 = sqc.op.physical.gate.Y2p(q9);
    X7.amp = 0;
    X7.Run();
    data = R();
    Data(1,ii) = sum(data([2,4,6,8]));
    Data(2,ii) = sum(data([3,4,7,8]));
    Data(3,ii) = sum(data([5,6,7,8]));
    legend({'q7','q8','q9'});
    plot(ax,q9ramp,Data.');
    drawnow;
end
%%
import sqc.op.physical.*

q7 = sqc.util.qName2Obj('q7');
q9 = sqc.util.qName2Obj('q9');

hf = figure();
ax = axes();

NReps = 10;

q9ramp = 5000:500:10000;
Data = NaN(3,numel(q9ramp));
for ii = 1:numel(q9ramp)
    q9.r_amp = q9ramp(ii);
    q9.f01 = 5.177e9;
    q9.r_freq = getQSettings('r_freq','q9')+00e6;
    R = sqc.measure.resonatorReadout({q7,q9});
    R.delay = 300;
    X7 = sqc.op.physical.gate.Y2p(q9);
%     X7.amp = 0;
    X7.Run();
    data = R();
    Data(1,ii) = sum(data([2,4]));
    Data(2,ii) = sum(data([3,4]));
    legend({'q7','q9'});
    plot(ax,q9ramp,Data.');
    drawnow;
end
%%
import sqc.op.physical.*

q7 = sqc.util.qName2Obj('q7');
q9 = sqc.util.qName2Obj('q9');

hf = figure();
ax = axes();

NReps = 10;

q7ramp = 0:100:5000;
Data = NaN(3,numel(q7ramp));
for ii = 1:numel(q7ramp)
    q7.r_amp = q7ramp(ii);
%     q9.f01 = 5.177e9;
%     q7.r_freq = getQSettings('r_freq','q9')+00e6;
    R = sqc.measure.resonatorReadout({q7,q9});
    R.delay = 300;
    X7 = sqc.op.physical.gate.Y2p(q7);
%     X7.amp = 0;
    X7.Run();
    data = R();
    Data(1,ii) = sum(data([2,4]));
    Data(2,ii) = sum(data([3,4]));
    legend({'q7','q9'});
    plot(ax,q9ramp,Data.');
    drawnow;
end
%%
import sqc.op.physical.*

q7 = sqc.util.qName2Obj('q7');
q8 = sqc.util.qName2Obj('q8');
q9 = sqc.util.qName2Obj('q9');

hf = figure();
ax = axes();

q9piAmp = 0:50:10000;
Data = NaN(3,numel(q9piAmp));
for ii = 1:numel(q9piAmp)
    R = sqc.measure.resonatorReadout({q7,q8,q9});
    R.delay = 300;
    X7 = sqc.op.physical.gate.Y2p(q9);
    X7.amp = q9piAmp(ii);
    X7.Run();
    data = R();
    Data(1,ii) = sum(data([2,4,6,8]));
    Data(2,ii) = sum(data([3,4,7,8]));
    Data(3,ii) = sum(data([5,6,7,8]));
    legend({'q7','q8','q9'});
    plot(ax,q9piAmp,Data.');
    drawnow;
end
%%
q7rfreq = getQSettings('r_freq','q9');
s21_01('qubit','q7','freq',[q7rfreq-1e6:0.05e6:q7rfreq+1.5e6],'notes','','gui',true,'save',true);

%%
rfc = getQSettings('r_fc','q9');
temp.s21_01_multiplexed('readoutQubits',{'q8'},'driveQubit','q7','freq',[rfc-1.5e6:0.05e6:rfc+2e6],'notes','','gui',true,'save',true);
%%
rfc = getQSettings('r_fc','q9');
temp.s21_01_multiplexed('readoutQubits',{'q7','q9'},'driveQubit','q9','freq',[rfc-1.5e6:0.05e6:rfc+2e6],'notes','','gui',true,'save',true);
%%
q7 = sqc.util.qName2Obj('q7');
q8 = sqc.util.qName2Obj('q8');
q9 = sqc.util.qName2Obj('q9');

I = sqc.op.physical.gate.I(q7);

X7 = sqc.op.physical.gate.X(q7);
X8 = sqc.op.physical.gate.X(q8);

p =  X7;
notes = 'q7:1,q8,0';
rfreq = getQSettings('r_freq','q9');
freq = rfreq-2e6:0.1e6:rfreq+2e6;
s21_process('qubit','q9','freq',freq,'process',p,...
      'notes',notes,'gui',true,'save',true);
  
%%
q7 = sqc.util.qName2Obj('q7');
q8 = sqc.util.qName2Obj('q8');
q9 = sqc.util.qName2Obj('q9');

I = sqc.op.physical.gate.I(q7);
X7 = sqc.op.physical.gate.X(q7);
X8 = sqc.op.physical.gate.X(q8);

process = X7;

hf = figure();
ax = axes();

% q7readoutDetuneFreq = 100e6:-1e6:-300e6;
q7readoutDetuneFreq = 5e6:-0.1e6:-5e6;

% q7readoutDetuneFreq = 2e9;

numFreqPoints = numel(q7readoutDetuneFreq);
r_freq0 = q7.r_freq;
Data = NaN(1,numFreqPoints);
for ii = 1:numFreqPoints
    q7.r_freq = r_freq0 + q7readoutDetuneFreq(ii);

    R = sqc.measure.resonatorReadout_ss(q9);
    R.swapdata = true;
    R.name = 'IQ';
    R.datafcn = @(x)mean(x);
    R.delay = process.length;
    
    allReadoutQubits = R.allReadoutQubits;
    allReadoutQubits{1}.r_freq = r_freq0 + q7readoutDetuneFreq(ii);
    
    process.Run();
    R.Run();
    
    Data(ii) = R.data;
    
    plot(ax,q7readoutDetuneFreq/1e9,abs(Data));
    xlabel('q7 readout frequence (GHz)');
    drawnow;
end































 

