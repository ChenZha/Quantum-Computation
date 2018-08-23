function zpa = detune2zpa(q,detune)
% detune: targetF01 - f01
% assume zplsamp2f01 x offset is not large, otherwise may procduce wroning
% result

% Copyright 2017 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com

    if ischar(q)
        q = sqc.util.qName2Obj(q);
    end
    r0 = -sqc.util.zpa2f01Shift(q);

    p = q.zpls_amp2f01;
    p(end) = p(end) - q.f01 - detune;
    r = roots(p);
    r = sort(r([isreal(r(1)),isreal(r(2))]));
    if isempty(r) %
        p = q.zpls_amp2f01;
        f01max = polyval(p,roots(polyder(p)));
        if abs(f01max - q.f01 - detune) > 5e6
            throw(MException('QOS_detune2zpa:illegalzplsamp2f01',...
                sprintf('zpls_amp2f01 setting for qubit %s has no root for f01+detune(%0.2f GHz) and f01+detune not close to max/min f01(>5Mz), wrong zpls_amp2f01 setting or f01 setting.',...
                q.name, (q.f01+detune)/1e9)));
        else
%             warning(sprintf('zpls_amp2f01 setting for qubit %s has no root for f01+detune(%0.2f GHz), yet f01 is within 5MHz of max/min f01, assume f01+detune to be max f01.',...
%                 q.name, (q.f01+detune)/1e9));
            r = roots(polyder(p));
        end
        
    end
    [~,idx] = min(abs(r));
    r = r(idx);
    
    zpa = r - r0;

end