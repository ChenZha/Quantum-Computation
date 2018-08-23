function ax = ibar3(z, ax, FaceAlpha)
    if nargin < 2 || isempty(ax)
        hf = qes.ui.qosFigure('Process Tomography',false);
		ax = axes('parent',hf);
        FaceAlpha = 1;
    elseif FaceAlpha < 3
        FaceAlpha = 1;
    end
    
    h = bar3(ax,z);
    for k = 1:length(h)
        zdata = h(k).ZData;
        h(k).CData = zdata;
        h(k).FaceColor = 'interp';
        h(k).FaceAlpha = FaceAlpha;
        h(k).EdgeAlpha = 1;
    end
end