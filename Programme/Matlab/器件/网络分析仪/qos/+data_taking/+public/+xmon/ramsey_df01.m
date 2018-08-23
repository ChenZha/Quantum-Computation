function varargout = ramsey_df01(varargin)
% ramsey: ramsey oscillation, detune by detuning iq frequency(sideband frequency)
% 
% <_o_> = ramsey_df01('qubit',_c|o_,...
%       'time',[_i_],'detuning',<[_f_]>,'phaseOffset',<_f_>,...
%       'dataTyp',<'_c_'>,...   % S21 or P
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

    fcn_name = 'data_taking.public.xmon.ramsey_df01'; % this and args will be saved with data
    import qes.*
    import sqc.*
    import sqc.op.physical.*

    args = util.processArgs(varargin,{'phaseOffset',0,'dataTyp','P','detuning',0,'gui',false,'notes','','save',true});
    q = data_taking.public.util.getQubits(args,{'qubit'});

    X2 = op.XY2(q,pi/2+args.phaseOffset);
    X2_ = op.XY2(q,-pi/2);
    I = gate.I(q);

    switch args.dataTyp
        case 'P'
            R = measure.resonatorReadout_ss(q);
            R.state = 2;
        case 'S21'
            R = measure.resonatorReadout_ss(q,false,true);
            R.swapdata = true;
            R.name = 'iq';
            R.datafcn = @(x)abs(mean(x));
        otherwise
            throw(MException('QOS_ramsey_df01:unrcognizedDataTyp','unrecognized dataTyp %s, available dataTyp options are P and S21.', args.dataTyp));
    end
    
    function procFactory(delay)
        I.ln = delay;
        proc = X2_*I*X2;
        proc.Run();
        R.delay = proc.length;
    end

    x = expParam(X2,'f01');
    x.offset = X2.f01;
    x.name = [q.name,' detunning'];
    y = expParam(@procFactory);
    y.name = [q.name,' time'];
    s1 = sweep(x);
    s1.vals = args.detuning;
    s2 = sweep(y);
    s2.vals = args.time;
    e = experiment();
	e.name = 'Ramsey(Detune by Sb. Freq.)';
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