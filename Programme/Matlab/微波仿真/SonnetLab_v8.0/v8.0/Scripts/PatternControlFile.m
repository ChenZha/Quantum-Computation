% This function writes an pattern export control file.

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


function [successful,filename]=PatternControlFile(Data)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Serhend Arvas                    %
% Part of Antenna Pattern Plot Code        %
% May 2011                                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Constructs the FileName
filename=[Data.theProjectFilePath filesep 'ctl.pg']; 
fid=fopen(filename,'w','n','UTF-8'); % Opens the file

% Sets a flag based on the success or failure of the open operation
if fid == -1
    successful = 0;
else
    successful = 1;
end

OutputText{1}='CTLPG';

OutputText{2}=['THETA ' num2str(Data.theThetaAngleVec(1),5) ' ' num2str(Data.theThetaAngleVec(2),5) ' ' num2str(Data.theThetaAngleVec(3),5)];
OutputText{3}=['PHI ' num2str(Data.thePhiAngleVec(1),5) ' ' num2str(Data.thePhiAngleVec(2),5) ' ' num2str(Data.thePhiAngleVec(3),5)];
OutputText{4}=Data.Units;
      
OutputText{5}='FREQ ALL';

[rows,cols]=size(Data.thePortInfo);

for n=1:rows
    OutputText{end+1}=['PORT ' num2str(Data.thePortInfo(1)) ' MAG=' num2str(Data.thePortInfo(2),5) ' PHASE=' num2str(Data.thePortInfo(3),5) ' R=' num2str(Data.thePortInfo(4),5) ' X=' num2str(Data.thePortInfo(5),5) ' L=' num2str(Data.thePortInfo(6),5) ' C=' num2str(Data.thePortInfo(7),5) ];
end
OutputText{end+1}='ENDCTL';

% writes the lines of the project file followed by newline characters.
for lineNum=1:length(OutputText)   
    line=OutputText{lineNum};
    fprintf(fid,line); 
    fprintf(fid,'\r\n');  
end

fclose(fid);