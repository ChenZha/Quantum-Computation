function varargout =qosFigure(figureTitle,autoClose, autoCloseTime)
    % a customized QOS figure that closes automatically after some time.

% Copyright 2017 Yulin Wu, USTC, China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    persistent allQOSFigures;
    if numel(allQOSFigures) > 50 % in rare cases the autoclose timers might fail
        while numel(allQOSFigures) > 10
            if isgraphics(allQOSFigures(11)) % the first few qos figures might be system apps guis like registry editor etc
                close(allQOSFigures(11));
            end
            allQOSFigures(11) = [];
        end
    end

    if nargin == 1
        autoClose = false;
    end
    if nargin == 2 && autoClose
        autoCloseTime = 60*3; % 3 minutes
    end

    h = figure('NumberTitle','off','Name',['QOS | ',figureTitle],...
        'Color',[1,1,1],'DockControls','off');
    warning('off');
    jf = get(h,'JavaFrame');
    jf.setFigureIcon(javax.swing.ImageIcon(...
        im2java(qes.ui.icons.qos1_32by32())));
    warning('on');
    if autoClose
        tm = timer('BusyMode','queue','ExecutionMode','singleShot',...
            'ObjectVisibility','off','StartDelay',autoCloseTime,...
            'TimerFcn',{@closeFigure});
        start(tm);
    end
    varargout{1} = h;
    function closeFigure(~,~)
        if isvalid(h)
            close(h);
        end
        stop(tm);
        delete(tm);
    end
    allQOSFigures(end+1) = h;
end