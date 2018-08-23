function SinusoidalDecayFit4data(varargin)
% Fit sinusoidal dacay data by load the mat datafile, data stored as x and
% y. Fit results are displayed in the cmd window and a figure file is saved to the data directory. 
% How to use: just run this funciton, no input arguments needed.

% Yulin Wu, Q02,IoP,CAS. mail4ywu@gmail.com
% $Revision: 1.1 $  $Date: 2013/9/13 $

ErrMsg = [];

    persistent lastselecteddir % last direction selection is remembered
    if isempty(lastselecteddir) || ~exist(lastselecteddir,'dir')
        Datafile = fullfile(pwd,'*.mat');
    else
        Datafile = fullfile(lastselecteddir,'*.mat');
    end
    [FileName,PathName,~] = uigetfile(Datafile,'Select data file:');
    if ischar(PathName) && isdir(PathName)
        lastselecteddir = PathName;
    end
    datafile = fullfile(PathName,FileName);
    if ~exist(datafile,'file')
        return;
    end
    load(datafile);

if exist(datafile,'file')
    load(datafile);
    if exist('Time','var')
        x = Time;
    elseif exist('T','var')
        x = T;
    elseif exist('time','var')
        x = time;
    elseif exist('t','var')
        x = t;
    elseif exist('x','var')
        % do nothing
    else
        ErrMsg = 'no variable ''x'' found!';
    end

    if exist('P','var')
        y = P;
    elseif exist('p','var')
        y = p;
    elseif exist('y','var')
        % do nothing
    else
        ErrMsg = 'no variable ''y'' found!';
    end
    if ~any(size(y) == 1)
        ErrMsg = 'Unable to fit two dimentional data!';
    end
    if isempty(ErrMsg)
        LeastOscN = 15;
        [A,B,C,D,freq,td,ci] = SinDecayFit(x,y,LeastOscN);
        h = figure('Position',[0,0,1000,500],'Color',[1,1,1]);
        plot(x,y,'bo','MarkerSize',10,'MarkerEdgeColor','b','MarkerFaceColor','b');
        hold on;
        if ischar(A)
            disp(A);
            xlabel('t','FontSize',28);
            ylabel('P','FontSize',28);
            set(gcf,'Color',[1,1,1]);
            set(gca,'LineWidth',2,'FontSize',24);
            title('automatic fitting failed','FontSize',16);
        else
            home;
            disp('Formula: A +B*(exp(-t/td).*(sin(2*pi*freq*t+D)+C))');
            fprintf('A = %f   B = %f   C = %f   D = %f   freq = %f td = %fnS\n ',A,B,C,D,freq,td);
            fprintf('Confidence interval(95%%): A = [%f,%f]   B = [%f,%f]   C = [%f,%f]   D = [%f,%f]   freq = [%f,%f] td = [%f,%f]nS\n ',ci(1,1),ci(1,2),ci(2,1),ci(2,2),ci(3,1),ci(3,2),ci(4,1),ci(4,2),ci(5,1),ci(5,2),ci(6,1),ci(6,2));
            fprintf('Unit of f: 1/(unit of t); Unit of td: unit of t'); 
            L = length(x);
            step = (x(end)-x(1))/L/50;       % 50 times sampling density
            xf = x(1):step:x(end);
            yf = SinusoidalDecay([A,B,C,D,freq,td],xf);
            
            plot(xf,yf,'r-','LineWidth',2);
            legend('data','fit');
            xlabel('t','FontSize',28);
            ylabel('P','FontSize',28);
            title(['Frequency: ',num2str(freq*1000,'%3.1f'),' 1/(unit of t); td: ',num2str(td,'%4.1f'),' (unit of t)'],'FontSize',16);
            set(gcf,'Color',[1,1,1]);
            set(gca,'LineWidth',2,'FontSize',24);
        end

        button = questdlg('If this automatic fitting failed, you may try fitting by helping me to find the proper initial values for the parameters:');
        if strcmp(button,'Yes')
            close(h);
            h = figure('Position',[0,0,1000,500],'Color',[1,1,1]);
            plot(x,y,'b-o','MarkerSize',8,'MarkerEdgeColor','b','MarkerFaceColor','b');
            title('Waiting... Adjust the figure for good eye sight if needed.','Color','b','FontSize',16);
            pause(3);
            title('What is the y value of the oscillation after full decay, click to indicate, only Y value is important.','FontSize',16);
            [xi,A0] = ginput(1);
            title('What is the oscillation amplitude at time zero, click two points to indicate, only Y values are important.','FontSize',16);
            [xi,yi] = ginput(2);
            B0 = abs(yi(1)-yi(2));
            title('What is the oscillation period, click two points to indicate, only X values are important.','FontSize',16);
            [xi,yi] = ginput(2);
            T = abs(xi(1)-xi(2));
            if T > 0
                freq0 = 1/T;
            else
                freq0 = [];
            end
            title('After what time duration the oscillation decayed to 0.37 of the maximum amplitude, click two points to indicate, only X values are important.','FontSize',16);
            [xi,yi] = ginput(2);
            T = abs(xi(1)-xi(2));
            if T > 0
                td0 = T;
            else
                td0 = [];
            end
            close(h);
            choice = questdlg('Choose fit mode:', ...
                'Fit mode', ...
                'Varied frequency_Exp','Constant frequency_Gaussian','Constant frequency_Exp','Constant frequency_Exp');
            % Handle response
            switch choice
                case 'Constant frequency'
                    [A,B,C,D,freq,td,ci] = SinDecayFit(x,y,LeastOscN,freq0,td0,A0,B0);
                    if ischar(A)
                        disp(A);
                    else
                        home;
                        disp('Formula: A +B*(exp(-t/td).*(sin(2*pi*freq*t+D)+C))');
                        fprintf('A = %f   B = %f   C = %f   D = %f   freq = %f td = %fnS\n ',A,B,C,D,freq,td);
                        fprintf('Confidence interval(95%%): A = [%f,%f]   B = [%f,%f]   C = [%f,%f]   D = [%f,%f]   freq = [%f,%f] td = [%f,%f]nS\n ',ci(1,1),ci(1,2),ci(2,1),ci(2,2),ci(3,1),ci(3,2),ci(4,1),ci(4,2),ci(5,1),ci(5,2),ci(6,1),ci(6,2));
                        fprintf('Unit of f: 1/(unit of t); Unit of td: unit of t'); 
                        h = figure('Position',[0,0,1000,500],'Color',[1,1,1]);
                        L = length(x);
                        step = (x(end)-x(1))/L/50;       % 50 times sampling density
                        xf = x(1):step:x(end);
                        yf = SinusoidalDecay([A,B,C,D,freq,td],xf);
                        plot(x,y,'bo','MarkerSize',10,'MarkerEdgeColor','b','MarkerFaceColor','b');
                        hold on;
                        plot(xf,yf,'r-','LineWidth',2);
                        legend('data','fit');
                        xlabel('t','FontSize',28);
                        ylabel('P','FontSize',28);
                        title(['Frequency: ',num2str(freq*1000,'%3.1f'),' 1/(unit of t); td: ',num2str(td,'%4.1f'),' (unit of t)'],'FontSize',16);
                        set(gcf,'Color',[1,1,1]);
                        set(gca,'LineWidth',2,'FontSize',24);
                    end
                case 'Constant frequency_Gaussian'
                    [A,B,C,D,freq,td,ci] = SinDecayFit_G(x,y,LeastOscN,freq0,td0,A0,B0);
                    if ischar(A)
                        disp(A);
                    else
                        home;
                        disp('Formula: A +B*(exp(-t/td).*(sin(2*pi*freq*t+D)+C))');
                        fprintf('A = %f   B = %f   C = %f   D = %f   freq = %f td = %fnS\n ',A,B,C,D,freq,td);
                        fprintf('Confidence interval(95%%): A = [%f,%f]   B = [%f,%f]   C = [%f,%f]   D = [%f,%f]   freq = [%f,%f] td = [%f,%f]nS\n ',ci(1,1),ci(1,2),ci(2,1),ci(2,2),ci(3,1),ci(3,2),ci(4,1),ci(4,2),ci(5,1),ci(5,2),ci(6,1),ci(6,2));
                        fprintf('Unit of f: 1/(unit of t); Unit of td: unit of t'); 
                        h = figure('Position',[0,0,1000,500],'Color',[1,1,1]);
                        L = length(x);
                        step = (x(end)-x(1))/L/50;       % 50 times sampling density
                        xf = x(1):step:x(end);
                        yf = SinusoidalDecay_G([A,B,C,D,freq,td],xf);
                        plot(x,y,'bo','MarkerSize',10,'MarkerEdgeColor','b','MarkerFaceColor','b');
                        hold on;
                        plot(xf,yf,'r-','LineWidth',2);
                        legend('data','fit');
                        xlabel('t','FontSize',28);
                        ylabel('P','FontSize',28);
                        title(['Frequency: ',num2str(freq*1000,'%3.1f'),' 1/(unit of t); td: ',num2str(td,'%4.1f'),' (unit of t)'],'FontSize',16);
                        set(gcf,'Color',[1,1,1]);
                        set(gca,'LineWidth',2,'FontSize',24);
                    end
                case 'Varied frequency'
                    [A,B,C,D,freq,td,varf,ci] = SinDecayFit_varf(x,y,LeastOscN,freq0,td0,A0,B0);
                    if ischar(A)
                        disp(A);
                    else
                        home;
                        disp('Formula: A +B*(exp(-t/td).*(sin(2*pi*(freq+varf*t)*t+D)+C))');
                        fprintf('A = %f   B = %f   C = %f   D = %f   freq = %f varf = %f td = %fnS\n ',A,B,C,D,freq,varf,td);
                        fprintf('Confidence interval(95%%): A = [%f,%f]   B = [%f,%f]   C = [%f,%f]   D = [%f,%f]   freq = [%f,%f] varf = [%f,%f] td = [%f,%f]nS\n ',ci(1,1),ci(1,2),ci(2,1),ci(2,2),ci(3,1),ci(3,2),ci(4,1),ci(4,2),ci(5,1),ci(5,2),ci(7,1),ci(7,2),ci(6,1),ci(6,2));
                        fprintf('Unit of f: 1/(unit of t); Unit of td: unit of t'); 
                        h = figure('Position',[0,0,1000,500],'Color',[1,1,1]);
                        L = length(x);
                        step = (x(end)-x(1))/L/50;       % 50 times sampling density
                        xf = x(1):step:x(end);
                        yf = SinusoidalDecay_varf([A,B,C,D,freq,td,varf],xf,xf(1));
                        plot(x,y,'bo','MarkerSize',10,'MarkerEdgeColor','b','MarkerFaceColor','b');
                        hold on;
                        plot(xf,yf,'r-','LineWidth',2);
                        legend('data','fit');
                        xlabel('t','FontSize',28);
                        ylabel('P','FontSize',28);
                        title(['Frequency: ',num2str(freq*1000,'%3.1f'),' 1/(unit of t); td: ',num2str(td,'%4.1f'),' (unit of t)'],'FontSize',16);
                        set(gcf,'Color',[1,1,1]);
                        set(gca,'LineWidth',2,'FontSize',24);
                    end
            end
        end
        button = questdlg('Save figure?');
        if strcmp(button,'Yes')
            saveas(h,[datafile(1:end-4),'(fit).fig']);
            saveas(h,[datafile(1:end-4),'(fit).png']);
        end
    else
        msgbox(ErrMsg);
    end
end



