classdef SonnetGeometryReferencePlane < handle
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This class defines the values for an reference plane
    % in the Geometry block of the Sonnet project file.
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
        
        LeftSide
        RightSide
        TopSide
        BottomSide
        
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = SonnetGeometryReferencePlane(theFid)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Defines the constructor for the reference plane. This
            %     will read a single value from the file and store it
            %     in the object for the appropriate side.  Additional
            %     reference planes are added to this object via
            %     the addNewSideFromFile function.
            % The constructor will be passed the file ID from the
            %     SONNET GEO object constructor.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if nargin == 1
                
                initialize(obj);
                
                obj.addNewSideFromFile(theFid);
                
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
        function addNewSideFromFile(obj,theFid)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function will make another side using passed values
            % and store it in the object so that all the Drp1 distances
            % are all defined within a single object.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            theSide=fscanf(theFid,'%s',1);                  % Read in the string that specifies which side the reference plane is on
            
            if strcmp(theSide,'TOP')==1
                aTempString=fscanf(theFid,' %s',1);         % Read in whether the reference plane is FIX or not. if it is FIX then we just need to read in one value (by making a FIX object) otherwise we will read in a polygon with the LINK object contructor
                if strcmp(aTempString,'FIX')==1
                    obj.TopSide=SonnetGeometryReferencePlaneFix(theFid);
                elseif strcmp(aTempString,'LINK')==1
                    obj.TopSide=SonnetGeometryReferencePlaneLink(theFid);
                else
                    obj.TopSide=SonnetGeometryReferencePlaneNone(theFid);
                end
                
            elseif strcmp(theSide,'RIGHT')==1
                aTempString=fscanf(theFid,' %s',1);         % Read in whether the reference plane is FIX or not. if it is FIX then we just need to read in one value (by making a FIX object) otherwise we will read in a polygon with the LINK object contructor
                if strcmp(aTempString,'FIX')==1
                    obj.RightSide=SonnetGeometryReferencePlaneFix(theFid);
                elseif strcmp(aTempString,'LINK')==1
                    obj.RightSide=SonnetGeometryReferencePlaneLink(theFid);
                else
                    obj.RightSide=SonnetGeometryReferencePlaneNone(theFid);
                end
                
            elseif strcmp(theSide,'LEFT')==1
                aTempString=fscanf(theFid,' %s',1);         % Read in whether the reference plane is FIX or not. if it is FIX then we just need to read in one value (by making a FIX object) otherwise we will read in a polygon with the LINK object contructor
                if strcmp(aTempString,'FIX')==1
                    obj.LeftSide=SonnetGeometryReferencePlaneFix(theFid);
                elseif strcmp(aTempString,'LINK')==1
                    obj.LeftSide=SonnetGeometryReferencePlaneLink(theFid);
                else
                    obj.LeftSide=SonnetGeometryReferencePlaneNone(theFid);
                end
                
            elseif strcmp(theSide,'BOTTOM')==1
                aTempString=fscanf(theFid,' %s',1);         % Read in whether the reference plane is FIX or not. if it is FIX then we just need to read in one value (by making a FIX object) otherwise we will read in a polygon with the LINK object contructor
                if strcmp(aTempString,'FIX')==1
                    obj.BottomSide=SonnetGeometryReferencePlaneFix(theFid);
                elseif strcmp(aTempString,'LINK')==1
                    obj.BottomSide=SonnetGeometryReferencePlaneLink(theFid);
                else
                    obj.BottomSide=SonnetGeometryReferencePlaneNone(theFid);
                end
                
            else
                fgetl(theFid);                              % If it doesnt recognize any of them then just ignore it.
                
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addNewSide(obj,theSide,theTypeOfReferencePlane,theLengthOrPolygon,theVertex)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function will make another side using passed values
            % and store it in the object so that all the Drp1 distances
            % are all defined within a single object.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if strcmp(theSide,'TOP')==1
                if strcmp(theTypeOfReferencePlane,'FIX')==1
                    obj.TopSide=SonnetGeometryReferencePlaneFix();
                    obj.TopSide.Length=theLengthOrPolygon;
                elseif strcmp(theTypeOfReferencePlane,'LINK')==1
                    obj.TopSide=SonnetGeometryReferencePlaneLink();
                    obj.TopSide.Polygon=theLengthOrPolygon;
                    obj.TopSide.Vertex=theVertex;
                else
                    obj.TopSide=SonnetGeometryReferencePlaneNone();
                    obj.TopSide.Length=theLengthOrPolygon;
                end
                
            elseif strcmp(theSide,'RIGHT')==1
                if strcmp(theTypeOfReferencePlane,'FIX')==1
                    obj.RightSide=SonnetGeometryReferencePlaneFix();
                    obj.RightSide.Length=theLengthOrPolygon;
                elseif strcmp(theTypeOfReferencePlane,'LINK')==1
                    obj.RightSide=SonnetGeometryReferencePlaneLink();
                    obj.RightSide.Polygon=theLengthOrPolygon;
                    obj.RightSide.Vertex=theVertex;
                else
                    obj.RightSide=SonnetGeometryReferencePlaneNone();
                    obj.RightSide.Length=theLengthOrPolygon;
                end
                
            elseif strcmp(theSide,'LEFT')==1
                if strcmp(theTypeOfReferencePlane,'FIX')==1
                    obj.LeftSide=SonnetGeometryReferencePlaneFix();
                    obj.LeftSide.Length=theLengthOrPolygon;
                elseif strcmp(theTypeOfReferencePlane,'LINK')==1
                    obj.LeftSide=SonnetGeometryReferencePlaneLink();
                    obj.LeftSide.Polygon=theLengthOrPolygon;
                    obj.LeftSide.Vertex=theVertex;
                else
                    obj.LeftSide=SonnetGeometryReferencePlaneNone();
                    obj.LeftSide.Length=theLengthOrPolygon;
                end
                
            elseif strcmp(theSide,'BOTTOM')==1
                if strcmp(theTypeOfReferencePlane,'FIX')==1
                    obj.BottomSide=SonnetGeometryReferencePlaneFix();
                    obj.BottomSide.Length=theLengthOrPolygon;
                elseif strcmp(theTypeOfReferencePlane,'LINK')==1
                    obj.BottomSide=SonnetGeometryReferencePlaneLink();
                    obj.BottomSide.Polygon=theLengthOrPolygon;
                    obj.BottomSide.Vertex=theVertex;
                else
                    obj.BottomSide=SonnetGeometryReferencePlaneNone();
                    obj.BottomSide.Length=theLengthOrPolygon;
                end
                
            else
                error('Improper argument for the side the reference plane is on.');
                
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function initialize(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function initializes the DRP1 properties to some default
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
            aNewObject=SonnetGeometryReferencePlane();
            SonnetClone(obj,aNewObject);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function writeObjectContents(obj, theFid, theVersion)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function writes the values from the object to a file.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            fprintf(theFid,'%s',obj.stringSignature(theVersion));
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aSignature=stringSignature(obj,theVersion) %#ok<INUSD>
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function writes the values from the object to a string.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            aSignature = '';
            
            if ~isempty(obj.LeftSide)
                aSignature = [aSignature sprintf('DRP1 LEFT ')];
                aSignature = [aSignature obj.LeftSide.stringSignature(theVersion)];
            end
            
            if ~isempty(obj.RightSide)
                aSignature = [aSignature sprintf('DRP1 RIGHT ')];
                aSignature = [aSignature obj.RightSide.stringSignature(theVersion)];
            end
            
            if ~isempty(obj.TopSide)
                aSignature = [aSignature sprintf('DRP1 TOP ')];
                aSignature = [aSignature obj.TopSide.stringSignature(theVersion)];
            end
            
            if ~isempty(obj.BottomSide)
                aSignature = [aSignature sprintf('DRP1 BOTTOM ')];
                aSignature = [aSignature obj.BottomSide.stringSignature(theVersion)];
            end
            
        end
        
        
    end
end

