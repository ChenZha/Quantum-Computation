function [T2,T2_err,detuningf,detuningf_err]=reFitRamsey(path,fitType,T1,dosave,doplot)
% example:
% [T2,T2_err,detuningf,detuningf_err]=toolbox.data_tool.fitting.reFitRamsey('',2,10,1,1)

if nargin<5
    dosave=true;
    doplot=true;
end
if nargin<3 && nargin>0
    if fitType==2
        warning('No T1 provided. Use fit Type 1 instead.')
    end
    fitType=1;
    T1=10;
end
if nargin==0
    try
        Data=evalin('base','Data');
        Config=evalin('base','Config');
        Ramsey_data0=Data{1,1};
        Ramsey_time=Config.args.time/2;
        fcn=Config.fcn;
        qubit=Config.args.qubit;
        detuning=Config.args.detuning;
        dosave=false; % No path provided thus cannot save
    catch
        Ramsey_data0=evalin('base','y');
        Ramsey_time=evalin('base','x')/2;
        fcn='';
        qubit='';
        detuning=0;
        dosave=false; % No path provided thus cannot save
    end
    fitType=1;
    T1=10;
    warning('In this mode no T1 are provided. Use fit Type 1.')
elseif ischar(path)
    e=load(path);
    Ramsey_data0=e.Data{1,1};
    Ramsey_time=e.Config.args.time/2;
    fcn=e.Config.fcn;
    detuning=e.Config.args.detuning;
    qubit=e.Config.args.qubit;
    if nargin<4
        dosave=e.Config.args.save;
    end
end
loopn=size(Ramsey_data0,1);
T2=NaN(1,loopn);
T2_err=NaN(1,loopn);
detuningf=NaN(1,loopn);
detuningf_err=NaN(1,loopn);
for II=1:loopn
    Ramsey_data=Ramsey_data0(II,:);
    [T2(II),T2_err(II),detuningf(II),fitramsey_time,fitramsey_data,detuningf_err(II)]=toolbox.data_tool.fitting.ramseyFit(Ramsey_time,Ramsey_data,fitType,T1*1000);
end
if doplot
    if size(Ramsey_data0,1)==1
        hf=figure(17);
        plot(Ramsey_time,Ramsey_data,'o',fitramsey_time,fitramsey_data,'linewidth',2,'MarkerFaceColor','r');
        title([qubit ' T_2^*=' num2str(T2/1e3,'%.2f') '\pm' num2str(T2_err/1e3,'%.1f') 'us, \Delta f=' num2str(1e3*detuningf,'%.2f') '\pm' num2str(1e3*detuningf_err,'%.2f') 'MHz'])
        xlabel('Pulse delay (ns)');
        ylabel('P');
    else
        hf=figure(17);
        h1=errorbar(detuning,T2/1e3,T2_err/1e3);
        ylim([0,Ramsey_time(end)*2/1e3])
        ylabel('T2* (us)')
        if strcmp(fcn,'data_taking.public.xmon.ramsey_dz')
            xlabel('Detune Amp')
        else
            xlabel('Detuning Freq (Hz)')
        end
        title([qubit ' Fit average T_2^* = ' num2str(mean(T2)/1e3,'%.2f') '\pm' num2str(std(T2)/1e3,'%.1f') ' us'])
        set(h1,'LineStyle','-','Marker','o','MarkerFaceColor','b')
    end
    warning('In this mode no readout parameter provided, thus no errorbar!')
    if dosave
        refile=replace(path,'.mat','_fit.fig');
        saveas(hf,refile);
    end
end
end