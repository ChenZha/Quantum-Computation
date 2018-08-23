function varargout = czRBFidelityVsPlsCalParam(varargin)
% <_o_> = czRBFidelityVsPlsCalParam('controlQ',_c&o_,'targetQ',_c&o_,...
%       'rAmplitude',[_f_],'td',[_f_],'calcControlQ',_b_,...
%       'numGates',_i_,'numReps',_i_,...
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
% arguments order not important as long as they form correct pairs.

% Yulin Wu, 2016/12/27

    fcn_name = 'data_taking.public.xmon.temp.czRBFidelityVsPlsCalParam'; % this and args will be saved with data
    import qes.*
    import sqc.*
    import sqc.op.physical.*

    args = util.processArgs(varargin,{'gui',false,'notes','','detuning',0,'save',true});
    [qc,qt] = data_taking.public.util.getQubits(args,{'controlQ','targetQ'});

    args.ridx = sqc.measure.randBenchMarkingFS.CZRndSeq(args.numGates,args.numReps);
    R = sqc.measure.randBenchMarkingFS({qc,qt},args.numGates,args.numReps,args.ridx);
    
    if args.calcControlQ
        da = qes.qHandle.FindByClassProp('qes.hwdriver.hardware',...
                     'name',qc.channels.z_pulse.instru);
        z_daChnl = da.GetChnl(qc.channels.z_pulse.chnl);
    else
        da = qes.qHandle.FindByClassProp('qes.hwdriver.hardware',...
                     'name',qt.channels.z_pulse.instru);
        z_daChnl = da.GetChnl(qt.channels.z_pulse.chnl);
    end
    lowPassFilterSettings0 = struct('type','function',...
                'funcName','com.qos.waveform.XfrFuncFastGaussianFilter',...
                'bandWidth',0.130);
    rAmp = qes.util.hvar(0.015);
	td = qes.util.hvar(800);
    
    function setXfrFunc()
        lowPassFilter = qes.util.xfrFuncBuilder(lowPassFilterSettings0);
        xfrFunc_ = qes.util.xfrFuncBuilder(...
            struct('type','function',...
            'funcName','qes.waveform.xfrFunc.gaussianExp',...
            'bandWidth',0.25,...
            'rAmp',[rAmp.val],...
            'td',[td.val]));
        rAmp.val, td.val
        xfrFunc = lowPassFilter.add(xfrFunc_.inv());
        z_daChnl.xfrFunc = xfrFunc;
    end
    x = qes.expParam(rAmp,'val');
    x.callbacks = {@(x)setXfrFunc()};
    x.name = 'rAmplitude';
    y = qes.expParam(td,'val');
    y.callbacks = {@(x)setXfrFunc()};
    y.name = 'td';

	s1 = sweep(x);
    s1.vals = args.rAmplitude;
    s2 = sweep(y);
    s2.vals = args.td;
    e = experiment();
    e.name = 'Fidelity vs Pulse Calc. Params';
    e.sweeps = [s1,s2];
    e.measurements = R;
    e.datafileprefix = sprintf('CZPlsCalc%s%s',qc.name,qt.name);
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