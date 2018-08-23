function GapIpSpreadVsAlphaS(jc,c,S,alpha,varargin)
%...
% jc unit: kA/cm^2
% c unit: fF/mum^2
% S unit: num^2
% varargin: 
% beta = varargin{1};
% kappa = varargin{2};
% NMatlabpools = varargin{3};
clc;
NMatlabpools = 2; 
FluxQuantum = 2.067833636e-15;
PlanksConst = 6.626068E-34;
ee = 1.602176e-19;
beta = 0;
if nargin > 4
    beta = varargin{1};
end
if nargin > 5
    kappa = varargin{2};
end
if nargin > 6
    NMatlabpools = int8(varargin{3});
    if NMatlabpools < 1
        NMatlabpools = 1;
    end
end
if beta < 0
    beta =0;
    disp('Warnning: beta < 0 ! beta will be set to 0 !');
    disp('Beta value has been set to 0 !');
end
nk = 5;
nl = 10;
nm = 2;
tmp1 = alpha;
tmp2 = S;
NN = length(alpha);
MM = length(S);
OutputDataName=['Data\GapIpSpreadVsAlphaS-c' num2str(c) 'jc' num2str(jc) 'beta' num2str(beta), '_'];
if isempty(dir('Data'))
    mkdir('Data');
end
fid = dir([OutputDataName, '*.mat']);
flag = 0;
if ~isempty(fid)
    for kk = 1:length(fid)
        filename = ['Data\', fid(kk).name];
        load(filename);
        if NN==length(alpha) && MM==length(S) && sum(tmp1==alpha)==length(tmp1) && sum(tmp2==S)==length(tmp2)
            flag = 1;
            OutputDataName = filename;
            if hh <= NN
                disp('A previous calculation for the present set of paramenters has been carried out but not finished.');
                disp('This calculation will continue the unfinished caculation job.');
                disp('If you want to do a new calculation, delete the following file(or move it to another location):');
                disp(OutputDataName);
            else
                disp('Calculation for the present set of paramenters has been done before.');
                disp('Energy level diagram will be ploted directly by loading the saved data file.')
                disp('If you want to do a new calculation, delete the following file(or move it to another location):');
                disp(OutputDataName);
                flag =2;
            end
            break;
        end
    end
end
if flag == 0
   alpha = tmp1;
   S = tmp2;
   hh = 1;
   x = zeros(NN,MM);
   y = zeros(NN,MM);
   EGap = zeros(NN,MM);
   Ip = zeros(NN,MM);
   MaxSpread = zeros(NN,MM);
   MinSpread = zeros(NN,MM);
   OutputDataName = [OutputDataName, num2str(int32(1e5*rand())) '.mat'];
end
if flag ~= 2
    if NMatlabpools > 1        % Start parallel language worker pool
        matlabpool(NMatlabpools);
    end
    disp('Calculation start ... ...');
    tic;
    hh0=hh-1;
    while hh <=NN
        x(hh,:) = S;
        y(hh,:) = alpha(hh)*ones(1,MM);
        Ic = jc*10*S;   % 1kA/cm^2 = 10 muA/mum^2
        Ej = Ic*1e-6*FluxQuantum/(2*pi)/PlanksConst/1e9;    % Unit: GHz.
        Ec = ee^2./(2*S*c*1e-15)/PlanksConst/1e9;   % Unit: GHz.
        L = length(S);
        ALPHA = alpha(hh);
        parfor ii = 1:L
            EL = TriJFlxQbtEL(Ej(ii),Ec(ii),ALPHA,beta,kappa,0,0.500,nk,nl,nm,4);
            EGap(hh,ii) = (EL(3) + EL(4) - EL(2) -EL(1))/2;
            MaxSpread(hh,ii) = EL(4) - EL(1) - (EL(3)-EL(2));
            EL = TriJFlxQbtEL(Ej(ii),Ec(ii),ALPHA,beta,kappa,0,0.480,nk,nl,nm,4);
            Ip(hh,ii) = 160*((EL(3) + EL(4) - EL(2) -EL(1))/2)/20;
            MinSpread(hh,ii) = EL(4) - EL(1) - (EL(3)-EL(2));
        end
        toc;
        time = toc/60;
        timeremaining = time*(NN-hh)/(hh-hh0);
        clc;
        disp(['Time elapsed: ', num2str(time)]);
        disp(['Estimated time remaining: ', num2str(timeremaining)]);
        disp('Calculation can work in a BREAK and CONTINUE mode. You can exit the calculation when it has not');
        disp('been finished and restart the programme next time with the same parameters, the calculation');
        disp('will continue from the break point.');
        hh = hh+1;
        save(OutputDataName,'alpha','S','hh','EGap','Ip','MaxSpread','MinSpread');
    end
    if NMatlabpools > 1
        matlabpool close; 
    end
else
    for hh=1:NN
        x(hh,:) = S;
        y(hh,:) = alpha(hh)*ones(1,MM);
    end
end
FigSaveName = OutputDataName(1:end-4);

PlotFigHandle1 = figure('Position',[100,25,800*4/3,800]);
PlotAX1 = axes('parent',PlotFigHandle1,'FontSize',16);
% surfc(PlotAX1,x,y,EGap);
% shading interp;
% YMAX = max(max(EGap));
% % axis([min(alpha),max(alpha),min(S),max(S),0,YMAX]);
% xlabel('Junction Area (\mum^2)');
% ylabel('\alpha');
% zlabel('Gap (GHz)');
% title(['J_c:',num2str(jc),'\muA/\mum^2;  c:',num2str(c), 'fF/\mum^2;  \beta:', num2str(beta)]);
% saveas(PlotFigHandle1,[FigSaveName,'_1.fig']);

xI = interp2(x,2);      % interp2(x,2)插值后数据密度变为16倍
yI = interp2(y,2);
EGapI = interp2(x,y,EGap,xI,yI,'*spline');
[C,h1] = contourf(PlotAX1,xI,yI,EGapI,'LevelStep',0.5);
set(h1,'ShowText','on','TextStep',get(h1,'LevelStep')*2);
colormap cool;
xlabel('Junction Area (\mum^2)','FontSize',18);
ylabel('\alpha','FontSize',18);
title(['Gap (GHz), J_c:',num2str(jc),'\muA/\mum^2;  c:',num2str(c), 'fF/\mum^2;  \beta:', num2str(beta)],'FontSize',18);
saveas(PlotFigHandle1,[FigSaveName,'_1.fig']);
saveas(PlotFigHandle1,[FigSaveName,'_1.png']);

PlotFigHandle2 = figure('Position',[100,25,800*4/3,800]);
PlotAX2 = axes('parent',PlotFigHandle2,'FontSize',16);
% surfc(PlotAX2,x,y,Ip);
% shading interp;
% xlabel('Junction Area (\mum^2)');
% ylabel('\alpha');
% zlabel('Ip (nA)');
% title(['J_c:',num2str(jc),'\muA/\mum^2;  c:',num2str(c), 'fF/\mum^2;  \beta:', num2str(beta)]);
% saveas(PlotFigHandle2,[FigSaveName,'_2.fig']);

IpI = interp2(x,y,Ip,xI,yI,'*spline');
[C,h2] = contourf(PlotAX2,xI,yI,IpI,'LevelStep',5);
set(h2,'ShowText','on','TextStep',get(h2,'LevelStep')*2)
colormap cool
xlabel('Junction Area (\mum^2)','FontSize',18);
ylabel('\alpha','FontSize',18);
title(['Ip (nA), J_c:',num2str(jc),'\muA/\mum^2;  c:',num2str(c), 'fF/\mum^2;  \beta:', num2str(beta)],'FontSize',18);
saveas(PlotFigHandle2,[FigSaveName,'_2.fig']);
saveas(PlotFigHandle2,[FigSaveName,'_2.png']);

PlotFigHandle3 = figure('Position',[100,25,800*4/3,800]);
PlotAX3 =  axes('parent',PlotFigHandle3,'FontSize',16);
% surfc(PlotAX3,x,y,MaxSpread*1000);
% shading interp;
% xlabel('Junction Area (\mum^2)');
% ylabel('\alpha');
% zlabel('Max EL Spliting (MHz)');
% title(['J_c:',num2str(jc),'\muA/\mum^2;  c:',num2str(c), 'fF/\mum^2;  \beta:', num2str(beta)]);
% saveas(PlotFigHandle3,[FigSaveName,'_3.fig']);

MaxSpreadI = interp2(x,y,MaxSpread,xI,yI,'*spline');
if max(max(MaxSpreadI*1000)) < 0.5
    LevelStep = 0.01;
elseif max(max(MaxSpreadI*1000)) < 5
    LevelStep = 0.1;
elseif max(max(MaxSpreadI*1000)) < 50
    LevelStep = 1;
elseif max(max(MaxSpreadI*1000)) < 500
    LevelStep = 10;
else
    LevelStep = max(max(MaxSpreadI*1000))/50;
end
[C,h3] = contourf(PlotAX3,xI,yI,MaxSpreadI*1000,'LevelStep',LevelStep);
set(h3,'ShowText','on','TextStep',get(h3,'LevelStep')*2)
colormap cool
xlabel('Junction Area (\mum^2)','FontSize',18);
ylabel('\alpha','FontSize',18);
title(['Max EL Spliting (MHz), J_c:',num2str(jc),'\muA/\mum^2;  c:',num2str(c), 'fF/\mum^2;  \beta:', num2str(beta)],'FontSize',18);
saveas(PlotFigHandle3,[FigSaveName,'_3.fig']);
saveas(PlotFigHandle3,[FigSaveName,'_3.png']);

PlotFigHandle4 = figure('Position',[100,25,800*4/3,800]);
PlotAX4 =  axes('parent',PlotFigHandle4,'FontSize',16);
% surfc(PlotAX4,x,y,MinSpread*1000);
% shading interp;
% xlabel('Junction Area (\mum^2)');
% ylabel('\alpha');
% zlabel('Min EL Spliting (MHz)');
% title(['J_c:',num2str(jc),'\muA/\mum^2;  c:',num2str(c), 'fF/\mum^2;  \beta:', num2str(beta)]);
% saveas(PlotFigHandle4,[FigSaveName,'_4.fig']);

MinSpreadI = interp2(x,y,MinSpread,xI,yI,'*spline');
[C,h4] = contourf(PlotAX4,xI,yI,MinSpreadI*1000,'LevelStep',LevelStep);
set(h4,'ShowText','on','TextStep',get(h4,'LevelStep')*2)
colormap cool
xlabel('Junction Area (\mum^2)','FontSize',18);
ylabel('\alpha','FontSize',18);
title(['Min EL Spliting (MHz), J_c:',num2str(jc),'\muA/\mum^2;  c:',num2str(c), 'fF/\mum^2;  \beta:', num2str(beta)],'FontSize',18);
saveas(PlotFigHandle4,[FigSaveName,'_4.fig']);
saveas(PlotFigHandle4,[FigSaveName,'_4.png']);