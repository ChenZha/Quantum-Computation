% data: x, y

        LeastOscN = 15;
        [A,B,C,D,freq,td,ci] = toolbox.data_tool.fitting.sinDecayFit_auto(x,y);
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
            yf = toolbox.data_tool.fitting.SinusoidalDecayTilt([A, B,C,D,freq,td],xf);
            
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
            freq0 = 1/T;
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
                'Varied frequency Exp','Constant frequency Gaussian','Constant frequency Exp','Constant frequency Exp');
            % Handle response
            switch choice
                case 'Constant frequency Exp'
                    [A, B,C,D,freq,td,ci] = toolbox.data_tool.fitting.sinDecayFitTilt(x,y,...
                        A0,[0.9*A0,1.1*A0],...
                        0.5*B0,[0.3*B0,0.7*B0],...
                        0.5,[0.3,0.7],...
                        pi/2,[-pi,pi],...
                        freq0,[0.7*freq0,1.4*freq0],...
                        td0,[0.7*td0,1.4*td0]);
%                     [B,C,D,freq,td,ci] = toolbox.data_tool.fitting.sinDecayFit_m(x,y,...
%                         0.5*B0,[0.3*B0,0.7*B0],...
%                         A0/(0.5*B0),sort([0.7*A0/(0.5*B0),1.4*A0/(0.5*B0)]),...
%                         pi/2,[-pi,pi],...
%                         freq0,[0.7*freq0,1.4*freq0],...
%                         td0,[0.7*td0,1.4*td0]);
                    if ischar(A)
                        disp(A);
                    else
                        home;
                        disp('Formula: A +B*(exp(-t/td).*(sin(2*pi*freq*t+D)+C))');
                        fprintf('B = %f   C = %f   D = %f   freq = %f td = %fnS\n ',B,C,D,freq,td);
                        fprintf('Confidence interval(95%%): B = [%f,%f]   C = [%f,%f]   D = [%f,%f]   freq = [%f,%f] td = [%f,%f]nS\n ',...
                            ci(1,1),ci(1,2),ci(2,1),ci(2,2),ci(3,1),ci(3,2),ci(4,1),ci(4,2),ci(5,1),ci(5,2));
                        fprintf('Unit of f: 1/(unit of t); Unit of td: unit of t'); 
                        h = figure('Position',[0,0,1000,500],'Color',[1,1,1]);
                        L = length(x);
                        step = (x(end)-x(1))/L/50;       % 50 times sampling density
                        xf = x(1):step:x(end);
                        yf = toolbox.data_tool.fitting.SinusoidalDecayTilt([A,B,C,D,freq,td],xf);
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
                case 'Constant frequency Gaussian'
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