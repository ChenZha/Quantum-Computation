function [varargout] = StateTomography(Data, SweepVals,ParamNames,MainParam,MeasurementName,AX,IsPreview)
    % plots state density matrix
    
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
    Data = Data{1}{1};
    
    if nargin < 7
        IsPreview = false;
    end

    hold(AX,'off');
    
    rho = sqc.qfcns.stateTomoData2Rho(Data);
    bar3(AX,rho);
    if ~IsPreview
        set(AX,'XTickLabel',{'|00>'})

    varargout{1} = x;
    varargout{2} = y;
    varargout{3} = z;
end