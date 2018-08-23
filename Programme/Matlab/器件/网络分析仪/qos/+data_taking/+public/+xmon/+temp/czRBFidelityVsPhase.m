function varargout = czRBFidelityVsPhase(varargin)
% <_o_> = czRBFidelityVsPhase('controlQ',_c&o_,'targetQ',_c&o_,...
%       'phase_c',[_f_],'phase_t',[_f_],...
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

    fcn_name = 'data_taking.public.xmon.temp.czRBFidelityVsPhase'; % this and args will be saved with data
    import qes.*
    import sqc.*
    import sqc.op.physical.*

    args = util.processArgs(varargin,{'gui',false,'notes','','detuning',0,'save',true});
    [qc,qt] = data_taking.public.util.getQubits(args,{'controlQ','targetQ'});
    
    aczSettingsKey = sprintf('%s_%s',qc.name,qt.name);
    QS = qes.qSettings.GetInstance();
    scz = QS.loadSSettings({'shared','g_cz',aczSettingsKey});
    aczSettings = sqc.qobj.aczSettings(aczSettingsKey);
    fn = fieldnames(scz);
    for ii = 1:numel(fn)
        aczSettings.(fn{ii}) = scz.(fn{ii});
    end
    qc.aczSettings = aczSettings;

    % R = sqc.measure.randBenchMarking4Opt({qc,qt},args.numGates,args.numReps);
    persistent ridx;
    if isfield(args,'ridx')
        ridx = args.ridx;
    elseif isempty(ridx)
        ridx = sqc.measure.randBenchMarkingFS.CZRndSeq(args.numGates,args.numReps);
    end
    R = sqc.measure.randBenchMarkingFS({qc,qt},args.numGates,args.numReps,ridx);

    x = qes.expParam(aczSettings,'dynamicPhase(1)');
    x.name = [qc.name,' phase(rad)'];
    y = qes.expParam(aczSettings,'dynamicPhase(2)');
    y.name = [qt.name,' phase(rad)'];

	s1 = sweep(x);
    s1.vals = args.phase_c;
    s2 = sweep(y);
    s2.vals = args.phase_t;
    e = experiment();
    e.name = 'Fidelity vs CZ Phase';
    e.sweeps = [s1,s2];
    e.measurements = R;
    e.datafileprefix = sprintf('CZPhase%s%s',qc.name,qt.name);
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