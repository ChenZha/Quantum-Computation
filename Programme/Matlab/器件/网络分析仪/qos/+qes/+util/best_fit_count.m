function  total_point = best_fit_count(fre)
%SETDACFREQUENCY 在2G采样率和最大波形深度为32768条件下生成给定频率波形
% 在固定采样率和有限长波形条件下生成一个频率误差最小的波形

sample_rate = 2e9;
if(fre < sample_rate/32768)
    total_point  = 32;
    return;
end
    
period_point = 1/fre*sample_rate;
err = ones(1,floor(32768/period_point));
for k = 1:floor(32768/period_point)
    total_point = floor((floor(k * period_point)/8))*8;
    err(k) = abs(k*period_point - total_point);
end
index = find(err == min(err));
total_point = floor(index(1) * period_point);
end

