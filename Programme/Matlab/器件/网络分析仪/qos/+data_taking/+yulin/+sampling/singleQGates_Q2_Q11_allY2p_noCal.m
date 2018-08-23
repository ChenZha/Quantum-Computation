function singleQGates_Q2_Q11_allY2p_noCal()
% data_taking.yulin.sampling.singleQGates_Q2_Q11_allI()

import sqc.util.getQSettings
datafile = ['E:\data\20180216_12bit\sampling\singleQ\','singleQ_Q2_Q11_',datestr(now,'yymmddTHHMMSS'),'.mat'];
notes = '';

hf = qes.ui.qosFigure('singleQ',false);
ax = axes('parent',hf);
circuit = {'Y2p','Y2p','Y2p','Y2p','Y2p','XY2p','Y2p','Y2p','Y2p','Y2p'};
opQs = {'q2','q3','q4','q5','q6','q7','q8','q9','q10','q11'};
measureQs = {'q2','q3','q4','q5','q6','q7','q8','q9','q10','q11'};
stats = 5000;
measureType = 'Mzj'; % default 'Mzj', z projection

QS = qes.qSettings.GetInstance();

hf = qes.ui.qosFigure('',false);
ax = axes('parent',hf);

numTakes = 20;
numRunsPerTake = 20;
P = cell(1,numTakes);
Events = cell(1,numTakes);
Fidelities = cell(1,numTakes);
for ii = 1:numTakes
    Ei = [];
%     data_taking.qCloud.calibrationsXLD180322.calibration_lvl3();
    for jj = 1:numRunsPerTake
        [result, singleShotEvents, ~, ~] =...
            sqc.util.runCircuit(circuit,opQs,measureQs,stats,measureType, false);
        if jj == 1
            Pi = result;
        else
            Pi = Pi + result;
        end
        Ei = [Ei,singleShotEvents];
    end
    P{ii} = Pi/numRunsPerTake;
    Events{ii} = Ei;
    Fidelities{ii} =  getQSettings('r_iq2prob_fidelity',measureQs);
    save(datafile,'P','Events','Fidelities','circuit','notes');
    try
        if ii == 1
            Pavg = P{1};
        else
            Pavg = Pavg + P{ii};
        end
        bar(ax,Pavg/ii);
        xlabel(ax,'state');
        ylabel(ax,'P');
    catch
        hf = qes.ui.qosFigure('',false);
        ax = axes('parent',hf);
    end
    drawnow;
end

end
