% phase stability
% data_taking.public.xmon.temp.phaseStability(qubits, delay, DurationInMin)
function phaseStability(qubits, delay, DurationInMin)

import sqc.util.qName2Obj;
import sqc.op.physical.*;
import sqc.util.getQSettings;
import sqc.util.setQSettings;

setQSettings('r_avg',10000);

if ~iscell(qubits)
    qubits = {qubits};
end
numQs = numel(qubits);
p = cell(1,numQs);
R = cell(1,numQs);
for ii = 1: numQs
    qubits{ii} = qName2Obj(qubits{ii});
    Y = gate.Y2m(qubits{ii});
    I = gate.I(qubits{ii});
    I.ln = delay;
    p{ii} = Y*I;
    r = sqc.measure.phase(qubits{ii});
    r.setProcess(p{ii});
    R{ii} = r;
end

data = [];
time = [];
startTime = now;
Duration = DurationInMin/60/24;

QS = qes.qSettings.GetInstance();
dataPath = QS.loadSSettings('data_path');
timeStamp = datestr(now,'_yymmddTHHMMSS_');

dataFileName = ['PhaseStability_',timeStamp,'.mat'];
figFileName = ['PhaseStability_',timeStamp,'.fig'];

sessionSettings = QS.loadSSettings;
hwSettings = QS.loadHwSettings;

h = qes.ui.qosFigure(sprintf('Phase stability | %s', ''),false);
ax = axes('parent',h);
QS = qes.qSettings.GetInstance();
data_ = ones(1,numQs);
lastSaveTime = now;
while now - startTime < Duration
    for ii = 1:numQs
        data_(ii) = R{ii}();
    end
   data = [data; data_];
   time = [time, now - startTime];
   
   try
       plot(ax,time*24*60,data);
       xlabel('time (min.)');
       ylabel('phase(rad)');
       drawnow;
   catch
       h = qes.ui.qosFigure(sprintf('Phase stability | %s', ''),false);
       ax = axes('parent',h);
   end
   if true
%    if time(end) - lastSaveTime > 10/60/24
       save(fullfile(dataPath,dataFileName),'time','data','sessionSettings','hwSettings');
       if isgraphics(ax)
            saveas(ax,fullfile(dataPath,figFileName));
       end
       lastSaveTime = now;
   end
end



save(fullfile(dataPath,dataFileName),'time','data','sessionSettings','hwSettings');
if isgraphics(ax)
    saveas(ax,fullfile(dataPath,figFileName));
end

