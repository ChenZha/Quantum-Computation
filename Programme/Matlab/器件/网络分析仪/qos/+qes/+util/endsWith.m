function bol = endsWith(str,pattern)
    %

% Copyright 2016 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com
    
    bol = false;
    lp = numel(pattern);
    if lp == 0 || (length(str) >= lp && all(str(end-lp+1:end) == pattern))
        bol = true;
    end

end