function varargout = Tomo_mQState(varargin)
% demonstration of state tomography on multiple qubits.
% state tomography is a measurement, it is not used alone in real
% applications, this simple function is just a demonstration/test to show
% that state tomography is working properly.
% prepares a a state(options are: '|00>')
% and do state tomography.
%
% <_o_> = Tomo_2QState('qubits',[_c|o_],...
%       'state',<_c_>,...
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

% Yulin Wu, 2017

    import qes.*
    import sqc.*
    import sqc.op.physical.*

    args = util.processArgs(varargin,{'state','0','gui',false,'notes','','save',true});
    
    if ~iscell(args.qubits)
        qubits = {args.qubits};
    else
        qubits = args.qubits;
    end
    numTomoQs = numel(qubits);
    for ii = 1:numTomoQs
        if ischar(qubits{ii})
            qubits{ii} = sqc.util.qName2Obj(qubits{ii});
        end
    end

    R = measure.stateTomography(qubits);

    switch args.state
        case '0'
            p = gate.I(qubits{1});
        case '1'
            p = gate.X(qubits{1});
            for ii = 2:numel(qubits)
                p = p.*gate.X(qubits{ii});
            end
        case {'+'}
            p = gate.Y2p(qubits{1});
            for ii = 2:numel(qubits)
                p = p.*gate.Y2p(qubits{ii});
            end
        case {'-'}
            p = gate.Y2m(qubits{1});
            for ii = 2:numel(qubits)
                p = p.*gate.Y2m(qubits{ii});
            end
        case {'i'}
            p = gate.X2m(qubits{1});
            for ii = 2:numel(qubits)
                p = p.*gate.X2m(qubits{ii});
            end
        case {'-i'}
            p = gate.X2p(qubits{1});
            for ii = 2:numel(qubits)
                p = p.*gate.X2p(qubits{ii});
            end
        otherwise
            throw(MException('QOS_singleQStateTomo:unsupportedStae',...
                sprintf('available state options for singleQStateTomo is %s, %s given.',...
                '0,1,+,-,i,-i',args.state)));
    end
    
    R.setProcess(p);
    P = R();

    if args.gui
        hf = qes.ui.qosFigure(sprintf('State tomography' ),true);
        ax = axes('parent',hf);
        qes.util.plotfcn.StateTomographyLine(P,ax,sprintf('%d qubits state |%s>(each qubit) tomography', numel(qubits),args.state));
    end
    if args.save
        QS = qes.qSettings.GetInstance();
        dataPath = QS.loadSSettings('data_path');
        dataFileName = ['STomo',datestr(now,'_yymmddTHHMMSS_')];
        sessionSettings = QS.loadSSettings;
        hwSettings = QS.loadHwSettings;
        save(fullfile(dataPath,[dataFileName,'.mat']),'P','args','sessionSettings','hwSettings');
        if args.gui && isgraphics(hf)
            saveas(hf,fullfile(dataPath,[dataFileName,'.fig']));
        end
    end
    varargout{1} = P;
end