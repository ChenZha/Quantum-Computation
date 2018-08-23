function data = loadJson(fullfilename)
% Copyright 2016 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com

    c = {};
    fid  = fopen(fullfilename,'r');
    while ~feof(fid)
        try
            c{end+1} = fgetl(fid);
        catch ME
            fclose(fid);
            rethrow(ME);
        end
    end
    fclose(fid);
    if isempty(c) || numel(c{1}) == 1 && c{1} < 0
        data = [];
        return;
        % throw(MException('QOS_loadJson:emptyFile','empty json file.'));
    end
    n = numel(c);
    str = '';
    for ii = 1:n
        idx = strfind(c{ii},'//');
        if ~isempty(idx)
            c{ii}(idx:end) = [];
        end
        c{ii}(c{ii}==10 & c{ii}==13) = [];
        str = [str,c{ii}];
    end
    try
        [data, ~] = qes.util.parseJson(str);
    catch ME
        throw(MException('QOS_loadJson:parseError',[strrep(fullfilename,'\','\\'), ': ', ME.message]));
    end
end