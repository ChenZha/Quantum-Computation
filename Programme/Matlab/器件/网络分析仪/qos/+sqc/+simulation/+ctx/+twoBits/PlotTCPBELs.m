% PlotTCPBELs is a slice-plot version of PlotTCPBEL.
% Author: Yulin Wu
% Date: 2009/8/13
% Email: mail4ywu@gmail.com
function PlotTCPBELs(Ec1,Ec2,Em,Ej1,Ej2,varargin)
NgLim=[0.25 0.8];           % Default ploting range: Ng, [-0.25 0.8],
nP=400;                     % 400 points for each energy level and
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
Ng=linspace(NgLim(1),NgLim(2),nP);
if size(dir('Output'),1)==0 || ~isdir('Output')    % If folder Output do not exit, make one.
    mkdir('Output');
end
OutputDataName=['Output/TCPBELs-Ec' num2str(Ec1) '_' num2str(Ec2) 'Em' num2str(Em) 'Ej' num2str(Ej1) '_' num2str(Ej2) 'NgLim' num2str(NgLim(1)) '-' num2str(NgLim(2)) 'nP' num2str(nP) '.mat'];
tmp=size(dir(OutputDataName));
Flag=true;
if tmp(1)~=0                % Check if the data already exits.
    for ii=1:1000
        clc;
        disp('Data for the current parameters have already been calculated previously. ');
        disp('If this is not the case, Enter N or n to ignore the exist data.');
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
    EnergyLevel1=zeros(N,nP);
    for jj=1:nP
        EL=TCPBEL(Ec1,Ec2,Em,Ej1,Ej2,Ng(1),Ng(jj));
        EL(N+1:end)=[];
        EnergyLevel1(:,jj)=EL;
        Time1=toc/60;
        Time2=Time1*3*(nP)/jj - Time1;
        clc;
        disp(['Time elapsed: ' num2str(Time1) ' min.']);
        disp(['Estimated time remaining: ' num2str(Time2) ' min.']);
    end
    EnergyLevel2=zeros(N,nP);
    for jj=1:nP
        EL=TCPBEL(Ec1,Ec2,Em,Ej1,Ej2,Ng(jj),Ng(1));
        EL(N+1:end)=[];
        EnergyLevel2(:,jj)=EL;
        Time1=toc/60;
        Time2=Time1*3*(nP)/(jj+nP) - Time1;
        clc;
        disp(['Time elapsed: ' num2str(Time1) ' min.']);
        disp(['Estimated time remaining: ' num2str(Time2) ' min.']);
    end
    EnergyLevel3=zeros(N,nP);
    for jj=1:nP
        EL=TCPBEL(Ec1,Ec2,Em,Ej1,Ej2,Ng(jj),Ng(jj));
        EL(N+1:end)=[];
        EnergyLevel3(:,jj)=EL;
        Time1=toc/60;
        Time2=Time1*3*nP/(jj+2*nP) - Time1;
        clc;
        disp(['Time elapsed: ' num2str(Time1) ' min.']);
        disp(['Estimated time remaining: ' num2str(Time2) ' min.']);
    end
    save(OutputDataName,'EnergyLevel1','EnergyLevel2','EnergyLevel3');
end
figure(int32(1e5*rand()));
for ii=1:N
    plot3(Ng(1)*ones(1,nP),Ng,EnergyLevel1(ii,:)/((Ec1+Ec2)/2));
    hold on;
    plot3(Ng,Ng(1)*ones(1,nP),EnergyLevel2(ii,:)/((Ec1+Ec2)/2));
    hold on;
%   plot3(Ng,Ng,EnergyLevel3(ii,:)/((Ec1+Ec2)/2));
%   hold on;
end
grid on;
xlim([Ng(1),Ng(nP)]);
ylim([Ng(1),Ng(nP)]);
xlabel('$N_{g1}$','interpreter','latex','Fontsize',16);
ylabel('$$N_{g2}$','interpreter','latex','Fontsize',16);
zlabel('$\frac{E}{(E_{c1}+E_{c2})/2}$','interpreter','latex','Fontsize',16);
title(['$E_{c1}: ' num2str(Ec1) '\quad E_{c2}: ' num2str(Ec2) '\quad E_{m}: ' num2str(Em)  '\quad E_{J1}: ' num2str(Ej1) '\quad  E_{J2}: ' num2str(Ej2) '$'],'interpreter','latex','Fontsize',16);
view(120,17);
figure(int32(1e5*rand()));
for ii=1:N
    plot(Ng,EnergyLevel3(ii,:)/((Ec1+Ec2)/2));
    hold on;
end
grid on;
xlim([Ng(1),Ng(nP)]);
xlabel('$N_{g1}=N_{g2}$','interpreter','latex','Fontsize',16);
ylabel('$\frac{E}{(E_{c1}+E_{c2})/2}$','interpreter','latex','Fontsize',16);
title(['$E_{c1}: ' num2str(Ec1) '\quad E_{c2}: ' num2str(Ec2) '\quad E_{m}: ' num2str(Em)  '\quad E_{J1}: ' num2str(Ej1) '\quad  E_{J2}: ' num2str(Ej2) '$'],'interpreter','latex','Fontsize',16);