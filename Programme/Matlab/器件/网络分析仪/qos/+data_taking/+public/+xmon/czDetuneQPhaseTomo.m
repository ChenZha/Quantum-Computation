function varargout = czDetuneQPhaseTomo(varargin)
% <_o_> = czDetuneQPhaseTomo('controlQ',_c|o_,'targetQ',_c|o_,'detuneQ',_c|o_,...
%       'phase',[_i_],'numCZs',_i_,...
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

% Yulin Wu, 2017/7/2

    
    import qes.*
    import sqc.*
    import sqc.op.physical.*

	if nargin > 1  % otherwise playback
		fcn_name = 'data_taking.public.xmon.czDetuneQPhaseTomo'; % this and args will be saved with data
		args = util.processArgs(varargin,{'numCZs',1,'gui',false,'notes','','save',true});
    end
    
    assert(args.numCZs >= 1);
	
    [qc,qt,qd] = data_taking.public.util.getQubits(args,{'controlQ','targetQ','detuneQ'});

    CZ = gate.CZ(qc,qt);
    % Zc = sqc.op.physical.op.Z_arbPhase(qd,0);
    Y = sqc.op.physical.gate.Y2p(qd);
    R = measure.phase(qd);

    CZseq = CZ^args.numCZs;
    function procFactory(phase_)
        Zc.phase = args.numCZs*phase_;
        p = Y*CZseq;
        R.setProcess(p);
    end

    y = expParam(@procFactory);
    y.name = ['phase compensation(rad)'];
    s2 = sweep(y);
    s2.vals = args.phase;
    e = experiment();
    e.name = 'ACZ Detune Q phase';
    e.sweeps = [s2];
    e.measurements = R;
    e.datafileprefix = sprintf('CZ%s%s%s', qc.name,qt.name,qd.name);
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