function data = numericCell2Mat(data)
% if data is a cell array of all numerics, convert to matrix, otherwise no
% change:
% converts {1,2,3} to [1,2,3]
% {1, 'a', someHandle}, no change 

% Copyright 2017 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com

    if ~iscell(data)
        return;
    end
    allNumeric = true;
    for ii = 1:numel(data)
        if ~isnumeric(data{ii}) || isempty(data{ii})
            allNumeric = false;
            break;
        end
    end
    if allNumeric
        data = cell2mat(data);
    end
end