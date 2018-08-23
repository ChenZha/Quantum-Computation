function [varargout] = Phase(Data, SweepVals,ParamNames,MainParam,MeasurementName,AX,IsPreview)
    % plot fonction for S parameter, plot phase
    % one measurement data only
    % each measurement data point is a 1 by N array s parameter trace or
    % 2 by N array, one row is the s parameter, the other is the frequency
    
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
        error('SParameter* only handles data of experiments with one measurement.');
    end
    Data = Data{1};
    hold(AX,'off');

    if length(SweepVals{1}{MainParam(1)}) == 1 % single sweep, single sweep point measurement
        if iscell(Data) % in case of numeric scalar measurement data, data may saved as matrix to reduce volume
            Data = Data{1};
        end
        Data = squeeze(Data);
        sz = size(Data);
         if length(sz) == 2 % scalar, array or 2D matrix
            if any(sz == 1) % 1D data, no frequency data, plot smith chart
                x = [];
                y = Data(:)';
                z = [];
%                 x_ = real(y);
%                 y_ = imag(y);
                
                x_ = 1:numel(y);
                ang = unwrap(angle(y));
                y_ = ang - linspace(ang(1),ang(end),length(ang));
                
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
%                     xlabel(AX,['Re[',MeasurementName{1},']']);
%                     ylabel(AX, ['Im[',MeasurementName{1},']']);
                    xlabel(AX,['Data Index']);
                    ylabel(AX, ['Normalized phase of ',MeasurementName{1},'(rad)]']);
                end
            elseif any(sz==2) % 2 by N or N by 2 data, sparamter and frequency
                if sz(1) == sz(2) 
                    if all(isreal(Data(1,:))) && any(~isreal(Data(2,:)))
                        freq = Data(1,:);
                        sparam = Data(2,:);
                    elseif all(~isreal(Data(1,:))) && any(isreal(Data(2,:)))
                        freq = Data(2,:);
                        sparam = Data(1,:);
                    elseif all(isreal(Data(1,:))) && all(isreal(Data(2,:)))
                        % confusing case, frequencies are normally much greater than s parameters, take a resonable gusse
                        [~,idx] = max([Data(1,1)+Data(1,2),Data(2,1)+Data(2,2),Data(1,1)+Data(2,1),Data(1,2)+Data(2,2)]);
                        switch idx
                            case 1
                                freq = Data(1,:);
                                sparam = Data(2,:);
                            case 2
                                freq = Data(2,:);
                                sparam = Data(1,:);
                            case 3
                                freq = Data(:,1);
                                sparam = Data(:,2);
                            case 4
                                freq = Data(:,2);
                                sparam = Data(:,1);
                        end
                    elseif all(isreal(Data(:,1))) && any(~isreal(Data(:,2)))
                        freq = Data(:,1);
                        sparam = Data(:,2);
                    elseif all(~isreal(Data(:,1))) && any(isreal(Data(:,2)))
                        freq = Data(:,2);
                        sparam = Data(:,1);
                    else
                        error('unrecognized data format.');
                    end
                else
                    if sz(2) == 2
                        Data = Data';
                    end
                    if all(isreal(Data(1,:))) && any(~isreal(Data(2,:)))
                        freq = Data(1,:);
                        sparam = Data(2,:);
                    elseif all(~isreal(Data(1,:))) && any(isreal(Data(2,:)))
                        freq = Data(2,:);
                        sparam = Data(1,:);
                    else % confusing case, frequencies are normally much greater than s parameters, take a resonable gusse
                        if mean(Data(1,:)) > mean(Data(2,:))
                            freq = Data(1,:);
                            sparam = Data(2,:);
                        else
                            freq = Data(2,:);
                            sparam = Data(1,:);
                        end
                    end
                end

                x = freq;
                y = sparam;
                ang = unwrap(angle(y));
                y_ = ang - linspace(ang(1),ang(end),length(ang));
                plot(AX,x,y_,'Color',[0,0.3,1]);
                dr = range(x);
                xlim = [min(x)-0.1*dr,max(x)+0.1*dr];
                dr = range(y_);
                ylim = [min(y_)-0.1*dr,max(y_)+0.1*dr];
                if all(~isnan(xlim))  && xlim(2) > xlim(1)
                    set(AX,'XLim',xlim);
                end
                if all(~isnan(ylim))  && ylim(2) > ylim(1)
                    set(AX,'YLim',ylim);
                end      
                if ~IsPreview
                    xlabel(AX,'Frequency (unit unknown)');
                    ylabel(AX, ['Normalized phase of ',MeasurementName{1},'(rad)]']);
                end
            else
                error('unrecognized data format.');
            end
        else % more than 2D data, too complex to plot.
            error('unrecognized data format.');
        end
    elseif length(SweepVals{1}{MainParam(1)}) > 1 % single sweep, multipoint sweep point measurement
        if iscell(Data) % sz is the size of each data point
            sz = size(squeeze(Data{1}));
        else
            sz = [1, 1];
        end
        if all(sz > 2) || length(sz) > 2 
            error('unrecognized data format.');
        else
            freq = NaN;
            if all(sz>=2) % data can only be cell
               sz_d = size(Data);
               for ii = 1:sz_d(1)
                    for jj = 1:sz_d(2)
                        Data{ii,jj} = squeeze(Data{ii,jj});
                        if isempty(Data{ii,jj})
                            Data{ii,jj} = NaN*ones(sz);  % fill empties with NaNs
                        end
                    end
                end 
               if sz(1) == sz(2)
                   % ..., never mind
               elseif sz(2) == 2
                   for ii = 1:sz_d(1)
                        for jj = 1:sz_d(2)
                            Data{ii,jj} = Data{ii,jj}';
                        end
                    end 
               end
               temp1 = abs(Data{1,1}(1,:));
               temp2 = abs(Data{1,1}(1,:));
               % the second row is taken as frequencies
               % frequencies are normally much greater than s parameters, take a resonable gusse
               if mean(temp1(~isnan(temp1))) > mean(temp2(~isnan(temp2)))
                   for ii = 1:sz_d(1)
                        for jj = 1:sz_d(2)
                            Data{ii,jj} = flipud(Data{ii,jj});
                        end
                    end
               end
               freq = Data{1,1}(2,:); % suppose all frequencies are the same
               for ii = 1:sz_d(1)
                    for jj = 1:sz_d(2)
                        Data{ii,jj}(2,:) = [];
                    end
               end
                sz = size(Data{1,1});
            end
            if any(sz==1)
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
                    ang = unwrap(angle(y));
                    y_ = ang - linspace(ang(1),ang(end),length(ang));
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
                            ylabel(AX, ['Normalized phase of ',MeasurementName{1},'(rad)]']);
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
                    if isnan(freq) % no frequency data
                        y = 1:sz(2);
                    else
                        y = freq;
                    end
                    
                    
%                     z = data;
%                     sz = size(z);
%                     z_ = angle(z);
%                     for uu = 1:2
%                         for ii = 1:swpsize
%                             z_(ii,:) = unwrap(z_(ii,:));
%                             z_(ii,:) = z_(ii,:) - z_(ii,1);
%                         end
%                         % handle unfinished data sets
%                         z__ = z_;
%                         idx = [];
%                         for ii = 1:swpsize
%                             if any(isnan(z__(ii,:)))
%                                 idx = [idx,ii];
%                             end
%                         end
%                         if numel(idx) < swpsize
%                             z__(idx,:) = [];
%                         end
%                         P = polyfit(0:(sz(2)-1),mean(z__,1),1);
%                         for ii = 1:swpsize
%                             z_(ii,:) = z_(ii,:) - polyval(P,0:(sz(2)-1));
%                         end
%                     end
                    
                    
                    z = data;
                    warning('off','MATLAB:polyfit:RepeatedPointsOrRescale');
                    sz = size(z);
                    z_ = angle(z);
                    for uu = 1:2
                        for ii = 1:swpsize
                            z_(ii,:) = unwrap(z_(ii,:));
                            z_(ii,:) = z_(ii,:) - z_(ii,1);
                        end
                        P = polyfit(0:(sz(2)-1),mean(z_,1),1);
                        for ii = 1:swpsize
                            hold on;
                            z_(ii,:) = z_(ii,:) - polyval(P,0:(sz(2)-1));
                        end
                    end
                    warning('on','MATLAB:polyfit:RepeatedPointsOrRescale');
                    
                    
                    
                    imagesc(x, y, mod(z_,2*pi)','Parent',AX);  % transpose Data to take the convention of spectrum, the first sweep is taken as y
                    set(AX,'YDir','normal');
                    if ~IsPreview
                        colormap(jet);
                        colorbar('peer',AX);
                        xlabel(AX,ParamNames{1}{MainParam(1)});
                        if isnan(freq) % no frequency data
                            ylabel(AX, 'Unknonwn, colorbar: normalized phase of data(rad)');
                        else
                            ylabel(AX, 'Frequency (unit unknown)');
                        end
                    end
                end
            end
        end
    end
    
    
    varargout{1} = x;
    varargout{2} = y;
    varargout{3} = z;
end