function [isEqual aOutput]=ssmdiff(theLeftFile, theRightFile)

% Delete the temporary files
warning off
delete 'ssmdiff_left.son'
delete 'ssmdiff_right.son'

% Remove values from the files that trip up SSDIFF but dont
% actually mean that the files are different in any important
% way. Example: the name label position for components is
% sometimes off by a few pixels; its still readable and
% doesn't in any way mean that the two files are not the same.
convertToClean(theLeftFile,'ssmdiff_left.son')
convertToClean(theRightFile,'ssmdiff_right.son')

% Call Sonnet's SSDIFF to compare the projects
aSonnetPath=SonnetPath();
aCallToSystem=['"' aSonnetPath '\bin\ssdiff.exe" -V geo ssmdiff_left.son ssmdiff_right.son "'];
%aCallToSystem=['"C:\\Program Files\\Sonnet Software\\13.52\\bin\\ssdiff.exe" -V geo ssmdiff_left.son ssmdiff_right.son "'];
[aStatus aOutput]=system(aCallToSystem);
isEqual=~aStatus;

% Delete the temporary files
delete 'ssmdiff_left.son'
delete 'ssmdiff_right.son'
warning on

end

function convertToClean(theInputFilename,theOutputFilename)

aInputFid = fopen(theInputFilename,'r');
aOutputFid = fopen(theOutputFilename,'w');

while ~feof(aInputFid)
    aLine=fgets(aInputFid);
    
    % Perform line replacements
    if ~isempty(strfind(aLine,'SBOX'))
        aLine=sprintf('SBOX 0 0 0 0\n');
    elseif ~isempty(strfind(aLine,'LPOS'))
        aLine=sprintf('LPOS 0 0\n');
    elseif ~isempty(strfind(aLine,'POS'))
        aLine=sprintf('POS 0 0\n');
    elseif ~isempty(strfind(aLine,'LORGN'))
        aLine='';
    end
    
    % This line has been processed; it can be
    % written to the output and we move on to next line
    fprintf(aOutputFid,'%s',aLine);
    
end

fclose(aInputFid);
fclose(aOutputFid);
end