function varargout = zGateAmpTuner(varargin)
% zGateAmpTuner: tune z gate amplitude
% 
% <_o_> = zGateAmpTuner('qubit',_c&o_,...
%       'time',[_i_],'detuning',<[_f_]>,...
%       'dataTyp',<'_c_'>,...   % S21 or P
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

    fcn_name = 'data_taking.public.xmon.zGateAmpTuner'; % this and args will be saved with data
    import qes.*
    import sqc.*
    import sqc.op.physical.*

    args = util.processArgs(varargin,{'detuning',0,'dataTyp','P',...
        'gui',false,'notes','','detuning',0,'save',true});
    q = data_taking.public.util.getQubits(args,{'qubit'});
    
    error('todo...');

    X2 = gate.X2p(q);
    I = op.detune(q);
    R = measure.resonatorReadout_ss(q);
 
    switch args.dataTyp
        case 'P'
            % pass
        case 'S21'
            R.swapdata = true;
            R.name = 'iq';
            R.datafcn = @(x)mean(abs(x));
        otherwise
            throw(MException('QOS_zGateAmpTuner:unrcognizedDataTyp',...
                'unrecognized dataTyp %s, available dataTyp options are P and S21.', args.dataTyp));
    end

    function proc = procFactory(delay)
        I.ln = delay;
        proc = X2*I*X2;
    end

    x = expParam(I,'df');
    x.name = [q.name,' detunning'];
    y = expParam(@procFactory);
    y.name = [q.name,' time'];
    y.callbacks ={@(x_) x_.expobj.Run()};

    y_s = expParam(R,'delay');
	y_s.offset = 2*X2.length+3*X2.gate_buffer;
    y_s.snap_val = R.adDelayStep;
    s1 = sweep(x);
    s1.vals = args.detuning;
    s2 = sweep({y,y_s});
    s2.vals = {args.time,args.time};
    e = experiment();
	e.name = 'zGateAmpTuner';
    e.sweeps = [s1,s2];
    e.measurements = R;
    
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