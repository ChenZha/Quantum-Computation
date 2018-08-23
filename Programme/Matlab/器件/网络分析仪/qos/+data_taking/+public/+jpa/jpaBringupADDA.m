function varargout = jpaBringupADDA(varargin)
% [iqAmp] vs [signalFreq], [signalAmp], [biasAmp], [pumpFreq], [pumpAmp], [pumpPower]
% with DAC, run in EXACTLY the same way as when the jpa is used for a working qubit.
%
% <_o_> = jpaBringup('jpa',_c&o_,...
%       'signalAmp',[_f_],signalFreq',[_f_],'signalPower',<_f_>,...
%		'signalSbFreq',<_f_>,'signalFc',<_f_>,...
%       'signalLn',_i_,'rAvg',<_i_>,...
%       'biasAmp',<[_f_]>,'pumpAmp',<[_f_]>,...
%       'pumpFreq',<[_f_]>,'pumpPower',<[_f_]>,...
%       'notes',<_c_>,'gui',<_b_>,'save',<_b_>)
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

% Yulin Wu, 2017/2/14

    fcn_name = 'data_taking.public.jpa.jpaBringupADDA'; % this and args will be saved with data
    import qes.*
    
    args = util.processArgs(varargin,{'signalPower',0,'signalSbFreq',[],'signalFc',[],...
        'biasAmp',[],'pumpAmp',[],'pumpFreq',[],'pumpPower',[],...
        'rAvg',500,'gui',false,'notes','','save',true});
    jpa = data_taking.public.util.getJPAs(args,{'jpa'});
    
    virtualQubit = sqc.util.virtualXmon();
    virtualQubit.channels.r_da_i.instru = jpa.channels.signal_da_i.instru;
    virtualQubit.channels.r_da_i.chnl = jpa.channels.signal_da_i.chnl;
    virtualQubit.channels.r_da_q.instru = jpa.channels.signal_da_q.instru;
    virtualQubit.channels.r_da_q.chnl = jpa.channels.signal_da_q.chnl;
    virtualQubit.channels.r_ad_i.instru = jpa.channels.signal_ad_i.instru;
    virtualQubit.channels.r_ad_i.chnl = jpa.channels.signal_ad_i.chnl;
    virtualQubit.channels.r_ad_q.instru = jpa.channels.signal_ad_q.instru;
    virtualQubit.channels.r_ad_q.chnl = jpa.channels.signal_ad_q.chnl;
    virtualQubit.channels.r_mw.instru = jpa.channels.signal_mw.instru;
    virtualQubit.channels.r_mw.chnl = jpa.channels.signal_mw.chnl;    
    virtualQubit.r_jpa = jpa.name;
    virtualQubit.r_avg = args.rAvg;
    virtualQubit.r_ln = args.signalLn;
    virtualQubit.r_wvSettings = struct('edgeWidth',10,  'ring_w',6, 'ring_amp',0);
    virtualQubit.r_iq2prob_center0 = 0;
    virtualQubit.r_iq2prob_center1 = 1;
    virtualQubit.r_iq2prob_center2 = 2;
    virtualQubit.r_iq2prob_intrinsic = true;
    virtualQubit.r_iq2prob_fidelity = [1,1];
    virtualQubit.r_truncatePts = [83,0];
    virtualQubit.syncDelay_r = [32,32];
    
    if isempty(args.signalFc)
        virtualQubit.r_fc = args.signalFreq(1)-args.signalSbFreq;
    else
        virtualQubit.r_fc = args.signalFc;
    end
    virtualQubit.r_freq = args.signalFreq(1);
    virtualQubit.r_uSrcPower = args.signalPower;
    virtualQubit.r_amp = args.signalAmp(1);
    
    R = sqc.measure.resonatorReadout_ss(virtualQubit);
    % jpa = data_taking.public.util.getJPAs(args,{'jpa'});
    jpaRunner = R.jpaRunner;
    jpa = jpaRunner.jpa;
    
    s = qes.sweep.empty();
    if numel(args.biasAmp) == 1
        jpa.biasAmp = args.biasAmp;
    elseif numel(args.biasAmp) > 1
        x = expParam(jpa,'biasAmp');
        x.name = 'bias amplitude';
        s_ = sweep(x);
        s_.vals = args.biasAmp;
        s = [s,s_];
    end
    if numel(args.pumpFreq) == 1
        jpa.pumpFreq = args.pumpFreq;
    elseif numel(args.pumpFreq) > 1
        x = expParam(jpa,'pumpFreq');
        x.name = 'pump frequency(Hz)';
        s_ = sweep(x);
        s_.vals = args.pumpFreq;
        s = [s,s_];
    end
    if numel(args.pumpAmp) == 1
        jpa.pumpAmp = args.pumpAmp;
    elseif numel(args.pumpAmp)> 1
        x = expParam(jpa,'pumpAmp');
        x.name = 'pump amplitude';
        s_ = sweep(x);
        s_.vals = args.pumpAmp;
        s = [s,s_];
    end
    if numel(args.pumpPower) == 1
        jpa.pumpPower = args.pumpPower;
    else
        x = expParam(jpa,'pumpPower');
        x.name = 'pump power(dBm)';
        s_ = sweep(x);
        s_.vals = args.pumpPower;
        s = [s,s_];
    end
    if numel(args.signalAmp) == 1
        virtualQubit.r_amp = args.signalAmp;
    elseif numel(args.signalAmp)> 1
        x = expParam(virtualQubit,'r_amp');
        x.name = 'signal amplitude';
        s_ = sweep(x);
        s_.vals = args.signalAmp;
        s = [s,s_];
    end
    if numel(args.signalFreq) == 1
		if ~isempty(args.signalSbFreq)
			if ~isempty(args.signalFc)
				warning('both signalSbFreq and signalFc are given, only signalSbFreq is used.');
			end
			virtualQubit.r_fc = args.signalFreq-args.signalSbFreq;
			virtualQubit.r_freq = args.signalFreq;
        elseif ~isempty(args.signalFc)
			virtualQubit.r_fc = args.signalFc;
			virtualQubit.r_freq = args.signalFreq;
		else
			error('both signalSbFreq and signalFc are not specified.');
		end
    elseif numel(args.signalFreq)> 1
		x = expParam(virtualQubit,'r_freq');
		x.name = 'signal frequency(Hz)';
		if isempty(args.signalFc)
			x_s = expParam(virtualQubit,'r_fc');
			x_s.offset = -args.signalSbFreq;
			s_ = sweep([x,x_s]);
			s_.vals = {args.signalFreq,args.signalFreq};
		else % fixed r_fc % 2018-04-06
			virtualQubit.r_fc = args.signalFc;
			s_ = sweep(x);
			s_.vals = {args.signalFreq};
		end
		s = [s,s_];
    end

    if isempty(s) % we need at least one sweep
        x = expParam(virtualQubit,'r_freq');
        x.name = 'signal frequency(Hz)';
        x_s = expParam(virtualQubit,'r_fc');
        x_s.offset = -args.signalSbFreq;
        s_ = sweep([x,x_s]);
        s_.vals = {args.signalFreq,args.signalFreq};
        s = [s,s_];
    end
    function generateReadout()
        R = sqc.measure.resonatorReadout_ss(virtualQubit);
        R.swapdata = true;
        R.setJPA(jpa);
        R.name = 'IQ';
        R.datafcn = @(x)mean(x);
        e.measurements = R;
    end
    s(end).poststepcallbacks = @(x_)generateReadout;

    e = experiment();
    e.name = 'JPA Bringup(ADDA)';
    e.sweeps = s;
%     e.plotfcn = @util.plotfcn.sparam.Amplitude;
    
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