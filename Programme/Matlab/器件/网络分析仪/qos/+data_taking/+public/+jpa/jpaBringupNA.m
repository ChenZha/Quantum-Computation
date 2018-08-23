function varargout = jpaBringupNA(varargin)
% function name changed from s21_BiasPwrpPwrs_networkAnalyzer to jpaBringupNA
% [s21] vs [bias], [pump frequency], [pumpPower],with network analyser
% 
% <_o_> = jpaBringupNA('jpa',_c&o_,...
%       'startFreq',_f_,'stopFreq',_f_,...
%       'numFreqPts',_i_,'avgcounts',_i_,...
%       'NAPower',_f_,'bandwidth',_f_,...
%       'pumpFreq',[_f_],'pumpPower',[_f_],...
%       'biasAmp',[_f_],...
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

    fcn_name = 'data_taking.public.jpa.jpaBringupNA'; % this and args will be saved with data
    import qes.*
    
    args = util.processArgs(varargin,{'gui',false,'notes','','save',true});
    jpa = data_taking.public.util.getJPAs(args,{'jpa'});

    na = qHandle.FindByClassProp('qes.hwdriver.hardware',...
                    'name',jpa.channels.signal_da_i.instru); % changed settings signal_i to signal_da_i to be compatible with jpa bringup with DAC/ADC, Yulin Wu, 170524
	% needs checking here because na could be a DAC
    if ~isa(na,'qes.hwdriver.sync.networkAnalyzer') && ~isa(na,'qes.hwdriver.async.networkAnalyzer')
        throw(MException('s21_BiasPumpPwrPumpFreq_networkAnalyzer:inValidSettings',...
              sprintf('the signal source %s is not a network analyzer.',jpa.channels.signal_da_i.instru)));
    end
    biasSrc = qHandle.FindByClassProp('qes.hwdriver.hardware','name',jpa.channels.bias.instru);
	% needs checking here because biasSrc could be a DAC
	if ~isa(biasSrc,'qes.hwdriver.sync.dcSource') && ~isa(na,'qes.hwdriver.async.dcSource')
        throw(MException('s21_BiasPumpPwrPumpFreq_networkAnalyzer:inValidSettings',...
              sprintf('the bias source %s is not a dc source.',jpa.channels.bias.instru)));
    end
	biasChnl = biasSrc.GetChnl(jpa.channels.bias.chnl);
    pumpMwSrc = qHandle.FindByClassProp('qes.hwdriver.hardware','name',jpa.channels.pump_mw.instru);
	pumpMwSrc = pumpMwSrc.GetChnl(jpa.channels.pump_mw.chnl);
    
    s = [];
    if numel(args.biasAmp) == 1
        biasChnl.dcval = args.biasAmp;
        biasChnl.on = true;
    else
        x = expParam(biasChnl,'dcval');
        x.name = 'bias amplitude';
        x.callbacks = {@(x)biasChnl.On(), @(x)pause(0.5)};
        s_ = sweep(x);
        s_.vals = args.biasAmp;
        s = [s,s_];
    end
    
    if numel(args.pumpFreq) == 0
        pumpMwSrc.on = false;
    elseif numel(args.pumpFreq) == 1
        pumpMwSrc.frequency = args.pumpFreq;
        pumpMwSrc.on = true;
    else
        x = expParam(pumpMwSrc,'frequency');
        x.name = 'pump frequency(Hz)';
        x.callbacks = {@(x)pumpMwSrc.On()};
        s_ = sweep(x);
        s_.vals = args.pumpFreq;
        s = [s,s_];
    end
    
    if numel(args.pumpPower) == 0
        pumpMwSrc.on = false;
    elseif numel(args.pumpPower) <= 1
        pumpMwSrc.power = args.pumpPower;
        pumpMwSrc.on = true;
    else
        x = expParam(pumpMwSrc,'power');
        x.name = 'pump power(dBm)';
        x.callbacks = {@(x)pumpMwSrc.On()};
        s_ = sweep(x);
        s_.vals = args.pumpPower;
        s = [s,s_];
    end
    
    if isempty(s) % we need at least one sweep
        x = expParam(biasChnl,'dcval');
        x.name = 'bias amplitude';
        x.callbacks = {@(x)biasChnl.On(), @(x)pause(0.5)};
        s_ = sweep(x);
        s_.vals = args.biasAmp;
        s = [s,s_];
    end

    na.swpstartfreq = args.startFreq;
    na.swpstopfreq = args.stopFreq;
    na.swppoints = args.numFreqPts;
    na.bandwidth = args.bandwidth;
    na.avgcounts = args.avgcounts;
    na.power = args.NAPower;
    pause(1);
    
    R = qes.measurement.sParam(na);
    R.name = 'S21';

    e = experiment();
    e.name = 'JPA Bringup(NA)';
    e.sweeps = s;
    e.measurements = R;
    e.plotfcn = @util.plotfcn.sparam.Amplitude;
    
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