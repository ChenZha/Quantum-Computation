% Stores pattern control information

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

classdef PatternControlBlock  <  handle
    
    properties
        Theta
        Phi
        ParameterBlock
        Ports
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj=PatternControlBlock(aFid)
            %processOptions   Reads the CTLPG block
            %   processOptions(aFid) Reads data stored in
            %   the CTLPG block of a pattern file.
            
            while(feof(aFid)~=1)
                
                aTempString=fscanf(aFid,'%s',1);
                
                switch(aTempString)
                    case 'THETA'
                        [aValues]=fscanf(aFid,' %g',3);
                        obj.Theta=aValues(1):aValues(3):aValues(2);
                        
                    case 'PHI'
                        [aValues]=fscanf(aFid,' %g',3);
                        obj.Phi=aValues(1):aValues(3):aValues(2);
                        
                    case 'GHZ'
                        fgetl(aFid);
                                                
                    case 'PORT'
                        obj.Ports{end+1}=PatternPort(fgetl(aFid));
                        
                    case 'PARAMS'
                        obj.ParameterBlock=PatternParameterBlock(aFid);
                        
                    case 'ENDCTL'
                        fgetl(aFid);
                        break;
                end
            end
        end
    end
    
end