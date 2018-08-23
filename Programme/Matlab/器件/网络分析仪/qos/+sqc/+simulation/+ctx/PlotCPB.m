
% plots the lowest energy levels and the
% average charge of a Cooper Pair Box (CPB), both single junction
% CPB and split CPB.
% A function call plots two figures, one is the energy levels and
% and the other is the average charge. The calculated data is
% saved to the current directory thus a later function call  with
% the same parameters can  skip the calculation procedure.
% Single Junction CPB:
% PlotCPB(Ec,Ej,'s'); PlotCPB(Ec,Ej,'s',N);
% PlotCPB(Ec,Ej,'s',N,NgLim); PlotCPB(Ec,Ej,'s',N,NgLim,nP);
% Split CPB:
% PlotCPB(Ec,Ej); PlotCPB(Ec,Ej,dEj); 
% PlotCPB(Ec,Ej,dEj,N); PlotCPB(Ec,Ej,dEj,N,NgLim);
% PlotCPB(Ec,Ej,dEj,N,NgLim,phiLim);
% PlotCPB(Ec,Ej,dEj,N,NgLim,phiLim,nP);
% Ec=(2e)^2/C_\sigma, the Cooper Pair Coulomb energy;
% Ej, Josephson Energy for single junction CPB,
% Ej=Ej1+Ej2 for split CPB;
% 's' could be any string, [single Junction CPB]
% dEj=Ej1-Ej2 [split CPB];
% N, plot N energy level(s).
% NgLim, phiLim define plotting range for Ng and \delta,
% Ng=CgVg/2e is the charge bias, \detta=2*\pi*FluxBias/FluxQuantum
% is the phase bias [single Junction CPB];
% nP, for single junction CPB: calculate 50 points to plot the
% energy level curve(s), for split CPB: calculate 50*50 points to
% plot the energy level surface(s);
% dEj,NgLim,phiLim,nP,N are not neccesary in the function call, if
% not specified, their default values will be assigned to them.
% Example:
% single junction CPB: PlotCPB(1,0.5,'s');
% PlotCPB(1,0.5,'s',4);
% PlotCPB(1,0.5,'s',4,[-0.21 1.25],200);
% split CPB with no asymmetry: PlotCPB(1,1);
% split CPB with asymmetry: PlotCPB(1,1,0.1), dEj=0.05;
% PlotCPB(1,1,0.1,3).
% PlotCPB(1,1,0.1,3,[-0.21 1.5],[-0.21 1.5],60).
% Author: Yulin Wu
% Date: 2009/7/14
% Email: mail4ywu@gmail.com

function PlotCPB(Ec,Ej,varargin)
dEj=0;                      % By default,assume split CPB and No asymmetry,
NgLim=[-0.25 1.25];         % ploting range: Ng, [-0.25 1.25],
phiLim=[-1.25 1.25]*pi;     % \delta, [-1.25*pi 1.25*pi],
nP=50;                      % 50*50 points for each energy level surface and
N=2;                        % plot 2 energy levels.
if nargin<2
    errot('Not enough input arguments !');
elseif nargin>7 || (ischar(dEj) && nargin>6)
    error('Too many input arguments !');
elseif nargin>2
    dEj=varargin{1};
	if nargin>3
        N=varargin{2};
    end
    if nargin>4
        NgLim=varargin{3};
    end
    if nargin>5
        phiLim=varargin{4}*pi;
    end
    if nargin>6
        nP=varargin{5};
    end
    if NgLim(2)<=NgLim(1) ||  phiLim(2)<=phiLim(1) || nP <3 || N>20 || N<2 || (~ischar(dEj) && nP>500)
        error('Bad input argument value !');
    end
end
tmp=size(dir('Output'));
if tmp(1)==0 || ~isdir('Output')    % If folder Output do not exit, make one.
    mkdir('Output');
end
if ~ischar(dEj)             % split CPB
    phi=linspace(phiLim(1),phiLim(2),nP);
    OutputDataName=['Output\sCPB-Ec' num2str(Ec) 'Ej' num2str(Ej) 'dEj' num2str(dEj) 'NgLim' num2str(NgLim(1)) '-' num2str(NgLim(2)) 'deltaLim' num2str(phiLim(1)/pi) 'pi-' num2str(phiLim(2)/pi) 'pi_' num2str(N) '-' num2str(nP) '.mat'];
else                        % CPB
    nP=500;                 % By default, calculate 500 points for the energy curve of single junction CPB.
    OutputDataName=['Output\CPB-Ec' num2str(Ec) 'Ej' num2str(Ej) 'NgLim' num2str(NgLim(1)) '-' num2str(NgLim(2)) '_' num2str(N)  '-' num2str(nP) '.mat'];
end
Ng=linspace(NgLim(1),NgLim(2),nP);
if size(dir(OutputDataName),1)==0               % Check if the data already exits.
    EnergyLevel=cell(1,N);
    for ii=1:nP
        if ischar(dEj)      % CPB
            [EL, EigV]=CPBEL(Ec,Ej,Ng(ii),0);
            tmp1=size(EigV,1);
            for kk=1:N
                EnergyLevel{kk}(ii)=EL(kk);
                AverCharge{kk}(ii)=0;
                for ll=1:tmp1
                      AverCharge{kk}(ii)=AverCharge{kk}(ii)+(abs(EigV(ll,kk)))^2*(ll-1-(tmp1(1)-1)/2);
                end
            end
        else                % split CPB
            for jj=1:nP
                [EL EigV]=CPBEL(Ec,Ej,Ng(ii),phi(jj),dEj);
                tmp1=size(EigV,1);
                for kk=1:N
                    EnergyLevel{kk}(jj,ii)=EL(kk);
                    AverCharge{kk}(jj,ii)=0;
                    for ll=1:tmp1
                        AverCharge{kk}(jj,ii)=AverCharge{kk}(jj,ii)+(abs(EigV(ll,kk)))^2*(ll-1-(tmp1(1)-1)/2);
                    end   
                end
            end
        end
    end
    save(OutputDataName,'EnergyLevel','AverCharge');
else
    load(OutputDataName);
end
fg=int32(1e5*rand());
figure(fg);
for ii=1:N
    if ischar(dEj)          % CPB
        plot(Ng,EnergyLevel{ii}/Ec);
    else                    % split CPB
        surf(Ng,phi/pi,EnergyLevel{ii}/Ec);
    end
    hold on;
end
xlim([Ng(1),Ng(nP)]);
if ~ischar(dEj)             % split CPB
    ylim([phi(1)/pi,phi(nP)/pi]);
end
xlabel('$N_g$','interpreter','latex','Fontsize',16);
if ischar(dEj)              % CPB             
    ylabel('$\frac{E}{E_c}$','interpreter','latex','Fontsize',16);
    title(['$E_c: ' num2str(Ec) '\quad E_{J}: ' num2str(Ej) '$'],'interpreter','latex','Fontsize',16);
else                        % split CPB
    ylabel('$\delta  (\pi)$','interpreter','latex','Fontsize',16);
    zlabel('$\frac{E}{E_c}$','interpreter','latex','Fontsize',16);
    title(['$E_c: ' num2str(Ec) '\quad E_{J1}+E_{J2}: ' num2str(Ej) '\quad E_{J1}-E_{J2}: ' num2str(dEj) '$'],'interpreter','latex','Fontsize',16);
    box on;
end
figure(fg+1);
for ii=1:N
    if ischar(dEj)          % CPB
        plot(Ng,AverCharge{ii});
    else                    % split CPB
        surf(Ng,phi/pi,AverCharge{ii});
    end
    hold on;
end
xlim([Ng(1),Ng(nP)]);
if ~ischar(dEj)             % split CPB
    ylim([phi(1)/pi,phi(nP)/pi]);
end
xlabel('$N_g$','interpreter','latex','Fontsize',16);
if ischar(dEj)              % CPB             
    ylabel('$<N>$','interpreter','latex','Fontsize',16);
    title(['$E_c: ' num2str(Ec) '\quad E_{J}: ' num2str(Ej) '$'],'interpreter','latex','Fontsize',16);
else                        % split CPB
    ylabel('$\delta  (\pi)$','interpreter','latex','Fontsize',16);
    zlabel('$<N>$','interpreter','latex','Fontsize',16);
    title(['$E_c: ' num2str(Ec) '\quad E_{J1}+E_{J2}: ' num2str(Ej) '\quad E_{J1}-E_{J2}: ' num2str(dEj) '$'],'interpreter','latex','Fontsize',16);
    box on;
end