function varargout = spin_echo_df01(varargin)
% spin echo: detune by detuning iq frequency(sideband frequency)
% 
% <_o_> = spin_echo_df01('qubit',_c|o_,...
%       'time',[_i_],'detuning',<_f_>,...
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

    fcn_name = 'data_taking.public.xmon.spin_echo_df01'; % this and args will be saved with data
    import qes.*
    import sqc.*
    import sqc.op.physical.*

    args = util.processArgs(varargin,{'gui',false,'notes','','detuning',0,'save',true});
    if any(mod(args.time,2)~=0)
        throw(MException('QOS_spinEcho:invalidInput','time not even integers.'));
    end
    q = data_taking.public.util.getQubits(args,{'qubit'});
    
    da =  qHandle.FindByClassProp('qes.hwdriver.hardware','name',q.channels.xy_i.instru);
    daSamplingRate = da.samplingRate;

    X = op.XY(q,0);
    X2 = op.XY2(q,pi/2);
    X2_ = op.XY2(q,-pi/2);
    I = gate.I(q);
    R = measure.resonatorReadout_ss(q);
    function procFactory(delay)
        I.ln = delay/2;
        X.phase = pi/2+2*pi*args.detuning*delay/2/daSamplingRate;
        proc = X2_*I*X*I*X2;
        proc.Run();
        R.delay = proc.length;
    end

	x = expParam(X2,'f01');
    x.offset = X2.f01;
    x.name = [q.name,' detunning'];
	x_s =  expParam(X,'f01');
	x_s.offset = X.f01;
    y = expParam(@procFactory);
    y.name = [q.name,' time'];
	s1 = sweep({x,x_s});
    s1.vals = {args.detuning,args.detuning};
    s2 = sweep(y);
    s2.vals = args.time;
    e = experiment();
    e.sweeps = [s1,s2];
    e.measurements = R;
    e.name = 'Spin Echo(Detune by Sb. Freq.';
    e.datafileprefix = sprintf('%s',q.name);
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