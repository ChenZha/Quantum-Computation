function [y,delta,fit_final]=fit_tail(xs,time,tail)
    n_para=12;
    nn=round(length(xs)/n_para);
    fit_final=zeros(1,length(time));
    x0=cell(1,nn);
    for ii=1:nn
        select=linspace(n_para*(ii-1)+1,n_para*ii,n_para);
        x0{ii}=xs(select);
        fit_final=fit_final+fit_tail_single(x0{ii},time);
    end
    if(nargin<3)
        delta=0;
        y=0;
    else
        y=mean((fit_final-tail).^4)^(1/4);
        delta=0;
    end
end

function fit_tail=fit_tail_single(x,time)
%     nn=length(tail);
%     delta=std(tail((nn-500):nn));
    fit_tail=x(1)*exp(-time/x(2))+x(3)*exp(-time/x(4))+x(5)*exp(-time/x(6)).*cos(2*pi*time/x(7)+x(8))+x(9)*exp(-time/x(10)).*cos(2*pi*time/x(11)+x(12));
    %y=mean((fit_tail-tail).^4)^(1/4);
    
end