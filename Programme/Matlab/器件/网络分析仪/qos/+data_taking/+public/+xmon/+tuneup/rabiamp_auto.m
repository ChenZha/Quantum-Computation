function varargout = rabiamp_auto(varargin)
% GM, 20180422


fcn_name = 'data_taking.public.xmon.tuneup.rabiamp_auto'; % this and args will be saved with data
import qes.*
import sqc.*
import sqc.op.physical.*

args = util.processArgs(varargin,{'biasLonger',0,'driveTyp','X','dataTyp','P','detuning',0,...
    'xyDriveAmp',[0e4:500:3.2e4],'numPi',1,'r_avg',0,'gui',false,'notes','','save',true,'update',true});

varargout{1} = data_taking.public.xmon.rabi_amp1('qubit',args.qubit,'biasAmp',args.biasAmp,'biasLonger',args.biasLonger,...
    'xyDriveAmp',args.xyDriveAmp,'detuning',args.detuning,'driveTyp',args.driveTyp,'numPi',args.numPi,...
    'dataTyp',args.dataTyp,'gui',false,'save',args.save,'update',args.update);
if args.update
    f=@(a,x) a(1)+a(2)*sin(2*pi*x/a(3)+a(4));
    data=varargout{1,1}.data{1,1};
    x=varargout{1,1}.sweepvals{1,2}{1,1};
    if strcmp(args.dataTyp,'S21')
        data=cell2mat(data);
    end
    [~,locs]=max(data);
    a=[(max(data)+min(data))/2,(max(data)-min(data))/2,2*x(locs),-pi/2];
    [b,r,J]=nlinfit(x,data,f,a);
    [~,se] = toolbox.data_tool.nlparci(b,r,J,0.05);
    amp=round((pi/2-b(4))/2/pi*b(3));
%     amp=x(locs);
    amp_err=round(sqrt(se(4)^2*b(3)^2+se(3)^2*b(4)^2)/2/pi);
    amp0=sqc.util.getQSettings('g_XY2_amp',args.qubit);
    sqc.util.setQSettings('g_XY2_amp',amp,args.qubit)
    if args.gui
        hf = qes.ui.qosFigure(sprintf('Rabi Amp auto | %s', args.qubit),true,30);
        ax = axes('parent',hf);
        plot(ax,x,data);
		hold(ax,'on');
		plot(ax,[amp0,amp0],get(ax,'YLim'),'--','Color',[1,0.7,0.7]);
		plot(ax,[amp,amp],get(ax,'YLim'),'--r');
        xlabel(ax,'rabi amplitude');
        ylabel(ax,'P|1>');
        legend(ax,{'rabi','X/2 Amp(old)','X/2 Amp(new)'})
        title([args.qubit ' \pi amp = ' num2str(amp,'%d') ' \pm ' num2str(amp_err, '%d')])
        drawnow;
        QS = qes.qSettings.GetInstance();
        dataSvName = fullfile(QS.loadSSettings('data_path'),...
            ['rabiAmpauto_',args.qubit,'_',datestr(now,'yymmddTHHMMSS'),...
            num2str(ceil(99*rand(1,1)),'%0.0f'),'_.fig']);
        try
            saveas(hf,dataSvName);
        catch
            warning('saving figure failed.');
        end
    end
    
    
    varargout{2}=amp;
    varargout{3}=amp_err;
end
end