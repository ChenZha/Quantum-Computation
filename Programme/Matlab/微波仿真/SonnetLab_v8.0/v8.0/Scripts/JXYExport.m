% JXYExport will call Sonnet to export the current data for a passed project
%   using the supplied output request configuration settings.
%
% Usage:
%   JXYExport(aXmlFilename,aProjectFilename) Will export the data requested
%       by the values in the XML file using the project specified by aProjectFilename.
%
%   JXYExport(aXmlFilename,aProjectObject) Will export the data requested
%       by the values in the XML file using the passed project object.
%
%   JXYExport(aRequestObject,aProjectFilename) Will export the data requested
%       by the JXYRequest object using the project specified by aProjectFilename.
%
%   JXYExport(aRequestObject,aProjectObject) Will export the data requested
%       by the JXYRequest object using the passed project object.
%
%   JXYExport(aXmlFilename,aProjectFilename,aVersionOfSonnet) Will export
%       the data requested by the values in the XML file using the project specified
%       by aProjectFilename. The specified version of Sonnet will be used (must be at
%       least Sonnet 13).
%
%   JXYExport(aXmlFilename,aProjectObject,aVersionOfSonnet) Will export the
%       data requested by the values in the XML file using the passed project object.
%       The specified version of Sonnet will be used (must be at least Sonnet 13).
%
%   JXYExport(aRequestObject,aProjectFilename,aVersionOfSonnet) Will export
%       the data requested by the JXYRequest object using the project
%       specified by aProjectFilename. The specified version of Sonnet will be used
%       (must be at least Sonnet 13).
%
%   JXYExport(aRequestObject,aProjectObject,aVersionOfSonnet) Will export
%       the data requested by the JXYRequest object using the passed project object.
%       The specified version of Sonnet will be used (must be at least Sonnet 13).
%
%  Written by Bashir Souid at Sonnet Software Inc.

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

function JXYExport(aXmlFilenameOrRequest,aProjectFilenameOrObject,theVersionOfSonnet)

% If we were given a Sonnet version then check that it is > 12
if nargin == 3 && str2double(theVersionOfSonnet) < 13
    error('Can''t export current data with Sonnet version < 13');
end

if nargin == 2 && ispc
    % Find an appropriate version of Sonnet
    [~, aSonnetInstallDirectoryList aSonnetInstallDateList]=SonnetPath();
    
    iCounter=1;
    while iCounter <= length(aSonnetInstallDirectoryList)
        aVersion=strrep(aSonnetInstallDirectoryList{iCounter},[fileparts(aSonnetInstallDirectoryList{iCounter}) '\sonnet.'],'');
        aVersion=strrep(aVersion,'"','');
        if str2double(aVersion) < 13
            aSonnetInstallDirectoryList(iCounter)=[];
            aSonnetInstallDateList(iCounter)=[];
            if isempty(aSonnetInstallDirectoryList)
                error('exportCurrents can only be called with Sonnet version 13');
            end
        else
            iCounter=iCounter+1;
        end
    end
    
    % Find the most recently installed version of Sonnet (excluding version 12)
    aMostRecentDate=0;
    aSonnetInstallDateList(strcmp('""',aSonnetInstallDateList)) = [];
    aSonnetInstallDateList(strcmp('',aSonnetInstallDateList)) = [];
    for iCounter=1:length(aSonnetInstallDateList)
        if datenum(aSonnetInstallDateList{iCounter}) > aMostRecentDate
            aMostRecentDate=datenum(aSonnetInstallDateList{iCounter});
            aPath=strrep(aSonnetInstallDirectoryList{iCounter},'"','');
        end
    end
    
elseif ispc
    aPath=SonnetPath(theVersionOfSonnet);
    
else % if it is unix ignore any version numbers
    aPath=SonnetPath();
    
end

% Check that the installed version is at least version 13
[~, aMajorVersion]=fileparts(aPath);
if aMajorVersion < str2double(13)
    error('exportCurrents can only be called with Sonnet version 13');
end

% If we got a request object then
% save it as an XML file.
if isa(aXmlFilenameOrRequest,'JXYRequest')
    aXmlFilenameOrRequest.write('temp.xml');
    aXmlFilenameOrRequest='temp.xml';
    isDeleteXmlFile=true;
else
    isDeleteXmlFile=false;
end

% If we got a filename then open the project
if isa(aProjectFilenameOrObject,'char')
    aProjectFilenameOrObject=SonnetProject(aProjectFilenameOrObject);
end
aProjectObject=aProjectFilenameOrObject;
aProjectFilename=[aProjectObject.FilePath aProjectObject.Filename];

% Back up the project's freq block because we will 
% overwrite it with one that only simulates at the
% desired frequencies. Also back up the control
% block because we will be turning on current 
% calculations and the original file shouldnt
% be perminently changed.
aOriginalFrequencyBlock=aProjectObject.FrequencyBlock;
aOriginalControlBlock=aProjectObject.ControlBlock.clone();

% Get the values for the selected frequencies
aFid=fopen(aXmlFilenameOrRequest);
aLine=fgetl(aFid);
aListOfFrequencies=[];
while feof(aFid)==0
    if ~isempty(strfind(aLine,'<Frequency Value="'))
        aLine=strrep(aLine,'<Frequency Value="','');
        aListOfFrequencies=[aListOfFrequencies sscanf(aLine,'%g')]; %#ok<AGROW>
    end
    aLine=fgetl(aFid);
end
fclose(aFid);

% Build a new frequency block that only  
% simulates at the desired frequencies
aFreqBlock=SonnetFrequencyBlock();
aProjectObject.FrequencyBlock=aFreqBlock;
for iCounter=1:length(aListOfFrequencies)
    aProjectObject.addStepFrequencySweep(aListOfFrequencies(iCounter)/1e9)
end

% Simulate the project
aProjectObject.enableCurrentCalculations();
[aStatus aMessage]=aProjectObject.simulate('-t');
if aStatus
    error(['Simulation failed. Message: ' aMessage]);
end

% Call Sonnet to export the current data
if isunix
    aCallToSystem=['"' aPath filesep 'bin' filesep 'soncmd" -JXYExport "' aXmlFilenameOrRequest '" "' aProjectFilename '"'];
else
    aCallToSystem=['"' aPath 'bin' filesep 'soncmd.exe" -JXYExport "' aXmlFilenameOrRequest '" "' aProjectFilename '"'];
end
[aStatus aMessage]=system(aCallToSystem);

% If we made a temporary XML file then delete it
if isDeleteXmlFile
    delete 'temp.xml'
end

% Restore the project's orginal frequency block
aProjectObject.FrequencyBlock=aOriginalFrequencyBlock;
aProjectObject.ControlBlock=aOriginalControlBlock;
aProjectObject.save();

if ~isempty(aMessage)
    error(['An error occured while exporting: ' aMessage]);
end

end