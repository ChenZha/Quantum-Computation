function [fidelity,fidelity2,err]=calClusterFidelity2(Pxz,Pzx,Pxzz,measureQs,N,pathxz,pathzx,pathxzz)
%fidelity=data_taking.ming.sampling.calClusterFidelity('','','','E:\data\20180216_12bit\sampling\20180505\Overall_8bit_clusterState_q5_q12_L2_180506T070456.mat','');
if nargin<5
    N=2500*10;
end
if nargin>=6
    load(pathxz);
    if exist('P')
        Pxz=P;
        zxdata=load(pathzx);
        Pzx=zxdata.P;
        xzzdata=load(pathxzz);
        Pxzz=xzzdata.P;
    else
        Pxz=Pxz;
        Pzx=Pzx;
        Pxzz=Pxzz;
    end
    measureQs=measureQs;
end
load('E:\data\20180622_12bit\sampling\toFidelity2.mat')
numQ=numel(measureQs);
Pxz=renormalize(mean(Pxz,1));
Pzx=renormalize(mean(Pzx,1));
Pxzz=renormalize(mean(Pxzz,1));
if ismember(measureQs{end},{'q2','q4','q6','q8','q10','q12'})
    XZ=toFidelity2{numQ-1}{2};
    ZX=toFidelity2{numQ-1}{3};
    XZZ=toFidelity2{numQ-1}{4};
else
    XZ=toFidelity2{numQ-1}{3};
    ZX=toFidelity2{numQ-1}{2};
    XZZ=toFidelity2{numQ-1}{4};
end
fidelity2=sum(Pxz.*XZ)+sum(Pzx.*ZX)-1;

if numQ==12
    pause(1)
end

% if ~isempty(XZZ)
%     fidelity=sum(Pxz.*XZ)+sum(Pzx.*ZX)+sum(Pxzz.*XZZ)-1;
%     err=1.96*sqrt(sum(abs(Pxz.*XZ))+sum(abs(Pzx.*ZX))+sum(abs(Pxzz.*XZZ)))/sqrt(N);
% else
    fidelity=fidelity2;
    err=1.96*sqrt(sum(abs(Pxz.*XZ))+sum(abs(Pzx.*ZX)))/sqrt(N);
% end


% figure;subplot(2,2,1);bar(XZ);xlabel('States');ylabel('\alpha_X_Z');axis tight;title([num2str(numQ) 'bit XZ']);subplot(2,2,3);bar(Pxz);axis tight;xlabel('States');ylabel('P_X_Z');
% subplot(2,2,2);bar(ZX);axis tight;xlabel('States');ylabel('\alpha_Z_X');title([num2str(numQ) 'bit ZX']);subplot(2,2,4);bar(Pzx);axis tight;xlabel('States');ylabel('P_Z_X');

% figure;subplot(2,2,1);bar(0:numel(XZ)-1,XZ/sum(XZ));ylabel('P_X_Z_, _T_h_e_o_r_e_t_i_c_a_l');axis tight;title([num2str(numQ) 'bit XZ']);
% % ticks=[0,ceil(numel(XZ)/3),ceil(numel(XZ)*2/3),numel(XZ)-1];
% ticks=[0,numel(XZ)-1];
% for ii=1:numel(ticks)
% ticklables(ii,:)=['|' dec2bin(ticks(ii),numQ) '\rangle'];
% end
% xticks([]);
% % xticklabels(ticklables)
% % xtickangle(45)
% % xlabel(['$' ticklables(1,:) ' \rightarrow ' ticklables(2,:) '$' ],'Interpreter','latex')
% subplot(2,2,3);bar(0:numel(XZ)-1,Pxz);axis tight;ylabel('P_X_Z_, _E_x_p_e_r_i_m_e_n_t_a_l');
% hold on;
% % errorbar(0:numel(XZ)-1,Pxz,sqrt(Pxz/N),'CapSize',1,'LineStyle','none');
% xticks([]);
% % xticklabels(ticklables)
% % xtickangle(45)
% xlabel(['$' ticklables(1,:) ' \rightarrow ' ticklables(2,:) '$' ],'Interpreter','latex')
% subplot(2,2,2);bar(0:numel(XZ)-1,ZX/sum(ZX));axis tight;ylabel('P_X_Z_, _T_h_e_o_r_e_t_i_c_a_l');title([num2str(numQ) 'bit ZX']);
% xticks([]);
% % xticklabels(ticklables)
% % xtickangle(45)
% % xlabel(['$' ticklables(1,:) ' \rightarrow ' ticklables(2,:) '$' ],'Interpreter','latex')
% subplot(2,2,4);bar(0:numel(XZ)-1,Pzx);axis tight;ylabel('P_Z_X_, _E_x_p_e_r_i_m_e_n_t_a_l');
% hold on;
% % errorbar(0:numel(XZ)-1,Pzx,sqrt(Pzx/N),'CapSize',1,'LineStyle','none');
% xticks([]);
% % xticklabels(ticklables)
% % xtickangle(45)
% xlabel(['$' ticklables(1,:) ' \rightarrow ' ticklables(2,:) '$' ],'Interpreter','latex')

% ticks=[0,numel(XZ)-1];
% for ii=1:numel(ticks)
% ticklables(ii,:)=['|' dec2bin(ticks(ii),numQ) '\rangle'];
% end
% h=figure;subplot(1,2,1);box on;set(h,'Position',[390 360 960 370]);
% hold on;bar(0:numel(XZ)-1,Pxz,'Edgecolor','none','Facecolor',[0.18 0.08 0.64])
% bar(0:numel(XZ)-1,-XZ/sum(XZ),'Edgecolor','none','Facecolor',[0.74 0.45 0.]);ylabel('Probability');axis tight;title([num2str(numQ) 'bit XZ']);%xlim(ticks);
% ylim(1.05*[-max(max(Pxz),max(XZ/sum(XZ))),max(max(Pxz),max(XZ/sum(XZ)))]);
% legend({'Experimental','Theoretical'},'location','best')
% xticks([]);
% xlabel(['$' ticklables(1,:) ' \rightarrow ' ticklables(2,:) '$' ],'Interpreter','latex')
% ytks=get(gca,'YTick');
% yticks([min(ytks),0,max(ytks)]);
% yticklabels([max(ytks),0,max(ytks)]);
% set(gca,'FontSize',14)
% subplot(1,2,2);box on;
% hold on;bar(0:numel(XZ)-1,Pzx,'Edgecolor','none','Facecolor',[0.18 0.08 0.64])
% bar(0:numel(XZ)-1,-ZX/sum(ZX),'Edgecolor','none','Facecolor',[0.74 0.45 0.]);axis tight;ylabel('Probability');title([num2str(numQ) 'bit ZX']);%xlim(ticks);
% ylim(1.05*[-max(max(Pzx),max(ZX/sum(ZX))),max(max(Pzx),max(ZX/sum(ZX)))]);
% legend({'Experimental','Theoretical'},'location','best')
% xticks([]);
% xlabel(['$' ticklables(1,:) ' \rightarrow ' ticklables(2,:) '$' ],'Interpreter','latex')
% ytks=get(gca,'YTick');
% yticks([min(ytks),0,max(ytks)]);
% yticklabels([max(ytks),0,max(ytks)]);
% set(gca,'FontSize',14)
end
function data=renormalize(data)
% data(find(data<0))=0;
% data=data/sum(data);
end