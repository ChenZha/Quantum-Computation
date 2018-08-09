% SonnetProjectCopy(Filename1,Filename2) Will copy 
%   a Sonnet project along with simulation data 
%   and any output files to the same location with 
%   another project filename.
%
% SonnetProjectCopy(Filename1,Filename2,theNewLocation) Will  
%   copy a Sonnet project along with simulation data and
%   any output files to a specified location with another 
%   project filename.
%
%  Examples:
%
%   SonnetProjectCopy('Design1.son','Design2.son')
%   SonnetProjectCopy('Design1.son','Design2.son','c:\temp')

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

function SonnetProjectCopy(theOriginalProjectName,theDesiredProjectName,theNewLocation)

% If no location is specified then
% use the current location
if nargin == 2
    theNewLocation='.';
end

aOriginalFileBaseName=strrep(theOriginalProjectName,'.son','');
aDestinationFileBaseName=strrep(theDesiredProjectName,'.son','');

% Copy the Sonnet Project file
copyfile([aOriginalFileBaseName '.son'],[theNewLocation filesep aDestinationFileBaseName '.son']);

% Copy any output files
aOriginalProject=SonnetProject([aOriginalFileBaseName '.son']);
if ~isempty(aOriginalProject.FileOutBlock)
    for iCounter=1:length(aOriginalProject.FileOutBlock.ArrayOfFileOutputConfigurations)
        aResponseName=aOriginalProject.FileOutBlock.ArrayOfFileOutputConfigurations{iCounter}.Filename;
        aResponseName=strrep(aResponseName,'$BASENAME',aOriginalFileBaseName);
        if ~isempty(dir(aResponseName))
            [~, ~, aExtension]=fileparts(aResponseName);
            copyfile(aResponseName,[theNewLocation filesep aDestinationFileBaseName aExtension]);
        end
    end
end

% Copy the simulation data
warning off
mkdir([theNewLocation filesep 'sondata\' aDestinationFileBaseName]);
warning on
copyfile(['.\sondata\' aOriginalFileBaseName],[theNewLocation filesep 'sondata\' aDestinationFileBaseName]);

end