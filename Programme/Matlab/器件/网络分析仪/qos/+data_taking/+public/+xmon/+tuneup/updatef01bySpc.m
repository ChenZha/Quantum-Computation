function varargout = updatef01bySpc(varargin)
% update f01 at the current working point(defined by zdc_amp in registry)
% by spectroscopy: f01 already set previously, correctf01bySpc is just to
% remeasure f01 in case f01 has drifted away slightly.
% note: estimation of the FWHM of the spectrum peak(t_spcFWHM_est) must be
% set with a resonable value, otherwise measuref01 might produce an
% incorrect result.
%
% <_f_> = updatef01bySpc('qubit',_c&o_,...
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
% arguments order not important as long as they form correct pairs.
    
    % Yulin Wu, 2017/4/14
    
    import data_taking.public.xmon.spectroscopy1_zpa
    
    args = qes.util.processArgs(varargin,{'gui',false,'save',true});
	q = data_taking.public.util.getQubits(args,{'qubit'});

    f = q.f01-10*q.t_spcFWHM_est:q.t_spcFWHM_est/15:q.f01+10*q.t_spcFWHM_est;
    e = spectroscopy1_zpa('qubit',q,'driveFreq',f,'save',false,'gui',false);
    P = e.data{1};
    
    % to deal with a bug(firt point always wrong), may not be needed in future versions
    f = f(2:end);
    P = P(2:end);
    
    rP = range(P);
    if rP < 0.1
        throw(MException('QOS_correctf01bySpc:visibilityTooLow',...
				'visibility(%0.2f) too low, run correctf01bySpc at low visibility might produce wrong result, thus not supported.', rP));
    end
    
    Ps = smooth(P,3);
    Ps = Ps - min(Ps); % P might have negative value in case of iq2prob parameters have drifted away
    rP = range(Ps);
    [pks,locs,~,p] = findpeaks(Ps,'SortStr','descend','MinPeakHeight',rP/2,...
        'MinPeakProminence',rP/2,'MinPeakDistance',numel(P)/5,...
        'WidthReference','halfprom');
    if numel(pks)
        [~,idx_] = sort(abs(locs - (numel(P)-1)/2),'descend');
        [~,rnk_locs] = sort(idx_,'ascend');
        [~,idx_] = sort(p,'descend');
        [~,rnk_p] = sort(idx_,'ascend');
        [~,pkIdx] = max(0.5*rnk_locs+rnk_p);
        f01 = f(locs(pkIdx));
    else
        throw(MException('QOS_correctf01bySpc:noPeaksFound',...
            'no peaks found.'));
    end
    
%     [~,idx] = max(smooth(P,5));
%     f01 = f(idx);
    
    if args.gui
        h = qes.ui.qosFigure(sprintf('Correct f01 by Spectroscopy | %s', q.name),true);
		ax = axes('parent',h);
		plot(ax,f,P,'-b');
		hold(ax,'on');
        ylim = get(ax,'YLim');
		plot(ax,[f01,f01],ylim,'--r');
		xlabel(ax,'xy drive frequency(Hz)');
		ylabel(ax,'P|1>');
        legend(ax,{'data',sprintf('f01:%0.5fGHz',f01/1e9)});
        set(ax,'YLim',ylim);
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
        QS.saveSSettings({q.name,'f01'},num2str(f01,'%0.5f'));
    end
	varargout{2} = f01;
end
