function StateTomographyLine(P, ax, Title)
    % plots state density matrix
    
% Copyright 2017 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com

    if nargin < 3
        Title = '';
    end

    if nargin < 2
        h = qes.ui.qosFigure('State tomography',false);
        ax = axes('parent',h);
    end
    
    numQs = round(log(size(P,1))/log(3));
    
    switch numQs
        case 1
            plot(ax, P(:,1),'-sk','LineWidth',1);
            hold(ax,'on');
            plot(ax, P(:,2),'-sb','LineWidth',1);
            hold(ax,'off');
            set(ax,'YLim',[-0.02,1.02],'YTick',[0,0.25,0.5,0.75,1],...
                'XTick',[1,2,3],'XTickLabel',...
                {'X','Y','Z'});
            grid(ax,'on');
            legend(ax,{'P|0>','P|1>'});
            ylabel('P');
            title(Title);
        case 2
            plot(ax, P(:,1),'-sk','LineWidth',1);
            hold(ax,'on');
            plot(ax, P(:,2),'-sb','LineWidth',1);
            plot(ax, P(:,3),'-sg','LineWidth',1);
            plot(ax, P(:,4),'-sr','LineWidth',1);
            hold(ax,'off');
            set(ax,'YLim',[-0.02,1.02],'YTick',[0,0.25,0.5,0.75,1],...
                'XTick',1:9,'XTickLabel',...
                {'q2_Xq1_X','q2_Xq1_Y','q2_Xq1_Z','q2_Yq1_X','q2_Yq1_Y','q2_Yq1_Z','q2_Zq1_X','q2_Zq1_Y','q2_Zq1_Z'});
            grid(ax,'on');
            grid(ax,'on');
            % legend(ax,{'P|q2_0q1_0>','P|q2_0q1_1>','P|q2_1q1_0>','P|q2_1q1_1>'});
            legend(ax,{'P|0_{q2}0_{q1}>','P|0_{q2}1_{q1}>','P|1_{q2}0_{q1}>','P|1_{q2}1_{q1}>'});
            ylabel('P');
            title(Title);
        otherwise
            sz = size(P);
            nq = log(sz(1))/log(3);
        % 	if round(nq) ~= nq % not working
            if abs(round(nq) - nq) > 0.001
                error('illegal data format: P not a 3^nq row matrix, nq is the number of qubits');
            end
        % 	if round(log(sz(2))/log2) ~= nq
            if abs(round(log(sz(2))/log(2)) - nq) > 0.001
                error('illegal data format: P not a 2^nq column matrix, nq is the number of qubits');
            end
            nq = round(nq);
            lprX0 = qes.util.looper({'X','Y','I'});
            lprX = lprX0;
            for ii = 2:nq
                lprX = lprX + lprX0;
            end
            xlbls = cell(1,3^nq);
            ii = 0;
            while 1
                ii = ii+1;
                e = lprX();
                if isempty(e)
                    break;
                end
                xlbls{ii} = cellfun(@horzcat,e);
            end
            legendsLbls = cell(1,2^nq);
            for ii = 0:2^nq-1
                legendsLbls{ii+1} = ['|',dec2bin(ii,nq),'>'];
            end
            plot(ax,P,'-s','LineWidth',1);
            set(gca,'XLim',[1,3^nq],'YLim',[-0.035,1.05],'XTick',1:3^nq,'XTickLabel',xlbls,'YTick',[0,0.25,0.5,0.75,1]);
            grid on;
            legend(legendsLbls);
            title(['|q_{n},...q_{1}>, ',Title]);
    end
    
end