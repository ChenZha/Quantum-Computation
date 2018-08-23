function varargout = jpaGainNA(varargin)

args = qes.util.processArgs(varargin,{'gui',false,'notes','','save',false});

dataFileName = ['jpaGainNA_',datestr(now,'_yymmddTHHMMSS_'),'.mat'];
QS = qes.qSettings.GetInstance();
dataPath = QS.loadSSettings('data_path');
sessionSettings = QS.loadSSettings;
hwSettings = QS.loadHwSettings;

data0=data_taking.public.jpa.jpaBringupNA('jpa',args.jpa,...
    'startFreq',args.startFreq,'stopFreq',args.stopFreq,...
    'numFreqPts',args.numFreqPts,'avgcounts',args.avgcounts,...
    'NAPower',args.NAPower,'bandwidth',args.bandwidth,...
    'pumpFreq',2e9,'pumpPower',-50,...
    'biasAmp',args.biasAmp,...
    'notes','JPA OFF','gui',false,'save',false);
data1=data_taking.public.jpa.jpaBringupNA('jpa',args.jpa,...
    'startFreq',args.startFreq,'stopFreq',args.stopFreq,...
    'numFreqPts',args.numFreqPts,'avgcounts',args.avgcounts,...
    'NAPower',args.NAPower,'bandwidth',args.bandwidth,...
    'pumpFreq',args.pumpFreq,'pumpPower',args.pumpPower,...
    'biasAmp',args.biasAmp,...
    'notes','JPA ON','gui',false,'save',false);

amplif=log10(abs(data1.data{1,1}{1,1}(1,:)))*20-log10(abs(data0.data{1,1}{1,1}(1,:)))*20;
freqs=linspace(args.startFreq,args.stopFreq,args.numFreqPts);

QRFreqs1=sqc.util.getQSettings('r_freq')+1e6;
freqs=linspace(args.startFreq,args.stopFreq,args.numFreqPts);
locals1=zeros(1,numel(QRFreqs1));
for ii=1:numel(QRFreqs1)
    [~,locals1(ii)]=min(abs(freqs-QRFreqs1(ii)));
end

QRFreqs2=sqc.util.getQSettings('r_freq')-1e6;
freqs=linspace(args.startFreq,args.stopFreq,args.numFreqPts);
locals2=zeros(1,numel(QRFreqs2));
for ii=1:numel(QRFreqs2)
    [~,locals2(ii)]=min(abs(freqs-QRFreqs2(ii)));
end

QRFreqs=(QRFreqs1+QRFreqs2)/2;
QRGains=(amplif(locals1)+amplif(locals2))/2;

if args.gui
    h = qes.ui.qosFigure(sprintf('JPA ON/OFF Comparation'),10);
    ax = axes('parent',h);
    plot(ax,freqs,amplif,'-',QRFreqs,QRGains,'o')
    xlabel(ax,'Freq (Hz)')
    ylabel(ax,'Gain (dB)')
    title(ax,['JPA On/Off @ bias=' num2str(args.biasAmp,'%.2e') ', P=' num2str(args.pumpPower) 'dBm, f=' num2str(args.pumpFreq) 'Hz'])
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