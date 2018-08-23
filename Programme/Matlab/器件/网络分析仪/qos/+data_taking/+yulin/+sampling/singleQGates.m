function singleQGates()

datafile = ['E:\data\20180216_12bit\sampling\singleQ\','singleQ_',datestr(now,'yymmddTHHMMSS'),'.mat'];
notes = 'r_avg=3000;Run immediatly after calibrations, No calibration between takes.';
hf = qes.ui.qosFigure('singleQ',false);
ax = axes('parent',hf);
circuit1 = {'','CZ','CZ';
            'CZ','CZ',''};
 opQs = {'q10','q11','q12'};
 measureQs = {'q10','q11','q12'};
 stats = 3000;
 measureType = 'Mptomo'; % default 'Mzj', z projection
 noConcurrentCZ = false; % default false
tic
while 1
    Time(end+1) = toc;
    [result, ~, ~, ~] = sqc.util.runCircuit(circuit,opQs,measureQs,stats,measureType, noConcurrentCZ);
    CZTomoData{end+1} = result;
    Chi{end+1} = sqc.qfcns.processTomoData2Chi(CZTomoData{end});
    fidelity(end+1)  = real(trace(Chi{end}*Chi{1}));
    save(datafile,'Time','CZTomoData','Chi','fidelity','circuit','notes');
    try
        plot(ax,Time/60,fidelity,'-s');
        xlabel(ax,'Time(min.)');
        ylabel(ax,'Trace(\chi_{i}\chi_{1})');
    catch
        hf = qes.ui.qosFigure('2 CZ Chi Stability',false);
        ax = axes('parent',hf);
    end
    drawnow;
    if Time(end) > TimeSpan
        break;
    end
%     for ii = 1:numel(qubits)
%         q = qubits{ii};
%     %     tuneup.correctf01byPhase('qubits',q,'delayTime',1e-6,'gui',true,'save',true,'doCorrection',true,'iter',true);
%         tuneup.iq2prob_01('qubits',q,'numSamples',2e4,'gui',true,'save',true);
%     end
end

end
