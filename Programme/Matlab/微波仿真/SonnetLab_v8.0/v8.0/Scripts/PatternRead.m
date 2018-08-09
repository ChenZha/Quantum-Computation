% PatternRead(theFilename) Reads a pattern
%   output file and stores its associated
%   pattern information.
%
%  Examples:
%
%   aData=PatternRead('infpole.pat');

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

classdef PatternRead  <  handle
    
    properties
        Version
        Filename
        ProjectName
        Options
        ArrayOfPatterns
    end
    
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = PatternRead(theFilename)
            %PatternRead   Reads a pattern file
            %   PatternRead('PatternFile.pat') Initializes an object to
            %   represent data stored in a Sonnet pattern file.
            
            aFid = fopen(theFilename, 'r');
            if aFid == -1
                error 'Error: File not found';
            end
            
            obj.ArrayOfPatterns=PatternEntry.empty(1,0);
            
            while(feof(aFid)~=1)
                
                aTempString=fscanf(aFid,'%s',1);
                
                switch(aTempString)
                    
                    case 'FTYP'
                        fgetl(aFid);
                        
                    case 'VER'
                        obj.Version=strtrim(fgetl(aFid));
                        
                    case 'PROG'
                        fgetl(aFid);
                        
                    case 'DATE'
                        fgetl(aFid);
                        
                    case 'JXYDATE'
                        fgetl(aFid);
                        
                    case 'NAM'
                        obj.Filename=strtrim(fgetl(aFid));
                        
                    case 'TOP'
                        fgetl(aFid);
                        
                    case 'BOTTOM'
                        fgetl(aFid);
                        
                    case 'JXYFILE'
                        obj.ProjectName=strtrim(fgetl(aFid));
                        
                    case 'CTLPG'
                        obj.Options=PatternControlBlock(aFid);
                        
                    case 'PDATA'
                        fgetl(aFid);
                        
                    case 'FRE'
                        aFrequency=fscanf(aFid,' %g',1);
                        aNumberOfPorts=length(obj.Options.Ports);
                        aPattern=PatternEntry(aFid,aFrequency,aNumberOfPorts);
                        obj.ArrayOfPatterns(end+1)=aPattern;
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aElement=getElement(obj,thePatternNumber,theFirstArgument,theSecondArgument)
            %getElement   Get an element by index
            %   element=getElement(n,m) Will return data for the nth
            %       element of the mth pattern.
            %
            %   element=getElement(n,theta,phi) Will return the element with
            %       specified theta and phi values in the nth pattern. Data
            %       for the specified theta and phi values must already be
            %       provided in the pattern file.
            
            if nargin == 3
                aElement=obj.ArrayOfPatterns(thePatternNumber).getElement(theFirstArgument);
            elseif nargin == 4
                aElement=obj.ArrayOfPatterns(thePatternNumber).getElement(theFirstArgument,theSecondArgument);
            else
                error('Improper number of arguments');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aData=getThetaList(obj)
            %getThetaList   Get a vector of theta values
            %   vector=getThetaList() Will return a
            %          vector of theta values
            
            aData=obj.Options.Theta;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aData=getPhiList(obj)
            %getPhiList   Get a vector of theta values
            %   vector=getPhiList() Will return a
            %          vector of phi values
            
            aData=obj.Options.Phi;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aData=getFrequencyValue(obj,thePatternNumber)
            %getFrequencyValue   Get a vector of theta values
            %   value=getFrequencyValue() Will return a vector
            %           with all the frequency values for the
            %           exports stored in the file.
            %
            %   value=getFrequencyValue(aIndex) Will return the
            %           frequency value used for the specified
            %           export index.
            
            if nargin == 1
                aData=zeros(length(obj.ArrayOfPatterns),1);
                for iCounter=1:length(obj.ArrayOfPatterns)
                    aData(iCounter)=obj.ArrayOfPatterns(iCounter).Frequency;
                end
            else
                aData=obj.ArrayOfPatterns(thePatternNumber).Frequency;
            end
        end
    end
end