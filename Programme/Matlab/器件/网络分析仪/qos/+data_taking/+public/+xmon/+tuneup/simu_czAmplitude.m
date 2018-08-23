function varargout = simu_czAmplitude(varargin)
% <_o_> = czAmplitude('controlQ',_c&o_,'targetQ',_c&o_,'largeRange',<_b_>...
%       'notes',<_c_>,'gui',<_b_>,'save',<_b_>,'logger',<_o_>,...
%       'repeatIfOutOfBoundButClose',<_b_>)
% _f_: float
% _i_: integer
% _c_: char or char string
% _b_: boolean
% _o_: object
% a&b: default type is a, but type b is also acceptable
% []: can be an array, scalar also acceptable
% {}: must be a cell array
% <>: optional, for input arguments, assume the default value if not specified
% arguments order not important as long as they form correct pairs.

% Yulin Wu, 2017/10/14

    fcn_name = 'data_taking.public.xmon.tuneup.simu_czAmplitude';
    import qes.*
    import sqc.*
    import sqc.op.physical.*
    
    varargout = {};

    args = util.processArgs(varargin,{'gui',false,'notes','','save',true,...
        'largeRange',false,'repeatIfOutOfBoundButClose',false,'logger',[]});
    [qc,qt] = data_taking.public.util.getQubits(args,{'controlQ','targetQ'});
    
    aczSettingsKey = sprintf('%s_%s',qc.name,qt.name);
    QS = qes.qSettings.GetInstance();
    scz = QS.loadSSettings({'shared','g_cz',aczSettingsKey});
    
	czAmp0 = scz.amp;
    if args.largeRange
        czAmp= round(scz.amp*linspace(0.95,1.05,30));
    else
        czAmp= round(scz.amp*linspace(0.995,1.005,30));
    end
%     try
        acz1= data_taking.public.xmon.simu_acz_ampLength('controlQ',qc,'targetQ',qt,...
           'dataTyp','Phase',...
           'czLength',scz.aczLn,'czAmp',czAmp,'cState','1',...
           'notes','','gui',false,'save',false);
        acz0= data_taking.public.xmon.simu_acz_ampLength('controlQ',qc,'targetQ',qt,...
           'dataTyp','Phase',...
           'czLength',scz.aczLn,'czAmp',czAmp,'cState','0',...
           'notes','','gui',false,'save',false);
%     catch ME
%         if ~isempty(args.logger)
%             args.logger.error('QOS_czAmplitude:dataTakingError',ME.message);
%         end
%         throw(ME);
%     end
   
    cz0data=unwrap(acz0.data{1,1});
    cz1data=unwrap(acz1.data{1,1});
    dp = unwrap(cz1data - cz0data);
    cz0data = cz0data/pi;
    cz1data = cz1data/pi;
    dp = dp/pi;
    fdp = polyfit(czAmp,dp,2);
    
    fdp_ = fdp;
    fdp_(3)=fdp_(3)-1;
    rd=roots(fdp_);
    if numel(rd) == 1
        if ~isreal(rd)
            rd = [];
        end
    elseif numel(rd) == 2
        rd = rd([isreal(rd(1)), isreal(rd(2))]);
    end
    ampBnd = minmax([czAmp(1),czAmp(end)]);
    czamp=rd(find(rd>ampBnd(1)&rd<ampBnd(end)));
    if isempty(czamp)
        fdp_ = fdp;
        fdp_(3)=fdp_(3)+1;
        rd=roots(fdp_);
        if numel(rd) == 1
            if ~isreal(rd)
                rd = [];
            end
        elseif numel(rd) == 2
            rd = rd([isreal(rd(1)), isreal(rd(2))]);
        end
        czamp=rd(find(rd>ampBnd(1)&rd<ampBnd(end)));
    end
    
    repeat = false;
    if isempty(czamp)
        ai = linspace(ampBnd(1),ampBnd(2),200);
        yi = polyval(fdp,ai);
        ai = [ai,ai];
        D = abs([yi-pi,yi+pi]);
        [minD,ind] = min(D);
        if minD < -0.25
            czamp = ai(ind);
            if ~isempty(args.logger)
                args.logger.warn('QOS_czAmplitude:czAmplitude',...
                    sprintf('%s,%s acz amplitude may out of range, the closest value is used.',qc.name, qt.name));
            end
            warning('QOSTuneup:czAmplitude',...
                sprintf('%s,%s acz amplitude may out of range, the closest value is used.',qc.name, qt.name));
            repeat = true;
        else
            repeat = true;
            if args.gui
                hf = qes.ui.qosFigure(sprintf('ACZ amplitude | %s,%s', qc.name, qt.name),true);
                ax = axes('parent',hf);
                plot(ax,czAmp,cz0data,'--b',czAmp, cz1data,'--r',...
                    czAmp,dp,'.',czAmp,polyval(fdp,czAmp),'-g',...
                    czAmp,ones(1,length(czAmp)),'--k',czAmp,-ones(1,length(czAmp)),'--k');
                xlabel(ax,'acz amplitude');
                ylabel(ax,'phase(\pi)');
                legend(ax,{'|0>','|1>','difference','difference fit','+\pi','-\pi'});
                drawnow;
            end
            if ~isempty(args.logger)
                args.logger.error('QOS_czAmplitude:czAmplitude',...
                    sprintf('%s,%s acz amplitude not found! Probably out of range.',qc.name, qt.name));
                warning('QOSTuneup:czAmplitude',...
                    sprintf('%s,%s acz amplitude not found! Probably out of range.',qc.name, qt.name));
                return;
            elseif ~args.repeatIfOutOfBoundButClose
                throw(exceptions.QRuntimeException('QOSTuneup:czAmplitude',...
                    sprintf('%s,%s acz amplitude not found! Probably out of range.',qc.name, qt.name)));
            end
        end
    end
    if ischar(args.save) && ~repeat
        args.save = false;
        choice  = qes.ui.questdlg_timer(600,'Update settings?','Save options','Yes','No','Yes');
%         choice  = questdlg('Update settings?','Save options',...
%                 'Yes','No','No');
        if ~isempty(choice) && strcmp(choice, 'Yes')
            args.save = true;
        end
    end
    if args.save && ~repeat
        try
            QS.saveSSettings({'shared','g_cz',aczSettingsKey,'amp'},czamp);
        catch ME
            if ~isempty(args.logger)
                args.logger.error('QOS_czAmplitude:czAmplitude',...
                    sprintf('Error at updating acz amplitude of %s,%s cz gate: ', qc.name, qt.name, ME.message));
                warning('QOSTuneup:czAmplitude',...
                    sprintf('Error at updating acz amplitude of %s,%s cz gate: ', qc.name, qt.name, ME.message));
                return;
            elseif ~args.repeatIfOutOfBoundButClose
                throw(ME);
            end
        end
    end
    
    if args.gui && ~repeat
        hf = qes.ui.qosFigure(sprintf('ACZ amplitude | %s,%s', qc.name, qt.name),true);
        ax = axes('parent',hf);
        plot(ax,czAmp,cz0data,'--b',czAmp, cz1data,'--c',...
            czAmp,dp,'.',czAmp,polyval(fdp,czAmp),'-g',...
            czAmp,ones(1,length(czAmp)),'--k',czAmp,-ones(1,length(czAmp)),'--k');
		hold(ax,'on');
		plot(ax,[czAmp0,czAmp0],get(ax,'YLim'),'--','Color',[1,0.7,0.7]);
		plot(ax,[czamp,czamp],get(ax,'YLim'),'--r');
        xlabel(ax,'acz amplitude');
        ylabel(ax,'phase(\pi)');
        legend(ax,{'|0>','|1>','difference','difference fit','+\pi','-\pi','CZ Amp(old)','CZ Amp(new)'})
        title(sprintf('acz amplitude: %0.5e',czamp));
        drawnow;
        if args.save && ~isempty(hf) && isvalid(hf)
            dataSvName = fullfile(QS.loadSSettings('data_path'),...
                ['czAmp_',qc.name,qt.name,'_',datestr(now,'yymmddTHHMMSS'),...
                num2str(ceil(99*rand(1,1)),'%0.0f'),'_.fig']);
            try
                saveas(hf,dataSvName);
            catch
                warning('saving figure failed.');
            end
        end
    end
    
    if args.repeatIfOutOfBoundButClose && repeat
        data_taking.public.xmon.tuneup.simu_czAmplitude(...
            'controlQ',args.controlQ,'targetQ',args.targetQ,'largeRange',true,...
        'gui',args.gui,'save',args.save,'logger',args.logger,...
        'repeatIfOutOfBoundButClose',false);
    end
end
    