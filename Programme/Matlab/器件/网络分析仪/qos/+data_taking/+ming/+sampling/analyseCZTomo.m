function [Phase,Fcz,Fpp]=analyseCZTomo(path)
% [Phase,Fcz,Fpp]=data_taking.ming.sampling.analyseCZTomo(path)

if nargin<1
    path='E:\data\20180622_12bit\sampling\180809\Tomo\CZTomo_Q1_Q12_180809T031141.mat';
end

load(path);

if isempty(strfind(path,'_analyseResult'))
    [PhaseA(1),PhaseB(1),Fcz(1),Fpp(1),chi{1}] = toolbox.data_tool.fitting.fitCZQPhase(Ptomo12);
    [PhaseA(2),PhaseB(2),Fcz(2),Fpp(2),chi{2}] = toolbox.data_tool.fitting.fitCZQPhase(Ptomo23);
    [PhaseA(3),PhaseB(3),Fcz(3),Fpp(3),chi{3}] = toolbox.data_tool.fitting.fitCZQPhase(Ptomo34);
    [PhaseA(4),PhaseB(4),Fcz(4),Fpp(4),chi{4}] = toolbox.data_tool.fitting.fitCZQPhase(Ptomo45);
    [PhaseA(5),PhaseB(5),Fcz(5),Fpp(5),chi{5}] = toolbox.data_tool.fitting.fitCZQPhase(Ptomo56);
    [PhaseA(6),PhaseB(6),Fcz(6),Fpp(6),chi{6}] = toolbox.data_tool.fitting.fitCZQPhase(Ptomo67);
    [PhaseA(7),PhaseB(7),Fcz(7),Fpp(7),chi{7}] = toolbox.data_tool.fitting.fitCZQPhase(Ptomo78);
    [PhaseA(8),PhaseB(8),Fcz(8),Fpp(8),chi{8}] = toolbox.data_tool.fitting.fitCZQPhase(Ptomo89);
    [PhaseA(9),PhaseB(9),Fcz(9),Fpp(9),chi{9}] = toolbox.data_tool.fitting.fitCZQPhase(Ptomo910);
    [PhaseA(10),PhaseB(10),Fcz(10),Fpp(10),chi{10}] = toolbox.data_tool.fitting.fitCZQPhase(Ptomo1011);
    [PhaseA(11),PhaseB(11),Fcz(11),Fpp(11),chi{11}] = toolbox.data_tool.fitting.fitCZQPhase(Ptomo1112);
    PhaseA=[PhaseA,PhaseB(end)];
    PhaseB=[PhaseA(1),PhaseB];
    Phase=(PhaseA+PhaseB)/2+pi*(abs(PhaseB-PhaseA)>pi);
    
    Fczerr=[];
    Fpperr=[];
    
    % for ii=1:11
    %     [Fczerr(ii),Fpperr(ii)]=resamplechi(chi{ii},5000);
    % end
    
    save(replace(path,'.mat','_analyseResult.mat'),'Fcz','Fpp','PhaseA','PhaseB','Phase','chi','Fczerr','Fpperr')
end





%% for fidelity prod
% tt=split(path,'\');
% tt=tt(end);
% h=figure;subplot(2,1,1);plot(1:11,Fcz,'ob',1:11,Fpp,'or');legend('CZ Fidelity','|++> Fidelity','location','best');xlabel('CZ sets');ylabel('Fidelity');title(tt)
% subplot(2,1,2);plot(1:12,Phase,'*',1:12,PhaseA,'^',1:12,PhaseB,'v');legend('Phase average','Phase from CZ1', 'Phase from CZ2','location','best');xlabel('qubits #');ylabel('Phase');axis tight
% saveas(h,replace(path,'.mat','.fig'))
% h2=figure;
% ax = axes('parent',h2);
% for ii=1:11
% fczall(ii)=prod(Fcz(12-ii:11));
% fppall(ii)=prod(Fpp(12-ii:11));
% end
% plot(ax,2:12,fczall,'-.',2:12,fppall,'--')
% saveas(h2,replace(path,'.mat','2.fig'))

%% for figures in manuscript only
% h3=figure;
% axes1=subplot(2,1,1);
% xvector1=1:12;
% yvector1=[99.97	99.81	99.75	99.66	99.84	99.81	99.95	99.8	99.83	99.85	99.9	99.85];
% D1=[0.11 	0.06 	0.22 	0.11 	0.06 	0.08 	0.07 	0.06 	0.07 	0.22 	0.09 	0.12];
% toolbox.data_tool.barcolormap(xvector1,yvector1,D1,axes1);
% ylabel('Y/2 Fidelity');
% xlim(axes1,[0.2 12.8]);
% ylim(axes1,[99.4 100.12]);
% box(axes1,'on');
% set(axes1,'XTick',[1 2 3 4 5 6 7 8 9 10 11 12],'XTickLabel',...
%     {'Q_1','Q_2','Q_3','Q_4','Q_5','Q_6','Q_7','Q_8','Q_9','Q_1_0','Q_1_1','Q_1_2'},...
%     'YTick',[99.5 100]);
% colorbar off
% set(axes1,'FontSize',14)
% 

%% for fidelity
h2=figure;
ax1=subplot(2,1,2);
toolbox.data_tool.barcolormap(1:numel(Fcz),Fcz,Fczerr,ax1);
ylim([0.85,1])
yticks([0.9,1])
xlim([0.2,11.8])
xticklabels('')
ylabel('CZ fidelity')
xticklabels({'Q_1Q_2','Q_2Q_3','Q_3Q_4','Q_4Q_5','Q_5Q_6','Q_6Q_7','Q_7Q_8','Q_8Q_9','Q_9Q_1_0','Q_1_0Q_1_1','Q_1_1Q_1_2'})
set(ax1,'XTickLabelRotation',60)
colorbar off
set(ax1,'FontSize',14)

%% for pp state fidelity
ax2=subplot(2,1,1);
toolbox.data_tool.barcolormap(1:numel(Fpp),Fpp,Fpperr,ax2);
ylim([0,1])
xlim([0.2,11.8])
xticklabels({'Q1Q2','Q2Q3','Q3Q4','Q4Q5','Q5Q6','Q6Q7','Q7Q8','Q8Q9','Q9Q10','Q10Q11','Q11Q12'})
ylabel('Initial state |++> fidelity')
set(ax2,'XTickLabelRotation',60)
colorbar off
set(ax1,'FontSize',14)
saveas(h2,replace(path,'.mat','_analyseResult.fig'))
end

function [Fczerr,Fpperr]=resamplechi(chi,ntrails)
[Measure_matrix_new,eigenval] = toolbox.data_tool.analyse_chi_data(chi);

nreps=1000;
Fcz=NaN(1,nreps);
Fpp=NaN(1,nreps);
parpool(4);
parfor ii=1:nreps
    P=singlePexp(Measure_matrix_new,eigenval,ntrails);
    [~,~,Fcz(ii),Fpp(ii)]=toolbox.data_tool.fitting.fitCZQPhase(P);
end
Fczerr=1.96*std(Fcz);
Fpperr=1.96*std(Fpp);
end

function P=singlePexp(Measure_matrix_new,eigenval,ntrails)
numQ=2;
rho=zeros(2^numQ,2^numQ,4^numQ);
rho_single(:,:,1)=[1 0;0 0];
rho_single(:,:,2)=[0 0;0 1];
rho_single(:,:,3)=0.5*[1 1;1 1];
rho_single(:,:,4)=0.5*[1 -1i;1i 1];
for ii=1:4^numQ
    qubit_base_index_rho=transform_index_fun(numQ,ii,4);
    rho_temp=1;
    for  jj=1:numQ
        rho_temp=kron(rho_single(:,:,qubit_base_index_rho(jj)),rho_temp);
    end
    rho(:,:,ii)=rho_temp;
end

I = [1,0;0,1];
sigma(:,:,1) = [0,1;1,0];
sigma(:,:,2) = [0,-1i;1i,0];
sigma(:,:,3) = [1,0;0,-1];

single_mesure_matrix(:,:,1) = expm(-1j*(-pi/2)*sigma(:,:,2)/2);
single_mesure_matrix(:,:,2) = expm(-1j*(pi/2)*sigma(:,:,1)/2);
single_mesure_matrix(:,:,3) = I;

%single_trans_matrix(:,:,1)=expm(1j*(pi/4)*sigma(:,:,2));
%single_trans_matrix(:,:,2)=expm(-1j*(pi/4)*sigma(:,:,1));
%single_trans_matrix(:,:,3)=I;
%single_trans_matrix(:,:,4)=I;
%X2p = expm(-1j*(pi/2)*sigmax/2);
%X2m = expm(-1j*(-pi/2)*sigmax/2);
%Y2p = expm(-1j*(pi/2)*sigmay/2);
%Y2m = expm(-1j*(-pi/2)*sigmay/2);

%求拉直化的U矩阵
Measure_matrix_all=zeros(2^numQ,2^numQ,3^numQ);
for ii=1:3^numQ
    Measure_matrix=1;
    qubit_base_index_matrix=transform_index_fun(numQ,ii,3);
    for jj=1:numQ
        Measure_matrix=kron(single_mesure_matrix(:,:,qubit_base_index_matrix(jj)),Measure_matrix);
    end
    Measure_matrix_all(:,:,ii)=Measure_matrix;
end

P=NaN(4^numQ,3^numQ,2^numQ);
for ii=1:4^numQ
    for jj=1:3^numQ
        trails=rand(1,ntrails);
        prob=real(eigenval);
        prob(prob<0)=0;
        prob=prob/sum(prob);
        for kk=2:16
            prob(kk)=sum(prob(kk-1:kk));
        end
        for kk=1:ntrails
            trails2(kk)=find(trails(kk)< prob, 1, 'first');
            Ui=Measure_matrix_new(:,:,trails2(kk));
            orgP=(Measure_matrix_all(:,:,jj)*Ui*rho(:,:,ii)*Ui'*Measure_matrix_all(:,:,jj)')/trace(Ui*rho(:,:,ii)*Ui');
            probP=[];
            for ll=1:2^numQ
                probP(ll)=abs(orgP(ll,ll));
                if ll>1
                    probP(ll)=probP(ll)+probP(ll-1);
                end
            end
            cr=rand(1);
            Pnt(kk)=find(cr<probP,1,'first');
        end
        P(ii,jj,:)=[numel(find(Pnt==1))/ntrails,numel(find(Pnt==2))/ntrails,numel(find(Pnt==3))/ntrails,numel(find(Pnt==4))/ntrails];
    end
end



end
function qubit_base_index=transform_index_fun(numQ,order_index,count_unit)
%用于下表转化（算法实质类似进制转换）
%order_index：是拉直化坐标
%numQ：新下标个数
%count_unit：新下标进制
%qubit_base_index：新下标（基于比特）的坐标
   old_index=order_index-1;
   qubit_base_index=NaN(1,numQ);
   for ii=1:numQ
       qubit_base_index(ii)=mod(old_index,count_unit)+1;
       old_index=fix(old_index/count_unit);
   end
end