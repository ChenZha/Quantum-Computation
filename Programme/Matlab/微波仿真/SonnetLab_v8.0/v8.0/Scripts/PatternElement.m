%   This class stores information for a single 
%   element in an pattern data entry.

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

classdef PatternElement <  handle
    
    properties
        Theta
        Phi
        EThetaMag
        EThetaAngle
        EPhiMag
        EPhiAngle
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj=PatternElement(theFid,theNumberOfPorts)
            %Element   Reads a pattern data
            %   Element(aFid,n) Reads data stored in
            %   a PDATA entry of a pattern file.
            
            fscanf(theFid,' %s',1);
            obj.Theta=fscanf(theFid,' %g',1);
            obj.Phi=fscanf(theFid,' %g',1);
            
            % ETHETA MAG ETHETA ANGLE
            % EPHI MAG  EPHI ANGLE 
            
            aData=textscan(theFid,'%f %f',theNumberOfPorts,'Delimiter',',');
            obj.EThetaMag=aData{1};
            obj.EThetaAngle=aData{2};
            
            aData=textscan(theFid,'%f %f',2*theNumberOfPorts,'Delimiter',',');
            obj.EPhiMag=aData{1};
            obj.EPhiAngle=aData{2};
            
        end
    end
end