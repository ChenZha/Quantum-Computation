%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function is helpful when writing
%   a string to a Sonnet Project File.
%	When a string with embedded whitespace is
%   meant to be exported as a Sonnet project
%   file it is required to have a set of quotes
%   to specify that this is one string.
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function theString = SonnetStringWriteFormat(theString)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function makes sure that if
% our string had spaces in it it gets
% printed out with quotation marks.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isa(theString,'double')
    theString=num2str(theString);
else
    theString=strtrim(theString);
    
    if ~isempty(strfind(theString, ' ')) || theString(1)=='"'
        if theString(1)=='"'
            theString(1)=' ';
        end
        
        if theString(length(theString))=='"'
            theString(length(theString))=' ';
        end
        
        theString=strtrim(theString);
        
        theString=['"' theString '"'];
    end
end
