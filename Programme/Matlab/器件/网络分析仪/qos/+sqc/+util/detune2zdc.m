function zdcShift = detune2zdc(q,detune)
% detune: targetF01 - f01

% Copyright 2017 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com

    if ischar(q)
        q = sqc.util.qName2Obj(q);
    end
    p = q.zdc_amp2f01;
    assert(numel(p)==3 && p(1) ~= 0,'zdc_amp2f01 not a 2-order polynomial')
    p(end) = p(end) - q.f01;
    r = roots(p);
    r = sort(r([isreal(r(1)),isreal(r(2))]));
    if isempty(r) %
        p = q.zdc_amp2f01;
        f01max = polyval(p,roots(polyder(p)));
        if abs(f01max - q.f01) > 5e6
            throw(MException('QOS_detune2dc:illegalzdcamp2f01',...
                sprintf('zdc_amp2f01 setting for qubit %s has no root for f01(%0.2f GHz) and f01 not close to max/min f01(>5Mz), wrong zpls_amp2f01 setting or f01 setting.',...
                q.name, q.f01/1e9)));
        else
%             warning(sprintf('zdc_amp2f01 setting for qubit %s has no root for f01(%0.2f GHz) yet f01 is within 5MHz of max/min f01, assume f01 to be max f01.',...
%                 q.name, q.f01/1e9));
            r = roots(polyder(p));
        end
    end
    [~,idx] = min(abs(r-q.zdc_amp));
    r0 = r(idx);
    
    p = q.zdc_amp2f01;
    p(end) = p(end) - q.f01 - detune;
    r = roots(p);
    r = sort(r([isreal(r(1)),isreal(r(2))]));
    if isempty(r) %
        p = q.zdc_amp2f01;
        f01max = polyval(p,roots(polyder(p)));
        if abs(f01max - q.f01 - detune) > 5e6
            throw(MException('QOS_detune2zpa:illegalzplsamp2f01',...
                sprintf('zdc_amp2f01 setting for qubit %s has no root for f01+detune(%0.2f GHz) and f01+detune not close to max/min f01(>5Mz), wrong zdc_amp2f01 setting or f01 setting.',...
                q.name, (q.f01+detune)/1e9)));
        else
%             warning(sprintf('zdc_amp2f01 setting for qubit %s has no root for f01+detune(%0.2f GHz), yet f01 is within 5MHz of max/min f01, assume f01+detune to be max f01.',...
%                 q.name, (q.f01+detune)/1e9));
            r = roots(polyder(p));
        end
        
    end
    [~,idx] = min(abs(r-r0));
    r = r(idx);
    
    zdcShift = r - r0;

end