function sampling_Q1_Q12_rGates_withCal()
% data_taking.ming.sampling.sampling_Q1_Q12_rGates_withCal()

import sqc.util.getQSettings
notes = '';

hf = qes.ui.qosFigure('sampling Q1 Q12',false);
ax = axes('parent',hf);

opQs = {'q1','q2','q3','q4','q5','q6','q7','q8','q9','q10','q11','q12'};
qubits=opQs;
measureQs = opQs;
% G1 = Gates(randi(numel(Gates),1,numel(opQs)));
% G2 = Gates(randi(numel(Gates),1,numel(opQs)));

    function rgz = ZRnd()
        rgz = sprintf('Rz(%0.6f)',(2*rand()-1)*pi);
    end

G1 = {'Y2m','Y2m','Y2m','Y2m','Y2m','Y2m','Y2m','Y2m','Y2m','Y2m','Y2m','Y2m'};
G2 = {ZRnd(),ZRnd(),ZRnd(),ZRnd(),ZRnd(),ZRnd(),ZRnd(),ZRnd(),ZRnd(),ZRnd(),ZRnd(),ZRnd();...
    'H','H','H','H','H','H','H','H','H','H','H','H'};
G3 = {'Y2p','Y2p','Y2p','Y2p','Y2p','Y2p','Y2p','Y2p','Y2p','Y2p','Y2p','Y2p'};

circuitLayer1 = {'','CZ','CZ','','CZ','CZ','','CZ','CZ','','CZ','CZ'};
circuitLayer2 = {'CZ','CZ','','CZ','CZ','','CZ','CZ','','CZ','CZ',''};
circuitLayer3 = {'','','CZ','CZ','','CZ','CZ','','CZ','CZ','',''};

circuits = [G1;circuitLayer1;circuitLayer2;circuitLayer3;G2];

stats = 5000;
measureType = 'Mzj'; % default 'Mzj', z projection

for mm=[1:4 6]
    circuit=circuits(1:mm,:);
    if mm>=2 || mm<=4
        circuit=[circuit;G3];
    end
    numTakes = 20;
    numRunsPerTake = 20;
    P = cell(1,numTakes);
    Events = cell(1,numTakes);
    Fidelities = cell(1,numTakes);
    for ii = 1:numTakes
        Ei = [];
        data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0);% calibration readout fidelity
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
        
        datafile = ['E:\data\20180216_12bit\sampling\sampling\','sampling_Q1_Q12_L',num2str(mm),'_',datestr(now,'yymmddTHHMMSS'),'.mat'];
        save(datafile,'P','Events','Fidelities','circuit','sequenceSamples','notes');
        try
            if ii == 1
                Pavg = P{1};
            else
                Pavg = Pavg + P{ii};
            end
            bar(ax,Pavg/ii);
            xlabel(ax,'state');
            ylabel(ax,'P');
            title(['Layer ' num2str(mm)])
        catch
            hf = qes.ui.qosFigure('',false);
            ax = axes('parent',hf);
        end
        drawnow;
        saveas(hf,replace(datafile,'mat','fig'))
    end
end
end
