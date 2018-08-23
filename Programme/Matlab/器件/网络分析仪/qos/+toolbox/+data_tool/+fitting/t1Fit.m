function [T1,T1_err,fitT1_time,fitT1_data]=t1Fit(T1_time,T1_data,fitType)
if nargin<3
    fitType=1;
end
if fitType==1
    f=@(a,x)(0+a(1)*exp(-x/a(2)));
    a=[max(T1_time)-min(T1_time),T1_time(end)/2];
elseif fitType==2
    f=@(a,x)(a(3)+a(1)*exp(-x/a(2)));
    a=[max(T1_time)-min(T1_time),T1_time(end)/2,0];
end
[b,r,J]=nlinfit(T1_time,T1_data,f,a);
[~,se] = toolbox.data_tool.nlparci(b,r,J,0.05);
T1=abs(b(2));
T1_err=se(2);

fitT1_time=linspace(min(T1_time),max(T1_time),1000);
if fitType==1
    fitT1_data=b(1)*exp(-fitT1_time./b(2));
else
    fitT1_data=b(1)*exp(-fitT1_time./b(2))+b(3);
end
end