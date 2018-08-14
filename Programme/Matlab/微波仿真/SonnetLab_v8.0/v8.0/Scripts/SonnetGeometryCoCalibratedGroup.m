classdef SonnetGeometryCoCalibratedGroup < handle
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This class defines the values for an cocalibrated group that is 
    % used for Sonnet ports.
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
    properties
        
        GroupName
        GroupType
        GroupId
        GroundReference
        TerminalWidthType
        ReferencePlanes
        UnknownLines
        
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = SonnetGeometryCoCalibratedGroup(theFid)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Defines the constructor for the SMD block.
            % The constructor will be passed the file ID from the
            %     SONNET GEO object constructor.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if nargin == 1              				
                
                initialize(obj);
                
                obj.GroupName=fscanf(theFid,' %s',1); % Read in the name of the group
                % obj.GroupType=fscanf(theFid,' %s',1);
                aCounterForUnknownLines=0;
                
                while(1==1)
                    
                    % Read a string from the file,  we will use this to determine what property needs to be modified by using a case statement.
                    aTempString=fscanf(theFid,' %s',1); 		% Read a Value from the file, we will be using this to drive the switch statment
                    
                    switch aTempString
                        case 'ID'
                            obj.GroupId=fscanf(theFid,'%d',1);
                            
                        case 'GNDREF'
                            obj.GroundReference=fscanf(theFid,'%s',1);
                            
                        case 'TWTYPE'
                            obj.TerminalWidthType=fscanf(theFid,'%s',1);
                            
                        case 'DRP1'
                            if isempty(obj.ReferencePlanes)                 % If we dont have a ReferencePlanes entry yet then make a new object for one
                                obj.ReferencePlanes=SonnetGeometryReferencePlane(theFid);
                            else                                            % If we already have an object for our ReferencePlanes entries then just add this one to the object using its add function
                                obj.ReferencePlanes.addNewSideFromFile(theFid);       % Tells the object to add a new Parallel subsection as defined from the file
                            end
                            
                        case 'END'
                            break;
                            
                        otherwise						% If we dont recognize the line then we want to save it so we can write it out again.
                            aCounterForUnknownLines=aCounterForUnknownLines+1;
                            obj.UnknownLines{aCounterForUnknownLines} = [aTempString fgetl(theFid) ' \n'];	% Add the line to the unknownlines array
                            
                    end
                    
                end
                
            else
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % we come here when we didn't recieve a file ID as an argument
                % which means that we are going to create a default object with
                % default values by calling the function's initialize method.
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                initialize(obj);
                
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function initialize(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function initializes the SMD properties to some default
            %   values. This is called by the constructor and can
            %   be called by the user to reinitialize the object to
            %   default values.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            aBackup=warning();
            warning off all
            aProperties = properties(obj);
            for iCounter = 1:length(aProperties)
                obj.(aProperties{iCounter}) = [];
            end
            warning(aBackup);
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aNewObject=clone(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function builds a deep copy of this object
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            aNewObject=SonnetGeometryCoCalibratedGroup();
            SonnetClone(obj,aNewObject);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addReferencePlane(obj,theSide,theTypeOfReferencePlane,theLengthOrPolygon,theVertex)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Adds a reference plane to the component
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if isempty(obj.ReferencePlanes)
                obj.ReferencePlanes=SonnetGeometryReferencePlane();
            end
            
            if nargin == 4
                obj.ReferencePlanes.addNewSide(theSide,theTypeOfReferencePlane,theLengthOrPolygon);
            else
                obj.ReferencePlanes.addNewSide(theSide,theTypeOfReferencePlane,theLengthOrPolygon,theVertex);
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function writeObjectContents(obj, theFid, theVersion)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function writes the values from the object to a file.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            fprintf(theFid,'%s',obj.stringSignature(theVersion));
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aSignature=stringSignature(obj,theVersion)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function writes the values from the object to a string.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if ~isempty(obj.GroupName)
                if theVersion >= 14
                    aSignature = sprintf('CUPGRP %s %s\n',obj.GroupName, obj.GroupType);
                else
                    aSignature = sprintf('CUPGRP %s\n',obj.GroupName);
                end
                
                aSignature = [aSignature sprintf('ID %d\n',obj.GroupId)];
                aSignature = [aSignature sprintf('GNDREF %s\n',obj.GroundReference)];
                aSignature = [aSignature sprintf('TWTYPE %s\n',obj.TerminalWidthType)];
                
                if ~isempty(obj.ReferencePlanes)
                    aSignature = [aSignature obj.ReferencePlanes.stringSignature(theVersion)];
                end
                
                for iCounter=1:length(obj.UnknownLines)
                    aSignature = [aSignature sprintf('%s\n',obj.UnknownLines{iCounter})]; %#ok<AGROW>
                end
                
                aSignature = [aSignature sprintf('END\n')];
                
            end
            
        end
        
    end
    
end

