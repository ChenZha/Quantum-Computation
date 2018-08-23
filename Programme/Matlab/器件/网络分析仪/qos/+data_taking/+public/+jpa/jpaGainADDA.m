function varargout = jpaGainADDA(varargin)

args = qes.util.processArgs(varargin,{'optFreqs',[],'signalSbFreq',[],'signalFc',[],'gui',false,'notes','','save',false});

dataFileName = ['jpaGainADDA_',datestr(now,'_yymmddTHHMMSS_'),'.mat'];
QS = qes.qSettings.GetInstance();
dataPath = QS.loadSSettings('data_path');
sessionSettings = QS.loadSSettings;
hwSettings = QS.loadHwSettings;

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
    'biasAmp',args.biasAmp,...
    'notes','JPA OFF','gui',false,'save',false);
data1=data_taking.public.jpa.jpaBringupADDA('jpa',args.jpa,...
    'signalAmp',args.signalAmp,'signalFreq',args.signalFreq,...
    'signalPower',args.signalPower,'signalSbFreq',args.signalSbFreq,'signalFc',args.signalFc,...
    'signalLn',args.signalLn,'rAvg',args.rAvg,...
    'pumpAmp',args.pumpAmp,...
    'pumpFreq',args.pumpFreq,'pumpPower',args.pumpPower,...
    'biasAmp',args.biasAmp,...
    'notes','JPA ON','gui',false,'save',false);

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

if args.gui
    h = qes.ui.qosFigure(sprintf('JPA ON/OFF Comparation'),5);
    ax=subplot(2,1,1,'parent',h);
    plot(ax,freqs,amplif,'--.',QRFreqs,QRGains,'o')
    title(ax,['Min Gain = ',num2str(min(QRGains),'%.2f'), 'dB, Avg Gain = ',num2str(mean(QRGains),'%.2f') , 'dB'])
    ylabel(ax,'Gain (dB)')
    ax2=subplot(2,1,2,'parent',h);
    plot(ax2,freqs,log10(abs(cell2mat(data0.data{1,1})))*20,'*b',freqs,log10(abs(cell2mat(data1.data{1,1})))*20,'*r')
    title(ax2,['JPA On/Off @ bias=' num2str(args.biasAmp,'%.4e') ', P=' num2str(args.pumpPower,'%.2f') 'dBm, f=' num2str(args.pumpFreq,'%.7e') 'Hz'])
    xlabel(ax2,'Freq (Hz)')
    legend(ax2,'Off','On')
    if args.save
        save(fullfile(dataPath,dataFileName),'amplif','freqs','args','sessionSettings','hwSettings');
        try
            if args.gui && isgraphics(h)
                figFileName = [dataFileName(1:end-3),'fig'];
                saveas(h,fullfile(dataPath,figFileName));
            end
        catch
        end
    end
end

varargout{1}=amplif;
varargout{2}=freqs;
varargout{3}=QRGains;
varargout{4}=QRFreqs;
end