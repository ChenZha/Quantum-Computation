function chi=processTomoData2Chi(pexp)

%pexp 是一个 (4^n,3^n,2^n)矩阵，
%第三个维度是态的编号，
% rho(:,:,1)： 初态是 |q2:0, q1:0>；
% rho(:,:,2)： 初态是 |q2:0, q1:1>；
% rho(:,:,3)： 初态是 |q2:0, q1:+>；
% rho(:,:,4)： 初态是 |q2:0, q1:i>；
% rho(:,:,5)： 初态是 |q2:1, q1:0>；
% rho(:,:,6)： 初态是 |q2:1, q1:1>；
    
    numQs = round(log(size(pexp,1))/log(4));

    statetomo_rho=zeros(2^numQs,2^numQs,4^numQs);
    for ii=1:4^numQs
        data=reshape(pexp(ii,:,:),3^numQs,2^numQs);
        statetomo_rho(:,:,ii)=sqc.qfcns.stateTomoData2Rho(data);
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