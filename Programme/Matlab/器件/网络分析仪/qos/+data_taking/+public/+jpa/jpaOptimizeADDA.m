function varargout = jpaOptimizeADDA(varargin)

optype=2;
args = qes.util.processArgs(varargin,{'signalSbFreq',[],'signalFc',[],'optFreqs',[],'gui',false,'notes','','save',false});

QS = qes.qSettings.GetInstance();
dataPath = QS.loadSSettings('data_path');
sessionSettings = QS.loadSSettings;
hwSettings = QS.loadHwSettings;

freq_org=sqc.util.getQSettings('pumpFreq','impa1');
power_org=sqc.util.getQSettings('pumpPower','impa1');
bias_org=sqc.util.getQSettings('biasAmp','impa1');

if ~isempty(args.optFreqs)
    QRFreqs=args.optFreqs;
else
    QRFreqs=sqc.util.getQSettings('r_freq');
end
if isempty(QRFreqs)
    QRFreqs=6.5e9:0.03e9:6.9e9; % Default optimize freqs
end
if isempty(args.signalFreq)
    % QRFreqss=[QRFreqs-2e6,QRFreqs-1e6,QRFreqs,QRFreqs+1e6,QRFreqs+2e6];
    QRFreqss=[QRFreqs-1e6,QRFreqs+1e6];
    QRFreqss=QRFreqss';
    QRFreqss=QRFreqss(:);
    QRFreqss=QRFreqss';
    args.signalFreq=QRFreqss;
end

data0=data_taking.public.jpa.jpaBringupADDA('jpa',args.jpa,...
    'signalAmp',args.signalAmp,'signalFreq',args.signalFreq,...
    'signalPower',args.signalPower,'signalSbFreq',args.signalSbFreq,'signalFc',args.signalFc,...
    'signalLn',args.signalLn,'rAvg',args.rAvg,...
    'pumpAmp',args.pumpAmp,...
    'pumpFreq',2e9,'pumpPower',-50,...
    'biasAmp',args.biasAmp(1),...
    'notes','','gui',false,'save',false);


    function f=singleAmp(param)
        data1=data_taking.public.jpa.jpaBringupADDA('jpa',args.jpa,...
            'signalAmp',args.signalAmp,'signalFreq',args.signalFreq,...
            'signalPower',args.signalPower,'signalSbFreq',args.signalSbFreq,'signalFc',args.signalFc,...
            'signalLn',args.signalLn,'rAvg',args.rAvg,...
            'pumpAmp',args.pumpAmp,...
            'pumpFreq',param(1),'pumpPower',param(2),...
            'biasAmp',param(3),...
            'notes','','gui',false,'save',false);
        
        amplif=log10(abs(cell2mat(data1.data{1,1})))*20-log10(abs(cell2mat(data0.data{1,1})))*20;
        freqs=args.signalFreq;
        
        QRFreqs1=QRFreqs+1e6;
        locals1=zeros(1,numel(QRFreqs1));
        for ii=1:numel(QRFreqs1)
            [~,locals1(ii)]=min(abs(freqs-QRFreqs1(ii)));
        end
        
        QRFreqs2=QRFreqs-1e6;
        locals2=zeros(1,numel(QRFreqs2));
        for ii=1:numel(QRFreqs2)
            [~,locals2(ii)]=min(abs(freqs-QRFreqs2(ii)));
        end
        
        QRGains=(amplif(locals1)+amplif(locals2))/2;

        if optype==1
            f=-sum(QRGains);
        else
            f=-min(QRGains);
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
tolY = [5e-2];

maxFEval = 200;

[optParams, x_trace, y_trace, n_feval] = qes.util.NelderMead(@singleAmp, x0, tolX, tolY, maxFEval, axs);
fval = y_trace(end);
fval0 = singleAmp([freq_org,power_org,bias_org]);

if fval > fval0
    warning('Optimization failed: final fidelity worse than initial fidelity, registry not updated.');
else
    QS.saveSSettings({args.jpa,'pumpFreq'},round(optParams(1)));
    QS.saveSSettings({args.jpa,'pumpPower'},round(100*optParams(2))/100);
    QS.saveSSettings({args.jpa,'biasAmp'},round(optParams(3)));
end

TimeStamp = datestr(now,'_yymmddTHHMMSS_');
dataFileName = ['JPAOptimizeADDA',TimeStamp,'.mat'];
figFileName = ['JPAOptimizeADDA',TimeStamp,'.fig'];
notes = 'JPA Optimize ADDA';
save(fullfile(dataPath,dataFileName),'optParams','x_trace','y_trace','n_feval','sessionSettings','hwSettings','notes');
try
    saveas(h,fullfile(dataPath,figFileName));
end
varargout{1}=optParams;
end