function [FilePaths,  FileNames]= allFiles(DirName)
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
%     FullFileNames = [];
%     if ~isempty(FileNames)
%         FullFileNames = cellfun(@(x) fullfile(DirName,x),...  % Prepend path to files
%                            FileNames,'UniformOutput',false);
%     end
    SubDirs = {DirData(DirIndex).name};  % Get a list of the subdirectories
    ValidIndex = ~ismember(SubDirs,{'.','..'});  % Find index of subdirectories
                                               % that are not '.' or '..'
    for iDir = find(ValidIndex)                  % Loop over valid subdirectories
        NextDir = fullfile(DirName,SubDirs{iDir});    % Get the subdirectory path
        [FilePaths_,  FileNames_] = qes.util.allFiles(NextDir); % Recursively call GetAllFiles
        FilePaths = [FilePaths; FilePaths_];  
        FileNames = [FileNames; FileNames_];
    end
end