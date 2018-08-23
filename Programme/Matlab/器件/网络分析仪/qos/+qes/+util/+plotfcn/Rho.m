function ax = Rho(data,ax,FaceAlpha,isRawData)
    % plots state density matrix
    
% Copyright 2017 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com
 
    if isempty(ax)
        hf = qes.ui.qosFigure('Density matrix',false);
        fpos = get(hf,'Position');
        fpos(1) = fpos(1) - fpos(3)/2;
        fpos(3) = fpos(3) + fpos(3)/2;
        set(hf,'Position',fpos);
		ax = [axes('parent',hf);axes('parent',hf)];
        set(ax(1),'Position',[0.0725,0.05,0.425,0.9]);
        set(ax(2),'Position',[0.55,0.05,0.425,0.9]);
    end
    assert(numel(ax) <= 2);
    
    if isRawData
        M = sqc.qfcns.stateTomoData2Rho(data);
    else
        M = data;
    end
    numQs = log2(size(M,1));

    for ii = 1:numel(ax)
        hold(ax(ii),'on');
        if ii == 1
            z = real(M);
        else
            z = imag(M);
        end
        h = bar3(ax(ii),z);
        for k = 1:length(h)
            zdata = h(k).ZData;
            h(k).CData = zdata;
            h(k).FaceColor = 'interp';
            h(k).FaceAlpha = FaceAlpha;
            h(k).EdgeAlpha = 1;
        end
        if ii == 1
            zlabel(ax(1),'Re(\rho_{ij})');
        else
            zlabel(ax(2),'Imag(\rho_{ij})');
        end
        sz = size(M);
        switch numQs
            case 1
                set(ax(ii),'XTick',[1,2],'XTickLabel',{'|0\rangle','|1\rangle'},...
                    'YTick',[1,2],'YTickLabel',{'\langle0|','\langle1|'});
                if ii == 1
                    xlabel(ax(1),'|q\rangle');
                    ylabel(ax(1),'\langleq|');
                else
                    xlabel(ax(2),'|q\rangle');
                    ylabel(ax(2),'\langleq|');
                end
            case 2
                set(ax(ii),'XTick',[1,2,3,4],'XTickLabel',{'|00\rangle','|01\rangle','|10\rangle','|11\rangle'},...
                    'YTick',[1,2,3,4],'YTickLabel',{'\langle00|','\langle01|','\langle10|','\langle11|'});
                if ii == 1
                    xlabel(ax(1),'|q2,q1\rangle');
                    ylabel(ax(1),'\langleq2,q1|');
                else
                    xlabel(ax(2),'|q2,q1\rangle');
                    ylabel(ax(2),'\langleq2,q1|');
                end
            case 3
                set(ax(ii),'XTick',[1,2,3,4,5,6,7,8],'XTickLabel',{'|000\rangle','|001\rangle','|010\rangle','|011\rangle','|100\rangle','|101\rangle','|110\rangle','|111\rangle'},...
                    'YTick',[1,2,3,4,5,6,7,8],'YTickLabel',{'\langle000|','\langle001|','\langle010|','\langle011|','\langle100|','\langle101|','\langle110|','\langle111|'});
                if ii == 1
                    xlabel(ax(1),'|q3,q2,q1\rangle');
                    ylabel(ax(1),'\langleq3,q2,q1|');
                else
                    xlabel(ax(2),'|q3,q2,q1\rangle');
                    ylabel(ax(2),'\langleq3,q2,q1|');
                end
            otherwise
                set(ax(ii),'XTick',[1,sz(1)],'XTickLabel',{'|0...00\rangle','|1...11\rangle'},...
                    'YTick',[1,sz(1)],'YTickLabel',{'\langle0...00|','\langle1...11|'});
                xlabel(ax(ii),'|x\rangle: |0...00\rangle,|0...01\rangle,|0...10\rangle \rightarrow |1...11\rangle');
                ylabel(ax(ii),'\langley|: \langle1...11| \rightarrow \langle0...10|,\langle0...01|,\langle0...00|');
                % set(gcf,'Position',[20   20   1000   650]);
                if ii == 1
                    xlabel(ax(1),'|qn,...,q1\rangle');
                    ylabel(ax(1),'\langleqn,...,q1|');
                else
                    xlabel(ax(2),'|qn,...,q1\rangle');
                    ylabel(ax(2),'\langleqn,...,q1|');
                end
        end
        grid(ax(ii),'off');
        % colormap(qes.ui.colormap.haxby);
        colormap(jet(128));
        % colorbar;
    %             set(ax,'CameraPosition',[-10   -10   10],'Projection','perspective');
        set(ax(ii),'Projection','perspective');
        set(ax(ii),'Projection','perspective','Color',get(gcf,'Color'),'YDir','reverse');
        if ii == 2
%             linkaxes(ax);
            zLim1 = get(ax(1),'ZLim');
            zLim2 = get(ax(2),'ZLim');
            zLim = [min(zLim1(1),zLim2(1)),max(zLim1(2),zLim2(2))];
            set(ax(1),'XLim',[0,2^numQs+1],'YLim',[0,2^numQs+1],'ZLim',zLim,'View',[-37.5,30],'Projection','orthographic');
            set(ax(2),'XLim',[0,2^numQs+1],'YLim',[0,2^numQs+1],'ZLim',zLim,'View',[-37.5,30],'Projection','orthographic');
        end
    end

end