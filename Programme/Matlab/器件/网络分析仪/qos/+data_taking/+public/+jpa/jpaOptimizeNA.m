function varargout = jpaOptimizeNA(varargin)

optype=2;
args = qes.util.processArgs(varargin,{'gui',false,'notes','','save',false});

QS = qes.qSettings.GetInstance();
dataPath = QS.loadSSettings('data_path');
sessionSettings = QS.loadSSettings;
hwSettings = QS.loadHwSettings;

% QRFreqs=sqc.util.getQSettings('r_freq');
% freqs=linspace(args.startFreq,args.stopFreq,args.numFreqPts);
% locals=zeros(1,numel(QRFreqs));
% for ii=1:numel(QRFreqs)
%     [~,locals(ii)]=min(abs(freqs-QRFreqs(ii)));
% end

    function f=singleAmp(param)
        [~,~,Ramplif,~]=data_taking.public.jpa.jpaGainNA('jpa',args.jpa,...
            'startFreq',args.startFreq,'stopFreq',args.stopFreq,...
            'numFreqPts',args.numFreqPts,'avgcounts',args.avgcounts,...
            'NAPower',args.NAPower,'bandwidth',args.bandwidth,...
            'pumpFreq',param(1),'pumpPower',param(2),...
            'biasAmp',param(3),...
            'notes','JPA Optimize Auto','gui',false,'save',false);
        if optype==1
            f=-sum(Ramplif);
        else
            f=-min(Ramplif);
        end
    end

h = qes.ui.qosFigure(sprintf('JPA Optimizer'),false);
axs(1) = subplot(2,2,1,'Parent',h);
axs(2) = subplot(2,2,2);
axs(3) = subplot(2,2,3);
axs(4) = subplot(2,2,4);

x0 = [min(args.pumpFreq),min(args.pumpPower),min(args.biasAmp);...
    max(args.pumpFreq),min(args.pumpPower),min(args.biasAmp);...
    max(args.pumpFreq),max(args.pumpPower),min(args.biasAmp);...
    max(args.pumpFreq),max(args.pumpPower),max(args.biasAmp)];

tolX = [1e5,0.05,10];
tolY = [1e-2];

maxFEval = 200;

[optParams, x_trace, y_trace, n_feval] = qes.util.NelderMead(@singleAmp, x0, tolX, tolY, maxFEval, axs);
fval = y_trace(end);
fval0 = y_trace(1);

if fval > fval0
    error('Optimization failed: final fidelity worse than initial fidelity, registry not updated.');
end

% opts = optimset('Display','none','MaxIter',obj.MAX_ITER_NUM,'TolX',0.2,'TolFun',0.1,'PlotFcns',{@optimplotfval});%,'PlotFcns',''); % current value and history
% lb = [-obj.awg.vpp/10, -obj.awg.vpp/10];
% ub = [obj.awg.vpp/10, obj.awg.vpp/10];
% xsol = qes.util.fminsearchbnd(f.fcn,[0,0],lb,ub,opts);
% x = xsol(1);
% y = xsol(2);

QS.saveSSettings({args.jpa,'pumpFreq'},round(optParams(1)));
QS.saveSSettings({args.jpa,'pumpPower'},round(100*optParams(2))/100);
QS.saveSSettings({args.jpa,'biasAmp'},round(optParams(3)));

TimeStamp = datestr(now,'_yymmddTHHMMSS_');
dataFileName = ['JPAOptimize',TimeStamp,'.mat'];
figFileName = ['JPAOptimize',TimeStamp,'.fig'];
notes = 'JPA Optimize';
save(fullfile(dataPath,dataFileName),'optParams','x_trace','y_trace','n_feval','sessionSettings','hwSettings','notes');
try
    saveas(h,fullfile(dataPath,figFileName));
end
    varargout{1}=optParams;
end