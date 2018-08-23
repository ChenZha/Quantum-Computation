function ax = Chi(M,ax,FaceAlpha, Fidelity,isRawData)
    % plots process tomography data
    
% Copyright 2017 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com

    if nargin < 2 || isempty(ax)
        hf = qes.ui.qosFigure('Process Tomography',false);
        fpos = get(hf,'Position');
        fpos(1) = fpos(1) - fpos(3)/2;
        fpos(3) = fpos(3) + fpos(3)/2;
        set(hf,'Position',fpos);
		ax = [axes('parent',hf);axes('parent',hf)];
        set(ax(1),'Position',[0.0725,0.05,0.4,0.9]);
        set(ax(2),'Position',[0.525,0.05,0.4,0.9]);
    end
    
    if nargin < 5
        isRawData = false;
    end
    if isRawData
        M = sqc.qfcns.processTomoData2Chi(M);
    end
    numQs = log(size(M,1))/log(4);
    
    if nargin < 3
        FaceAlpha= 1;
    end
    for ii = 1:numel(ax)
        if ii == 1
            z = real(M);
        else
            z = imag(M);
        end
        h = bar3(ax(ii),z(:,:,1));
        for k = 1:length(h)
            zdata = h(k).ZData;
            h(k).CData = zdata;
            h(k).FaceColor = 'interp';
            h(k).FaceAlpha = FaceAlpha;
            h(k).EdgeAlpha = 1;
        end
        if ii == 1
            zlabel(ax(1),'Re(\chi_{ij})');
        else
            zlabel(ax(2),'Imag(\chi_{ij})');
        end
        sz = size(M);
        switch numQs
            case 1
                tickLabels = {'I','X','Y','Z'};
                set(ax(ii),'XTick',[1,2,3,4],'XTickLabel',tickLabels,...
                    'YTick',[1,2,3,4],'YTickLabel',tickLabels);
            case 2
                tickLabels = {'II','XI','YI','ZI',...
                              'IX','XX','YX','ZX',...
                              'IY','XY','YY','ZY',...
                              'IZ','XZ','YZ','ZZ'};
                set(ax(ii),'XTick',[1:16],'XTickLabel',tickLabels,...
                    'YTick',[1:16],'YTickLabel',tickLabels);
            otherwise
                set(ax(ii),'XTick',[1,sz(1)],'XTickLabel',{'I...I','Z...Z'},...
                    'YTick',[1,sz(1)],'YTickLabel',{'I...I','Z...Z'});
                % set(gcf,'Position',[20   20   1000   650]);
        end
        grid(ax(ii),'off');
        % colormap(qes.ui.colormap.haxby);
        colormap(jet(128));
        % colorbar;
    %             set(ax,'CameraPosition',[-10   -10   10],'Projection','perspective');
        set(ax(ii),'Projection','perspective');
        set(ax(ii),'Projection','perspective','Color',get(gcf,'Color'),'YDir','reverse');
        if ii == 1 && nargin > 3
            title(ax(1),sprintf('Fidelity: %0.1f%%',Fidelity*100),'FontSize',10);
        end
        if ii == 2
%             linkaxes(ax);
            zLim1 = get(ax(1),'ZLim');
            zLim2 = get(ax(2),'ZLim');
            zLim = [min(zLim1(1),zLim2(1)),max(zLim1(2),zLim2(2))];
            set(ax(1),'ZLim',zLim,'FontSize',6);
            set(ax(2),'ZLim',zLim,'FontSize',6);
        end
        xtickangle(ax(ii),30);
        ytickangle(ax(ii),30);
    end
    
    
    
end