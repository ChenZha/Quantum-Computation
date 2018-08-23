function chi=processTomoData2Chi(pexp)

%pexp ��һ�� (4^n,3^n,2^n)����
%������ά����̬�ı�ţ�
% rho(:,:,1)�� ��̬�� |q2:0, q1:0>��
% rho(:,:,2)�� ��̬�� |q2:0, q1:1>��
% rho(:,:,3)�� ��̬�� |q2:0, q1:+>��
% rho(:,:,4)�� ��̬�� |q2:0, q1:i>��
% rho(:,:,5)�� ��̬�� |q2:1, q1:0>��
% rho(:,:,6)�� ��̬�� |q2:1, q1:1>��
    
    numQs = round(log(size(pexp,1))/log(4));

    statetomo_rho=zeros(2^numQs,2^numQs,4^numQs);
    for ii=1:4^numQs
        data=reshape(pexp(ii,:,:),3^numQs,2^numQs);
        statetomo_rho(:,:,ii)=sqc.qfcns.stateTomoData2Rho(data);
    end

    %��4^n����ͬ��̬���ܶȾ��󣬲��������ܶȾ�����ֱ����
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
    
    %��4^n��statetomo��ֱ����
    e_rho_order_index=zeros(4^numQs,4^numQs);
    for ii=1:4^numQs
        for jj=1:2^numQs
            for kk=1:2^numQs
                e_rho_order_index(ii,(jj-1)*2^numQs+kk)=statetomo_rho(jj,kk,ii);
            end
        end
    end
    
    %��langbuda������ֱ����
    langbuda=e_rho_order_index/rho_order_index;
    langbuda_order_index=reshape(langbuda.',1,16^numQs);
    
    %��4^n*4^n*4^n�����������ܶȾ��󲢽���ͬm,n�±���ܶȾ�������ֱ�����һ��4^n*4^n����
    %�ҳ���ֱ����ĳ�̬���ܶȾ��󣬻�ö�Ӧm,n�±��bata_m_n
    %������е�4^n*4^n��bata_m_n��������ֱ����
    %����ֱ������bata�������ֱ������langbuda�����ֱ����chi
    %����ֱ����chi����ֱ����õ�������ʽ��chi
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
%�����±�ת�����㷨ʵ�����ƽ���ת����
%order_index������ֱ������
%numQs�����±����
%count_unit�����±����
%qubit_base_index�����±꣨���ڱ��أ�������
   old_index=order_index-1;
   qubit_base_index=NaN(1,numQs);
   for ii=1:numQs
       qubit_base_index(ii)=mod(old_index,count_unit)+1;
       old_index=fix(old_index/count_unit);
   end
end