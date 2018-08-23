circuit = {'X',''};
opQs = {'q1','q2'};
measureQs = {'q2','q1'};
stats = 3000;
measureType = 'Mzj'; % default 'Mzj', z projection
noConcurrentCZ = false; % default false
[result, singleShotEvents, sequenceSamples, finalCircuit] =...
    sqc.util.runCircuit(circuit,opQs,measureQs,stats,measureType, noConcurrentCZ);
figure();bar(result);

%% xy drive crosstalk
opQs = qubits;
measureQs = qubits;
stats = 2000;
measureType = 'Mzj'; % default 'Mzj', z projection
numPi = 10;
for kk=1:numel(opQs)
    for jj=1:numel(measureQs)
        if ~strcmp(opQs{kk},measureQs{jj})
        data = nan(1,numPi);
        x = 1:numPi;
        %  tuneup.iq2prob_01('qubits',measureQs{1},'numSamples',2e4,'gui',true,'save',true);
        figure();
        circuit = {};
        results=NaN(numPi,1);
        for ii = 1:numPi
            circuit = [circuit;'X'];
            [result, ~, ~, ~] = sqc.util.runCircuit(circuit,opQs(kk),measureQs(jj),stats,measureType);
            results(ii)=result(2);
            data(ii) = result(2);
            plot(x,data,'-s');
            xlabel('number of \pi pulses');
            ylabel('P|1>');
            title([opQs{kk},' -> ', measureQs{jj}, ' xy cross talk']);
            drawnow;
        end
        if max(abs(results))>0.05
            disp([opQs{kk},measureQs{jj},num2str(max(abs(results)))])
        else
            close
        end
        end
    end
end