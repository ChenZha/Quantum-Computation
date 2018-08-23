function [best_fx,best_x,fx_all,fv_all,x_all,v_all,n_generation]=Differential_Evolution_RandWalk(function_handle,x_l,x_u,tolX,tolY,para,max_generation,population)
    n_dim=length(x_l);
    best_fx=zeros(max_generation,2);
    fx_all=zeros(max_generation,population,2);
    fv_all=zeros(max_generation,population,2);
    best_x=zeros(max_generation,n_dim);
    x_all=zeros(max_generation,population,n_dim);
    v_all=zeros(max_generation,population,n_dim);
    n_generation=1;
    F=para(1);
    CR=para(2);
    %DE �㷨��ʼ��
    rand_index=rand(population,n_dim);
    for m=1:population
        for n=1:n_dim
            v_all(n_generation,m,n)=x_l(n)+rand_index(m,n)*(x_u(n)-x_l(n)); 
        end
    end
    x_all(n_generation,:,:)=v_all(n_generation,:,:);
    for m=1:population
        v_temp=reshape(v_all(n_generation,m,:),1,n_dim);
        [f_value,delta]=feval ( function_handle,  v_temp);
        fv_all(n_generation,m,1)=f_value;
        fv_all(n_generation,m,2)=delta;
    end
    fx_all(n_generation,:,:)=fv_all(n_generation,:,:);
    [~,best_index]=min(fx_all(n_generation,:,1));
    best_x(n_generation,:)=x_all(n_generation,best_index,:);
    best_fx(n_generation,:)=fx_all(n_generation,best_index,:);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%��ʼ����
    for n_generation=2:max_generation
        %�������
        for m=1:population  
                r1=randi([1,population]);  
            while(r1==m)  
                r1=randi([1,population]);  
            end  
            r2=randi([1,population]);  
            while(r2==m)||(r2==r1)  
                r2=randi([1,population]);  
            end  
            r3=randi([1,population]);  
            while((r3==m)||(r3==r1)||(r3==r2))  
                r3=randi([1,population],1,1);  
            end
            v_all(n_generation,m,:)=x_all(n_generation-1,r1,:)+rand(1)*F*(x_all(n_generation-1,r2,:)-x_all(n_generation-1,r3,:));
        end 
        %�������  
        
        for m=1:population
            r_CR=randi([1,population]);  %ȷ����һ������
            for n=1:n_dim
                cr=rand(1);  
                if(cr<CR)||(n==r_CR)  %����Ⱦɫ�彻���ĸ�����CR
                    %�޲���
                else  
                    v_all(n_generation,m,n)=x_all(n_generation-1,m,n);
                end  
            end
        end
        %�߽���������  
        %�߽�����  
        for m=1:population 
            for n=1:n_dim  
                if v_all(n_generation,m,n)>x_u(n)  
                    v_all(n_generation,m,n)=x_u(n);  
                end  
                if v_all(n_generation,m,n)<x_l(n)  
                    v_all(n_generation,m,n)=x_u(n);  
                end  
            end  
        end
        %��ֵ����
        for m=1:population
            v_temp=reshape(v_all(n_generation,m,:),1,n_dim);
            [f_value,delta]=feval ( function_handle,  v_temp);
            fv_all(n_generation,m,1)=f_value;
            fv_all(n_generation,m,2)=delta;
        end
        %��̭����
        for m=1:population
            is_v_smaller=rand_compara(fv_all(n_generation,m,1),fx_all(n_generation-1,m,1),fv_all(n_generation,m,2),fx_all(n_generation-1,m,2));
            if(is_v_smaller)
                x_all(n_generation,m,:)=v_all(n_generation,m,:);
                fx_all(n_generation,m,:)=fv_all(n_generation,m,:);
            else
                x_all(n_generation,m,:)=x_all(n_generation-1,m,:);
                fx_all(n_generation,m,:)=fx_all(n_generation-1,m,:);
            end
        end
        [~,best_index]=min(fx_all(n_generation,:,1));
        best_x(n_generation,:)=x_all(n_generation,best_index,:);
        best_fx(n_generation,:)=fx_all(n_generation,best_index,:);
        %�ж�����
        converged_Y=1;%Ĭ��ֵ
        if(length(tolY==1))
            tolY(2)=0;
        end
        if(tolY(2)==0)  %tolY(2)��ѡ�������жϵ����ͣ�0������жϣ�1ʱ�����ж�
            if((max(fx_all(n_generation,:,1))-best_fx(n_generation,1))>tolY(1))
                converged_Y=0;
            end
        else
            if(best_fx(n_generation,1)>tolY(1))
                converged_Y=0;
            end
        end
        converged_X=1;%Ĭ��ֵ
        for n=1:n_dim
            if(max(x_all(n_generation,:,n))-min(x_all(n_generation,:,n))>tolX(n))
                converged_X=0;
                break;
            end
        end
        converged=converged_X||converged_Y;
        if(converged)
            if(converged_X)
            	fprintf('Differential Evolution X converged\n');
            end
            if(converged_Y)
                fprintf('Differential Evolution Y converged\n');
            end
            break;
        end
        if(0)%���ڻ�ͼ�ʹ洢
            figure_plot_nn=ceil(sqrt(2*n_dim+2));
            figure(605);
            for n=1:n_dim
                subplot(figure_plot_nn,figure_plot_nn,n);
                cla;
                hold on;
                for m=1:population 
                    plot(1:n_generation,x_all(1:n_generation,m,n));
                    xlabel('generation');
                    ylabel(['x(',num2str(n),')'])
                end
                subplot(figure_plot_nn,figure_plot_nn,n+n_dim);
                cla;
                hold on;
                for m=1:population 
                    plot(1:n_generation,v_all(1:n_generation,m,n));
                    xlabel('generation');
                    ylabel(['v(',num2str(n),')'])
                end
            end
            subplot(figure_plot_nn,figure_plot_nn,2*n_dim+1);
            cla;
            hold on;
            for m=1:population
                errorbar(1:n_generation,fx_all(1:n_generation,m,1),fx_all(1:n_generation,m,2));
                xlabel('generation');
                ylabel('fx');
            end
            subplot(figure_plot_nn,figure_plot_nn,2*n_dim+2);
            cla;
            hold on;
            errorbar(1:n_generation,best_fx(1:n_generation,1),best_fx(1:n_generation,2));
            xlabel('generation');
            ylabel('best fx')
            drawnow;
            pause(0.1);
        end
        if(1)
            figure(200);
            cla;
            hold on;
            errorbar(1:n_generation,best_fx(1:n_generation,1),best_fx(1:n_generation,2));
            xlabel('generation');
            ylabel('best fx')
            drawnow;
        end
    end
    
    if(n_generation==max_generation)
        fprintf('Differential Evolution Max n_generation reached\n');
    end
end

function [is_val1_smaller]=rand_compara(val1,val2,delta1,delta2)
    %�Ƚ�������������������val1��val2ʱ����ֵ��delta1��delta2�Ƕ�Ӧ�Ĳ���ƫ�
    %��������ģ���Ǹ�˹����
    delta_eff=sqrt(delta1^2+delta2^2);
    if(delta_eff<=0)
        is_val1_smaller=val1<val2;
    else
        P=(erf((val2-val1)/delta_eff/sqrt(2))+1)/2;
        is_val1_smaller=(rand()<P);
    end
end