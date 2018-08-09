function [aSonnetPath aSonnetInstallDirectoryList aSonnetInstallVersionList]=SonnetPath(theVersionNumber)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function will search the windows registry and try to locate the
% installation path for Sonnet.
%
% This function takes an optional argument for the version of Sonnet
% whose path we are requesting.
%
% This script is modified from the work done by Serhend Arvas in the package: 
%   Patch Antenna Design Using Sonnet
%   http://www.mathworks.com/matlabcentral/fileexchange/16077-patch-antenna-design-using-sonnet-v3-1
%
% SonnetLab, all included documentation, all included examples 
% and all other files (unless otherwise specified) are copyrighted by Sonnet Software 
% in 2011 with all rights reserved.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS". ANY AND 
% ALL EXPRESS OR IMPLIED WARRANTIES ARE DISCLAIMED. UNDER NO CIRCUMSTANCES AND UNDER 
% NO LEGAL THEORY, TORT, CONTRACT, OR OTHERWISE, SHALL THE COPYWRITE HOLDERS,  CONTRIBUTORS, 
% MATLAB, OR SONNET SOFTWARE BE LIABLE FOR ANY DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR 
% CONSEQUENTIAL DAMAGES OF ANY CHARACTER INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF 
% GOODWILL, WORK STOPPAGE, COMPUTER FAILURE OR MALFUNCTION, OR ANY AND ALL OTHER COMMERCIAL 
% DAMAGES OR LOSSES, OR FOR ANY DAMAGES EVEN IF THE COPYWRITE HOLDERS, CONTRIBUTORS, MATLAB, 
% OR SONNET SOFTWARE HAVE BEEN INFORMED OF THE POSSIBILITY OF SUCH DAMAGES, OR FOR ANY CLAIM 
% BY ANY OTHER PARTY.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% If a copied registry file already exists delete it 
% so we can get a fresh version from the system.
% [~, junk]=system('del "SonnetRegEntry.reg"'); %#ok<NASGU>

% Attempt to get the registry entry for Sonnet
if strcmp(computer,'PCWIN')
    [Status, ~]=system('reg.exe export "HKEY_LOCAL_MACHINE\SOFTWARE\Sonnet Software\sonnet" "SonnetRegEntry.reg" /y');
    if Status == 1
        % Check if C:\Program Files\sonnet.13.52 exists, if so display a warning and use it instead of throwing an error
        if exist('C:\\Program Files\\sonnet.13.52','dir') ~= 0 
           warning('Could not find Sonnet registry entry on Windows 32bit system; Defaulting to C:\\Program Files\\sonnet.13.52');
           aSonnetPath='C:\\Program Files\\sonnet.13.52';
           aSonnetInstallDirectoryList={'C:\\Program Files\\sonnet.13.52'};
           aSonnetInstallVersionList='"00-00-0000"';
           return
        % Check if C:\Program Files\sonnet.12.52 exists, if so display a warning and use it instead of throwing an error
        elseif exist('C:\\Program Files\\sonnet.12.52','dir') ~= 0 
            warning('Could not find Sonnet registry entry on Windows 32bit system; Defaulting to C:\\Program Files\\sonnet.12.52' );
            aSonnetPath='C:\\Program Files\\sonnet.12.52';
            aSonnetInstallDirectoryList={'C:\\Program Files\\sonnet.12.52'};
            aSonnetInstallVersionList='"00-00-0000"';
            return
        else
            error('Could not find Sonnet registry entry on Windows 32bit system');
        end        
    end
    
    if nargin == 1
        [aSonnetPath, aSonnetInstallDirectoryList, aSonnetInstallVersionList]=ProcessRegistryFile(theVersionNumber);
    else
       [aSonnetPath, aSonnetInstallDirectoryList, aSonnetInstallVersionList]=ProcessRegistryFile(); 
    end
            
elseif strcmp(computer,'PCWIN64')
    [Status, cmdout]=system('reg.exe export "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Sonnet Software\sonnet" "SonnetRegEntry.reg" /y');
    if Status == 1
        % Check if C:\Program Files\sonnet.13.52 exists, if so display a warning and use it instead of throwing an error
        if exist('C:\\Program Files\\sonnet.13.52','dir') ~= 0 
           warning('Could not find Sonnet registry entry on Windows 64bit system; Defaulting to C:\\Program Files\\sonnet.13.52');
           aSonnetPath='C:\\Program Files\\sonnet.13.52';
           aSonnetInstallDirectoryList={'C:\\Program Files\\sonnet.13.52'};
           aSonnetInstallVersionList='"00-00-0000"';
           return
        % Check if C:\Program Files\sonnet.12.52 exists, if so display a warning and use it instead of throwing an error
        elseif exist('C:\\Program Files\\sonnet.12.52','dir') ~= 0 
            warning('Could not find Sonnet registry entry on Windows 64bit system; Defaulting to C:\\Program Files\\sonnet.12.52' );
            aSonnetPath='C:\\Program Files\\sonnet.12.52';
            aSonnetInstallDirectoryList={'C:\\Program Files\\sonnet.12.52'};
            aSonnetInstallVersionList='"00-00-0000"';
            return
        elseif exist('C:\\Progra~2\\sonnet.12.56','dir') ~= 0 
            %warning('Could not find Sonnet registry entry on Windows 64bit system; Defaulting to C:\\Program Files\\sonnet.12.56' );
            aSonnetPath='C:\\Program Files\\sonnet.12.56';
            aSonnetInstallDirectoryList={'C:\\Progra~2\\sonnet.12.56'};
            aSonnetInstallVersionList='"00-00-0000"';
            return            
        else
            outputstr = strcat('Could not find Sonnet registry entry on Windows 64bit system, ', cmdout, pwd);
            
            error(outputstr);
        end        
    end
    
    if nargin == 1
        [aSonnetPath, aSonnetInstallDirectoryList, aSonnetInstallVersionList]=ProcessRegistryFile(theVersionNumber);
    else
       [aSonnetPath, aSonnetInstallDirectoryList, aSonnetInstallVersionList]=ProcessRegistryFile(); 
    end
            
elseif isunix
    aSonnetPath = getenv('SONNET_DIR');
    aSonnetInstallDirectoryList={aSonnetPath};
    [~, aVersionPart1, aVersionPart2]=fileparts(aSonnetPath);
    aSonnetInstallVersionList={[aVersionPart1 aVersionPart2]};
    
else
    error('Unknown system type. SonnetPath can''t find where Sonnet is located');
    
end

function [aSonnetPath, aSonnetInstallDirectoryList, aSonnetInstallVersionList]=ProcessRegistryFile(theVersionNumber)

% Open the registry file
aFid=fopen('SonnetRegEntry.reg','r','l');
aSonnetInstallDirectoryList={};
aSonnetInstallVersionList={};

% Store the waste character
aRegistryFileLine=fgetl(aFid);
aWasteCharacter=aRegistryFileLine(5);

% Find all the Sonnet Installations
while feof(aFid)==0
    
    aRegistryFileLine=fgetl(aFid);
    aRegistryFileLine=strrep(aRegistryFileLine,aWasteCharacter,'');
    
    if findstr(aRegistryFileLine,'"SONNET_DIR"=')
        aNewNumberOfInstalledVersions=length(aSonnetInstallDirectoryList)+1;
        aInstalledDirectory=strrep(aRegistryFileLine,'"SONNET_DIR"=','');
        aSonnetInstallDirectoryList{aNewNumberOfInstalledVersions}=aInstalledDirectory; %#ok<AGROW>
    end
    if findstr(aRegistryFileLine,'"InstallationDate"=')
        aNewNumberOfInstalledVersions=length(aSonnetInstallVersionList)+1;
        aInstalledVersion=strrep(aRegistryFileLine,'"InstallationDate"=','');
        aSonnetInstallVersionList{aNewNumberOfInstalledVersions}=aInstalledVersion; %#ok<AGROW>
    end

end

aSonnetPath=[];

% If they passed a version number then use the version they specified
if nargin == 1
    for iCounter=1:length(aSonnetInstallDirectoryList)
        % Extract the version number
        aRemainingPath=aSonnetInstallDirectoryList{iCounter};
        while ~isempty(aRemainingPath)
            [aPartialPath, aRemainingPath]=strtok(aRemainingPath,filesep); %#ok<STTOK>
        end
        
        % format the version number
        aVersionNumber=strrep(aPartialPath,'"','');
        aVersionNumber=strrep(aVersionNumber,'sonnet.','');
        
        % If the passed variable is a string then do strcmp
        if strcmp(num2str(theVersionNumber),aVersionNumber)==1
            aSonnetPath=aSonnetInstallDirectoryList{iCounter};
            aSonnetPath=strrep(aSonnetPath,'"','');
            break;
        end
    end

% If they did not specify a version number use the one that was most
% recently installed.  This could possibly mean that the latest version
% is not returned.
else
    
    aMostRecentDate=0;
    
    % Find the most recent date
    for jCounter=1:length(aSonnetInstallVersionList)
        if strcmp(aSonnetInstallVersionList{jCounter},'""')
            continue
        end
        if datenum(aSonnetInstallVersionList{jCounter}) > aMostRecentDate
            aMostRecentDate=datenum(aSonnetInstallVersionList{jCounter});
            aSonnetPath=aSonnetInstallDirectoryList{jCounter};
            aSonnetPath=strrep(aSonnetPath,'"','');
        end
    end
end

% Delete the registry file
fclose(aFid);
system('del "SonnetRegEntry.reg"');
