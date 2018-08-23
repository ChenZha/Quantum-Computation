function varargout = zPulseCrossTalk(varargin)
% <_o_> = zPulseCrossTalk('sourceQ',_c|o_,'targetQ',_c|o_,'numZPulses',<_i_>,...
%       'sourceZLength',_i_,'sourceZAmp',_f_,'targeZLonger',<_i_>,'targetZAmp',<_f_>,...
%       'notes',<_c_>,'gui',<_b_>,'save',<_b_>)
% _f_: float
% _i_: integer
% _c_: char or char string
% _b_: boolean
% _o_: object
% a|b: default type is a, but type b is also acceptable
% []: can be an array, scalar also acceptable
% {}: must be a cell array
% <>: optional, for input arguments, assume the default value if not specified
% arguments order not important as long as they form correct pairs.

% Yulin Wu, 2018/02/10

    import qes.*
    import sqc.*
    import sqc.op.physical.*
    
    maxFEval = 50;

	fcn_name = 'data_taking.public.xmon.zPulseRingingPhase'; % this and args will be saved with data
	args = util.processArgs(varargin,{'numZPulses',1,'targeZLonger',0,'targetZAmp',0,...
				'gui',false,'notes','','save',true});
    [sourceQ,targetQ] = data_taking.public.util.getQubits(args,{'targetQ','sourceQ'});
	if sourceQ == targetQ
		throw(MException('QOS_zPulseCrossTalk:illegalArguments','sourceQ and targetQ are the same qubit.'));
	end
	
	Z1 = op.zRect(sourceQ);
	Z1.ln = args.sourceZLength;
	Z2Bias = op.zRect(targetQ);
	Z2Bias.ln = args.sourceZLength+2*args.targeZLonger;
	Z2Bias.amp = args.targetZAmp;
	Z2 = op.zRect(targetQ)
	Z2.ln = args.sourceZLength;
	
	I1 = gate.I(sourceQ);
	I1.length = args.targeZLonger;
	I2 = gate.I(targetQ);
	I2.length = args.targeZLonger;
	I3 = gate.I(sourceQ);
	I3.length = args.sourceZLength;
	
	R = measure.phase(targetQ);
	function procFactory(r)
        Z2.amp = -r*args.sourceZAmp;
		proc = Z2Bias.*(I2*Z2).*(I1*Z1)*I3;
		proc = proc^args.numZPulses;
        R.setProcess(proc);
    end
	Z1.amp = 0;
    Z2.amp = 0;
	procFactory(0);
	phi0 = R();
	Z1.amp = args.sourceZAmp;
	R.datafcn = @(x)rem(abs(x-phi0),2*pi);
	
	xTalkCoefficient = qes.expParam(@procFactory);
	
	f = qes.expFcn(xTalkCoefficient,R);

    x0 = [-0.01;...
          0.01];
    tolX = [0.0001];
    tolY = [0.01];
            
    h = qes.ui.qosFigure(sprintf('zPulseCrossTalk | %s%s', targetQ.name, sourceQ.name),false);
    axs(1) = subplot(2,1,2,'Parent',h);
    axs(2) = subplot(2,1,1);
    [optParams, x_trace, y_trace, n_feval] = qes.util.NelderMead(f.fcn, x0, tolX, tolY, maxFEval, axs);
    fval = y_trace(end);
    fval0 = y_trace(1);

	if fval > fval0
        error('Optimization failed: no convergence, registry not updated.');
    end
	[~,ind] = min(y_trace);
	xTalkCoef = x_trace(ind);

    if args.save
        QS = qes.qSettings.GetInstance();
		xTalkData = sourceQ.xTalk_z;
		xTalkQExists = false;
		for ii = 1:3:numel(xTalkData)
			if strcmp(xTalkData{ii},targetQ.name)
				xTalkData{ii+1} = xTalkCoef;
				xTalkQExists = true;
			end
		end
		if ~xTalkQExists
			xTalkData{end+1:end+3} = {targetQ.name, xTalkCoef,0};
		end
		QS.saveSSettings({sourceQ.name,'xTalk_z'},xTalkData);
        dataPath = QS.loadSSettings('data_path');
        timeStamp = datestr(now,'_yymmddTHHMMSS_');
        figFileName = ['ZpulseCal',q.name,timeStamp,'.fig'];
        try
            saveas(h, fullfile(dataPath,figFileName));
        catch
        end
    end
    varargout{1} = xTalkCoef;
end