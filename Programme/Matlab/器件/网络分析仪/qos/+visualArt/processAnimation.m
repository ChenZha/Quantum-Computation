function processAnimation()
% demonstration of processAnimation
    hf = qes.ui.qosFigure('Process Animation Demo',false);
    set(hf,'ToolBar','none','MenuBar','none');
    ax = axes('Parent',hf,'Position',[-0.25,-0.25,1.5,1.5]);
    pa = sqc.util.processAnimator(ax);
    pa.drawHistory = true;
    pa.initialState = '|0>+(1+1i)|1>';
    pa.process = {'Y','X','Z',{'Y', pi/3}};
    % pa.process = {'H','-X/2',{'Y', pi/3},'X',{'Z', -pi/5}};
%     pa.process = {'H','Y','H','X','Y/4','-Y/2','Z',...
%         'Y/2','-X/4','Y','X/4','H','-X/4','Y'}; 
    pa.playDuration = 5; % play time in seconds
    pa.play();

end

