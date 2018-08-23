function [Measure_matrix_new,eigenval] = analyse_chi_data(chi)
%     load('chi.mat')
    numQs = round(log(size(chi,2))/log(4));
    [eigenstate,eigenvalue]=eig(chi);
    eigenval=diag(eigenvalue);
    single_mesure_matrix(:,:,2) = [0 1;1 0];
    single_mesure_matrix(:,:,3) = [0 -1i;1i 0];
    single_mesure_matrix(:,:,4) = [1 0;0 -1];
    single_mesure_matrix(:,:,1) = [1 0;0 1];
    rho_single(:,:,1)=[1 0;0 0];
    rho_single(:,:,2)=[0 0;0 1];
    rho_single(:,:,3)=0.5*[1 1;1 1];
    rho_single(:,:,4)=0.5*[1 -1i;1i 1];
    
    %%计算对应的测量矩阵
    Measure_matrix=zeros(2^numQs,2^numQs,4^numQs);
    Measure_matrix_order_index=zeros(4^numQs,4^numQs);
    Measure_matrix_new=zeros(2^numQs,2^numQs,4^numQs);
    Measure_matrix_new_eff=zeros(2^numQs,2^numQs,4^numQs);
    for mm=1:4^numQs
    Measure_matrix_temp=1;
    qubit_base_index_m=transform_index_fun(numQs,mm,4);
        for mmii=1:numQs
            Measure_matrix_temp=kron(single_mesure_matrix(:,:,qubit_base_index_m(mmii)),Measure_matrix_temp);
        end
        Measure_matrix(:,:,mm)=Measure_matrix_temp;
        Measure_matrix_order_index(:,mm)=reshape(Measure_matrix_temp,4^numQs,1);
    end
    Measure_matrix_order_index_new=Measure_matrix_order_index*eigenstate;
    Measure_matrix_sum=zeros(2^numQs,2^numQs);
    Measure_matrix_sum_part=zeros(2^numQs,2^numQs,4^numQs);
    
    for mm=1:4^numQs
        Measure_matrix_new(:,:,mm)=reshape(Measure_matrix_order_index_new(:,mm),2^numQs,2^numQs);
        Measure_matrix_new_eff(:,:,mm)=Measure_matrix_new(:,:,mm)*sqrt(eigenvalue(mm,mm));
        Measure_matrix_sum_part(:,:,mm)=Measure_matrix_new(:,:,mm)'*Measure_matrix_new(:,:,mm)*eigenvalue(mm,mm);
        Measure_matrix_sum=Measure_matrix_sum+Measure_matrix_new(:,:,mm)'*Measure_matrix_new(:,:,mm)*eigenvalue(mm,mm);
        %Measure_matrix_sum=Measure_matrix_sum+Measure_matrix_new_eff(:,:,mm)*Measure_matrix_new_eff(:,:,mm)';
    end
    
%     %%由测量矩阵计算对应的rho
%     rho=zeros(2^numQs,2^numQs,4^numQs);
%     rho1=zeros(2^numQs,2^numQs,4^numQs);
%     rho2=zeros(2^numQs,2^numQs,4^numQs);
%     
%     for ii=1:4^numQs
%         qubit_base_index_rho=transform_index_fun(numQs,ii,4);
%         rho_temp=1;
%         for  jj=1:numQs
%             rho_temp=kron(rho_single(:,:,qubit_base_index_rho(jj)),rho_temp);
%         end
%         rho(:,:,ii)=rho_temp;
%         for jj=1:4^numQs
%             rho1(:,:,ii)=rho1(:,:,ii)+Measure_matrix_new(:,:,jj)*rho(:,:,ii)*Measure_matrix_new(:,:,jj)'*eigenval(jj);
%         end
%         for mm=1:4^numQs
%             for nn=1:4^numQs
%                 rho2(:,:,ii)=rho2(:,:,ii)+Measure_matrix(:,:,mm)*rho(:,:,ii)*Measure_matrix(:,:,nn)*chi(mm,nn);
%             end
%         end
%     end
% %     load('rho_c.mat')
%     
%     %%测量矩阵转变到有物理意义
%     Measure_matrix_sum_part_phisycal=zeros(2^numQs,2^numQs,4^numQs);
%     Measure_matrix_sum_part_phisycal_order_index=zeros(4^numQs,4^numQs);
%     for mm=1:4^numQs
%         if(eigenval(mm)>=0)
%             Measure_matrix_sum_part_phisycal(:,:,mm)=Measure_matrix_new(:,:,mm)'*Measure_matrix_new(:,:,mm)*eigenvalue(mm,mm);
%         else
%             Measure_matrix_sum_part_phisycal(:,:,1)=Measure_matrix_sum_part_phisycal(:,:,1)+Measure_matrix_new(:,:,mm)'*Measure_matrix_new(:,:,mm)*eigenvalue(mm,mm);
%         end
%     end
%     for mm=1:4^numQs
%         Measure_matrix_sum_part_phisycal_order_index(:,mm)=reshape(Measure_matrix_sum_part_phisycal(:,:,mm),4^numQs,1);
%     end
%     
%     e_matrix=zeros(4^numQs,4^numQs);
%     %%测量矩阵转变到chi
    
    
    
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