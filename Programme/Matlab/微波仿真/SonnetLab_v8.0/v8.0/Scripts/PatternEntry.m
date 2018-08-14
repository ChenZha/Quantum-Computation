%   This class stores information for a single 
%   element in an exported pattern file.

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

classdef PatternEntry <  handle
    
    properties
        Frequency
        ArrayOfElements
        Drive
        Normalization
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj=PatternEntry(aFid,theFrequency,theNumberOfPorts)
            %PatternEntry   Reads a pattern entry
            %   PatternEntry(aFid) Reads data stored in
            %   a PDATA entry of a pattern file.
            
            obj.Frequency=theFrequency;
            
            while(feof(aFid)~=1)
                
                aTempString=fscanf(aFid,'%s',1);
                
                switch(aTempString)
                    
                    case 'SPR'
                        fgetl(aFid);
                        
                    case 'DRIVE'
                        obj.Drive=textscan(aFid,'%f %f',2,'Delimiter',',');
                        
                    case 'NORM'
                        obj.Normalization=textscan(aFid,'%f',3,'Delimiter',',');
                        
                    case 'ADATA'
                        aNumberOfElements=fscanf(aFid,'%d',1);
                        
                        % Pre-allocate the vector of elements with the
                        % first element for speed.
                        anArrayOfElements=PatternElement.empty(aNumberOfElements,0);
                        
                        % Process each of the ANG subblocks
                        for iCounter=1:aNumberOfElements
                            aANG=PatternElement(aFid,theNumberOfPorts);
                            anArrayOfElements(iCounter)=aANG;
                        end
                        obj.ArrayOfElements=anArrayOfElements;
                        
                    case 'END'
                        fgetl(aFid);
                        break;
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aElement=getElement(obj,theFirstArgument,theSecondArgument)
            %getElement   Get an element by index
            %   element=getElement(n) Will return data for the nth element
            %
            %   element=getElement(theta,phi) Will return the element with
            %       specified theta and phi values.
            
            if nargin == 2
                aElement=obj.ArrayOfElements(theFirstArgument);
            elseif nargin == 3
                for iCounter=1:length(obj.ArrayOfElements)
                    if obj.ArrayOfElements(iCounter).Theta==theFirstArgument &&...
                            obj.ArrayOfElements(iCounter).Phi==theSecondArgument
                        aElement=obj.ArrayOfElements(iCounter);
                        return;
                    end
                end
                if ~(exist('aElement','var'))
                    error('No matching theta/phi element was found')
                end
            else
                error('Improper number of arguments');
            end
        end
        
    end
end