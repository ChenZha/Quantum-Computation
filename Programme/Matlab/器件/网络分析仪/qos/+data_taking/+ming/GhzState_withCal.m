opQs = {'q6','q7'};
measureQs = {'q6','q7'};
stats = 3000;
measureType = 'Mzj';
circuits = {'Y2p','Y2m';
             'CZ','CZ' ;
              '' ,'Y2p'};

M = {'Y2m','Y2m'};
% circuit=[circuits;M]
circuit=[circuits];

[result, singleShotEvents, sequenceSamples, ~] =sqc.util.runCircuit(circuit,...
                    opQs,measureQs,stats,measureType, false);