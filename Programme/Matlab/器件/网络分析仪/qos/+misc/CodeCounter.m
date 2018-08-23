function NumLines = CodeCounter(DirName,CodeFileSurfix)
    [FilePaths,  FileNames]= GetAllFiles(DirName);
    NFiles = numel(FilePaths);
    ln_s  = length(CodeFileSurfix);
    NumLines = 0;
    NumClasses = 0;
    NumFcns = 0;
    for ii = 1:NFiles
        if length(FileNames{ii}) < ln_s || ~strcmp(FileNames{ii}(end-ln_s+1:end),CodeFileSurfix)
            continue;
        end
        fid = fopen(fullfile(FilePaths{ii},FileNames{ii}),'r');
        while ~feof(fid)
            [~] = fgetl(fid);
            NumLines = NumLines+1;
        end
        fclose(fid);
    end
end

function [FilePaths,  FileNames]= GetAllFiles(DirName)
    % List all files within a folder, subfolders included.

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    DirData = dir(DirName);      % Get the data for the current directory
    DirIndex = [DirData.isdir];  % Find the index for directories
    FileNames = {DirData(~DirIndex).name}';  % Get a list of the files
    NumFiles = length(FileNames);
    FilePaths = cell(NumFiles,1);
    for ii = 1:NumFiles
        FilePaths{ii} = DirName;
    end
    FullFileNames = [];
    if ~isempty(FileNames)
        FullFileNames = cellfun(@(x) fullfile(DirName,x),...  % Prepend path to files
                           FileNames,'UniformOutput',false);
    end
    SubDirs = {DirData(DirIndex).name};  % Get a list of the subdirectories
    ValidIndex = ~ismember(SubDirs,{'.','..'});  % Find index of subdirectories
                                               % that are not '.' or '..'
    for iDir = find(ValidIndex)                  % Loop over valid subdirectories
        NextDir = fullfile(DirName,SubDirs{iDir});    % Get the subdirectory path
        [FilePaths_,  FileNames_] = GetAllFiles(NextDir);
        FilePaths = [FilePaths; FilePaths_];  % Recursively call GetAllFiles
        FileNames = [FileNames; FileNames_];
    end
end