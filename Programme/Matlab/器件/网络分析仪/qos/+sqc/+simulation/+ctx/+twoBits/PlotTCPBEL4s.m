% PlotTCPBEL4s is a slice-plot version of PlotTCPBEL expand
% to the basis { |00> |10> |01> |11> }.
% Author: Yulin Wu
% Date: 2009/8/14
% Email: mail4ywu@gmail.com

function PlotTCPBEL4s(Ec1,Ec2,Em,Ej1,Ej2,varargin)
NgLim=[0.25 0.8];           % Default ploting range: Ng, [-0.25 0.8],
nP=400;                     % 400 points for each energy level
if nargin<5
    error('Not enough input arguments !');
elseif nargin>6
    error('Too many input arguments !');
elseif nargin>5
    NgLim=varargin{1};
end
Ng=linspace(NgLim(1),NgLim(2),nP);
EnergyLevel1=zeros(4,nP);
for jj=1:nP
    EL=TCPBEL4(Ec1,Ec2,Em,Ej1,Ej2,Ng(1),Ng(jj));
    EnergyLevel1(:,jj)=EL;
end
EnergyLevel2=zeros(4,nP);
for jj=1:nP
    EL=TCPBEL4(Ec1,Ec2,Em,Ej1,Ej2,Ng(jj),Ng(1));
    EnergyLevel2(:,jj)=EL;
end
EnergyLevel3=zeros(4,nP);
for jj=1:nP
    EL=TCPBEL4(Ec1,Ec2,Em,Ej1,Ej2,Ng(jj),Ng(jj));
    EnergyLevel3(:,jj)=EL;
end
figure(int32(1e5*rand()));
for ii=1:4
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
for ii=1:4
    plot(Ng,EnergyLevel3(ii,:)/((Ec1+Ec2)/2));
    hold on;
end
grid on;
xlim([Ng(1),Ng(nP)]);
xlabel('$N_{g1}=N_{g2}$','interpreter','latex','Fontsize',16);
ylabel('$\frac{E}{(E_{c1}+E_{c2})/2}$','interpreter','latex','Fontsize',16);
title(['$E_{c1}: ' num2str(Ec1) '\quad E_{c2}: ' num2str(Ec2) '\quad E_{m}: ' num2str(Em)  '\quad E_{J1}: ' num2str(Ej1) '\quad  E_{J2}: ' num2str(Ej2) '$'],'interpreter','latex','Fontsize',16);
