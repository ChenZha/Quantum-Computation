function FlxQbtSpcFit()
% fit flux qubit spectrum by openning the spectrum figure file
% how to use:
% just run this funcion.

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com
    persistent lastselecteddir
    if isempty(lastselecteddir) || ~exist(lastselecteddir,'dir')
        Datafile = fullfile(pwd,'*.fig');
    else
        Datafile = fullfile(lastselecteddir,'*.fig');
    end
    
    [FileName,PathName,~] = uigetfile(Datafile,'Select the flux qubit spectrum figure(*.fig) file to fit:');
    if ischar(PathName) && isdir(PathName)
        lastselecteddir = PathName;
    end
    figfile = fullfile(PathName,FileName);
    if ~exist(figfile,'file')
        return;
    end
    open(figfile);
    title('Adjust the figure window for good eye sight if needed.');
    pause(4);
    title(['Left click to select data points then press Enter.',char(10),...
        'Fitting coefficients will be displayed in command window.']);
    [x,y] = ginput;
    [x, idx] = sort(x);
    y = y(idx);
    if length(x)<3 || x(1)+x(end) == 0
        error('Pick at least three data points!');
    else
        Coefficients(1) = (x(1)+x(end))/2;
        Coefficients(2) = min(y);
        % Coefficients(3) = abs(2*max(y)/(x(1)-x(end)));
        Coefficients(3) = abs(2*(max(y) - Coefficients(2))/(x(1)-x(end)));
        for ii = 1:5
            Coefficients = lsqcurvefit(@FlxQbtSpc,Coefficients,x,y);
        end
        x0 = Coefficients(1);
        Delta = Coefficients(2);
        k = Coefficients(3);
        title(['Fit coefficients are displayed in command window.']);
        
        home;
        disp('Formula: y = sqrt((k*(x-x0)).^2 + Delta^2)');
        disp(['Center position x0 = ', num2str(x0,'%0.6f')]);
        disp(['Energy gap Delta = ', num2str(Delta,'%0.6f')]);
        disp(['k = ', num2str(k,'%0.6f')]);
        b = 6.626068e-34*k/2.067833636e-15*1e9/2*1e9;
        disp(['Ip = ', num2str(b,'%0.6f'), '*T*b (nA), where T and b are unitless, x/T is the qubit flux bias(Phi0), b*y is the microwave frequency(GHz),']);
        disp(['e.g., if the unit of y axis is Hz, b = 1e-9, if the unit of y axis is GHz, b = 1.']);
        
        xi = linspace(min(x),max(x),2000);
        yi = FlxQbtSpc(Coefficients,xi);
        hold(gca,'on');
        xlimit = get(gca,'XLim');
        ylimit = get(gca,'YLim');
        set(gcf,'Color',[1,1,1]);
        plot(x,y,'xb',xi,yi,'-b');
        set(gca,'XLim',xlimit);
        set(gca,'YLim',ylimit);
        set(gcf,'Color',[1,1,1]);
        
    end
end

    

function [y]=FlxQbtSpc(Coefficients,x)
% y = sqrt((k(x-x0)).^2+Delta^2);
x0 = Coefficients(1);
Delta = Coefficients(2);
k = Coefficients(3);
y = sqrt((k*(x-x0)).^2+Delta^2);
end