function varargout = f21(varargin)
% measure f21 frequency
% detune by changing the second pi/2 pulse tracking frame
% 
% <_o_> = f21('qubit',_c|o_,...
%       'ahFreq',[_i_],'sbFreq',<_f_>,...
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

    fcn_name = 'data_taking.public.xmon.f21'; % this and args will be saved with data
    import qes.*
    import sqc.*
    import sqc.op.physical.*

    args = util.processArgs(varargin,{'sbFreq',[],'gui',false,'notes','','save',true});
    q = data_taking.public.util.getQubits(args,{'qubit'});
    if ~isempty(args.sbFreq)
        q.qr_xy_fc = q.f01 + args.sbFreq;
    end
    if any(args.ahFreq >= 0)
        throw(MException('QOS_f21:invalidInput','ahFreq not negative.'));
    end
   
    X = gate.X(q);
    I = gate.I(q);
    R = measure.resonatorReadout_ss(q);
    R.state = 1;
    function procFactory(ah)
        proc = I*X;
        q.f01 = q.f01 + ah;
        switch q.g_XY_impl
            case 'hPi'
                q.g_XY2_ln = 50*q.g_XY2_ln;
                q.g_XY2_amp = q.g_XY2_amp/50;
                X_ = sqc.op.physical.gate.X(q);
                proc = proc*X_;
                q.g_XY2_ln = q.g_XY2_ln/50;
                q.g_XY2_amp = 50*q.g_XY2_amp;
            case 'pi'
                q.g_XY_ln = 50*q.g_XY_ln;
                q.g_XY_amp = q.g_XY_amp/50;
                X_ = sqc.op.physical.gate.X(q);
                proc = proc*X_;
                q.g_XY_ln = q.g_XY_ln/50;
                q.g_XY_amp = 50*q.g_XY_amp;
            otherwise
                error('invalid g_XY_impl setting');
        end
        q.f01 = q.f01 - ah;
        proc = proc*X;
        proc.Run();
        R.delay = proc.length;
    end
    x = expParam(@procFactory);
    x.name = [q.name,' f21-f10'];
	s1 = sweep(x);
    s1.vals = args.ahFreq;
    e = experiment();
    e.name = 'f21';
    e.sweeps = [s1];
    e.measurements = R;
    e.datafileprefix = sprintf('%s[f21]',q.name);
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