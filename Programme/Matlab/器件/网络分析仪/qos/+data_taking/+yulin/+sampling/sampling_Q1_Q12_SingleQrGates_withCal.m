function sampling_Q1_Q12_SingleQrGates_withCal()
% data_taking.yulin.sampling.sampling_Q1_Q12_SingleQrGates_withCal()

import sqc.util.getQSettings
datafile = ['E:\data\20180216_12bit\sampling\sampling\','sampling_Q1_Q12_singleQ_',datestr(now,'yymmddTHHMMSS'),'.mat'];
notes = '';

hf = qes.ui.qosFigure('singleQ',false);
ax = axes('parent',hf);


opQs = {'q1','q2','q3','q4','q5','q6','q7','q8','q9','q10','q11','q12'};
measureQs = opQs;
% G1 = Gates(randi(numel(Gates),1,numel(opQs)));
% G2 = Gates(randi(numel(Gates),1,numel(opQs)));

    function rgz = ZRnd()
        rgz = sprintf('Rz(%0.6f)',(2*rand()-1)*pi);
    end

G1 = {'Y2m','Y2m','Y2m','Y2m','Y2m','Y2m','Y2m','Y2m','Y2m','Y2m','Y2m','Y2m'};
G2 = {ZRnd(),ZRnd(),ZRnd(),ZRnd(),ZRnd(),ZRnd(),ZRnd(),ZRnd(),ZRnd(),ZRnd(),ZRnd(),ZRnd();...
    'H','H','H','H','H','H','H','H','H','H','H','H'};

circuit = [G1;G2];

stats = 5000;
measureType = 'Mzj'; % default 'Mzj', z projection

numTakes = 20;
numRunsPerTake = 20;
P = cell(1,numTakes);
Events = cell(1,numTakes);
Fidelities = cell(1,numTakes);
for ii = 1:numTakes
    Ei = [];
%     data_taking.qCloud.calibrationsXLD180322.calibration_lvl3();
    for jj = 1:numRunsPerTake
        [result, singleShotEvents, sequenceSamples, ~] =...
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
    save(datafile,'P','Events','Fidelities','sequenceSamples','circuit','notes');
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
