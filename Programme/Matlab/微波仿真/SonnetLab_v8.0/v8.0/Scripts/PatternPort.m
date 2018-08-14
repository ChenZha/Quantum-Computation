%   This class stores information for port
%   value information present when the project
%   was simulated.

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

classdef PatternPort
    
    properties
        MAG
        PHASE
        R
        X
        L
        C
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj=PatternPort(theData)
            
            theData=strrep(theData,'MAG=','');
            theData=strrep(theData,'PHASE=','');
            theData=strrep(theData,'R=','');
            theData=strrep(theData,'X=','');
            theData=strrep(theData,'L=','');
            theData=strrep(theData,'C=','');
            
            aData=sscanf(theData,'%f',6);
            obj.MAG=aData(1);
            obj.PHASE=aData(2);
            obj.R=aData(3);
            obj.X=aData(4);
            obj.L=aData(5);
            obj.C=aData(6);
        end
    end
end

