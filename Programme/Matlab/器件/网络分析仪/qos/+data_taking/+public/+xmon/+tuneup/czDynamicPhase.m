% data_taking.public.xmon.tuneup.czDynamicPhase('controlQ',_c&o_,'targetQ',_c&o_,'dynamicPhaseQ',_c&o_,...
%       'numCZs',<_i_>,'PhaseTolerance',<_f_>,...
%       'gui',<_b_>,'save',<_b_>)
function varargout = czDynamicPhase(varargin)
% <_o_> = czDynamicPhase('controlQ',_c&o_,'targetQ',_c&o_,'dynamicPhaseQ',_c&o_,...
%       'numCZs',<_i_>,'PhaseTolerance',<_f_>,...
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

% Yulin Wu, 2017/10/14

    fcn_name = 'data_taking.public.xmon.tuneup.czDynamicPhase'; % this and args will be saved with data
    import qes.*
    import sqc.*
    import sqc.op.physical.*
    
    MAX_ITER = 3;

    args = util.processArgs(varargin,{'numCZs',10,'PhaseTolerance',0.03,'gui',false,'notes','','save',true});
    [qc,qt,qd] = data_taking.public.util.getQubits(args,{'controlQ','targetQ','dynamicPhaseQ'});
    
    czs = sqc.qobj.aczSettings(sprintf('%s_%s',qc.name,qt.name));
    czs.load();
    qc.aczSettings = czs;
    qt.aczSettings = czs;
    qdInd = qes.util.find(qd.name, czs.qubits);
    if isempty(qdInd)
        MAX_ITER = 1;
    end
 
    Y = gate.Y2m(qd);

    if args.gui
        hf = qes.ui.qosFigure(sprintf('ACZ dynamic phase | %s,%s,%s', qc.name, qt.name, qd.name),true);
        ax = axes('parent',hf);
    else
            hf = [];
        end

    p= [1e4,0];
    count = 0;
    while abs(p(1)) > args.PhaseTolerance && count < MAX_ITER
        CZ = gate.CZ(qc,qt);
        count = count + 1;
        x = 1:args.numCZs;
        data = NaN(1, args.numCZs);
        for ii = 1:args.numCZs
            disp(['Iter: ', num2str(count), 'num CZ: ', num2str(ii),' of ', num2str(args.numCZs)]);
            process = Y*(CZ^ii);
            R = sqc.measure.phase(qd);
            R.setProcess(process);
            data(ii) = R();
        end
        data = unwrap(data);
        p = polyfit(x,data,1);
        if args.gui
            if ~ishghandle(ax) % prevents failure when figure inadvertently closed by user
                hf = qes.ui.qosFigure(sprintf('ACZ dynamic phase | %s,%s,%s', qc.name, qt.name, qd.name),true);
                ax = axes('parent',hf);
            end
            plot(ax,x,data,'s',x,polyval(p,x),'-r');
            xlabel(ax,'number of CZs');
            ylabel(ax,[qd.name,' phase(rad)']);
            legend(ax,{'data','linear fit'});
            title([qd.name, ' dynamic phase correction: ', num2str(p(1),'%0.4f')]);
            drawnow;
        end
        if ~isempty(qdInd)
            czs.dynamicPhases(qdInd) = czs.dynamicPhases(qdInd) + p(1); % update for the next interation
        end
    end
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
        QS = qes.qSettings.GetInstance();
        QS.saveSSettings({'shared','g_cz',czs.key,'dynamicPhases'},czs.dynamicPhases);
    end

    varargout{1} = p(1);
end
    