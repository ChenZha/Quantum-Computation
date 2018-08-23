ii=2;

s = struct();
s.type = 'function';
s.funcName = 'qes.waveform.xfrFunc.gaussianExp';
s.bandWidht = 0.25;
q = qubits{ii};
s.r=[0];
s.td=[100];

xfrFunc = qes.util.xfrFuncBuilder(s);
xfrFunc_inv = xfrFunc.inv();
xfrFunc_lp = com.qos.waveform.XfrFuncFastGaussianFilter(0.13);
xfrFunc_f = xfrFunc_lp.add(xfrFunc_inv);

time=[1:10:20000];    % delay time
cali_para=struct();
cali_para.X2_Ln=sqc.util.getQSettings('g_XY2_ln');
cali_para.Z_Ln=30000;
cali_para.integral_phase_time=1000;
cali_para.z_amp=30000;

data_phase=toolbox.fit_ztail.zPulseRingingPhase1('qubit',q,'delayTime',time,'Z_ln',cali_para.Z_Ln,...
    'xfrFunc',[],'zAmp',cali_para.z_amp,'s',s,'integral_phase_time',cali_para.integral_phase_time,...
    'notes','','gui',true,'save',true);

close all;
chnl=sqc.util.getQSettings('channels.z_pulse.chnl');
tail0=unwrap(data_phase(1,:)-data_phase(2,:))+6*pi;    % blach line
figure();plot(time,tail0);

p=sqc.util.getQSettings('zpls_amp2f01');
cali_para.df01_per_count=p(2)/1e6; %MHz/Vcode
xtail=1:20000;
%%
tail=tail0;
op_final_y=1;
op_final_x=[];
nn_try=0;
nn=length(tail0);
phase_error=std(tail0((nn-100):nn));
decay_para_handle={};
while((op_final_y>1.5*phase_error) && (nn_try<5))
    nn_try=nn_try+1;
    function_handle=@(x)toolbox.fit_ztail.fit_tail(x,time,tail);
    
    max_tail=max(tail)-min(tail);
    x_l=[-max_tail/2    5,         -max_tail/2   1000,      -max_tail/2           5         10        0,         -max_tail/2       1000         1000         0];
    x_u=[max_tail       1000,    max_tail       30000,      max_tail           1000       1000     2*pi,         max_tail          30000       30000      2*pi];
    [best_fx,best_x,fx_all,fv_all,x_all,v_all,n_generation]=toolbox.fit_ztail.Differential_Evolution_RandWalk(function_handle,x_l,x_u,0,0,[0.9,0.5],500,30);
    
    x0=best_x(end,:);
    x_delta=reshape(std(x_all(end,:,:)),1,length(x_l));
    x0=[x0;x0+diag(x_delta)];
    [ x_opt, x_trace, y_trace, n_feval] = toolbox.fit_ztail.NelderMead_RandWalk (function_handle, x0,0, 0, 1000);
    
    op_final_y=y_trace(end);
    [~,~,tail_new]=toolbox.fit_ztail.fit_tail(x_opt,time,tail);
    tail=tail-tail_new;
    op_final_x=[op_final_x,x_opt];
    
    figure();
    hold on;
    grid on;
    plot(time,tail,'k.');
    plot(time,tail_new+tail,'b.');
    plot(time,tail_new,'r','LineWidth',3);
    decay_para_handle{4*nn_try-3}=[op_final_x(1),-1/op_final_x(2)];
    decay_para_handle{4*nn_try-2}=[op_final_x(3),-1/op_final_x(4)];
    decay_para_handle{4*nn_try-1}=[op_final_x(5)*exp(2*pi*1i*op_final_x(8)),-1/op_final_x(6)+2*pi*1i/op_final_x(7)];
    decay_para_handle{4*nn_try}=[op_final_x(9)*exp(2*pi*1i*op_final_x(12)),-1/op_final_x(10)+2*pi*1i/op_final_x(11)];
    
end
%%
[y,delta,fit_final]=toolbox.fit_ztail.fit_tail(op_final_x,time,tail);
figure();
hold on;
grid on;
plot(time,tail0);
plot(time,fit_final,'r.','LineWidth',2)
figure();
hold on;
grid on;
time_out=[-50:0,time];
[y,delta,fit_final_out]=toolbox.fit_ztail.fit_tail(op_final_x,time_out);
plot(time,tail0);
plot(time_out,fit_final_out,'r.','LineWidth',2)
%%
cali_para.decay_para_handle=decay_para_handle;
ztail=toolbox.fit_ztail.tail_calibration_fun(xtail,cali_para);
figure();
plot(xtail,ztail);
save(['E:\settings\hardware\zchnl\chnl',num2str(chnl)],'ztail');


