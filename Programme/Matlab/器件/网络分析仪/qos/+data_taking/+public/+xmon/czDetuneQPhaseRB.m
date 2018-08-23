function varargout = czDetuneQPhaseRB(varargin)
% <_o_> = czDetuneQPhaseRB('controlQ',_c|o_,'targetQ',_c|o_,'detuneQ',_c|o_,...
%       'phase',[_i_],'numGates',_i_,'numShots',_i_,...
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
		fcn_name = 'data_taking.public.xmon.czDetuneQPhaseRB'; % this and args will be saved with data
		args = util.processArgs(varargin,{'cState','0','readoutQubit',[],'gui',false,'notes','','save',true});
	end
	
    [qc,qt,qd] = data_taking.public.util.getQubits(args,{'controlQ','targetQ','detuneQ'});

    CZ = gate.CZ(qc,qt);
    Zc = sqc.op.physical.op.Z_arbPhase(qd,0);
    % R = sqc.measure.randBenchMarkingFS(qd,args.numGates,args.numShots);
    R = sqc.measure.randBenchMarking4Opt(qd,args.numGates,args.numShots,CZ*Zc);

    function procFactory(phase_)
        Zc.phase = phase_;
        p = CZ*Zc;
        R.changeProcessTo(p);
    end

    y = expParam(@procFactory);
    y.name = ['phase(rad)'];
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