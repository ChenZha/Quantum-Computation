%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function is helpful when reading
%   a string from A Sonnet Project File.
%	When a string with a space in it is meant to be
%	printed out to the file it often
% 	will require a set of quotes to specify that this is
%	one string.
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function aTempString = SonnetStringReadFormat(theFid)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function makes sure we read
% in the proper string given things
% like how quotation marks may
% allow for strings with spaces.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% We want to read from the file,
% if the first character is
% a set of quotes then keep
% reading till we get to another
% set of quotes. Concatinate those
% strings we read to make one string
% that is all the substrings that
% existed in the parenthesis.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

aBackupOfTheFid=ftell(theFid);          	        % Store a backup of the file ID so that we can restore it afer we read the line
aTempCharacter=fscanf(theFid,' %c',1);
fseek(theFid,aBackupOfTheFid,'bof');	            % Restore the backup of the fid

if strcmp(aTempCharacter,'"')==0	% If the first character is not a set of quotes then just read in the string normally
  aTempString=fscanf(theFid,'%s',1);
  
  % If the string is a number then store it as a number
  if ~isnan(str2double(aTempString))
    aTempString=str2double(aTempString);
  end
  
else
  
  aTempString=fscanf(theFid,' %c',1); % read in the first character which will be a quotation mark.
  aTempCharacter='';
  
  % loop and read in all the characters till we get to the end of the string (another set of quotation marks with a space after it)
  while 1==1
    aTempString=[aTempString aTempCharacter];  
    aTempCharacter=fscanf(theFid,'%c',1);
    
    % Check if we have an "
    if strcmp(aTempCharacter,'"')==1
        % Check if the next character is a space
        aBackupOfTheFid=ftell(theFid);          	        % Store a backup of the file ID so that we can restore it afer we read the line
        aTempCharacter2=fscanf(theFid,'%c',1);
        fseek(theFid,aBackupOfTheFid,'bof');	            % Restore the backup of the fid
        if isspace(aTempCharacter2)
           aTempString=[aTempString aTempCharacter];
           break; 
        end
    end    
    
  end
  
end

%#ok<*AGROW>


