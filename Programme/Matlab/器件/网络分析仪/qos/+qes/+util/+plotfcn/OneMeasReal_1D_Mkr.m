function [varargout] = OneMeasReal_1D_Mkr(Data, SweepVals,ParamNames,MainParam,MeasurementName,AX,IsPreview)
    % plot 1D data to line with marker at data point
    % varargout: data parsed from QES format to simple x, y and z,
    % varargout{1} is x, varargout{2} is y, varargout{3} is z, if
    % not exist in data, an empty matrix is returned, for example,
    % varargout{3} will be an empty matrix if there is no z data.
    
% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
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
        error('OneMeasReal_* only handles data of experiments with one measurement.');
    end
    Data = Data{1};
    if (iscell(Data) && ~isreal(Data{1}(1))) ||...
        (~iscell(Data) && ~isreal(Data(1)))
        error('OneMeasReal_* only handles numeric real data.');
    end
    
    if nargin < 7
        IsPreview = false;
    end
    
    hold(AX,'off');
    NumSweeps = numel(SweepVals); 
    if NumSweeps == 1
        if length(SweepVals{1}{MainParam(1)}) == 1 % single sweep, single sweep point measurement
            if iscell(Data) % in case of numeric scalar measurement data, data may saved as matrix to reduce volume
                Data = Data{1};
            end
            Data = squeeze(Data);
            sz = size(Data);
%             if all(sz == 1) % each measurement data point is a scalar
%                 warning('need at least two data points to plot.');
%                 return;
%             elseif length(sz) == 2 % each measurement data  point  is an array
             if length(sz) == 2 % each measurement data  point  is an array
                if any(sz == 1) % 1D data
                    x = [];
                    y = Data(:)';
                    z = [];
                    plot(AX,y,'Color',[1,0.3,0],'Marker','o','MarkerSize',3,'MarkerFaceColor',[1,0.3,0]);
                    xlim = [0,length(y)+1];
                    dr = range(y);
                    ylim = [min(y)-0.1*dr,max(y)+0.1*dr];
                    if all(~isnan(xlim))  && xlim(2) > xlim(1)
                        set(AX,'XLim',xlim);
                    end
                    if all(~isnan(ylim))  && ylim(2) > ylim(1)
                        set(AX,'YLim',ylim);
                    end      
                    if ~IsPreview
                        xlabel(AX,'Data Index');
                        ylabel(AX, MeasurementName{1});
                    end
                else % 2D data, each measurement data  point  is a matrix
                    error('OneMeasReal_1D_Mkr only handles 1 D data');
                end
            else % more than 2D data, too complex to plot.
                error('data too complex to be handled by this plot function.');
            end
        elseif length(SweepVals{1}{MainParam(1)}) > 1 % single sweep, multipoint sweep point measurement
            if iscell(Data)
                sz = size(squeeze(Data{1}));
            else
                sz = [1, 1];
            end
            if all(sz > 1) || length(sz) > 2 % 
                error('data too complex to be handled by this plot function.');
            else
                if all(sz == 1) % 1D data, each measurement data  point is a scalar
                    if iscell(Data) % in case of numeric scalar measurement data, data may saved as matrix to reduce volume
                        sz_d = size(Data);
                        for ii = 1:sz_d(1)
                            for jj = 1:sz_d(2)
                                if isempty(Data{ii,jj})
                                    Data{ii,jj} = NaN;  % fill empties with NaNs
                                end
                            end
                        end
                        Data = cell2mat(Data);
                    end
                    x = SweepVals{1}{MainParam(1)}(:)';
                    y = Data(:)';
                    z = [];
                    plot(AX,x,y,'Color',[1,0.3,0],'Marker','o','MarkerSize',3,'MarkerFaceColor',[1,0.3,0]);
                    xlim = [x(1),x(end)];
                    dr = range(y);
                    ylim = [min(y)-0.1*dr,max(y)+0.1*dr];
                    if all(~isnan(xlim)) && xlim(2) > xlim(1)
                        set(AX,'XLim',xlim);
                    end
                    if all(~isnan(ylim)) && ylim(2) > ylim(1)
                        set(AX,'YLim',ylim);
                    end
                    if ~IsPreview
                        xlabel(AX,ParamNames{1}{MainParam(1)});
                        if iscell(MeasurementName) % deals with a bug in old version data
                            ylabel(AX, MeasurementName{1});
                        end
                    end
                else  % 2D data, each measurement data  point is an array
                    error('OneMeasReal_1D_Mkr only handles 1 D data');
                end
            end
        end
    elseif NumSweeps == 2
        % Here Data = Data{1} is already given in line 30. % GM, 20170415
%         if numel(Data) > 1 % in cases of more than one sweeps, each measurement data point can only be a scalar, otherwise it is too complex to be plotted.
%             error('data too complex to be handled by this plot function.');
%         end
        if iscell(Data) % in case of numeric scalar measurement data, data may saved as matrix to reduce volume
            sz = size(Data);
            for ii = 1:sz(1)
                for jj = 1:sz(2)
                    if isempty(Data{ii,jj})
                        Data{ii,jj} = NaN;  % fill empties with NaNs
                    end
                end
            end
            Data = cell2mat(Data);
        end
        sz = size(Data);
%         if all(sz==1)
%             warning('single data point measurement experiment, to plot, have at least two data points.');
%             return; % single point measurement, this is the case of having multiple sweeps, yet all sweeps are only having one sweep point.
%         end
        if all(sz>1) % 2D data
            error('OneMeasReal_1D_Mkr only handles 1 D data');
        else % 1D data
             if sz(1)==1
                 x = SweepVals{2}{MainParam(2)}(:)';
                 y = Data(:)';
                 z = [];
                 plot(AX,x,y,'Color',[1,0.3,0],'Marker','o','MarkerSize',3,'MarkerFaceColor',[1,0.3,0]);
                 if ~IsPreview
                    xlabel(AX,ParamNames{2}{MainParam(2)});
                    ylabel(AX,MeasurementName{1});
                end
             else
                 x = SweepVals{1}{MainParam(2)}(:)';
                 y = Data(:)';
                 z = [];
                 plot(AX,x,y,'Color',[1,0.3,0],'Marker','o','MarkerSize',3,'MarkerFaceColor',[1,0.3,0]);
                 if ~IsPreview
                    xlabel(AX,ParamNames{1}{MainParam(1)});
                    ylabel(AX,MeasurementName{1});
                end
             end
             xlim = [x(1),x(end)];
            dr = range(y);
            ylim = [min(y)-0.1*dr,max(y)+0.1*dr];
            if all(~isnan(xlim))  && xlim(2) > xlim(1)
                set(AX,'XLim',xlim);
            end
            if all(~isnan(ylim)) && ylim(2) > ylim(1)
                set(AX,'YLim',ylim);
            end
        end
    else % more than 2 sweeps
        error('data too complex to be handled by this plot function.');
    end
    varargout{1} = x;
    varargout{2} = y;
    varargout{3} = z;
end