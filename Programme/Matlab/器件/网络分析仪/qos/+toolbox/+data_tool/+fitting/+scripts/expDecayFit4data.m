function expDecayFit4data()
% Fit exponential decay data by load the mat datafile, data stored as x and
% y. Fit results are displayed in the cmd window and a figure file is saved to the data directory. 
% How to use: just run this function, no input arguments needed.

%
% Yulin Wu, SC5,IoP,CAS. wuyulin@ssc.iphy.ac.cn/mail4ywu@gmail.com
% $Revision: 1.0 $  $Date: 2012/04/08 $

    import toolbox.data_tool.fitting.*
    
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

    if ~exist('x','var') || ~exist('y','var')
        error('variable x or y not exist.');
    end

    t = x(:);
    P = y(:);

    [A,B,td] = expDecayFit(t,P);
    h = figure('Position',[0,0,1601,796]);
    L = length(t);
    step = (t(end)-t(1))/L/50;       % 50 times sampling density
    tf = t(1):step:t(end);
    pf = expDecay([A,B,td],tf);
    fucnstr = sprintf('y =@(x) %f +%f*exp(-x/%f)',A,B,td);
    home;
    disp('Fit fucntion handle:');
    disp(fucnstr);
    plot(t,P,'bo','MarkerSize',10,'MarkerEdgeColor','b','MarkerFaceColor','b');
    hold on;
    plot(tf,pf,'r-','LineWidth',2);
    legend('data','fit');
    xlabel('t','FontSize',28);
    ylabel('P','FontSize',28);
    title(['T_1: ',num2str(td,'%4.1f'),''],'FontSize',20)
    set(gcf,'Color',[1,1,1]);
    set(gca,'LineWidth',2,'FontSize',20);
    saveas(h,[datafile(1:end-4),'(fit1).fig']);
    saveas(h,[datafile(1:end-4),'(fit1).png']);
end
