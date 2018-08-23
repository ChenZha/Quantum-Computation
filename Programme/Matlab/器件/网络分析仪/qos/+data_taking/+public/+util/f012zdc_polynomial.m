function [zdc, slop] = f012zdc(q, f01)
% calculates z dc bias amp from f01, polynomial fit
% if f01 not given, finds the symmetric point(zdc where f01 is maximum)
    
    % Yulin Wu, 2017/3/9

	if range(q.zdc_amp2f01ValidRng) < 20*q.zdc_ampCorrection
		% zdc_ampCorrection is only intended to be a small calibration, in practice, zdc_ampCorrection
		% might grow too large due to accumulated drift, in such case, zdc_amp2f01 needs to be remeasured.
		throw(MException('QOS_setF01:tooMuchDrift',...
                sprintf('%s: zdc_ampCorrection too large, zdc_amp2f01 needs to be updated.', q.name)));
	end
	zdc_amp2f01 = q.zdc_amp2f01;
	zdc_amp2f01_driv = polyder(zdc_amp2f01);
    if nargin < 2 || isempty(01) % optimal point
        r = roots(zdc_amp2f01_driv);
        r = sort(r(isreal(r)));
        r = r(r>=q.zdc_amp2f01ValidRng(1) & r<=q.zdc_amp2f01ValidRng(2));
        if isempty(r)
            throw(MException('QOS_f012zdc:badSettings',...
                sprintf('domain of definition''zdc_amp2f01ValidRng'' of zdc_amp2f01 for qubit %s dose not cover the optimal point.', q.name)));
        elseif length(r) > 1
            throw(MException('QOS_f012zdc:badSettings',...
                sprintf('zdc_amp2f01 for qubit %s has more than one extrema in its domain of definition, thus not a valid fit for xmon f01 spectrum.', q.name)));
        end
		[d,idx] = max(abs(q.zdc_amp2f01ValidRng-r(1)));
		slop = zdc_amp2f01_driv(r(1)+sign(idx-1.5)*d/5);
    else
        zdc_amp2f01(end) = zdc_amp2f01(end) - f01/q.zdc_amp2f_freqUnit;
        r = roots(zdc_amp2f01_);
        r = sort(r(isreal(r)));
        r = r(r>=q.zdc_amp2f01ValidRng(1) & r<=q.zdc_amp2f01ValidRng(2));
        if isempty(r)
            throw(MException('QOS_f012zdc:badSettings',...
                sprintf('zdc_amp2f01 setting for qubit %s has no root for %0.3e Hz', q.name,...
                args.f01/q.zdc_amp2f_freqUnit)));
        elseif length(r) > 1
            throw(MException('QOS_f012zdc:badSettings',...
                sprintf('zdc_amp2f01 for qubit %s has more than one extrema in its domain of definition, thus not a valid fit for xmon f01 spectrum.', q.name)));
        end
		slop = zdc_amp2f01_driv(r(1));
    end
    zdc = (r(1)+q.zdc_ampCorrection)*q.zdc_amp2f_dcUnit;
end