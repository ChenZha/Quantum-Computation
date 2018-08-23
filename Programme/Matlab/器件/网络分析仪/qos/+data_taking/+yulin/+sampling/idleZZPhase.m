% idle zz coupling
q = 'q1';
setQSettings('r_avg',1000);
tuneup.correctf01byPhase('qubits',q,'delayTime',1e-6,'gui',true,'save',true,'doCorrection',true,'iter',true);
tuneup.iq2prob_01('qubits',q,'numSamples',2e4,'gui',true,'save',true);
% tuneup.xyGateAmpTuner('qubit',q,'gateTyp','X/2','AE',true,'AENumPi',41,'gui',true,'save',true);
% tuneup.iq2prob_01('qubits',q,'numSamples',2e4,'gui',true,'save',true);
%%
delay = 0:50:1500;
phase = nan(1,numel(delay));
datafile = ['E:\data\20180216_12bit\sampling\idlezz\','q2_q3_idlezz_',datestr(now,'yymmddTHHMMSS'),'.mat'];
notes = 'r_avg=3000';
hf = qes.ui.qosFigure('idle zz',false);
ax = axes('parent',hf);
opQs = {'q2','q1'};
measureQs = {'q1'};
stats = 3000;
measureType = 'Mphase'; % default 'Mzj', z projection
noConcurrentCZ = false; % default false
for  ii = 1:numel(delay)
    circuit0 = {'','Y2p';
                sprintf('I(%d)',delay(ii)),''};
    circuit1 = {'X','Y2p';
                sprintf('I(%d)',delay(ii)),''};
    [phase0, ~, ~, ~] = sqc.util.runCircuit(circuit0,opQs,measureQs,stats,measureType, noConcurrentCZ);
    [phase1, ~, ~, ~] = sqc.util.runCircuit(circuit1,opQs,measureQs,stats,measureType, noConcurrentCZ);
    dp = phase1 - phase0;
    if ii == 1
        if dp < pi
            offset = 2*pi;
        elseif dp > pi
            offset = -2*pi;
        else
            offset = 0;
        end
    end
        
    phase(ii) = rem(phase1 - phase0+offset,2*pi);
    save(datafile,'delay','phase','notes');
    try
        plot(ax,delay/2,unwrap(phase),'-s');
        xlabel(ax,'idle time(ns)');
        ylabel(ax,'phase(rad)');
    catch
        hf = qes.ui.qosFigure('idle zz phase',false);
        ax = axes('parent',hf);
    end
    drawnow;
end