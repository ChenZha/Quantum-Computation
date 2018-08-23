function pks = findpeaks2D(x,z)
% example:
% export spectroscopy data to workspace with DataViewer
% pks = toolbox.data_tool.findpeaks2D(y,z);
% pks is 3 by length(x) matrix
% the first row are the most prominent peaks, which migh
% be false peaks at some points, in such case, you also have
% the second and the third rows which are weaker peaks to
% select the right peaks.

% Copyright 2016 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com

    pks = NaN*ones(3,size(z,1));
    for ii = 1:size(z,1)
        index = find(~isnan(z(ii,:)));
        if numel(index) < 3
            continue;
        end
        yi = z(ii,index);
        yi = yi - min(smooth(yi,3));
        xi = x(index);
        r = range(yi);
        [~,locs,~,~] = findpeaks(yi,'SortStr','descend','MinPeakHeight',r/3,...
            'MinPeakProminence',r/3,'MinPeakDistance',numel(yi)/5,...
            'WidthReference','halfprom','NPeaks',3);
        pks(1:numel(locs),ii) = xi(locs);
    end
end