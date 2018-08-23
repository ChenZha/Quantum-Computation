function varargout = czDetuneQPhaseFit(varargin)
% <_o_> = czDetuneQPhaseFit('controlQ',_c&o_,'targetQ',_c&o_,...
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

    fcn_name = 'data_taking.public.xmon.tuneup.czDetuneQPhaseFit'; % this and args will be saved with data
    import qes.*
    import sqc.*
    import sqc.op.physical.*

    args = util.processArgs(varargin,{'numCZs',1,'gui',false,'notes','','save',true});
    [qc,qt,qd] = data_taking.public.util.getQubits(args,{'controlQ','targetQ','detuneQ'});
    
    aczSettingsKey = sprintf('%s_%s',qc.name,qt.name);
    QS = qes.qSettings.GetInstance();
    scz = QS.loadSSettings({'shared','g_cz',aczSettingsKey});
    
    e = data_taking.public.xmon.czDetuneQPhaseTomo(...
       'controlQ',qc,'targetQ',qt,'detuneQ',qd,...
       'phase',args.phase,'numCZs',args.numCZs,... 
       'notes','','gui',false,'save',false);
   
    data = unwrap(e.data{1})/pi;

    fdp = polyfit(args.phase(:),data,2);
    rd=roots(fdp);
    phase0=rd(find(rd>args.phase(1)&rd<args.phase(end)));
    
    if isempty(phase0)
        if args.gui
            hf = qes.ui.qosFigure(sprintf('CZ%s%s%s', qc.name,qt.name,qd.name),true);
            ax = axes('parent',hf);
            plot(ax,args.phase,data,'.b',args.phase,polyval(fdp,args.phase),'-g');
            xlabel(ax,'phase shift(\pi)');
            ylabel(ax,'phase(\pi)');
            title('not found! Probably out of range.');
        else
            hf = [];
        end
        error('not found! Probably out of range.');
    end
    scz.dynamicPhase(3) = scz.dynamicPhase(3) + phase0;
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
        QS.saveSSettings({'shared','g_cz',aczSettingsKey,'dynamicPhase'},scz.dynamicPhase);
    end
    
    args.phase = args.phase/pi;
    
    if args.gui
        hf = qes.ui.qosFigure(sprintf('CZ%s%s%s', qc.name,qt.name,qd.name),true);
        ax = axes('parent',hf);
        plot(ax,args.phase,data,'.b',args.phase,polyval(fdp,args.phase),'-g',...
            phase0,zeros(1,length(args.phase)),'-k');
        xlabel(ax,[qd.name, 'phase shift(\pi)']);
        ylabel(ax,[qd.name,' phase(\pi)']);
        title(sprintf('phase0: %0.5e',phase0));
    end
end
    