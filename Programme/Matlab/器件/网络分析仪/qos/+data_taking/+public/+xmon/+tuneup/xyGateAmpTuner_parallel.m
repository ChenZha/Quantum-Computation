function varargout = xyGateAmpTuner_parallel(varargin)
% tune xy gate amplitude: X, X/2, -X/2, X/4, -X/4, Y, Y/2, -Y/2, Y/4, -Y/4
% 
% <_f_> = xyGateAmpTuner('qubits',_c&o_,'gateTyp',_c_,...
%		'AENumPi',<_i_>,'tuneRange',<_f_>,...  % insert multiple Idle gate(implemented by two pi rotations) to Amplify Error or not
%       'gui',<_b_>,'save',<_b_>,'logger',<_o_>)
% _f_: float
% _i_: integer
% _c_: char or char string
% _b_: boolean
% _o_: object
% a&b: default type is a, but type b is also acceptable
% []: can be an array, scalar also acceptable
% {}: must be a cell array
% <>: optional, for input arguments, assume the default value if not specified
% arguments order not important as long as the form correct pairs.
    
    % Yulin Wu, 2017/1/8
    import data_taking.public.xmon.rabi_amp1
	
	NUM_RABI_SAMPLING_PTS = 50;
	MIN_VISIBILITY = 0.3;
	AE_NUM_PI = 11; % positive odd integer
	
	args = qes.util.processArgs(varargin,{'AENumPi',AE_NUM_PI,'tuneRange',0.05,...
        'gui',false,'save',true,'logger',[]});
    args.AENumPi = round(args.AENumPi);
    if mod(args.AENumPi,2) ==0 || args.AENumPi <= 0
        if ~isempty(args.logger)
            args.logger.error('QOS_xyGateAmpTuner:IllegalArgument',...
                sprintf('AENumPi %0.0f not a positive odd integer.',args.AENumPi));
        end
        throw(MException('QOS_xyGateAmpTuner:IllegalArgument',...
            sprintf('AENumPi %0.0f not a positive odd integer.',args.AENumPi)));
    end
	if args.tuneRange <= 0 || args.tuneRange >= 1
        if ~isempty(args.logger)
            args.logger.error('QOS_xyGateAmpTuner:IllegalArgument',...
                sprintf('tuneRange %0.3f not withing (0,1))',args.tuneRange));
        end
        throw(MException('QOS_xyGateAmpTuner:IllegalArgument',...
				sprintf('tuneRange %0.3f not withing (0,1))',args.tuneRange)));
	end
	
	qubits = args.qubits;
	if ~iscell(qubits)
		qubits = {qubits};
	end
	
	numQs = numel(qubits);
	allf01s = nan(1,numQs);
    skip = nan(1,numQs);
    for ii = 1:numQs
        if ischar(qubits{ii})
            qubits{ii} = sqc.util.qName2Obj(qubits{ii});
        end
		F = qubits{ii}.r_iq2prob_fidelity;
		vis = F(1)+F(2)-1;
        skip(ii) = false; 
		if vis < 0.2
            skip(ii) = true;
			warning('QOS_xyGateAmpTuner:visibilityTooLow',...
				sprintf('%s visibility(%0.2f) too low, run xyGateAmpTuner at low visibility might produce wrong results, tuning for this qubit will be skipped.', ...
					qubits{ii}.name, vis));
           if ~isempty(args.logger)
                args.logger.warn('QOS_xyGateAmpTuner:visibilityTooLow',...
                    sprintf('%s visibility(%0.2f) too low, run xyGateAmpTuner at low visibility might produce wrong results, tuning for this qubit will be skipped.', ...
					qubits{ii}.name, vis));
           end
		end
		qubits{ii}.r_iq2prob_intrinsic = true;
    end

% 	switch args.gateTyp
% 		case {'X','Y'}
% % 			maxAmp = da.vpp/2;
% 		case {'X/2','-X/2','X2m','X2p','Y/2','-Y/2','Y2m','Y2p'}
% % 			maxAmp = da.vpp/4;
%         case {'X/4','-X/4','X4m','X4p','Y/4','-Y/4','Y4m','Y4p'}
% % 			maxAmp = da.vpp/8;
%     end
    
    QS = qes.qSettings.GetInstance();
	switch args.gateTyp
        case {'X','Y'}
            gateAmpSettingsKey ='g_XY_amp';
        case {'X/2','X2p','-X/2','X2m','Y/2','Y2p','-Y/2','Y2m'}
            gateAmpSettingsKey ='g_XY2_amp';
        case {'X/4','X4p','-X/4','X4m','Y/4','Y4p','-Y/4','Y4m'}
            gateAmpSettingsKey ='g_XY4_amp';
        otherwise
            if ~isempty(args.logger)
                args.logger.error('QOS_xyGateAmpTuner:unsupportedGataType',...
                    sprintf('gate %s is not supported, supported types are %s',args.gateTyp,...
				'X Y X/2 -X/2 X2m X2p X/4 -X/4 X4m X4p Y/2 -Y/2 Y2m Y2p Y/4 -Y/4 Y4m Y4p'));
            end
			throw(MException('QOS_xyGateAmpTuner:unsupportedGataType',...
				sprintf('gate %s is not supported, supported types are %s',args.gateTyp,...
				'X Y X/2 -X/2 X2m X2p X/4 -X/4 X4m X4p Y/2 -Y/2 Y2m Y2p Y/4 -Y/4 Y4m Y4p')));
    end
	amps = cell(numQs,1);
	for ii = 1:numQs
		da = qes.qHandle.FindByClassProp('qes.hwdriver.hardware',...
                        'name', qubits{ii}.channels.xy_i.instru);
		daChnl = da.GetChnl(qubits{ii}.channels.xy_i.chnl);
		currentGateAmp = qubits{ii}.(gateAmpSettingsKey); % QS.loadSSettings({q.name,gateAmpSettingsKey});
		% amps{ii} = linspace(0.95*gateAmp,min(daChnl.vpp,1.05*gateAmp),NUM_RABI_SAMPLING_PTS*3);
		amps{ii} = linspace((1-args.tuneRange)*currentGateAmp,...
				min(daChnl.vpp,(1+args.tuneRange)*currentGateAmp),NUM_RABI_SAMPLING_PTS);
    end

    try
        e = rabi_amp1('qubit',qubits,'biasAmp',0,'biasLonger',0,'xyDriveAmp',amps,...
            'detuning',0,'numPi',args.AENumPi,'driveTyp',args.gateTyp,'gui',false,'save',false);
    catch ME
        if ~isempty(args.logger)
            args.logger.error('QOS_xyGateAmpTuner:dataTakingError',...
                ME.message);
        end
        throw(ME);
    end
	
	data = e.data{1};
    if numQs > 1
        for ii = 1:numel(data)
            data{ii}(:,1) = [];
        end
        data = cell2mat(data);
    end
	
	allGateAmps = nan(1,numQs);
	for ii = 1:numQs
        if skip(ii)
            continue;
        end
        q = qubits{ii};
        P = data(ii,:);
        try
            gateAmp = findsPkLoc(amps{ii},P);
        catch ME
            if ~isempty(args.logger)
                args.logger.warn('QOS_xyGateAmpTuner:findsPkLocError',...
                    [q.name, ' ',ME.message]);
            end
            warning('QOS_xyGateAmpTuner:findsPkLocError',[q.name, ': ', ME.message]);
            continue;
        end
        allGateAmps(ii) = gateAmp;
        if isempty(gateAmp)
            warning('QOS_xyGateAmpTuner:gateAmpNotFound',...
                    '%s gateAmp for qubit %s not found', args.gateTyp, q.name);
            if ~isempty(args.logger)
                args.logger.warn('QOS_xyGateAmpTuner:gateAmpNotFound',...
                    '%s gateAmp for qubit %s not found', args.gateTyp, q.name);
            end
            continue;
        end

        if args.gui
            h = qes.ui.qosFigure(sprintf('XY Gate Tuner | %s: %s', q.name, args.gateTyp),true);
            ax = axes('parent',h);
            plot(ax,amps{ii},P,'-b');
            hold(ax,'on');
    %         ylim = get(ax,'YLim');
            ylim = [0,1];
            gateAmp0 = sqc.util.getQSettings(gateAmpSettingsKey,q.name);
            plot(ax,[gateAmp0,gateAmp0],ylim,'--','Color',[1,0.7,0.7]);
            plot(ax,[gateAmp,gateAmp],ylim,'--r');
            xlabel(ax,'xy drive amplitude');
            ylabel(ax,'P|1>');
            legend(ax,{[sprintf('data(%d',args.AENumPi),'\pi)'],'gate amplitude(old)', 'gate amplitude(new)'});
            set(ax,'YLim',ylim);
            drawnow;
        else
            hf = [];
        end
        if ischar(args.save)
            args.save = false;
            choice  = qes.ui.questdlg_timer(600,'Update settings?','Save options','Yes','No','Yes');
    %         choice  = questdlg('Update settings?','Save options',...
    %                 'Yes','No','No');
            if ~isempty(choice) && strcmp(choice, 'Yes')
                args.save = true;
            end
        end
        if args.save
            QS.saveSSettings({q.name,gateAmpSettingsKey},gateAmp);
        end
	end
	
	varargout{1} = allGateAmps;
end

function xp = findsPkLoc(x,y)
    rng = range(y);
    [pks,locs,~,~] = findpeaks(y,'MinPeakHeight',2*rng/3,...
        'MinPeakProminence',rng/2,'MinPeakDistance',numel(x)/4,...
        'WidthReference','halfprom');
    
    if ~isempty(pks)
        [locs,idx] = sort(locs,'ascend');
        pks = pks(idx);

        maxIdx = locs(1);
        if numel(pks) > 3
            throw(MException('QOS_xyGateAmpTuner:tooManyOscCycles',...
                    'too many oscillation cycles or data SNR too low.'));
        end
        dy = pks(1)-y;
    else
        [mP,maxIdx] = max(y);
        dy = mP-y;
    end

	idx1 = find(dy(maxIdx:-1:1)>rng/3,1,'first');
	if isempty(idx1)
		idx1 = 1;
	else
		idx1 = maxIdx-idx1+1;
	end
	
	idx2 = find(dy(maxIdx:end)>rng/4,1,'first');
	if isempty(idx2)
		idx2 = numel(x);
	else
		idx2 = maxIdx+idx2-1;
    end
%	 [~, gateAmp, ~, ~] = toolbox.data_tool.fitting.gaussianFit.gaussianFit(...
%		 amps(idx1:idx2),P(idx1:idx2),maxP,amps(maxIdx),amps(idx2)-amp(idx1));

	% gateAmp = roots(polyder(polyfit(amps(idx1:idx2),P(idx1:idx2),2)));
    warning('off');
	p = polyfit(x(idx1:idx2),y(idx1:idx2),2);
    warning('on');
	if mean(abs(polyval(p,x(idx1:idx2))-y(idx1:idx2))) > range(y(idx1:idx2))/4
		throw(MException('QOS_xyGateAmpTuner:fittingFailed','fitting error too large.'));
	end
	xp = roots(polyder(p));

    if xp < x(idx1) || xp > x(idx2)
		throw(MException('QOS_xyGateAmpTuner:xyGateAmpTuner',...
				'gate amplitude probably out of range.'));
    end
end