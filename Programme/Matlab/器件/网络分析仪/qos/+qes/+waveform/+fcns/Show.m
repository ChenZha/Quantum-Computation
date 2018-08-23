function [varargout] = Show(obj,ax,freq_domain)
    % plot waveform
    % optional input argument: axes to plot, default: creat one
    % optional output argument: handle of plot axes, handle of ploted line
    
% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    if nargin == 1 || (nargin >1  &&  (isempty(ax) || ~ishghandle(ax)))
        h = figure('NumberTitle','off','Name',[class(obj), ': ',obj.name],'Color',[1,1,1]);
        ax = axes('Parent',h);
    else
        hold(ax,'on');
    end
    if nargin < 3
        freq_domain = false;
    end
    if freq_domain
        f = linspace(-0.5,0.5,10*obj.length);
        y = obj(f,true);
        hl = plot(ax,f,real(y),'--r',f,imag(y),'--g',f,abs(y),'-b');
        legend({'Real','Imaginary','Amplitude'});
%         hl = plot(ax,f,abs(y),'-b');

        set(ax,'XLim',[f(1),f(end)]);
        xlabel('frequency (sampling frequency)');
        ylabel('|amplitude|');
    else
        dt = 0.1;
        t = obj.t0-5:dt:obj.t0+obj.length-1+5;
        y =obj(t);
        if obj.iq
            %             if size(y,1) < 100
%                 hl = plot(ax,t,real(y),'-+',t,imag(y),'-+');
%             else
%                 hl = plot(ax,t,real(y),'-',t,imag(y),'-');
%             end
            hl = plot(ax,t,real(y),'-',t,imag(y),'--');
            legend({'I','Q'});
        else
            %             hl = plot(ax,t,real(y),'-');
%         if isreal(y)
%             if size(y,1) < 100
%                 hl = plot(ax,t,y,'-+');
%             else
%                 hl = plot(ax,t,y,'-');
%             end
            hl = plot(ax,t,y,'-');
        end
        set(ax,'XLim',[t(1),t(end)]);
        xlabel(['time (1/sampling frequency, t0=',num2str(obj.t0,'%0.1f'),')']);
        ylabel('amplitude');
        
%         v = y;
%         figure();
%         AXLimits = [min([real(v),imag(v)]),max([real(v),imag(v)])];
%         ax1 = axes('XLim',AXLimits,'YLim',AXLimits,'PlotBoxAspectRatio',[1,1,1]);
%         grid on;
% %         pbaspect([1 1 1]);
%         for ii = 1:length(v)
%             plot(ax1,real(v(ii)),imag(v(ii)),'b.','MarkerSize',8);
%             set(ax1,'XLim',AXLimits,'YLim',AXLimits,'PlotBoxAspectRatio',[1,1,1]);
%             hold on;
%             pause(0.01);
%         end
    end
    varargout{1} = ax;
    varargout{2} = hl;
end