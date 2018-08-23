function varargout = czPhaseTomo(varargin)
% <_o_> = czPhaseTomo('controlQ',_c&o_,'targetQ',_c&o_,...
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

	fcn_name = 'data_taking.public.xmon.czPhaseTomo'; % this and args will be saved with data
	args = util.processArgs(varargin,{'gui',false,'notes','','save',true});

    CZTomoData = data_taking.public.xmon.Tomo_2QProcess('qubit1',args.controlQ,'qubit2',args.targetQ,...
       'process','CZ','notes','','gui',false,'save',true);
   
    [theta1,theta2] = toolbox.data_tool.fitting.fitCZQPhase(CZTomoData);
    
    toolbox.data_tool.showprocesstomo_new(CZTomoData,CZTomoData);
    
    QS = qes.qSettings.GetInstance();
    aczSettingsKey = sprintf('%s_%s',args.controlQ,args.targetQ);
    scz = QS.loadSSettings({'shared','g_cz',aczSettingsKey});
    scz.dynamicPhases(1) = scz.dynamicPhases(1) + theta1;
    scz.dynamicPhases(2) = scz.dynamicPhases(2) + theta2;
    if args.save
        QS.saveSSettings({'shared','g_cz',aczSettingsKey,'dynamicPhases'},...
								scz.dynamicPhases);
    end

    varargout{1} = theta1;
    varargout{2} = theta2;
end