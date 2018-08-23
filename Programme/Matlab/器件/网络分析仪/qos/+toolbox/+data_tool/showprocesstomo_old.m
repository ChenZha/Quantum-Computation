function [] = showprocesstomo(pexp,pideal,User_defined_gate)
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
    showdata()
end

function showdata()
    ishow = get(hpopupshow,'Value');
    iidealdata = get(hpopupidealdata,'Value');
    theta=zeros(1,numQs);
    for ii1=1:numQs
        theta(ii1) = get(hsldtheta(ii1),'Value')/180*pi;
        set(htexttheta(ii1),'string',['θ',num2str(ii1),': ' num2str(theta(ii1)/pi*180,4) '°']);
    end
    pe = rotatep(pexp,theta);
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
    switch ishow
        case 1
            chiexp = processTomoData2Rho(pe);
            chiid = processTomoData2Rho(pid);
            showchi(hax1,hax2,chiexp,chiid);
            F = fidelity(chiexp,chiid);
        otherwise
            istate = ishow-1;
            rhoexp = stateTomoData2Rho(squeeze(pe(istate,:,:)));
            rhoid = stateTomoData2Rho(squeeze(pid(istate,:,:)));
            showrho(hax1,hax2,rhoexp,rhoid)
            F = fidelity(rhoexp,rhoid);
    end
    set(htextfidelity,'string',['Fidelity = ' num2str(F*100,4) '%']);
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
            [theta] = thetafit(pexp,pid);
        otherwise
            istate = ishow-1;
            [theta] = thetafit(pexp(istate,:,:),pid(istate,:,:));
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
    showdata();
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

function [theta] = thetafit(pexp,pid)
    function y = fitFunc(pexp,pid,theta)
        pe = rotatep(pexp,theta);
        D = (pe - pid).^2;
        y = sum(D(:));
    end
    numQs = round(log(size(pexp,2))/log(3));
    theta = qes.util.fminsearchbnd(@(theta)fitFunc(pexp,pid,theta),zeros(1,numQs),-ones(1,numQs)*2*pi,ones(1,numQs)*2*pi);
end

function [pr] = rotatep(p,theta)
    sz = size(p,1);
    Z = [1,0;0,-1];
    numQs = round(log(size(p,2))/log(3));
    pr = NaN(sz,3^numQs,2^numQs);
    U=1;
    for ii=1:numQs
        U=kron(expm(-1i*theta(ii)*Z/2),U);
    end
    %U = kron(expm(-1i*theta2*Z/2),expm(-1i*theta1*Z/2));
    for istate = 1:sz
        rho = stateTomoData2Rho(squeeze(p(istate,:,:)));
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
end
end

function chi=processTomoData2Rho(P)

%statetomo_rho 是一个 (2^n,2^n,4^n)矩阵，
%第三个维度是态的编号，
% rho(:,:,1)： 初态是 |q2:0, q1:0>；
% rho(:,:,2)： 初态是 |q2:0, q1:1>；
% rho(:,:,3)： 初态是 |q2:0, q1:+>；
% rho(:,:,4)： 初态是 |q2:0, q1:i>；
% rho(:,:,5)： 初态是 |q2:1, q1:0>；
% rho(:,:,6)： 初态是 |q2:1, q1:1>；
    
    numQs = round(log(size(P,2))/log(3));
    
    %求4^n个不同初态的statetomo
    statetomo_rho=zeros(2^numQs,2^numQs,4^numQs);
    for ii=1:4^numQs
        data=reshape(P(ii,:,:),3^numQs,2^numQs);
        statetomo_rho(:,:,ii)=stateTomoData2Rho(data);
    end
    
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
end

function rho = stateTomoData2Rho(data)
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