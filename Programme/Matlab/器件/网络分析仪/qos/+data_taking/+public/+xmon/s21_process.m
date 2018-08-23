function varargout = s21_process(varargin)
% scan resonator s21 vs frequency, with qubit process
% 
% <_o_> = s21_rAmp('qubit',_c|o_,...
%       'freq',[_f_],'process',_c|o_,...
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
    
    args = util.processArgs(varargin,{'amp',[],'r_avg',[],'gui',false,'notes','','save',true});
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
    R.delay = args.process.length;
    
    x = expParam(R,'mw_src_frequency');
    x.offset = q.r_fc - q.r_freq;
    x.name = [q.name,' readout frequency'];
    process = args.process;
    x.callbacks = {@(x) process.Run()};
    args.process = [];
   
    s1 = sweep(x);
    s1.vals = args.freq;
    
    e = experiment();
    e.name = 'S21';
    e.sweeps = [s1];
    e.measurements = R;
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
    varargout{1} = e;
end