function varargout = czDetuneQPhaseTomoOpt(varargin)
% <_o_> = czDetuneQPhaseTomo('controlQ',_c&o_,'targetQ',_c&o_,'detuneQ',_c&o_,...
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

% Yulin Wu, 2017/7/2

    import qes.*
    import sqc.*
    import sqc.op.physical.*

	if nargin > 1  % otherwise playback
		fcn_name = 'data_taking.public.xmon.czDetuneQPhaseTomo'; % this and args will be saved with data
		args = util.processArgs(varargin,{'maxFEval',40,'gui',false,'notes','','save',true});
    end
    
    [qc,qt,qd] = data_taking.public.util.getQubits(args,{'controlQ','targetQ','detuneQ'});

    CZ = gate.CZ(qc,qt);
    Zc = sqc.op.physical.op.Z_arbPhase(qd,0);
    Y = sqc.op.physical.gate.Y2p(qd);
    R = measure.phase(qd);
    R.datafcn = @(x)abs(x);

    args.numCZs = 1;
    CZseq = CZ^args.numCZs;
    function procFactory(phase_)
        Zc.phase = args.numCZs*phase_;
        p = Y*CZseq*Zc;
        R.setProcess(p);
    end

    y = expParam(@procFactory);
    y.name = ['phase(rad)'];
    
    f = qes.expFcn(y,R);
    x0 = [-pi;pi]*0.5;
    tolX = [pi,pi]/1e3;
    tolY = [1e-3];
    
    h = qes.ui.qosFigure(sprintf('CZ detune Q phase | %s%s[%s] ', qc.name, qt.name, qd.name),false);
    axs(1) = subplot(2,1,2,'Parent',h);
    axs(2) = subplot(2,1,1);
    [optParams, x_trace, y_trace, n_feval] = qes.util.NelderMead(f.fcn, x0, tolX, tolY, args.maxFEval, axs);
    fval = y_trace(end);
    fval0 = y_trace(1);
    
    QS = qes.qSettings.GetInstance();
    aczSettingsKey = sprintf('%s_%s',qc.name,qt.name);
    scz = QS.loadSSettings({'shared','g_cz',aczSettingsKey});
    scz.dynamicPhase(3) = scz.dynamicPhase(3) - fval;
    if ischar(args.save)
        args.save = false;
        choice  = qes.ui.questdlg_timer(600,'Update settings?','Save options','Yes','No','Yes');
%         choice  = questdlg('Update settings?','Save options',...
%                 'Yes','No','No');
        if ~isempty(choice) && strcmp(choice, 'Yes')
            args.save = true;
        end
    end
    if args.save
        QS.saveSSettings({'shared','g_cz',aczSettingsKey,'dynamicPhase'},...
								scz.dynamicPhase);
        dataPath = QS.loadSSettings('data_path');
        TimeStamp = datestr(now,'_yymmddTHHMMSS_');
        dataFileName = ['CZDQPhase',TimeStamp,'.mat'];
        figFileName = ['CZDQPhase',TimeStamp,'.fig'];
        sessionSettings = QS.loadSSettings;
        hwSettings = QS.loadHwSettings;
        notes = 'CZDQPhase';
        save(fullfile(dataPath,dataFileName),'x_trace','y_trace','sessionSettings','hwSettings','notes');
        try
            saveas(h,fullfile(dataPath,figFileName));
        catch
            
        end
    end

    varargout{1} = fval;
end