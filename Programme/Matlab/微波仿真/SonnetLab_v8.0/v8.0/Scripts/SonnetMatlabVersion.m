% SonnetMatlabVersion   Return/Print the version identifier for SonnetLab
%   version=SonnetMatlabVersion(); will return the version identifier for
%   the current version of SonnetLab. The SonnetLab version and Matlab
%   version information will be printed to the console window.
%
%   version=SonnetMatlabVersion(isVerbose); will return the version identifier for
%   the current version of SonnetLab. If isVerbose is true then the SonnetLab 
%   version and Matlab version information will be printed to the console window.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

function version = SonnetMatlabVersion(isVerbose)
    version='8.0';
    if nargin == 0 || isVerbose
        fprintf(1,'\n-------------------------------------------------------------------------------------')
        fprintf(1,'\nSonnetLab version %s is installed',version) %#ok<PRTCAL>
        fprintf(1,'\n-------------------------------------------------------------------------------------\n')
        ver
        fprintf(1,'-------------------------------------------------------------------------------------\n')
    end
end