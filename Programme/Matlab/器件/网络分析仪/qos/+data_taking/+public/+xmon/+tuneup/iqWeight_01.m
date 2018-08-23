function varargout = iqWeight_01(varargin)
% measures iq weight of state |0> and |1>
% 
% <[_f_]> = iqWeight_01('qubit',_c&o_,...
%       'gui',<_b_>,'save',<_b_>)
% _f_: float
% _i_: integer
% _c_: char or char string
% _b_: boolean
% _o_: object
% a&b: default type is a, but type b is also acceptable
% []: can be an array, scalar also acceptable
% {}: must be a cell array
% <>: optional, for input arguments, assume the default value if not specified
% arguments order not important as long as the form correct pairs.

% Yulin Wu, 2017

    import qes.*
    import sqc.*
    import sqc.op.physical.*
	
	SMOOTH_SPAN = 50;
	
	args = util.processArgs(varargin,{'gui',false,'save',true});
	q = data_taking.public.util.getQubits(args,{'qubit'});

    X = gate.X(q);
    R = measure.resonatorReadout(q);
    R.delay = q.g_XY_ln;
    R.iqRaw = true;
    
    X.Run();
    iq_raw_1 = R();
    iq_raw_0 = R();
    
    iqWeight1 = smooth(iq_raw_1,SMOOTH_SPAN);
    iqWeight0 = smooth(iq_raw_0,SMOOTH_SPAN);
    MAX = max(max(iqWeight1),max(iqWeight0));
    iqWeight1 = iqWeight1/MAX;
    iqWeight0 = iqWeight0/MAX;
    if args.gui
        hf = qes.ui.qosFigure('IQ Weight',true);
        ax = axes('parent',hf);
        plot(ax,abs(iqWeight0),'.b');
        hold(ax,'on');
        plot(ax, abs(iqWeight1),'.r');
        legend('|0>','|1>');
    else
            hf = [];
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
        save(fullfile(QS.root,QS.user,QS.session,q.name,'_data','iqWeight.mat'),'iqWeight1','iqWeight0')
    end

	varargout{1} = iqWeight0;
	varargout{1} = iqWeight1;
end