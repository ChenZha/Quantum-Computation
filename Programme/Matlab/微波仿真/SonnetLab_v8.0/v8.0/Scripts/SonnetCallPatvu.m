% SonnetCallPatvu will call Sonnet Patvu
% to generate the Far Field of a Sonnet Project File.
%
% This function has the following parameters:
%   1) The filename of the project
%   2) Units as a string.  THZ, GHZ, MHZ, KHZ, HZ
%   3) The PhiAngleVec [start stop step] of Phi (azimuthal angle) in degs.
%   4) The ThetaAngleVec [start stop step] of Theta ("elevation" angle) in degs.
%   5) The List of Frequencies at which the pattern should be calculated in units of 2).
%   6) The port excitations/terminations.
%      This should be a matrix with columns:
%       [PortNumber Magnitude Phase(deg) Real(Z) Imag(Z) Inductance Capacitance]
%       example: [1 1 0 50 0 0 0]
%       which means: [Port 1, MAG=1, PHASE=0, R=50, X=0, L=0, C=0]
%
%  An example call:
%
%   SonnetCallPatvu('Antenna.son','C:\','GHZ',[0 360 1],[-90 90 1],[2.3 2.4 2.5],[1 1 0 50 0 0 0])

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

function [aStatus aMessage]=SonnetCallPatvu(theFilename,theProjectFilePath,Units,thePhiAngleVec,theThetaAngleVec,theListOfFreqs,thePortInfo)

theFilenameBase=theFilename(1:end-4);
Data.theProjectFilePath=theProjectFilePath;
Data.Units=Units;
Data.thePhiAngleVec=thePhiAngleVec;
Data.theThetaAngleVec=theThetaAngleVec;
Data.theListOfFreqs=theListOfFreqs;
Data.thePortInfo=thePortInfo;
PatternControlFile(Data);

Path=SonnetPath();

if isunix
    aCallToSystem=['"' Path filesep 'bin' filesep 'patvu" "' theProjectFilePath filesep theFilename '" -pg "' theProjectFilePath filesep 'ctl.pg" -Patgen'];
else
    aCallToSystem=['"' Path filesep 'bin' filesep 'patvu.exe" "' theProjectFilePath filesep theFilename '" -pg "' theProjectFilePath filesep 'ctl.pg" -Patgen'];
end
    
[aStatus aMessage]=system(aCallToSystem);

if aStatus==1
   error(['Error: ' aMessage]);
end