function varargout = xyGate(varargin)
% bring up xy gate with Randomized benchmarking.
% requirement: gates already tuned up, only needs fine callibration here
% 
% <_f_> = xyGateAmpTuner('qubit',_c&o_,'gateTyp',_c_,...
%		'AE',<_b_>,'AENumPi',<_i_>,...  % insert multiple Idle gate(implemented by two pi rotations) to Amplify Error or not
%       'gui',<_b_>,'save',<_b_>)
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
    import sqc.qfcns.gateOptimizer
	
	NUM_RABI_SAMPLING_PTS = 30;
	MIN_VISIBILITY = 0.3;
	AE_NUM_PI = 11; % must be an positive odd number
	
	args = qes.util.processArgs(varargin,{'AE',false,'AENumPi',AE_NUM_PI,'gui',false,'save',true});
    args.AENumPi = round(args.AENumPi);
    if mod(args.AENumPi,2) ==0 || args.AENumPi <= 0
        error('AENumPi not a positive odd number.');
    end
	q = data_taking.public.util.getQubits(args,{'qubit'});
    F = q.r_iq2prob_fidelity;
    vis = F(1)+F(2)-1;
    if vis < 0.25
        throw(MException('QOS_xyGateAmpTuner:visibilityTooLow',...
				sprintf('visibility(%0.25f) too low, run bringup.xyGate at low visibility might produce wrong result, thus not supported.', vis)));
    end
    q.r_iq2prob_intrinsic = true;

    QS = qes.qSettings.GetInstance();
	switch args.gateTyp
        case {'X','Y'}
            gateAmpSettingsKey ='g_XY_amp';
        case {'X/2','X2p','-X/2','X2m','Y/2','Y2p','-Y/2','Y2m'}
            gateAmpSettingsKey ='g_XY2_amp';
        case {'X/4','X4p','-X/4','X4m','Y/4','Y4p','-Y/4','Y4m'}
            gateAmpSettingsKey ='g_XY4_amp';
        otherwise
            throw(MException('QOS_xyGateAmpTuner:unsupportedGataType',...
                sprintf('gate %s is not supported, supported types are %s',args.gateTyp,...
                'X Y X/2 -X/2 X2m X2p X/4 -X/4 X4m X4p Y/2 -Y/2 Y2m Y2p Y/4 -Y/4 Y4m Y4p')));
    end
    currentGateAmp = QS.loadSSettings({q.name,gateAmpSettingsKey});

	e = rabi_amp1('qubit',q,'biasAmp',0,'biasLonger',0,'xyDriveAmp',amps,...
		'detuning',0,'numPi',numPi0,'driveTyp',args.gateTyp,'gui',false,'save',false);
	P = e.data{1};
	
	if args.gui
		h = qes.ui.qosFigure(sprintf('XY Gate Tuner | %s: %s', q.name, args.gateTyp),true);
		ax = axes('parent',h);
		plot(ax,amps,P,'-b');
		hold(ax,'on');
        if args.AE
           plot(ax,amps_ae,P_ae);
        end
%         ylim = get(ax,'YLim');
        ylim = [0,1];
        plot(ax,[gateAmp,gateAmp],ylim,'--r');
		xlabel(ax,'xy drive amplitude');
		ylabel(ax,'P|1>');
        if args.AE
            legend(ax,{'data(1\pi)',...
                [sprintf('data(AE:%0.0f',args.AENumPi),'\pi)'],...
                sprintf('%s gate amplitude',args.gateTyp)});
            title('Precision: ~0.5%');
        else
            legend(ax,{'data(1\pi)',sprintf('%s gate amplitude',args.gateTyp)});
            title('Precision: ~2%');
        end
        set(ax,'YLim',ylim);
        drawnow;
	end
	if ischar(args.save)
        args.save = false;
        choice  = questdlg('Update settings?','Save options',...
                'Yes','No','No');
        if ~isempty(choice) && strcmp(choice, 'Yes')
            args.save = true;
        end
    end
    if args.save
        QS.saveSSettings({q.name,gateAmpSettingsKey},gateAmp);
    end
	varargout{1} = gateAmp;
end
