function Plot3JJQbtELNP(varargin)
% Plot3JJQbtELNP is the non parallel computing version of function Plot3JJQbtEL,
% it plots the energy diagram of a three-junction flux qubit.
% Based on the papar: Robertson et al.,
% Phys. Rev. Letts. B 73, 174526 (2006). Example:
% Plot3JJQbtELNP(Ej,Ec,alpha,beta,kappa,sigma,StartPoint,dFluxBias,nlevels,nk,nl,nm)
% Plot3JJQbtELNP(Ej,Ec,alpha,beta,kappa,sigma,StartPoint)
% Plot3JJQbtELNP(Ej,Ec,alpha,beta,kappa,sigma)
% Plot3JJQbtELNP()
% Flux Bias range:[0.5-StartPoint,0.5+StartPoint]*FluxQuantum.
% dFluxBias: dFluxBias*FluxQuantum is the Flux Bias Step.
% Energy unit: Plank's Constant*GHz.
% This function has a subfunction: 'TriJFlxQbtEL.m'.
% Author: Yulin Wu <mail2ywu@gmail.com>
% Date: 2009/5/6
% Revision:
% 2011/4/30

clc;
% Set default values for input arguments:
Ec=1;        % Unit:Plank's Constant*GHz
Ej=50;       % Unit:Plank's Constant*GHz
alpha=0.63;  % Plot3JJQbtEL(50,1,0.63,0.15,0,0,0.3,0.04)                   
beta=0.15;
kappa=0;
sigma=0;
StartPoint=0.38;
dFluxBias=0.005;
nk=5;       % n_k
nl=10;      % n_l
nm=2;       % n_m
nlevels=20;
%Input arguments handling:
if nargin>0 && nargin<6
    error('Not enough input arguments!');
elseif nargin>12
    error('Too many input arguments !');
elseif nargin>=6
    Ej=varargin{1};
    Ec=varargin{2};
    alpha=varargin{3};
    beta=varargin{4};
    kappa=varargin{5};
    sigma=varargin{6};
    if nargin>=7
        StartPoint=varargin{7};
        if StartPoint>=0.5
            error('The Value of input argument StartPoint should be less than 0.5!');
        end
        dFluxBias=(0.5-varargin{7})/25;
    end
	if nargin>=8
        dFluxBias=varargin{8};
        if dFluxBias> (0.5-StartPoint)
            error('Improper dFluxBias value: dFluxBias > StartPoint !');
        end
    end
    if nargin > 8
        nlevels=varargin{9};
    end
    if nargin>9
        if nargin<12
            error('Not enough input arguments!');
        else
           nk=varargin{10}; 
           nl=varargin{11};
           nm=varargin{12};
        end
    end
    if nk<5 && nl<10 && nm<2
        disp('Warning: Matrix dimension too small !')
    end
end
clc;
% Calculates the energy levels of the following Flux Bias conditions :
% (Startpoint : dFluxBias :1-Startpoint)*FluxQuantum
FluxBias=StartPoint:dFluxBias:0.5;	
if FluxBias(end)~=0.5
    FluxBias = [FluxBias, 0.5];   % Add the symmetrical flux bias point if it's not there.
end
Npoints=length(FluxBias);
NPperSection = 20;
ContinuePoint = 1;
OutputDataName=['Data\3JJQbtEL-Ej' num2str(Ej) 'Ec' num2str(Ec) 'alpha' num2str(alpha) 'beta' num2str(beta) 'kappa' num2str(kappa) 'sigma' num2str(sigma)];
OutputDataName=[OutputDataName 'S' num2str(StartPoint) 's' num2str(dFluxBias) 'D[' num2str(nk), ',', num2str(nl), ',', num2str(nm), ']', '.mat'];

if isempty(dir('Data'))
    mkdir('Data');
elseif ~isempty(dir(OutputDataName))
    load(OutputDataName);
end
if ischar(ContinuePoint)
	disp('Calculation for the present set of paramenters has been done before.');
	disp('Energy level diagram will be ploted directly by loading the saved data file.')
	disp('If you want to do a fresh calculation, delete the following file(or move it to another location):');
	disp(OutputDataName);
else
    if ContinuePoint >1
        disp('A previous calculation for the present set of paramenters has been carried out but not finished.');
        disp('This calculation will continue the unfinished caculationn job.');
        disp('If you want to do a fresh calculation, delete the following file(or move it to another location):');
        disp(OutputDataName);
    end
	Nsections = floor(Npoints/NPperSection);
	NPFinal = NPperSection;
	tmp = mod(Npoints,NPperSection);
	if tmp > 0
        Nsections = Nsections +1;
        NPFinal = tmp;
    end
    tic;
    LastFinished = (ContinuePoint-1)*NPperSection;
    disp('Calculation start ... ...');
    for dd = ContinuePoint:Nsections
        if dd == Nsections
             NPSection = NPFinal;
        else
             NPSection = NPperSection;
        end
        SliceH = (dd-1)*NPperSection+1;
        SliceE = (dd-1)*NPperSection+NPSection;
        BiasSlice = FluxBias(SliceH:SliceE);
        for ee=1:NPSection
             EL = TriJFlxQbtEL(Ej,Ec,alpha,beta,kappa,sigma,BiasSlice(ee),nk,nl,nm,nk*nl*nm);
             if ischar(EL)
                 error(EL);
             end
             el(ee,:) = EL;
        end
        if ContinuePoint == 1
            EnergyLevel = el;
        else
            EnergyLevel = [EnergyLevel; el];
        end
        ContinuePoint = dd + 1;
        save(OutputDataName,'FluxBias','EnergyLevel','ContinuePoint','NPperSection');
        time = toc/60;
        timeremaining = time*(Npoints-SliceE)/(SliceE-LastFinished);
        clc;
        disp(['Time elapsed: ',num2str(time)]);
        disp(['Estimated time remaining: ', num2str(timeremaining)]);
    end
    EnergyLevel=EnergyLevel-EnergyLevel(Npoints,1);    % set the ground level of 0.5*FluxQuantum Flux Bias as the zero energy point.
    for kk=Npoints+1:2*Npoints-1
        EnergyLevel(kk,:)=EnergyLevel(2*Npoints-kk,:);
        if kk == Npoints+1
            FluxBias(kk)=2*FluxBias(kk-1)-FluxBias(kk-2);
        else
            FluxBias(kk)=FluxBias(kk-1)+dFluxBias;
        end
    end
    ContinuePoint = 'END';
    save(OutputDataName,'FluxBias','EnergyLevel','ContinuePoint','NPperSection');
         % EnergyLevel(jj,kk) is the kkth energy level value of the fluxbias
         % condition Fluxbias = FluxBias(jj)*Flux quantum.
end
figure(int32(1e5*rand()));
for kk=1:nlevels
    plot(FluxBias,EnergyLevel(:,kk));
    hold on;
end
xlabel('$\Phi_Q/\Phi_0$','interpreter','latex','fontsize',14);
ylabel('$E (GHz)$','interpreter','latex','fontsize',14);
xlim([FluxBias(1),FluxBias(2*Npoints-1)]);
title('3JJ Flux Qubit Energy Diagram','fontsize',14);
Parameters = ['E_J:' num2str(Ej) 'GHz;  E_C:' num2str(Ec)  'GHz;  \alpha:' num2str(alpha) ';  \beta:' num2str(beta) ';  \sigma:' num2str(sigma) ';  \kappa:' num2str(kappa)];
text((0.5+StartPoint)/2, 0.85*EnergyLevel(1),Parameters,'fontsize',12);

