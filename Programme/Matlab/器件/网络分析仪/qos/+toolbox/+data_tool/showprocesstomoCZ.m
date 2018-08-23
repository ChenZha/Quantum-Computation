% toolbox.data_tool.showprocesstomoCZ(pexp)

function [h,chi_prime] = showprocesstomoCZ(pexp)

   P= CZ(2);
   [chi_prime,h]=showprocesstomo1(pexp,P);
   
end



function [chi_prime,h] = showprocesstomo1(pexp,pideal,User_defined_gate)
% Tomo data check
% 数据： P
% 格式：
% 4^n x 3^n x 2^n
% P(n,:,:) 是第n个State tomo 数据
% 对两比特：
% P(1,:,:)： 初态是 |q2:0, q1:0>；
% P(2,:,:)： 初态是 |q2:0, q1:1>；
% P(3,:,:)： 初态是 |q2:0, q1:+>；
% P(4,:,:)： 初态是 |q2:0, q1:i>；
% P(5,:,:)： 初态是 |q2:1, q1:0>；
% P(6,:,:)： 初态是 |q2:1, q1:1>；
% 态： {0,1,+,i} => {|0>, |1>, |0>+|1>, |0>+i|1>} ;
% state tomo 数据格式：3^n by 2^n， n 是比特数
% 行排序： 
%       1Q: {X}, {Y} ,{Z}
%       2Q: {q2:X q1:X}, {q2:X q1:Y}, {q2:X q1:Z},... ,{q2:Z q1:Z}
% X: Y/2 门, 测量 X 分量
% Y：-X/2 门, 测量 Y 分量
% Z：I 门, 测量 Z 分量
% 列排序： 
%       1Q: P|0>, P|1> 
%       2Q: P|q2:0, q1:0>，P|q2:0, q1:1>， P|q2:1, q1:0>， P|q2:1, q1:1>

pexp = real(pexp);
pideal = real(pideal);
numQs = round(log(size(pexp,2))/log(3));

%add 2018.01.26 Liswer
set_fit=struct ();
set_fit.is_fit=1;
set_fit.tolX=0;
set_fit.tolY=1e-7;%P的标准差
set_fit.max_feval=1e5; 
statetomo_rho_prime=zeros(2^numQs,2^numQs,4^numQs);
for ii=1:4^numQs
    data=reshape(pexp(ii,:,:),3^numQs,2^numQs);
    statetomo_rho_prime(:,:,ii)=stateTomoData2Rho(data,set_fit);
%     set_fit.is_fit=0;   set_fit.is_fit=0;
%     rho_c_prime(:,:,ii)=stateTomoData2Rho(data,set_fit);
%     set_fit.is_fit=1;
end
rho_c_prime=statetomo_rho_prime;
set_fit.is_fit=0;
chi_prime=processTomoData2Rho(rho_c_prime,pexp,set_fit);
[bata_order_index,rho_order_index]=calculate_bata(numQs);
[~,rho_c] = chi2p(chi_prime,bata_order_index,rho_order_index);

if nargin < 3
    User_defined_gate=eye(2^numQs);
end
h = figure;
set(h,'defaultuicontrolunits','normalized');
hax1 = axes('position',[0.1,0.2,0.3,0.6],'linewidth',2.25,'fontsize',14);
hax2 = axes('position',[0.6,0.2,0.3,0.6],'linewidth',2.25,'fontsize',14);
state_string_basic='01+i';
popupshowstr=cell(1,4^numQs+1);
popupshowstr{1}='Process Tomo';
for ii=1:4^numQs
    qubit_base_index=transform_index_fun(numQs,ii,4);
    state_string='';
    qubit_index='';
    for kk=1:numQs
        state_string=strcat(state_string,state_string_basic(qubit_base_index(numQs-kk+1)));
        qubit_index=strcat(qubit_index,'q',num2str(numQs-kk+1));
    end
    popupshowstr{ii+1}=strcat('|',qubit_index,'> = |',state_string,'>');
end
htextfidelity = uicontrol(h,'Style','text',...
    'position',[0.35,0.05,0.3,0.1],...
    'string','',...
    'FontSize',16);
% htexttheta1 = uicontrol(h,'Style','text',...
%     'position',[0.65,0.075,0.08,0.03],...
%     'string','θ1: 0 °',...
%     'HorizontalAlign','right');
% htexttheta2 = uicontrol(h,'Style','text',...
%     'position',[0.65,0.025,0.08,0.03],...
%     'string','θ2: 0 °',...
%     'HorizontalAlign','right');
hsldtheta_Height=0.1/(3*numQs-1);
for ii=1:numQs
    htexttheta(ii) = uicontrol(h,'Style','text',...
    'position',[0.65,0.12-3*(ii-1)*hsldtheta_Height-2*hsldtheta_Height,0.08,2*hsldtheta_Height],...
    'string',strcat('θ',num2str(ii),': 0 °'),...
    'HorizontalAlign','right');
    hsldtheta(ii) = uicontrol('Style', 'slider',...
            'Min',-180,'Max',180,'Value',0,...
            'SliderStep',[1/360,1/36],...
            'Position', [0.75 0.12-3*(ii-1)*hsldtheta_Height-2*hsldtheta_Height 0.2 2*hsldtheta_Height],...
        'callback',@uicallback); 
end
hbuttonauto = uicontrol(h,'Style','pushbutton',...
    'position',[0.95,0.02,0.05,0.1],...
    'string','Auto',...
    'callback',@bttnautocallback);
hpopupshow = uicontrol(h,'Style','popup',...
    'position',[0.4,0.85,0.2,0.1],...
    'string',popupshowstr,...
    'callback',@uicallback);
htextidealdata = uicontrol(h,'Style','text',...
    'position',[0.7,0.86,0.08,0.08],...
    'string','Ideal Data',...
    'HorizontalAlign','right');
hpopupidealdata = uicontrol(h,'Style','popup',...
    'position',[0.8,0.85,0.15,0.1],...
    'string',{'PIdeal','CZ','CNOT','Idle','iSWAP','SWAP','User Defined'},...
    'callback',@uicallback);

uicallback(hpopupshow,0)



function uicallback(hObject,callbackdata)
    showdata(statetomo_rho_prime)
end

function showdata(statetomo_rho_prime)
    ishow = get(hpopupshow,'Value');
    iidealdata = get(hpopupidealdata,'Value');
    theta=zeros(1,numQs);
    for ii1=1:numQs
        theta(ii1) = get(hsldtheta(ii1),'Value')/180*pi;
        set(htexttheta(ii1),'string',['θ',num2str(ii1),': ' num2str(theta(ii1)/pi*180,4) '°']);
    end
    %pe = rotatep(pexp,theta);
    statetomo_rho_rotate=zeros(2^numQs,2^numQs,4^numQs);
    for ii1=1:4^numQs
        statetomo_rho_rotate(:,:,ii1) = rotaterho(statetomo_rho_prime(:,:,ii1),theta);
    end
    switch iidealdata
        case 1 % PIdeal
            pid = pideal;
        case 2 % CZ
            pid = CZ(numQs);
        case 3 % CNOT
            pid = CNOT(numQs);
        case 4 % IDLE
            pid = IDLE(numQs);
        case 5 % iSWAP
            pid = ISWAP(numQs);
        case 6 % SWAP
            pid = SWAP(numQs);
        case 7 % User difined
            pid = m2p(User_defined_gate);
    end
    
    statetomo_rho_id=zeros(2^numQs,2^numQs,4^numQs);
    for ii1=1:4^numQs
        data_id=reshape(pid(ii1,:,:),3^numQs,2^numQs);
        temp=struct();
        temp.is_fit=0;
        statetomo_rho_id(:,:,ii1)=stateTomoData2Rho(data_id,temp);
    end
    

    switch ishow
        case 1
            rho_c_rotate=zeros(2^numQs,2^numQs,4^numQs);
            for ii1=1:4^numQs
                rho_c_rotate(:,:,ii1) = rotaterho(rho_c(:,:,ii1),theta);
            end
            temp=struct();
            temp.is_fit=0;
            chiexp = processTomoData2Rho(rho_c_rotate,pexp,temp);
            chiid = processTomoData2Rho(statetomo_rho_id,pid,temp);
            showchi(hax1,hax2,chiexp,chiid);
            F = fidelity(chiexp,chiid);
            eigenvalue=real(eig(chiexp))';
            eigenvalue=round(eigenvalue*1e4)/1e4;%保留小数点后四位
            set(htextfidelity,'FontSize',10);
            set(htextfidelity,'string',['Fidelity = ' num2str(F*100,4) '%    eigenvalue=',num2str(eigenvalue,4)]);
        otherwise
            istate = ishow-1;
            rhoexp = statetomo_rho_rotate(:,:,istate);
            rhoid = statetomo_rho_id(:,:,istate);
            showrho(hax1,hax2,rhoexp,rhoid)
            F = fidelity(rhoexp,rhoid);
            eigenvalue=real(eig(rhoexp))';
            eigenvalue=round(eigenvalue*1e4)/1e4;%保留小数点后四位
            set(htextfidelity,'FontSize',16);
            set(htextfidelity,'string',['Fidelity = ' num2str(F*100,4) '%    eigenvalue=',num2str(eigenvalue,4)]);
    end    
end

function bttnautocallback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    iidealdata = get(hpopupidealdata,'Value');
    switch iidealdata
        case 1 % PIdeal
            pid = pideal;
        case 2 % CZ
            pid = CZ(numQs);
        case 3 % CNOT
            pid = CNOT(numQs);
        case 4 % IDLE
            pid = IDLE(numQs);
        case 5 % iSWAP
            pid = ISWAP(numQs);
        case 6 % SWAP
            pid = SWAP(numQs);
        case 7 % User difined
            pid = m2p(User_defined_gate);
    end
    ishow = get(hpopupshow,'Value');
    switch ishow
        case 1
            [theta] = thetafit(rho_c,pid);
        otherwise
            istate = ishow-1;
            [theta] = thetafit(statetomo_rho_prime(:,:,istate),pid(istate,:,:));
    end
    theta_ = theta; % Yulin Wu
    for ii2=1:numQs
        if theta_(ii2) <= -pi
            theta_(ii2) = theta(ii2) + 2*pi;
        elseif theta_(ii2) > pi
            theta_(ii2) = theta(ii2) - 2*pi;
        end
        set(hsldtheta(ii2),'Value',theta_(ii2)*180/pi);
        set(hsldtheta(ii2),'Value',theta_(ii2)*180/pi);
    end
    showdata(statetomo_rho_prime);
    disp(['[' num2str(-theta_)  ']'])
end
end

function showchi(haxreal,haximage,chiexp,chiid)
    numQs = round(log(size(chiexp,1))/log(4));
    axes(haxreal);
    hold off;
    brealexp = bar3(real(chiexp));
    for ibar = 1:length(brealexp)
        zdata = brealexp(ibar).ZData;
        brealexp(ibar).CData = zdata;
        brealexp(ibar).EdgeAlpha = 0;
        brealexp(ibar).FaceColor = 'interp';
    end
    hold on;
    brealideal = bar3(real(chiid));
    for ibar = 1:length(brealideal)
        zdata = brealideal(ibar).ZData;
        brealideal(ibar).CData = zdata;
        brealideal(ibar).FaceAlpha = 0;
        brealideal(ibar).FaceColor = 'interp';
    end
    chi_Label=cell(1,4^numQs);
    single_chi_string='IXYZ';
    for ii=1:4^numQs
        qubit_base_index=transform_index_fun(numQs,ii,4);
        string_temp='';
        for kk=1:numQs
            string_temp=strcat(single_chi_string(qubit_base_index(kk)),string_temp);
        end
        chi_Label{ii}=string_temp;
    end
    sigam_index_string='';
    for kk=1:numQs
        sigam_index_string=strcat('\sigma_',num2str(kk),sigam_index_string);
    end
    title('Real(\chi)');
    set(gca,'XTick',1:4^numQs);
    set(gca,'XTickLabel',chi_Label);
    set(gca,'YTick',1:4^numQs);
    set(gca,'YTickLabel',chi_Label);
    xlabel(sigam_index_string); ylabel(sigam_index_string);
    colorbar('position',[0.45 0.3 0.01 0.4]);
    colormap jet
    hold off;
    axes(haximage);
    hold off;
    brealexp = bar3(imag(chiexp));
    for ibar = 1:length(brealexp)
        zdata = brealexp(ibar).ZData;
        brealexp(ibar).CData = zdata;
        brealexp(ibar).EdgeAlpha = 0;
        brealexp(ibar).FaceColor = 'interp';
    end
    hold on;
    bimage = bar3(imag(chiid));
    for ibar = 1:length(bimage)
        zdata = bimage(ibar).ZData;
        bimage(ibar).CData = zdata;
        bimage(ibar).FaceAlpha = 0;
        bimage(ibar).FaceColor = 'interp';
    end
    title('Image(\chi)');
    set(gca,'XTick',1:4^numQs);
    set(gca,'XTickLabel',chi_Label);
    set(gca,'YTick',1:4^numQs);
    set(gca,'YTickLabel',chi_Label);
    xlabel(sigam_index_string); ylabel(sigam_index_string);
    colorbar('position',[0.95 0.3 0.01 0.4]);
    hold off;
end
function showrho(haxreal,haximage,rhoexp,rhoid)
    numQs = round(log(size(rhoexp,1))/log(2));
    axes(haxreal);
    hold off;
    brealexp = bar3(real(rhoexp));
    for ibar = 1:length(brealexp)
        zdata = brealexp(ibar).ZData;
        brealexp(ibar).CData = zdata;
        brealexp(ibar).EdgeAlpha = 0;
        brealexp(ibar).FaceColor = 'interp';
    end
    hold on;
    brealideal = bar3(real(rhoid));
    for ibar = 1:length(brealideal)
        zdata = brealideal(ibar).ZData;
        brealideal(ibar).CData = zdata;
        brealideal(ibar).FaceAlpha = 0;
        brealideal(ibar).FaceColor = 'interp';
    end
    qubit_state_Label=cell(1,2^numQs);
    qubit_index_string='';
    for ii=1:1:2^numQs
        qubit_state_Label{ii}=num2str(dec2bin(ii-1,numQs));
    end
    for kk=1:numQs
        qubit_index_string=strcat('q_',num2str(kk),qubit_index_string);
    end
    title('Real(\rho)');
    set(gca,'XTick',1:2^numQs);
    set(gca,'XTickLabel',qubit_state_Label);
    set(gca,'YTick',1:2^numQs);
    set(gca,'YTickLabel',qubit_state_Label);
    xlabel(qubit_index_string); ylabel(qubit_index_string);
    colorbar('position',[0.45 0.3 0.01 0.4]);
    colormap jet
    hold off;
    axes(haximage);
    hold off;
    brealexp = bar3(imag(rhoexp));
    for ibar = 1:length(brealexp)
        zdata = brealexp(ibar).ZData;
        brealexp(ibar).CData = zdata;
        brealexp(ibar).EdgeAlpha = 0;
        brealexp(ibar).FaceColor = 'interp';
    end
    hold on;
    bimage = bar3(imag(rhoid));
    for ibar = 1:length(bimage)
        zdata = bimage(ibar).ZData;
        bimage(ibar).CData = zdata;
        bimage(ibar).FaceAlpha = 0;
        bimage(ibar).FaceColor = 'interp';
    end
    title('Image(\rho)');
    set(gca,'XTick',1:2^numQs);
    set(gca,'XTickLabel',qubit_state_Label);
    set(gca,'YTick',1:2^numQs);
    set(gca,'YTickLabel',qubit_state_Label);
    xlabel(qubit_index_string); ylabel(qubit_index_string);
    colorbar('position',[0.95 0.3 0.01 0.4]);
    hold off;
end
function [rho_rotate] = rotaterho(rho_prime,theta)
    numQs = round(log(size(rho_prime,1))/log(2));
    Z = [1,0;0,-1];
    U=1;
    for ii=1:numQs
        U=kron(expm(-1i*theta(ii)*Z/2),U);
    end
    rho_rotate = U*rho_prime*U';
end
function [theta] = thetafit(statetomo_rho_prime,pid)
    function y = fitFunc(statetomo_rho_prime,pid,theta,sz)
        pe = rotatep(statetomo_rho_prime,theta,sz);
        D = (pe - pid).^2;
        y = sum(D(:));
    end
    numQs = round(log(size(statetomo_rho_prime,2))/log(2));
    sz=size(pid,1);
    %theta = qes.util.fminsearchbnd(@(theta)fitFunc(statetomo_rho_prime,pid,theta,sz),zeros(1,numQs),-ones(1,numQs)*2*pi,ones(1,numQs)*2*pi);
    theta = fminsearchbnd(@(theta)fitFunc(statetomo_rho_prime,pid,theta,sz),zeros(1,numQs),-ones(1,numQs)*2*pi,ones(1,numQs)*2*pi);
end
function [pr] = rotatep(statetomo_rho_prime,theta,sz)
    Z = [1,0;0,-1];
    numQs = round(log(size(statetomo_rho_prime,2))/log(2));
    pr = NaN(sz,3^numQs,2^numQs);
    U=1;
    for ii=1:numQs
        U=kron(expm(-1i*theta(ii)*Z/2),U);
    end
    %U = kron(expm(-1i*theta2*Z/2),expm(-1i*theta1*Z/2));
    for istate = 1:sz
        rho = statetomo_rho_prime(:,:,istate);
        rho = U*rho*U';
        pr(istate,:,:) = rho2p(rho);
    end
    pr = real(pr);
end
function [F] = fidelity(rho1,rho2)
m = rho1*rho2;
F = trace(m);
F = sqrt(real(F));
end
function [P] = CZ(numQs)
cz = [1,0,0,0;
     0,1,0,0;
     0,0,1,0;
     0,0,0,-1];
 cz = kron(eye(2^(numQs-2)),cz);
P = m2p(cz);
end
function [P] = CNOT(numQs)
cnot = [1,0,0,0;
     0,1,0,0;
     0,0,0,1;
     0,0,1,0];
 cnot = kron(eye(2^(numQs-2)),cnot);
P = m2p(cnot);
end
function [P] = IDLE(numQs)
P = m2p(eye(2^numQs));
end
function [P] = ISWAP(numQs)
iswap = [1,0,0,0;
     0,0,1i,0;
     0,1i,0,0;
     0,0,0,1];
 iswap = kron(eye(2^(numQs-2)),iswap);
P = m2p(iswap);
end
function [P] = SWAP(numQs)
swap = [1,0,0,0;
     0,0,1,0;
     0,1,0,0;
     0,0,0,1];
 swap = kron(eye(2^(numQs-2)),swap);
P = m2p(swap);
end
function [P] = m2p(m)
s = cell(1,4);
s{1} = [1;0];
s{2} = [0;1];
s{3} = [1;1]/sqrt(2);
s{4} = [1;1i]/sqrt(2);
numQs = round(log(size(m,1))/log(2));
P = zeros(4^numQs,3^numQs,2^numQs);
for ii=1:4^numQs
    qubit_base_index=transform_index_fun(numQs,ii,4);
    rho_ii=1;
    for kk=1:numQs
        rho_ii=kron(s{qubit_base_index(kk)}*s{qubit_base_index(kk)}',rho_ii);
    end
    rho_ii_final=m*rho_ii*m';
    P(ii,:,:) = rho2p(rho_ii_final);
end     
end
function [P] = rho2p(rho)
% single_mesure_matrix(:,:,1) = [0 1;1 0];
% single_mesure_matrix(:,:,2) = [0 -1i;1i 0];
% single_mesure_matrix(:,:,3) = [1 0;0 -1];
numQs = round(log(size(rho,2))/log(2));
X = [0,1;1,0];
Y = [0, -1i; 1i,0];
I = [1,0;0,1];
Y2m = expm(-1i*(-pi)*Y/4);
X2p = expm(-1i*pi*X/4);
TomoGateSet = {Y2m,X2p,I};
P=zeros(3^numQs,2^numQs);
for ii=1:3^numQs
    qubit_base_index=transform_index_fun(numQs,ii,3);
    u_ii=1;
    for kk=1:numQs
        u_ii=kron(TomoGateSet{qubit_base_index(kk)},u_ii);
    end
    rho_ii=u_ii*rho*u_ii';
    for jj=1:2^numQs
        P(ii,jj)=rho_ii(jj,jj);
    end
    P=abs(P);
end
end
function [P,rho] = chi2p(chi,bata_order_index,rho_order_index)
%statetomo_rho 是一个 (2^n,2^n,4^n)矩阵，
%第三个维度是态的编号，
% rho(:,:,1)： 初态是 |q2:0, q1:0>；
% rho(:,:,2)： 初态是 |q2:0, q1:1>；
% rho(:,:,3)： 初态是 |q2:0, q1:+>；
% rho(:,:,4)： 初态是 |q2:0, q1:i>；
% rho(:,:,5)： 初态是 |q2:1, q1:0>；
% rho(:,:,6)： 初态是 |q2:1, q1:1>；
    
    numQs = round(log(size(chi,2))/log(4));
    chi_order_index=reshape(chi.',1,16^numQs);
    langbuda_order_index=chi_order_index*bata_order_index;
    langbuda=reshape(langbuda_order_index,4^numQs,4^numQs).';
    e_rho_order_index=langbuda*rho_order_index;
    P=zeros(4^numQs,3^numQs,2^numQs);
    rho=zeros(2^numQs,2^numQs,4^numQs);
    for ii=1:4^numQs
        rho(:,:,ii)=reshape(e_rho_order_index(ii,:),2^numQs,2^numQs).';
        P_temp=rho2p(rho(:,:,ii));
        P(ii,:,:)=P_temp;
    end
end
function [bata_order_index,rho_order_index]=calculate_bata(numQs)
    %求4^n个不同初态的密度矩阵，并将所有密度矩阵拉直重组
    rho_order_index=zeros(4^numQs,4^numQs);
    rho=zeros(2^numQs,2^numQs,4^numQs);
    rho_single(:,:,1)=[1 0;0 0];
    rho_single(:,:,2)=[0 0;0 1];
    rho_single(:,:,3)=0.5*[1 1;1 1];
    rho_single(:,:,4)=0.5*[1 -1i;1i 1];
    for ii=1:4^numQs
        qubit_base_index_rho=transform_index_fun(numQs,ii,4);
        rho_temp=1;
        for  jj=1:numQs
            rho_temp=kron(rho_single(:,:,qubit_base_index_rho(jj)),rho_temp);
        end
        rho(:,:,ii)=rho_temp;
        rho_order_index(ii,:)=reshape(rho(:,:,ii).',1,4^numQs);
    end
    
    %求4^n*4^n*4^n个测量伴随密度矩阵并将相同m,n下标的密度矩阵类拉直重组成一个4^n*4^n矩阵
    %右除拉直化后的初态总密度矩阵，获得对应m,n下标的bata_m_n
    %求出所有的4^n*4^n个bata_m_n，将其拉直重组
    bata_order_index=zeros(16^numQs,16^numQs);
    rho_order_index_mm_nn=zeros(4^numQs,4^numQs);
    single_mesure_matrix(:,:,2) = [0 1;1 0];
    single_mesure_matrix(:,:,3) = [0 -1i;1i 0];
    single_mesure_matrix(:,:,4) = [1 0;0 -1];
    single_mesure_matrix(:,:,1) = [1 0;0 1];
    for mm=1:4^numQs
        Measure_m_matrix=1;
        qubit_base_index_m=transform_index_fun(numQs,mm,4);
        for mmii=1:numQs
            Measure_m_matrix=kron(single_mesure_matrix(:,:,qubit_base_index_m(mmii)),Measure_m_matrix);
        end          
        for nn=1:4^numQs
            Measure_n_matrix=1;
            qubit_base_index_n=transform_index_fun(numQs,nn,4);
            for nnii=1:numQs
                Measure_n_matrix=kron(single_mesure_matrix(:,:,qubit_base_index_n(nnii)),Measure_n_matrix);
            end            
            for jj=1:1:4^numQs
                rho_order_index_mm_nn(jj,:)=reshape((Measure_m_matrix*rho(:,:,jj)*Measure_n_matrix).',1,4^numQs);
            end
            bata_mm_nn=rho_order_index_mm_nn/rho_order_index;
            bata_order_index((mm-1)*4^numQs+nn,:)=reshape(bata_mm_nn.',1,16^numQs);
        end
    end
end
function chi=processTomoData2Rho(statetomo_rho,data,set_fit)

%statetomo_rho 是一个 (2^n,2^n,4^n)矩阵，
%第三个维度是态的编号，
% rho(:,:,1)： 初态是 |q2:0, q1:0>；
% rho(:,:,2)： 初态是 |q2:0, q1:1>；
% rho(:,:,3)： 初态是 |q2:0, q1:+>；
% rho(:,:,4)： 初态是 |q2:0, q1:i>；
% rho(:,:,5)： 初态是 |q2:1, q1:0>；
% rho(:,:,6)： 初态是 |q2:1, q1:1>；
    
    numQs = round(log(size(statetomo_rho,2))/log(2));

    %求4^n个不同初态的密度矩阵，并将所有密度矩阵拉直重组
    rho_order_index=zeros(4^numQs,4^numQs);
    rho=zeros(2^numQs,2^numQs,4^numQs);
    rho_single(:,:,1)=[1 0;0 0];
    rho_single(:,:,2)=[0 0;0 1];
    rho_single(:,:,3)=0.5*[1 1;1 1];
    rho_single(:,:,4)=0.5*[1 -1i;1i 1];
    for ii=1:4^numQs
        qubit_base_index_rho=transform_index_fun(numQs,ii,4);
        rho_temp=1;
        for  jj=1:numQs
            rho_temp=kron(rho_single(:,:,qubit_base_index_rho(jj)),rho_temp);
        end
        rho(:,:,ii)=rho_temp;
        rho_order_index(ii,:)=reshape(rho(:,:,ii).',1,4^numQs);
    end
    
    %将4^n个statetomo拉直重组
    e_rho_order_index=zeros(4^numQs,4^numQs);
    for ii=1:4^numQs
        for jj=1:2^numQs
            for kk=1:2^numQs
                e_rho_order_index(ii,(jj-1)*2^numQs+kk)=statetomo_rho(jj,kk,ii);
            end
        end
    end
    
    %求langbuda矩阵并拉直重组
    langbuda=e_rho_order_index/rho_order_index;
    langbuda_order_index=reshape(langbuda.',1,16^numQs);
    
    %求4^n*4^n*4^n个测量伴随密度矩阵并将相同m,n下标的密度矩阵类拉直重组成一个4^n*4^n矩阵
    %右除拉直化后的初态总密度矩阵，获得对应m,n下标的bata_m_n
    %求出所有的4^n*4^n个bata_m_n，将其拉直重组
    %由拉直重组后的bata矩阵和拉直重组后的langbuda求得拉直化的chi
    %将拉直化的chi逆拉直处理得到矩阵形式的chi
    bata_order_index=zeros(16^numQs,16^numQs);
    rho_order_index_mm_nn=zeros(4^numQs,4^numQs);
    single_mesure_matrix(:,:,2) = [0 1;1 0];
    single_mesure_matrix(:,:,3) = [0 -1i;1i 0];
    single_mesure_matrix(:,:,4) = [1 0;0 -1];
    single_mesure_matrix(:,:,1) = [1 0;0 1];
    for mm=1:4^numQs
        Measure_m_matrix=1;
        qubit_base_index_m=transform_index_fun(numQs,mm,4);
        for mmii=1:numQs
            Measure_m_matrix=kron(single_mesure_matrix(:,:,qubit_base_index_m(mmii)),Measure_m_matrix);
        end          
        for nn=1:4^numQs
            Measure_n_matrix=1;
            qubit_base_index_n=transform_index_fun(numQs,nn,4);
            for nnii=1:numQs
                Measure_n_matrix=kron(single_mesure_matrix(:,:,qubit_base_index_n(nnii)),Measure_n_matrix);
            end            
            for jj=1:1:4^numQs
                rho_order_index_mm_nn(jj,:)=reshape((Measure_m_matrix*rho(:,:,jj)*Measure_n_matrix).',1,4^numQs);
            end
            bata_mm_nn=rho_order_index_mm_nn/rho_order_index;
            bata_order_index((mm-1)*4^numQs+nn,:)=reshape(bata_mm_nn.',1,16^numQs);
        end
    end
    
    chi_order_index=langbuda_order_index/bata_order_index;
    chi=reshape(chi_order_index,4^numQs,4^numQs).';
    if(set_fit.is_fit)
        [chi_opt]=fit_rho(chi,data,set_fit) ;
        chi=chi_opt;
    end
end
function rho = stateTomoData2Rho(data,set_fit)
% data: 3^n by 2^n
% row: {'Y2p','X2m','I'} => {'sigma_x','sigma_y','sigma_z'}(abbr.: {X,Y,Z})
%       1Q: {X}, {Y} ,{Z}
%       2Q: {q2:X q1:X}, {q2:X q1:Y}, {q2:X q1:I},... ,{q2:Z q1:Z}
%       X（Y）指把X（Y）翻转到Z轴，实际操作的矩阵是Y（X）
% colomn: P|00>,|01>,|10>,|11>
% qubit labeled as: |qubits{2},qubits{1}>
% in case of 2Q data(3,2): {qubits{2}:X qubits{1}:I} P|01> (|qubits{2},qubits{1}>)

    I = [1,0;0,1];
    sigma(:,:,1) = [0,1;1,0];
    sigma(:,:,2) = [0,-1i;1i,0];
    sigma(:,:,3) = [1,0;0,-1];
    
    single_mesure_matrix(:,:,1) = sigma(:,:,1);
    single_mesure_matrix(:,:,2) = sigma(:,:,2);
    single_mesure_matrix(:,:,3) = sigma(:,:,3);
    single_mesure_matrix(:,:,4) = I;
    
%single_trans_matrix(:,:,1)=expm(1j*(pi/4)*sigma(:,:,2));
%single_trans_matrix(:,:,2)=expm(-1j*(pi/4)*sigma(:,:,1));
%single_trans_matrix(:,:,3)=I;
%single_trans_matrix(:,:,4)=I;
    %X2p = expm(-1j*(pi/2)*sigmax/2);
    %X2m = expm(-1j*(-pi/2)*sigmax/2);
    %Y2p = expm(-1j*(pi/2)*sigmay/2);
    %Y2m = expm(-1j*(-pi/2)*sigmay/2);
    
    %求拉直化的U矩阵
    numQs = round(log(size(data,1))/log(3));
    U=zeros(2^(2*numQs),4^numQs);
    for ii=1:4^numQs
        Measure_matrix=1;
        qubit_base_index_matrix=transform_index_fun(numQs,ii,4);
        for jj=1:numQs
            Measure_matrix=kron(single_mesure_matrix(:,:,qubit_base_index_matrix(jj)),Measure_matrix);
        end
        for jj=1:2^numQs
            U((jj-1)*2^numQs+1:(jj)*2^numQs,ii)=Measure_matrix(:,jj);
        end
    end
    
    %根据U矩阵中的测量基矢选择方式生成对应的期望（拉直化的P）
    p_order_index=zeros(1,4^numQs);
    for ii=1:4^numQs
        p_order_index(ii)=0;
        qubit_base_index_matrix=transform_index_fun(numQs,ii,4);
        for jj=1:2^numQs
            qubit_base_index_p=transform_index_fun(numQs,jj,2);
            factor=1;
            ii_trans=1;
            qubit_base_index_matrix_test=zeros(1,numQs);
            for kk=1:numQs
                if(qubit_base_index_matrix(kk)==4)
                    qubit_base_index_matrix_test(kk)=qubit_base_index_matrix(kk)-1;
                else
                    qubit_base_index_matrix_test(kk)=qubit_base_index_matrix(kk);
                    factor=factor*(-2*qubit_base_index_p(kk)+3);                    
                end
                ii_trans=ii_trans+3^(kk-1)*(qubit_base_index_matrix_test(kk)-1);
            end
            p_order_index(ii)=p_order_index(ii)+factor*data(ii_trans,jj);
        end 
    end
    
    %求拉直化的rho并将它矩阵化
    rho0=p_order_index/U;
    rho=zeros(2^numQs,2^numQs);
    for ii=1:2^numQs
        rho(ii,:)=rho0((ii-1)*2^numQs+1:ii*2^numQs);
    end
    if(set_fit.is_fit)
        [rho_opt]=fit_rho(rho,data,set_fit) ;
        rho=rho_opt;
    end
end
function qubit_base_index=transform_index_fun(numQs,order_index,count_unit)
%用于下表转化（算法实质类似进制转换）
%order_index：是拉直化坐标
%numQs：新下标个数
%count_unit：新下标进制
%qubit_base_index：新下标（基于比特）的坐标
   old_index=order_index-1;
   qubit_base_index=NaN(1,numQs);
   for ii=1:numQs
       qubit_base_index(ii)=mod(old_index,count_unit)+1;
       old_index=fix(old_index/count_unit);
   end
end
function [rho_opt]=fit_rho(rho,data,set_fit)

numQs = round(log(size(rho,2))/log(2));
[eigenstate,eigenvalue]=eig(rho);

%边界与归一处理

%%%%%%%%%%%%%%%%%%%%%%%%%%保留主要项方式选初始点
P_pure_state=zeros(1,2^numQs);
%主要项
P_pure_state(1)=min(real(eigenvalue(1,1)),1); 
%误差项
for ii=2:2^numQs
    P_pure_state(ii)=max(0,real(eigenvalue(ii,ii)));    
end
P_pure_state(2:2^numQs)=(1-P_pure_state(1))*P_pure_state(2:2^numQs)/sum(P_pure_state(2:2^numQs));

% %%%%%%%%%%%%%%%%%%%%%%%%%%非保留主要项方式选初始点
% P_pure_state=zeros(1,2^numQs);
% for ii=1:2^numQs
%     P_pure_state(ii)=max(0,real(eigenvalue(ii,ii)));    
% end
% P_pure_state=P_pure_state/sum(P_pure_state);


V_pure_state=eigenstate;

if (length(size(data))==2)
    fprintf('正在优化 statetomo\n')
    function_handle=@(x)x2distance(x,numQs,V_pure_state,data);
    x_center=[P_pure_state(1:2^numQs-1),zeros(1,round((2^numQs-1)*(2^numQs)))];
    x0=[x_center;x_center+0.01*eye(length(x_center))];
%     options = optimset('TolFun',1e-5,'TolX',1e-5,'MaxIter',100,'MaxFunEvals',200);
%     [X,FVAL,EXITFLAG,OUTPUT] = fminsearch
    [ x_opt, x_trace, y_trace, n_feval] = NelderMead (function_handle, x0, set_fit.tolX, set_fit.tolY, set_fit.max_feval);
else
    fprintf('正在优化 processtomo\n')
    [bata_order_index,rho_order_index]=calculate_bata(round(numQs/2));
    function_handle=@(x)x2distance_chi(x,numQs,V_pure_state,data,bata_order_index,rho_order_index);
    x_center=[P_pure_state(1:2^numQs-1),zeros(1,round((2^numQs-1)*(2^numQs)))];
    x0=[x_center;x_center+0.01*eye(length(x_center))];
    [ x_opt, x_trace, y_trace, n_feval] = NelderMead (function_handle, x0, set_fit.tolX, set_fit.tolY, set_fit.max_feval);
    
    %%for test
    figure(200);
    clf;
    plot(1:length(y_trace),y_trace);
    xlabel('n feval')
    ylabel('delta(P_s_i_m-data)')
    title('y trace')

    [m,n]=size(x_trace);
    figure(201);
    clf;
    hold on;
    for ii=1:2^numQs-1
        plot(1:m,x_trace(:,ii))
    end
    plot(1:m,1-x_trace(:,1)-x_trace(:,2)-x_trace(:,3))
    xlabel('n feval')
    ylabel('eigen value')
    title('x trace1')
    figure(202);
    clf;
    hold on;
    for ii=2^numQs:n
        plot(1:m,x_trace(:,ii))
    end
    xlabel('n feval')
    ylabel('rotate angle')
    title('x trace2')
    figure(200)
    %%for test
end

[rho_opt]=x2rho(x_opt,numQs,V_pure_state);



end
function [rho]=x2rho(x,numQs,V_pure_state)

P_pure_state=zeros(0,2^numQs);
%边界与归一处理
for ii=1:2^numQs-1
    P_pure_state(ii)=max(0,x(ii));    
end
P_pure_state(2^numQs)=max(1-sum(P_pure_state),0);
P_pure_state=P_pure_state/sum(P_pure_state);

rotate_value=zeros(1,length(x)-2^numQs+1);
for nn=1:length(rotate_value)
    rotate_value(nn)=x(2^numQs-1+ii);
end
nn=0;
rotate_matrix_all=V_pure_state;
for ii=2:2^numQs
    for jj=1:ii-1
        nn=nn+2;
        R_rotate=rotate_value(nn-1)+1i*rotate_value(nn);
        delta_matrix=eye(2^numQs);
        delta_matrix(ii,jj)=R_rotate;
        delta_matrix(jj,ii)=-R_rotate';
        delta_matrix(ii,ii)=sqrt(1-abs(R_rotate)^2);
        delta_matrix(jj,jj)=sqrt(1-abs(R_rotate)^2);
    end
    rotate_matrix_all=rotate_matrix_all*delta_matrix;
end

rho=rotate_matrix_all*diag(P_pure_state)*rotate_matrix_all';

end
function distance=x2distance(x,numQs,V_pure_state,data)
    [rho]=x2rho(x,numQs,V_pure_state);
    [P] = rho2p(rho);
    distance=sqrt((sum(sum((P-data).^2)))/(size(P(:),1)));    
end
function distance=x2distance_chi(x,numQs,V_pure_state,data,bata_order_index,rho_order_index)
    [chi]=x2rho(x,numQs,V_pure_state);
    [P,~]=chi2p(chi,bata_order_index,rho_order_index);
    distance=sqrt((sum(sum(sum((P-data).^2))))/(size(P(:),1)));   
end
function [ x_opt, x_trace, y_trace, n_feval] = NelderMead (function_handle, x0, tolX, tolY, max_feval, axs)

%*****************************************************************************80
%
% NELDER_MEAD performs the Nelder-Mead optimization search.
%
%  Licensing:
%
%    This code is distributed under the GNU LGPL license.
%
%  Modified:
%
%    19 January 2009
%
%  Author:
%
%    Jeff Borggaard
%
%  Reference:
%
%    John Nelder, Roger Mead,
%    A simplex method for function minimization,
%    Computer Journal,
%    Volume 7, Number 4, January 1965, pages 308-313.
%
%  Parameters:
%
%    Input, real X(M+1,M), contains a list of distinct points that serve as 
%    initial guesses for the solution.  If the dimension of the space is M,
%    then the matrix must contain exactly M+1 points.  For instance,
%    for a 2D space, you supply 3 points.  Each row of the matrix contains
%    one point; for a 2D space, this means that X would be a
%    3x2 matrix.
%
%    Input, handle FUNCTION_HANDLE, a quoted expression for the function,
%    or the name of an M-file that defines the function, preceded by an 
%    "@" sign;
%
%    Input, logical FLAG, an optional argument; if present, and set to 1, 
%    it will cause the program to display a graphical image of the contours 
%    and solution procedure.  Note that this option only makes sense for 
%    problems in 2D, that is, with N=2.
%
%    Output, real X_OPT, the optimal value of X found by the algorithm.
%

%
%  Define algorithm constants
%

% modified by Yulin Wu

x = x0;
tolerance = tolY;

  rho = 1;    % rho > 0
  xi  = 2;    % xi  > max(rho, 1)
  gam = 0.5;  % 0 < gam < 1
  sig = 0.5;  % 0 < sig < 1
  
  %  tolerance = 1.0E-06;
  %  max_feval = 250;
%
%  Initialization
%

  [ temp, n_dim ] = size ( x );
  
  plotTrace = false;
  if nargin < 6
     axs = [];
  elseif numel(axs) < n_dim + 1
     error('number of axes must equal to number of dimmension +1.');
  else
      plotTrace = true;
  end

  if ( temp ~= n_dim + 1 )
    fprintf ( 1, '\n' );
    fprintf ( 1, 'NELDER_MEAD - Fatal error!\n' );
    error('  Number of points must be = number of design variables + 1\n');
  end

%   if ( nargin == 2 )
%     flag = 0;
%   end

%   if ( flag )
% 
%     xp = linspace(-5,5,101);
%     yp = xp;
%     for i=1:101
%       for j=1:101
%         fp(j,i) = feval(function_handle,[xp(i),yp(j)]);
%       end
%     end
%     
%     figure ( 27 )
%     hold on
%     contour(xp,yp,fp,linspace(0,200,25))
%     
%     if ( flag )
%       plot(x(1:2,1),x(1:2,2),'r')
%       plot(x(2:3,1),x(2:3,2),'r')
%       plot(x([1 3],1),x([1 3],2),'r')
%       pause
%       plot(x(1:2,1),x(1:2,2),'b')
%       plot(x(2:3,1),x(2:3,2),'b')
%       plot(x([1 3],1),x([1 3],2),'b')
%     end
% 
%   end

  index = 1 : n_dim + 1;
  
  [f    ] = evaluate ( x, function_handle ); 
  n_feval = n_dim + 1;

  [ f, index ] = sort ( f );
  x = x(index,:);
  % Yulin Wu
  x_trace = x(1,:); 
  y_trace = f(1);
  traces = NaN(1,n_dim+1);
  if plotTrace
      for ww = 1:n_dim
          if isgraphics(axs(ww))
            traces(ww) = line('parent',axs(ww),'XData',1,'YData',x_trace(:,ww),'Marker','.','Color','b');
            ylabel(axs(ww),['X(',num2str(ww,'%0.0f'),')']);
            xlabel(axs(ww),num2str(x_trace(end,ww),'%0.4e'));
          end
      end
      if isgraphics(axs(n_dim+1))
        traces(n_dim+1) = line('parent',axs(n_dim+1),'XData',1,'YData',y_trace,'Marker','.','Color','r');
        title(axs(n_dim+1),[num2str(n_feval),'th evaluation.']);
        ylabel(axs(n_dim+1),'Y');
      end
      drawnow;
  end

%  
%  Begin the Nelder Mead iteration.
%
  converged = false;
  diverged  = false;
  while ( ~converged && ~diverged)
%    
%  Compute the midpoint of the simplex opposite the worst point.
%
    x_bar = sum ( x(1:n_dim,:) ) / n_dim;
%
%  Compute the reflection point.
%
    x_r   = ( 1 + rho ) * x_bar ...
                - rho   * x(n_dim+1,:);

    f_r   = feval(function_handle,x_r); 
    n_feval = n_feval + 1;
    
    % Yulin Wu
  x_trace = [x_trace;x_r]; 
  y_trace = [y_trace,f_r];
  if plotTrace
      for ww = 1:n_dim
          if isgraphics(traces(ww))
            set(traces(ww),'XData',1:length(y_trace),'YData',x_trace(:,ww));
            xlabel(axs(ww),num2str(x_trace(end,ww),'%0.4e'));
          end
      end
      if isgraphics(traces(n_dim+1))
            set(traces(n_dim+1),'XData',1:length(y_trace),'YData',y_trace);
            title(axs(n_dim+1),[num2str(n_feval),'th evaluation, reflection.']);
      end
      drawnow;
  end

    
%
%  Accept the point:
%    
    if ( f(1) <= f_r && f_r <= f(n_dim) )

      x(n_dim+1,:) = x_r;
      f(n_dim+1  ) = f_r; 
       
%       if (flag)
%         title('reflection')
%       end
%
%  Test for possible expansion.
%
    elseif ( f_r < f(1) )

      x_e = ( 1 + rho * xi ) * x_bar ...
                - rho * xi   * x(n_dim+1,:);

      f_e = feval(function_handle,x_e); 
      n_feval = n_feval+1;
      
      % Yulin Wu
  x_trace = [x_trace;x_e]; 
  y_trace = [y_trace,f_e];
  if plotTrace
      for ww = 1:n_dim
          if isgraphics(traces(ww))
            set(traces(ww),'XData',1:length(y_trace),'YData',x_trace(:,ww));
            xlabel(axs(ww),num2str(x_trace(end,ww),'%0.4e'));
          end
      end
      if isgraphics(traces(n_dim+1))
            set(traces(n_dim+1),'XData',1:length(y_trace),'YData',y_trace);
            title(axs(n_dim+1),[num2str(n_feval),'th evaluation, expansion.'])
      end
      drawnow;
  end
%
%  Can we accept the expanded point?
%
      if ( f_e < f_r )
        x(n_dim+1,:) = x_e;
        f(n_dim+1  ) = f_e;
%         if (flag), title('expansion'), end
      else
        x(n_dim+1,:) = x_r;
        f(n_dim+1  ) = f_r;
%         if (flag), title('eventual reflection'), end
      end
%
%  Outside contraction.
%
    elseif ( f(n_dim) <= f_r && f_r < f(n_dim+1) )

      x_c = (1+rho*gam)*x_bar - rho*gam*x(n_dim+1,:);
      f_c = feval(function_handle,x_c);
      n_feval = n_feval+1;
      
      % Yulin Wu
          x_trace = [x_trace;x_c]; 
          y_trace = [y_trace,f_c];
          if plotTrace
              for ww = 1:n_dim
                  if isgraphics(traces(ww))
                    set(traces(ww),'XData',1:length(y_trace),'YData',x_trace(:,ww));
                    xlabel(axs(ww),num2str(x_trace(end,ww),'%0.4e'));
                  end
              end
              if isgraphics(traces(n_dim+1))
                    set(traces(n_dim+1),'XData',1:length(y_trace),'YData',y_trace);
                    title(axs(n_dim+1),[num2str(n_feval),'th evaluation, outside contraction.'])
              end
              drawnow;
          end
      
      if (f_c <= f_r) % accept the contracted point
        x(n_dim+1,:) = x_c;
        f(n_dim+1  ) = f_c;
%         if (flag), title('outside contraction'), end

      else
        [x,f] = shrink(x,function_handle,sig);
        n_feval = n_feval+n_dim;
%         if (flag), title('shrink'), end

        % Yulin Wu
        [ f_, index_ ] = sort ( f );
        x_ = x(index_,:);
          x_trace = [x_trace;x_(1,:)]; 
          y_trace = [y_trace,f_(1)];
          if plotTrace
              for ww = 1:n_dim
                  if isgraphics(traces(ww))
                    set(traces(ww),'XData',1:length(y_trace),'YData',x_trace(:,ww));
                    xlabel(axs(ww),num2str(x_trace(end,ww),'%0.4e'));
                  end
              end
              if isgraphics(traces(n_dim+1))
                    set(traces(n_dim+1),'XData',1:length(y_trace),'YData',y_trace);
                    title(axs(n_dim+1),[num2str(n_feval),'th evaluation, shrink.'])
              end
              drawnow;
          end

      end
%
%  F_R must be >= F(N_DIM+1).
%  Try an inside contraction.
%
    else

      x_c = ( 1 - gam ) * x_bar ...
                + gam   * x(n_dim+1,:);

      f_c = feval(function_handle,x_c); 
      n_feval = n_feval+1;

%
%  Can we accept the contracted point?
%
      if (f_c < f(n_dim+1))
        x(n_dim+1,:) = x_c;
        f(n_dim+1  ) = f_c;
%         if (flag), title('inside contraction'), end

        % Yulin Wu
          x_trace = [x_trace;x_c]; 
          y_trace = [y_trace,f_c];
          if plotTrace
              for ww = 1:n_dim
                  if isgraphics(traces(ww))
                    set(traces(ww),'XData',1:length(y_trace),'YData',x_trace(:,ww));
                    xlabel(axs(ww),num2str(x_trace(end,ww),'%0.4e'));
                  end
              end
              if isgraphics(traces(n_dim+1))
                    set(traces(n_dim+1),'XData',1:length(y_trace),'YData',y_trace);
                    title(axs(n_dim+1),[num2str(n_feval),'th evaluation, inside contraction.'])
              end
              drawnow;
          end
          
      else
        [x,f] = shrink(x,function_handle,sig); n_feval = n_feval+n_dim;
%         if (flag), title('shrink'), end
        
         % Yulin Wu
        [ f_, index_ ] = sort ( f );
        x_ = x(index_,:);
          x_trace = [x_trace;x_(1,:)]; 
          y_trace = [y_trace,f_(1)];
          if plotTrace
              for ww = 1:n_dim
                  if isgraphics(traces(ww))
                    set(traces(ww),'XData',1:length(y_trace),'YData',x_trace(:,ww));
                    xlabel(axs(ww),num2str(x_trace(end,ww),'%0.4e'));
                  end
              end
              if isgraphics(traces(n_dim+1))
                    set(traces(n_dim+1),'XData',1:length(y_trace),'YData',y_trace);
                    title(axs(n_dim+1),[num2str(n_feval),'th evaluation, shrink.'])
              end
              drawnow;
          end
         
      end

    end
%
%  Resort the points.  Note that we are not implementing the usual
%  Nelder-Mead tie-breaking rules  (when f(1) = f(2) or f(n_dim) =
%  f(n_dim+1)...
%
    [ f, index ] = sort ( f );
    x = x(index,:);
    
    % convergence smaller than tolerance, break, Yulin Wu
    if all(range(x) - tolX < 0)
        % Yulin Wu
        if isgraphics(traces(n_dim+1))
            title(axs(n_dim+1),[num2str(n_feval),'th evaluation, optimization terminate: X tolerance reached.'])
        end
        break;
    end
%
%  Test for convergence
%
    converged = f(n_dim+1)-f(1) < tolerance;
    if converged && isgraphics(traces(n_dim+1))
        title(axs(n_dim+1),[num2str(n_feval),'th evaluation, optimization terminate: Y tolerance reached.'])
    end
%   
%  Test for divergence
%
    diverged = ( max_feval < n_feval );
    
%     if (flag)
%       plot(x(1:2,1),x(1:2,2),'r')
%       plot(x(2:3,1),x(2:3,2),'r')
%       plot(x([1 3],1),x([1 3],2),'r')
%       pause
%       plot(x(1:2,1),x(1:2,2),'b')
%       plot(x(2:3,1),x(2:3,2),'b')
%       plot(x([1 3],1),x([1 3],2),'b')
%     end

  end

  if ( 0 )
    fprintf('The best point x^* was: %d %d\n',x(1,:));
    fprintf('f(x^*) = %d\n',f(1));
  end

  x_opt = x(1,:);
  
  if ( diverged )
    fprintf ( 1, '\n' );
    fprintf ( 1, 'NELDER_MEAD - Warning!\n' );
    fprintf ( 1, '  The maximum number of function evaluations was exceeded\n')
    fprintf ( 1, '  without convergence being achieved.\n' );
  end

  return
end
function f = evaluate ( x, function_handle )

%*****************************************************************************80
%
% EVALUATE handles the evaluation of the function at each point.
%
%  Licensing:
%
%    This code is distributed under the GNU LGPL license.
%
%  Modified:
%
%    19 January 2009
%
%  Author:
%
%    Jeff Borggaard
%
%  Reference:
%
%    John Nelder, Roger Mead,
%    A simplex method for function minimization,
%    Computer Journal,
%    Volume 7, Number 4, January 1965, pages 308-313.
%
%  Parameters:
%
%    Input, real X(N_DIM+1,N_DIM), the points.
%
%    Input, real FUNCTION_HANDLE ( X ), the handle of a MATLAB procedure
%    to evaluate the function.
%
%    Output, real F(1,NDIM+1), the value of the function at each point.
%
  [ temp, n_dim ] = size ( x );

  f = zeros ( 1, n_dim+1 );
  
  for i = 1 : n_dim + 1
    f(i) = feval(function_handle,x(i,:));
  end

  return
end
function [ x, f ] = shrink ( x, function_handle, sig )

%*****************************************************************************80
%
% SHRINK shrinks the simplex towards the best point.
%
%  Discussion:
%
%    In the worst case, we need to shrink the simplex along each edge towards
%    the current "best" point.  This is quite expensive, requiring n_dim new
%    function evaluations.
%
%  Licensing:
%
%    This code is distributed under the GNU LGPL license.
%
%  Modified:
%
%    19 January 2009
%
%  Author:
%
%    Jeff Borggaard
%
%  Reference:
%
%    John Nelder, Roger Mead,
%    A simplex method for function minimization,
%    Computer Journal,
%    Volume 7, Number 4, January 1965, pages 308-313.
%
%  Parameters:
%
%    Input, real X(N_DIM+1,N_DIM), the points.
%
%    Input, real FUNCTION_HANDLE ( X ), the handle of a MATLAB procedure
%    to evaluate the function.
%
%    Input, real SIG, ?
%
%    Output, real X(N_DIM+1,N_DIM), the points after shrinking was applied.
%
%    Output, real F(1,NDIM+1), the value of the function at each point.
%
  [ temp, n_dim ] = size ( x );

  x1 = x(1,:);
  f(1) = feval ( function_handle, x1 );

  for i = 2 : n_dim + 1
    x(i,:) = sig * x(i,:) + ( 1.0 - sig ) * x(1,:);
    f(i) = feval ( function_handle, x(i,:) );
  end
  
  return
end
function [x,fval,exitflag,output] = fminsearchbnd(fun,x0,LB,UB,options,varargin)
% FMINSEARCHBND: FMINSEARCH, but with bound constraints by transformation
% usage: x=FMINSEARCHBND(fun,x0)
% usage: x=FMINSEARCHBND(fun,x0,LB)
% usage: x=FMINSEARCHBND(fun,x0,LB,UB)
% usage: x=FMINSEARCHBND(fun,x0,LB,UB,options)
% usage: x=FMINSEARCHBND(fun,x0,LB,UB,options,p1,p2,...)
% usage: [x,fval,exitflag,output]=FMINSEARCHBND(fun,x0,...)
% 
% arguments:
%  fun, x0, options - see the help for FMINSEARCH
%
%  LB - lower bound vector or array, must be the same size as x0
%
%       If no lower bounds exist for one of the variables, then
%       supply -inf for that variable.
%
%       If no lower bounds at all, then LB may be left empty.
%
%       Variables may be fixed in value by setting the corresponding
%       lower and upper bounds to exactly the same value.
%
%  UB - upper bound vector or array, must be the same size as x0
%
%       If no upper bounds exist for one of the variables, then
%       supply +inf for that variable.
%
%       If no upper bounds at all, then UB may be left empty.
%
%       Variables may be fixed in value by setting the corresponding
%       lower and upper bounds to exactly the same value.
%
% Notes:
%
%  If options is supplied, then TolX will apply to the transformed
%  variables. All other FMINSEARCH parameters should be unaffected.
%
%  Variables which are constrained by both a lower and an upper
%  bound will use a sin transformation. Those constrained by
%  only a lower or an upper bound will use a quadratic
%  transformation, and unconstrained variables will be left alone.
%
%  Variables may be fixed by setting their respective bounds equal.
%  In this case, the problem will be reduced in size for FMINSEARCH.
%
%  The bounds are inclusive inequalities, which admit the
%  boundary values themselves, but will not permit ANY function
%  evaluations outside the bounds. These constraints are strictly
%  followed.
%
%  If your problem has an EXCLUSIVE (strict) constraint which will
%  not admit evaluation at the bound itself, then you must provide
%  a slightly offset bound. An example of this is a function which
%  contains the log of one of its parameters. If you constrain the
%  variable to have a lower bound of zero, then FMINSEARCHBND may
%  try to evaluate the function exactly at zero.
%
%
% Example usage:
% rosen = @(x) (1-x(1)).^2 + 105*(x(2)-x(1).^2).^2;
%
% fminsearch(rosen,[3 3])     % unconstrained
% ans =
%    1.0000    1.0000
%
% fminsearchbnd(rosen,[3 3],[2 2],[])     % constrained
% ans =
%    2.0000    4.0000
%
% See test_main.m for other examples of use.
%
%
% See also: fminsearch, fminspleas
%
%
% Author: John D'Errico
% E-mail: woodchips@rochester.rr.com
% Release: 4
% Release date: 7/23/06

% size checks
xsize = size(x0);
x0 = x0(:);
n=length(x0);

if (nargin<3) || isempty(LB)
  LB = repmat(-inf,n,1);
else
  LB = LB(:);
end
if (nargin<4) || isempty(UB)
  UB = repmat(inf,n,1);
else
  UB = UB(:);
end

if (n~=length(LB)) || (n~=length(UB))
  error 'x0 is incompatible in size with either LB or UB.'
end

% set default options if necessary
if (nargin<5) || isempty(options)
  options = optimset('fminsearch');
end

% stuff into a struct to pass around
params.args = varargin;
params.LB = LB;
params.UB = UB;
params.fun = fun;
params.n = n;
% note that the number of parameters may actually vary if 
% a user has chosen to fix one or more parameters
params.xsize = xsize;
params.OutputFcn = [];

% 0 --> unconstrained variable
% 1 --> lower bound only
% 2 --> upper bound only
% 3 --> dual finite bounds
% 4 --> fixed variable
params.BoundClass = zeros(n,1);
for i=1:n
  k = isfinite(LB(i)) + 2*isfinite(UB(i));
  params.BoundClass(i) = k;
  if (k==3) && (LB(i)==UB(i))
    params.BoundClass(i) = 4;
  end
end

% transform starting values into their unconstrained
% surrogates. Check for infeasible starting guesses.
x0u = x0;
k=1;
for i = 1:n
  switch params.BoundClass(i)
    case 1
      % lower bound only
      if x0(i)<=LB(i)
        % infeasible starting value. Use bound.
        x0u(k) = 0;
      else
        x0u(k) = sqrt(x0(i) - LB(i));
      end
      
      % increment k
      k=k+1;
    case 2
      % upper bound only
      if x0(i)>=UB(i)
        % infeasible starting value. use bound.
        x0u(k) = 0;
      else
        x0u(k) = sqrt(UB(i) - x0(i));
      end
      
      % increment k
      k=k+1;
    case 3
      % lower and upper bounds
      if x0(i)<=LB(i)
        % infeasible starting value
        x0u(k) = -pi/2;
      elseif x0(i)>=UB(i)
        % infeasible starting value
        x0u(k) = pi/2;
      else
        x0u(k) = 2*(x0(i) - LB(i))/(UB(i)-LB(i)) - 1;
        % shift by 2*pi to avoid problems at zero in fminsearch
        % otherwise, the initial simplex is vanishingly small
        x0u(k) = 2*pi+asin(max(-1,min(1,x0u(k))));
      end
      
      % increment k
      k=k+1;
    case 0
      % unconstrained variable. x0u(i) is set.
      x0u(k) = x0(i);
      
      % increment k
      k=k+1;
    case 4
      % fixed variable. drop it before fminsearch sees it.
      % k is not incremented for this variable.
  end
  
end
% if any of the unknowns were fixed, then we need to shorten
% x0u now.
if k<=n
  x0u(k:n) = [];
end

% were all the variables fixed?
if isempty(x0u)
  % All variables were fixed. quit immediately, setting the
  % appropriate parameters, then return.
  
  % undo the variable transformations into the original space
  x = xtransform(x0u,params);
  
  % final reshape
  x = reshape(x,xsize);
  
  % stuff fval with the final value
  fval = feval(params.fun,x,params.args{:});
  
  % fminsearchbnd was not called
  exitflag = 0;
  
  output.iterations = 0;
  output.funcCount = 1;
  output.algorithm = 'fminsearch';
  output.message = 'All variables were held fixed by the applied bounds';
  
  % return with no call at all to fminsearch
  return
end

% Check for an outputfcn. If there is any, then substitute my
% own wrapper function.
if ~isempty(options.OutputFcn)
  params.OutputFcn = options.OutputFcn;
  options.OutputFcn = @outfun_wrapper;
end

%%%%%%% % by Yulin Wu
if isfield(options,'TolX')
    options.TolX = tolxtransform(options.TolX,params);
end
%%%%%%%

% now we can call fminsearch, but with our own
% intra-objective function.
[xu,fval,exitflag,output] = fminsearch(@intrafun,x0u,options,params);

% undo the variable transformations into the original space
x = xtransform(xu,params);

% final reshape to make sure the result has the proper shape
x = reshape(x,xsize);

% Use a nested function as the OutputFcn wrapper
  function stop = outfun_wrapper(x,varargin)
    % we need to transform x first
    xtrans = xtransform(x,params);
    
    % then call the user supplied OutputFcn
    stop = params.OutputFcn(xtrans,varargin{1:(end-1)});
    
  end

end % mainline end
function fval = intrafun(x,params)
% transform variables, then call original function

% transform
xtrans = xtransform(x,params);

% and call fun
fval = feval(params.fun,reshape(xtrans,params.xsize),params.args{:});

end % sub function intrafun end
function xtrans = xtransform(x,params)
% converts unconstrained variables into their original domains

xtrans = zeros(params.xsize);
% k allows some variables to be fixed, thus dropped from the
% optimization.
k=1;
for i = 1:params.n
  switch params.BoundClass(i)
    case 1
      % lower bound only
      xtrans(i) = params.LB(i) + x(k).^2;
      
      k=k+1;
    case 2
      % upper bound only
      xtrans(i) = params.UB(i) - x(k).^2;
      
      k=k+1;
    case 3
      % lower and upper bounds
      xtrans(i) = (sin(x(k))+1)/2;
      xtrans(i) = xtrans(i)*(params.UB(i) - params.LB(i)) + params.LB(i);
      % just in case of any floating point problems
      xtrans(i) = max(params.LB(i),min(params.UB(i),xtrans(i)));
      
      k=k+1;
    case 4
      % fixed variable, bounds are equal, set it at either bound
      xtrans(i) = params.LB(i);
    case 0
      % unconstrained variable.
      xtrans(i) = x(k);
      
      k=k+1;
  end
end

end % sub function xtransform end
function xtrans = tolxtransform(tolx,params)
% by Yulin Wu
switch params.BoundClass(1)
case {1,2}
  % lower/upper bound only
  xtrans = tolx^2;
case 3
  % lower and upper bounds
  xtrans = sin(abs(tolx));
otherwise
  xtrans = abs(tolx);
end

end
