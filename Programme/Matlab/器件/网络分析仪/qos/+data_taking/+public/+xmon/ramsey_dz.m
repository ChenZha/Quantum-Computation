function varargout = ramsey_dz(varargin)
% ramsey_dz: ramsey oscillation, detune by z detune pulse
% 
% <_o_> = ramsey_dz('qubit',_c&o_,...
%       'time',[_i_],'detuning',<[_f_]>,'phaseOffset',<_f_>,...
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
% GM, 2017/12/3

    fcn_name = 'data_taking.public.xmon.ramsey_dz'; % this and args will be saved with data
    import qes.*
    import sqc.*
    import sqc.op.physical.*

    args = util.processArgs(varargin,{'biasqubit',[],'r_avg',[],'phaseOffset',0,'detuning',0,'dataTyp','P',...
        'gui',false,'notes','','detuning',0,'save',true});
    if isempty(args.biasqubit)
        args.biasqubit=args.qubit;
    end
    [q,biasq] = data_taking.public.util.getQubits(args,{'qubit','biasqubit'});
    
    X2 = op.XY2(q,0);
    I = gate.I(q);
    Z = op.zBias4Spectrum(biasq);
    R = measure.resonatorReadout_ss(q);
 
    switch args.dataTyp
        case 'P'
            R.state = 2;
        case 'S21'
            R.swapdata = true;
            R.name = 'iq';
            R.datafcn = @(x)mean(abs(x));
        otherwise
            throw(MException('QOS_ramsey_dz:unrcognizedDataTyp',...
                'unrecognized dataTyp %s, available dataTyp options are P and S21.', args.dataTyp));
    end

    X2_ = op.XY2(q,0);
    X2.phi = args.phaseOffset;
    function procFactory(delay)
%         X2_.f01=polyval(q.zpls_amp2f01,Z.amp)-3e6;
%         X2.f01=polyval(q.zpls_amp2f01,Z.amp)-3e6;
        Z.ln = delay;
        proc = X2_*Z*X2;
        proc.Run();
        R.delay = proc.length;
    end

    x = expParam(Z,'amp');
    x.name = [q.name,' detunneAmp'];
    y = expParam(@procFactory);
    y.name = [q.name,' time'];
    s1 = sweep(x);
    s1.vals = args.detuning;
    s2 = sweep(y);
    s2.vals = args.time;
    e = experiment();
    e.name = 'Ramsey(Detune by Z)';
    e.sweeps = [s1,s2];
    e.measurements = R;
    e.datafileprefix = sprintf('%s_Ramsey_', q.name);
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