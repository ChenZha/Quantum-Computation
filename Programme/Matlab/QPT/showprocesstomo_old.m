function [] = showprocesstomo(pexp,pideal)
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
h = figure;
set(h,'defaultuicontrolunits','normalized');
hax1 = axes('position',[0.1,0.2,0.3,0.6],'linewidth',2.25,'fontsize',14);
hax2 = axes('position',[0.6,0.2,0.3,0.6],'linewidth',2.25,'fontsize',14);
popupshowstr = {'Process Tomo'...
    '|q2q1> = |00>'...
    '|q2q1> = |01>'...
    '|q2q1> = |0+>'...
    '|q2q1> = |0i>'...
    '|q2q1> = |10>'...
    '|q2q1> = |11>'...
    '|q2q1> = |1+>'...
    '|q2q1> = |1i>'...
    '|q2q1> = |+0>'...
    '|q2q1> = |+1>'...
    '|q2q1> = |++>'...
    '|q2q1> = |+i>'...
    '|q2q1> = |i0>'...
    '|q2q1> = |i1>'...
    '|q2q1> = |i+>'...
    '|q2q1> = |ii>'};
htextfidelity = uicontrol(h,'Style','text',...
    'position',[0.35,0.05,0.3,0.1],...
    'string','',...
    'FontSize',16);
htexttheta1 = uicontrol(h,'Style','text',...
    'position',[0.65,0.075,0.08,0.03],...
    'string','θ1: 0 °',...
    'HorizontalAlign','right');
htexttheta2 = uicontrol(h,'Style','text',...
    'position',[0.65,0.025,0.08,0.03],...
    'string','θ2: 0 °',...
    'HorizontalAlign','right');
hsldtheta1 = uicontrol('Style', 'slider',...
        'Min',-180,'Max',180,'Value',0,...
        'SliderStep',[1/360,1/36],...
        'Position', [0.75 0.08 0.2 0.04],...
    'callback',@uicallback); 
hsldtheta2 = uicontrol('Style', 'slider',...
        'Min',-180,'Max',180,'Value',0,...
        'SliderStep',[1/360,1/36],...
        'Position', [0.75 0.02 0.2 0.04],...
    'callback',@uicallback); 
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
    'string',{'PIdeal','CZ','CNOT','Idle','iSWAP','SWAP'},...
    'callback',@uicallback);
uicallback(hpopupshow,0)
function uicallback(hObject,callbackdata)
    showdata()
end

function showdata()
    ishow = get(hpopupshow,'Value');
    iidealdata = get(hpopupidealdata,'Value');
    theta1 = get(hsldtheta1,'Value')/180*pi;
    theta2 = get(hsldtheta2,'Value')/180*pi;
    set(htexttheta1,'string',['θ1: ' num2str(theta1/pi*180,4) '°']);
    set(htexttheta2,'string',['θ2: ' num2str(theta2/pi*180,4) '°']);
    pe = rotatep(pexp,theta1,theta2);
    switch iidealdata
        case 1 % PIdeal
            pid = pideal;
        case 2 % CZ
            pid = CZ();
        case 3 % CNOT
            pid = CNOT();
        case 4 % IDLE
            pid = IDLE();
        case 5 % iSWAP
            pid = ISWAP();
        case 6 % SWAP
            pid = SWAP();
    end
    switch ishow
        case 1
            chiexp = sqc.qfcns.processTomoData2Chi(pe);
            chiid = sqc.qfcns.processTomoData2Chi(pid);
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
            pid = CZ();
        case 3 % CNOT
            pid = CNOT();
        case 4 % IDLE
            pid = IDLE();
        case 5 % iSWAP
            pid = ISWAP();
        case 6 % SWAP
            pid = SWAP();
    end
    ishow = get(hpopupshow,'Value');
    switch ishow
        case 1
            [theta1,theta2] = thetafit(pexp,pid);
        otherwise
            istate = ishow-1;
            [theta1,theta2] = thetafit(pexp(istate,:,:),pid(istate,:,:));
    end
    set(hsldtheta1,'Value',theta1*180/pi);
    set(hsldtheta2,'Value',theta2*180/pi);
    showdata();
end
end

function showchi(haxreal,haximage,chiexp,chiid)
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
    title('Real(\chi)');
    set(gca,'XTick',1:16);
    set(gca,'XTickLabel',{'II','IX','IY','IZ','XI','XX','XY','XZ','YI','YX','YY','YZ','ZI','ZX','ZY','ZZ'});
    set(gca,'YTick',1:16);
    set(gca,'YTickLabel',{'II','IX','IY','IZ','XI','XX','XY','XZ','YI','YX','YY','YZ','ZI','ZX','ZY','ZZ'});
    xlabel('\sigma_2\sigma_1'); ylabel('\sigma_2\sigma_1');
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
    set(gca,'XTick',1:16);
    set(gca,'XTickLabel',{'II','IX','IY','IZ','XI','XX','XY','XZ','YI','YX','YY','YZ','ZI','ZX','ZY','ZZ'});
    set(gca,'YTick',1:16);
    set(gca,'YTickLabel',{'II','IX','IY','IZ','XI','XX','XY','XZ','YI','YX','YY','YZ','ZI','ZX','ZY','ZZ'});
    xlabel('\sigma_2\sigma_1'); ylabel('\sigma_2\sigma_1');
    colorbar('position',[0.95 0.3 0.01 0.4]);
    hold off;
end

function showrho(haxreal,haximage,rhoexp,rhoid)
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
    title('Real(\rho)');
    set(gca,'XTick',1:4);
    set(gca,'XTickLabel',{'00','01','10','11'});
    set(gca,'YTick',1:4);
    set(gca,'YTickLabel',{'00','01','10','11'});
    xlabel('|q_2q_1>'); ylabel('|q_2q_1>');
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
    set(gca,'XTick',1:4);
    set(gca,'XTickLabel',{'00','01','10','11'});
    set(gca,'YTick',1:4);
    set(gca,'YTickLabel',{'00','01','10','11'});
    xlabel('|q_2q_1>'); ylabel('|q_2q_1>');
    colorbar('position',[0.95 0.3 0.01 0.4]);
    hold off;
end

function [theta1,theta2] = thetafit(pexp,pid)
    function y = fitFunc(pexp,pid,theta)
        pe = rotatep(pexp,theta(1),theta(2));
        D = (pe - pid).^2;
        y = sum(D(:));
    end
    
    theta = qes.util.fminsearchbnd(@(theta)fitFunc(pexp,pid,theta),[0,0],[-pi,-pi],[pi,pi]);
    theta1 = theta(1);
    theta2 = theta(2);
end

function [pr] = rotatep(p,theta1,theta2)
    sz = size(p,1);
    pr = NaN(sz,9,4);
    Z = [1,0;0,-1];
    U = kron(expm(-1i*theta2*Z/2),expm(-1i*theta1*Z/2));
    for istate = 1:sz
        rho = stateTomoData2Rho(squeeze(p(istate,:,:)));
        rho = U*rho*U';
        pr(istate,:,:) = rho2p(rho);
    end
    pr = real(pr);
end

function [F] = fidelity(rho1,rho2)
m = sqrtm(sqrtm(rho1)*rho2*sqrtm(rho1));
F = trace(m)*trace(m);
F = real(F);
end

function [P] = CZ()
cz = [1,0,0,0;
     0,1,0,0;
     0,0,1,0;
     0,0,0,-1];
P = m2p(cz);
end

function [P] = CNOT()
cnot = [1,0,0,0;
     0,1,0,0;
     0,0,0,1;
     0,0,1,0];
P = m2p(cnot);
end

function [P] = IDLE()
cnot = [1,0,0,0;
     0,1,0,0;
     0,0,1,0;
     0,0,0,1];
P = m2p(cnot);
end

function [P] = ISWAP()
iswap = [1,0,0,0;
     0,0,1i,0;
     0,1i,0,0;
     0,0,0,1];
P = m2p(iswap);
end

function [P] = SWAP()
swap = [1,0,0,0;
     0,0,1,0;
     0,1,0,0;
     0,0,0,1];
P = m2p(swap);
end

function [P] = m2p(m)
s = cell(1,4);
s{1} = [1;0];
s{2} = [0;1];
s{3} = [1;1]/sqrt(2);
s{4} = [1;1i]/sqrt(2);

rho = cell(4,4);
for iq1 = 1:4
    for iq2 = 1:4
        rho{iq2,iq1} = kron(s{iq2}*s{iq2}',s{iq1}*s{iq1}');
    end
end
P = NaN(16,9,4);
for ii = 1:16
    iq2 = fix((ii-1)/4)+1;
    iq1 = ii-(iq2-1)*4;
    rho_ = m*rho{iq2,iq1}*m';
    P(ii,:,:) = rho2p(rho_);
end      
end

function [P] = rho2p(rho)
I = [1,0;0,1];
X = [0,1;1,0];
Y = [0, -1i; 1i,0];
Y2m = expm(-1i*(-pi)*Y/4);
X2p = expm(-1i*pi*X/4);
TomoGateSet = {Y2m,X2p,I};
u = cell(3,3);
for u_q1 = 1:3
    for u_q2 = 1:3
        u{u_q2,u_q1} = kron(TomoGateSet{u_q2},TomoGateSet{u_q1});
    end
end
U = NaN(36,16);
for Ui = 1:36 % Ui is index as {u_q2,u_q1,s_q2,s_q1}
    for Uj = 1:16 % Uj is index as {j_col_q2,j_col_q1,j_row_q2,j_row_q1}
        ui = fix((Ui-1)/4)+1;
        s = Ui-(ui-1)*4;
        u_q2 = fix((ui-1)/3)+1;
        u_q1 = ui-(u_q2-1)*3;
        s_q2 = fix((s-1)/2)+1;
        s_q1 = s-(s_q2-1)*2;
        j_col = fix((Uj-1)/4)+1;
        j_row = Uj-(j_col-1)*4;
        j_col_q2 = fix((j_col-1)/2)+1;
        j_col_q1 = j_col-(j_col_q2-1)*2;
        j_row_q2 = fix((j_row-1)/2)+1;
        j_row_q1 = j_row-(j_row_q2-1)*2;
        U(Ui,Uj) = u{u_q2,u_q1}(s,j_row)*conj(u{u_q2,u_q1}(s,j_col));
    end
end
P_ = U*rho(:);
P_ = reshape(P_,4,9);
P = P_.';
end

function rho = stateTomoData2Rho(data)
% data: 3^n by 2^n
% row: {'Y2p','X2m','I'} => {'sigma_x','sigma_y','sigma_z'}(abbr.: {X,Y,Z})
%       1Q: {X}, {Y} ,{Z}
%       2Q: {q2:X q1:X}, {q2:X q1:Y}, {q2:X q1:I},... ,{q2:Z q1:Z}
% colomn: P|00>,|01>,|10>,|11>
% qubit labeled as: |qubits{2},qubits{1}>
% in case of 2Q data(3,2): {qubits{2}:X qubits{1}:I} P|01> (|qubits{2},qubits{1}>)

    sigmaz = [1,0;0,-1];
    sigmax = [0,1;1,0];
    sigmay = [0,-1i;1i,0];
    
    I = [1,0;0,1];
    X2p = expm(-1j*(pi/2)*sigmax/2);
    % X2m = expm(-1j*(-pi/2)*sigmax/2);

    % Y2p = expm(-1j*(pi/2)*sigmay/2);
    Y2m = expm(-1j*(-pi/2)*sigmay/2);
    
    numQs = round(log(size(data,1))/log(3));
    switch numQs
        case 1
            % data = data*[-1;1];  % {'Y2m','X2p','I'}
			data = data*[1;-1];  % {'Y2m','X2p','I'}
            rho = (data(3)*sigmaz + data(2)*sigmay + data(1)*sigmax+eye(2))/2;
        case 2
            
            % data(:,[2,3]) = data(:,[3,2]);
            
            u = {Y2m,X2p,I};
            U = cell(3,3);
            for uq2= 1:3
                for uq1 = 1:3
                    U{uq2,uq1} = kron(u{uq2},u{uq1});
                end
            end

%             R = NaN(36,16);
%             for ii = 1:4
%                 for jj = 1:4
%                     for kk = 1:4
%                         for ui = 1:3
%                             for uj = 1:3
%                                 u_ = U{ui,uj};
%                                 R((kk-1)*9+(ui-1)*3+uj,(ii-1)*4+jj) = ...
%                                    u_(kk,ii)*conj(u_(kk,jj));
%                             end
%                         end
%                     end
%                 end
%             end

            
            R = NaN(36,16);

            for l = 1:4
                for m = 1:4
                    for s = 1:4
                        for uq2 = 1:3
                            for uq1 = 1:3
                                u_ = U{uq2,uq1};
                                
                                ii = (s-1)*9+(uq2-1)*3+uq1;
                                jj = (m-1)*4+l;
                                
                                R(ii,jj) = u_(s,l)*conj(u_(s,m));
                            end
                        end
                    end
                end
            end

            D = data(:);

            rho_ = R\D;

            rho = NaN(4,4);
            for ii = 1:4
                for jj = 1:4
                    rho(ii,jj) = rho_((jj-1)*4+ii);
                end
            end
        otherwise 
            error('TODO');
    end
end