function varargout = ramsey_dp(varargin)
% support multi-qubit parallel process
%
% ramsey: ramsey oscillation,..
% detune by changing the second pi/2 pulse tracking frame
% 
% <_o_> = ramsey_dp('qubit',[_c|o_],...
%       'time',[_i_],'detuning',<[_f_]>,'phaseOffset',<_f_>,...
%       'dataTyp',<'_c_'>,...   % S21, P or Phase
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

% Yulin Wu, 2016/12/27

    fcn_name = 'data_taking.public.xmon.ramsey_dp'; % this and args will be saved with data
    import qes.*
    import sqc.*
    import sqc.op.physical.*

    args = util.processArgs(varargin,{'phaseOffset',0,'dataTyp','P',...
        'gui',false,'notes','','detuning',0,'save',true});
	
	allQubits = sqc.util.loadQubits();
	qubits = args.qubit; % qubit not qubits because this function only support one qubit measurement when first written
	if ~iscell(qubits)
		qubits = {qubits};
	end
	numQs = numel(qubits);
	X2 = cell(1,numQs);
	X2_ = cell(1,numQs);
	I = cell(1,numQs);
	Z = cell(1,numQs);
	for ii = 1:numQs
		if ischar(qubits{ii})
			qubits{ii} = allQubits{qes.util.find(qubits{ii},allQubits)};
        end
        q = qubits{ii};
		X2{ii} = op.XY2(q,pi/2+args.phaseOffset);
		X2_{ii} = op.XY2(q,-pi/2);
		I{ii} = gate.I(q);
		Z{ii} = gate.ZArbPhase(q,args.phaseOffset);
	end
    
%     I = op.detune(q);
%     I.df = 3e4;

	if numQs > 1
		parallelReadout = true;
	else
		parallelReadout = false;
	end

    isPhase = false;
    switch args.dataTyp
        case 'P'
            R = measure.resonatorReadout_ss(qubits);
            R.state = 2;
        case 'S21'
            R = measure.resonatorReadout_ss(qubits,false,true); 
            R.swapdata = true;
            R.name = 'iq';
            R.datafcn = @(x)aba(mean(x));
        case 'Phase'
            R = measure.phase(qubits,parallelReadout);
            isPhase = true;
        otherwise
            throw(MException('QOS_ramsey_dp:unrcognizedDataTyp',...
            'unrecognized dataTyp %s, available dataTyp options are P, S21 or Phase.', args.dataTyp));
    end

	detuning = qes.util.hvar(0);
	da = qHandle.FindByClassProp('qes.hwdriver.hardware','name',...
		q.channels.xy_i.instru);
	daChnl = da.GetChnl(q.channels.xy_i.chnl);
	daSamplingRate = daChnl.samplingRate;

    function procFactory(delay)
        phase = 2*pi*detuning.val*delay/daSamplingRate+args.phaseOffset;
        if isPhase
            Z{1}.phase = phase;
            I{1}.ln = delay;
            proc = X2_{1}*I{1}*Z{1};
			for ii_ = 2:numQs
                Z{ii_}.phase = phase;
                I{ii_}.ln = delay;
				proc = proc.*(X2_{ii_}*I{ii_}*Z{ii_});
			end
            R.setProcess(proc);
        else
            I{1}.ln = delay;
            X2{1}.phi = -phase;
			proc = X2_{1}*I{1}*X2{1};
			for ii_ = 2:numQs
                I{ii_}.ln = delay;
				X2{ii_}.phi = -phase;
				proc = proc.*(X2_{ii_}*I{ii_}*X2{ii_});
			end
			proc.Run();
            R.delay = proc.length;
        end
    end

    x = expParam(detuning,'val');
	x.name = [q.name,' detuning(Hz)'];
    y = expParam(@procFactory);
    y.name = [q.name,' time'];
	s1 = sweep(x);
    s1.vals = args.detuning;
    s2 = sweep(y);
    s2.vals = args.time;
    e = experiment();
    e.name = 'Ramsey(Detune by Phase)';
    e.sweeps = [s1,s2];
    e.measurements = R;
    e.datafileprefix = sprintf('%s_ramsey_', q.name);
    if ~args.gui
        e.showctrlpanel = false;
        e.plotdata = false;
    end
    if ~args.save
        e.savedata = false;
    end
    e.notes = args.notes;
    e.addSettings({'fcn','args'},{fcn_name,args});
    e.Run();
    varargout{1} = e;
end