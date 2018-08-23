function varargout = correctf01byPhase(varargin)
% support multi-qubit parallel correction
% 
% correct f01  in case f01 has drifted away slightly:
% 1st step: measrue drift by phase tomo(T2* time can not be too short);
% 2nd step: adjust zdc_amp to set f01 to the f01_set

%
% <_f_> = correctf01byPhase('qubit',[_c&o_],'delayTime',<_i_>,'doCorrection',<_b_>...
%       'gui',<_b_>,'save',<_b_>,'logger',<_o_>,'logger',<_o_>,'iter',<_b_>)
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
    
    % Yulin Wu, 2017/4/14
    
    import data_taking.public.xmon.ramsey
    
    args = qes.util.processArgs(varargin,{'delayTime',1e-6,'robust',true,'gui',false,...
        'save',true,'doCorrection',true,'logger',[],'iter',false});
	
	qubits = args.qubits;
	if ~iscell(qubits)
		qubits = {qubits};
	end
	
	numQs = numel(qubits);
	allf01s = nan(1,numQs);
    for ii = 1:numQs
        if ischar(qubits{ii})
            qubits{ii} = sqc.util.qName2Obj(qubits{ii});
        end
		qubits{ii}.qr_xy_dragPulse = false;
    end
	% assume all qubit DACs has the same samplingRate
    da = qes.qHandle.FindByClassProp('qes.hwdriver.hardware','name',...
		qubits{1}.channels.xy_i.instru);
    daChnl = da.GetChnl(qubits{1}.channels.xy_i.chnl);
	daSamplingRate = daChnl.samplingRate;
    
    t = unique(round(linspace(0,args.delayTime,20)*daSamplingRate));

    try
        e = ramsey('qubit',qubits,'mode','dp','dataTyp','Phase',... 
            'time',t,'detuning',0,'gui',false,'save',false);
    catch ME
        if ~isempty(args.logger)
            args.logger.error('QOS_correctf01byPhase:dataTakingError',...
                ME.message);
        end
        throw(ME);
    end

	data = e.data{1};
    if numQs > 1
        data = cell2mat(data(:));
    else
        data = data(:);
    end
    t = t.';
    
    if isscalar(args.doCorrection)
        args.doCorrection = args.doCorrection*ones(1,numQs);
    end
	for ii = 1:numQs
        q = qubits{ii};
        phase = unwrap(data(:,ii));
        phase(1) = [];
        dp = diff(phase);
        ddp = diff(dp);
        if (~isempty(dp(abs(dp) > pi/2)) || ~isempty(ddp(abs(ddp) > pi/4))) && args.iter && args.delayTime/3 > 0.1e-6
            allf01s(ii) = data_taking.public.xmon.tuneup.correctf01byPhase(...
                'qubits',q,'delayTime',args.delayTime/3,'gui',args.gui,'save',args.save,...
                'doCorrection',args.doCorrection(ii),'iter',args.iter);
            continue;
        end
        t_ = t(2:end);
        [p,s] = polyfit(t_,phase,1);
        [y,delta]=polyconf(p,t_,s);
        err=abs(mean(delta));
        errf=err/args.delayTime/2/pi;
        df = p(1)/(2*pi/daSamplingRate);

        if args.gui
            hf = qes.ui.qosFigure(sprintf('Correct f01 by phase | %s', q.name),true);
            ax = axes('parent',hf);
            plot(ax,1e9*t_/daSamplingRate,phase,'.','MarkerSize',15);
            hold(ax,'on');
            plot(ax,1e9*t_/daSamplingRate,polyval(p,t_),'-r','LineWidth',1);
            legend(ax,{'data','linear fit'});
            xlabel(ax,'time(ns)');
            ylabel(ax,'phase(rad)');
            title(['detune frequency: ', num2str(df/1e6,'%0.5fMHz'),' \pm ' ,num2str(errf/1e6,'%0.5fMHz')]);
            grid on;
        else
            hf = [];
        end

        if abs(df) > 20e6 || errf>0.2e6
            if ~isempty(args.logger)
                args.logger.error('QOS_correctf01byPhase:driftTooLarge',...
                    [q.name ' frequency drift too large, settings not updated.']);
            end
            warning('QOS_correctf01byPhase:driftTooLarge',...
                    [q.name ' frequency drift too large, settings not updated.']);
            continue;
        end

        f01 = q.f01-df;

        updateSettings = false;
        if ischar(args.save)
            choice  = qes.ui.questdlg_timer(600,'Update settings?','Save options','Yes','No','Yes');
%             choice  = questdlg('Update settings?','Save options',...
%                     'Yes','No','No');
            if ~isempty(choice) && strcmp(choice, 'Yes')
                updateSettings = true;
            end
        else
            updateSettings = args.save;
        end

        if updateSettings
            QS = qes.qSettings.GetInstance();
            QS.saveSSettings({q.name,'f01'},num2str(f01,'%0.6e'));
            dataFolder = fullfile(QS.loadSSettings('data_path'),'cal','correctF01ByPhase');
            if ~exist(dataFolder,'dir')
                mkdir(dataFolder);
            end
            dataFileName = [q.name,'_',datestr(now,'yymmddTHHMMSS'),...
                    num2str(ceil(99*rand(1,1)),'%0.0f'),'_'];
            if ~isempty(hf) && isvalid(hf)
                figName = fullfile(dataFolder,[dataFileName,'.fig']);
                try
                    saveas(hf,figName);
                catch ME
                    warning([q.name, ': save figure failed: ', ME.message]);
                end
            end
            dataFileName = fullfile(dataFolder,[dataFileName,'.mat']);
            time = t_; % ns
            save(dataFileName,'time','phase','p');
            if args.doCorrection(ii)
                f01_set = QS.loadSSettings({q.name,'f01_set'});
                if isempty(f01_set)
                    if ~isempty(args.logger)
                        args.logger.warn('QOS_correctf01byPhase:noF01_set',...
                            [q.name ' f01_set value empty in registry, f01 updated but no corrected.']);
                    end
                    warning('QOS_correctf01byPhase:noF01_set',...
                        [q.name ' f01_set value empty in registry, f01 updated but no corrected.']);
                else
                    if abs(f01_set - f01) > 20e6
                        warning('QOS_correctf01byPhase:driftTooLarge',...
                            [q.name ' f01 far away from f01_set, it might be a wrong result, f01 updated but no corrected.']);
                    else
                        sqc.util.SetWorkingPoint(q.name, f01_set, false);
                    end
                end
            end
        end
        allf01s(ii) = f01;
	end
	varargout{1} = allf01s;
end
