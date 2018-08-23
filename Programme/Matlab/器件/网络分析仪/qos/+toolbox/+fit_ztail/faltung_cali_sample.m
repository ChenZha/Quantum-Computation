function WaveData=faltung_cali_sample(CZ_single_WaveData0,ztail)
    CZ_single_WaveData0=double(CZ_single_WaveData0)-32768;
    nn_In=length(CZ_single_WaveData0);
    cali_length=length(ztail);
    if(nn_In<=cali_length)
        CZ_single_WaveData0(nn_In:cali_length+1)=0;
    end
    mark_amp=20000;
    Waveform_ln=cali_length;
    CZ_single_WaveData0=CZ_single_WaveData0(1:Waveform_ln+1);
    dCZ_single_WaveData0=zeros(1,cali_length);
    for ii=1:Waveform_ln-1 %之后是0的部分不参与计算
        dCZ_single_WaveData0(ii)=CZ_single_WaveData0(ii+1)-CZ_single_WaveData0(ii);
    end
    %方波化
    [~,rise_index]=max(dCZ_single_WaveData0);
    [~,fall_index]=min(dCZ_single_WaveData0);
    dCZ_single_WaveData0=zeros(1,cali_length+1);
    zpa_amp=max(abs(CZ_single_WaveData0));
    dCZ_single_WaveData0(rise_index)=zpa_amp;
    dCZ_single_WaveData0(fall_index)=-zpa_amp;
    CZ_single_WaveData0=zeros(1,cali_length+1);
    if(fall_index>rise_index)
        CZ_single_WaveData0((rise_index+1):fall_index)=zpa_amp;
    else
        CZ_single_WaveData0((fall_index+1):rise_index)=-zpa_amp;
    end
    %
    y_tail=ztail;
    y_star1=zeros(1,cali_length+1);
    dy_star1=zeros(1,cali_length+1);
    for ii=1:cali_length+1
        for jj=1:ii-1
            y_star1(ii)=y_star1(ii)+dCZ_single_WaveData0(ii-jj)*y_tail(jj)/mark_amp;
        end
        if(ii>2)
            dy_star1(ii-1)=y_star1(ii)-y_star1(ii-1);
        end
    end
    y_star2=zeros(1,cali_length+1);
    for ii=1:cali_length+1
        for jj=1:ii-1
            y_star2(ii)=y_star2(ii)+dy_star1(ii-jj)*y_tail(jj)/mark_amp;
        end
    end

    %非对称向响应
    y_star_fall=zeros(1,cali_length+1);
%     y_offset=74/30000*abs(fall_index-rise_index);
%     y_th=-10000;
%     for ii=1:cali_length+1
%         for jj=1:ii-1
%             if(dCZ_single_WaveData0(ii-jj)<y_th)
%                 y_star_fall(ii)=y_star_fall(ii)+dCZ_single_WaveData0(ii-jj)*y_offset/mark_amp;
%             end
%         end
%     end
    %上升沿修正
%     k_amp=1.2;
%     CZ_single_WaveData0(rise_index+1)=k_amp*CZ_single_WaveData0(rise_index+1);
    
    
    WaveData=uint16(CZ_single_WaveData0+y_star1+y_star2+y_star_fall+32768);
    WaveData(end)=[];
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
end