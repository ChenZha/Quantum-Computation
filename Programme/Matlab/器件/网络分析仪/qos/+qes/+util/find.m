function idx = find(A,B)
    % find A in cell B, numbers, strings or any objects with an eq methods
    % idx = find(3, {'Hello', 3, anObject, 0});
    
% Copyright 2016 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com

    if isempty(A) || isempty(B)
        idx = [];
        return;
    end
    if ~ischar(A) && numel(A) > 1
        error('A is an array, scalar expected');
    end
    if iscell(A)
        A = A{1};
    end
    if ~iscell(B)
        B_ = cell(1,numel(B));
        for ii = 1:numel(B)
            B_{ii} = B(ii);
        end
        B = B_;
    end
    idx = [];
    if ischar(A)
        for ii  = 1:numel(B)
            try 
                if B{ii} == A % to equal object to its name
                    idx = [idx, ii];
                end
            catch
                if ~ischar(B{ii})
                    continue;
                elseif strcmp(B{ii},A)
                    idx = [idx, ii];
                end
            end
        end
    else
        for ii  = 1:numel(B)
            if B{ii} == A
                idx = [idx, ii];
            end
        end
    end
end