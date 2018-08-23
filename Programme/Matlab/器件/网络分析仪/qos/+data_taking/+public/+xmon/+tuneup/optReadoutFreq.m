function varargout = optReadoutFreq(varargin)
% finds the optimal readout resonator probe frequency for qubit
%
% <_f_> = optReadoutFreq('qubit',_c&o_,...
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
    
    % Yulin Wu, 2017/1/14
    
    import qes.*
    import data_taking.public.xmon.s21_01
	import data_taking.public.util.getQubits

    args = util.processArgs(varargin,{'gui',false,'save',true});
	q = data_taking.public.util.getQubits(args,{'qubit'});
	
    R_AVG_MIN = 1e3;
    if q.r_avg < R_AVG_MIN
        q.r_avg = R_AVG_MIN;
    end
    frequency = q.r_freq-4*q.t_rrDipFWHM_est:q.t_rrDipFWHM_est/20:q.r_freq+4*q.t_rrDipFWHM_est;
    e = s21_01('qubit',q,'freq',frequency);
    data = e.data{1};
    data = data(2:end,:); % 2:end, drop first point to deal with an ad bug, may not be necessary in future versions
    frequency = frequency(2:end);
%     data(:,1) = abs(data(:,1)).*...
%         exp(1i*qes.util.removeJumps(angle(data(:,1)),0.2*pi)); % remove mw source phase jumps
%     data(:,2) = abs(data(:,2)).*...
%         exp(1i*qes.util.removeJumps(angle(data(:,2)),0.2*pi));
    [~,minIdx1] = min(abs(data(:,1)));
    [~,minIdx2] = min(abs(data(:,2)));
    numPts = size(data,1);
%     if any(abs([minIdx1,minIdx2] - numPts/2) > numPts/2/5*4)
%         if args.gui
%             hf = qes.ui.qosFigure(sprintf('Opt. Readout Freq. | %s', q.name),true);
%             ax_ = axes('parent',hf);
%             plot(ax_,frequency,abs(data(:,1)),'--.r',frequency,abs(data(:,2)),'--.b');legend('|0>','|1>');
%             xlabel('frequency(Hz)');
%             ylabel('|IQ|');
%             title('Error!');
%         end
%         throw(MException('QOS_XmonOptReadoutFreq:inproperSettings',...
%             'inproper r_freq or t_rrDipFWHM_est value, dip(s) out of range.'));
%     end

%     data(:,1) = smooth(data(:,1),3);
%     data(:,2) = smooth(data(:,2),3);
    
    [~, idx] = max(abs(data(:,1) - data(:,2)));
    optFreq = frequency(idx);
    
    if args.gui
        optFreq0=sqc.util.getQSettings('r_freq',q.name);
        hf = qes.ui.qosFigure(sprintf('Opt. Readout Freq. | %s', q.name),true);
        ax_ = axes('parent',hf);
        plot(ax_,frequency,abs(data(:,1)),'--.r',frequency,abs(data(:,2)),'--.b');legend('|0>','|1>');
        hold(ax_,'on');
		plot(ax_,[optFreq0,optFreq0],get(ax_,'YLim'),'--','Color',[1,0.7,0.7]);
		plot(ax_,[optFreq,optFreq],get(ax_,'YLim'),'--r');
        hf = qes.ui.qosFigure(sprintf('Opt. Readout Freq. | %s', q.name),true);
        ax = axes('parent',hf);
        plot(ax,data(:,1),'--.r');
        hold(ax,'on');
        plot(ax,data(:,2),'--.b');
        plot(ax,real(data(idx,:)),imag(data(idx,:)),'-','Color',[0,1,0]);
        legend(ax,{'|1>','|0>','Max IQ separation'});
        xlabel(ax,'I');
        ylabel(ax,'Q');
        xlim = get(ax,'XLim');
        xRange = xlim(2) - xlim(1);
        ylim = get(ax,'YLim');
        yRange = ylim(2) - ylim(1);
        dR = xRange - yRange;
        if dR > 0
            ylim(2) = ylim(2) + 0.5*dR;
            ylim(1) = ylim(1) - 0.5*dR;
            set(ax,'YLim',ylim);
        else
            xlim(2) = xlim(2) - 0.5*dR;
            xlim(1) = xlim(1) + 0.5*dR;
            set(ax,'XLim',xlim);
        end
        title(ax,sprintf('Maximum IQ separation frequency: %0.5fGHHz',optFreq/1e9));
        set(ax,'PlotBoxAspectRatio',[1,1,1]);
        pbaspect(ax,[1,1,1]);
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
        QS.saveSSettings({q.name,'r_freq'},optFreq);
        if ~isempty(hf) && isvalid(hf)
            dataSvName = fullfile(QS.loadSSettings('data_path'),...
                ['optReadoutFreq_',q.name,'_',datestr(now,'yymmddTHHMMSS'),...
                num2str(ceil(99*rand(1,1)),'%0.0f'),'_.fig']);
            saveas(hf,dataSvName);
        end
    end
	varargout{1} = optFreq;
end