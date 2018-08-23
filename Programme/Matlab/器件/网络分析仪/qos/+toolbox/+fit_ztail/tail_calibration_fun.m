function y_tail=tail_calibration_fun(x_tail,cali_para)  %ÍÏÎ²²âÁ¿ÏìÓ¦
    if(length(x_tail)>1)
        nn=length(x_tail);
        y_tail=zeros(1,nn);
        for ii=1:nn
            y_tail(ii)=toolbox.fit_ztail.tail_calibration_fun(x_tail(ii),cali_para);
        end
    else
        y_tail=0;
        delay=-cali_para.X2_Ln/2;
        Z_Ln=cali_para.Z_Ln;
        integral_phase_time_eff=cali_para.integral_phase_time+cali_para.X2_Ln;
        decay_para_handle=cali_para.decay_para_handle;
        df01_per_count=cali_para.df01_per_count;
        z_amp=cali_para.z_amp;
        k=z_amp/20000;
        x_tail=x_tail+delay;
        HMN=1;%half mean num
        for ii=1:length(decay_para_handle)
            A1=decay_para_handle{ii}(1);
            A2=decay_para_handle{ii}(2);
    %         y_tail=real(...
    %                A1*exp(A2*x_tail)/(-exp(integral_phase_time_eff*A2)+1)*A2/(exp(HMN*A2)-exp(-HMN*A2))*A2*2*HMN/(1-exp(Z_Ln*A2)) ...
    %               +B1*exp(B2*x_tail)/(-exp(integral_phase_time_eff*B2)+1)*B2/(exp(HMN*B2)-exp(-HMN*B2))*B2*2*HMN/(1-exp(Z_Ln*B2)) ...
    %               +C1*exp(C2*x_tail)/(-exp(integral_phase_time_eff*C2)+1)*C2/(exp(HMN*C2)-exp(-HMN*C2))*C2*2*HMN/(1-exp(Z_Ln*C2)) ...
    %               +D1*exp(D2*x_tail)/(-exp(integral_phase_time_eff*D2)+1)*D2/(exp(HMN*D2)-exp(-HMN*D2))*D2*2*HMN/(1-exp(Z_Ln*D2)) ...
    %               +E1*exp(E2*x_tail)/(-exp(integral_phase_time_eff*E2)+1)*E2/(exp(HMN*E2)-exp(-HMN*E2))*D2*2*HMN/(1-exp(Z_Ln*E2)) ...
    %               )/(2*pi)*2000/df01_per_count;
            y_tail=y_tail+real( A1*exp(A2*x_tail)/(-exp(integral_phase_time_eff*A2)+1)*A2/(exp(HMN*A2)-exp(-HMN*A2))*A2*2*HMN/(1-exp(Z_Ln*A2)) )/(2*pi)*2000/df01_per_count/k;  
        end
    end
end