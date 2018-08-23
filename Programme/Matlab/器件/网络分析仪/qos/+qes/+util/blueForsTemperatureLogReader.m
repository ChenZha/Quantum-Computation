function [Temperature, Time] = blueForsTemperatureLogReader(logRootDir,Chnl)
% reads the latest temperature log on the specified channel:
% [Tmc, Time] = qes.util.blueForsTemperatureLogReader('Z:\newton\bluefors\log',6)

% Copyright 2017 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    dateStr = datestr(now,'yy-mm-dd');
    filename = fullfile(logRootDir,dateStr,['CH',num2str(Chnl,'%0.0f'),' T ',dateStr,'.log']);
    if ~exist(filename,'file')
        warning(['log file: ',filename,' not found.']);
        Temperature = NaN;
        Time = NaN;
        return;
    end
    try
        fid = fopen(filename,'r');
        while 1
            line = fgetl(fid);
            if ~ischar(line)
                break;
            end
            lastLine = line;
        end
        fclose(fid);
    catch ME
        warning(getReport(ME,'basic','hyperlinks','off'));
        Temperature = NaN;
        try
            fclose(fid);
        catch
        end
        return;
    end
    if isempty(lastLine)
        Temperature = NaN;
        return;
    end
    parts = strsplit(lastLine,',');
    if numel(parts) ~= 3
        warning(['unrecognized log file content: ',lastLine]);
        Temperature = NaN;
        Time = NaN;
        return;
    end
    try
        Time = datenum(strtrim([parts{1},' ', parts{2}]),'yyyy-mm-dd HH:MM:SS');
        Temperature = str2double(parts{end});
    catch ME
        warning(getReport(ME,'basic','hyperlinks','off'));
        Temperature = NaN;
        return;
    end

end