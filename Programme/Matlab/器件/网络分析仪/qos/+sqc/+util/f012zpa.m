function [zpa,ff01] = f012zpa(qubit,f01)
    if ischar(qubit)
        q = sqc.util.qName2Obj(qubit);
    end

    p = q.zpls_amp2f01;
    f01max=(4*p(1)*p(3)-p(2)^2)/4/p(1);
    f01left=polyval(p,-3.2e4);
    f01right=polyval(p,3.2e4);
    
    if f01right<f01left
        choice=1; % Choose the right band
    else
        choice=0; % Choose the left band
    end
    
    zpa=[];
    ff01=[];
    
    for ii=1:numel(f01)
        ff=f01(ii);
        pp=p;
        pp(3)=pp(3)-ff;
        rr=roots(pp);
        if choice && ~isempty(rr) && isreal(rr)
            zpa=[zpa,max(rr)];
            ff01=[ff01,f01(ii)];
        elseif ~choice && ~isempty(rr) && isreal(rr)
            zpa=[zpa,min(rr)];
            ff01=[ff01,f01(ii)];
        end
    end
    
    locals=find(zpa>3.2e4|zpa<-3.2e4);
    zpa(locals)=[];
    ff01(locals)=[];

end