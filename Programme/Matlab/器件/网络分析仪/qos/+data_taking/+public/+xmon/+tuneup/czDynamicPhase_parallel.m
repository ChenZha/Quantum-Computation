function varargout = czDynamicPhase_parallel(varargin)
% <_o_> = czDynamicPhase('controlQ',_c&o_,'targetQ',_c&o_,'dynamicPhaseQ',[_c&o_],...
%       'numCZs',<_i_>,'PhaseTolerance',<_f_>,'numIter',<_i_>...
%       'notes',<_c_>,'gui',<_b_>,'save',<_b_>,'logger',<_o_>)
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

    args = util.processArgs(varargin,{'numCZs',10,'PhaseTolerance',0.03,'numIter',1,'gui',false,'notes','','save',true});
    [qc,qt] = data_taking.public.util.getQubits(args,{'controlQ','targetQ'});
    
    dynamicPhaseQs = args.dynamicPhaseQs;
    if ~iscell(dynamicPhaseQs)
        dynamicPhaseQs = {dynamicPhaseQs};
    end
    numQs = numel(dynamicPhaseQs);
	Y = cell(1,numQs);
	for ii = 1:numQs
		if ischar(dynamicPhaseQs{ii})
			dynamicPhaseQs{ii} = sqc.util.qName2Obj(dynamicPhaseQs{ii});
        end
		Y{ii} = gate.Y2m(dynamicPhaseQs{ii});
	end

    czs = sqc.qobj.aczSettings(sprintf('%s_%s',qc.name,qt.name));
    czs.load();
    qc.aczSettings = czs;
    qt.aczSettings = czs;
    qdInd = nan(1,numQs);
    for ii = 1:numQs
        qdInd_ = qes.util.find(dynamicPhaseQs{ii}.name, czs.qubits);
        if isempty(qdInd_)
            error([dynamicPhaseQs{ii}.name ,' not one of the cz qubits.']);
        end
        qdInd(ii) = qdInd_;
    end

    p= [1e4,0];
    count = 0;
    while abs(p(1)) > args.PhaseTolerance && count < args.numIter
        CZ = gate.CZ(qc,qt);
        count = count + 1;
        x = 1:args.numCZs;
        data = nan(args.numCZs,numQs);
        for ii = 1:args.numCZs
            disp(['Iter ', num2str(count), ': ', num2str(ii),' of ', num2str(args.numCZs)]);
            proc = Y{1};
            for jj = 2:numQs
                proc = proc.*Y{jj};
            end
            proc = proc*(CZ^ii);
            R = sqc.measure.phase(dynamicPhaseQs);
            R.setProcess(proc);
            data(ii,:) = R();
        end
        data = unwrap(data,[],1);
        x = x(:);
        for jj = 1:numQs
            p = polyfit(x,data(:,jj),1);
            if args.gui
                hf = qes.ui.qosFigure(sprintf('ACZ dynamic phase | %s,%s,%s',...
                    qc.name, qt.name, dynamicPhaseQs{jj}.name),false);
                ax = axes('parent',hf);
                plot(ax,x,data(:,jj),'s',[0;x],polyval(p,[0;x]),'-r');
                xlabel(ax,'number of CZs');
                ylabel(ax,[dynamicPhaseQs{jj}.name,' phase(rad)']);
                legend(ax,{'data','linear fit'});
                title([dynamicPhaseQs{jj}.name, ' dynamic phase correction: ', num2str(p(1),'%0.4f')]);
                drawnow;
            else
                hf = [];
            end
            dp = czs.dynamicPhases(qdInd(jj)) + p(1);
            if dp > pi
                dp = dp - 2*pi;
            elseif dp <= -pi
                dp = dp + 2*pi;
            end
            czs.dynamicPhases(qdInd(jj)) = dp; % update for the next interation
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

    varargout{1} = czs.dynamicPhases;
end
    