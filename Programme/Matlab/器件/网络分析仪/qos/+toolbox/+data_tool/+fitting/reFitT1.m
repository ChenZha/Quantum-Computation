function [T1,bias]=reFitT1(path,fitType,dosave,doplot,p)
if nargin<5
    p=[];
end
if nargin<4
    dosave=true;
    doplot=true;
end
if nargin<2 && nargin>0
    if fitType==1
        warning(' Use fit Type 1.')
    end
    fitType=1;
    T1=10;
end
if ischar(p)
    p=sqc.util.getQSettings('zpls_amp2f01',p);
end
if nargin==0
    try
        Data=evalin('base','Data');
        Config=evalin('base','Config');
        data=Data{1,1};
        T1_data=NaN(size(data,2)/2,size(data,1));
        for ii=1:size(data,2)/2
            T1_data(ii,:)=(data(:,2*ii-1)-data(:,2*ii))';
        end
        T1_time=Config.args.time/2;
        bias=Config.args.biasAmp;
        if ~isempty(p)
            bias=polyval(p,bias);
        end
        qubit=Config.args.readoutQubit;
        fcn=Config.fcn;
        dosave=false; % No path provided thus cannot save
    catch
        bias=evalin('base','x');
        if ~isempty(p)
            bias=polyval(p,bias);
        end
        T1_data=evalin('base','z');
        T1_time=evalin('base','y')/2;
        qubit='';
        fcn='';
        dosave=false; % No path provided thus cannot save
    end
    fitType=1;
    warning('In this mode use fit Type 1 only.')
else
    e=load(path);
    data=cell2mat(e.Data{1,1}');
    T1_data=NaN(size(data,2)/2,size(data,1));
    for ii=1:size(data,2)/2
        T1_data(ii,:)=(data(:,2*ii-1)-data(:,2*ii))';
    end
    T1_time=e.Config.args.time/2;
    fcn=e.Config.fcn;
    qubit=e.Config.args.readoutQubit;
    if nargin<3
        dosave=e.Config.args.save;
    end
    bias=e.Config.args.biasAmp;
    if ~isempty(p)
        bias=polyval(p,bias);
    end
end

if length(bias)==1
    [T1,T1_err,fitT1_time,fitT1_data]=toolbox.data_tool.fitting.t1Fit(T1_time,T1_data,fitType);
    
else
    for ii = 1:length(bias)
        [T1(ii),T1_err(ii),~,~]=toolbox.data_tool.fitting.t1Fit(T1_time,T1_data(ii,:),fitType);
    end
    
end
if doplot
    if size(T1_data,1)==1
        hf=figure;
        plot(T1_time,T1_data,'.','MarkerFaceColor','b','LineWidth',1);
        hold on;
        plot(fitT1_time,fitT1_data,'LineWidth',1.5,'Color','r');
        title([qubit ' T_1 = ' num2str(T1/1e3,'%.2f') '\pm' num2str(T1_err/1e3,'%.2f') ' us'])
        xlabel('Pulse delay (ns)');
        ylabel('diff(P<1>)')
    else
        hf=figure;
        h=pcolor(bias,T1_time,T1_data');
        set(h,'edgeColor','none')
        hold on;
        errorbar(bias,T1,T1_err,'ro','MarkerSize',5,'MarkerFaceColor',[1,1,1]);
        hold off;
        set(gca,'YDir','normal');
        if ~isempty(p)
            xlabel('Freq (Hz)');
        else
            xlabel('Z Bias');
        end
        ylabel('Time (ns)');
        title([qubit ' Fit average T_1 = ' num2str(mean(T1/1e3),'%.2f') ' us'])
        colorbar;
        caxis([0,1]);
        hh=figure;
        plot(bias,T1,'-*');
        xlabel([qubit ' Freq'])
        ylabel('T1')
        title([qubit ' Fit average T_1 = ' num2str(mean(T1/1e3),'%.2f') ' us'])
%         ylabel('\gamma_1 (1/T1)')
    end
    warning('In this mode no readout parameter provided, thus no errorbar!')
    if dosave
        refile=replace(path,'.mat','_fit.fig');
        saveas(hf,refile);
        refile=replace(path,'.mat','2_fit.fig');
        saveas(hh,refile);
    end
end
end