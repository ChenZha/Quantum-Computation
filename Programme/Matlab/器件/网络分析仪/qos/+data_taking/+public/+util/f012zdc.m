function [zdc, slop] = f012zdc(q, f01)
% calculates z dc bias amp from f01
% if f01 not given, finds the symmetric point(zdc where f01 is maximum)
    
    % Yulin Wu, 2017/3/9

	if numel(q.zdc_amp2f01) ~= 4
		throw(MException('QOS_setF01:illegaleAmp2f01Func',...
                sprintf('%s: illegale zdc_amp2f01, zdc_amp2f01 should be a parameter array: [M, offset, fmax, fc]', q.name)));
	end
	M = q.zdc_amp2f01(1);
	offset = q.zdc_amp2f01(2);
	fmax = q.zdc_amp2f01(3);
	fc = q.zdc_amp2f01(4);
    if nargin < 2 || isempty(01) % optimal point
        r = offset;
		slop = 0;
    else
		if f01 <= fmax
			t = ((f01+fc)/(fc+fmax))^2;
			r = [offset - M*acos(t)/pi, offset + M*acos(t)/pi];
			slop = -pi*M*(fmax+fc)/2./sqrt(cos(pi*M*(r-offset))).*sin(pi*M*(r-offset));
		elseif f01-fmax < 1e6
			r = offset;
			slop = 0;
		else
			throw(MException('QOS_setF01:f01OutOfRange',...
                sprintf('%s: f01 greater than maximum %0.4fMHz.', q.name, fmax/1e9)));
		end
    end
    zdc = r+q.zdc_ampCorrection;
end