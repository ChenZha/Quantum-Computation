function vout = upsample_c(vin,n)
	% upsample by fast linear interpolation, second dimension taken as time
	% axis
    % note: MATLAB upsample just insert zeros
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    if n == 1
        vout = vin;
        return;
    end
	d = diff([vin,vin(:,end)],1,2)/n;
    vout = zeros(size(vin,1),n*size(vin,2));
    for ii = 1:size(vin,2)
        for jj = 1:n
            vout(:,n*(ii-1)+jj) = vin(:,ii)+(jj-1)*d(:,ii);
        end
    end

end