function singleQGates_Q1_Q12_allX_noCal()
% data_taking.yulin.sampling.singleQGates_Q2_Q11_allI()

import sqc.util.getQSettings
datafile = ['E:\data\20180216_12bit\sampling\singleQ\','singleQ_Q2_Q11_',datestr(now,'yymmddTHHMMSS'),'.mat'];
notes = '';

hf = qes.ui.qosFigure('singleQ',false);
ax = axes('parent',hf);
circuit = {'X','X','X','X','X','X','X','X','X','X','X','X'};
opQs = {'q1','q2','q3','q4','q5','q6','q7','q8','q9','q10','q11','q12'};
measureQs = {'q1','q2','q3','q4','q5','q6','q7','q8','q9','q10','q11','q12'};
stats = 5000;
measureType = 'Mzj'; % default 'Mzj', z projection

numTakes = 20;
numRunsPerTake = 20;
P = cell(1,numTakes);
Events = cell(1,numTakes);
Fidelities = cell(1,numTakes);
for ii = 1:numTakes
    Ei = [];
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
