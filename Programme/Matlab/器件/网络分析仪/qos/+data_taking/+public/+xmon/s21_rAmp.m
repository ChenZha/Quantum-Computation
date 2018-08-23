function varargout = s21_rAmp(varargin)
% scan resonator s21 vs frequency and raadout amplitude(iq), no qubit drive
% 
% <_o_> = s21_rAmp('qubit',_c|o_,...
%       'freq',[_f_],'amp',<[_f_]>,'updateSettings',<_b_>,'isDip',<_b_>,...
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

% Yulin Wu, 2017/1/13

    fcn_name = 'data_taking.public.xmon.s21_rAmp'; % this and args will be saved with data
    import qes.*
    import sqc.*
    import sqc.op.physical.*
    
    args = util.processArgs(varargin,{'amp',[],'r_avg',[],'gui',false,'notes','',...
		'save',true,'updateSettings',false,'isDip',true});
    q = data_taking.public.util.getQubits(args,{'qubit'});
    
    data_taking.public.util.setZDC(q); %add by GM, 20170415
    
    if ~isempty(args.r_avg) %add by GM, 20170414
        q.r_avg=args.r_avg;
    end
    
    if isempty(args.amp)
        args.amp = q.r_amp;
    end
    
    R = measure.resonatorReadout_ss(q,false,true);
    R.swapdata = true;
    R.name = 'IQ';
    R.datafcn = @(x)mean(x);
    
    I = gate.I(q);
    
    % x = expParam(I,'ln');
    
    x = expParam(R,'mw_src_frequency');
    x.offset = q.r_fc - q.r_freq;
    x.name = [q.name,' readout frequency'];
    y = expParam(R,'r_amp');
    y.name = [q.name,' readout pulse amplitude'];
    s1 = sweep(x);
    s1.vals = args.freq;
    s2 = sweep(y);
    s2.vals = args.amp;
    e = experiment();
    e.name = 'S21-Readout Amp.';
    e.sweeps = [s1,s2];
    e.measurements = R;
    if s2.size > 1
        e.plotfcn = @util.plotfcn.OneMeasComplex_2DMap_Amp_dB_X; % add by GM, 20170413
    end
    e.datafileprefix = sprintf('%s_s21_rAmp', q.name);
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
	if args.updateSettings && numel(args.amp) == 1
		data = abs(cell2mat(e.data{1}));
		if args.isDip
			data = -data;
		end
		[~,ind] = max(data);
		peakFreq = args.freq(ind);
		if ~args.gui
			h = qes.ui.qosFigure(sprintf('S21 vs Amp. | %s', q.name),true);
			ax = axes('parent',h);
			plot(ax,args.freq/1e9,data,'-b');
			hold(ax,'on');
			plot(ax,[peakFreq,peakFreq]/1e9,get(ax,'YLim'),'--r');
			xlabel(ax,'frequency(GHz)');
			ylabel(ax,'|S21|');
		end
		QS = qes.qSettings.GetInstance();
		QS.saveSSettings({q.name,'r_fr'},peakFreq);
	end
    varargout{1} = e;
end