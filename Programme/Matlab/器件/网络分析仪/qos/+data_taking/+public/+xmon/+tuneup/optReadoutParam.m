function optReadoutParam(varargin)

import qes.*
import data_taking.public.util.getQubits

args = util.processArgs(varargin,{'optrange',0.7,'optnum',100,'gui',true,'save',true,'tunerf',false});
q = data_taking.public.util.getQubits(args,{'qubits'});
qubit = q.name;

QS = qes.qSettings.GetInstance();
dataPath = QS.loadSSettings('data_path');
sessionSettings = QS.loadSSettings;
hwSettings = QS.loadHwSettings;

r_amp_org=q.r_amp;
r_ln_org=q.r_ln;

    function tt=getMaxfid(param)
        ramp=round(param(1));
        if ramp>32000
            ramp=32000;
        elseif ramp<500
            ramp=500;
        end
        rln=round(param(2));
        if rln>10000
            rln=10000;
        elseif rln<200
            rln=200;
        end
        sqc.util.setQSettings('r_amp',ramp, qubit);
        sqc.util.setQSettings('r_ln',rln, qubit);
        [~,~,tt]=data_taking.public.xmon.tuneup.iq2prob_01('qubits',qubit,'numSamples',1e4,...
            'gui',false,'save',false);
        tt=-tt;
    end

h = qes.ui.qosFigure(sprintf( '%s Readout Optimizer',qubit),false);
axs(1) = subplot(2,2,1,'Parent',h);
axs(2) = subplot(2,2,2);
axs(3) = subplot(2,2,[3,4]);

x0= [r_amp_org,r_ln_org];
x0 = [x0;x0.*diag([args.optrange,0])];
% x0 = [x0;x0.*diag([args.optrange,args.optrange])];

tolX = [10,50];
tolY = [0.7e-2];

maxFEval = args.optnum;

[optParams, x_trace, y_trace, n_feval] = qes.util.NelderMead(@getMaxfid, x0, tolX, tolY, maxFEval, axs);
fval = y_trace(end);
fval0 = getMaxfid([r_amp_org,r_ln_org]);

if fval > fval0
    warning('Optimization failed: final fidelity worse than initial fidelity, registry not updated.');
    sqc.util.setQSettings('r_amp',r_amp_org, qubit);
    sqc.util.setQSettings('r_ln',r_ln_org, qubit);
else
    ramp=round(optParams(1));
    if ramp>32000
        ramp=32000;
    elseif ramp<100
        ramp=100;
    end
    rln=round(optParams(2));
    if rln>20000
        rln=20000;
    elseif rln<200
        rln=200;
    end
    sqc.util.setQSettings('r_amp',ramp, qubit);
    sqc.util.setQSettings('r_ln',rln, qubit);
end


data_taking.public.xmon.tuneup.iq2prob_01('qubits',qubit,'numSamples',2e4,...
    'gui',true,'save',true);

TimeStamp = datestr(now,'_yymmddTHHMMSS_');
dataFileName = [qubit ' optReadoutParams',TimeStamp,'.mat'];
figFileName = [qubit ' optReadoutParams',TimeStamp,'.fig'];
notes = [qubit ' optReadoutParams ' ];
save(fullfile(dataPath,dataFileName),'optParams','x_trace','y_trace','n_feval','sessionSettings','hwSettings','notes');
try
    saveas(h,fullfile(dataPath,figFileName));
end
varargout{1}=optParams;
end