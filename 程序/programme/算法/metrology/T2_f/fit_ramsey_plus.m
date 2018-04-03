function [f_expect,t2_expect,tf_expect,X_op,FVAL]=fit_ramsey_plus(x,y , beta)
%x 要求是递增等差数据
[w0,f_y0]=FFT_peak(x,y); %w是频率的初始分布
w=w0(1:round(length(w0)/3));  %非线性整流
f_y=f_y0(1:round(length(w0)/3));
pw=abs(f_y)/sum(abs(f_y));%归一化概率
[pw_max,pw_max_index]=max(pw(1:round(length(pw)/2)));
f_expect=w(pw_max_index);

% figure();
% plot(w0,abs(f_y0));
%[pw_max,pw_max_index]=max(pw(1:round(length(pw)/2)));
%detuning=w(pw_max_index);
%分段
T_expect=1/f_expect;
amp=(max(y)-min(y))/2;
y0=(max(y)+min(y))/2;
y_section=zeros(fix(x(end)/T_expect)+1,fix(T_expect/(x(2)-x(1)))+1);
n_section=1;
n_section_index=1;
change_protect=fix(T_expect/(x(2)-x(1))/2);%半周期
n_change_protect=change_protect+1;
isselect=true;
check_close=false;
isbreak=false;
f_expect_sign=1;
for ii=1:length(y)
    n_change_protect=n_change_protect+1;
    if(n_change_protect>2*change_protect)
        if(isbreak)
            break;%确保不跳周期取点
        else
            n_change_protect=0;
            isbreak=true;
            f_expect_sign=-1;
        end
    end
    if(n_change_protect>change_protect)
        isselect=true;
    end
    if(y(ii)>(y0+0.25*amp)&&isselect) 
        y_section(n_section,n_section_index)=y(ii);
        check_close=true;
        n_section_index=n_section_index+1;
        n_change_protect=0;
        isbreak=true;
    end
    if(y(ii)<=(y0+0.25*amp)&&check_close)
        t2_fit(n_section)=log(max(y_section(n_section,:))-y0);
        n_section=n_section+1;
        n_section_index=1;
        isselect=false;
        check_close=false;
    end
end
if(exist('t2_fit','var'))
    t2_fit_length=length(t2_fit);
    t2_fit_mean=mean(t2_fit);
    k_t2=0;
    temp=0;
    for ii=1:t2_fit_length
       k_t2=k_t2+ii*t2_fit(ii);%-(1+t2_fit_length)/2*mean(t2_fit);
       temp=temp+ii^2;
    end
    k_t2=k_t2-sum(1:t2_fit_length)*t2_fit_mean;
    temp=temp-t2_fit_length*((1+t2_fit_length)/2)^2;
    t2_expect=-T_expect/(k_t2/temp);
else
    t2_expect=T_expect;
end
%figure();
%plot(w,pw,'k');
% hold on;
% plot((1:length(f_y))*(f_x(2)-f_x(1)),imag(f_y),'g');
% plot((1:length(f_y))*(f_x(2)-f_x(1)),abs(f_y),'k');
%fit
t2_expect = beta(1);
tf_expect = beta(2);
fminsearch_ramsey_set=@(para)fminsearch_ramsey(para,x,y);
options = optimset('TolFun',0,'Tolx',0,'MaxIter',5000,'MaxFunEvals',50000,'Display','off');
[X_op,FVAL,EXITFLAG,OUTPUT] = fminsearch(fminsearch_ramsey_set,[f_expect_sign*f_expect,t2_expect,tf_expect,0,amp,y0],options);

%画图
f_expect=X_op(1);
t2_expect=X_op(2);
tf_expect=X_op(3);
phi0=X_op(4);
amp=X_op(5);
y0=X_op(6);
x_data=x;
y_fit=y0+amp*sin(2*pi*f_expect*x_data+phi0).*exp(-x_data/t2_expect-(x_data/tf_expect).^2);
% figure();
% plot(x/2000,y,'*');
% hold on;
% plot(x/2000,y_fit,'g');
% title(['f=',num2str(f_expect*2000),'MHz,T2*=',num2str(t2_expect/2000),'us,Tf*=',num2str(tf_expect/2000),'us']);
% xlabel('T(us)');
% ylabel('P(1)');
%输出
t2_expect=t2_expect/2000;
tf_expect = tf_expect/2000;
f_expect=f_expect*2000;
end

function [f_x,f_y]=FFT_peak(x,y)
%t change into w
data_length=length(y);
f_y=zeros(1,data_length);
for kk=1:data_length
    for jj=1:data_length
        f_y(kk)=f_y(kk)+y(jj)*exp(2*pi*1i*jj*kk/data_length);   %jj represent t, and 1/n_th*kk/data_length represent w
    end
    f_y(kk)=f_y(kk)/sqrt(data_length);
end
f_x=(1:data_length)/(x(2)-x(1))/data_length;
end

function delta=fminsearch_ramsey(para,x_data,y_data)
f_expect=para(1);
t2_expect=para(2);
tf_expect=para(3);
phi0=para(4);
amp=para(5);
y0=para(6);
y_fit=y0+amp*sin(2*pi*f_expect*x_data+phi0).*exp(-x_data/t2_expect-(x_data/tf_expect).^2);
delta=norm(y_data-y_fit);
end