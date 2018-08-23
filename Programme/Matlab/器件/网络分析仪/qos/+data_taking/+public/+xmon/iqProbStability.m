function varargout = iqProbStability(varargin)
% IQ and probability stability over time
% 
% <[_f_]> = iqProbStability('qubit',_c|o_,...
%       'timeSpan',_f_,... % in seconds
%       'gui',<_b_>,'save',<_b_>)
% _f_: float
% _i_: integer
% _c_: char or char string
% _b_: boolean
% _o_: object
% a|b: default type is a, but type b is also acceptable
% []: can be an array, scalar also acceptable
% {}: must be a cell array
% <>: optional, for input arguments, assume the default value if not specified
% arguments order not important as long as the form correct pairs.

% Yulin Wu, 2017

    import qes.*
    import sqc.*
    import sqc.op.physical.*
	
	args = util.processArgs(varargin,{'gui',false,'save',true});
	q = data_taking.public.util.getQubits(args,{'qubit'});

    X = gate.X(q);
    X2 = gate.Y2p(q);
    R = measure.resonatorReadout(q,false,true);
    R.delay = max(X.length,X2.length);
    
    hf = qes.ui.qosFigure(sprintf('IQ stability' ),false);
    ax1 = axes('parent',hf,'Position',[0.1,0.1,0.85,0.35]);
    ax2 = axes('parent',hf,'Position',[0.1,0.6,0.85,0.35]);
    
    QS = qes.qSettings.GetInstance();
    dataPath = QS.loadSSettings('data_path');
    dataFileName = ['iqStability',datestr(now,'_yymmddTHHMMSS_')];
    sessionSettings = QS.loadSSettings;
    hwSettings = QS.loadHwSettings;
    
    iqCenter = (q.r_iq2prob_center0 + q.r_iq2prob_center1)/2;

    iq_raw_1 = [];
    iq_raw_0 = [];
    iq_raw_plus = [];
    Pplus = [];
    Time = [];
    ii = 0;
    tic;
    while 1
        ii = ii +1;
        Time(ii) = toc;
        
        X.Run();
        R.Run();
        iq_raw_1(ii,:) = R.extradata - iqCenter;
        
        R.Run();
        iq_raw_0(ii,:) = R.extradata - iqCenter;
        
        X2.Run();
        R.Run();
        iq_raw_plus(ii,:) = R.extradata - iqCenter;
        Pplus(ii,:) = R.data;
        
        try
            plot(ax1,Time/60,angle(mean(iq_raw_0,2)),...
                Time/60,angle(mean(iq_raw_1,2)),...
                Time/60,angle(mean(iq_raw_plus,2)));
            legend(ax1,{'|0>','|1>','|0>+|1>'});
            xlabel(ax1,'Time(min.)');
            ylabel(ax1,'IQ angle');
            plot(ax2,Time/60,Pplus(:,1),Time/60,Pplus(:,2));
            legend(ax2,{'P|0>','P|1>'});
            xlabel(ax2,'Time(min.)');
            ylabel(ax2,'P');
        catch
            hf = qes.ui.qosFigure(sprintf('IQ stability' ),false);
            ax1 = axes('parent',hf,'Position',[0.1,0.1,0.85,0.35]);
            ax2 = axes('parent',hf,'Position',[0.1,0.6,0.85,0.35]);
        end
        
        save(fullfile(dataPath,[dataFileName,'.mat']),...
            'iq_raw_1', 'iq_raw_0', 'iq_raw_plus', 'Pplus', 'Time',...
            'args','sessionSettings','hwSettings');
        try
            if isgraphics(hf)
                saveas(hf,fullfile(dataPath,[dataFileName,'.fig']));
            end
        catch
        end

        if Time(ii) > args.timeSpan
            break;
        end
    end
end