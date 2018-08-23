function varargout = updatef01byRamsey(varargin)
% update f01 at the current working point(defined by zdc_amp in registry)
% by ramsey: f01 already set previously, correctf01byRamsey is just to
% remeasure f01 in case f01 has drifted away slightly.
% note: T2* time can not be too short
%
% <_f_> = updatef01byRamsey('qubit',_c&o_,...
%       'robust',<_b_>,'gui',<_b_>,'save',<_b_>)
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
    
    % Yulin Wu, 2017/4/14
    
    MAXFREQDRIFT = 30e6;
    DELAYTIMERANGE = 500e-9;
    
    import data_taking.public.xmon.ramsey
    
    args = qes.util.processArgs(varargin,{'robust',true,'gui',false,'save',true});
	q = data_taking.public.util.getQubits(args,{'qubit'});
    da = qes.qHandle.FindByClassProp('qes.hwdriver.hardware','name',...
		q.channels.xy_i.instru);
    daChnl = da.GetChnl(q.channels.xy_i.chnl);
	daSamplingRate = daChnl.samplingRate;
    
    t = unique(round((0:3e-9:DELAYTIMERANGE)*daSamplingRate));
    e = ramsey('qubit',q,'mode','dp',... 
      'time',t,'detuning',MAXFREQDRIFT,'gui',false,'save',false);
    Pp = e.data{1};
    maP = max(Pp);
    miP = min(Pp);
    if maP < 0.75 || maP > 1.25 || miP < -0.25 || miP > 0.25
        if args.gui
            h = qes.ui.qosFigure(sprintf('Correct f01 by ramsey | %s', q.name),true);
            ax = axes('parent',h);
            plot(ax,t,Pp);
            legend(ax,{num2str(MAXFREQDRIFT/1e6,'%0.2fMHz'),'fit'});
            xlabel(ax,'time(us)');
            ylabel(ax,'P|1>');
            title('fitting failed.');
        end 
        throw(MException('QOS_correctf01byRamsey:probabilityNotProperlyCallibrated',...
				'probability not properly callibrated to SNR too low.'));
    end
    e = ramsey('qubit',q,'mode','dp',... 
      'time',t,'detuning',-MAXFREQDRIFT,'gui',false,'save',false);
    Pn = e.data{1};
    t = t/daSamplingRate;
    tf = linspace(t(1),t(end),200);
    
    % P = B*(exp(-t/td)*(sin(2*pi*freq*t+D)+C));

    [pxx,f] = plomb(Pp,t);
    [~,idx] = max(pxx);
    freqEstimation_p = f(idx);
    
    rng = range(Pp);
    [B,C,D,freqp,tdp,cip] =...
        toolbox.data_tool.fitting.sinDecayFit_m(t,Pp,...
        0.5*rng,[0.3*rng,rng*0.7],...
        1,[0.7,1.4],...
        pi/2,[-pi,pi],...
        freqEstimation_p,[0.95*freqEstimation_p,1.05*freqEstimation_p],...
        5e-6,[0.2e-6,100e6]);
    Ppf = B*(exp(-tf/tdp).*(sin(2*pi*freqp*tf+D)+C));
    
    
    dcip = diff(cip,1,2);
    failed = false;
    if  B < 0.3 || B > 0.7 || C < 0.5 || C > 2 ...
        || freqp < 2e6 || freqp > 1.7*MAXFREQDRIFT || freqp < 0.3*MAXFREQDRIFT...
        || abs(tdp) < 200e-9 || any(abs(dcip([1,2,4])./[B;C;freqp]) > 0.20)
    
        [A,B,C,freqp,cip] =...
            toolbox.data_tool.fitting.cosFit(t,Pp,...
            0.5*rng,[0.3*rng,rng*0.7],...
            pi/2,[-pi,pi],...
            1,[0.65,1.5],...
            freqEstimation_p,[0.9*freqEstimation_p,1.1*freqEstimation_p]);
        Ppf = A*(cos(2*pi*freqp*tf+B)+C);
        dcip = diff(cip,1,2);
        if  A < 0.3 || A > 0.7 || C < 0.5 || C > 2 ...
            || freqp < 2e6 || freqp > 1.7*MAXFREQDRIFT || freqp < 0.3*MAXFREQDRIFT || ...
            any(abs(dcip([1,3,4])./[A;C;freqp]) > 0.30)
            failed = true;
        end
    
        if failed
            if args.robust
                Ppf = freqEstimation_p;
            else
                if args.gui
                    h = qes.ui.qosFigure(sprintf('Correct f01 by ramsey | %s', q.name),true);
                    ax = axes('parent',h);
                    plot(ax,t,Pp,'.',tf,Ppf);
                    legend(ax,{num2str(MAXFREQDRIFT/1e6,'%0.2fMHz'),'fit'});
                    xlabel(ax,'time(us)');
                    ylabel(ax,'P|1>');
                    title('fitting failed.');
                end    
                throw(MException('QOS_correctf01byRamsey:fittingFailed',...
                        'fitting failed.'));
            end
        end
    end
    
    [pxx,f] = plomb(Pn,t);
    [~,idx] = max(pxx);
    freqEstimation_n = f(idx);
    
    rng = range(Pn);
    [B,C,D,freqn,tdn,cin] =...
        toolbox.data_tool.fitting.sinDecayFit_m(t,Pn,...
        0.5*rng,[0.3*rng,rng*0.7],...
        1,[0.7,1.4],...
        pi/2,[-pi,pi],...
        freqEstimation_n,[0.95*freqEstimation_n,1.05*freqEstimation_n],...
        5e-6,[0.2e-6,100e6]);
    Pnf = B*(exp(-tf/tdn).*(sin(2*pi*freqn*tf+D)+C));

    dcip = diff(cin,1,2);
    if B < 0.3 || B > 0.7 || C < 0.5 || C > 2 ...
        || freqn < 2e6 || freqn > 2*MAXFREQDRIFT || abs(tdn) < 200e-9 ||...
        any(abs(dcip([1,2,4])./[B;C;freqn]) > 0.20)
    
        [A,B,C,freqn,cip] =...
            toolbox.data_tool.fitting.cosFit(t,Pn,...
            0.5*rng,[0.3*rng,rng*0.7],...
            pi/2,[-pi,pi],...
            1,[0.65,1.5],...
            freqEstimation_n,[0.9*freqEstimation_n,1.1*freqEstimation_n]);
        Pnf = A*(cos(2*pi*freqn*tf+B)+C);
        dcip = diff(cip,1,2);
        if  A < 0.3 || A > 0.7 || C < 0.5 || C > 2 ...
            || freqn < 2e6 || freqn > 1.7*MAXFREQDRIFT || freqn < 0.3*MAXFREQDRIFT || ...
            any(abs(dcip([1,3,4])./[A;C;freqp]) > 0.30)
            failed = true;
        end
    
        if failed
            if args.robust
                Pnf = freqEstimation_n;
            else
                if args.gui
                    h = qes.ui.qosFigure(sprintf('Correct f01 by ramsey | %s', q.name),true);
                    ax = axes('parent',h);
                    plot(ax,tf/1e-6,Ppf,'-b',tf/1e-6,Pnf,'-r');
                    hold on;
                    plot(ax,t/1e-6,Pp,'.',t/1e-6,Pn,'.');
                    legend(ax,{'','',num2str(MAXFREQDRIFT/1e6,'%0.2fMHz'),num2str(-MAXFREQDRIFT/1e6,'%0.2fMHz')});
                    xlabel(ax,'time(us)');
                    ylabel(ax,'P|1>');
                    title('fitting failed.');
                    drawnow;
                end
                throw(MException('QOS_correctf01byRamsey:fittingFailed',...
                    'fitting failed.'));
            end
        end
    end
    
    if ((freqn + freqp)/2-MAXFREQDRIFT)/MAXFREQDRIFT > 0.05
        throw(MException('QOS_correctf01byRamsey:fittingFailed',...
				'fitting failed or frequency drift out of measureable range.'));
    end
    
    f01 = q.f01+(freqn - freqp)/2;
    
    if args.gui
        hf = qes.ui.qosFigure(sprintf('Correct f01 by ramsey | %s', q.name),true);
		ax = axes('parent',hf);
        plot(ax,tf/1e-6,Ppf,'-b',tf/1e-6,Pnf,'-r');
        hold on;
		plot(ax,t/1e-6,Pp,'.',t/1e-6,Pn,'.');
		legend(ax,{'','',num2str(MAXFREQDRIFT/1e6,'%0.2fMHz'),num2str(-MAXFREQDRIFT/1e6,'%0.2fMHz')});
		xlabel(ax,'time(us)');
		ylabel(ax,'P|1>');
        title(sprintf('Original f01: %0.5fGHz, current f01: %0.5fGHz',q.f01/1e9,f01/1e9));
        drawnow;
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
        QS.saveSSettings({q.name,'f01'},num2str(f01,'%0.6e'));
        if ~isempty(hf) && isvalid(hf)
            dataSvName = fullfile(QS.loadSSettings('data_path'),...
                ['corrF01_',q.name,'_',datestr(now,'yymmddTHHMMSS'),...
                num2str(ceil(99*rand(1,1)),'%0.0f'),'_.fig']);
            saveas(hf,dataSvName);
        end
    end
	varargout{2} = f01;
end
