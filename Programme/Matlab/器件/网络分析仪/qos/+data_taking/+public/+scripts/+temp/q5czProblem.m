import sqc.op.physical.*
import sqc.measure.*
import sqc.util.qName2Obj

q1 = qName2Obj('q5');
q2 = qName2Obj('q6');

X1 = gate.X(q1);
% X1 = gate.I(q1);

aczSettingsKey = 'q5_q6';
QS = qes.qSettings.GetInstance();
scz = QS.loadSSettings({'shared','g_cz',aczSettingsKey});

aczSettings = sqc.qobj.aczSettings();
fn = fieldnames(scz);
for ii = 1:numel(fn)
    aczSettings.(fn{ii}) = scz.(fn{ii});
end

czAmp = 5e3:50:3e4;
czAmp = czAmp*0 + 1.7e4;
data = NaN(1,numel(czAmp));

figure();
ax = axes();

for ii = 1:numel(czAmp)
    aczSettings.amp = czAmp(ii);

    q1.aczSettings = aczSettings;
    q2.aczSettings = aczSettings;

    CZ = gate.CZ(q1,q2);
    proc =  X1*CZ;
%     proc =  X1;

    R = resonatorReadout_ss(q1);
    R.state = 1;
    R.delay = proc.length;

    proc.Run();
    data(ii) = R();
    
    % plot(ax,czAmp, data);
    plot(ax, data);
    drawnow;
end