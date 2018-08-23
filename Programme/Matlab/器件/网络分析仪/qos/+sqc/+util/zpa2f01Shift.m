function xShift = zpa2f01Shift(q)
% the zpls_amp2f01 in the registry is correct up to a x shift, zpa2f01XShift calculates this shift
% assumes zplsamp2f01 the x shift is not large
% xShift: position of actual zpa2f01 - position of zpa2f01 in registry

% Copyright 2018 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com

    if ischar(q)
        q = sqc.util.qName2Obj(q);
    end
    p = q.zpls_amp2f01;
    f01max = polyval(p,roots(polyder(p)));
    assert(numel(p)==3 && p(1) ~= 0,'zpls_amp2f01 not a 2-order polynomial')
    p(end) = p(end) - q.f01;
    r = roots(p);
    r = sort(r([isreal(r(1)),isreal(r(2))]));
    if isempty(r) %
        if abs(f01max - q.f01) > 5e6
            throw(MException('QOS_detune2zpa:invalidzplsamp2f01',...
                sprintf('zpls_amp2f01 setting for qubit %s has no root for f01(%0.2f GHz) and f01 not close to max/min f01(>5Mz), wrong zpls_amp2f01 setting or f01 setting.',...
                q.name, q.f01/1e9)));
        else
%             warning(sprintf('zpls_amp2f01 setting for qubit %s has no root for f01(%0.2f GHz) yet f01 is within 5MHz of max/min f01, assume f01 to be max f01.',...
%                 q.name, q.f01/1e9));
            r = roots(polyder(p));
        end
    end
    ar = abs(r);
    % assume zplsamp2f01 x shift is not large
    if f01max - q.f01 >5e6 && r(1)*r(2) < 0 && abs(ar(1)-ar(2))/(ar(1)+ar(2)) < 0.33
        throw(MException('QOS_detune2zpa:invalidzplsamp2f01',...
                sprintf('zpls_amp2f01 setting for qubit %s needs to be updated.',q.name)));
    end
    [~,idx] = min(abs(r));
    xShift = -r(idx);
    
end