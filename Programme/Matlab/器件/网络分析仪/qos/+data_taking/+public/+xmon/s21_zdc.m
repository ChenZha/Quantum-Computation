function varargout = s21_zdc(varargin)
% scan resonator s21 vs frequency and qubit z dc bias
% 
% <_o_> = s21_zdc('qubit',_c|o_,...
%       'freq',[_f_],'amp',[_f_],'updateSettings',<_b_>,'isDip',<_b_>,...
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

    fcn_name = 'data_taking.public.xmon.s21_zdc'; % this and args will be saved with data
    import qes.*
    import sqc.*
    import sqc.op.physical.*
    
    args = util.processArgs(varargin,{'gui',false,'notes','','save',true,...
		'updateSettings',false,'isDip',true});
    q = data_taking.public.util.getQubits(args,{'qubit'});
    
    dcSrc = qHandle.FindByClassProp('qes.hwdriver.hardware','name',q.channels.z_dc.instru);
    dcChnl = dcSrc.GetChnl(q.channels.z_dc.chnl);
    
    R = measure.resonatorReadout_ss(q,false,true);
    R.state = 1;
    R.swapdata = true;
    R.name = 'IQ';
    R.datafcn = @(x)mean(x);
    
    x = expParam(dcChnl,'dcval');
    x.name = [q.name,' dc bias'];
    y = expParam(R,'mw_src_frequency');
    y.offset = q.r_fc - q.r_freq;
    y.name = [q.name,' readout frequency'];
    s1 = sweep(x);
    s1.vals = args.amp;
    s2 = sweep(y);
    s2.vals = args.freq;
    e = experiment();
    e.name = 'S21-ZDC';
    e.sweeps = [s1,s2];
    e.measurements = R;
    e.datafileprefix = sprintf('%s_s21_zdc', q.name);
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
	if args.updateSettings && numel(args.amp) > 2
		data = abs(cell2mat(e.data{1}));
		if args.isDip
			data = -data;
		end
		peakFreqs = nan(1,numel(args.amp));
		for ii = 1:numel(args.amp)
			[~,ind] = max(data(ii,:));
			peakFreqs(ii) = args.freq(ind);
		end
		zdc2fr = polyfit(args.amp,peakFreqs,2);
		if args.gui
			h = qes.ui.qosFigure(sprintf('S21 vs ZDC. | %s', q.name),true);
			ax = axes('parent',h);
			hs = pcolor(ax,args.amp,args.freq/1e9,data.'); set(hs,'EdgeColor','none');
			hold(ax,'on');
			plot(ax,args.amp,peakFreqs/1e9,'+','Color',[1,1,1]);
			plot(ax,args.amp,polyval(zdc2fr,args.amp)/1e9,'-','Color',[1,1,1]);
			xlabel(ax,'zdc amplitude');
			ylabel(ax,'frequency (GHz)');
            colormap(jet);
            colorbar();
		end
		QS = qes.qSettings.GetInstance();
		QS.saveSSettings({q.name,'r_zdc2fr'},zdc2fr);
	end
    varargout{1} = e;
    data_taking.public.util.setZDC(q);
end