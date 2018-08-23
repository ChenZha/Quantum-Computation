function [varargout] = OneMeas_Def(Data, SweepVals,ParamNames,MainParam,MeasurementName,AX,IsPreview)
    % default plot function for data:
    % One measurement, measure data are scalar, array or
    % maxtrix.
    % 2D data is transposed to take the convention of a spectrum plot, the first sweep is taken as y
    % This is the default plot function for class Experiment and DataViewer.
    % varargout: data parsed from QES format to simple x, y and z,
    % varargout{1} is x, varargout{2} is y, varargout{3} is z, if
    % not exist in data, an empty matrix is returned, for example,
    % varargout{3} will be an empty matrix if there is no z data.
    
% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com


    nSwps = numel(SweepVals);
    a = numel(MainParam);
    if a < nSwps
        MainParam = [MainParam, ones(1,nSwps-a)];
    end
    
    if nargin < 7
        IsPreview = false;
    end
    if (iscell(Data{1}) && ~isempty(Data{1}{1}) && ~isreal(Data{1}{1}(1))) ||...
       (~iscell(Data{1}) && ~isreal(Data{1}(1)))
        [x,y,z] = OneMeasComplex_Def(Data, SweepVals,ParamNames,MainParam,MeasurementName,AX,IsPreview);
    else
        [x,y,z] = OneMeasReal_Def(Data, SweepVals,ParamNames,MainParam,MeasurementName,AX,IsPreview);
    end
    varargout{1} = x;
    varargout{2} = y;
    varargout{3} = z;
end

function [varargout] = OneMeasReal_Def(Data, SweepVals,ParamNames,MainParam,MeasurementName,AX,IsPreview)
    % default plot function for data:
    % One measurement, measure data are real number scalar, array or
    % maxtrix.
    % 2D data is transposed to take the convention of a spectrum plot, the first sweep is taken as y
    % This is the default plot function for class Experiment and DataViewer.
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
    if nargin < 7
        IsPreview = false;
    end
    if (iscell(Data{1}) && ~isreal(Data{1}{1}(1))) ||...
       (~iscell(Data{1}) && ~isreal(Data{1}(1)))
        error('OneMeasReal_* only handles numeric real data.');
    end
    if length(Data) > 1
        error('OneMeasReal_* only handles data of experiments with one measurement.');
    end
    Data = Data{1};
    hold(AX,'off');
    NumSweeps = numel(SweepVals); 
    if NumSweeps == 1
        if length(SweepVals{1}{MainParam(1)}) == 1 % single sweep, single sweep point measurement
            if iscell(Data) % in case of numeric scalar measurement data, data may saved as matrix to reduce volume
                Data = Data{1};
            end
            Data = squeeze(Data);
            sz = size(Data); % sz is the size of each data point
             if length(sz) == 2 % scalar, array or 2D matrix
                if any(sz == 1) % 1D data
                    x = [];
                    y = Data(:)';
                    z = [];
                    plot(AX,y,'Color',[0,0.3,1]);
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
                    x = [];
                    y = [];
                    z = Data;  
                    % imagesc(z','Parent',AX);  % transpose Data to take the convention of spectrum, the first sweep is taken y
                    s = pcolor(z','Parent',AX);
                    set(s,'EdgeColor','none');
                    colormap(jet);
                    if ~IsPreview
                        colormap(jet);
                        colorbar('peer',AX);
                    end
                    set(AX,'YDir','normal');
                    if ~IsPreview
                        xlabel(AX,'Data Index 1');
                        ylabel(AX,'Data Index 2');
                    end
                end
            else % more than 2D data, too complex to plot.
                error('data too complex to be handled by this plot function.');
            end
        elseif length(SweepVals{1}{MainParam(1)}) > 1 % single sweep, multipoint sweep point measurement
            if iscell(Data) % sz is the size of each data point
                sz = size(squeeze(Data{1}));
            else
                sz = [1, 1]; 
            end
            if all(sz > 1) || length(sz) > 2 % 
                error('data too complex to be handled by this plot function.');
            else
                if all(sz== 1) % 1D data, each measurement data  point is a scalar
                    if iscell(Data) % in case of numeric scalar measurement data, data may saved as matrix to reduce volume
                        sz_d = size(Data);
                        for ii = 1:sz_d(1)
                            for jj = 1:sz_d(2)
                                Data{ii,jj} = squeeze(Data{ii,jj});
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
                    plot(AX,x,y,'Color',[0,0.3,1]);
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
                else  % 2D data, each measurement data  point is an array, in this case Data can only be a cell
                    swpsize = length(SweepVals{1}{MainParam(1)});
                    data = NaN*ones(swpsize,numel(Data{1}));
                    for ii = 1:swpsize
                        if ~isempty(Data{ii}(:))
                            data(ii,:) = Data{ii}(:); %  Nx1 should be converted to 1xN
                        end
                    end
                    x = SweepVals{1}{MainParam(1)}(:)';
                    y = 1:sz(2);
                    z = data; 
                    % imagesc(x, y, z','Parent',AX);  % transpose Data to take the convention of spectrum, the first sweep is taken y
                    s = pcolor(x, y, z','Parent',AX);
                    set(s,'EdgeColor','none');
                    colormap(jet);
                    set(AX,'YDir','normal');
                    if ~IsPreview
                        colormap(jet);
                        colorbar('peer',AX);
                        xlabel(AX,ParamNames{1}{MainParam(1)});
                        ylabel(AX, 'Unknonwn');
                    end
                end
            end
        end
    elseif NumSweeps == 2
        if iscell(Data) && numel(Data{1}) > 1 % in cases of more than one sweeps, each measurement data point can only be a scalar, otherwise it is too complex to be plotted.
            error('data too complex to be handled by this plot function.');
        end
        if iscell(Data) % in case of numeric scalar measurement data, data may saved as matrix to reduce volume
            sz = size(Data);
            for ii = 1:sz(1)
                for jj = 1:sz(2)
                    Data{ii,jj} = squeeze(Data{ii,jj});
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
            x = SweepVals{1}{MainParam(1)}(:)';
            y  = SweepVals{2}{MainParam(2)}(:)';
            z = Data; 
            % imagesc(x,y,z','Parent',AX);  % transpose Data to take the convention of spectrum, the first sweep is taken y
            s = pcolor(x,y,z','Parent',AX);
            set(s,'EdgeColor','none');
            colormap(jet);
            set(AX,'YDir','normal');
            if ~IsPreview
                colormap(jet);
                colorbar('peer',AX);
                xlabel(AX,ParamNames{1}{MainParam(1)});
                ylabel(AX,ParamNames{2}{MainParam(2)});
            end
        else % 1D data
             if sz(1)==1
                 x = SweepVals{2}{MainParam(2)}(:)';
                 y = Data(:)';
                 z = [];
                 plot(AX,x,y,'Color',[0,0.3,1]);
                 if ~IsPreview
                    xlabel(AX,ParamNames{2}{MainParam(2)});
                    ylabel(AX,MeasurementName{1});
                end
             else
                 x = SweepVals{1}{MainParam(1)}(:)';
                 y = Data(:)';
                 z = [];
                 plot(AX,x,y,'Color',[0,0.3,1]);
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

function [varargout] = OneMeasComplex_Def(Data, SweepVals,ParamNames,MainParam,MeasurementName,AX,IsPreview)
    % default plot function for data:
    % One measurement, measure data are complex number scalar, array or
    % maxtrix.
    % 2D data is transposed to take the convention of a spectrum plot, the first sweep is taken as y
    % This is the default plot function for class Experiment and DataViewer.
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
    if nargin < 7
        IsPreview = false;
    end
    if length(Data) > 1
        error('OneMeasComplex_* only handles data of experiments with one measurement.');
    end
    Data = Data{1};
    hold(AX,'off');
    NumSweeps = numel(SweepVals); 
    if NumSweeps == 1
        if length(SweepVals{1}{MainParam(1)}) == 1 % single sweep, single sweep point measurement
            if iscell(Data) % in case of numeric scalar measurement data, data may saved as matrix to reduce volume
                Data = Data{1};
            end
            Data = squeeze(Data);
            sz = size(Data);
             if length(sz) == 2 % scalar, array or 2D matrix
                if any(sz == 1) % 1D data
                    x = [];
                    y = Data(:)';
                    z = [];
                    x_ = real(y);
                    y_ = imag(y);
                    plot(AX,x_,y_,'Color',[0,0.3,1]);
                    dr = range(x_);
                    xlim = [min(x_)-0.1*dr,max(x_)+0.1*dr];
                    dr = range(y_);
                    ylim = [min(y_)-0.1*dr,max(y_)+0.1*dr];
                    if all(~isnan(xlim))  && xlim(2) > xlim(1)
                        set(AX,'XLim',xlim);
                    end
                    if all(~isnan(ylim))  && ylim(2) > ylim(1)
                        set(AX,'YLim',ylim);
                    end      
                    if ~IsPreview
                        xlabel(AX,['Re[',MeasurementName{1},']']);
                        ylabel(AX, ['Im[',MeasurementName{1},']']);
                    end
                else % 2D data, each measurement data  point  is a matrix
                    x = [];
                    y = [];
                    z = Data;
                    z_ = abs(z);
                    % imagesc(z_','Parent',AX);  % transpose Data to take the convention of spectrum, the first sweep is taken y
                    s = pcolor(z_','Parent',AX);
                    set(s,'EdgeColor','none');
                    colormap(jet);
                    if ~IsPreview
                        colormap(jet);
                        colorbar('peer',AX);
                    end
                    set(AX,'YDir','normal');
                    if ~IsPreview
                        xlabel(AX,'Data Index 1(color scale: amplitude)');
                        ylabel(AX,'Data Index 2(color scale: amplitude)');
                    end
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
                if all(sz== 1) % 1D data, each measurement data  point is a scalar
                    if iscell(Data) % in case of numeric scalar measurement data, data may saved as matrix to reduce volume
                        sz_d = size(Data);
                        for ii = 1:sz_d(1)
                            for jj = 1:sz_d(2)
                                Data{ii,jj} = squeeze(Data{ii,jj});
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
                    y_ = abs(y);
                    plot(AX,x,y_,'Color',[0,0.3,1]);
                    xlim = [x(1),x(end)];
                    dr = range(y_);
                    ylim = [min(y_)-0.1*dr,max(y_)+0.1*dr];
                    if all(~isnan(xlim)) && xlim(2) > xlim(1)
                        set(AX,'XLim',xlim);
                    end
                    if all(~isnan(ylim)) && ylim(2) > ylim(1)
                        set(AX,'YLim',ylim);
                    end
                    if ~IsPreview
                        xlabel(AX,ParamNames{1}{MainParam(1)});
                        if iscell(MeasurementName) % deals with a bug in old version data
                            ylabel(AX, ['Amplitude of ', MeasurementName{1}]);
                        end
                    end
                else  % 2D data, each measurement data  point is an array, in this case Data can only be a cell
                    swpsize = length(SweepVals{1}{MainParam(1)});
                    data = NaN*ones(swpsize,numel(Data{1}));
                    for ii = 1:swpsize
                        if ~isempty(Data{ii}(:))
                            data(ii,:) = Data{ii}(:); %  Nx1 should be converted to 1xN
                        end
                    end
                    x = SweepVals{1}{MainParam(1)}(:)';
                    y = 1:sz(2);
                    z = data; 
                    z_ = abs(z);
                    % imagesc(x, y, z_','Parent',AX);  % transpose Data to take the convention of spectrum, the first sweep is taken y
                    s = pcolor(x, y, z_','Parent',AX);
                    set(s,'EdgeColor','none');
                    colormap(jet);
                    set(AX,'YDir','normal');
                    if ~IsPreview
                        colormap(jet);
                        colorbar('peer',AX);
                        xlabel(AX,ParamNames{1}{MainParam(1)});
                        ylabel(AX, 'Unknonwn, colorbar: amplitude of data');
                    end
                end
            end
        end
    elseif NumSweeps == 2
        if iscell(Data) && numel(Data{1}) > 1 % in cases of more than one sweeps, each measurement data point can only be a scalar, otherwise it is too complex to be plotted.
            error('data too complex to be handled by this plot function.');
        end
        if iscell(Data) % in case of numeric scalar measurement data, data may saved as matrix to reduce volume
            sz = size(Data);
            for ii = 1:sz(1)
                for jj = 1:sz(2)
                    Data{ii,jj} = squeeze(Data{ii,jj});
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
            x = SweepVals{1}{MainParam(1)}(:)';
            y  = SweepVals{2}{MainParam(2)}(:)';
            z = Data; 
            z_ = abs(z);
            % imagesc(x,y,z_','Parent',AX);  % transpose Data to take the convention of spectrum, the first sweep is taken y
            s = pcolor(x,y,z_','Parent',AX);
            set(s,'EdgeColor','none');
            colormap(jet);
            set(AX,'YDir','normal');
            if ~IsPreview
                colormap(jet);
                colorbar('peer',AX);
                xlabel(AX,ParamNames{1}{MainParam(1)});
                ylabel(AX,[ParamNames{2}{MainParam(2)},'(colorbar: amplitude of data)']);
            end
        else % 1D data
             if sz(1)==1
                 x = SweepVals{2}{MainParam(2)}(:)';
                 y = Data(:)';
                 z = [];
                 y_ = abs(y);
                 plot(AX,x,y_,'Color',[0,0.3,1]);
                 if ~IsPreview
                    xlabel(AX,ParamNames{2}{MainParam(2)});
                    ylabel(AX,['Amplitude of ', MeasurementName{1}]);
                end
             else
                 x = SweepVals{1}{MainParam(1)}(:)';
                 y = Data(:)';
                 z = [];
                 y_ = abs(y);
                 plot(AX,x,y_,'Color',[0,0.3,1]);
                 if ~IsPreview
                    xlabel(AX,ParamNames{1}{MainParam(1)});
                    ylabel(AX,['Amplitude of ', MeasurementName{1}]);
                end
             end
             xlim = [x(1),x(end)];
            dr = range(y_);
            ylim = [min(y_)-0.1*dr,max(y_)+0.1*dr];
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