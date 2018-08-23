function [varargout] = T1(Data, SweepVals,ParamNames,MainParam,MeasurementName,AX,IsPreview)
    % plots T1 data
    
% Copyright 2017 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com

    x = [];
    y = [];
    z = [];
    if isempty(Data) || isempty(Data{1}) || isempty(SweepVals) ||...
            (iscell(Data{1}) && isempty(Data{1}{1}))
        varargout{1} = x;
        varargout{2} = y;
        varargout{3} = z;
        plot(AX,NaN,NaN);
        XLIM = get(AX,'XLim');
        YLIM = get(AX,'YLim');
        text('Parent',AX,'Position',[mean(XLIM),mean(YLIM)],'String','Empty data',...
            'HorizontalAlignment','center','VerticalAlignment','middle',...
            'Color',[1,0,0],'FontSize',10,'FontWeight','bold');
        return;
    end
    if length(Data) > 1
        error('OneMeasComplex_* only handles data of experiments with one measurement.');
    end
    Data = Data{1};
    
    if nargin < 7
        IsPreview = false;
    end

    hold(AX,'off');
    NumSweeps = numel(SweepVals); 
    if NumSweeps ~= 2
        throw(MException('QOS_plotT1Data:unsupportedData','T1 data should have exactly two sweeps, %d in found.', NumSweeps));
    end

    sz = size(Data);
    for ii = 1:sz(1)
        for jj = 1:sz(2)
            if isempty(Data{ii,jj})
                Data{ii,jj} = NaN;  % fill empties with NaNs
            else
                Data{ii,jj} = Data{ii,jj}(1) - Data{ii,jj}(2);
            end
        end
    end
    Data = cell2mat(Data);
    

    x = SweepVals{1}{MainParam(1)}(:)';
    y = SweepVals{2}{MainParam(2)}(:)';
    z = Data;
    if isreal(z)
        z_ = z;
    else
        z_ = abs(z);
    end
    if all([numel(x),numel(y)] > 1)
        imagesc(x,y,z_','Parent',AX);
        set(AX,'YDir','normal');
        if ~IsPreview
            colormap(jet);
            colorbar('peer',AX);
            xlabel(AX,ParamNames{1}{MainParam(1)});
            ylabel(AX,ParamNames{2}{MainParam(2)});
        end
    elseif numel(x) > 1
        plot(AX,x,z_');
        if ~IsPreview
            xlabel(AX,ParamNames{1}{MainParam(1)});
            ylabel(AX,MeasurementName{1});
        end
    else
        plot(AX,y,z_');
        if ~IsPreview
            colormap(jet);
            colorbar('peer',AX);
            xlabel(AX,ParamNames{2}{MainParam(2)});
            ylabel(AX,MeasurementName{1});
        end
    end
    

    varargout{1} = x;
    varargout{2} = y;
    varargout{3} = z;
end