function [P] = OpMat2ProcessTomoData(D)
% D = [1,0,0,0;
%      0,1,0,0;
%      0,0,1,0;
%      0,0,0,-1];
numQs = log(size(D,1))/log(2);
P = m2p(kron(eye(2^(numQs-2)),D));
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
function [rho_opt]=fit_rho(rho,data)

numQs = round(log(size(rho,2))/log(2));
[eigenstate,eigenvalue]=eig(rho);
P_pure_state=zeros(1,2^numQs);
V_pure_state=eigenstate;
for ii=1:2^numQs
    P_pure_state(ii)=real(eigenvalue(ii,ii));
end

function_handle=@(x)x2distance(x,numQs,V_pure_state,data);
x_center=[P_pure_state(1:2^numQs-1),zeros(1,round((2^numQs-1)*(2^numQs)))];
x0=[x_center;x_center+0.01*eye(length(x_center))];

[ x_opt, x_trace, y_trace, n_feval] = NelderMead (function_handle, x0, 1e-5, 1e-5, 200);
[rho_opt]=x2rho(x_opt,numQs,V_pure_state);

%%%for test
% fprintf('now');
% clf;
% figure(200);
% plot(1:length(y_trace),y_trace);
% title('y trace')
% 
% [m,n]=size(x_trace);
% figure(201);
% hold on;
% for ii=1:3
%     plot(1:m,x_trace(:,ii))
% end
% plot(1:m,1-x_trace(:,1)-x_trace(:,2)-x_trace(:,3))
% title('x trace1')
% figure(202);
% hold on;
% for ii=4:n
%     plot(1:m,x_trace(:,ii))
% end
% title('x trace2')
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