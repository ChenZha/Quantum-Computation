
% This MATLAB function plots the lowest energy levels of two
% capacitively coupled Cooper Pair Boxes (CPBs). A function call
% plots a figure of the energy levels. The calculated data is
% saved to the directory $/Output (a later function call with the
% same parameters can thus skip the calculation procedure).
% Function call and Meaning of arguments:
% Single Junction CPB:
% PlotTCPBEL(Ec1,Ec2,Em,Ej1,Ej2);
% PlotTCPBEL(Ec1,Ec2,Em,Ej1,Ej2,NgLim);
% PlotTCPBEL(Ec1,Ec2,Em,Ej1,Ej2,NgLim,N);
% PlotTCPBEL(Ec1,Ec2,Em,Ej1,Ej2,NgLim,N,nP);
% Ec1=(2e)^2/C_{1\sigma}, Ec1=(2e)^2/C_{2\sigma}, the Cooper Pair
% Coulomb energys of the two CPBs;
% Em=4e^{2}Cm/(C_{1\sigma}C_{2\sigma}-C_{M}^{2}), the coupling
% energy. Cm is the coupling capacitor;
% Ej1, Ej2, the Josephson Energys;
% NgLim defines plotting range for Ng1 and Ng2, Ng1=Cg1Vg1/2e,
% Ng2=Cg2Vg2/2e, are the Charge Biases;
% N, plot N energy level(s).
% nP calculate nP*nP points to plot the energy level surface(s);
% NgLim,N,nP are not neccesary in the function call, if
% not specified, their default values will be assigned to them.
% Example:
% PlotTCPBEL(1,1,0.2,0.15,0.15);
% PlotTCPBEL(1,1,0.2,0.15,0.15,[0 1]);
% PlotTCPBEL(1,1,0.2,0.15,0.15,[0 1],5);
% PlotTCPBEL(1,1,0.2,0.15,0.15,[0 1],5,30);
% Author: Yulin Wu
% Date: 2009/8/10
% Email: mail4ywu@gmail.com

function PlotTCPBEL(Ec1,Ec2,Em,Ej1,Ej2,varargin)
NgLim=[0.25 0.8];           % Default ploting range: Ng, [-0.25 0.8],
nP=50;                      % 50*50 points for each energy level surface and
N=4;                        % plot 4 energy levels.
if nargin<5
    error('Not enough input arguments !');
elseif nargin>8
    error('Too many input arguments !');
elseif nargin>5
    NgLim=varargin{1};
	if nargin>6
        N=varargin{2};
        if nargin>7
            nP=varargin{3};
        end
    end
end
if N>10
    N=10;
end
tmp=size(dir('Output'));
if tmp(1)==0 || ~isdir('Output')    % If folder Output do not exit, make one.
    mkdir('Output');
end
OutputDataName=['Output/TCPBEL-Ec' num2str(Ec1) '_' num2str(Ec2) 'Em' num2str(Em) 'Ej' num2str(Ej1) '_' num2str(Ej2) 'NgLim' num2str(NgLim(1)) '-' num2str(NgLim(2)) 'nP' num2str(nP) '.mat'];
Ng1=linspace(NgLim(1),NgLim(2),nP);
Ng2=Ng1;
Flag=true;
if size(dir(OutputDataName),1)~=0                % Check if the data already exits.
    for ii=1:1000
        clc;
        disp('Data for the current parameters have already been calculated previously. ');
        disp('If this is not the case, press N or n to ignore the exist data.');
        disp('======================================');
        user_entry=input('Accept the exist data?  Y/N [Y]    ','s');
        if isempty(user_entry) || user_entry=='Y' || user_entry=='y'
           load(OutputDataName); 
           Flag=false; break;
        elseif user_entry=='N' || user_entry=='n'
            delete(OutputDataName); break;
        end
    end
end
if Flag==true       % Flag==true : Previously caculated data for the current parameters do
    tic;            % no exist or being ignored.
    EnergyLevel=cell(1,N);
    for ii=1:nP
        for jj=1:nP
            EL=TCPBEL(Ec1,Ec2,Em,Ej1,Ej2,Ng1(ii),Ng2(jj));
            for kk=1:N
                 EnergyLevel{kk}(jj,ii)=EL(kk);
            end
        end
        Time1=toc/60;
        Time2=Time1*(nP)/ii - Time1;
        clc;
        disp(['Time elapsed: ' num2str(Time1) ' min.']);
        disp(['Estimated time remaining: ' num2str(Time2) ' min.']);
    end
    save(OutputDataName,'EnergyLevel');
end
figure(int32(1e5*rand()));
for ii=1:N
    surf(Ng1,Ng2,EnergyLevel{ii}/((Ec1+Ec2)/2));
    hold on;
end
xlim([Ng1(1),Ng1(nP)]);
ylim([Ng2(1),Ng2(nP)]);
xlabel('$N_{g1}$','interpreter','latex','Fontsize',16);
ylabel('$$N_{g2}$','interpreter','latex','Fontsize',16);
zlabel('$\frac{E}{(E_{c1}+E_{c2})/2}$','interpreter','latex','Fontsize',16);
title(['$E_{c1}: ' num2str(Ec1) '\quad E_{c2}: ' num2str(Ec2) '\quad E_{J1}: ' num2str(Ej1) '\quad  E_{J2}: ' num2str(Ej2) '$'],'interpreter','latex','Fontsize',16);
