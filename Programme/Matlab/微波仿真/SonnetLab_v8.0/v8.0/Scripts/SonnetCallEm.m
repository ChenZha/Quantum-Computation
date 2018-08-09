% SonnetCallEm will call Sonnet EM
% to simulate the Sonnet Project File.
%
% This function has the following parameters:
%   1) The filename of the project to be simulated
%   2) (Optional) a string that defines extra options
%       in the format explained below.
%
% Options are passed as a single string. Order of option switches 
% doesnt matter and unknown option switches are ignored.
%
% Supported option switches:
%   '-c'              To clean the project data first
%   '-x'              To not clean the project data first (default)
%   '-w'              To display a simulation status window (default)
%   '-t'              To not display a simulation status window
%   '-r'              To run the simulation instantaneously (default)
%   '-p'              To not run the simulation instantaneously (requires status window)
%   '-v' <VERSION>    To use a particular version of Sonnet to do the simulation (PC only)
%   '-s' <DIRECTORY>  To manually specify the Sonnet directory to
%                      use for the simulation. The directory may either
%                      be the base Sonnet directory or the version's bin
%                      directory.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [aStatus aMessage]=SonnetCallEm(theFilename, theOptions)

if nargin == 1
    theOptions='';
end

% If they specified a specific version of Sonnet to use then use that version
if ispc && (~isempty(strfind(theOptions,'-v')) || ~isempty(strfind(theOptions,'-V')))
    % Parse the input string
    [aParcialString, aRemainingString] = strtok(theOptions,'vV'); %#ok<ASGLU>
    
    % Read in the version number
    aRemainingString=aRemainingString(2:length(aRemainingString));
    aSonnetVersion=sscanf(aRemainingString,'%s',1);
    
    Path=SonnetPath(aSonnetVersion);
    
elseif ~isempty(strfind(theOptions,'-s')) || ~isempty(strfind(theOptions,'-S'))
    % Parse the input string
    [aParcialString, aRemainingString] = strtok(theOptions,'sS'); %#ok<ASGLU>
    
    % Read in the version number
    aRemainingString=aRemainingString(2:length(aRemainingString));
    
    % Store the path
    Path='';
    for iCounter=1:length(aRemainingString)
        if aRemainingString(iCounter) ~= '-'
            Path=[Path aRemainingString(iCounter)]; %#ok<AGROW>
        else
           break; 
        end
    end
    
    % Remove any quotation marks
    Path=strrep(Path,'"','');
    Path=strtrim(Path);
    Path=strrep(Path,[filesep 'bin'],'');
    
    % If the specified location does not have \bin\em.exe (if on PC)
    % or /bin/em (if UNIX) then it is not a valid Sonnet directory.
    if isunix
        if ~exist([Path filesep 'bin' filesep 'em'],'file')
            error(['Invalid Sonnet Directory Specified: ' Path]);
        end
    else
        if ~exist([Path filesep 'bin' filesep 'em.exe'],'file')
            error(['Invalid Sonnet Directory Specified: ' Path]);
        end
    end
    
elseif isunix && (~isempty(strfind(theOptions,'-v')) || ~isempty(strfind(theOptions,'-V')))
    warning('-v option is not valid for UNIX. The option will be ignored. To select the Sonnet version use the enviornment variable');
    Path=SonnetPath();
    
else
    Path=SonnetPath();
    
end

% Call Sonnet to unlock the project
if isempty(strfind(theOptions,'-l')) && isempty(strfind(theOptions,'-L'))
    if isunix
        aCallToSystem=['"' Path filesep 'bin' filesep 'soncmd" -unlock "' theFilename '"'];
    else
        aCallToSystem=['"' Path filesep 'bin' filesep 'soncmd.exe" -unlock "' theFilename '"'];
    end
    [aStatus aMessage]=system(aCallToSystem);
    
    if aStatus
        error(['Failed to call soncmd to unlock the project: ' aMessage]);
    end
end

% If the 'C' flag was given delete the folder for the simulation to clean the data
if ~isempty(strfind(theOptions,'-c')) || ~isempty(strfind(theOptions,'-C')) % If they didnt pass an x value
    aProject=SonnetProject(theFilename);
    aProject.cleanProject;
end

% If the folder for simulation results doesn't exist create it
[path, name] = fileparts(theFilename);
path=strrep(path,'\',filesep);
path=strrep(path,'/',filesep);
if isempty(path)
path='.';
end
if ~isempty(strfind(path,':')) %if it is an absolute path
    aFolderLocation=[path filesep 'sondata' filesep strrep(name,'.son','')];
elseif isempty(path)
    aFolderLocation=[path filesep 'sondata' filesep strrep(name,'.son','')];
else
    aFolderLocation=[path filesep 'sondata' filesep strrep(name,'.son','')];
end

[~,result]=mkdir(aFolderLocation); %#ok<NASGU>

aLogFilename=[aFolderLocation filesep 'SimulationStatus.log'];

aStatus=[];
aMessage='';

% Prep System Call to invoke EM on the .son file
if isempty(strfind(theOptions,'-t')) && isempty(strfind(theOptions,'-T'))
    % If we are drawing an EM Status window
    if ~isempty(strfind(theOptions,'-p')) || ~isempty(strfind(theOptions,'-P'))
        % If we are going to start out paused
        if isunix
            aCallToSystem=['"' Path filesep 'bin' filesep 'emstatus" "' theFilename '" -LogFile "' aLogFilename '" &'];
        else
            aCallToSystem=['"' Path filesep 'bin' filesep 'emstatus.exe" "' theFilename '" -LogFile "' aLogFilename '" &'];
        end
    else
        % If we are running right away
        if isunix
            aCallToSystem=['"' Path filesep 'bin' filesep 'emstatus" -Run "' theFilename '" -LogFile "' aLogFilename '" &'];
        else
            aCallToSystem=['"' Path filesep 'bin' filesep 'emstatus.exe" -Run "' theFilename '" -LogFile "' aLogFilename '" &'];
        end
    end
else
    % If we are going to do the simulation without a GUI
    if isunix
        aCallToSystem=['"' Path filesep 'bin' filesep 'em" "' theFilename '"'];
    else
        if(strcmp(computer,'PCWIN64'))
            aCallToSystem=['"' Path filesep 'bin_x64' filesep 'em.exe" "' theFilename '"'];
        else
            aCallToSystem=['"' Path filesep 'bin' filesep 'em.exe" "' theFilename '"'];
        end
    end
end

% Make the call and wait for the simulation to complete successfully or to fail
if ~isempty(strfind(theOptions,'-t')) || ~isempty(strfind(theOptions,'-T'))
    [aStatus aMessage]=system(aCallToSystem);
else    
    % if the log file exists then delete it
    if ~isempty(dir(aLogFilename))
        warning off all
        delete(aLogFilename);
        warning on all
    end
    
    % Run the simulation
    system(aCallToSystem);
       
    while true
        
        % This pause needs to be here (cut it in half
        % or something if necessary but leave something there)
        % because otherwise we have full utilization
        % for of matlab while the simulation is running.
        pause(1);
        
        % if the log file doesnt exist yet then wait for it to exist
        % if 5 seconds go by and there is no log file yet then throw
        % an error.
        aFid=fopen(aLogFilename);
        aAmountOfTimeWaitedSoFar=0;
        while aFid == -1
            aFid=fopen(aLogFilename);
            pause(1);
            aAmountOfTimeWaitedSoFar=aAmountOfTimeWaitedSoFar+1;
            if aAmountOfTimeWaitedSoFar > 10
                error('Sonnet never created a log file.')
            end
        end
        
        % Search the file to see if we are done with the simulation
        while feof(aFid)==0
            aFileLine=fgetl(aFid);
            if ~isempty(strfind(aFileLine,'Analysis stopped'))
                aStatus=1;
                aMessage='Analysis stopped';
            end
            if ~isempty(strfind(aFileLine,'EM abnormally terminated'))
                aStatus=1;
                aMessage='EM abnormally terminated';
            end
            if ~isempty(strfind(aFileLine,'Analysis completed successfully'))
                aStatus=0;
                aMessage='';
            end            
            if ~isempty(strfind(aFileLine,'Log file closed'))
                fclose(aFid);
                
                % if the log file exists then delete it
                if ~isempty(dir(aLogFilename))
                    warning off all
                    delete(aLogFilename);
                    warning on all
                end
                
                return;
            end
        end
        fclose(aFid);
    end
end
