function waterMaker(ax,transparency)
    % transparency: 0, opaque, 1, complitly transparent
    if nargin < 2
        transparency = 0.6;
    end
    axPos = get(ax,'Position');
    r = axPos(4)/axPos(3);
    XLim = get(ax,'XLim');
    YLim = get(ax,'YLim');
    
    marker = qes.ui.icons.ustcLogo_blue_large();
    msz = size(marker);
    
    xrng = XLim(2) - XLim(1);
    x = linspace(XLim(1) + xrng/4, XLim(2) - xrng/4,msz(1));
    
    yrng = YLim(2) - YLim(1);
    y = linspace(YLim(1) + yrng/4/r, YLim(2) - yrng/4/r,msz(2));

    hold(ax,'on');
    im = imagesc(x,fliplr(y),marker);
    im.AlphaData = 1 - transparency;
end