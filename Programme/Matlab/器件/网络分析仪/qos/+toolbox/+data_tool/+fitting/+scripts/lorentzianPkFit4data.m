function LorentzianPkFit4data()
% Fit Lorentzian peak data by load the mat datafile, data stored as x and
% y. Fit results are displayed in the cmd window and a figure file is saved to the data directory. 
% How to use: just run this funciton, no input arguments needed.

% Yulin Wu, Q02,IoP,CAS. mail4ywu@gmail.com
% $Revision: 2.0 $  $Date: 2013/12/29 $

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
    if exist('MWFreq','var');
        x = MWFreq;
    elseif exist('MWFrequency','var');
        x = MWFrequency;
    elseif exist('Freq','var');
        x = Freq;
    elseif exist('Frequency','var');
        x = Frequency;
    elseif exist('MW_Freq','var');
        x = MW_Freq;
    elseif exist('MW_Frequency','var');
        x = MW_Frequency;
    elseif exist('mwfreq','var');
        x = MWFreq;
    elseif exist('mwfrequency','var');
        x = MWFrequency;
    elseif exist('Freq','var');
        x = Freq;
    elseif exist('frequency','var');
        x = Frequency;
    elseif exist('F','var');
        x = F;
    elseif exist('mw_freq','var');
        x = MW_Freq;
    elseif exist('mw_frequency','var');
        x = MW_Frequency;
    elseif exist('f','var');
        x = f;
    elseif exist('x','var');
        % do nothing
    else
        ErrMsg = 'no variable ''x'' found!';
    end

    if exist('P','var');
        y = P;
    elseif exist('p','var');
        y = p;
    elseif exist('y','var');
        % do nothing
    else
        ErrMsg = 'no variable ''y'' found!';
    end
    if isempty(ErrMsg)
        [y0, A, w, x0] = LorentzianPkFit(x,y);
        if ischar(y0)
            disp(y0);
        else
            home;
            disp('Formula:  y = y0 + (2*A/pi)*(w/(4*(x-x0)^2+w^2))');
            fprintf('y0 = %f  A = %f  w = %f   x0 = %f\n ',y0, A, w, x0);
            fprintf('Peak amplitude = %f  FWHM = %f\n ',2*A/(pi*w), w);
            L = length(x);
            step = (x(end)-x(1))/L/20;       % 20 times sampling density
            xf = x(1):step:x(end);
            yf = Lorentzian([y0, A, w, x0],xf);
            FigHandle = figure('position',[30,30,900,675],'Color',[1,1,1]);
            AxesHandle = axes('parent',FigHandle);
            plot(AxesHandle,x,y,'bo',...
                        'MarkerEdgeColor','b',...
                        'MarkerFaceColor','b',...
                        'MarkerSize',6,...
                        'LineWidth',2);
            hold on;
            plot(AxesHandle,xf,yf,'r-',...
                        'MarkerEdgeColor','b',...
                        'MarkerFaceColor','b',...
                        'MarkerSize',8,...
                         'LineWidth',3);
            legend('data','fit');
            xlabel('f (GHz)','FontSize',28);
            ylabel('P','FontSize',28);
            title(['FWHM: ',num2str(w,'%f'), '; Peak amplitude: ', num2str(2*A/(pi*w),'%f')],'FontSize',16);
            set(AxesHandle,'LineWidth',2,'FontSize',24,'Box','on');

            minx = min(x);
            maxx = max(x);
            xlim1 = minx - 0.1*(maxx - minx);
            xlim2 = maxx + 0.1*(maxx - minx);
            if xlim2 > xlim1
                xlim(AxesHandle,[xlim1, xlim2]);
            end

            miny = min(y);
            maxy = max(y);
            ylim1 = miny - 0.1*(maxy - miny);
            ylim2 = maxy + 0.1*(maxy - miny);
            if ylim2 > ylim1
                ylim(AxesHandle,[ylim1, ylim2]);
            end
        end

        button = questdlg('If this automatic fitting failed, you may try fitting by helping me to find the proper initial values for the parameters:');
        if strcmp(button,'Yes')
            close(FigHandle);
            FigHandle = figure('position',[30,30,900,675],'Color',[1,1,1]);
            AxesHandle = axes('parent',FigHandle);
            plot(AxesHandle,x,y,'-bo',...
                        'MarkerEdgeColor','b',...
                        'MarkerFaceColor','b',...
                        'MarkerSize',3,...
                        'LineWidth',1);
            title('Waiting... Adjust the figure for good eye sight if needed.','Color','b','FontSize',16);
            pause(3);
            title('Click to indicate the position of the peak, both X value and Y value are important!','FontSize',16);
            [x00,yi] = ginput(1);
            title('Click to indicate the background, only Y value is important.','FontSize',16);
            [xi,y00] = ginput(1);
            Amplitude = (yi-y00);
            title('Click two points to indicate FWHM, only X values are important.','FontSize',16);
            [xi,yi] = ginput(2);
            w0 = abs(xi(1)-xi(2));
            A0 = pi*w0*Amplitude/2;
            close(FigHandle);
            [y0, A, w, x0] = LorentzianPkFit(x,y,x00,A0,w0,y00);
            if ischar(y0)
                disp(y0);
            else
                home;
                disp('Formula:  y = y0 + (2*A/pi)*(w/(4*(x-x0)^2+w^2))');
                fprintf('y0 = %f  A = %f  w = %f   x0 = %f\n ',y0, A, w, x0);
                fprintf('Peak amplitude = %f  FWHM = %f\n ',2*A/(pi*w), w);
                L = length(x);
                step = (x(end)-x(1))/L/20;       % 20 times sampling density
                xf = x(1):step:x(end);
                yf = Lorentzian([y0, A, w, x0],xf);
                FigHandle = figure('position',[30,30,900,675],'Color',[1,1,1]);
                AxesHandle = axes('parent',FigHandle);
                plot(AxesHandle,x,y,'bo',...
                            'MarkerEdgeColor','b',...
                            'MarkerFaceColor','b',...
                            'MarkerSize',6,...
                            'LineWidth',2);
                hold on;
                plot(AxesHandle,xf,yf,'r-',...
                            'MarkerEdgeColor','b',...
                            'MarkerFaceColor','b',...
                            'MarkerSize',8,...
                             'LineWidth',3);
                legend('data','fit');
                xlabel('f (GHz)','FontSize',28);
                ylabel('P','FontSize',28);
                title(['FWHM: ',num2str(w,'%f'), '; Peak amplitude: ', num2str(2*A/(pi*w),'%f')],'FontSize',16);
                set(AxesHandle,'LineWidth',2,'FontSize',24,'Box','on');

                minx = min(x);
                maxx = max(x);
                xlim1 = minx - 0.1*(maxx - minx);
                xlim2 = maxx + 0.1*(maxx - minx);
                if xlim2 > xlim1
                    xlim(AxesHandle,[xlim1, xlim2]);
                end

                miny = min(y);
                maxy = max(y);
                ylim1 = miny - 0.1*(maxy - miny);
                ylim2 = maxy + 0.1*(maxy - miny);
                if ylim2 > ylim1
                    ylim(AxesHandle,[ylim1, ylim2]);
                end
            end

            button = questdlg('If fitting failed, you may try fitting with a backgroud ''y0 + k1*x + k2*x^2'':');
            if strcmp(button,'Yes')
                close(FigHandle);
                [y0, k1, k2, A, w, x0] = LorentzianPkFit_Adv(x,y,x00,A0,w0,y00);
                if ischar(y0)
                    disp(y0);
                else
                    home;
                    disp('Formula:  y = y0 + k1*x + k2*x^2 + (2*A/pi)*(w/(4*(x-x0)^2+w^2))');
                    fprintf('y0 = %f   k1 = %f   k2 = %f   A = %f   w = %f   x0 = %f\n ',y0, k1, k2, A, w, x0);
                    fprintf('Peak amplitude = %f  FWHM = %f\n ',2*A/(pi*w), w);
                    L = length(x);
                    step = (x(end)-x(1))/L/20;       % 20 times sampling density
                    xf = x(1):step:x(end);
                    yf = Lorentzian_Adv([y0, k1, k2, A, w, x0],xf);
                    FigHandle = figure('position',[30,30,900,675],'Color',[1,1,1]);
                    AxesHandle = axes('parent',FigHandle);
                    plot(AxesHandle,x,y,'bo',...
                                'MarkerEdgeColor','b',...
                                'MarkerFaceColor','b',...
                                'MarkerSize',6,...
                                'LineWidth',2);
                    hold on;
                    plot(AxesHandle,xf,yf,'r-',...
                                'MarkerEdgeColor','b',...
                                'MarkerFaceColor','b',...
                                'MarkerSize',8,...
                                 'LineWidth',3);
                    legend('data','fit');
                    xlabel('f (GHz)','FontSize',28);
                    ylabel('P','FontSize',28);
                    title(['FWHM: ',num2str(w,'%f'), '; Peak amplitude: ', num2str(2*A/(pi*w),'%f')],'FontSize',16);
                    set(AxesHandle,'LineWidth',2,'FontSize',24,'Box','on');

                    minx = min(x);
                    maxx = max(x);
                    xlim1 = minx - 0.1*(maxx - minx);
                    xlim2 = maxx + 0.1*(maxx - minx);
                    if xlim2 > xlim1
                        xlim(AxesHandle,[xlim1, xlim2]);
                    end

                    miny = min(y);
                    maxy = max(y);
                    ylim1 = miny - 0.1*(maxy - miny);
                    ylim2 = maxy + 0.1*(maxy - miny);
                    if ylim2 > ylim1
                        ylim(AxesHandle,[ylim1, ylim2]);
                    end
                end
            end
        end
        button = questdlg('Save figure?');
        if strcmp(button,'Yes')
            saveas(FigHandle,[datafile(1:end-4),'(fit).fig']);
            saveas(FigHandle,[datafile(1:end-4),'(fit).png']);
        end
    else
        msgbox(ErrMsg);
    end
end
