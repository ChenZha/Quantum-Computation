classdef SonnetGeometryComponent < handle
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This class defines the values for an component
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
        
        Name
        Level
        Id
        Type                        % Can be NONE, IDEAL, or SPARAM
        GroundReference
        TerminalWidthType
        TerminalWidth
        ArrayOfPorts
        ReferencePlanes
        
        DisplayPackageSize
        PackageLength
        PackageWidth
        PackageHeight
        
        UnknownLines
        
    end
    
    properties (Dependent=true)
        
        LabelPositionXCoordinate
        LabelPositionYCoordinate
        
        SchematicBoxLeftPosition
        SchematicBoxRightPosition
        SchematicBoxTopPosition
        SchematicBoxBottomPosition
        
        Port1
        Port2
        
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = SonnetGeometryComponent(theFid)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Defines the constructor for the SMD block.
            % The constructor will be passed the file ID from the
            %     SONNET GEO object constructor.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if nargin == 1
                
                initialize(obj);
                
                % clear the ArrayOfPorts value; this is incorrectly constructed by the
                % initialize method calling the set methods for the port1 and port2
                % properties
                obj.ArrayOfPorts={};
                
                %read in LevelNumber and Label
                obj.Level=fscanf(theFid,'%d',1);
                obj.Name=fscanf(theFid,'%s',1);
                
                while(1==1)
                    
                    % Read a string from the file,  we will use this to determine what property needs to be modified by using a case statement.
                    aTempString=fscanf(theFid,' %s',1); 		% Read a Value from the file, we will be using this to drive the switch statment
                    
                    switch aTempString
                        
                        case 'ID'
                            obj.Id=fscanf(theFid,'%d',1);
                            
                        case 'GNDREF'
                            obj.GroundReference=fscanf(theFid,'%s',1);
                            
                        case 'TWTYPE'
                            obj.TerminalWidthType=fscanf(theFid,'%s',1);
                            
                        case 'TWVALUE'
                            obj.TerminalWidth=fscanf(theFid,'%f',1);
                            
                        case 'DRP1'
                            if isempty(obj.ReferencePlanes)                 % If we dont have a ReferencePlanes entry yet then make a new object for one
                                obj.ReferencePlanes=SonnetGeometryReferencePlane(theFid);
                            else                                            % If we already have an object for our ReferencePlanes entries then just add this one to the object using its add function
                                obj.ReferencePlanes.addNewSideFromFile(theFid);       % Tells the object to add a new Parallel subsection as defined from the file
                            end
                            
                        case 'PBSHW'
                            obj.DisplayPackageSize=fscanf(theFid,'%s',1);
                            
                        case 'PKG'
                            obj.PackageLength=fscanf(theFid,'%f',1);
                            obj.PackageWidth=fscanf(theFid,'%f',1);
                            obj.PackageHeight=fscanf(theFid,'%f',1);
                            
                        case 'TYPE'
                            aTempString=fscanf(theFid,'%s',1);
                            
                            if strcmp(aTempString,'IDEAL')==1
                                obj.Type.Type='IDEAL';
                                obj.Type.Idealtype=fscanf(theFid,'%s',1);
                                obj.Type.Compval=fscanf(theFid,'%s',1);
                                
                                % If Compval is a string for a
                                % number then make it a number in memory
                                if ~isnan(str2double(obj.Type.Compval))
                                    obj.Type.Compval = str2double(obj.Type.Compval);
                                end
                                
                            elseif strcmp(aTempString,'SPARAM')==1
                                obj.Type.Type='SPARAM';
                                obj.Type.paramfileindex=fscanf(theFid,'%d',1);
                                
                            elseif strcmp(aTempString,'NONE')==1
                                obj.Type.Type='NONE';
                            end
                            
                        case 'SMDP'
                            aPort=SonnetGeometryComponentPort(theFid);
                            obj.ArrayOfPorts{length(obj.ArrayOfPorts)+1}=aPort;
                            
                        case 'PBOX'
                            fscanf(theFid,'%f',1);
                            fscanf(theFid,'%f',1);
                            fscanf(theFid,'%f',1);
                            fscanf(theFid,'%f',1);
                            
                        case 'LPOS'
                            fscanf(theFid,'%f',1);
                            fscanf(theFid,'%f',1);
                            
                        case 'SBOX'
                            fscanf(theFid,'%f',1);
                            fscanf(theFid,'%f',1);
                            fscanf(theFid,'%f',1);
                            fscanf(theFid,'%f',1);
                            
                        case 'FIX'
                            fgetl(theFid);
                            
                        case 'END'
                            break;
                            
                        otherwise                                                                   % If we dont recognize the line then we want to save it so we can write it out again.
                            obj.UnknownLines = [obj.UnknownLines aTempString fgetl(theFid) ' \n'];	% Add the line to the unknownlines array
                            
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
        function isResistor=isResistorComponent(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Returns true if the polygon is a Resistor Component
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if strcmp(obj.Type.Type, 'IDEAL')==1 && strcmp(obj.Type.Idealtype, 'RES')==1
                isResistor=true;
            else
                isResistor=false;
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function isCapacitor=isCapacitorComponent(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Returns true if the polygon is a Capacitor Component
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if strcmp(obj.Type.Type, 'IDEAL')==1 && strcmp(obj.Type.Idealtype, 'CAP')==1
                isCapacitor=true;
            else
                isCapacitor=false;
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function isInductor=isInductorComponent(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Returns true if the polygon is a Inductor Component
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if strcmp(obj.Type.Type, 'IDEAL')==1 && strcmp(obj.Type.Idealtype, 'IND')==1
                isInductor=true;
            else
                isInductor=false;
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function isDataFile=isDataFileComponent(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Returns true if the polygon is a Data File Component
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if strcmp(obj.Type.Type, 'SPARAM')==1
                isDataFile=true;
            else
                isDataFile=false;
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
            aNewObject=SonnetGeometryComponent();
            SonnetClone(obj,aNewObject);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function writeObjectContents(obj, theFid, thePortCount, theVersion)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function writes the values from the object to a file.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            fprintf(theFid,'%s',obj.stringSignature(thePortCount,theVersion));
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aSignature=stringSignature(obj,thePortCount,theVersion)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function writes the values from the object to a string.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            aSignature='SMD';
            
            if ~isempty(obj.Level)
                aSignature = [aSignature sprintf(' %d',obj.Level)];
            end
            
            if ~isempty(obj.Name)
                obj.Name=strrep(obj.Name,'"','');	% first get rid of all the quotation marks so that we dont have multiple sets of quotation marks in the string.
                obj.Name=['"' obj.Name '"'];		% add quotes to the label because the label must be wrapped in quotes.
                aSignature = [aSignature sprintf(' %s',obj.Name)];
            end
            
            aSignature = [aSignature sprintf('\n')];
            
            if ~isempty(obj.Id)
                aSignature = [aSignature sprintf('ID %d\n',obj.Id)];
            end
            
            if ~isempty(obj.GroundReference)
                aSignature = [aSignature sprintf('GNDREF %s\n',obj.GroundReference)];
            end
            
            if ~isempty(obj.TerminalWidthType) && strcmpi(obj.TerminalWidthType,'CUST')==0
                aSignature = [aSignature sprintf('TWTYPE %s\n',obj.TerminalWidthType)];
            else
                aSignature = [aSignature sprintf('TWTYPE CUST\n')];
                aSignature = [aSignature sprintf('TWVALUE %.15g\n',obj.TerminalWidth)];
            end
            
            if ~isempty(obj.ReferencePlanes)
                aSignature = [aSignature obj.ReferencePlanes.stringSignature(theVersion)];
            end
            
            if ~isempty(obj.SchematicBoxLeftPosition)
                aSignature = [aSignature sprintf('SBOX %.15g',obj.SchematicBoxLeftPosition)];
                aSignature = [aSignature sprintf(' %.15g',obj.SchematicBoxRightPosition)];
                aSignature = [aSignature sprintf(' %.15g',obj.SchematicBoxTopPosition)];
                aSignature = [aSignature sprintf(' %.15g\n',obj.SchematicBoxBottomPosition)];
            end
            
            if isempty(obj.DisplayPackageSize) || strcmpi(obj.DisplayPackageSize,'N')==1
                aSignature = [aSignature sprintf('PBSHW N\n')];
            else
                aSignature = [aSignature sprintf('PBSHW Y\n')];
            end
            
            if ~isempty(obj.PackageLength)
                aSignature = [aSignature sprintf('PKG %.15g',obj.PackageLength)];
                aSignature = [aSignature sprintf(' %.15g',obj.PackageWidth)];
                aSignature = [aSignature sprintf(' %.15g\n',obj.PackageHeight)];
            end
            
            if ~isempty(obj.LabelPositionXCoordinate) && ~isempty(obj.LabelPositionYCoordinate)
                aSignature = [aSignature sprintf('LPOS %.15g',obj.LabelPositionXCoordinate)];
                aSignature = [aSignature sprintf(' %.15g\n',obj.LabelPositionYCoordinate)];
            end
            
            if ~isempty(obj.Type)
                if strcmp(obj.Type.Type,'IDEAL')==1
                    if isa(obj.Type.Compval,'char')
                        aSignature = [aSignature sprintf('TYPE IDEAL %s %s\n',obj.Type.Idealtype,obj.Type.Compval)];
                    else
                        aSignature = [aSignature sprintf('TYPE IDEAL %s %d\n',obj.Type.Idealtype,obj.Type.Compval)];
                    end
                    
                elseif strcmp(obj.Type.Type,'SPARAM')==1
                    aSignature = [aSignature sprintf('TYPE SPARAM %d\n',obj.Type.paramfileindex)];
                    
                elseif strcmp(obj.Type.Type,'NONE')==1
                    aSignature = [aSignature sprintf('TYPE NONE\n')];
                    
                end
            end
            
            for iCounter= thePortCount:thePortCount+length(obj.ArrayOfPorts)-1
                aSignature = [aSignature obj.ArrayOfPorts{iCounter-thePortCount+1}.stringSignature(iCounter)]; %#ok<AGROW>
            end
            
            if (~isempty(obj.UnknownLines))
                aSignature = [aSignature strrep(obj.UnknownLines,'\n',sprintf('\n'))];
            end
            
            aSignature = [aSignature sprintf('END\n')];
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get/Set functions: We want to change the value of
        % the polygon properties when the coordinates change.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [aPort1X aPort1Y aPort2X aPort2Y]=getPortDimensions(obj)
            % If there is no port1 or port2 then use (0,0)
            if isempty(obj.Port1)
                aPort1X=0;
                aPort1Y=0;
            else
                aPort1X=obj.Port1.XLocation;
                aPort1Y=obj.Port1.YLocation;
            end
            if isempty(obj.Port2)
                aPort2X=0;
                aPort2Y=0;
            else
                aPort2X=obj.Port2.XLocation;
                aPort2Y=obj.Port2.YLocation;
            end
        end
        function [aCenterX aCenterY]=getCenter(obj)
            
            aCenterX=[];
            aCenterY=[];
            
            % If there is a top/bottom port then use its
            % X value as the box center X value
            for iCounter=1:length(obj.ArrayOfPorts)
                if strcmpi(obj.ArrayOfPorts{iCounter}.Orientation,'T')==1
                    aCenterX=obj.ArrayOfPorts{iCounter}.XLocation;
                elseif strcmpi(obj.ArrayOfPorts{iCounter}.Orientation,'B')==1
                    aCenterX=obj.ArrayOfPorts{iCounter}.XLocation;
                end
            end
            
            % If we havent found a center X value then use the 
            % average of the largest and smallest port X values
            aSmallestX=inf;
            aLargestX=-inf;
            for iCounter=1:length(obj.ArrayOfPorts)
                if obj.ArrayOfPorts{iCounter}.XLocation < aSmallestX
                    aSmallestX=obj.ArrayOfPorts{iCounter}.XLocation;
                end
                if obj.ArrayOfPorts{iCounter}.XLocation > aLargestX
                    aLargestX=obj.ArrayOfPorts{iCounter}.XLocation;
                end
            end
            aCenterX=mean([aSmallestX aLargestX]);
            
            % If there is a left/right port then use its
            % Y value as the box center Y value
            for iCounter=1:length(obj.ArrayOfPorts)
                if strcmpi(obj.ArrayOfPorts{iCounter}.Orientation,'L')==1
                    aCenterY=obj.ArrayOfPorts{iCounter}.YLocation;
                elseif strcmpi(obj.ArrayOfPorts{iCounter}.Orientation,'R')==1
                    aCenterY=obj.ArrayOfPorts{iCounter}.YLocation;
                end
            end
            
            % If we havent found a center Y value then use the 
            % average of the largest and smallest port Y values
            aSmallestY=inf;
            aLargestY=-inf;
            for iCounter=1:length(obj.ArrayOfPorts)
                if obj.ArrayOfPorts{iCounter}.XLocation < aSmallestY
                    aSmallestY=obj.ArrayOfPorts{iCounter}.YLocation;
                end
                if obj.ArrayOfPorts{iCounter}.XLocation > aLargestY
                    aLargestY=obj.ArrayOfPorts{iCounter}.YLocation;
                end
            end
            aCenterY=mean([aSmallestY aLargestY]);
            
        end
        function value = get.LabelPositionXCoordinate(obj)
            aCenterX=obj.getCenter();
            value = aCenterX;
        end
        function value = get.LabelPositionYCoordinate(obj)
            [~, aCenterY]=obj.getCenter();
            value = aCenterY;
        end
        function value = get.SchematicBoxLeftPosition(obj)
            [aCenterX aCenterY]=obj.getCenter();
            
            % If there is a custom terminal width number then
            % make the side of the box be 1/2 of the
            % terminal width from the center of the box.
            % % %             if ~isempty(obj.TerminalWidth) && isa(obj.TerminalWidth,'double')
            % % %                 value=aCenterX-0.5*obj.TerminalWidth;
            % % %                 return
            % % %             end
            
            % If there is no terminal width then check if there
            % is a port on the left side. If there is then the
            % side wall should be 75% of the way between 
            % the port's X coordinate and the center.
            aSmallestDistanceFromCenter=inf;
            for iCounter=1:length(obj.ArrayOfPorts)
                if strcmpi(obj.ArrayOfPorts{iCounter}.Orientation,'L')==1
                    aDistanceFromCenter=0.75*abs(aCenterX-obj.ArrayOfPorts{iCounter}.XLocation);
                    if aDistanceFromCenter < aSmallestDistanceFromCenter
                        aSmallestDistanceFromCenter=aDistanceFromCenter;
                        value=aCenterX-aDistanceFromCenter;
                    end
                elseif strcmpi(obj.ArrayOfPorts{iCounter}.Orientation,'R')==1
                    aDistanceFromCenter=0.75*abs(aCenterX-obj.ArrayOfPorts{iCounter}.XLocation);
                    if aDistanceFromCenter < aSmallestDistanceFromCenter
                        aSmallestDistanceFromCenter=aDistanceFromCenter;
                        value=aCenterX-aDistanceFromCenter;
                    end
                end
            end
            if aSmallestDistanceFromCenter < inf
                return
            end
                        
            % If there is no port on either side then 
            % use 0.25% of the larger of the X distance
            % or Y distance of the first port.
            [aPort1X aPort1Y]=obj.getPortDimensions();
            if abs(aCenterX-aPort1X) > abs(aCenterY-aPort1Y) 
                aDistanceFromCenter=0.25*abs(aCenterX-aPort1X);
                value=aCenterX-aDistanceFromCenter;
                return
            else
                aDistanceFromCenter=0.25*abs(aCenterY-aPort1Y);
                value=aCenterX-aDistanceFromCenter;
                return
            end
        end
        function value = get.SchematicBoxRightPosition(obj)
            [aCenterX aCenterY]=obj.getCenter();
            
            % If there is a custom terminal width number then
            % make the side of the box be 1/2 of the
            % terminal width from the center of the box.
            % % %             if ~isempty(obj.TerminalWidth) && isa(obj.TerminalWidth,'double')
            % % %                 value=aCenterX+0.5*obj.TerminalWidth;
            % % %                 return
            % % %             end
            
            % If there is no terminal width then check if there
            % is a port on the side. If there is then the
            % side wall should be 75% of the way between 
            % the port's X coordinate and the center.
            aSmallestDistanceFromCenter=inf;
            for iCounter=1:length(obj.ArrayOfPorts)
                if strcmpi(obj.ArrayOfPorts{iCounter}.Orientation,'L')==1
                    aDistanceFromCenter=0.75*abs(aCenterX-obj.ArrayOfPorts{iCounter}.XLocation);
                    if aDistanceFromCenter < aSmallestDistanceFromCenter
                        aSmallestDistanceFromCenter=aDistanceFromCenter;
                        value=aCenterX+aDistanceFromCenter;
                    end
                elseif strcmpi(obj.ArrayOfPorts{iCounter}.Orientation,'R')==1
                    aDistanceFromCenter=0.75*abs(aCenterX-obj.ArrayOfPorts{iCounter}.XLocation);
                    if aDistanceFromCenter < aSmallestDistanceFromCenter
                        aSmallestDistanceFromCenter=aDistanceFromCenter;
                        value=aCenterX+aDistanceFromCenter;
                    end
                end
            end
            if aSmallestDistanceFromCenter < inf
                return
            end
                                    
            % If there is no port on either side then 
            % use 0.25% of the larger of the X distance
            % or Y distance of the first port.
            [aPort1X aPort1Y]=obj.getPortDimensions();
            if abs(aCenterX-aPort1X) > abs(aCenterY-aPort1Y) 
                aDistanceFromCenter=0.25*abs(aCenterX-aPort1X);
                value=aCenterX+aDistanceFromCenter;
                return
            else
                aDistanceFromCenter=0.25*abs(aCenterY-aPort1Y);
                value=aCenterX+aDistanceFromCenter;
                return
            end
        end
        function value = get.SchematicBoxTopPosition(obj)
            [aCenterX aCenterY]=obj.getCenter();
            
            % If there is a custom terminal width number then
            % make the side of the box be 1/2 of the
            % terminal width from the center of the box.
            % % %             if ~isempty(obj.TerminalWidth) && isa(obj.TerminalWidth,'double')
            % % %                 value=aCenterY-0.5*obj.TerminalWidth;
            % % %                 return
            % % %             end
            
            % If there is no terminal width then check if there
            % is a port on the side. If there is then the
            % side wall should be 75% of the way between 
            % the port's Y coordinate and the center.
            aSmallestDistanceFromCenter=inf;
            for iCounter=1:length(obj.ArrayOfPorts)
                if strcmpi(obj.ArrayOfPorts{iCounter}.Orientation,'T')==1
                    aDistanceFromCenter=0.75*abs(aCenterY-obj.ArrayOfPorts{iCounter}.YLocation);
                    if aDistanceFromCenter < aSmallestDistanceFromCenter
                        aSmallestDistanceFromCenter=aDistanceFromCenter;
                        value=aCenterY-aDistanceFromCenter;
                    end
                elseif strcmpi(obj.ArrayOfPorts{iCounter}.Orientation,'B')==1
                    aDistanceFromCenter=0.75*abs(aCenterY-obj.ArrayOfPorts{iCounter}.YLocation);
                    if aDistanceFromCenter < aSmallestDistanceFromCenter
                        aSmallestDistanceFromCenter=aDistanceFromCenter;
                        value=aCenterY-aDistanceFromCenter;
                    end
                end
            end
            if aSmallestDistanceFromCenter < inf
                return
            end
            
            % If there is no port on either side then 
            % use 0.25% of the larger of the X distance
            % or Y distance of the first port.
            [aPort1X aPort1Y]=obj.getPortDimensions();
            if abs(aCenterX-aPort1X) > abs(aCenterY-aPort1Y) 
                aDistanceFromCenter=0.25*abs(aCenterX-aPort1X);
                value=aCenterY-aDistanceFromCenter;
                return
            else
                aDistanceFromCenter=0.25*abs(aCenterY-aPort1Y);
                value=aCenterY-aDistanceFromCenter;
                return
            end
        end
        function value = get.SchematicBoxBottomPosition(obj)
            [aCenterX aCenterY]=obj.getCenter();
            
            % If there is a custom terminal width number then
            % make the side of the box be 1/2 of the
            % terminal width from the center of the box.
            % % %             if ~isempty(obj.TerminalWidth) && isa(obj.TerminalWidth,'double')
            % % %                 value=aCenterY+0.5*obj.TerminalWidth;
            % % %                 return
            % % %             end
            
            % If there is no terminal width then check if there
            % is a port on the side. If there is then the
            % side wall should be 75% of the way between 
            % the port's Y coordinate and the center.
            aSmallestDistanceFromCenter=inf;
            for iCounter=1:length(obj.ArrayOfPorts)
                if strcmpi(obj.ArrayOfPorts{iCounter}.Orientation,'T')==1
                    aDistanceFromCenter=0.75*abs(aCenterY-obj.ArrayOfPorts{iCounter}.YLocation);
                    if aDistanceFromCenter < aSmallestDistanceFromCenter
                        aSmallestDistanceFromCenter=aDistanceFromCenter;
                        value=aCenterY+aDistanceFromCenter;
                    end
                elseif strcmpi(obj.ArrayOfPorts{iCounter}.Orientation,'B')==1
                    aDistanceFromCenter=0.75*abs(aCenterY-obj.ArrayOfPorts{iCounter}.YLocation);
                    if aDistanceFromCenter < aSmallestDistanceFromCenter
                        aSmallestDistanceFromCenter=aDistanceFromCenter;
                        value=aCenterY+aDistanceFromCenter;
                    end
                end
            end
            if aSmallestDistanceFromCenter < inf
               return 
            end
            
            % If there is no port on either side then 
            % use 0.25% of the larger of the X distance
            % or Y distance of the first port.
            [aPort1X aPort1Y]=obj.getPortDimensions();
            if abs(aCenterX-aPort1X) > abs(aCenterY-aPort1Y) 
                aDistanceFromCenter=0.25*abs(aCenterX-aPort1X);
                value=aCenterY+aDistanceFromCenter;
                return
            else
                aDistanceFromCenter=0.25*abs(aCenterY-aPort1Y);
                value=aCenterY+aDistanceFromCenter;
                return
            end
        end
        function value = get.Port1(obj)
            if isempty(obj.ArrayOfPorts)
                value=[];
            else
                value=obj.ArrayOfPorts{1};
            end
        end
        function value = get.Port2(obj)
            if isempty(obj.ArrayOfPorts)
                value=[];
            elseif length(obj.ArrayOfPorts) == 1 || isempty(obj.ArrayOfPorts{2})
                value=obj.ArrayOfPorts{1};
            else
                value=obj.ArrayOfPorts{2};
            end
        end
        function set.Port1(obj,value)
            obj.ArrayOfPorts{1}=value;
        end
        function set.Port2(obj,value)
            obj.ArrayOfPorts{2}=value;
        end
        function set.LabelPositionXCoordinate(obj,~) %#ok<MANU>
            warning 'This value may not be modified.'
        end
        function set.LabelPositionYCoordinate(obj,~) %#ok<MANU>
            warning 'This value may not be modified.'
        end
        function set.SchematicBoxLeftPosition(obj,~) %#ok<MANU>
            warning 'This value may not be modified.'
        end
        function set.SchematicBoxRightPosition(obj,~) %#ok<MANU>
            warning 'This value may not be modified.'
        end
        function set.SchematicBoxTopPosition(obj,~) %#ok<MANU>
            warning 'This value may not be modified.'
        end
        function set.SchematicBoxBottomPosition(obj,~) %#ok<MANU>
            warning 'This value may not be modified.'
        end
        
    end
    
end

