function  total_point = best_fit_count(fre)
%SETDACFREQUENCY ��2G�����ʺ���������Ϊ32768���������ɸ���Ƶ�ʲ���
% �ڹ̶������ʺ����޳���������������һ��Ƶ�������С�Ĳ���

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

