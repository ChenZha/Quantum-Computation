function rho = stateTomoData2Rho(data,phaseCorrection,set_fit)
% data: 3^n by 2^n
% row: {'Y2p','X2m','I'} => {'sigma_x','sigma_y','sigma_z'}(abbr.: {X,Y,Z})
%       1Q: {X}, {Y} ,{Z}
%       2Q: {q2:X q1:X}, {q2:X q1:Y}, {q2:X q1:Z},... ,{q2:Z q1:Z}
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
    
    if nargin < 2
        phaseCorrection = [];
        set_fit=struct();
        set_fit.is_fit=0;
    elseif nargin < 3
        set_fit=struct();
        set_fit.is_fit=0;
    elseif numel(phaseCorrection) ~= numQs
        error('length of phaseCorrection not equal to number of qubits');
    end
    
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
    
    if isempty(phaseCorrection)
        return;
    elseif phaseCorrection~=[0,0]
        r = [1,0;0,exp(-1j*phaseCorrection(1))];
        for ii = 2:numQs
            r = kron(r,[1,0;0,exp(-1j*phaseCorrection(ii))]);
        end
        rho = r'*rho*r;
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
    [ x_opt, x_trace, y_trace, n_feval] = qes.util.NelderMead (function_handle, x0, set_fit.tolX, set_fit.tolY, set_fit.max_feval);
else
    fprintf('正在优化 processtomo\n')
    [bata_order_index,rho_order_index]=calculate_bata(round(numQs/2));
    function_handle=@(x)x2distance_chi(x,numQs,V_pure_state,data,bata_order_index,rho_order_index);
    x_center=[P_pure_state(1:2^numQs-1),zeros(1,round((2^numQs-1)*(2^numQs)))];
    x0=[x_center;x_center+0.01*eye(length(x_center))];
    [ x_opt, x_trace, y_trace, n_feval] = qes.util.NelderMead (function_handle, x0, set_fit.tolX, set_fit.tolY, set_fit.max_feval);
    
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
function distance=x2distance(x,numQs,V_pure_state,data)
    [rho]=x2rho(x,numQs,V_pure_state);
    [P] = rho2p(rho);
    distance=sqrt((sum(sum((P-data).^2)))/(size(P(:),1)));    
end