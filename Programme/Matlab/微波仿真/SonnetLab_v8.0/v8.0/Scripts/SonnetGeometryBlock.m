classdef SonnetGeometryBlock < handle
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This class defines the GEO portion of a SONNET project file.
    % This class is a container for the Geometry information that is obtained
    % from the SONNET project file.
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
        
        SonnetBox
        IsSymmetric
        TopCoverMetal
        BottomCoverMetal
        LocalOrigin
        VNCells
        
        ArrayOfMetalTypes
        ParallelSubsections
        ReferencePlanes
        ArrayOfDimensions
        ArrayOfDielectricMaterials
        ArrayOfVariables
        ArrayOfParameters
        ArrayOfEdgeVias
        ArrayOfPorts
        ArrayOfComponents
        ArrayOfCoCalibratedGroups
        ArrayOfPolygons
        ArrayOfTechLayers
        
        IsAutoHeightVias % added for v15
        SnapAngle        % added for v15 valid values are {90, 45, 30, 22.5 5}   
        
        UnknownLines
        
        AutoDelete=true;        
        
    end
    
    properties (SetAccess = private, GetAccess = private)
        DoneConstructing=false;
        ArrayOfListeners
    end
    
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function nominalChangedEvent(obj, src, evnt)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % updates the associating values for a parameter
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            for i =1:length(obj.ArrayOfVariables)
                if strcmpi(obj.ArrayOfVariables{i}.VariableName, src.Parname)
                    obj.ArrayOfVariables{i}.IsValueUpdated = true;
                    obj.ArrayOfVariables{i}.Value = src.NominalValue;
                    obj.ArrayOfVariables{i}.IsValueUpdated = false;
                end            
            end       
            
             for i =1:length(obj.ArrayOfParameters)
                if  obj.ArrayOfParameters{i} ~= src
                    if strcmpi(obj.ArrayOfParameters{i}.Parname, src.Parname)
                        obj.ArrayOfParameters{i}.IsNominalValueUpdated = true;
                        obj.ArrayOfParameters{i}.NominalValue = src.Value;                    
                        obj.ArrayOfParameters{i}.IsNominalValueUpdated = false;
                    end  
                end
            end     
        end
                
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function valueChangedEvent(obj, src, evnt)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % updates the associating values for a parameter
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            for i =1:length(obj.ArrayOfParameters)
                if strcmpi(obj.ArrayOfParameters{i}.Parname, src.VariableName)
                    obj.ArrayOfParameters{i}.IsNominalValueUpdated = true;
                    obj.ArrayOfParameters{i}.NominalValue = src.Value;                    
                    obj.ArrayOfParameters{i}.IsNominalValueUpdated = false;
                end            
            end       
        end 
    end    
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = SonnetGeometryBlock(theFid)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % define the constructor for the GEO block.
            %     the constructor will be passed the file ID from the
            %     SONNET project constructor.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if nargin == 1
                
                initialize(obj);
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % We are going to loop and read initial tags
                %		for all the lines in the GEO block and
                %		move to the appropriate case depending
                %		on the input.  This is necessary to
                %		allow for statements to be in different
                %		orders.
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                isKeepLooping=true;
                
                % Initialize all the geometry component arrays
                aTopCoverMetal={};
                aBottomCoverMetal={};
                aSonnetBox={};
                aIsSymmetric={};
                aParallelSubsections={};
                aReferencePlanes={};
                aArrayOfElectricVias={};
                aLocalOrigin={};
                aArrayOfDimensions={};
                aArrayOfDielectricMaterials={};
                aArrayOfVariables={};
                aArrayOfParameters={};
                aArrayOfPorts={};
                aArrayOfComponents={};
                aArrayOfPolygons={};
                aArrayOfCoCalibratedGroups={};
                aArrayOfMetalTypes={};
                aArrayOfTechLayers={};
                aVNCells={};
                aIsAutoHeightVias={}; 
                aSnapAngle={};
                
                % We loop when true and quit when false.
                while(isKeepLooping)
                    
                    % Read a string from the file,  we will use this to determine what property needs to be modified by using a case statement.
                    aTempString=fscanf(theFid,' %s',1);                                 % Read a Value from the file, we will be using this to drive the switch statment
                    
                    switch aTempString
                        
                        case 'SYM'                                                      % If we read in the line defining the symmetry then modify the property for it accordingly
                            aIsSymmetric = 'True';
                            
                        case 'TMET'                                                     % If we read in the line defining the top of the box then make the appropriate object and assign it to the property
                            aTopCoverMetal=SonnetGeometryTopAndBottomMetals(theFid);
                            
                        case 'BMET'                                                     % If we read in the line defining the bottom of the box then make the appropriate object and assign it to the property
                            aBottomCoverMetal=SonnetGeometryTopAndBottomMetals(theFid);
                            
                        case 'MET'                                                      % If we read in the line defining the a piece of metal then make the appropriate object and assign it to the property
                            aArrayOfMetalTypes{length(aArrayOfMetalTypes)+1}=...
                                SonnetGeometryMetalType(theFid);                  % Add another metal to an array of metals
                            
                        case 'BOX'                                                      % If we read in the line defining the box then make the appropriate object and assign it to the property
                            aSonnetBox=SonnetGeometryBox(theFid);
                           
                        case 'TECHLAY'

                            aArrayOfTechLayers{length(aArrayOfTechLayers)+1}=...
                                SonnetGeometryTechLayer(theFid);                        % Add tech layer to an array og tech layers 
                            
                        case 'PSB1'                                                     % If we read in the line defining the Parallel Subsections then make the appropriate object and assign it to the property
                            if isempty(aParallelSubsections)                            % If we dont have a ParallelSubsections entry yet then make a new object for one
                                aParallelSubsections=SonnetGeometryParallelSubsection(theFid);
                            else                                                        % If we already have an object for our ParallelSubsections entries then just add this one to the object using its add function
                                aParallelSubsections.addNewSideFromFile(theFid);        % Tells the object to add a new Parallel subsection as defined from the file
                            end
                            
                        case 'DRP1'                                                     % Defines attributes for an individual reference plane for the box.  There can be 4 such planes.
                            if isempty(aReferencePlanes)                                % If we dont have a DRP1 entry yet then make a new object for one
                                aReferencePlanes=SonnetGeometryReferencePlane(theFid);
                            else                                                        % If we already have an object for our DRP1 entries then just add this one to the object using its add function
                                aReferencePlanes.addNewSideFromFile(theFid);            % Tells the object to add a new Parallel subsection as defined from the file
                            end
                            
                        case 'DIM'                                                      % If we read in the line defining the Parallel Subsections then make the appropriate object and assign it to the property
                            aArrayOfDimensions{length(aArrayOfDimensions)+1}=...
                                SonnetGeometryDimension(theFid);                        % Add another metal to an array of DIMs
                            
                        case 'BRI'                                                      % If we read in the line defining an isotropic dielectric material then make an object for it
                            aArrayOfDielectricMaterials{length(aArrayOfDielectricMaterials)+1}=...
                                SonnetGeometryIsotropic(theFid);
                            
                        case 'BRA'                                                      % If we read in the line defining an anisotropic dielectric material then make an object for it
                            aArrayOfDielectricMaterials{length(aArrayOfDielectricMaterials)+1}=...
                                SonnetGeometryAnisotropic(theFid);
                            
                        case 'VALVAR'                                                   % If we read in a variable value then lets make a variable object to store its information
                            aArrayOfVariables{length(aArrayOfVariables)+1}=...
                                SonnetGeometryVariable(theFid);
                            
                        case 'GEOVAR'                                                   % Defines the beginning of a GEOVAR sub-block
                            aArrayOfParameters{length(aArrayOfParameters)+1}=...
                                SonnetGeometryParameter(theFid);                        % Add another metal to an array of metals
                            
                        case 'EVIA1'
                            aArrayOfElectricVias{length(aArrayOfElectricVias)+1}=...
                                SonnetGeometryEdgeVia(theFid);
                            
                        case 'POR1'                                                     % If we read in the line defining a port in the circuit then make a port object
                            aArrayOfPorts{length(aArrayOfPorts)+1}=...
                                SonnetGeometryPort(theFid);                             % Add another port to an array of ports
                            
                        case 'SMD'                                                      % Defines a component in the circuit by identifying the type of component, location of the schematic box, port properties, label and reference planes.
                            aArrayOfComponents{length(aArrayOfComponents)+1}=...
                                SonnetGeometryComponent(theFid);                        % Add another metal to an array of metals
                            
                        case 'CUPGRP'                                                   % If we read in the line defining the number of polygons then create a NUM object and read in the polygons
                            aArrayOfCoCalibratedGroups{length(aArrayOfCoCalibratedGroups)+1}=...
                                SonnetGeometryCoCalibratedGroup(theFid);                % Add another port to an array of ports
                            
                            aIndex = length(aArrayOfCoCalibratedGroups);
                            if strcmp(aArrayOfCoCalibratedGroups{aIndex}.GroupType, 'LOCAL')
                                aArrayOfPorts{length(aArrayOfPorts)}.GroupId = aArrayOfCoCalibratedGroups{aIndex}.GroupId;
                            end
                                                        
                        case 'NUM'                                                      % If we read in the line defining the number of polygons then create a NUM object and read in the polygons
                            aNumberOfPolygons=str2double(fgetl(theFid));                % read in the number of polygons
                            aArrayOfPolygons=cell(1,aNumberOfPolygons);
                            for iCounter=1:aNumberOfPolygons                            % Loop so that we read all the polygons that we need to read
                                aArrayOfPolygons{iCounter}=SonnetGeometryPolygon(theFid);
                            end
                            
                        case 'LORGN'                                                    % If we get a line defining a local origin. This is not present in Sonnet project versions <13
                            aLocalOrigin.X=fscanf(theFid,'%g',1);
                            aLocalOrigin.Y=fscanf(theFid,'%g',1);
                            aLocalOrigin.Locked=strtrim(fgetl(theFid));
                            
                        case 'END'                                                      % If the input was END then we are done with this block and can move on to the next block
                            aTempString=fgetl(theFid);
                            if strcmp(aTempString,' GEO')==1
                                isKeepLooping=false;                                    % Indicate that we should stop looping.
                            end
                            
                        case 'VNCELLS'
                            aVNCells.X=SonnetStringReadFormat(theFid);
                            
                            if ~isnumeric(aVNCells.X)                            
                                aVNCells.X=strrep(aVNCells.X,'"','');
                            end
                            
                            aVNCells.Y=SonnetStringReadFormat(theFid);
                            
                            if ~isnumeric(aVNCells.Y)                            
                                aVNCells.Y=strrep(aVNCells.Y,'"','');
                            end
                        case 'VGMODE'
                            aTempString=fscanf(theFid,' %s',1);
                            
                            if strcmp(aTempString,'STOP')==1
                                aIsAutoHeightVias='True';
                            end   
                            
                        case 'SNPANG'
                            aTempString=fscanf(theFid,' %s',1);
                            [aSnapAngle, aStatus] = str2double(aTempString);                                                                        
                            
                            if aStatus == 0  
                                aSnapAngle=[];
                                warning('Invalid Snap Angle value %s found. Numeric value expected. Value will be ignored.');                            
                            end
                                                        
                        case '\n'                                                       % If the input was \n then do nothing; just go back to the top of the loop.
                            continue;
                            
                        otherwise
                            obj.UnknownLines = [obj.UnknownLines aTempString fgetl(theFid) '\n'];	% Add the line to the uknownlines array
                    end
                    
                end
                
                % Assign the arrays to the properties
                obj.TopCoverMetal=aTopCoverMetal;
                obj.BottomCoverMetal=aBottomCoverMetal;
                obj.SonnetBox=aSonnetBox;
                obj.IsSymmetric=aIsSymmetric;
                obj.ParallelSubsections=aParallelSubsections;
                obj.ReferencePlanes=aReferencePlanes;
                obj.ArrayOfEdgeVias=aArrayOfElectricVias;
                obj.LocalOrigin=aLocalOrigin;
                obj.ArrayOfDimensions=aArrayOfDimensions;
                obj.ArrayOfDielectricMaterials=aArrayOfDielectricMaterials;
                obj.ArrayOfVariables=aArrayOfVariables;
                obj.ArrayOfParameters=aArrayOfParameters;
                obj.ArrayOfPorts=aArrayOfPorts;
                obj.ArrayOfComponents=aArrayOfComponents;
                obj.ArrayOfCoCalibratedGroups=aArrayOfCoCalibratedGroups;
                obj.ArrayOfMetalTypes=aArrayOfMetalTypes;
                obj.ArrayOfPolygons=aArrayOfPolygons;
                obj.ArrayOfTechLayers=aArrayOfTechLayers;
                obj.VNCells=aVNCells;
                % Assign polygon references to the ports
                obj.assignPolygonReferences();
                obj.IsAutoHeightVias=aIsAutoHeightVias;
                obj.SnapAngle=aSnapAngle;
                
            else
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % we come here when we didn't recieve a file ID as an argument
                % which means that we are going to create a default GEO block with
                % default values by calling the function's initialize method.
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                initialize(obj);
                
            end
                        
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % we now are going to set a variable tha keeps track of whether
            % we are done constructing or not. This variable is used when
            % deleting polygons with VIAs; if the polygon holding a VIA is
            % deleted then the VIA should be deleted too. The reason why
            % we do this is because we dont want to have the function
            % delete VIAs while reading from file because the VIAs
            % are read in before the polygons.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.DoneConstructing=true;
           
            if ~isempty(obj.ArrayOfParameters)                
                for i =1:length(obj.ArrayOfParameters)
                   obj.ArrayOfListeners{length(obj.ArrayOfListeners)+1}...
                       = addlistener(obj.ArrayOfParameters{i},'NominalValueChanged', @obj.nominalChangedEvent);                                    
                end
            end
            
           if ~isempty(obj.ArrayOfVariables)                
                for i =1:length(obj.ArrayOfVariables)
                   obj.ArrayOfListeners{length(obj.ArrayOfListeners)+1}...
                       = addlistener(obj.ArrayOfVariables{i},'valueChangedEvent', @obj.valueChangedEvent);                                    
                end
            end
            
        end
        

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function initialize(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function initializes the GEO properties to some default
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
            
            obj.TopCoverMetal=SonnetGeometryTopAndBottomMetals();
            obj.BottomCoverMetal=SonnetGeometryTopAndBottomMetals();
            obj.SonnetBox=SonnetGeometryBox();
            obj.AutoDelete=true;
            obj.IsAutoHeightVias='False';
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aNewObject=clone(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function builds a deep copy of this object
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            aNewObject=SonnetGeometryBlock();
            SonnetClone(obj,aNewObject);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Set function: If a polygon is deleted then we want
        % to check if any edge polygons should be deleted.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function set.ArrayOfPolygons(obj,value)
            % If the polygon array has shrunk then check if we should
            % delete any edge vias or ports if they were attached to
            % the deleted polygon.
            
            % Check if any edge vias need to be deleted
            if (length(obj.ArrayOfPolygons) > length(value)) && obj.AutoDelete %#ok<MCSUP>
                obj.ArrayOfPolygons = value;
                checkToDeleteVia(obj);
                checkToDeletePort(obj);
                checkToDeleteParameter(obj);
                checkToDeleteDimension(obj);
            else
                obj.ArrayOfPolygons = value;
            end
            
        end
        
        function set.SnapAngle(obj, value)
            % Checks to see if the Snap Angle value is valid                   

            if isa(value, 'numeric')               
                if value == 90
                    obj.SnapAngle=90;
                elseif value == 45
                    obj.SnapAngle=45;
                elseif value == 30
                    obj.SnapAngle=30;
                elseif value == 22.5
                    obj.SnapAngle=22.5;
                elseif value == 5
                    obj.SnapAngle=5;
                else
                    % warning message
                    warning('Invalid Snap Angle value %d found. Value will be ignored.', value)
                    
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function writeObjectContents(obj, theFid, theVersion)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function writes the values from the object to a file.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            fprintf(theFid,'GEO\n');
            
            if strcmp(obj.IsSymmetric,'True')==1
                fprintf(theFid,'SYM\n');
            end
            
            if theVersion >= 15
                if strcmp(obj.IsAutoHeightVias,'True')==1
                    fprintf(theFid,'VGMODE STOP\n');
                end
                
                if ~isempty(obj.SnapAngle)
                    fprintf(theFid,'SNPANG %d\n', obj.SnapAngle);
                end
                
            end
            
            if ~isempty(obj.ReferencePlanes)
                obj.ReferencePlanes.writeObjectContents(theFid,theVersion);
            end
            
            if ~isempty(obj.TopCoverMetal)
                fprintf(theFid,'TMET ');
                obj.TopCoverMetal.writeObjectContents(theFid,theVersion);
            end
            
            if ~isempty(obj.BottomCoverMetal)
                fprintf(theFid,'BMET ');
                obj.BottomCoverMetal.writeObjectContents(theFid,theVersion);
            end
            
            if ~isempty(obj.ArrayOfMetalTypes)
                for iCounter= 1:length(obj.ArrayOfMetalTypes)
                    obj.ArrayOfMetalTypes{iCounter}.writeObjectContents(theFid,theVersion);
                end
            end
            
            for iCounter= 1:length(obj.ArrayOfDielectricMaterials)
                obj.ArrayOfDielectricMaterials{iCounter}.writeObjectContents(theFid,theVersion);
            end
            
            if ~isempty(obj.ParallelSubsections)
                obj.ParallelSubsections.writeObjectContents(theFid,theVersion);
            end
            
            if ~isempty(obj.SonnetBox)
                obj.SonnetBox.writeObjectContents(theFid,theVersion);
            end
            
            if theVersion >= 14
                if  ~isempty(obj.VNCells)
                    
                    if isnumeric(obj.VNCells.X)
                        obj.VNCells.X = num2str(obj.VNCells.X);
                    end
                    
                    if isnumeric(obj.VNCells.Y)
                        obj.VNCells.Y = num2str(obj.VNCells.Y);
                    end
                    
                    fprintf(theFid,'VNCELLS "%s" "%s"\n', obj.VNCells.X, obj.VNCells.Y);
                end
                                
                if ~isempty(obj.ArrayOfTechLayers)
                    for iCounter= 1:length(obj.ArrayOfTechLayers)
                        obj.ArrayOfTechLayers{iCounter}.writeObjectContents(theFid,theVersion);
                    end
                end
            end
            
            for iCounter= 1:length(obj.ArrayOfDimensions)
                obj.ArrayOfDimensions{iCounter}.writeObjectContents(theFid,theVersion);
            end           
            
            % Write geometry variables that dont have associated geometry
            % parameters first then write matching pairs together,
            % then write any parameters that dont have associated variables
            % (this last one should not normally occur but I have seen at
            % least one file where this is the case)
            for iCounter= 1:length(obj.ArrayOfVariables)
                isMatched=false;
                for jCounter= 1:length(obj.ArrayOfParameters)
                    if strcmpi(obj.ArrayOfVariables{iCounter}.VariableName,obj.ArrayOfParameters{jCounter}.Parname)==1
                        isMatched=true;
                    end
                end
                if ~isMatched
                    obj.ArrayOfVariables{iCounter}.writeObjectContents(theFid,theVersion);
                end
            end
            for iCounter= 1:length(obj.ArrayOfVariables)
                obj.ArrayOfVariables{iCounter}.writeObjectContents(theFid,theVersion);
                for jCounter= 1:length(obj.ArrayOfParameters)
                    if strcmpi(obj.ArrayOfVariables{iCounter}.VariableName,obj.ArrayOfParameters{jCounter}.Parname)==1
                        %obj.ArrayOfVariables{iCounter}.writeObjectContents(theFid,theVersion);
                        obj.ArrayOfParameters{jCounter}.writeObjectContents(theFid,theVersion);
                    end
                end
            end
            for iCounter= 1:length(obj.ArrayOfParameters)
                isMatched=false;
                for jCounter= 1:length(obj.ArrayOfVariables)
                    if strcmpi(obj.ArrayOfVariables{jCounter}.VariableName,obj.ArrayOfParameters{iCounter}.Parname)==1
                        isMatched=true;
                    end
                end
                if ~isMatched
                    obj.ArrayOfParameters{iCounter}.writeObjectContents(theFid,theVersion);
                end
            end
            
            if ~isempty(obj.LocalOrigin) && theVersion >= 13
                fprintf(theFid,'LORGN %g %g %s\n',obj.LocalOrigin.X,obj.LocalOrigin.Y,obj.LocalOrigin.Locked);
            end
                        
            for iCounter= 1:length(obj.ArrayOfEdgeVias)
                obj.ArrayOfEdgeVias{iCounter}.writeObjectContents(theFid,theVersion);
            end
            
            for iCounter= 1:length(obj.ArrayOfPorts)
                obj.ArrayOfPorts{iCounter}.writeObjectContents(theFid,theVersion);
                
                if ~isempty(obj.ArrayOfPorts{iCounter}.GroupId)                      
                    for inCounter= 1:length(obj.ArrayOfCoCalibratedGroups)
                        if obj.ArrayOfCoCalibratedGroups{inCounter}.GroupId == obj.ArrayOfPorts{inCounter}.GroupId
                            obj.ArrayOfCoCalibratedGroups{inCounter}.writeObjectContents(theFid,theVersion);
                            break;
                        end
                    end
                end                                
            end
            
            % Find the largest port number. Can't use the length of the array of ports because
            % some ports may have negitive number indexes.
            if ~isempty(obj.ArrayOfPorts)
                aPortCounter=-inf;
                for iCounter=1:length(obj.ArrayOfPorts)
                    if obj.ArrayOfPorts{iCounter}.PortNumber > aPortCounter
                        aPortCounter=obj.ArrayOfPorts{iCounter}.PortNumber;
                    end
                end
                aPortCounter=aPortCounter+1;
            else
                % If there are no ports then start at zero
                aPortCounter=0;
            end
            
            for iCounter= 1:length(obj.ArrayOfComponents)
                obj.ArrayOfComponents{iCounter}.writeObjectContents(theFid,aPortCounter,theVersion);
                aPortCounter=aPortCounter+length(obj.ArrayOfComponents{iCounter}.ArrayOfPorts);
            end
            
            for iCounter= 1:length(obj.ArrayOfCoCalibratedGroups)
                if ~strcmp(obj.ArrayOfCoCalibratedGroups{iCounter}.GroupType, 'LOCAL')
                    obj.ArrayOfCoCalibratedGroups{iCounter}.writeObjectContents(theFid,theVersion);
                end
            end
            
            if (~isempty(obj.UnknownLines))
                fprintf(theFid, sprintf('%s',obj.UnknownLines));
            end
            
            fprintf(theFid,'NUM %d',length(obj.ArrayOfPolygons));
            for iCounter= 1:length(obj.ArrayOfPolygons)
                obj.ArrayOfPolygons{iCounter}.writeObjectContents(theFid,theVersion);
            end
            
            fprintf(theFid,'\nEND GEO\n');
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aSignature=stringSignature(obj,theVersion)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function writes the values from the object to a string.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            aSignature = sprintf('GEO\n');
            
            if strcmp(obj.IsSymmetric,'True')==1
                aSignature = [aSignature sprintf('SYM\n')];
            end
            
            if ~isempty(obj.ReferencePlanes)
                aSignature = [aSignature obj.ReferencePlanes.stringSignature(theVersion)];
            end
            
            if ~isempty(obj.TopCoverMetal)
                aSignature = [aSignature sprintf('TMET ')];
                aSignature = [aSignature obj.TopCoverMetal.stringSignature(theVersion)];
            end
            
            if ~isempty(obj.BottomCoverMetal)
                aSignature = [aSignature sprintf('BMET ')];
                aSignature = [aSignature obj.BottomCoverMetal.stringSignature(theVersion)];
            end
            
            if ~isempty(obj.ArrayOfMetalTypes)
                for iCounter= 1:length(obj.ArrayOfMetalTypes)
                    aSignature = [aSignature obj.ArrayOfMetalTypes{iCounter}.stringSignature(theVersion)];
                end
            end
            
            for iCounter= 1:length(obj.ArrayOfDielectricMaterials)
                aSignature = [aSignature obj.ArrayOfDielectricMaterials{iCounter}.stringSignature(theVersion)];
            end
            
            if ~isempty(obj.ParallelSubsections)
                aSignature = [aSignature obj.ParallelSubsections.stringSignature(theVersion)];
            end
            
            if ~isempty(obj.SonnetBox)
                aSignature = [aSignature obj.SonnetBox.stringSignature(theVersion)];
            end
                       
            for iCounter= 1:length(obj.ArrayOfDimensions)
                aSignature = [aSignature obj.ArrayOfDimensions{iCounter}.stringSignature(theVersion)];
            end
            
            % Write geometry variables that dont have associated geometry
            % parameters first then write matching pairs together,
            % then write any parameters that dont have associated variables
            % (this last one should not normally occur but I have seen at
            % least one file where this is the case)
            for iCounter= 1:length(obj.ArrayOfVariables)
                isMatched=false;
                for jCounter= 1:length(obj.ArrayOfParameters)
                    if strcmpi(obj.ArrayOfVariables{iCounter}.VariableName,obj.ArrayOfParameters{jCounter}.Parname)==1
                        isMatched=true;
                    end
                end
                if ~isMatched
                    aSignature = [aSignature obj.ArrayOfVariables{iCounter}.stringSignature(theVersion)];
                end
            end
            for iCounter= 1:length(obj.ArrayOfVariables)
                for jCounter= 1:length(obj.ArrayOfParameters)
                    if strcmpi(obj.ArrayOfVariables{iCounter}.VariableName,obj.ArrayOfParameters{jCounter}.Parname)==1
                        aSignature = [aSignature obj.ArrayOfVariables{iCounter}.stringSignature(theVersion)];
                        aSignature = [aSignature obj.ArrayOfParameters{iCounter}.stringSignature(theVersion)];
                    end
                end
            end
            for iCounter= 1:length(obj.ArrayOfParameters)
                isMatched=false;
                for jCounter= 1:length(obj.ArrayOfVariables)
                    if strcmpi(obj.ArrayOfVariables{jCounter}.VariableName,obj.ArrayOfParameters{iCounter}.Parname)==1
                        isMatched=true;
                    end
                end
                if ~isMatched
                    aSignature = [aSignature obj.ArrayOfParameters{iCounter}.stringSignature(theVersion)];
                end
            end
            
            if ~isempty(obj.LocalOrigin) && theVersion >= 13
                aSignature = [aSignature sprintf('LORGN %d %d %s',obj.LocalOrigin.X,obj.LocalOrigin.Y,obj.LocalOrigin.Locked)];
            end
                        
            for iCounter= 1:length(obj.ArrayOfEdgeVias)
                aSignature = [aSignature obj.ArrayOfEdgeVias{iCounter}.stringSignature(theVersion)];
            end
            
            for iCounter= 1:length(obj.ArrayOfPorts)
                aSignature = [aSignature obj.ArrayOfPorts{iCounter}.stringSignature(theVersion)];
            end
            
            % Find the largest port number. Can't use the length of the array of ports because
            % some ports may have negitive number indexes.
            if ~isempty(obj.ArrayOfPorts)
                aPortCounter=-inf;
                for iCounter=1:length(obj.ArrayOfPorts)
                    if obj.ArrayOfPorts{iCounter}.PortNumber > aPortCounter
                        aPortCounter=obj.ArrayOfPorts{iCounter}.PortNumber;
                    end
                end
                aPortCounter=aPortCounter+1;
            else
                % If there are no ports then start at zero
                aPortCounter=0;
            end
            
            for iCounter= 1:length(obj.ArrayOfComponents)
                aSignature = [aSignature obj.ArrayOfComponents{iCounter}.stringSignature(length(obj.ArrayOfPorts),theVersion)];
                aPortCounter=aPortCounter+length(obj.ArrayOfComponents{iCounter}.ArrayOfPorts);
            end
            
            for iCounter= 1:length(obj.ArrayOfCoCalibratedGroups)
                aSignature = [aSignature obj.ArrayOfCoCalibratedGroups{iCounter}.stringSignature(theVersion)];
            end
            
            if (~isempty(obj.UnknownLines))
                aSignature = [aSignature strrep(obj.UnknownLines,'\n',sprintf('\n'))];
            end
            
            aSignature = [aSignature sprintf('NUM %d',length(obj.ArrayOfPolygons))];
            
            for iCounter= 1:length(obj.ArrayOfPolygons)
                aSignature = [aSignature obj.ArrayOfPolygons{iCounter}.stringSignature(theVersion)];
            end
            
            aSignature = [aSignature sprintf('\nEND GEO\n')];
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [theArrayOfPolygonPairs, theArrayOfPolygonIndexPairs, iNumberOfMatches]=findDuplicatePolygons(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method finds the duplicate polygons in the
            % project. The duplicates are returned in matrixes
            % and thir indecies are similarily returned in a matrix.
            % This method has no parameters.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if nargin == 1
                
                iNumberOfMatches=0;                               % Keeps track of the number of matches so far
                theArrayOfPolygons=obj.ArrayOfPolygons;
                theArrayOfPolygonIndexPairs=[];
                theArrayOfPolygonPairs=[];
                
                for iCounter=1:length(obj.ArrayOfPolygons)
                    
                    theArrayOfMatches=theArrayOfPolygons{iCounter}; % Stores polygons that match the given polygon. Start it out with the value we are testing for
                    theArrayOfPolygonIndexes=iCounter;
                    
                    for jCounter=iCounter+1:length(theArrayOfPolygons)
                        
                        % If all the points match then they are the same
                        if obj.determineIfPolygonsAreDuplicates(theArrayOfPolygons{iCounter},theArrayOfPolygons{jCounter})==true
                            theArrayOfMatches=[theArrayOfMatches theArrayOfPolygons{jCounter}];
                            theArrayOfPolygonIndexes=[theArrayOfPolygonIndexes jCounter];
                        end
                        
                    end
                    
                    % If more than one polygon were the same then add it to the array
                    if length(theArrayOfMatches) > 1
                        iNumberOfMatches=iNumberOfMatches+1;
                        theArrayOfPolygonIndexPairs{iNumberOfMatches}=theArrayOfPolygonIndexes;
                        theArrayOfPolygonPairs{iNumberOfMatches}=theArrayOfMatches;
                    end
                    
                end
                
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function theEquivalenceValue=determineIfPolygonsAreDuplicates(obj,theFirstPolygon,theSecondPolygon)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method determines if the points match for 2
            % polygon parameters. Even if the points are out of order
            % it will return if they are the same. The returned value
            % is a boolean. This function is used by findDuplicates.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            theEquivalenceValue=true; % Assume true and determine if any of the tests fail
            
            % Determine if they have the same class
            if strcmp(class(theFirstPolygon),class(theSecondPolygon))==0
                theEquivalenceValue=false;
                return
            end
            
            % Determine if they have the same type
            if strcmp(theFirstPolygon.Type,theSecondPolygon.Type)==1 || (isempty(theFirstPolygon.Type) && isempty(theSecondPolygon.Type))
            else
                theEquivalenceValue=false;
                return
            end
            
            % Determine if they have the same level index
            if theFirstPolygon.MetalizationLevelIndex~=theSecondPolygon.MetalizationLevelIndex
                theEquivalenceValue=false;
                return
            end
            
            % Determine if they have the same metal type
            if theFirstPolygon.MetalType~=theSecondPolygon.MetalType
                theEquivalenceValue=false;
                return
            end
            
            % Determine if they have the same fill type
            if strcmp(theFirstPolygon.FillType,theSecondPolygon.FillType)==0
                theEquivalenceValue=false;
                return
            end
            
            % Determine if they have the same subsection sizes
            if theFirstPolygon.XMinimumSubsectionSize~=theSecondPolygon.XMinimumSubsectionSize || theFirstPolygon.YMinimumSubsectionSize~=theSecondPolygon.YMinimumSubsectionSize || theFirstPolygon.XMaximumSubsectionSize~=theSecondPolygon.XMaximumSubsectionSize || theFirstPolygon.YMaximumSubsectionSize~=theSecondPolygon.YMaximumSubsectionSize
                theEquivalenceValue=false;
                return
            end
            
            % Determine if they have the same subsection sizes
            if theFirstPolygon.MaximumLengthForTheConformalMeshSubsection~=theSecondPolygon.MaximumLengthForTheConformalMeshSubsection
                theEquivalenceValue=false;
                return
            end
            
            % in the case that they were vias we want to know if they both are connected to the same place
            if theFirstPolygon.LevelTheViaIsConnectedTo~=theSecondPolygon.LevelTheViaIsConnectedTo
                theEquivalenceValue=false;
                return
            end
            
            % If the polygons have the same coordinates in any order
            if obj.pointsMatch(theFirstPolygon,theSecondPolygon)==false || obj.pointsMatch(theSecondPolygon,theFirstPolygon)==false
                theEquivalenceValue=false;
                return
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function theEquivalenceValue=pointsMatch(obj,theFirstPolygon,theSecondPolygon) 
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method determines if all the points in the first
            % polygon are contained in the second polygon. Even if
            % the points are out of order it will return true if all
            % the points in the first polygon are contained in the
            % second polygon. Duplicate points are allowed. This method
            % i called by determineIfPolygonsAreDuplicates which is
            % in turn called by findDuplicates.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            theEquivalenceValue=true;   % Assume they are equivalent and test if we can disprove it with any point.
            
            for iCounter=1:length(theFirstPolygon.XCoordinateValues);
                
                theBooleanForIfWeFoundAMatchForThisValue=false; % Keeps track whether there has been a match for the coordinate of the first polygon with a coordinate for the second polygon. We will assume false and set it true if we find a match.
                
                for jCounter=1:length(theSecondPolygon.XCoordinateValues);
                    
                    if theFirstPolygon.XCoordinateValues{iCounter} == theSecondPolygon.XCoordinateValues{jCounter} && theFirstPolygon.YCoordinateValues{iCounter} == theSecondPolygon.YCoordinateValues{jCounter}
                        
                        theBooleanForIfWeFoundAMatchForThisValue=true;
                        
                    end
                    
                end
                
                % If we didnt find a match then set the variable keeping track of
                % whether the polygons were equal to false and leave the function.
                if theBooleanForIfWeFoundAMatchForThisValue==false
                    theEquivalenceValue=false;
                    return;
                end
                
            end
            
        end
                
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function deleteDuplicatePolygons(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method calls the find duplicates method and
            % deletes one instance of the duplicate polygons.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            [theArrayOfPolygonPairs, theArrayOfPolygonIndexPairs]=findDuplicatePolygons(obj);
            
            % Empty out the duplicate entries from the polygon array
            for iCounter=1:length(theArrayOfPolygonPairs);
                
                for jCounter=2:length(theArrayOfPolygonIndexPairs{iCounter})  % Loop through all the duplicates and delete them
                    
                    aPolygonToDelete=theArrayOfPolygonPairs{iCounter};
                    aPolygonToDelete=aPolygonToDelete(jCounter);
                    aIndexNumberToDelete=findPolygonIndex(obj,aPolygonToDelete);
                    if aIndexNumberToDelete~=-1                                 % If the polygon is still there (hasn't been deleted yet)
                        obj.ArrayOfPolygons(aIndexNumberToDelete)=[];
                    end
                    
                end
                
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [aPolygon, aPolygonId, aIndex]=findPolygonUsingCentroidXY(obj,theXCoordinate,theYCoordinate,theLayer,theSize)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method finds polygons given its
            % centroid x and y coordinates. This method may return
            % more than one polygon.
            % If this function is given only one argument then
            % it does the same thing as findPolygonCentroidX.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if nargin==5
                
                [aArrayOfCentroidXValues, aArrayOfCentroidYValues, aArrayOfLayers, aArrayOfSizes, aArrayOfReferences]=cellfun(@(x) getPolygonCentroidXYLayerSize(obj,x),obj.ArrayOfPolygons,'UniformOutput',false);
                aArrayOfCentroidXValues=cell2mat(aArrayOfCentroidXValues);
                aArrayOfCentroidYValues=cell2mat(aArrayOfCentroidYValues);
                aArrayOfLayers=cell2mat(aArrayOfLayers);
                aArrayOfSizes=cell2mat(aArrayOfSizes);
                aPolygonIndex=find(theXCoordinate==aArrayOfCentroidXValues & theYCoordinate==aArrayOfCentroidYValues & theLayer==aArrayOfLayers & theSize==aArrayOfSizes);
                
                if isempty(aPolygonIndex)
                    aPolygon=[];
                    aPolygonId=[];
                    aIndex=[];
                else
                    % Assign the polygon and polygon ID
                    aPolygon=SonnetGeometryPolygon();
                    aPolygonId=zeros(1,length(aPolygonIndex));
                    aIndex=zeros(1,length(aPolygonIndex));
                    for iCounter=1:length(aPolygonIndex)
                        aPolygon(iCounter)=aArrayOfReferences{aPolygonIndex(iCounter)};
                        aPolygonId(iCounter)=aArrayOfReferences{aPolygonIndex(iCounter)}.DebugId;
                        
                        % Make sure the index of the polygon is correct.
                        % If not then search for the polygon. The results
                        % of cellfun are not always in order but usually are
                        % so it is faster to check if the value is correct and
                        % only do a slow search if necessary.
                        if aArrayOfReferences{aPolygonIndex(iCounter)}==obj.ArrayOfPolygons{aPolygonIndex(iCounter)}
                            aIndex(iCounter)=aPolygonIndex(iCounter);
                        else
                            isIndexFound=false;
                            for jCounter=1:length(obj.ArrayOfPolygons)
                                if aArrayOfReferences{aPolygonIndex(iCounter)}
                                    isIndexFound=true;
                                end
                            end
                            
                            if ~isIndexFound
                                error('Could not find the index for all of the found polygons');
                            end
                        end
                    end
                end
                
            elseif nargin==4
                
                [aArrayOfCentroidXValues, aArrayOfCentroidYValues, aArrayOfLayers, aArrayOfReferences]=cellfun(@(x) getPolygonCentroidXYLayer(obj,x),obj.ArrayOfPolygons,'UniformOutput',false);
                aArrayOfCentroidXValues=cell2mat(aArrayOfCentroidXValues);
                aArrayOfCentroidYValues=cell2mat(aArrayOfCentroidYValues);
                aArrayOfLayers=cell2mat(aArrayOfLayers);
                aPolygonIndex=find(theXCoordinate==aArrayOfCentroidXValues & theYCoordinate==aArrayOfCentroidYValues & theLayer==aArrayOfLayers);
                
                if isempty(aPolygonIndex)
                    aPolygon=[];
                    aPolygonId=[];
                    aIndex=[];
                else
                    % Assign the polygon and polygon ID
                    aPolygon=SonnetGeometryPolygon();
                    aPolygonId=zeros(1,length(aPolygonIndex));
                    aIndex=zeros(1,length(aPolygonIndex));
                    for iCounter=1:length(aPolygonIndex)
                        aPolygon(iCounter)=aArrayOfReferences{aPolygonIndex(iCounter)};
                        aPolygonId(iCounter)=aArrayOfReferences{aPolygonIndex(iCounter)}.DebugId;
                        
                        % Make sure the index of the polygon is correct.
                        % If not then search for the polygon. The results
                        % of cellfun are not always in order but usually are
                        % so it is faster to check if the value is correct and
                        % only do a slow search if necessary.
                        if aArrayOfReferences{aPolygonIndex(iCounter)}==obj.ArrayOfPolygons{aPolygonIndex(iCounter)}
                            aIndex(iCounter)=aPolygonIndex(iCounter);
                        else
                            isIndexFound=false;
                            for jCounter=1:length(obj.ArrayOfPolygons)
                                if aArrayOfReferences{aPolygonIndex(iCounter)}
                                    isIndexFound=true;
                                end
                            end
                            
                            if ~isIndexFound
                                error('Could not find the index for all of the found polygons');
                            end
                        end
                    end
                end
                
            elseif nargin==3
                
                [aArrayOfCentroidXValues, aArrayOfCentroidYValues, aArrayOfReferences]=cellfun(@(x) getPolygonCentroidXY(obj,x),obj.ArrayOfPolygons,'UniformOutput',false);
                aArrayOfCentroidXValues=cell2mat(aArrayOfCentroidXValues);
                aArrayOfCentroidYValues=cell2mat(aArrayOfCentroidYValues);
                aPolygonIndex=find(theXCoordinate==aArrayOfCentroidXValues & theYCoordinate==aArrayOfCentroidYValues);
                
                if isempty(aPolygonIndex)
                    aPolygon=[];
                    aPolygonId=[];
                    aIndex=[];
                else
                    % Assign the polygon and polygon ID
                    aPolygon=SonnetGeometryPolygon();
                    aPolygonId=zeros(1,length(aPolygonIndex));
                    aIndex=zeros(1,length(aPolygonIndex));
                    for iCounter=1:length(aPolygonIndex)
                        aPolygon(iCounter)=aArrayOfReferences{aPolygonIndex(iCounter)};
                        aPolygonId(iCounter)=aArrayOfReferences{aPolygonIndex(iCounter)}.DebugId;
                        
                        % Make sure the index of the polygon is correct.
                        % If not then search for the polygon. The results
                        % of cellfun are not always in order but usually are
                        % so it is faster to check if the value is correct and
                        % only do a slow search if necessary.
                        if aArrayOfReferences{aPolygonIndex(iCounter)}==obj.ArrayOfPolygons{aPolygonIndex(iCounter)}
                            aIndex(iCounter)=aPolygonIndex(iCounter);
                        else
                            isIndexFound=false;
                            for jCounter=1:length(obj.ArrayOfPolygons)
                                if aArrayOfReferences{aPolygonIndex(iCounter)}
                                    isIndexFound=true;
                                end
                            end
                            
                            if ~isIndexFound
                                error('Could not find the index for all of the found polygons');
                            end
                        end
                    end
                end
                
            else
                error('Invalid number of parameters.');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [thePolygon, thePolygonId, theIndex]=findPolygonUsingFunction(obj,theFunction)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method finds a polygon using a user defined function
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            thePolygon=[];
            theIndex=[];
            thePolygonId=[];
            
            for iCounter=1:length(obj.ArrayOfPolygons)
                if theFunction(obj.ArrayOfPolygons{iCounter})
                    thePolygon=[thePolygon obj.ArrayOfPolygons{iCounter}];  % Add the polygon to the array of matching polygons
                    theIndex=[theIndex iCounter];                           % Add the index to the array of indecies for the polygons
                    thePolygonId=[thePolygonId thePolygon.DebugId];         % Add the polygon's ID to the array of polygon ID's
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [aPolygon, aPolygonId, aIndex]=findPolygonUsingCentroidX(obj,theXCoordinate,theLayer,theSize)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method finds the index for a polygon given its
            % centroid X coordinate. This method may return
            % more than one polygon.
            % This returns the polygon object and its index in
            % the polygon array.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if nargin==4
                [aArrayOfCentroidXValues, aArrayOfLayers, aArrayOfSizes, aArrayOfReferences]=cellfun(@(x) getPolygonCentroidXLayerSize(obj,x),obj.ArrayOfPolygons,'UniformOutput',false);
                aArrayOfCentroidXValues=cell2mat(aArrayOfCentroidXValues);
                aArrayOfLayers=cell2mat(aArrayOfLayers);
                aArrayOfSizes=cell2mat(aArrayOfSizes);
                aPolygonIndex=find(theXCoordinate==aArrayOfCentroidXValues & theLayer==aArrayOfLayers & theSize==aArrayOfSizes);
                
                if isempty(aPolygonIndex)
                    aPolygon=[];
                    aPolygonId=[];
                    aIndex=[];
                else
                    % Assign the polygon and polygon ID
                    aPolygon=SonnetGeometryPolygon();
                    aPolygonId=zeros(1,length(aPolygonIndex));
                    aIndex=zeros(1,length(aPolygonIndex));
                    for iCounter=1:length(aPolygonIndex)
                        aPolygon(iCounter)=aArrayOfReferences{aPolygonIndex(iCounter)};
                        aPolygonId(iCounter)=aArrayOfReferences{aPolygonIndex(iCounter)}.DebugId;
                        
                        % Make sure the index of the polygon is correct.
                        % If not then search for the polygon. The results
                        % of cellfun are not always in order but usually are
                        % so it is faster to check if the value is correct and
                        % only do a slow search if necessary.
                        if aArrayOfReferences{aPolygonIndex(iCounter)}==obj.ArrayOfPolygons{aPolygonIndex(iCounter)}
                            aIndex(iCounter)=aPolygonIndex(iCounter);
                        else
                            isIndexFound=false;
                            for jCounter=1:length(obj.ArrayOfPolygons)
                                if aArrayOfReferences{aPolygonIndex(iCounter)}
                                    aIndex=jCounter;
                                    isIndexFound=true;
                                end
                            end
                            
                            if ~isIndexFound
                                error('Could not find the index for all of the found polygons');
                            end
                        end
                    end
                end
                
            elseif nargin==3
                
                [aArrayOfCentroidXValues, aArrayOfLayers, aArrayOfReferences]=cellfun(@(x) getPolygonCentroidXLayer(obj,x),obj.ArrayOfPolygons,'UniformOutput',false);
                aArrayOfCentroidXValues=cell2mat(aArrayOfCentroidXValues);
                aArrayOfLayers=cell2mat(aArrayOfLayers);
                aPolygonIndex=find(theXCoordinate==aArrayOfCentroidXValues & theLayer==aArrayOfLayers);
                
                if isempty(aPolygonIndex)
                    aPolygon=[];
                    aPolygonId=[];
                    aIndex=[];
                else
                    % Assign the polygon and polygon ID
                    aPolygon=SonnetGeometryPolygon();
                    aPolygonId=zeros(1,length(aPolygonIndex));
                    aIndex=zeros(1,length(aPolygonIndex));
                    for iCounter=1:length(aPolygonIndex)
                        aPolygon(iCounter)=aArrayOfReferences{aPolygonIndex(iCounter)};
                        aPolygonId(iCounter)=aArrayOfReferences{aPolygonIndex(iCounter)}.DebugId;
                        
                        % Make sure the index of the polygon is correct.
                        % If not then search for the polygon. The results
                        % of cellfun are not always in order but usually are
                        % so it is faster to check if the value is correct and
                        % only do a slow search if necessary.
                        if aArrayOfReferences{aPolygonIndex(iCounter)}==obj.ArrayOfPolygons{aPolygonIndex(iCounter)}
                            aIndex(iCounter)=aPolygonIndex(iCounter);
                        else
                            isIndexFound=false;
                            for jCounter=1:length(obj.ArrayOfPolygons)
                                if aArrayOfReferences{aPolygonIndex(iCounter)}
                                    aIndex=jCounter;
                                    isIndexFound=true;
                                end
                            end
                            
                            if ~isIndexFound
                                error('Could not find the index for all of the found polygons');
                            end
                        end
                    end
                end
                
            elseif nargin==2
                
                [aArrayOfCentroidXValues, aArrayOfReferences]=cellfun(@(x) getPolygonCentroidX(obj,x),obj.ArrayOfPolygons,'UniformOutput',false);
                aArrayOfCentroidXValues=cell2mat(aArrayOfCentroidXValues);
                aPolygonIndex=find(theXCoordinate==aArrayOfCentroidXValues);
                
                if isempty(aPolygonIndex)
                    aPolygon=[];
                    aPolygonId=[];
                    aIndex=[];
                else
                    % Assign the polygon and polygon ID
                    aPolygon=SonnetGeometryPolygon();
                    aPolygonId=zeros(1,length(aPolygonIndex));
                    aIndex=zeros(1,length(aPolygonIndex));
                    for iCounter=1:length(aPolygonIndex)
                        aPolygon(iCounter)=aArrayOfReferences{aPolygonIndex(iCounter)};
                        aPolygonId(iCounter)=aArrayOfReferences{aPolygonIndex(iCounter)}.DebugId;
                        
                        % Make sure the index of the polygon is correct.
                        % If not then search for the polygon. The results
                        % of cellfun are not always in order but usually are
                        % so it is faster to check if the value is correct and
                        % only do a slow search if necessary.
                        if aArrayOfReferences{aPolygonIndex(iCounter)}==obj.ArrayOfPolygons{aPolygonIndex(iCounter)}
                            aIndex(iCounter)=aPolygonIndex(iCounter);
                        else
                            isIndexFound=false;
                            for jCounter=1:length(obj.ArrayOfPolygons)
                                if aArrayOfReferences{aPolygonIndex(iCounter)}
                                    aIndex=jCounter;
                                    isIndexFound=true;
                                end
                            end
                            
                            if ~isIndexFound
                                error('Could not find the index for all of the found polygons');
                            end
                        end
                    end
                end
                
            else
                error('Invalid number of parameters.');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [aPolygon, aPolygonId, aIndex]=findPolygonUsingCentroidY(obj,theYCoordinate,theLayer,theSize)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method finds the index for a polygon given its
            % centroid Y coordinate. This method may return
            % more than one polygon.
            % This returns the polygon object and its index in
            % the polygon array.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if nargin==4
                [aArrayOfCentroidYValues, aArrayOfLayers, aArrayOfSizes, aArrayOfReferences]=cellfun(@(x) getPolygonCentroidYLayerSize(obj,x),obj.ArrayOfPolygons,'UniformOutput',false);
                aArrayOfCentroidYValues=cell2mat(aArrayOfCentroidYValues);
                aArrayOfLayers=cell2mat(aArrayOfLayers);
                aArrayOfSizes=cell2mat(aArrayOfSizes);
                aPolygonIndex=find(theYCoordinate==aArrayOfCentroidYValues & theLayer==aArrayOfLayers & theSize==aArrayOfSizes);
                
                if isempty(aPolygonIndex)
                    aPolygon=[];
                    aPolygonId=[];
                    aIndex=[];
                else
                    % Assign the polygon and polygon ID
                    aPolygon=SonnetGeometryPolygon();
                    aPolygonId=zeros(1,length(aPolygonIndex));
                    aIndex=zeros(1,length(aPolygonIndex));
                    for iCounter=1:length(aPolygonIndex)
                        aPolygon(iCounter)=aArrayOfReferences{aPolygonIndex(iCounter)};
                        aPolygonId(iCounter)=aArrayOfReferences{aPolygonIndex(iCounter)}.DebugId;
                        
                        % Make sure the index of the polygon is correct.
                        % If not then search for the polygon. The results
                        % of cellfun are not always in order but usually are
                        % so it is faster to check if the value is correct and
                        % only do a slow search if necessary.
                        if aArrayOfReferences{aPolygonIndex(iCounter)}==obj.ArrayOfPolygons{aPolygonIndex(iCounter)}
                            aIndex(iCounter)=aPolygonIndex(iCounter);
                        else
                            isIndexFound=false;
                            for jCounter=1:length(obj.ArrayOfPolygons)
                                if aArrayOfReferences{aPolygonIndex(iCounter)}
                                    aIndex=jCounter;
                                    isIndexFound=true;
                                end
                            end
                            
                            if ~isIndexFound
                                error('Could not find the index for all of the found polygons');
                            end
                        end
                    end
                end
                
            elseif nargin==3
                
                [aArrayOfCentroidYValues, aArrayOfLayers, aArrayOfReferences]=cellfun(@(x) getPolygonCentroidYLayer(obj,x),obj.ArrayOfPolygons,'UniformOutput',false);
                aArrayOfCentroidYValues=cell2mat(aArrayOfCentroidYValues);
                aArrayOfLayers=cell2mat(aArrayOfLayers);
                aPolygonIndex=find(theYCoordinate==aArrayOfCentroidYValues & theLayer==aArrayOfLayers);
                
                if isempty(aPolygonIndex)
                    aPolygon=[];
                    aPolygonId=[];
                    aIndex=[];
                else
                    % Assign the polygon and polygon ID
                    aPolygon=SonnetGeometryPolygon();
                    aPolygonId=zeros(1,length(aPolygonIndex));
                    aIndex=zeros(1,length(aPolygonIndex));
                    for iCounter=1:length(aPolygonIndex)
                        aPolygon(iCounter)=aArrayOfReferences{aPolygonIndex(iCounter)};
                        aPolygonId(iCounter)=aArrayOfReferences{aPolygonIndex(iCounter)}.DebugId;
                        
                        % Make sure the index of the polygon is correct.
                        % If not then search for the polygon. The results
                        % of cellfun are not always in order but usually are
                        % so it is faster to check if the value is correct and
                        % only do a slow search if necessary.
                        if aArrayOfReferences{aPolygonIndex(iCounter)}==obj.ArrayOfPolygons{aPolygonIndex(iCounter)}
                            aIndex(iCounter)=aPolygonIndex(iCounter);
                        else
                            isIndexFound=false;
                            for jCounter=1:length(obj.ArrayOfPolygons)
                                if aArrayOfReferences{aPolygonIndex(iCounter)}
                                    aIndex=jCounter;
                                    isIndexFound=true;
                                end
                            end
                            
                            if ~isIndexFound
                                error('Could not find the index for all of the found polygons');
                            end
                        end
                    end
                end
                
            elseif nargin==2
                
                [aArrayOfCentroidYValues, aArrayOfReferences]=cellfun(@(x) getPolygonCentroidY(obj,x),obj.ArrayOfPolygons,'UniformOutput',false);
                aArrayOfCentroidYValues=cell2mat(aArrayOfCentroidYValues);
                aPolygonIndex=find(theYCoordinate==aArrayOfCentroidYValues);
                
                if isempty(aPolygonIndex)
                    aPolygon=[];
                    aPolygonId=[];
                    aIndex=[];
                else
                    % Assign the polygon and polygon ID
                    aPolygon=SonnetGeometryPolygon();
                    aPolygonId=zeros(1,length(aPolygonIndex));
                    aIndex=zeros(1,length(aPolygonIndex));
                    for iCounter=1:length(aPolygonIndex)
                        aPolygon(iCounter)=aArrayOfReferences{aPolygonIndex(iCounter)};
                        aPolygonId(iCounter)=aArrayOfReferences{aPolygonIndex(iCounter)}.DebugId;
                        
                        % Make sure the index of the polygon is correct.
                        % If not then search for the polygon. The results
                        % of cellfun are not always in order but usually are
                        % so it is faster to check if the value is correct and
                        % only do a slow search if necessary.
                        if aArrayOfReferences{aPolygonIndex(iCounter)}==obj.ArrayOfPolygons{aPolygonIndex(iCounter)}
                            aIndex(iCounter)=aPolygonIndex(iCounter);
                        else
                            isIndexFound=false;
                            for jCounter=1:length(obj.ArrayOfPolygons)
                                if aArrayOfReferences{aPolygonIndex(iCounter)}
                                    aIndex=jCounter;
                                    isIndexFound=true;
                                end
                            end
                            
                            if ~isIndexFound
                                error('Could not find the index for all of the found polygons');
                            end
                        end
                    end
                end
                
            else
                error('Invalid number of parameters.');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [aPolygon, aPolygonId, aIndex]=findPolygonUsingMeanXY(obj,theXCoordinate,theYCoordinate,theLayer,theSize)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method finds the index for a polygon given its
            % mean x and y coordinates. This method may return
            % more than one polygon.
            % If this function is given only one argument then
            % it does the same thing as findPolygonCentroidX.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if nargin==5
                
                [aArrayOfMeanXValues, aArrayOfMeanYValues, aArrayOfLayers, aArrayOfSizes, aArrayOfReferences]=cellfun(@(x) getPolygonMeanXYLayerSize(obj,x),obj.ArrayOfPolygons,'UniformOutput',false);
                aArrayOfMeanXValues=cell2mat(aArrayOfMeanXValues);
                aArrayOfMeanYValues=cell2mat(aArrayOfMeanYValues);
                aArrayOfLayers=cell2mat(aArrayOfLayers);
                aArrayOfSizes=cell2mat(aArrayOfSizes);
                aPolygonIndex=find(theXCoordinate==aArrayOfMeanXValues & theYCoordinate==aArrayOfMeanYValues & theLayer==aArrayOfLayers & theSize==aArrayOfSizes);
                
                if isempty(aPolygonIndex)
                    aPolygon=[];
                    aPolygonId=[];
                    aIndex=[];
                else
                    % Assign the polygon and polygon ID
                    aPolygon=SonnetGeometryPolygon();
                    aPolygonId=zeros(1,length(aPolygonIndex));
                    aIndex=zeros(1,length(aPolygonIndex));
                    for iCounter=1:length(aPolygonIndex)
                        aPolygon(iCounter)=aArrayOfReferences{aPolygonIndex(iCounter)};
                        aPolygonId(iCounter)=aArrayOfReferences{aPolygonIndex(iCounter)}.DebugId;
                        
                        % Make sure the index of the polygon is correct.
                        % If not then search for the polygon. The results
                        % of cellfun are not always in order but usually are
                        % so it is faster to check if the value is correct and
                        % only do a slow search if necessary.
                        if aArrayOfReferences{aPolygonIndex(iCounter)}==obj.ArrayOfPolygons{aPolygonIndex(iCounter)}
                            aIndex(iCounter)=aPolygonIndex(iCounter);
                        else
                            isIndexFound=false;
                            for jCounter=1:length(obj.ArrayOfPolygons)
                                if aArrayOfReferences{aPolygonIndex(iCounter)}
                                    aIndex=jCounter;
                                    isIndexFound=true;
                                end
                            end
                            
                            if ~isIndexFound
                                error('Could not find the index for all of the found polygons');
                            end
                        end
                    end
                end
                
            elseif nargin==4
                
                [aArrayOfMeanXValues, aArrayOfMeanYValues, aArrayOfLayers, aArrayOfReferences]=cellfun(@(x) getPolygonMeanXYLayer(obj,x),obj.ArrayOfPolygons,'UniformOutput',false);
                aArrayOfMeanXValues=cell2mat(aArrayOfMeanXValues);
                aArrayOfMeanYValues=cell2mat(aArrayOfMeanYValues);
                aArrayOfLayers=cell2mat(aArrayOfLayers);
                aPolygonIndex=find(theXCoordinate==aArrayOfMeanXValues & theYCoordinate==aArrayOfMeanYValues & theLayer==aArrayOfLayers);
                
                if isempty(aPolygonIndex)
                    aPolygon=[];
                    aPolygonId=[];
                    aIndex=[];
                else
                    % Assign the polygon and polygon ID
                    aPolygon=SonnetGeometryPolygon();
                    aPolygonId=zeros(1,length(aPolygonIndex));
                    aIndex=zeros(1,length(aPolygonIndex));
                    for iCounter=1:length(aPolygonIndex)
                        aPolygon(iCounter)=aArrayOfReferences{aPolygonIndex(iCounter)};
                        aPolygonId(iCounter)=aArrayOfReferences{aPolygonIndex(iCounter)}.DebugId;
                        
                        % Make sure the index of the polygon is correct.
                        % If not then search for the polygon. The results
                        % of cellfun are not always in order but usually are
                        % so it is faster to check if the value is correct and
                        % only do a slow search if necessary.
                        if aArrayOfReferences{aPolygonIndex(iCounter)}==obj.ArrayOfPolygons{aPolygonIndex(iCounter)}
                            aIndex(iCounter)=aPolygonIndex(iCounter);
                        else
                            isIndexFound=false;
                            for jCounter=1:length(obj.ArrayOfPolygons)
                                if aArrayOfReferences{aPolygonIndex(iCounter)}
                                    aIndex=jCounter;
                                    isIndexFound=true;
                                end
                            end
                            
                            if ~isIndexFound
                                error('Could not find the index for all of the found polygons');
                            end
                        end
                    end
                end
                
            elseif nargin==3
                
                [aArrayOfMeanXValues, aArrayOfMeanYValues, aArrayOfReferences]=cellfun(@(x) getPolygonMeanXY(obj,x),obj.ArrayOfPolygons,'UniformOutput',false);
                aArrayOfMeanXValues=cell2mat(aArrayOfMeanXValues);
                aArrayOfMeanYValues=cell2mat(aArrayOfMeanYValues);
                aPolygonIndex=find(theXCoordinate==aArrayOfMeanXValues & theYCoordinate==aArrayOfMeanYValues);
                
                if isempty(aPolygonIndex)
                    aPolygon=[];
                    aPolygonId=[];
                    aIndex=[];
                else
                    % Assign the polygon and polygon ID
                    aPolygon=SonnetGeometryPolygon();
                    aPolygonId=zeros(1,length(aPolygonIndex));
                    aIndex=zeros(1,length(aPolygonIndex));
                    for iCounter=1:length(aPolygonIndex)
                        aPolygon(iCounter)=aArrayOfReferences{aPolygonIndex(iCounter)};
                        aPolygonId(iCounter)=aArrayOfReferences{aPolygonIndex(iCounter)}.DebugId;
                        
                        % Make sure the index of the polygon is correct.
                        % If not then search for the polygon. The results
                        % of cellfun are not always in order but usually are
                        % so it is faster to check if the value is correct and
                        % only do a slow search if necessary.
                        if aArrayOfReferences{aPolygonIndex(iCounter)}==obj.ArrayOfPolygons{aPolygonIndex(iCounter)}
                            aIndex(iCounter)=aPolygonIndex(iCounter);
                        else
                            isIndexFound=false;
                            for jCounter=1:length(obj.ArrayOfPolygons)
                                if aArrayOfReferences{aPolygonIndex(iCounter)}
                                    aIndex=jCounter;
                                    isIndexFound=true;
                                end
                            end
                            
                            if ~isIndexFound
                                error('Could not find the index for all of the found polygons');
                            end
                        end
                    end
                end
                
            else
                error('Invalid number of parameters.');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [aPolygon, aPolygonId, aIndex]=findPolygonUsingMeanX(obj,theXCoordinate,theLayer,theSize)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method finds the index for a polygon given its
            % mean X coordinate. This method may return
            % more than one polygon.
            % This returns the polygon object and its index in
            % the polygon array.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if nargin==4
                
                [aArrayOfMeanXValues, aArrayOfLayers, aArrayOfSizes, aArrayOfReferences]=cellfun(@(x) getPolygonMeanXLayerSize(obj,x),obj.ArrayOfPolygons,'UniformOutput',false);
                aArrayOfMeanXValues=cell2mat(aArrayOfMeanXValues);
                aArrayOfLayers=cell2mat(aArrayOfLayers);
                aArrayOfSizes=cell2mat(aArrayOfSizes);
                aPolygonIndex=find(theXCoordinate==aArrayOfMeanXValues & theLayer==aArrayOfLayers & theSize==aArrayOfSizes);
                
                if isempty(aPolygonIndex)
                    aPolygon=[];
                    aPolygonId=[];
                    aIndex=[];
                else
                    % Assign the polygon and polygon ID
                    aPolygon=SonnetGeometryPolygon();
                    aPolygonId=zeros(1,length(aPolygonIndex));
                    aIndex=zeros(1,length(aPolygonIndex));
                    for iCounter=1:length(aPolygonIndex)
                        aPolygon(iCounter)=aArrayOfReferences{aPolygonIndex(iCounter)};
                        aPolygonId(iCounter)=aArrayOfReferences{aPolygonIndex(iCounter)}.DebugId;
                        
                        % Make sure the index of the polygon is correct.
                        % If not then search for the polygon. The results
                        % of cellfun are not always in order but usually are
                        % so it is faster to check if the value is correct and
                        % only do a slow search if necessary.
                        if aArrayOfReferences{aPolygonIndex(iCounter)}==obj.ArrayOfPolygons{aPolygonIndex(iCounter)}
                            aIndex(iCounter)=aPolygonIndex(iCounter);
                        else
                            isIndexFound=false;
                            for jCounter=1:length(obj.ArrayOfPolygons)
                                if aArrayOfReferences{aPolygonIndex(iCounter)}
                                    aIndex=jCounter;
                                    isIndexFound=true;
                                end
                            end
                            
                            if ~isIndexFound
                                error('Could not find the index for all of the found polygons');
                            end
                        end
                    end
                end
                
            elseif nargin==3
                [aArrayOfMeanXValues, aArrayOfLayers, aArrayOfReferences]=cellfun(@(x) getPolygonMeanXLayer(obj,x),obj.ArrayOfPolygons,'UniformOutput',false);
                aArrayOfMeanXValues=cell2mat(aArrayOfMeanXValues);
                aArrayOfLayers=cell2mat(aArrayOfLayers);
                aPolygonIndex=find(theXCoordinate==aArrayOfMeanXValues & theLayer==aArrayOfLayers);
                
                if isempty(aPolygonIndex)
                    aPolygon=[];
                    aPolygonId=[];
                    aIndex=[];
                else
                    % Assign the polygon and polygon ID
                    aPolygon=SonnetGeometryPolygon();
                    aPolygonId=zeros(1,length(aPolygonIndex));
                    aIndex=zeros(1,length(aPolygonIndex));
                    for iCounter=1:length(aPolygonIndex)
                        aPolygon(iCounter)=aArrayOfReferences{aPolygonIndex(iCounter)};
                        aPolygonId(iCounter)=aArrayOfReferences{aPolygonIndex(iCounter)}.DebugId;
                        
                        % Make sure the index of the polygon is correct.
                        % If not then search for the polygon. The results
                        % of cellfun are not always in order but usually are
                        % so it is faster to check if the value is correct and
                        % only do a slow search if necessary.
                        if aArrayOfReferences{aPolygonIndex(iCounter)}==obj.ArrayOfPolygons{aPolygonIndex(iCounter)}
                            aIndex(iCounter)=aPolygonIndex(iCounter);
                        else
                            isIndexFound=false;
                            for jCounter=1:length(obj.ArrayOfPolygons)
                                if aArrayOfReferences{aPolygonIndex(iCounter)}
                                    aIndex=jCounter;
                                    isIndexFound=true;
                                end
                            end
                            
                            if ~isIndexFound
                                error('Could not find the index for all of the found polygons');
                            end
                        end
                    end
                end
                
            elseif nargin==2
                [aArrayOfMeanXValues, aArrayOfReferences]=cellfun(@(x) getPolygonMeanXLayer(obj,x),obj.ArrayOfPolygons,'UniformOutput',false);
                aArrayOfMeanXValues=cell2mat(aArrayOfMeanXValues);
                aPolygonIndex=find(theXCoordinate==aArrayOfMeanXValues);
                
                if isempty(aPolygonIndex)
                    aPolygon=[];
                    aPolygonId=[];
                    aIndex=[];
                else
                    % Assign the polygon and polygon ID
                    aPolygon=SonnetGeometryPolygon();
                    aPolygonId=zeros(1,length(aPolygonIndex));
                    aIndex=zeros(1,length(aPolygonIndex));
                    for iCounter=1:length(aPolygonIndex)
                        aPolygon(iCounter)=aArrayOfReferences{aPolygonIndex(iCounter)};
                        aPolygonId(iCounter)=aArrayOfReferences{aPolygonIndex(iCounter)}.DebugId;
                        
                        % Make sure the index of the polygon is correct.
                        % If not then search for the polygon. The results
                        % of cellfun are not always in order but usually are
                        % so it is faster to check if the value is correct and
                        % only do a slow search if necessary.
                        if aArrayOfReferences{aPolygonIndex(iCounter)}==obj.ArrayOfPolygons{aPolygonIndex(iCounter)}
                            aIndex(iCounter)=aPolygonIndex(iCounter);
                        else
                            isIndexFound=false;
                            for jCounter=1:length(obj.ArrayOfPolygons)
                                if aArrayOfReferences{aPolygonIndex(iCounter)}
                                    aIndex=jCounter;
                                    isIndexFound=true;
                                end
                            end
                            
                            if ~isIndexFound
                                error('Could not find the index for all of the found polygons');
                            end
                        end
                    end
                end
                
            else
                error('Invalid number of parameters.');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [aPolygon, aPolygonId, aIndex]=findPolygonUsingMeanY(obj,theYCoordinate,theLayer,theSize)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method finds the index for a polygon given its
            % mean Y coordinate. This method may return
            % more than one polygon.
            % This returns the polygon object and its index in
            % the polygon array.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if nargin==4
                
                [aArrayOfMeanYValues, aArrayOfLayers ,aArrayOfSizes ,aArrayOfReferences]=cellfun(@(x) getPolygonMeanYLayerSize(obj,x),obj.ArrayOfPolygons,'UniformOutput',false);
                aArrayOfMeanYValues=cell2mat(aArrayOfMeanYValues);
                aArrayOfLayers=cell2mat(aArrayOfLayers);
                aArrayOfSizes=cell2mat(aArrayOfSizes);
                aPolygonIndex=find(theYCoordinate==aArrayOfMeanYValues & theLayer==aArrayOfLayers & theSize==aArrayOfSizes);
                
                if isempty(aPolygonIndex)
                    aPolygon=[];
                    aPolygonId=[];
                    aIndex=[];
                else
                    % Assign the polygon and polygon ID
                    aPolygon=SonnetGeometryPolygon();
                    aPolygonId=zeros(1,length(aPolygonIndex));
                    aIndex=zeros(1,length(aPolygonIndex));
                    for iCounter=1:length(aPolygonIndex)
                        aPolygon(iCounter)=aArrayOfReferences{aPolygonIndex(iCounter)};
                        aPolygonId(iCounter)=aArrayOfReferences{aPolygonIndex(iCounter)}.DebugId;
                        
                        % Make sure the index of the polygon is correct.
                        % If not then search for the polygon. The results
                        % of cellfun are not always in order but usually are
                        % so it is faster to check if the value is correct and
                        % only do a slow search if necessary.
                        if aArrayOfReferences{aPolygonIndex(iCounter)}==obj.ArrayOfPolygons{aPolygonIndex(iCounter)}
                            aIndex(iCounter)=aPolygonIndex(iCounter);
                        else
                            isIndexFound=false;
                            for jCounter=1:length(obj.ArrayOfPolygons)
                                if aArrayOfReferences{aPolygonIndex(iCounter)}
                                    aIndex=jCounter;
                                    isIndexFound=true;
                                end
                            end
                            
                            if ~isIndexFound
                                error('Could not find the index for all of the found polygons');
                            end
                        end
                    end
                end
                
            elseif nargin==3
                
                [aArrayOfMeanYValues, aArrayOfLayers, aArrayOfReferences]=cellfun(@(x) getPolygonMeanYLayer(obj,x),obj.ArrayOfPolygons,'UniformOutput',false);
                aArrayOfMeanYValues=cell2mat(aArrayOfMeanYValues);
                aArrayOfLayers=cell2mat(aArrayOfLayers);
                aPolygonIndex=find(theYCoordinate==aArrayOfMeanYValues & theLayer==aArrayOfLayers);
                
                if isempty(aPolygonIndex)
                    aPolygon=[];
                    aPolygonId=[];
                    aIndex=[];
                else
                    % Assign the polygon and polygon ID
                    aPolygon=SonnetGeometryPolygon();
                    aPolygonId=zeros(1,length(aPolygonIndex));
                    aIndex=zeros(1,length(aPolygonIndex));
                    for iCounter=1:length(aPolygonIndex)
                        aPolygon(iCounter)=aArrayOfReferences{aPolygonIndex(iCounter)};
                        aPolygonId(iCounter)=aArrayOfReferences{aPolygonIndex(iCounter)}.DebugId;
                        
                        % Make sure the index of the polygon is correct.
                        % If not then search for the polygon. The results
                        % of cellfun are not always in order but usually are
                        % so it is faster to check if the value is correct and
                        % only do a slow search if necessary.
                        if aArrayOfReferences{aPolygonIndex(iCounter)}==obj.ArrayOfPolygons{aPolygonIndex(iCounter)}
                            aIndex(iCounter)=aPolygonIndex(iCounter);
                        else
                            isIndexFound=false;
                            for jCounter=1:length(obj.ArrayOfPolygons)
                                if aArrayOfReferences{aPolygonIndex(iCounter)}
                                    aIndex=jCounter;
                                    isIndexFound=true;
                                end
                            end
                            
                            if ~isIndexFound
                                error('Could not find the index for all of the found polygons');
                            end
                        end
                    end
                end
                
            elseif nargin==2
                
                [aArrayOfMeanYValues, aArrayOfReferences]=cellfun(@(x) getPolygonMeanY(obj,x),obj.ArrayOfPolygons,'UniformOutput',false);
                aArrayOfMeanYValues=cell2mat(aArrayOfMeanYValues);
                aPolygonIndex=find(theYCoordinate==aArrayOfMeanYValues);
                
                if isempty(aPolygonIndex)
                    aPolygon=[];
                    aPolygonId=[];
                    aIndex=[];
                else
                    % Assign the polygon and polygon ID
                    aPolygon=SonnetGeometryPolygon();
                    aPolygonId=zeros(1,length(aPolygonIndex));
                    aIndex=zeros(1,length(aPolygonIndex));
                    for iCounter=1:length(aPolygonIndex)
                        aPolygon(iCounter)=aArrayOfReferences{aPolygonIndex(iCounter)};
                        aPolygonId(iCounter)=aArrayOfReferences{aPolygonIndex(iCounter)}.DebugId;
                        
                        % Make sure the index of the polygon is correct.
                        % If not then search for the polygon. The results
                        % of cellfun are not always in order but usually are
                        % so it is faster to check if the value is correct and
                        % only do a slow search if necessary.
                        if aArrayOfReferences{aPolygonIndex(iCounter)}==obj.ArrayOfPolygons{aPolygonIndex(iCounter)}
                            aIndex(iCounter)=aPolygonIndex(iCounter);
                        else
                            isIndexFound=false;
                            for jCounter=1:length(obj.ArrayOfPolygons)
                                if aArrayOfReferences{aPolygonIndex(iCounter)}
                                    aIndex=jCounter;
                                    isIndexFound=true;
                                end
                            end
                            
                            if ~isIndexFound
                                error('Could not find the index for all of the found polygons');
                            end
                        end
                    end
                end
                
            else
                error('Invalid number of parameters.');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [aPort, aPortNumber, aIndex]=findPort(obj,thePortNumber)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will return a reference to the polygon
            % represented by a particular port number.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            aPort=[];
            aPortNumber=[];
            aIndex=[];
            
            for iCounter=1:length(obj.ArrayOfPolygons)
                if thePortNumber==obj.ArrayOfPorts{iCounter}.PortNumber
                    aPort=obj.ArrayOfPorts{iCounter};
                    aPortNumber=obj.ArrayOfPorts{iCounter}.PortNumber;
                    aIndex=iCounter;
                    break;
                end
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [thePolygon, thePolygonId, theIndex]=findPolygonUsingPoint(obj, theXCoordinate, theYCoordinate, theLevel)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method finds a polygon given a particular X
            % and Y coordinate that is within the polygon.
            % This method may return more than one polygon.
            % This returns the polygon object and its index in
            % the polygon array.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            thePolygon=[];
            theIndex=[];
            thePolygonId=[];
            
            for iCounter=1:length(obj.ArrayOfPolygons)
                
                anArrayOfXCoordinates=cell2mat(obj.ArrayOfPolygons{iCounter}.XCoordinateValues);
                anArrayOfYCoordinates=cell2mat(obj.ArrayOfPolygons{iCounter}.YCoordinateValues);
                
                if inpolygon(theXCoordinate,theYCoordinate,anArrayOfXCoordinates,anArrayOfYCoordinates)
                    
                    % If we have gotten the level and the polygon is not on our specified level then check next polygon
                    if nargin == 4 && theLevel~=obj.ArrayOfPolygons{iCounter}.MetalizationLevelIndex
                        continue;
                    else
                        thePolygon=[thePolygon obj.ArrayOfPolygons{iCounter}];  % Add the polygon to the array of matching polygons
                        theIndex=[theIndex iCounter];                           % Add the index to the array of indecies for the polygons
                        thePolygonId=[thePolygonId obj.ArrayOfPolygons{iCounter}.DebugId];         % Add the polygon's ID to the array of polygon ID's
                    end
                    
                end
                
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [thePort, thePortNumber, theIndex]=findPortUsingPoint(obj, theXCoordinate, theYCoordinate, theLevel)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method finds a port given a particular X
            % and Y coordinate that is 2% of the length of
            % the box width and height away from the port.
            % This method may return more than one port.
            % This returns the port object, port number and
            % its index in the port array. Only the closest port
            % is returned.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            thePort=[];
            thePortNumber=[];
            theIndex=[];
            aBestDistanceSum=inf;
            
            aThresholdX=.02*obj.xBoxSize;
            aThresholdY=.02*obj.yBoxSize;
            
            for iCounter=1:length(obj.ArrayOfPorts)
                
                aDistanceX=abs(obj.ArrayOfPorts{iCounter}.YCoordinate-theYCoordinate);
                aDistanceY=abs(obj.ArrayOfPorts{iCounter}.XCoordinate-theXCoordinate);
                
                if aDistanceX < aThresholdX && aDistanceY < aThresholdY && (aDistanceX+aDistanceY)<aBestDistanceSum
                    
                    % If we have gotten a level then we need to check that the port is on the right level
                    if nargin == 4
                        aPolygon=obj.ArrayOfPorts{iCounter}.Polygon;
                        if aPolygon.MetalizationLevelIndex ~= theLevel
                            continue;
                        else
                            aBestDistanceSum = aDistanceX + aDistanceY;
                            thePort=obj.ArrayOfPorts{iCounter};
                            thePortNumber=obj.ArrayOfPorts{iCounter}.PortNumber;
                            theIndex=iCounter;
                        end
                    else
                        aBestDistanceSum = aDistanceX + aDistanceY;
                        thePort=obj.ArrayOfPorts{iCounter};
                        thePortNumber=obj.ArrayOfPorts{iCounter}.PortNumber;
                        theIndex=iCounter;
                    end
                    
                end
                
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [thePort, thePortNumber, theIndex]=findPortsInGroup(obj, theGroupName)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method returns all the ports that
            %   are in a particular port group.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            thePort=[];
            thePortNumber=[];
            theIndex=[];
            
            for iCounter=1:length(obj.ArrayOfPorts)
                if ~isempty(obj.ArrayOfPorts{iCounter}.GroupName) && strcmpi(strrep(theGroupName,'"',''),strrep(obj.ArrayOfPorts{iCounter}.GroupName,'"',''))==1
                    if isempty(thePort)
                        thePort=obj.ArrayOfPorts{iCounter};
                        thePort(1)=obj.ArrayOfPorts{iCounter};
                    else
                        thePort(length(thePort)+1)=obj.ArrayOfPorts{iCounter};
                    end
                    thePortNumber(length(thePortNumber)+1)=obj.ArrayOfPorts{iCounter}.PortNumber;
                    theIndex(length(theIndex)+1)=iCounter;
                end
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function movePolygon(obj,thePolygon, theNewXCoordinate, theNewYCoordinate)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will move a polygon to a new x and
            % y location. It accepts as input either a polygon
            % object or an polygon ID for the appropriate polygon in
            % the polygon array. X and Y values are required. This
            % Function will call the polygon's internal move function.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Check the type of the passed polygon.
            % If it is an integer for the polygon's ID then
            % find the corresponding polygon. If we were passed
            % a polygon then that is fine. Anything else will
            % throw and error.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if isa(thePolygon,'SonnetGeometryPolygon') % If we were supplied a polygon then use that polygon
            else                                     % If we were supplied an ID for a polygon then find the polygon from the ID
                [~, thePolygon]=obj.findPolygonUsingId(thePolygon);
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % At this point we should have a valid polygon
            % to move. We will change its coordinates.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if isa(thePolygon,'SonnetGeometryPolygon')
                thePolygon.movePolygon(theNewXCoordinate,theNewYCoordinate);
            else
                error('Invalid debug ID. Does not correspond to any polygons');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function movePolygonUsingIndex(obj,thePolygon, theNewXCoordinate, theNewYCoordinate)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will move a polygon to a new x and
            % y location. It accepts as input either a polygon
            % object or an polygon ID for the appropriate polygon in
            % the polygon array. X and Y values are required. This
            % Function will call the polygon's internal move function.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Check the type of the passed polygon.
            % If it is an integer for the polygon's ID then
            % find the corresponding polygon. If we were passed
            % a polygon then that is fine. Anything else will
            % throw and error.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if isa(thePolygon,'SonnetGeometryPolygon') % If we were supplied a polygon then use that polygon
            else                                     % If we were supplied an ID for a polygon then find the polygon from the ID
                thePolygon=obj.ArrayOfPolygons{thePolygon};
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % At this point we should have a valid polygon
            % to move. We will change its coordinates.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if isa(thePolygon,'SonnetGeometryPolygon')
                thePolygon.movePolygon(theNewXCoordinate,theNewYCoordinate);
            else
                error('Invalid debug ID. Does not correspond to any polygons');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function movePolygonExact(obj,thePolygon, theNewXCoordinate, theNewYCoordinate)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method calls movePolygon to move the polgon.
            % this is just another name for the function.
            %
            % This method will move a polygon to a new x and
            % y location. It accepts as input either a polygon
            % object or an polygon ID for the appropriate polygon in
            % the polygon array. X and Y values are required. This
            % Function will call the polygon's internal move function.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            movePolygon(obj,thePolygon, theNewXCoordinate, theNewYCoordinate)
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function movePolygonExactUsingIndex(obj,thePolygon, theNewXCoordinate, theNewYCoordinate)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method calls movePolygon to move the polgon.
            % this is just another name for the function.
            %
            % This method will move a polygon to a new x and
            % y location. It accepts as input either a polygon
            % object or an polygon ID for the appropriate polygon in
            % the polygon array. X and Y values are required. This
            % Function will call the polygon's internal move function.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            movePolygonUsingIndex(obj,thePolygon, theNewXCoordinate, theNewYCoordinate)
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function movePolygonRelative(obj,thePolygon, theXChange, theYChange)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will move a polygon to an specified
            % amount in the x direction and y direction from
            % where it is currently located.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Check the type of the passed polygon.
            % If it is an integer then assign the variable to
            % the corresponding polygon. If it is a polygon
            % then that is fine. Anything else should throw
            % and error.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if isa(thePolygon,'SonnetGeometryPolygon') % If we were supplied a polygon then use that polygon
            else                                     % If we were supplied an ID for a polygon then find the polygon from the ID
                [~, thePolygon]=obj.findPolygonUsingId(thePolygon);
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % At this point we should have a valid polygon
            % to move. We will change its coordinates.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if isa(thePolygon,'SonnetGeometryPolygon')
                thePolygon.movePolygonRelative(theXChange, theYChange);
            else
                error('Invalid debug ID. Does not correspond to any polygons');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function movePolygonRelativeUsingIndex(obj,thePolygon, theXChange, theYChange)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will move a polygon to an specified
            % amount in the x direction and y direction from
            % where it is currently located.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Check the type of the passed polygon.
            % If it is an integer then assign the variable to
            % the corresponding polygon. If it is a polygon
            % then that is fine. Anything else should throw
            % and error.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if isa(thePolygon,'SonnetGeometryPolygon') % If we were supplied a polygon then use that polygon
            else                                     % If we were supplied an ID for a polygon then find the polygon from the ID
                [~, thePolygon]=obj.findPolygonUsingId(thePolygon);
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % At this point we should have a valid polygon
            % to move. We will change its coordinates.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if isa(thePolygon,'SonnetGeometryPolygon')
                thePolygon.movePolygonRelative(theXChange, theYChange);
            else
                error('Invalid debug ID. Does not correspond to any polygons');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function scalePolygon(obj,thePolygon, theXChangeFactor, theYChangeFactor)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will increase the size of a polygon by
            % multipling all of its coordinates by the passed
            % variables
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % If the passed polygon value was a polygon then change
            % the properties of that polygon. If the passed value was
            % an integer then modify the values for the polygon
            % specified at that integer location.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if isa(thePolygon,'SonnetGeometryPolygon') % If we were supplied a polygon then use that polygon
            else                                     % If we were supplied an ID for a polygon then find the polygon from the ID
                [~, thePolygon]=obj.findPolygonUsingId(thePolygon);
            end
            
            % Call the polygon's scale function
            if thePolygon ~= -1
                thePolygon.scalePolygon(theXChangeFactor, theYChangeFactor);
            else
                error('Invalid debug ID. Does not correspond to any polygons');
            end
            
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function scalePolygonUsingIndex(obj,thePolygon, theXChangeFactor, theYChangeFactor)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will increase the size of a polygon by
            % multipling all of its coordinates by the passed
            % variables
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % If the passed polygon value was a polygon then change
            % the properties of that polygon. If the passed value was
            % an integer then modify the values for the polygon
            % specified at that integer location.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if isa(thePolygon,'SonnetGeometryPolygon') % If we were supplied a polygon then use that polygon
            else                                     % If we were supplied an ID for a polygon then find the polygon from the ID
                thePolygon=obj.ArrayOfPolygons{thePolygon};
            end
            
            % Call the polygon's scale function
            if thePolygon ~= -1
                thePolygon.scalePolygon(theXChangeFactor, theYChangeFactor);
            else
                error('Invalid debug ID. Does not correspond to any polygons');
            end
            
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function scalePolygonFromPoint(obj, thePolygon,  theXChangeFactor, theYChangeFactor, thePointX, thePointY)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will increase the size of a polygon by
            % scaling the polygon by factors in the x and y
            % directions with respect to a particular coordinate.
            % if no coordinate is supplied the centroid is used.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Determines the validity of the polygon supplied, if it is an
            % integer than use it as ID for a polygon.
            if isa(thePolygon,'SonnetGeometryPolygon') % If we were supplied a polygon then use that polygon
            else                                     % If we were supplied an ID for a polygon then find the polygon from the ID
                [~, thePolygon]=obj.findPolygonUsingId(thePolygon);
            end
            
            % Call the polygon's scale function
            if thePolygon ~= -1
                if nargin == 6
                    thePolygon.scalePolygonFromPoint(theXChangeFactor, theYChangeFactor, thePointX, thePointY)
                elseif nargin == 4
                    thePolygon.scalePolygonFromPoint(theXChangeFactor, theYChangeFactor)
                elseif nargin == 2
                    thePolygon.scalePolygonFromPoint()
                end
            else
                error('Invalid debug ID. Does not correspond to any polygons');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function scalePolygonFromPointUsingIndex(obj, thePolygon,  theXChangeFactor, theYChangeFactor, thePointX, thePointY)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will increase the size of a polygon by
            % scaling the polygon by factors in the x and y
            % directions with respect to a particular coordinate.
            % if no coordinate is supplied the centroid is used.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Determines the validity of the polygon supplied, if it is an
            % integer than use it as ID for a polygon.
            if isa(thePolygon,'SonnetGeometryPolygon') % If we were supplied a polygon then use that polygon
            else                                     % If we were supplied an ID for a polygon then find the polygon from the ID
                thePolygon=obj.ArrayOfPolygons{thePolygon};
            end
            
            % Call the polygon's scale function
            if thePolygon ~= -1
                if nargin == 6
                    thePolygon.scalePolygonFromPoint(theXChangeFactor, theYChangeFactor, thePointX, thePointY)
                elseif nargin == 4
                    thePolygon.scalePolygonFromPoint(theXChangeFactor, theYChangeFactor)
                elseif nargin == 2
                    thePolygon.scalePolygonFromPoint()
                end
            else
                error('Invalid debug ID. Does not correspond to any polygons');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function flipPolygonXUsingId(obj,thePolygon)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Flip the passed polygon over its X axis.  The argument
            %   may either be a reference to a polygon or the
            %   polygon's debug ID.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Check the type of the passed polygon.
            % If it is an integer for the polygon's ID then
            % find the corresponding polygon. If we were passed
            % a polygon then that is fine. Anything else will
            % throw and error.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if isa(thePolygon,'SonnetGeometryPolygon') % If we were supplied a polygon then use that polygon
            else                                       % If we were supplied an ID for a polygon then find the polygon from the ID
                [~, thePolygon]=obj.findPolygonUsingId(thePolygon);
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % At this point we should have a valid polygon
            % to flip. We will change its coordinates.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if isa(thePolygon,'SonnetGeometryPolygon')
                thePolygon.flipPolygonX();
            else
                error('Invalid debug ID. Does not correspond to any polygons');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function flipPolygonYUsingId(obj,thePolygon)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Flip the passed polygon over its Y axis.  The argument
            %   may either be a reference to a polygon or the
            %   polygon's debug ID.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Check the type of the passed polygon.
            % If it is an integer for the polygon's ID then
            % find the corresponding polygon. If we were passed
            % a polygon then that is fine. Anything else will
            % throw and error.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if isa(thePolygon,'SonnetGeometryPolygon') % If we were supplied a polygon then use that polygon
            else                                       % If we were supplied an ID for a polygon then find the polygon from the ID
                [~, thePolygon]=obj.findPolygonUsingId(thePolygon);
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % At this point we should have a valid polygon
            % to flip. We will change its coordinates.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if isa(thePolygon,'SonnetGeometryPolygon')
                thePolygon.flipPolygonY();
            else
                error('Invalid debug ID. Does not correspond to any polygons');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function flipPolygonXUsingIndex(obj,thePolygon)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Flip the passed polygon over its X axis.  The argument
            %   may either be a reference to a polygon or the
            %   polygon's debug ID.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Check the type of the passed polygon.
            % If it is an integer for the polygon's ID then
            % find the corresponding polygon. If we were passed
            % a polygon then that is fine. Anything else will
            % throw and error.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if isa(thePolygon,'SonnetGeometryPolygon') % If we were supplied a polygon then use that polygon
            else                                       % If we were supplied an ID for a polygon then find the polygon from the ID
                thePolygon=obj.ArrayOfPolygons{thePolygon};
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % At this point we should have a valid polygon
            % to flip. We will change its coordinates.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if isa(thePolygon,'SonnetGeometryPolygon')
                thePolygon.flipPolygonX();
            else
                error('Invalid debug ID. Does not correspond to any polygons');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function flipPolygonYUsingIndex(obj,thePolygon)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Flip the passed polygon over its Y axis.  The argument
            %   may either be a reference to a polygon or the
            %   polygon's debug ID.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Check the type of the passed polygon.
            % If it is an integer for the polygon's ID then
            % find the corresponding polygon. If we were passed
            % a polygon then that is fine. Anything else will
            % throw and error.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if isa(thePolygon,'SonnetGeometryPolygon') % If we were supplied a polygon then use that polygon
            else                                       % If we were supplied an ID for a polygon then find the polygon from the ID
                thePolygon=obj.ArrayOfPolygons{thePolygon};
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % At this point we should have a valid polygon
            % to flip. We will change its coordinates.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if isa(thePolygon,'SonnetGeometryPolygon')
                thePolygon.flipPolygonY();
            else
                error('Invalid debug ID. Does not correspond to any polygons');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aNewPolygon=copyPolygonUsingId(obj,thePolygon)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %copyPolygonUsingId      Makes a copy of a polygon and adds it to the project
            %   copyMetalPolygonUsingId(ID) Makes a copy of the polygon  with the passed ID value in the
            %   array of polygons and adds the copy to the end of the array of
            %   polygons. The new polygon will have a unique debug ID. A reference
            %   to the polygon object may be passed instead of the ID.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if isa(thePolygon,'SonnetGeometryPolygon') % If we were supplied a polygon then use that polygon
            else                                       % If we were supplied an ID for a polygon then find the polygon from the ID
                [~, thePolygon]=obj.findPolygonUsingId(thePolygon);
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % At this point we should have a valid polygon
            % to copy. We will change its coordinates.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if isa(thePolygon,'SonnetGeometryPolygon')
                aNewPolygon=thePolygon.clone();
                aNewPolygon.DebugId=obj.generateUniqueId();
            else
                error('Invalid debug ID. Does not correspond to any polygons');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aNewPolygon=copyPolygonUsingIndex(obj,aPolygonIndex)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %copyPolygonUsingIndex      Makes a copy of a polygon and adds it to the project
            %   copyMetalPolygon(N) Makes a copy of the Nth polygon in the
            %   array of polygons and adds the copy to the end of the array of
            %   polygons. The new polygon will have a unique debug ID.  A reference
            %   to the polygon object may be passed instead of the ID.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if isa(aPolygonIndex,'SonnetGeometryPolygon')   % If we were supplied a polygon then use that polygon
            else                                            % If we were supplied an ID for a polygon then find the polygon from the ID
                thePolygon=obj.ArrayOfPolygons{aPolygonIndex};
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % At this point we should have a valid polygon
            % to copy. We will change its coordinates.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if isa(thePolygon,'SonnetGeometryPolygon')
                aNewPolygon=thePolygon.clone();
                aNewPolygon.DebugId=obj.generateUniqueId();
            else
                error('Invalid debug ID. Does not correspond to any polygons');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aPolygon=dividePolygonX(obj,thePolygon,theXValue)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Divide the passed polygon over an X value.  The argument
            %   may either be a reference to a polygon or the
            %   polygon's debug ID.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Check the type of the passed polygon.
            % If it is an integer for the polygon's ID then
            % find the corresponding polygon. If we were passed
            % a polygon then that is fine. Anything else will
            % throw and error.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if isa(thePolygon,'SonnetGeometryPolygon') % If we were supplied a polygon then use that polygon
            else                                       % If we were supplied an ID for a polygon then find the polygon from the ID
                [~, thePolygon]=obj.findPolygonUsingId(thePolygon);
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % At this point we should have a valid polygon
            % to flip. We will change its coordinates.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if isa(thePolygon,'SonnetGeometryPolygon')
                % Check that the divide point is within
                % the range of the polygon's X coordinates
                if theXValue>=max(cell2mat(thePolygon.XCoordinateValues)) || theXValue<=min(cell2mat(thePolygon.XCoordinateValues))
                    error('Specified X coordinate is outside the range of the polygon');
                else
                    aXCoordinatesLeftPolygon={};
                    aYCoordinatesLeftPolygon={};
                    aXCoordinatesRightPolygon={};
                    aYCoordinatesRightPolygon={};
                    
                    % Find the coordinates for the left polygon
                    for iCounter=1:length(thePolygon.XCoordinateValues)-1
                        if thePolygon.XCoordinateValues{iCounter}<=theXValue && ...
                                thePolygon.XCoordinateValues{iCounter+1}<=theXValue
                            % If this point and the point after it are on the
                            % correct side of the line then the point should be
                            % one this side of the line.
                            aXCoordinatesLeftPolygon{length(aXCoordinatesLeftPolygon)+1}=thePolygon.XCoordinateValues{iCounter};
                            aYCoordinatesLeftPolygon{length(aYCoordinatesLeftPolygon)+1}=thePolygon.YCoordinateValues{iCounter};
                            
                        elseif thePolygon.XCoordinateValues{iCounter}<=theXValue && ...
                                thePolygon.XCoordinateValues{iCounter+1}>theXValue
                            % If this point is on the correct side and the
                            % next point is on the wrong side then we need
                            % to find a point on the line that is correct.
                            % We will include the first point.
                            aXCoordinatesLeftPolygon{length(aXCoordinatesLeftPolygon)+1}=thePolygon.XCoordinateValues{iCounter};
                            aYCoordinatesLeftPolygon{length(aYCoordinatesLeftPolygon)+1}=thePolygon.YCoordinateValues{iCounter};
                            
                            % Find the slope
                            aSlope=(thePolygon.YCoordinateValues{iCounter+1}-thePolygon.YCoordinateValues{iCounter})/...
                                (thePolygon.XCoordinateValues{iCounter+1}-thePolygon.XCoordinateValues{iCounter});
                            
                            % Find the Y value
                            aYCoordinate=aSlope*theXValue-aSlope*thePolygon.XCoordinateValues{iCounter}+thePolygon.YCoordinateValues{iCounter};
                            
                            % Add the new coordinate pair to the array
                            aXCoordinatesLeftPolygon{length(aXCoordinatesLeftPolygon)+1}=theXValue;
                            aYCoordinatesLeftPolygon{length(aYCoordinatesLeftPolygon)+1}=aYCoordinate;
                            
                        elseif thePolygon.XCoordinateValues{iCounter}>theXValue && ...
                                thePolygon.XCoordinateValues{iCounter+1}<=theXValue
                            % If this point is on the wrong side and the
                            % next point is on the correct side then we need
                            % to find a point on the line that is correct.
                            % We will not include the first point.
                            
                            % Find the slope
                            aSlope=(thePolygon.YCoordinateValues{iCounter+1}-thePolygon.YCoordinateValues{iCounter})/...
                                (thePolygon.XCoordinateValues{iCounter+1}-thePolygon.XCoordinateValues{iCounter});
                            
                            % Find the Y value
                            aYCoordinate=aSlope*theXValue-aSlope*thePolygon.XCoordinateValues{iCounter}+thePolygon.YCoordinateValues{iCounter};
                            
                            % Add the new coordinate pair to the array
                            aXCoordinatesLeftPolygon{length(aXCoordinatesLeftPolygon)+1}=theXValue;
                            aYCoordinatesLeftPolygon{length(aYCoordinatesLeftPolygon)+1}=aYCoordinate;
                            
                        elseif thePolygon.XCoordinateValues{iCounter}>theXValue && ...
                                thePolygon.XCoordinateValues{iCounter+1}>=theXValue
                            % If this point is on the wrong side and the
                            % next point is on the wrong side then we don't
                            % include either point.
                            
                        else
                            % We should never get here
                            error('Unkown Error: This case should never exist.');
                        end
                    end
                    
                    % Find the coordinates for the right polygon
                    for iCounter=1:length(thePolygon.XCoordinateValues)-1
                        if thePolygon.XCoordinateValues{iCounter}>=theXValue && ...
                                thePolygon.XCoordinateValues{iCounter+1}>=theXValue
                            % If this point and the point after it are on the
                            % correct side of the line then the point should be
                            % one this side of the line.
                            aXCoordinatesRightPolygon{length(aXCoordinatesRightPolygon)+1}=thePolygon.XCoordinateValues{iCounter};
                            aYCoordinatesRightPolygon{length(aYCoordinatesRightPolygon)+1}=thePolygon.YCoordinateValues{iCounter};
                            
                        elseif thePolygon.XCoordinateValues{iCounter}>=theXValue && ...
                                thePolygon.XCoordinateValues{iCounter+1}<theXValue
                            % If this point is on the correct side and the
                            % next point is on the wrong side then we need
                            % to find a point on the line that is correct.
                            % We will include the first point.
                            aXCoordinatesRightPolygon{length(aXCoordinatesRightPolygon)+1}=thePolygon.XCoordinateValues{iCounter};
                            aYCoordinatesRightPolygon{length(aYCoordinatesRightPolygon)+1}=thePolygon.YCoordinateValues{iCounter};
                            
                            % Find the slope
                            aSlope=(thePolygon.YCoordinateValues{iCounter+1}-thePolygon.YCoordinateValues{iCounter})/...
                                (thePolygon.XCoordinateValues{iCounter+1}-thePolygon.XCoordinateValues{iCounter});
                            
                            % Find the Y value
                            aYCoordinate=aSlope*theXValue-aSlope*thePolygon.XCoordinateValues{iCounter}+thePolygon.YCoordinateValues{iCounter};
                            
                            % Add the new coordinate pair to the array
                            aXCoordinatesRightPolygon{length(aXCoordinatesRightPolygon)+1}=theXValue;
                            aYCoordinatesRightPolygon{length(aYCoordinatesRightPolygon)+1}=aYCoordinate;
                            
                        elseif thePolygon.XCoordinateValues{iCounter}<theXValue && ...
                                thePolygon.XCoordinateValues{iCounter+1}>=theXValue
                            % If this point is on the wrong side and the
                            % next point is on the correct side then we need
                            % to find a point on the line that is correct.
                            % We will not include the first point.
                            
                            % Find the slope
                            aSlope=(thePolygon.YCoordinateValues{iCounter+1}-thePolygon.YCoordinateValues{iCounter})/...
                                (thePolygon.XCoordinateValues{iCounter+1}-thePolygon.XCoordinateValues{iCounter});
                            
                            % Find the Y value
                            aYCoordinate=aSlope*theXValue-aSlope*thePolygon.XCoordinateValues{iCounter}+thePolygon.YCoordinateValues{iCounter};
                            
                            % Add the new coordinate pair to the array
                            aXCoordinatesRightPolygon{length(aXCoordinatesRightPolygon)+1}=theXValue;
                            aYCoordinatesRightPolygon{length(aYCoordinatesRightPolygon)+1}=aYCoordinate;
                            
                        elseif thePolygon.XCoordinateValues{iCounter}<theXValue && ...
                                thePolygon.XCoordinateValues{iCounter+1}<=theXValue
                            % If this point is on the wrong side and the
                            % next point is on the wrong side then we don't
                            % include either point.
                            
                        else
                            % We should never get here
                            error('Unkown Error: This case should never exist.');
                        end
                    end
                    
                    % Add the first point to the end
                    aXCoordinatesLeftPolygon{length(aXCoordinatesLeftPolygon)+1}=aXCoordinatesLeftPolygon{1};
                    aYCoordinatesLeftPolygon{length(aYCoordinatesLeftPolygon)+1}=aYCoordinatesLeftPolygon{1};
                    
                    % Add the first point to the end
                    aXCoordinatesRightPolygon{length(aXCoordinatesRightPolygon)+1}=aXCoordinatesRightPolygon{1};
                    aYCoordinatesRightPolygon{length(aYCoordinatesRightPolygon)+1}=aYCoordinatesRightPolygon{1};
                    
                    % Add the new polygon to the array of polygons
                    obj.ArrayOfPolygons{length(obj.ArrayOfPolygons)+1}=thePolygon.clone();
                    aPolygon=obj.ArrayOfPolygons{length(obj.ArrayOfPolygons)};
                    
                    % Make sure the new polygon has a unique debugId
                    aPolygon.DebugId=obj.generateUniqueId();
                    
                    % Modify the original polygon's coordinates
                    thePolygon.XCoordinateValues=aXCoordinatesLeftPolygon;
                    thePolygon.YCoordinateValues=aYCoordinatesLeftPolygon;
                    
                    % Modify the new polygon's coordinates
                    aPolygon.XCoordinateValues=aXCoordinatesRightPolygon;
                    aPolygon.YCoordinateValues=aYCoordinatesRightPolygon;
                    
                end
            else
                error('Invalid debug ID. Does not correspond to any polygons');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aDebugId=generateUniqueId(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will very quickly find a debugId
            % that is not being used by any other polygons in
            % the project. Values are not sequencial but are
            % found quickly even with a large number of polygons.
            %
            % If the project has no polygons a debug ID of one
            % is always returned.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if ~isempty(obj.ArrayOfPolygons)
                aDebugId=randi(length(obj.ArrayOfPolygons)*10,1);
                while true
                    if cellfun(@(x) isequal(x.DebugId, aDebugId),obj.ArrayOfPolygons)==0
                        break;
                    end
                    aDebugId=randi(length(obj.ArrayOfPolygons)*10,1);
                end
            else
                aDebugId=1;
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function assignUniqueDebugId(obj,aPolygon)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %   assignUniqueDebugId() will assign a polygon an unique debugId.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            aPolygon.DebugId=obj.generateUniqueId();
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function assignAllPolygonsSequentialIds(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %   This method will make sure all the
            %   polygons in a project have unique debugIds. This
            %   method will make all the debugIds be their current
            %   index in the array of polygons.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            for iCounter=1:length(obj.ArrayOfPolygons)
                obj.ArrayOfPolygons{iCounter}.DebugId=iCounter;
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function snapPolygonsToGrid(obj,theAxis)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will call the appropriate snap method
            % depending on the provided input to either snap to
            % the X axis, the Y axis or both. This snaps all
            % polygons to the grid.
            %
            % The user can send the following inputs:
            % 'x' or 'X' for x direction
            % 'Y' or 'Y' for x direction
            % 'xy' or 'XY' for x and y directions
            %
            % If no argument is supplied or an invalid one
            % is supplied an XY snap will be performed.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if nargin == 1 % If no argument is given then snap to X and Y
                for iCounter=1:length(obj.ArrayOfPolygons)
                    obj.ArrayOfPolygons{iCounter}.snapPolygonToGrid('XY',obj.xCellSize,obj.yCellSize);
                end
                
            else
                
                for iCounter=1:length(obj.ArrayOfPolygons)
                    obj.ArrayOfPolygons{iCounter}.snapPolygonToGrid(theAxis,obj.xCellSize,obj.yCellSize);
                end
                
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [aIndex aPolygon]=findComponentUsingId(obj,theId)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will try to find the index of a component
            % in the array of components. the component ID is passed to it.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            aIndex=[];
            aPolygon=[];
            for iCounter=1:length(obj.ArrayOfComponents)
                if obj.ArrayOfComponents{iCounter}.Id == theId
                    aIndex=iCounter;
                    aPolygon=obj.ArrayOfComponents{iCounter};
                    return
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [aIndex aPolygon]=findComponentUsingName(obj,theName)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will try to find the index of a component
            % in the array of components. the component name is passed to it.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            aIndex=[];
            aPolygon=[];
            theName=strrep(theName,'"','');
            for iCounter=1:length(obj.ArrayOfComponents)
                aName=strrep(obj.ArrayOfComponents{iCounter}.Name,'"','');
                if strcmpi(aName,theName)==1
                    aIndex=iCounter;
                    aPolygon=obj.ArrayOfComponents{iCounter};
                    return
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aIndex=findPolygonIndex(obj,thePolygon)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will try to find the index of a polygon
            % in the array of polygons. the polygon is passed to it.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            [aArrayOfIdValues aArrayOfReferences]=obj.getAllPolygonIds();
            
            aPolygonIndex=find(aArrayOfIdValues==thePolygon.DebugId,1);
            
            % Make sure the index of the polygon is correct.
            % If not then search for the polygon. The results
            % of cellfun are not always in order but usually are
            % so it is faster to check if the value is correct and
            % only do a slow search if necessary.
            if aArrayOfReferences{aPolygonIndex}==obj.ArrayOfPolygons{aPolygonIndex}
                aIndex=aPolygonIndex;
            else
                isIndexFound=false;
                for jCounter=1:length(obj.ArrayOfPolygons)
                    if aArrayOfReferences{aPolygonIndex}
                        aIndex=jCounter;
                        isIndexFound=true;
                    end
                end
                
                if ~isIndexFound
                    error('Could not find the index for all of the found polygons');
                end
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [aPolygonIndex aPolygon]=findPolygonUsingId(obj,theId)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will try to find the index of a polygon
            % in the array of polygons. the polygon's Debug ID is passed to it.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            [aArrayOfIdValues aArrayOfReferences]=obj.getAllPolygonIds();
            
            aPolygonIndex=find(aArrayOfIdValues==theId,1);
            
            if isempty(aPolygonIndex)
                aPolygon=[];
            else
                aPolygon=aArrayOfReferences{aPolygonIndex};
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function deletePolygonUsingId(obj,theId)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will try to delete a polygon from the
            % array of polygons. the polygon's Debug ID is passed to it.
            % If there are any Edge Vias connected to it they will be
            % deleted aswell. The function will return true if the delete
            % was performed and false otherwise.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            function copyAllPolygonsExceptThese(thePolygon,theId)
                if ~ismember(thePolygon.DebugId,theId)
                    aPolygons{iPolygonCounter}=thePolygon;
                    iPolygonCounter=iPolygonCounter+1;
                end
            end
            
            if isa(theId,'SonnetGeometryPolygon')
                for iCounter=1:length(theId)
                    aId(iCounter)=theId(iCounter).DebugId;
                end
                theId=aId;
            end
            
            aPolygons=cell(1,length(obj.ArrayOfPolygons)-length(theId));
            iPolygonCounter=1;
            cellfun(@(x) copyAllPolygonsExceptThese(x,theId),obj.ArrayOfPolygons,'UniformOutput',false);
            
            obj.ArrayOfPolygons=aPolygons;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function deletePolygonUsingIndex(obj,theIndex)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will try to delete a polygon from the
            % array of polygons. the polygon's Debug index is passed to it.
            % If there are any Edge Vias connected to it they will be
            % deleted aswell. The function will return true if the delete
            % was performed and false otherwise.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            function copyAllPolygonsExceptThese(thePolygon,theId)
                if ~ismember(thePolygon.DebugId,theId)
                    aPolygons{iPolygonCounter}=thePolygon;
                    iPolygonCounter=iPolygonCounter+1;
                end
            end
            
            if isa(theIndex,'SonnetGeometryPolygon')
                for iCounter=1:length(theIndex)
                    aId(iCounter)=theIndex.DebugId;
                end
            else
                for iCounter=1:length(theIndex)
                    aId(iCounter)=obj.ArrayOfPolygons{theIndex(iCounter)}.DebugId;
                end
            end
            
            aPolygons=cell(1,length(obj.ArrayOfPolygons)-length(theIndex));
            iPolygonCounter=1;
            cellfun(@(x) copyAllPolygonsExceptThese(x,aId),obj.ArrayOfPolygons,'UniformOutput',false);
            
            obj.ArrayOfPolygons=aPolygons;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changePolygonTypeUsingId(obj,theSonnetVersion,theId,theType)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %   changePolygonTypeUsingId(ID,Type) will try to change the
            %   composition of the polygon with the debugID of ID to the
            %   type Type. Type is a string. Type should be the name of the
            %   polygon type that should be used. If the polygon is a metal
            %   polygon then Type must be the name of a metal type in the
            %   project. If the polygon is a dielectric brick then Type
            %   should be the name of one of the brick types in the
            %   project.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Check that the polygon exists
            if isa(theId,'SonnetGeometryPolygon')
                aPolygon=theId;
            else
                [~, aPolygon]=obj.findPolygonUsingId(theId);
            end
            
            if isempty(aPolygon)
                error('Invalid ID supplied to changePolygonTypeUsingId');
            end
            
            if aPolygon.isPolygonMetal
                % If the user wants Lossless then type is -1
                if strcmpi(theType,'Lossless')==1
                    aPolygon.MetalType=-1;
                    return
                else % Find the index for the specified metal type
                    for iCounter=1:length(obj.ArrayOfMetalTypes)
                        if strcmpi(obj.ArrayOfMetalTypes{iCounter}.Type,'SFC')==1 || ...
                                strcmpi(obj.ArrayOfMetalTypes{iCounter}.Type,'ARR')==1 || ...
                                strcmpi(obj.ArrayOfMetalTypes{iCounter}.Type,'VOL')==1 || ...
                                strcmpi(obj.ArrayOfMetalTypes{iCounter}.Type,'Surface')==1 || ...
                                strcmpi(obj.ArrayOfMetalTypes{iCounter}.Type,'Array')==1 || ...
                                strcmpi(obj.ArrayOfMetalTypes{iCounter}.Type,'Volume')==1
                            continue
                        end
                        if strcmpi(obj.ArrayOfMetalTypes{iCounter}.Name,theType)==1
                            aPolygon.MetalType=iCounter-1;
                            return
                        end
                    end
                end
                
            elseif aPolygon.isPolygonVia
                % If the user wants Lossless then type is -1
                if strcmpi(theType,'Lossless')==1
                    aPolygon.MetalType=-1;
                    return
                else % Find the index for the specified metal type
                    for iCounter=1:length(obj.ArrayOfMetalTypes)
                        if theSonnetVersion < 13 ||...
                                strcmpi(obj.ArrayOfMetalTypes{iCounter}.Type,'SFC')==1 || ...
                                strcmpi(obj.ArrayOfMetalTypes{iCounter}.Type,'ARR')==1 || ...
                                strcmpi(obj.ArrayOfMetalTypes{iCounter}.Type,'VOL')==1 || ...
                                strcmpi(obj.ArrayOfMetalTypes{iCounter}.Type,'Surface')==1 || ...
                                strcmpi(obj.ArrayOfMetalTypes{iCounter}.Type,'Array')==1 || ...
                                strcmpi(obj.ArrayOfMetalTypes{iCounter}.Type,'Volume')==1
                            if strcmpi(obj.ArrayOfMetalTypes{iCounter}.Name,theType)==1
                                aPolygon.MetalType=iCounter-1;
                                return
                            end
                        end
                    end
                end
                
            elseif aPolygon.isPolygonBrick
                % Find the index for the specified brick type
                % If the user wants Air then type is 0
                if strcmpi(theType,'Air')==1
                    aPolygon.MetalType=0;
                    return
                else % Find the index for the specified brick type
                    % Seatch the list of Isotropic Dielectric Materials
                    for iCounter=1:length(obj.ArrayOfDielectricMaterials)
                        if strcmpi(obj.ArrayOfDielectricMaterials{iCounter}.Name,theType)==1
                            aPolygon.MetalType=iCounter;
                            return
                        end
                    end
                end
            end
            
            % If we get to here then we know that we didnt change the type
            % of the polygon. This occurs when the user supplies an invalid
            % name for the material type
            error('Unknown material type given to changePolygonTypeUsingId. The requested material must be defined before it can be used');
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changePolygonTypeUsingIndex(obj,theSonnetVersion,theIndex,theType)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %   changePolygonTypeUsingIndex(theIndex,Type) will try to change
            %   the composition of the polygon with the polygon's index in
            %   the array of polygons to type Type. Type is a string. Type
            %   should be the name of the polygon type that should be used.
            %   If the polygon is a metal polygon then Type must be the name
            %   of a metal type in the project. If the polygon is a dielectric
            %   brick then Type should be the name of one of the brick types
            %   in the project.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Check that the polygon index is in the range of the array
            if theIndex<1 || theIndex>length(obj.ArrayOfPolygons)
                error('Invalid index supplied to changePolygonTypeUsingIndex');
            end
            
            % Check that the polygon exists
            if isa(theIndex,'SonnetGeometryPolygon')
                aPolygon=theIndex;
            else
                aPolygon=obj.ArrayOfPolygons{theIndex};
            end
            
            if aPolygon.isPolygonMetal
                % If the user wants Lossless then type is -1
                if strcmpi(theType,'Lossless')==1
                    aPolygon.MetalType=-1;
                    return
                else % Find the index for the specified metal type
                    for iCounter=1:length(obj.ArrayOfMetalTypes)
                        if strcmpi(obj.ArrayOfMetalTypes{iCounter}.Type,'SFC')==1 || ...
                                strcmpi(obj.ArrayOfMetalTypes{iCounter}.Type,'ARR')==1 || ...
                                strcmpi(obj.ArrayOfMetalTypes{iCounter}.Type,'VOL')==1 || ...
                                strcmpi(obj.ArrayOfMetalTypes{iCounter}.Type,'Surface')==1 || ...
                                strcmpi(obj.ArrayOfMetalTypes{iCounter}.Type,'Array')==1 || ...
                                strcmpi(obj.ArrayOfMetalTypes{iCounter}.Type,'Volume')==1
                            continue
                        end
                        if strcmpi(obj.ArrayOfMetalTypes{iCounter}.Name,theType)==1
                            aPolygon.MetalType=iCounter-1;
                            return
                        end
                    end
                end
                
            elseif aPolygon.isPolygonVia
                % If the user wants Lossless then type is -1
                if strcmpi(theType,'Lossless')==1
                    aPolygon.MetalType=-1;
                    return
                else % Find the index for the specified metal type
                    for iCounter=1:length(obj.ArrayOfMetalTypes)
                        if theSonnetVersion < 13 ||...
                                strcmpi(obj.ArrayOfMetalTypes{iCounter}.Type,'SFC')==1 || ...
                                strcmpi(obj.ArrayOfMetalTypes{iCounter}.Type,'ARR')==1 || ...
                                strcmpi(obj.ArrayOfMetalTypes{iCounter}.Type,'VOL')==1 || ...
                                strcmpi(obj.ArrayOfMetalTypes{iCounter}.Type,'Surface')==1 || ...
                                strcmpi(obj.ArrayOfMetalTypes{iCounter}.Type,'Array')==1 || ...
                                strcmpi(obj.ArrayOfMetalTypes{iCounter}.Type,'Volume')==1
                            if strcmpi(obj.ArrayOfMetalTypes{iCounter}.Name,theType)==1
                                aPolygon.MetalType=iCounter-1;
                                return
                            end
                        end
                    end
                end
                
            elseif aPolygon.isPolygonBrick
                % Find the index for the specified brick type
                % If the user wants Air then type is 0
                if strcmpi(theType,'Air')==1
                    aPolygon.MetalType=0;
                    return
                else % Find the index for the specified brick type
                    % Seatch the list of Isotropic Dielectric Materials
                    for iCounter=1:length(obj.ArrayOfDielectricMaterials)
                        if strcmpi(obj.ArrayOfDielectricMaterials{iCounter}.Name,theType)==1
                            aPolygon.MetalType=iCounter;
                            return
                        end
                    end
                end
            end
            
            % If we get to here then we know that we didnt change the type
            % of the polygon. This occurs when the user supplies an invalid
            % name for the material type
            error('Unknown material type given to changePolygonTypeUsingIndex. The requested material must be defined before it can be used');
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function checkToDeleteVia(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will delete vias if their polygons have
            % been deleted.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if ~isempty(obj.ArrayOfEdgeVias) && obj.DoneConstructing==true
                
                iCounter=1;
                while iCounter<=length(obj.ArrayOfEdgeVias)
                    
                    if isempty(obj.findPolygonUsingId(obj.ArrayOfEdgeVias{iCounter}.Polygon.DebugId))
                        obj.ArrayOfEdgeVias(iCounter)=[];
                    else
                        iCounter=iCounter+1;
                    end
                    
                end
                
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function checkToDeleteDimension(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will delete dimension objectes if
            % their polygons have been deleted.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if ~isempty(obj.ArrayOfDimensions) && obj.DoneConstructing==true
                
                iCounter=1;
                while iCounter<=length(obj.ArrayOfDimensions)
                    
                    if isempty(obj.findPolygonUsingId(obj.ArrayOfDimensions{iCounter}.ReferencePolygon1.DebugId)) || ...
                            isempty(obj.findPolygonUsingId(obj.ArrayOfDimensions{iCounter}.ReferencePolygon2.DebugId))
                        obj.ArrayOfDimensions(iCounter)=[];
                    else
                        iCounter=iCounter+1;
                    end
                    
                end
                
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function checkToDeletePort(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will delete vias if their polygons have
            % been deleted.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if ~isempty(obj.ArrayOfPorts) && obj.DoneConstructing==true
                
                iCounter=1;
                while iCounter<=length(obj.ArrayOfPorts)
                    
                    if isempty(obj.findPolygonUsingId(obj.ArrayOfPorts{iCounter}.Polygon.DebugId))
                        obj.ArrayOfPorts(iCounter)=[];
                    else
                        iCounter=iCounter+1;
                    end
                    
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function checkToDeleteParameter(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will delete parameters if their polygons have
            % been deleted.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if ~isempty(obj.ArrayOfParameters) && obj.DoneConstructing==true
                
                iCounter=1;
                while iCounter<=length(obj.ArrayOfParameters)
                    
                    aThePolygonExists=true;
                    
                    % Make sure the reference planes still
                    % point to existing polygons.
                    if isempty(obj.findPolygonUsingId(obj.ArrayOfParameters{iCounter}.ReferencePolygon1.DebugId))
                        aThePolygonExists=false;
                    end
                    if isempty(obj.findPolygonUsingId(obj.ArrayOfParameters{iCounter}.ReferencePolygon2.DebugId))
                        aThePolygonExists=false;
                    end
                    
                    % Make sure the point sets still
                    % point to existing polygons.
                    for jCounter=1:length(obj.ArrayOfParameters{iCounter}.PointSet1.ArrayOfPolygons)
                        if isempty(obj.findPolygonUsingId(obj.ArrayOfParameters{iCounter}.PointSet1.ArrayOfPolygons{jCounter}.DebugId))
                            aThePolygonExists=false;
                            break;
                        end
                    end
                    for jCounter=1:length(obj.ArrayOfParameters{iCounter}.PointSet2.ArrayOfPolygons)
                        if isempty(obj.findPolygonUsingId(obj.ArrayOfParameters{iCounter}.PointSet2.ArrayOfPolygons{jCounter}.DebugId))
                            aThePolygonExists=false;
                            break;
                        end
                    end
                    
                    if aThePolygonExists==false
                        obj.ArrayOfParameters(iCounter)=[];
                    else
                        iCounter=iCounter+1;
                    end
                    
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [aId thePolygon]=getPolygonId(obj,thePolygon) %#ok<MANU>
            aId=thePolygon.DebugId;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [aCentroidX aCentroidY thePolygon]=getPolygonCentroidXY(obj,thePolygon) %#ok<MANU>
            aCentroidX=thePolygon.CentroidXCoordinate;
            aCentroidY=thePolygon.CentroidYCoordinate;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [aCentroidX aCentroidY aLayer thePolygon]=getPolygonCentroidXYLayer(obj,thePolygon) %#ok<MANU>
            aCentroidX=thePolygon.CentroidXCoordinate;
            aCentroidY=thePolygon.CentroidYCoordinate;
            aLayer=thePolygon.MetalizationLevelIndex;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [aCentroidX aCentroidY aLayer aSize thePolygon]=getPolygonCentroidXYLayerSize(obj,thePolygon) %#ok<MANU>
            aCentroidX=thePolygon.CentroidXCoordinate;
            aCentroidY=thePolygon.CentroidYCoordinate;
            aLayer=thePolygon.MetalizationLevelIndex;
            aSize=thePolygon.PolygonSize;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [aCentroidX thePolygon]=getPolygonCentroidX(obj,thePolygon) %#ok<MANU>
            aCentroidX=thePolygon.CentroidXCoordinate;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [aCentroidX aLayer thePolygon]=getPolygonCentroidXLayer(obj,thePolygon) %#ok<MANU>
            aCentroidX=thePolygon.CentroidXCoordinate;
            aLayer=thePolygon.MetalizationLevelIndex;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [aCentroidX aLayer aSize thePolygon]=getPolygonCentroidXLayerSize(obj,thePolygon) %#ok<MANU>
            aCentroidX=thePolygon.CentroidXCoordinate;
            aLayer=thePolygon.MetalizationLevelIndex;
            aSize=thePolygon.PolygonSize;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [aCentroidY thePolygon]=getPolygonCentroidY(obj,thePolygon) %#ok<MANU>
            aCentroidY=thePolygon.CentroidYCoordinate;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [aCentroidY aLayer thePolygon]=getPolygonCentroidYLayer(obj,thePolygon) %#ok<MANU>
            aCentroidY=thePolygon.CentroidYCoordinate;
            aLayer=thePolygon.MetalizationLevelIndex;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [aCentroidY aLayer aSize thePolygon]=getPolygonCentroidYLayerSize(obj,thePolygon) %#ok<MANU>
            aCentroidY=thePolygon.CentroidYCoordinate;
            aLayer=thePolygon.MetalizationLevelIndex;
            aSize=thePolygon.PolygonSize;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [aMeanX aMeanY thePolygon]=getPolygonMeanXY(obj,thePolygon) %#ok<MANU>
            aMeanX=thePolygon.MeanXCoordinate;
            aMeanY=thePolygon.MeanYCoordinate;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [aMeanX aMeanY aLayer thePolygon]=getPolygonMeanXYLayer(obj,thePolygon) %#ok<MANU>
            aMeanX=thePolygon.MeanXCoordinate;
            aMeanY=thePolygon.MeanYCoordinate;
            aLayer=thePolygon.MetalizationLevelIndex;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [aMeanX aMeanY aLayer aSize thePolygon]=getPolygonMeanXYLayerSize(obj,thePolygon) %#ok<MANU>
            aMeanX=thePolygon.MeanXCoordinate;
            aMeanY=thePolygon.MeanYCoordinate;
            aLayer=thePolygon.MetalizationLevelIndex;
            aSize=thePolygon.PolygonSize;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [aMeanX aMeanY thePolygon]=getPolygonMeanX(obj,thePolygon) %#ok<MANU>
            aMeanX=thePolygon.MeanXCoordinate;
            aMeanY=thePolygon.MeanYCoordinate;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [aMeanX aMeanY aLayer thePolygon]=getPolygonMeanXLayer(obj,thePolygon) %#ok<MANU>
            aMeanX=thePolygon.MeanXCoordinate;
            aMeanY=thePolygon.MeanYCoordinate;
            aLayer=thePolygon.MetalizationLevelIndex;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [aMeanX aMeanY aLayer aSize thePolygon]=getPolygonMeanXLayerSize(obj,thePolygon) %#ok<MANU>
            aMeanX=thePolygon.MeanXCoordinate;
            aMeanY=thePolygon.MeanYCoordinate;
            aLayer=thePolygon.MetalizationLevelIndex;
            aSize=thePolygon.PolygonSize;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [aMeanX aMeanY thePolygon]=getPolygonMeanY(obj,thePolygon) %#ok<MANU>
            aMeanX=thePolygon.MeanXCoordinate;
            aMeanY=thePolygon.MeanYCoordinate;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [aMeanX aMeanY aLayer thePolygon]=getPolygonMeanYLayer(obj,thePolygon) %#ok<MANU>
            aMeanX=thePolygon.MeanXCoordinate;
            aMeanY=thePolygon.MeanYCoordinate;
            aLayer=thePolygon.MetalizationLevelIndex;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [aMeanX aMeanY aLayer aSize thePolygon]=getPolygonMeanYLayerSize(obj,thePolygon) %#ok<MANU>
            aMeanX=thePolygon.MeanXCoordinate;
            aMeanY=thePolygon.MeanYCoordinate;
            aLayer=thePolygon.MetalizationLevelIndex;
            aSize=thePolygon.PolygonSize;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [aXCoordinateValues aYCoordinateValues aLayer aSize thePolygon]=getPolygonPoints(obj,thePolygon) %#ok<MANU>
            aXCoordinateValues=cell2mat(thePolygon.XCoordinateValues);
            aYCoordinateValues=cell2mat(thePolygon.YCoordinateValues);
            aLayer=thePolygon.MetalizationLevelIndex;
            aSize=thePolygon.PolygonSize;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [aArrayOfIdValues aArrayOfReferences]=getAllPolygonIds(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Makes a vector for the ID and the reference for all
            % of the polygons in the array of polygons.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            [aArrayOfIdValues aArrayOfReferences]=cellfun(@(x) getPolygonId(obj,x),obj.ArrayOfPolygons,'UniformOutput',false);
            aArrayOfIdValues=cell2mat(aArrayOfIdValues);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [aCentroidX aCentroidY aLayer aSize thePolygon]=getAllPolygonCentroids(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Makes a vector for the ID and the reference for all
            % of the polygons in the array of polygons.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            [aCentroidX aCentroidY aLayer aSize thePolygon]=cellfun(@(x) getPolygonCentroidXYLayerSize(obj,x),obj.ArrayOfPolygons,'UniformOutput',false);
            aCentroidX=cell2mat(aCentroidX);
            aCentroidY=cell2mat(aCentroidY);
            aLayer=cell2mat(aLayer);
            aSize=cell2mat(aSize);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [aMeanX aMeanY aLayer aSize thePolygon]=getAllPolygonMeans(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Makes a vector for the ID and the reference for all
            % of the polygons in the array of polygons.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            [aMeanX aMeanY aLayer aSize thePolygon]=cellfun(@(x) getPolygonMeanXYLayerSize(obj,x),obj.ArrayOfPolygons,'UniformOutput',false);
            aMeanX=cell2mat(aMeanX);
            aMeanY=cell2mat(aMeanY);
            aLayer=cell2mat(aLayer);
            aSize=cell2mat(aSize);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [aXCoordinateValues aYCoordinateValues thePolygon]=getAllPolygonPoints(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Makes a vector for the ID and the reference for all
            % of the polygons in the array of polygons.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            [aXCoordinateValues aYCoordinateValues thePolygon]=cellfun(@(x) getPolygonPoints(obj,x),obj.ArrayOfPolygons,'UniformOutput',false);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function assignPolygonReferences(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Changes references for ports from being debugIds
            % to being polygon references.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Build a list of polygon ID values
            [aArrayOfIdValues aArrayOfReferences]=obj.getAllPolygonIds();
            
            % Assign references for all of the ports
            for iCounter = 1:length(obj.ArrayOfPorts)
                aPolygonIndex=find(aArrayOfIdValues==obj.ArrayOfPorts{iCounter}.Polygon,1);
                if ~isempty(aPolygonIndex)
                    obj.ArrayOfPorts{iCounter}.Polygon=aArrayOfReferences{aPolygonIndex};
                else
                    error(['Port number ' num2str(obj.ArrayOfPorts{iCounter}.PortNumber) ...
                        ' (index is ' num2str(iCounter) ') is attached to an non-existing polygon.']);
                end
                if ~isempty(obj.ArrayOfPorts{iCounter}.ReferencePlaneLink)
                    aPolygonIndex=find(aArrayOfIdValues==obj.ArrayOfPorts{iCounter}.ReferencePlaneLink,1);
                    if ~isempty(aPolygonIndex)
                        obj.ArrayOfPorts{iCounter}.ReferencePlaneLink=aArrayOfReferences{aPolygonIndex};
                    else
                        error(['Port reference link number ' num2str(obj.ArrayOfPorts{iCounter}.PortNumber) ...
                            ' (index is ' num2str(iCounter) ') is attached to an non-existing polygon.']);
                    end
                end
            end
            
            % Assign references for all of the edge vias
            for iCounter = 1:length(obj.ArrayOfEdgeVias)
                aPolygonIndex=find(aArrayOfIdValues==obj.ArrayOfEdgeVias{iCounter}.Polygon,1);
                if ~isempty(aPolygonIndex)
                    obj.ArrayOfEdgeVias{iCounter}.Polygon=aArrayOfReferences{aPolygonIndex};
                else
                    error(['Edge via number ' num2str(iCounter) ' is attached to an non-existing polygon.']);
                end
            end
            
            % Assign references for all of the edge vias
            for iCounter = 1:length(obj.ArrayOfDimensions)
                aPolygonIndex=find(aArrayOfIdValues==obj.ArrayOfDimensions{iCounter}.ReferencePolygon1,1);
                if ~isempty(aPolygonIndex)
                    obj.ArrayOfDimensions{iCounter}.ReferencePolygon1=aArrayOfReferences{aPolygonIndex};
                else
                    error(['ReferencePolygon1 of Dimension number ' num2str(iCounter) ' is attached to an non-existing polygon.']);
                end
                aPolygonIndex=find(aArrayOfIdValues==obj.ArrayOfDimensions{iCounter}.ReferencePolygon2,1);
                if ~isempty(aPolygonIndex)
                    obj.ArrayOfDimensions{iCounter}.ReferencePolygon2=aArrayOfReferences{aPolygonIndex};
                else
                    error(['ReferencePolygon2 of Dimension number ' num2str(iCounter) ' is attached to an non-existing polygon.']);
                end
            end
            
            % Build a list of reference plane link values
            if ~isempty(obj.ReferencePlanes)
                if isa(obj.ReferencePlanes.LeftSide,'SonnetGeometryReferencePlaneLink')
                    aPolygonIndex=find(aArrayOfIdValues==obj.ReferencePlanes.LeftSide.Polygon,1);
                    if ~isempty(aPolygonIndex)
                        obj.ReferencePlanes.LeftSide.Polygon=aArrayOfReferences{aPolygonIndex};
                    else
                        error('Reference plane left side is attached to an non-existing polygon.');
                    end
                end
                if isa(obj.ReferencePlanes.RightSide,'SonnetGeometryReferencePlaneLink')
                    aPolygonIndex=find(aArrayOfIdValues==obj.ReferencePlanes.RightSide.Polygon,1);
                    if ~isempty(aPolygonIndex)
                        obj.ReferencePlanes.RightSide.Polygon=aArrayOfReferences{aPolygonIndex};
                    else
                        error('Reference plane right side is attached to an non-existing polygon.');
                    end
                end
                if isa(obj.ReferencePlanes.TopSide,'SonnetGeometryReferencePlaneLink')
                    aPolygonIndex=find(aArrayOfIdValues==obj.ReferencePlanes.TopSide.Polygon,1);
                    if ~isempty(aPolygonIndex)
                        obj.ReferencePlanes.TopSide.Polygon=aArrayOfReferences{aPolygonIndex};
                    else
                        error('Reference plane top side is attached to an non-existing polygon.');
                    end
                end
                if isa(obj.ReferencePlanes.BottomSide,'SonnetGeometryReferencePlaneLink')
                    aPolygonIndex=find(aArrayOfIdValues==obj.ReferencePlanes.BottomSide.Polygon,1);
                    if ~isempty(aPolygonIndex)
                        obj.ReferencePlanes.BottomSide.Polygon=aArrayOfReferences{aPolygonIndex};
                    else
                        error('Reference plane bottom side is attached to an non-existing polygon.');
                    end
                end
            end
            
            % Assign references for all of the parameters
            for iCounter = 1:length(obj.ArrayOfParameters)
                aPolygonIndex=find(aArrayOfIdValues==obj.ArrayOfParameters{iCounter}.ReferencePolygon1,1);
                if ~isempty(aPolygonIndex)
                    obj.ArrayOfParameters{iCounter}.ReferencePolygon1=aArrayOfReferences{aPolygonIndex};
                else
                    error(['ReferencePolygon1 of Parameter number ' num2str(iCounter) ' is attached to an non-existing polygon.']);
                end
                aPolygonIndex=find(aArrayOfIdValues==obj.ArrayOfParameters{iCounter}.ReferencePolygon2,1);
                if ~isempty(aPolygonIndex)
                    obj.ArrayOfParameters{iCounter}.ReferencePolygon2=aArrayOfReferences{aPolygonIndex};
                else
                    error(['ReferencePolygon2 of Parameter number ' num2str(iCounter) ' is attached to an non-existing polygon.']);
                end
                for jCounter=1:length(obj.ArrayOfParameters{iCounter}.PointSet1.ArrayOfPolygons)
                    aPolygonIndex=find(aArrayOfIdValues==obj.ArrayOfParameters{iCounter}.PointSet1.ArrayOfPolygons{jCounter},1);
                    if ~isempty(aPolygonIndex)
                        obj.ArrayOfParameters{iCounter}.PointSet1.ArrayOfPolygons{jCounter}=aArrayOfReferences{aPolygonIndex};
                    else
                        error(['A point in PointSet1 of Parameter number ' num2str(iCounter) ' is attached to an non-existing polygon.']);
                    end
                end
                for jCounter=1:length(obj.ArrayOfParameters{iCounter}.PointSet2.ArrayOfPolygons)
                    aPolygonIndex=find(aArrayOfIdValues==obj.ArrayOfParameters{iCounter}.PointSet2.ArrayOfPolygons{jCounter},1);
                    if ~isempty(aPolygonIndex)
                        obj.ArrayOfParameters{iCounter}.PointSet2.ArrayOfPolygons{jCounter}=aArrayOfReferences{aPolygonIndex};
                    else
                        error(['A point in PointSet2 of Parameter number ' num2str(iCounter) ' is attached to an non-existing polygon.']);
                    end
                end
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addDimensionLabel(obj,theReferencePolygon1,theReferenceVertex1,theReferencePolygon2,theReferenceVertex2,theDirection)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %   addDimensionLabel will add a geometry
            %   dimension label to the project.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            aDimension=SonnetGeometryDimension();
            
            aDimension.Type='STD';
            aDimension.ParameterLabelXCoord=0;
            aDimension.ParameterLabelYCoord=0;
                                    
            % Get handles to the reference polygons
            if isa(theReferencePolygon1,'SonnetGeometryPolygon')
            else
                [~, theReferencePolygon1]=obj.findPolygonUsingId(theReferencePolygon1);
                if isempty(theReferencePolygon1)
                    error('ReferencePolygon1: Specified polygon was not found.');
                end
            end
            if isa(theReferencePolygon2,'SonnetGeometryPolygon')
            else
                [~, theReferencePolygon2]=obj.findPolygonUsingId(theReferencePolygon2);
                if isempty(theReferencePolygon2)
                    error('ReferencePolygon2: Specified polygon was not found.');
                end
            end
            
            % Assign the values for the reference polygons and points
            aDimension.ReferencePolygon1=theReferencePolygon1;
            aDimension.ReferenceVertex1=theReferenceVertex1;
            aDimension.ReferencePolygon2=theReferencePolygon2;
            aDimension.ReferenceVertex2=theReferenceVertex2;
            
            % Store the movement direction
            if strcmpi(theDirection,'X')==1 || strcmpi(theDirection,'XDIR')==1
                aDimension.Direction='XDIR';
            elseif strcmpi(theDirection,'Y')==1 || strcmpi(theDirection,'YDIR')==1
                aDimension.Direction='YDIR';
            else
                error('Improper direction selection')
            end
                        
            % Append the parameter to the array of parameters
            obj.ArrayOfDimensions{end+1}=aDimension;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addAnchoredDimensionParameter(obj,theParameterName,...
                theReferencePolygon1,theReferenceVertex1,...
                theReferencePolygon2,theReferenceVertex2,...
                theArrayOfOtherPolygons, theArrayOfOtherVertices,...
                theDirection,theEquation)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %   addDimensionParameter will add a geometry
            %   dimension parameter to the project.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            aParameter=SonnetGeometryParameter();
            
            aParameter.ParameterLabelXCoord=0;
            aParameter.ParameterLabelYCoord=0;
            
            aParameter.Parname=theParameterName;
            aParameter.Partype='ANC';
            aParameter.Scaletype='NSCD';
            
            if nargin==8
                aParameter.Equation=theEquation;
            end
            
            % Get handles to the reference polygons
            if isa(theReferencePolygon1,'SonnetGeometryPolygon')
            else
                [~, theReferencePolygon1]=obj.findPolygonUsingId(theReferencePolygon1);
                if isempty(theReferencePolygon1)
                    error('ReferencePolygon1: Specified polygon was not found.');
                end
            end
            if isa(theReferencePolygon2,'SonnetGeometryPolygon')
            else
                [~, theReferencePolygon2]=obj.findPolygonUsingId(theReferencePolygon2);
                if isempty(theReferencePolygon2)
                    error('ReferencePolygon2: Specified polygon was not found.');
                end
            end
            
            % Assign the values for the reference points
            aParameter.ReferencePolygon1=theReferencePolygon1;
            aParameter.ReferenceVertex1=theReferenceVertex1;
            aParameter.ReferencePolygon2=theReferencePolygon2;
            aParameter.ReferenceVertex2=theReferenceVertex2;
            
            % Store the movement direction
            if strcmpi(theDirection,'X')==1 || strcmpi(theDirection,'XDIR')==1
                aParameter.Direction='XDIR';
            elseif strcmpi(theDirection,'Y')==1 || strcmpi(theDirection,'YDIR')==1
                aParameter.Direction='YDIR';
            else
                error('Improper direction selection')
            end
            
            % Set the values for the point set
            aPointSet1=SonnetGeometryParameterPointSet();
            aPointSet2=SonnetGeometryParameterPointSet();
            if length(theArrayOfOtherPolygons)==1 && ~isa(theArrayOfOtherPolygons,'cell')
                if isa(theArrayOfOtherPolygons,'SonnetGeometryPolygon')
                    aPointSet2.ArrayOfPolygons{1}=theArrayOfOtherPolygons;
                else
                    [~, aPointSet2.ArrayOfPolygons{1}]=obj.findPolygonUsingId(theArrayOfOtherPolygons);
                    if isempty(aPointSet2.ArrayOfPolygons{1})
                        error('Specified polygon was not found.');
                    end
                end
                if isempty(theArrayOfOtherVertices)
                    % Include all the polygon's vertices
                    aPointSet2.ArrayOfVertexVectors{1}=1:length(aPointSet2.ArrayOfPolygons{1}.XCoordinateValues)-1;
                    jCounter=1;
                    while jCounter<=length(aPointSet2.ArrayOfVertexVectors{1})
                        if aPointSet2.ArrayOfPolygons{1}==theReferencePolygon2 &&...
                                aPointSet2.ArrayOfVertexVectors{1}(jCounter)==theReferenceVertex2
                            aPointSet2.ArrayOfVertexVectors{1}(jCounter)=[];
                        else
                            jCounter=jCounter+1;
                        end
                    end
                else
                    aPointSet2.ArrayOfVertexVectors{1}=theArrayOfOtherVertices;
                end
            else
                for iCounter=1:length(theArrayOfOtherPolygons)
                    if isa(theArrayOfOtherPolygons{iCounter},'SonnetGeometryPolygon')
                        for jCounter=1:length(theArrayOfOtherPolygons)
                            aPointSet2.ArrayOfPolygons{jCounter}=theArrayOfOtherPolygons{jCounter};
                        end
                    else
                        [~, aPointSet2.ArrayOfPolygons{iCounter}]=obj.findPolygonUsingId(theArrayOfOtherPolygons{iCounter});
                        if isempty(aPointSet2.ArrayOfPolygons{iCounter})
                            error('Specified polygon was not found.');
                        end
                    end
                end
                for iCounter=1:length(theArrayOfOtherPolygons)
                    if isempty(theArrayOfOtherVertices{iCounter})
                        % Include all the polygon's vertices
                        aPointSet2.ArrayOfVertexVectors{iCounter}=1:length(aPointSet2.ArrayOfPolygons{iCounter}.XCoordinateValues)-1;
                        jCounter=1;
                        while jCounter<=length(aPointSet2.ArrayOfVertexVectors{iCounter})
                            if aPointSet2.ArrayOfPolygons{iCounter}==theReferencePolygon2 &&...
                                    aPointSet2.ArrayOfVertexVectors{iCounter}(jCounter)==theReferenceVertex2
                                aPointSet2.ArrayOfVertexVectors{iCounter}(jCounter)=[];
                            else
                                jCounter=jCounter+1;
                            end
                        end
                    else
                        aPointSet2.ArrayOfVertexVectors{iCounter}=theArrayOfOtherVertices{iCounter};
                    end
                end
            end
            aParameter.PointSet1=aPointSet1;
            aParameter.PointSet2=aPointSet2;
            
            % Append the parameter to the array of parameters
            obj.ArrayOfParameters{length(obj.ArrayOfParameters)+1}=aParameter;
            
            % Build the appropriate variable
            obj.defineVariable(theParameterName, aParameter.NominalValue, 'LNG', '"Dim. Param."');
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addSymmetricDimensionParameter(obj,theParameterName,...
                theReferencePolygon1,theReferenceVertex1,...
                theReferencePolygon2,theReferenceVertex2,...
                theArrayOfFirstPointSetPolygons, theArrayOfFirstPointSetVertices,...
                theArrayOfSecondPointSetPolygons, theArrayOfSecondPointSetVertices,...
                theDirection,theEquation)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %   addSymmetricDimensionParameter will add a geometry
            %   dimension parameter to the project.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            aParameter=SonnetGeometryParameter();
            
            aParameter.ParameterLabelXCoord=0;
            aParameter.ParameterLabelYCoord=0;
            
            aParameter.Parname=theParameterName;
            aParameter.Partype='SYM';
            aParameter.Scaletype='NSCD';
            
            if nargin==12
                aParameter.Equation=theEquation;
            end
            
            % Get handles to the reference polygons
            if isa(theReferencePolygon1,'SonnetGeometryPolygon')
            else
                [~, theReferencePolygon1]=obj.findPolygonUsingId(theReferencePolygon1);
                if isempty(theReferencePolygon1)
                    error('ReferencePolygon1: Specified polygon was not found.');
                end
            end
            if isa(theReferencePolygon2,'SonnetGeometryPolygon')
            else
                [~, theReferencePolygon2]=obj.findPolygonUsingId(theReferencePolygon2);
                if isempty(theReferencePolygon2)
                    error('ReferencePolygon2: Specified polygon was not found.');
                end
            end
            
            % Assign the values for the reference points
            aParameter.ReferencePolygon1=theReferencePolygon1;
            aParameter.ReferenceVertex1=theReferenceVertex1;
            aParameter.ReferencePolygon2=theReferencePolygon2;
            aParameter.ReferenceVertex2=theReferenceVertex2;
            
            % Store the movement direction
            if strcmpi(theDirection,'X')==1 || strcmpi(theDirection,'XDIR')==1
                aParameter.Direction='XDIR';
            elseif strcmpi(theDirection,'Y')==1 || strcmpi(theDirection,'YDIR')==1
                aParameter.Direction='YDIR';
            else
                error('Improper direction selection')
            end
            
            % Set the values for Point Set One
            aPointSet1=SonnetGeometryParameterPointSet();
            if length(theArrayOfFirstPointSetPolygons)==1  && ~isa(theArrayOfFirstPointSetPolygons,'cell')
                if isa(theArrayOfFirstPointSetPolygons,'SonnetGeometryPolygon')
                    aPointSet1.ArrayOfPolygons{1}=theArrayOfFirstPointSetPolygons;
                else
                    [~, aPointSet1.ArrayOfPolygons{1}]=obj.findPolygonUsingId(theArrayOfFirstPointSetPolygons);
                    if isempty(aPointSet1.ArrayOfPolygons{1})
                        error('Specified polygon was not found.');
                    end
                end
                if isempty(theArrayOfFirstPointSetVertices)
                    % Include all the polygon's vertices
                    aPointSet1.ArrayOfVertexVectors{1}=1:length(aPointSet1.ArrayOfPolygons{1}.XCoordinateValues)-1;
                    jCounter=1;
                    while jCounter<=length(aPointSet1.ArrayOfVertexVectors{1})
                        if aPointSet1.ArrayOfPolygons{1}==theReferencePolygon1 &&...
                                aPointSet1.ArrayOfVertexVectors{1}(jCounter)==theReferenceVertex1
                            aPointSet1.ArrayOfVertexVectors{1}(jCounter)=[];
                        else
                            jCounter=jCounter+1;
                        end
                    end
                else
                    aPointSet1.ArrayOfVertexVectors{1}=theArrayOfFirstPointSetVertices;
                end
            else
                for iCounter=1:length(theArrayOfFirstPointSetPolygons)
                    if isa(theArrayOfFirstPointSetPolygons{iCounter},'SonnetGeometryPolygon')
                        for jCounter=1:length(theArrayOfFirstPointSetPolygons)
                            aPointSet1.ArrayOfPolygons{jCounter}=theArrayOfFirstPointSetPolygons{jCounter};
                        end
                    else
                        [~, aPointSet1.ArrayOfPolygons{iCounter}]=obj.findPolygonUsingId(theArrayOfFirstPointSetPolygons{iCounter});
                        if isempty(aPointSet1.ArrayOfPolygons{iCounter})
                            error('Specified polygon was not found.');
                        end
                    end
                end
                for iCounter=1:length(theArrayOfFirstPointSetPolygons)
                    if isempty(theArrayOfFirstPointSetVertices{iCounter})
                        % Include all the polygon's vertices
                        aPointSet1.ArrayOfVertexVectors{iCounter}=1:length(aPointSet1.ArrayOfPolygons{iCounter}.XCoordinateValues)-1;
                        jCounter=1;
                        while jCounter<=length(aPointSet1.ArrayOfVertexVectors{iCounter})
                            if aPointSet1.ArrayOfPolygons{iCounter}==theReferencePolygon1 &&...
                                    aPointSet1.ArrayOfVertexVectors{iCounter}(jCounter)==theReferenceVertex1
                                aPointSet1.ArrayOfVertexVectors{iCounter}(jCounter)=[];
                            else
                                jCounter=jCounter+1;
                            end
                        end
                    else
                        aPointSet1.ArrayOfVertexVectors{iCounter}=theArrayOfFirstPointSetVertices{iCounter};
                    end
                end
            end
            aParameter.PointSet1=aPointSet1;
            
            % Set the values for Point Set Two
            aPointSet2=SonnetGeometryParameterPointSet();
            if length(theArrayOfSecondPointSetPolygons)==1 && ~isa(theArrayOfSecondPointSetPolygons,'cell')
                if isa(theArrayOfSecondPointSetPolygons,'SonnetGeometryPolygon')
                    aPointSet2.ArrayOfPolygons{1}=theArrayOfSecondPointSetPolygons;
                else
                    [~, aPointSet2.ArrayOfPolygons{1}]=obj.findPolygonUsingId(theArrayOfSecondPointSetPolygons);
                    if isempty(aPointSet2.ArrayOfPolygons{1})
                        error('Specified polygon was not found.');
                    end
                end
                if isempty(theArrayOfFirstPointSetVertices)
                    % Include all the polygon's vertices
                    aPointSet2.ArrayOfVertexVectors{1}=1:length(aPointSet2.ArrayOfPolygons{1}.XCoordinateValues)-1;
                    jCounter=1;
                    while jCounter<=length(aPointSet2.ArrayOfVertexVectors{1})
                        if aPointSet2.ArrayOfPolygons{1}==theReferencePolygon2 &&...
                                aPointSet2.ArrayOfVertexVectors{1}(jCounter)==theReferenceVertex2
                            aPointSet2.ArrayOfVertexVectors{1}(jCounter)=[];
                        else
                            jCounter=jCounter+1;
                        end
                    end
                else
                    aPointSet2.ArrayOfVertexVectors{1}=theArrayOfSecondPointSetVertices;
                end
            else
                for iCounter=1:length(theArrayOfSecondPointSetPolygons)
                    if isa(theArrayOfSecondPointSetPolygons{iCounter},'SonnetGeometryPolygon')
                        for jCounter=1:length(theArrayOfSecondPointSetPolygons)
                            aPointSet2.ArrayOfPolygons{jCounter}=theArrayOfSecondPointSetPolygons{jCounter};
                        end
                    else
                        [~, aPointSet2.ArrayOfPolygons{iCounter}]=obj.findPolygonUsingId(theArrayOfSecondPointSetPolygons{iCounter});
                        if isempty(aPointSet2.ArrayOfPolygons{iCounter})
                            error('Specified polygon was not found.');
                        end
                    end
                end
                for iCounter=1:length(theArrayOfSecondPointSetPolygons)
                    if isempty(theArrayOfSecondPointSetVertices{iCounter})
                        % Include all the polygon's vertices
                        aPointSet2.ArrayOfVertexVectors{iCounter}=1:length(aPointSet2.ArrayOfPolygons{iCounter}.XCoordinateValues)-1;
                        jCounter=1;
                        while jCounter<=length(aPointSet2.ArrayOfVertexVectors{iCounter})
                            if aPointSet2.ArrayOfPolygons{iCounter}==theReferencePolygon2 &&...
                                    aPointSet2.ArrayOfVertexVectors{iCounter}(jCounter)==theReferenceVertex2
                                aPointSet2.ArrayOfVertexVectors{iCounter}(jCounter)=[];
                            else
                                jCounter=jCounter+1;
                            end
                        end
                    else
                        aPointSet2.ArrayOfVertexVectors{iCounter}=theArrayOfSecondPointSetVertices{iCounter};
                    end
                end
            end
            aParameter.PointSet2=aPointSet2;
            
            % Append the parameter to the array of parameters
            obj.ArrayOfParameters{length(obj.ArrayOfParameters)+1}=aParameter;
            
            % Build the appropriate variable
            obj.defineVariable(theParameterName, aParameter.NominalValue, 'LNG', '"Dim. Param."');
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addParallelSubsection(obj,theSide,theDistance)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will add another Parallel Subsection
            % to the array of Parallel Subsections. It requires
            % Two arguments:
            %     1) the Side     -  The side the subsection is on ('LEFT', 'RIGHT', 'TOP', 'BOTTOM')
            %     2) the Distance -  distance from the box wall to which the parallel subsections extend
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Make the side all upper case
            theSide=upper(theSide);
            
            if isempty(obj.ParallelSubsections)                                     % If we dont have a Parallel Subsections entry yet then make a new object for one
                obj.ParallelSubsections=SonnetGeometryParallelSubsection();
                obj.ParallelSubsections.addNewSideFromValue(theSide,theDistance);   % Tells the object to add a new Parallel subsection as defined from the arguments
            else                                                                    % If we already have an object for our ParallelSubsections entries then just add this one to the object using its add function
                obj.ParallelSubsections.addNewSideFromValue(theSide,theDistance);   % Tells the object to add a new Parallel subsection as defined from the arguments
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addReferencePlane(obj,theSide,theTypeOfReferencePlane,theLengthOrPolygon,theVertex)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will add another reference plane
            % to the array of reference planes. It requires
            % three arguments:
            %     1) The Side    -  the side the plane is on ('LEFT', 'RIGHT', 'Top', 'BOTTOM')
            %     2) The Type    -  type of reference plane (FIX, LINK, NONE)
            %     3) The length  -  length of the reference plane (If type is FIX or NONE)
            %          or
            %     3) The polygon -  the polygon to which the reference plane is linked
            %                       either the polygon object or the polygon's debugId.
            %     4) If it is a polygon the vertex to which the reference
            %         plane will be connected to will need to be specified
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Make the strings upper case
            theSide=upper(theSide);
            theTypeOfReferencePlane=upper(theTypeOfReferencePlane);
            
            if nargin < 5 % If we didnt get a vertex then assign one as -1.
                theVertex=-1;
            end
            
            % If they pass us an index or the polygon in a LINK then we want to grab the ID
            if strcmp(theTypeOfReferencePlane,'LINK')==1
                
                % if it is a link type and we didnt get a vertex throw an error
                if nargin < 5
                    error('Adding a reference plane of LINK type requires 4 arguments, the last being the vertex number. Please see the help');
                end
                
                % Get a reference to the polygon
                if isa(theLengthOrPolygon,'SonnetGeometryPolygon')
                elseif isa(theLengthOrPolygon,'integer') || isa(theLengthOrPolygon,'double')
                    [~, theLengthOrPolygon]=obj.findPolygonUsingId(theLengthOrPolygon);
                else
                    error('Improper type for polygon.');
                end
            end
            
            
            % Create the Plane
            if ~isempty(theLengthOrPolygon)
                if isempty(obj.ReferencePlanes)
                    obj.ReferencePlanes=SonnetGeometryReferencePlane();
                    obj.ReferencePlanes.addNewSide(theSide,theTypeOfReferencePlane,theLengthOrPolygon,theVertex);
                else
                    obj.ReferencePlanes.addNewSide(theSide,theTypeOfReferencePlane,theLengthOrPolygon,theVertex);
                end
            else
                error('Polygon reference not found.');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addDielectricBrickTypeFromLibrary(obj,theName)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will define a new brick type from
            % an entry in the Sonnet materials library.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            [~, aSonnetInstallDirectoryList]=SonnetPath();
            
            % Find an installed version of Sonnet that has a metal library
            iPathCounter=1;
            while iPathCounter <= length(aSonnetInstallDirectoryList)
                aSonnetPath=strrep(aSonnetInstallDirectoryList{iPathCounter},'"','');
                if exist([aSonnetPath '\data\libraries\die-library.txt'],'file')
                    break
                end
                iPathCounter=iPathCounter+1;
            end
            if iPathCounter > length(aSonnetInstallDirectoryList)
                error('Could not locate a metal type library file in Sonnet path');
            end
            
            aFid=fopen([aSonnetPath '\data\libraries\die-library.txt']);
            aTempString=fgetl(aFid);
            
            while feof(aFid)~=1
                
                if ~isempty(strfind(aTempString,theName))
                    % Construct an empty layer
                    aType=SonnetGeometryIsotropic();
                    
                    aTempString=strrep(aTempString,'BRI','');
                    aTempString=strrep(aTempString,'"','');
                    aTempString=strrep(aTempString,theName,'');
                    
                    % Import the properties of the layer material
                    aResults=sscanf(aTempString,'%f');
                    aType.Name=theName;
                    aType.RelativeDielectricConstant=aResults(1);
                    aType.LossTangent=aResults(2);
                    aType.BulkConductivity=aResults(3);
                    
                    % Append the layer to the array
                    obj.ArrayOfDielectricMaterials{length(obj.ArrayOfDielectricMaterials)+1}=aType;
                    
                    fclose(aFid);
                    return;
                    
                end
                aTempString=fgetl(aFid);
            end
            error('Invalid Dielectric Material Specified');
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addIsotropicDielectric(obj,theName,theRelativeDielectricConstant,theLossTangent,theBulkConductivity)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will add an Isotropic Dielectric
            % to the array of Isotropic Dielectrics. It requires
            % four arguments:
            %     1) the name of the dielectric
            %     2) relative dielectric constant
            %     3) loss tangent
            %     4) bulk conductivity
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Construct an empty dielectric
            aType=SonnetGeometryIsotropic();
            
            % determine an appropriate pattern ID
            aIdNumber=1;
            for iCounter=1:length(obj.ArrayOfDielectricMaterials)
                if aIdNumber==obj.ArrayOfDielectricMaterials{iCounter}.PatternId
                    aIdNumber=aIdNumber+1;
                    iCounter=1;
                end
            end
            
            % Modify the values for the dielectric
            aType.Name                       =   theName;
            aType.LossTangent                =   theLossTangent;
            aType.BulkConductivity           =   theBulkConductivity;
            aType.RelativeDielectricConstant =   theRelativeDielectricConstant;
            aType.PatternId                  =   aIdNumber;
            
            % Add the brick type to the array
            obj.ArrayOfDielectricMaterials{length(obj.ArrayOfDielectricMaterials)+1}=aType;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addAnisotropicDielectric(obj,theName,theXRelativeDielectricConstant,theXLossTangent,...
                theXBulkConductivity,theYRelativeDielectricConstant,theYLossTangent,theYBulkConductivity,...
                theZRelativeDielectricConstant,theZLossTangent,theZBulkConductivity)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will add an Anisotropic Dielectric
            % to the array of Anisotropic Dielectrics. It requires
            % the following arguments:
            %     1)  The name of the dielectric
            %     2)  Relative dielectric constant in the X direction
            %     3)  Loss tangent in the X direction
            %     4)  Bulk conductivity in the X direction
            %     5)  Relative dielectric constant in the Y direction
            %     6)  Loss tangent in the Y direction
            %     7)  Bulk conductivity in the Y direction
            %     8)  Relative dielectric constant in the Z direction
            %     9)  Loss tangent in the Z direction
            %     10) Bulk conductivity in the Z direction
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Construct an empty dielectric
            aType=SonnetGeometryAnisotropic();
            
            % determine an appropriate pattern ID
            aIdNumber=1;
            for iCounter=1:length(obj.ArrayOfDielectricMaterials)
                if aIdNumber==obj.ArrayOfDielectricMaterials{iCounter}.PatternId
                    aIdNumber=aIdNumber+1;
                    iCounter=1;
                end
            end
            
            % Modify the values for the dielectric
            aType.Name                        =   theName;
            aType.XRelativeDielectricConstant =   theXRelativeDielectricConstant;
            aType.XLossTangent                =   theXLossTangent;
            aType.XBulkConductivity           =   theXBulkConductivity;
            aType.YRelativeDielectricConstant =   theYRelativeDielectricConstant;
            aType.YLossTangent                =   theYLossTangent;
            aType.YBulkConductivity           =   theYBulkConductivity;
            aType.ZRelativeDielectricConstant =   theZRelativeDielectricConstant;
            aType.ZLossTangent                =   theZLossTangent;
            aType.ZBulkConductivity           =   theZBulkConductivity;
            aType.PatternId                   =   aIdNumber;
            
            % Add the brick type to the array
            obj.ArrayOfDielectricMaterials{length(obj.ArrayOfDielectricMaterials)+1}=aType;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addVariable(obj,theVariableName,theUnitType,theValue,theDescription)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will add an variable
            % to the array of variables. It requires
            % the following arguments:
            %     1) The name of the variable
            %     2) Unit Type which is one of the strings represented
            %         in the reference table below:
            %
            %        Unit Type     Type of Units
            %           LNG     -    Length
            %           RES     -    Resistance
            %           CAP     -    Capacitance
            %           IND     -    Inductance
            %           FREQ    -    Frequency
            %           OPS     -    Ohms/sq
            %           SPM     -    Siemens/meter
            %           PHPM    -    picoHenries/meter
            %           RRF     -    Rrf
            %           NONE    -    Undefined
            %
            %     3) Value of the unit specified
            %     4) Description of the variable
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Capitalize the unit type
            theUnitType=upper(theUnitType);
            
            % Construct an empty variable
            aVariable=SonnetGeometryVariable();
            
            % Modify the values for the variable
            aVariable.VariableName  =   theVariableName;
            aVariable.UnitType      =   theUnitType;
            aVariable.Value         =   theValue;
            aVariable.Description   =   theDescription;
            
            % Append the variable to the array
            obj.ArrayOfVariables{length(obj.ArrayOfVariables)+1}=aVariable;
            
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addEdgeVia(obj,thePolygon,theVertex,theToLevel)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will add an Electric Edge Via
            % to the array of Electric Edge Vias. It requires
            % three arguments:
            %     1) The polygon the via is connected to (Either a polygon
            %         object or the polygon's ID.
            %     2) The index number of the polygon vertex. The via is
            %         placed on the polygon edge specified by this vertex
            %         to the next vertex. For example, if vertex 3 is
            %         specified, the via extends from vertex 3 to vertex
            %         4 on the polygon.
            %     3) The level the via is connected to
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Determine the validity of the polygon supplied, if it is an
            % integer than use it as an index in the array of polygons.
            if isa(thePolygon,'SonnetGeometryPolygon') % If we were supplied a polygon then use that polygon
            else                                     % If we were supplied an ID for a polygon then find the polygon from the ID
                [aJunkField thePolygon]=obj.findPolygonUsingId(thePolygon); %#ok<ASGLU>
            end
            
            aEdgeVia=SonnetGeometryEdgeVia();
            aEdgeVia.Polygon=thePolygon;
            aEdgeVia.Vertex=theVertex;
            aEdgeVia.Level=theToLevel;
            
            obj.ArrayOfEdgeVias{length(obj.ArrayOfEdgeVias)+1}=aEdgeVia;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addViaPolygon(obj,theProjectVersion,theToLevel,theMetalizationLevelIndex,theMetalType,theFillType,theXMinimumSubsectionSize,theYMinimumSubsectionSize,theXMaximumSubsectionSize,theYMaximumSubsectionSize,theMaximumLengthForTheConformalMeshSubsection,theEdgeMesh,theXCoordinateValues,theYCoordinateValues)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will add an Via Polygon
            % to the array of Polygons. It requires
            % three arguments:
            %     1)  The level the VIA attaches to.
            %     2)  Metalization Level Index (The level the polygon is on)
            %     2)  The index for the metal type in the metals array or
            %           the name of the metal. Index 0 is lossless.
            %     4)  A string to identify the fill type used for the polygon.
            %           N indicates staircase fill, T indicates diagonal
            %           fill and V indicates conformal mesh. Note that filltype
            %           only applies to metal
            %           polygons; this field is ignored for dielectric brick polygons
            %     5)  Minimum subsection size in X direction
            %     6)  Minimum subsection size in Y direction
            %     7)  Maximum subsection size in X direction
            %     8)  Maximum subsection size in Y direction
            %     9)  The Maximum Length For The Conformal Mesh Subsection
            %     10)  Edge mesh setting. Y indicates edge meshing is on for this
            %           polygon. N indicates edge meshing is off.
            %     11) A matrix for the X coordinate values
            %     12) A matrix for the Y coordinate values
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Construct an empty polygon
            aPolygon=SonnetGeometryPolygon();
            
            % Generate a unique debugId for the new polygon
            aDebugId=obj.generateUniqueId();
            
            % Convert the coordinates from a matrix to a cell array
            if ~isa(theXCoordinateValues,'cell')
                for iCounter=1:length(theXCoordinateValues)
                    anArrayOfXCoordinateValues{iCounter}=theXCoordinateValues(iCounter);
                end
            else
                anArrayOfXCoordinateValues=theXCoordinateValues;
            end
            if ~isa(theYCoordinateValues,'cell')
                for iCounter=1:length(theYCoordinateValues)
                    anArrayOfYCoordinateValues{iCounter}=theYCoordinateValues(iCounter);
                end
            else
                anArrayOfYCoordinateValues=theYCoordinateValues;
            end
            
            % Find the appropriate metal type
            if isa(theMetalType,'char')
                % We recieved the name of the metal
                if strcmpi(theMetalType,'Lossless')==1
                    theMetalType=-1;
                else
                    % Search for a metal type with a matching name
                    % for version 12 projects use the first metal type
                    % of the desired name. For version 13 projects use
                    % a metal definition of type
                    if theProjectVersion >= 13
                        wasFound=false;
                        for iCounter=1:length(obj.ArrayOfMetalTypes)
                            if strcmpi(obj.ArrayOfMetalTypes{iCounter}.Type,'SFC')==1 || ...
                                    strcmpi(obj.ArrayOfMetalTypes{iCounter}.Type,'ARR')==1 || ...
                                    strcmpi(obj.ArrayOfMetalTypes{iCounter}.Type,'VOL')==1 || ...
                                    strcmpi(obj.ArrayOfMetalTypes{iCounter}.Type,'Surface')==1 || ...
                                    strcmpi(obj.ArrayOfMetalTypes{iCounter}.Type,'Array')==1 || ...
                                    strcmpi(obj.ArrayOfMetalTypes{iCounter}.Type,'Volume')==1
                                if strcmpi(obj.ArrayOfMetalTypes{iCounter}.Name,theMetalType)==1
                                    theMetalType=iCounter-1;
                                    wasFound=true;
                                    break;
                                end
                            end
                        end
                        
                        if ~wasFound
                            % If we get to here then we didnt find a match for
                            % the name of the metal type. Throw an error.
                            error('No metal type matches specified name');
                        end
                    else
                        wasFound=false;
                        for iCounter=1:length(obj.ArrayOfMetalTypes)
                            if strcmpi(obj.ArrayOfMetalTypes{iCounter}.Name,theMetalType)==1
                                theMetalType=iCounter-1;
                                wasFound=true;
                                break;
                            end
                        end
                        
                        if ~wasFound
                            % If we get to here then we didnt find a match for
                            % the name of the metal type. Throw an error.
                            error('No metal type matches specified name');
                        end
                    end
                end
                
            else
                % We recieved the desired metal type.
                % Make sure the metal type isnt over
                % the length of the array
                if theMetalType > length(obj.ArrayOfMetalTypes)
                    error('Invalid metal index given')
                end
                
                % Make sure that if this is a Sonnet 13 project that
                % selected metal type is not a via metal type.
                if theMetalType <= 0
                    theMetalType=-1;
                elseif strcmpi(obj.ArrayOfMetalTypes{theMetalType}.Type,'SFC')==0 && ...
                        strcmpi(obj.ArrayOfMetalTypes{theMetalType}.Type,'ARR')==0 && ...
                        strcmpi(obj.ArrayOfMetalTypes{theMetalType}.Type,'VOL')==0 && ...
                        strcmpi(obj.ArrayOfMetalTypes{theMetalType}.Type,'Surface')==0 && ...
                        strcmpi(obj.ArrayOfMetalTypes{theMetalType}.Type,'Array')==0 && ...
                        strcmpi(obj.ArrayOfMetalTypes{theMetalType}.Type,'Volume')==0 && ...
                        theProjectVersion >= 13
                    error('Trying to create a via polygon using planar metal');
                else
                    theMetalType=theMetalType-1;
                end
            end
            
            % Modify the values for the polygon
            aPolygon.MetalizationLevelIndex  =  theMetalizationLevelIndex;
            aPolygon.MetalType               =  theMetalType;
            aPolygon.FillType                =  theFillType;
            aPolygon.XMinimumSubsectionSize  =  theXMinimumSubsectionSize;
            aPolygon.YMinimumSubsectionSize  =  theYMinimumSubsectionSize;
            aPolygon.XMaximumSubsectionSize  =  theXMaximumSubsectionSize;
            aPolygon.YMaximumSubsectionSize  =  theYMaximumSubsectionSize;
            aPolygon.MaximumLengthForTheConformalMeshSubsection=theMaximumLengthForTheConformalMeshSubsection;
            aPolygon.EdgeMesh                =  theEdgeMesh;
            aPolygon.DebugId                 =  aDebugId;
            aPolygon.Type                    =  'VIA POLYGON';
            aPolygon.LevelTheViaIsConnectedTo=theToLevel;
            aPolygon.XCoordinateValues       =  anArrayOfXCoordinateValues;
            aPolygon.YCoordinateValues       =  anArrayOfYCoordinateValues;
            
            % If this is a version 13 project then assign
            % values for some additional variables.
            if theProjectVersion >= 13
                aPolygon.Meshing             =  'RING';
                aPolygon.isCapped            =  false;
            end
            
            % We need to be sure that the last point is the same as the first point
            % to do this we will add the last point to the list of points and then
            % remove any duplicate points.
            aNumberOfCoordinates=length(aPolygon.XCoordinateValues)+1;
            aPolygon.XCoordinateValues{aNumberOfCoordinates}=aPolygon.XCoordinateValues{1};
            aPolygon.YCoordinateValues{aNumberOfCoordinates}=aPolygon.YCoordinateValues{1};
            aPolygon.removeDuplicatePoints();
            
            % Put the polygon in the array
            obj.ArrayOfPolygons{length(obj.ArrayOfPolygons)+1}=aPolygon;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addCoCalibratedGroup(obj,theGroupName,theGroundReference,theTerminalWidthType)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will add an CoCalibration Group
            % to the array of CoCalibration Groups. It requires
            % four arguments:
            %     1) The name of the group
            %     2) The Ground Reference
            %     3) The Terminal Width
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Capitialize the strings
            theGroupName=upper(theGroupName);
            theGroupName=strrep(theGroupName,'"','');
            theGroundReference=upper(theGroundReference);
            theTerminalWidthType=upper(theTerminalWidthType);
            
            % Check if the group is already in the list
            % if it is then dont make a new entry
            % otherwise make a new entry
            for iCounter=1:length(obj.ArrayOfCoCalibratedGroups)
                aTempName=strrep(obj.ArrayOfCoCalibratedGroups{iCounter}.GroupName,'"','');
                if strcmp(theGroupName,aTempName)==1
                    return;
                end
            end
            
            % Construct an empty CoCalibrated Group and put it in the array
            aGroup=SonnetGeometryCoCalibratedGroup();
            
            % Find a valid group ID Number
            aGroupId=1;
            for iCounter=1:length(obj.ArrayOfCoCalibratedGroups)
                if aGroupId==obj.ArrayOfCoCalibratedGroups{iCounter}.GroupId
                    aGroupId=aGroupId+1;
                    iCounter=1;  % Reset the counter to start at the beginning of the loop again.
                end
            end
            
            % Modify the values for the CoCalibrated Group
            aGroup.GroupName         =  theGroupName;
            aGroup.GroupId           =  aGroupId;
            aGroup.GroundReference   =  theGroundReference;
            aGroup.TerminalWidthType =  theTerminalWidthType;
            
            % Append the group to the array
            obj.ArrayOfCoCalibratedGroups{length(obj.ArrayOfCoCalibratedGroups)+1}=aGroup;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addReferencePlaneToPortGroup(obj,theGroupName,theSide,theTypeOfReferencePlane,theLengthOrPolygon,theVertex)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %   This function will add a reference plane
            %   to a cocalibrated port group.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Check if the group is already in the list
            % if it is not then throw an error
            theGroupName=upper(theGroupName);
            theGroupName=strrep(theGroupName,'"','');
            isValid=false;
            for iCounter=1:length(obj.ArrayOfCoCalibratedGroups)
                aTempName=strrep(obj.ArrayOfCoCalibratedGroups{iCounter}.GroupName,'"','');
                if strcmp(theGroupName,aTempName)==1
                    isValid=true;
                    % Add the reference plane to the polygon
                    if nargin == 6
                        obj.ArrayOfCoCalibratedGroups{iCounter}.addReferencePlane(theSide,theTypeOfReferencePlane,theLengthOrPolygon,theVertex);
                    else
                        obj.ArrayOfCoCalibratedGroups{iCounter}.addReferencePlane(theSide,theTypeOfReferencePlane,theLengthOrPolygon);
                    end
                end
            end
            
            if ~isValid
                error('Invalid cocalibrated group name');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addMetalPolygon(obj,theMetalizationLevelIndex,theMetalType,theFillType,theXMinimumSubsectionSize,theYMinimumSubsectionSize,theXMaximumSubsectionSize,theYMaximumSubsectionSize,theMaximumLengthForTheConformalMeshSubsection,theEdgeMesh,theXCoordinateValues,theYCoordinateValues)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will add an polygon Group
            % to the array of polygon Groups. It requires
            % four arguments:
            %     1)  Metalization Level Index ( The level the polygon is on)
            %     2)  The index for the metal type in the metals array or
            %           the name of the metal. Index 0 is lossless.
            %     3)  A string to identify the fill type used for the polygon.
            %           N indicates staircase fill, T indicates diagonal
            %           fill and V indicates conformal mesh. Note that filltype
            %           only applies to metal
            %           polygons; this field is ignored for dielectric brick polygons
            %     4)  Minimum subsection size in X direction
            %     5)  Minimum subsection size in Y direction
            %     6)  Maximum subsection size in X direction
            %     7)  Maximum subsection size in Y direction
            %     8)  The Maximum Length For The Conformal Mesh Subsection
            %     9)  Edge mesh setting. Y indicates edge meshing is on for this
            %           polygon. N indicates edge meshing is off.
            %     10) A column vector for the X coordinate values
            %     11) A column vector for the Y coordinate values
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Construct an empty polygon
            aPolygon=SonnetGeometryPolygon();
            
            % Generate a unique debugId for the new polygon
            aDebugId=obj.generateUniqueId();
            
            % Convert the coordinates from a matrix to a cell array
            if ~isa(theXCoordinateValues,'cell')
                for iCounter=1:length(theXCoordinateValues)
                    anArrayOfXCoordinateValues{iCounter}=theXCoordinateValues(iCounter);
                end
            else
                anArrayOfXCoordinateValues=theXCoordinateValues;
            end
            if ~isa(theYCoordinateValues,'cell')
                for iCounter=1:length(theYCoordinateValues)
                    anArrayOfYCoordinateValues{iCounter}=theYCoordinateValues(iCounter);
                end
            else
                anArrayOfYCoordinateValues=theYCoordinateValues;
            end
            
            % Find the appropriate metal type
            if isa(theMetalType,'char')
                % We recieved the name of the metal
                if strcmpi(theMetalType,'Lossless')==1
                    theMetalType=-1;
                else
                    wasFound=false;
                    for iCounter=1:length(obj.ArrayOfMetalTypes)
                        if strcmpi(obj.ArrayOfMetalTypes{iCounter}.Type,'SFC')==0 && ...
                                strcmpi(obj.ArrayOfMetalTypes{iCounter}.Type,'ARR')==0 && ...
                                strcmpi(obj.ArrayOfMetalTypes{iCounter}.Type,'VOL')==0 && ...
                                strcmpi(obj.ArrayOfMetalTypes{iCounter}.Type,'Surface')==0 && ...
                                strcmpi(obj.ArrayOfMetalTypes{iCounter}.Type,'Array')==0 && ...
                                strcmpi(obj.ArrayOfMetalTypes{iCounter}.Type,'Volume')==0
                            if strcmpi(obj.ArrayOfMetalTypes{iCounter}.Name,theMetalType)==1
                                theMetalType=iCounter-1;
                                wasFound=true;
                                break;
                            end
                        end
                    end
                    
                    if ~wasFound
                        % If we get to here then we didnt find a match for
                        % the name of the metal type. Throw an error.
                        error('No metal type matches specified name');
                    end
                end
            else
                % Make sure that if this is a Sonnet 13 project that
                % selected metal type is not a via metal type.
                if theMetalType <= 0
                    theMetalType=-1;
                elseif strcmpi(obj.ArrayOfMetalTypes{theMetalType}.Type,'SFC')==1 || ...
                        strcmpi(obj.ArrayOfMetalTypes{theMetalType}.Type,'ARR')==1 || ...
                        strcmpi(obj.ArrayOfMetalTypes{theMetalType}.Type,'VOL')==1 || ...
                        strcmpi(obj.ArrayOfMetalTypes{theMetalType}.Type,'Surface')==1 || ...
                        strcmpi(obj.ArrayOfMetalTypes{theMetalType}.Type,'Array')==1 || ...
                        strcmpi(obj.ArrayOfMetalTypes{theMetalType}.Type,'Volume')==1
                    error('Trying to create a metal polygon using via metal');
                else
                    theMetalType=theMetalType-1;
                end
            end
            
            % Modify the values for the polygon
            aPolygon.MetalizationLevelIndex  =   theMetalizationLevelIndex;
            aPolygon.MetalType               =   theMetalType;
            aPolygon.FillType                =   theFillType;
            aPolygon.XMinimumSubsectionSize  =   theXMinimumSubsectionSize;
            aPolygon.YMinimumSubsectionSize  =   theYMinimumSubsectionSize;
            aPolygon.XMaximumSubsectionSize  =   theXMaximumSubsectionSize;
            aPolygon.YMaximumSubsectionSize  =   theYMaximumSubsectionSize;
            aPolygon.EdgeMesh                =   theEdgeMesh;
            aPolygon.XCoordinateValues       =   anArrayOfXCoordinateValues;
            aPolygon.YCoordinateValues       =   anArrayOfYCoordinateValues;
            aPolygon.DebugId                 =   aDebugId;
            aPolygon.MaximumLengthForTheConformalMeshSubsection=theMaximumLengthForTheConformalMeshSubsection;
            
            % we need to be sure that the last point is the same as the first point
            % to do this we will add the last point to the list of points and then
            % remove any duplicate points.
            aNumberOfCoordinates=length(aPolygon.XCoordinateValues)+1;
            aPolygon.XCoordinateValues{aNumberOfCoordinates}=aPolygon.XCoordinateValues{1};
            aPolygon.YCoordinateValues{aNumberOfCoordinates}=aPolygon.YCoordinateValues{1};
            aPolygon.removeDuplicatePoints();
            
            % Put the polygon in the array
            obj.ArrayOfPolygons{length(obj.ArrayOfPolygons)+1}=aPolygon;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addDielectricBrick(obj,theMetalizationLevelIndex,theMetalType,theXMinimumSubsectionSize,theYMinimumSubsectionSize,theXMaximumSubsectionSize,theYMaximumSubsectionSize,theMaximumLengthForTheConformalMeshSubsection,theEdgeMesh,theXCoordinateValues,theYCoordinateValues)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will add an polygon Group
            % to the array of polygon Groups. It requires
            % four arguments:
            %     1)  Metalization Level Index ( The level the polygon is on)
            %     2)  The index for the dielectric type to use.
            %           the value for Air is zero. User defined indexes
            %           count up from one.
            %     4)  Minimum subsection size in X direction
            %     5)  Minimum subsection size in Y direction
            %     6)  Maximum subsection size in X direction
            %     7)  Maximum subsection size in Y direction
            %     8)  The Maximum Length For The Conformal Mesh Subsection
            %     9)  Edge mesh setting. Y indicates edge meshing is on for this
            %           polygon. N indicates edge meshing is off.
            %     10) A matrix for the X coordinate values
            %     11) A matrix for the Y coordinate values
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Construct an empty polygon
            aPolygon=SonnetGeometryPolygon();
            
            % Generate a unique debugId for the new polygon
            aDebugId=obj.generateUniqueId();
            
            % Convert the coordinates from a matrix to a cell array
            if ~isa(theXCoordinateValues,'cell')
                for iCounter=1:length(theXCoordinateValues)
                    anArrayOfXCoordinateValues{iCounter}=theXCoordinateValues(iCounter);
                end
            else
                anArrayOfXCoordinateValues=theXCoordinateValues;
            end
            if ~isa(theYCoordinateValues,'cell')
                for iCounter=1:length(theYCoordinateValues)
                    anArrayOfYCoordinateValues{iCounter}=theYCoordinateValues(iCounter);
                end
            else
                anArrayOfYCoordinateValues=theYCoordinateValues;
            end
            
            % Find the appropriate brick type
            if isa(theMetalType,'char')
                % We recieved the name of the material
                if strcmpi(theMetalType,'Air')==1
                    theMetalType=0;
                else
                    % Search for a brick type with a matching name
                    wasFound=false;
                    for iCounter=1:length(obj.ArrayOfDielectricMaterials)
                        if strcmpi(obj.ArrayOfDielectricMaterials{iCounter}.Name,theMetalType)==1
                            theMetalType=iCounter;
                            wasFound=true;
                            break;
                        end
                    end
                    
                    if ~wasFound
                        % If we get to here then we didnt find a match for
                        % the name of the metal type. Throw an error.
                        error('No brick material matches specified name');
                    end
                end
                
            else
                % We recieved the desired metal type.
                % Make sure the metal type isnt over
                % the length of the array
                if theMetalType > length(obj.ArrayOfDielectricMaterials) || theMetalType<0
                    error('Invalid brick type index given')
                end
            end
            
            % Modify the values for the polygon
            aPolygon.MetalizationLevelIndex  =   theMetalizationLevelIndex;
            aPolygon.MetalType               =   theMetalType;
            aPolygon.FillType                =   'N';   % In bricks this value is ignored
            aPolygon.XMinimumSubsectionSize  =   theXMinimumSubsectionSize;
            aPolygon.YMinimumSubsectionSize  =   theYMinimumSubsectionSize;
            aPolygon.XMaximumSubsectionSize  =   theXMaximumSubsectionSize;
            aPolygon.YMaximumSubsectionSize  =   theYMaximumSubsectionSize;
            aPolygon.EdgeMesh                =   theEdgeMesh;
            aPolygon.XCoordinateValues       =   anArrayOfXCoordinateValues;
            aPolygon.YCoordinateValues       =   anArrayOfYCoordinateValues;
            aPolygon.DebugId                 =   aDebugId;
            aPolygon.Type                    =   'BRI POLY';
            aPolygon.MaximumLengthForTheConformalMeshSubsection=theMaximumLengthForTheConformalMeshSubsection;
            
            % we need to be sure that the last point is the same as the first point
            % to do this we will add the last point to the list of points and then
            % remove any duplicate points.
            aNumberOfCoordinates=length(aPolygon.XCoordinateValues)+1;
            aPolygon.XCoordinateValues{aNumberOfCoordinates}=aPolygon.XCoordinateValues{1};
            aPolygon.YCoordinateValues{aNumberOfCoordinates}=aPolygon.YCoordinateValues{1};
            aPolygon.removeDuplicatePoints();
            
            % Put the polygon in the array
            obj.ArrayOfPolygons{length(obj.ArrayOfPolygons)+1}=aPolygon;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aPort=addPort(obj,theType,theArgument1,theArgument2,theArgument3,theArgument4,theArgument5,theArgument6,theArgument7,theArgument8,theArgument9)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This Method will add another port
            %   to the project. It requires a type as
            %   the first argument which should
            %   be one of the following:
            %
            %       STD   -   Standard Port
            %       AGND  -   Auto Grounded Port
            %       CUP   -   Co-Calibrated Port
            %
            % Then you will need to supply the necessary
            %   arguments for each as follows:
            %
            %  STD-Standard Port
            %     1) The Polygon the port is attached to.
            %           This can be replaced by the polygon's
            %           debug ID value.
            %     2) The Vertex the polygon is attached to
            %     3) The Resistance for the port
            %     4) The Reactance for the port
            %     5) The Inductance for the port
            %     6) The capacitance for the port
            %     7) The Port Number (Optional)
            %
            % AGND-Auto Grounded Port
            %     1) The Polygon the port is attached to.
            %           This can be replaced by the polygon's
            %           debug ID value.
            %     2)  The Vertex the polygon is attached to
            %     3)  The Resistance for the port
            %     4)  The Reactance for the port
            %     5)  The Inductance for the port
            %     6)  The capacitance for the port
            %     7)  A character string which identifies a
            %          reference plane for the autogrounded port.
            %          this value is FIX for a reference
            %          plane and NONE for a calibration length.
            %     8)  A floating point number which provides the
            %          length of the reference plane when the type
            %          is FIX and provides the calibration length
            %          when the type is NONE.
            %     9) The Port Number(Optional)
            %
            %  CUP-CoCalibrated Port
            %     1) The Polygon the port is attached to.
            %           This can be replaced by the polygon's
            %           debug ID value.
            %     2) The Name of the group it belongs to
            %     3) The Vertex the polygon is attached to
            %     4) The Resistance for the port
            %     5) The Reactance for the port
            %     6) The Inductance for the port
            %     7) The capacitance for the port
            %     8) The Port Number (Optional)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % make the type uppercase
            theType=upper(theType);
            
            switch theType
                case 'STD'      % Standard Port
                    if nargin == 8
                        aPort=obj.addPortStandard(theArgument1,theArgument2,theArgument3,theArgument4,theArgument5,theArgument6);
                    elseif nargin == 9
                        aPort=obj.addPortStandard(theArgument1,theArgument2,theArgument3,theArgument4,theArgument5,theArgument6,theArgument7);
                    else
                        error('Invalid number of arguments');
                    end
                case 'AGND'     % Auto Grounded Port
                    if nargin == 10
                        aPort=obj.addPortAutoGrounded(theArgument1,theArgument2,theArgument3,theArgument4,theArgument5,theArgument6,theArgument7,theArgument8);
                    elseif nargin ==11
                        aPort=obj.addPortAutoGrounded(theArgument1,theArgument2,theArgument3,theArgument4,theArgument5,theArgument6,theArgument7,theArgument8,theArgument9);
                    else
                        error('Invalid number of arguments');
                    end
                case 'CUP'      % CoCalibrated Port
                    if nargin == 9
                        aPort=obj.addPortCocalibrated(theArgument1,theArgument2,theArgument3,theArgument4,theArgument5,theArgument6,theArgument7);
                    elseif nargin == 10
                        aPort=obj.addPortCocalibrated(theArgument1,theArgument2,theArgument3,theArgument4,theArgument5,theArgument6,theArgument7,theArgument8);
                    else
                        error('Invalid number of arguments');
                    end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aPort=addPortToPolygon(obj,thePolygon,theVertex)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This Method will add a standard port
            %   to the project.
            %
            %  Parameters
            %     1) The Polygon the port is attached to
            %     2) The Vertex the polygon is attached to
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if nargin == 3
                
                if (theVertex == 0)
                    error('Value must be greater than zero. The first side is side 1.');
                end
                
                % Construct an empty port
                aPort=SonnetGeometryPort();
                
                % Find a valid Port Number
                aPortNumber=1;
                for iCounter=1:length(obj.ArrayOfPorts)
                    if aPortNumber==obj.ArrayOfPorts{iCounter}.PortNumber
                        aPortNumber=aPortNumber+1;
                        iCounter=1;  % Reset the counter to start at the beginning of the loop again.
                    end
                end
                
                % Determine the validity of the polygon supplied, if the
                % user passed a polygon then extract the ID. If they passed
                % an ID then we already have what we want.
                if isa(thePolygon,'SonnetGeometryPolygon') % If we were supplied a polygon then fin the polygon's ID
                    aPolygon=thePolygon;
                else                                       % If we were supplied an ID for a polygon then use it
                    [~, aPolygon]=obj.findPolygonUsingId(thePolygon);
                    if isempty(aPolygon)
                        error('Polygon is unfound');
                    end
                end
                
                % Modify the values for the port
                aPort.Type          =   'STD';
                aPort.PortNumber    =   aPortNumber;
                aPort.Resistance    =   50;
                aPort.Reactance     =   0;
                aPort.Inductance    =   0;
                aPort.Capacitance   =   0;
                aPort.Polygon       =   aPolygon;
                aPort.Vertex        =   theVertex;
                
                % Append the port to the array
                obj.ArrayOfPorts{length(obj.ArrayOfPorts)+1}=aPort;
                
            else
                disp('Improper number of arguments.  See help.');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aPort=addPortAtLocation(obj,theXCoordinate,theYCoordinate, theLevel)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will add an standard port
            %  to the project by specifying an X and Y coordinate.
            %  When this occurs the function will find the closest
            %  polygon side and place the port there. If the
            %  closest side for the port it more than 5% of the
            %  average of the length and width of the box then
            %  the port will not be placed and an error will be thrown.
            %
            %  Parameters
            %     1) The X coordinate for the port
            %     2) The Y coordinate for the port
            %     3) The level for the port (optional)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if nargin == 3 || nargin == 4
                
                % Find a valid Port Number
                aPortNumber=1;
                for iCounter=1:length(obj.ArrayOfPorts)
                    if aPortNumber==obj.ArrayOfPorts{iCounter}.PortNumber
                        aPortNumber=aPortNumber+1;
                        iCounter=1;  % Reset the counter to start at the beginning of the loop again.
                    end
                end
                
                % find the closest edge to where was clicked to find the connected polygon
                aLengthOfPolygonArray=length(obj.ArrayOfPolygons);
                
                % loop for all the polygons in the array
                aBestDistance=inf;
                
                % make the new port if it is close to the polygon. if it is really far away then
                % dont make a port because the user probably misclicked. we will define
                % far away as more than 5% of the box (width+length)/2
                aDistanceThreshold=(obj.SonnetBox.XWidthOfTheBox+obj.SonnetBox.YWidthOfTheBox)/2*.05;
                
                for iCounter=1:aLengthOfPolygonArray
                    
                    % if the polygon is not on the same level as specified then skip it
                    if nargin == 4 && theLevel ~= obj.ArrayOfPolygons{iCounter}.MetalizationLevelIndex
                        continue;
                    end
                    
                    % if the polygon is dielectric brick then ignore it
                    if strcmpi(obj.ArrayOfPolygons{iCounter}.Type,'BRI POLY')==1
                        continue;
                    end
                    
                    % loop for all the sides in an polygon
                    for jCounter=1:length(obj.ArrayOfPolygons{iCounter}.XCoordinateValues)-1
                        
                        aCoordinate1=[obj.ArrayOfPolygons{iCounter}.XCoordinateValues{jCounter},...
                            obj.ArrayOfPolygons{iCounter}.YCoordinateValues{jCounter}, 0];
                        aCoordinate2=[obj.ArrayOfPolygons{iCounter}.XCoordinateValues{jCounter+1},...
                            obj.ArrayOfPolygons{iCounter}.YCoordinateValues{jCounter+1}, 0];
                        aCenterPointX=mean([aCoordinate1(1) aCoordinate2(1)]);
                        aCenterPointY=mean([aCoordinate1(2) aCoordinate2(2)]);
                        
                        % find the distance from the center point to our new point
                        aDistance = sqrt((aCenterPointX-theXCoordinate)^2+(aCenterPointY-theYCoordinate)^2);
                        
                        % if this distance is closer than the best distance so far
                        % then store it (unless it is more than 5% away)
                        if aDistance < aBestDistance && aDistance <= aDistanceThreshold
                            aBestDistance=aDistance;
                            aBestVertex=jCounter;
                            aBestPolygon=obj.ArrayOfPolygons{iCounter};
                        end
                        
                    end
                    
                end
                
                if aBestDistance < inf
                    
                    if aBestDistance <= aDistanceThreshold
                        
                        % find the coordinates at which to place the port (the center of the vertex)
                        aPortXLocation=(aBestPolygon.XCoordinateValues{aBestVertex}+aBestPolygon.XCoordinateValues{aBestVertex+1})/2;
                        aPortYLocation=(aBestPolygon.YCoordinateValues{aBestVertex}+aBestPolygon.YCoordinateValues{aBestVertex+1})/2;
                        
                        % make the port
                        aPort=obj.addPortStandard(aBestPolygon,aBestVertex,50,0,0,0);
                        
                    else
                        error('Requested port location not near polygon edge.');
                    end
                end
                
                % If we recieved an improper number of arguments
            else
                disp('Improper number of arguments.  See help.');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aPort=addPortStandard(obj,thePolygon,theVertex,theResistance,theReactance,theInductance,theCapacitance,thePortNumber)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will add a standard port
            % to the array of ports. It requires
            % the following arguments:
            %     1) The Polygon the port is attached to
            %     2) The Vertex the polygon is attached to
            %     3) The Resistance for the port
            %     4) The Reactance for the port
            %     5) The Inductance for the port
            %     6) The Capacitance for the port
            %     7) The Port Number (Optional)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Construct an empty port
            aPort=SonnetGeometryPort();
            
            if nargin < 8 % If we havent recieved a port number then generate a fresh one
                
                % Find a valid Port Number
                aPortNumber=1;
                for iCounter=1:length(obj.ArrayOfPorts)
                    if aPortNumber==obj.ArrayOfPorts{iCounter}.PortNumber
                        aPortNumber=aPortNumber+1;
                        iCounter=1;  % Reset the counter to start at the beginning of the loop again.
                    end
                end
                
            else % If a port number was passed then we will use it
                aPortNumber=thePortNumber;
                
            end
            
            % Determine the validity of the polygon supplied, if the
            % user passed a polygon then extract the ID. If they passed
            % an ID then we already have what we want.           
            if isa(thePolygon,'SonnetGeometryPolygon') % If we were supplied a polygon then fin the polygon's ID
                aPolygon=thePolygon;
            else                                       % If we were supplied an ID for a polygon then use it
                [~, aPolygon]=obj.findPolygonUsingId(thePolygon);
                if isempty(aPolygon)
                    error('Polygon is unfound');
                end
            end
            
            % Modify the values for the port
            aPort.Type          =   'STD';
            aPort.PortNumber    =   aPortNumber;
            aPort.Resistance    =   theResistance;
            aPort.Reactance     =   theReactance;
            aPort.Inductance    =   theInductance;
            aPort.Capacitance   =   theCapacitance;
            aPort.Polygon       =   aPolygon;
            aPort.Vertex        =   theVertex;
            
            % Append the port to the array
            obj.ArrayOfPorts{length(obj.ArrayOfPorts)+1}=aPort;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aPort=addPortAutoGrounded(obj,thePolygon,theVertex,theResistance,theReactance,theInductance,theCapacitance,theTypeOfReferencePlane,theReferencePlaneOrCalibrationLength,thePortNumber)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will add am autogrounded port
            % to the array of ports. It requires
            % the following arguments:
            %     1)  The Polygon the port is attached to
            %     2)  The Vertex the polygon is attached to
            %     3)  The Resistance for the port
            %     4)  The Reactance for the port
            %     5)  The Inductance for the port
            %     6)  The capacitance for the port
            %     7)  A character string which identifies a
            %          reference plane for the autogrounded port.
            %          this value is FIX for a reference
            %          plane and NONE for a calibration length.
            %     8)  A floating point number which provides the
            %          length of the reference plane when the type
            %          is FIX and provides the calibration length
            %          when the type is NONE.
            %     9) The Port Number(Optional)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Capitalize the string for consistency
            theTypeOfReferencePlane=upper(theTypeOfReferencePlane);
            
            % Construct an empty port
            aPort=SonnetGeometryPort();
            
            if nargin < 10 % If we havent recieved a port number then generate a fresh one
                
                % Find a valid Port Number
                aPortNumber=1;
                for iCounter=1:length(obj.ArrayOfPorts)
                    if aPortNumber==obj.ArrayOfPorts{iCounter}.PortNumber
                        aPortNumber=aPortNumber+1;
                        iCounter=1;  % Reset the counter to start at the beginning of the loop again.
                    end
                end
                
            else % If a port number was passed then we will use it
                aPortNumber=thePortNumber;
            end
            
            % Modify the values for the port
            aPort.Type        =  'AGND';
            aPort.Polygon     =  thePolygon;
            aPort.PortNumber  =  aPortNumber;
            aPort.Resistance  =  theResistance;
            aPort.Reactance   =  theReactance;
            aPort.Inductance  =  theInductance;
            aPort.Capacitance =  theCapacitance;
            aPort.Vertex      =  theVertex;
            aPort.TypeOfReferencePlane=theTypeOfReferencePlane;
            aPort.ReferencePlaneOrCalibrationLength=theReferencePlaneOrCalibrationLength;
            
            % Append the port to the array
            obj.ArrayOfPorts{length(obj.ArrayOfPorts)+1}=aPort;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aPort=addPortCocalibrated(obj,thePolygon,theGroupName,theVertex,theResistance,theReactance,theInductance,theCapacitance,thePortNumber)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will add a standard port
            % to the array of ports. It requires
            % the following arguments:
            %     1) The Polygon the port is attached to
            %     2) The Name of the group it belongs to
            %     3) The Vertex the polygon is attached to
            %     4) The Resistance for the port
            %     5) The Reactance for the port
            %     6) The Inductance for the port
            %     7) The capacitance for the port
            %     8) The Port Number (Optional)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Construct an empty port
            aPort=SonnetGeometryPort();
            
            if nargin < 9 % If we havent recieved a port number then generate a fresh one
                
                % Find a valid Port Number
                aPortNumber=1;
                for iCounter=1:length(obj.ArrayOfPorts)
                    if aPortNumber==obj.ArrayOfPorts{iCounter}.PortNumber
                        aPortNumber=aPortNumber+1;
                        iCounter=1;  % Reset the counter to start at the beginning of the loop again.
                    end
                end
                
            else % If a port number was passed then we will use it
                aPortNumber=thePortNumber;
            end
            
            % Determine the validity of the polygon supplied, if it is an
            % integer than use it as an index in the array of polygons.
            if isa(thePolygon,'SonnetGeometryPolygon') % If we were supplied a polygon then use that polygon
            else                                     % If we were supplied an ID for a polygon then find the polygon from the ID
                [~, thePolygon]=obj.findPolygonUsingId(thePolygon);
            end
            
            % Try to add the groupname as a new cocalibrated port group
            % if the group does not exist it will be created. If
            % it does exist then it wont replace the current one.
            theGroupName=upper(theGroupName);
            obj.addCoCalibratedGroup(theGroupName,'B','FEED')
            
            % Modify the values for the port
            aPort.Type        =  'CUP';
            aPort.GroupName   =  theGroupName;
            aPort.PortNumber  =  aPortNumber;
            aPort.Resistance  =  theResistance;
            aPort.Reactance   =  theReactance;
            aPort.Inductance  =  theInductance;
            aPort.Capacitance =  theCapacitance;
            aPort.Polygon     =  thePolygon;
            aPort.Vertex      =  theVertex;
            
            % Append the port to the array
            obj.ArrayOfPorts{length(obj.ArrayOfPorts)+1}=aPort;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function deletePort(obj,thePortNumber)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %deletePort   Deletes a port
            %   deletePort(PortNumber) will delete
            %   the port represented by port number
            %   PortNumber from the project.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if isa(thePortNumber,'SonnetGeometryPort')
                for iCounter=1:length(obj.ArrayOfPorts)
                    if thePortNumber == obj.ArrayOfPorts{iCounter}
                        obj.ArrayOfPorts(iCounter)=[];
                        break;
                    end
                end
            else
                for iCounter=1:length(obj.ArrayOfPorts)
                    if thePortNumber == obj.ArrayOfPorts{iCounter}.PortNumber
                        obj.ArrayOfPorts(iCounter)=[];
                        break;
                    end
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function deletePortUsingIndex(obj,thePortIndex)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %deletePortUsingIndex   Deletes a port
            %   deletePortUsingIndex(N) will delete
            %   the Nth port in the array of ports.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if isa(thePortIndex,'SonnetGeometryPort')
                for iCounter=1:length(obj.ArrayOfPorts)
                    if thePortIndex == obj.ArrayOfPorts{iCounter}
                        obj.ArrayOfPorts(iCounter)=[];
                        break;
                    end
                end
            else
                obj.ArrayOfPorts(thePortIndex)=[];
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aUniqueId=generateUniqueComponentId(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %   generateUniqueComponentId(N) will generate
            %   a unique component ID value.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            aUniqueId=1;
            while true
                isUnique=true;
                for iCounter = 1:length(obj.ArrayOfComponents)
                    if obj.ArrayOfComponents{iCounter}.Id==aUniqueId;
                        isUnique=false;
                        break;
                    end
                end
                if isUnique
                    break;
                else
                    aUniqueId=aUniqueId+1;
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aComponent = addResistorComponent(obj,theComponentName,theResistorValue,theLevelNumber,...
                theArrayOfPortLocations,theTerminalWidth)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %   aComponent=Project.addResistorComponent(...) adds an ideal resistor
            %   component to a geometry project.  A reference to the newly added
            %   component is returned which can be used to modify the component's
            %   settings.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            aComponent=SonnetGeometryComponent();
            
            aComponent.Type.Type='IDEAL';
            aComponent.Type.Idealtype='RES';
            aComponent.Type.Compval=theResistorValue;
            
            aComponent.Level=theLevelNumber;
            aComponent.Name=theComponentName;
            aComponent.Id=obj.generateUniqueComponentId();
            aComponent.GroundReference='F';
            
            % If the terminal width is a double then the terminal width type is CUST
            % Otherwise the terminal width type may be feed or cell
            if nargin == 6
                if isa(theTerminalWidth,'char')
                    theTerminalWidth=upper(theTerminalWidth);
                    switch theTerminalWidth
                        case 'F'
                            aComponent.TerminalWidthType='FEED';
                        case 'FEED'
                            aComponent.TerminalWidthType='FEED';
                        case 'CELL'
                            aComponent.TerminalWidthType='1CELL';
                        case '1CELL'
                            aComponent.TerminalWidthType='1CELL';
                        case 'C'
                            aComponent.TerminalWidthType='1CELL';
                    end
                else
                    aComponent.TerminalWidthType='CUST';
                    aComponent.TerminalWidth=theTerminalWidth;
                end
            else
                aComponent.TerminalWidthType='FEED';
            end
            
            % Determine port direction if there are two ports. 
            % If there is one port then assume top
            if size(theArrayOfPortLocations,1)==2
                aXCenter=(theArrayOfPortLocations(1)+theArrayOfPortLocations(2))/2;
                aYCenter=(theArrayOfPortLocations(3)+theArrayOfPortLocations(4))/2;
                aXDelta=abs(theArrayOfPortLocations(1)-theArrayOfPortLocations(2));
                aYDelta=abs(theArrayOfPortLocations(3)-theArrayOfPortLocations(4));
                if aXDelta > aYDelta
                    if theArrayOfPortLocations(1) < theArrayOfPortLocations(2)
                        aOrientation1='L';
                        aOrientation2='R';
                    else
                        aOrientation1='R';
                        aOrientation2='L';
                    end
                else
                    if theArrayOfPortLocations(3) < theArrayOfPortLocations(4)
                        aOrientation1='T';
                        aOrientation2='B';
                    else
                        aOrientation1='B';
                        aOrientation2='T';
                    end
                end
                
                % Populate the SMD ports
                aPort1=SonnetGeometryComponentPort();
                aPort1.Level=theLevelNumber;
                aPort1.XLocation=theArrayOfPortLocations(1);
                aPort1.YLocation=theArrayOfPortLocations(3);
                aPort1.Orientation=aOrientation1;
                aPort1.PinNumber=1;
                aPort2=SonnetGeometryComponentPort();
                aPort2.Level=theLevelNumber;
                aPort2.XLocation=theArrayOfPortLocations(2);
                aPort2.YLocation=theArrayOfPortLocations(4);
                aPort2.Orientation=aOrientation2;
                aPort2.PinNumber=2;
                aComponent.Port1=aPort1;
                aComponent.Port2=aPort2;
                
            elseif size(theArrayOfPortLocations,1)==1
                
                % Populate the SMD ports
                aPort1=SonnetGeometryComponentPort();
                aPort1.Level=theLevelNumber;
                aPort1.XLocation=theArrayOfPortLocations(1);
                aPort1.YLocation=theArrayOfPortLocations(2);
                aPort1.Orientation='T';
                aPort1.PinNumber=1;
                aComponent.ArrayOfPorts{1}=aPort1;
                aComponent.ArrayOfPorts(2)=[];
                
            else
                aComponent.ArrayOfPorts={};                
            end
            
            obj.ArrayOfComponents{length(obj.ArrayOfComponents)+1}=aComponent();
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aComponent = addCapacitorComponent(obj,theComponentName,theCapacitorValue,theLevelNumber,...
                theArrayOfPortLocations,theTerminalWidth)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %addCapacitorComponent   Add a capacitor component
            %   Project.addCapacitorComponent(...) adds an ideal capacitor
            %   component to a geometry project.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            aComponent=SonnetGeometryComponent();
            
            aComponent.Type.Type='IDEAL';
            aComponent.Type.Idealtype='CAP';
            aComponent.Type.Compval=theCapacitorValue;
            
            aComponent.Level=theLevelNumber;
            aComponent.Name=theComponentName;
            aComponent.Id=obj.generateUniqueComponentId();
            aComponent.GroundReference='F';
            
            % If the terminal width is a double then the terminal width type is CUST
            % Otherwise the terminal width type may be feed or cell
            if nargin == 6
                if isa(theTerminalWidth,'char')
                    theTerminalWidth=upper(theTerminalWidth);
                    switch theTerminalWidth
                        case 'F'
                            aComponent.TerminalWidthType='FEED';
                        case 'FEED'
                            aComponent.TerminalWidthType='FEED';
                        case 'CELL'
                            aComponent.TerminalWidthType='1CELL';
                        case '1CELL'
                            aComponent.TerminalWidthType='1CELL';
                        case 'C'
                            aComponent.TerminalWidthType='1CELL';
                    end
                else
                    aComponent.TerminalWidthType='CUST';
                    aComponent.TerminalWidth=theTerminalWidth;
                end
            else
                aComponent.TerminalWidthType='FEED';
            end
            
            % Determine port direction if there are two ports. 
            % If there is one port then assume top
            if size(theArrayOfPortLocations,1)==2
                aXCenter=(theArrayOfPortLocations(1)+theArrayOfPortLocations(2))/2;
                aYCenter=(theArrayOfPortLocations(3)+theArrayOfPortLocations(4))/2;
                aXDelta=abs(theArrayOfPortLocations(1)-theArrayOfPortLocations(2));
                aYDelta=abs(theArrayOfPortLocations(3)-theArrayOfPortLocations(4));
                if aXDelta > aYDelta
                    if theArrayOfPortLocations(1) < theArrayOfPortLocations(2)
                        aOrientation1='L';
                        aOrientation2='R';
                    else
                        aOrientation1='R';
                        aOrientation2='L';
                    end
                else
                    if theArrayOfPortLocations(3) < theArrayOfPortLocations(4)
                        aOrientation1='T';
                        aOrientation2='B';
                    else
                        aOrientation1='B';
                        aOrientation2='T';
                    end
                end
                
                % Populate the SMD ports
                aPort1=SonnetGeometryComponentPort();
                aPort1.Level=theLevelNumber;
                aPort1.XLocation=theArrayOfPortLocations(1);
                aPort1.YLocation=theArrayOfPortLocations(3);
                aPort1.Orientation=aOrientation1;
                aPort1.PinNumber=1;
                aPort2=SonnetGeometryComponentPort();
                aPort2.Level=theLevelNumber;
                aPort2.XLocation=theArrayOfPortLocations(2);
                aPort2.YLocation=theArrayOfPortLocations(4);
                aPort2.Orientation=aOrientation2;
                aPort2.PinNumber=2;
                aComponent.Port1=aPort1;
                aComponent.Port2=aPort2;
                
            elseif size(theArrayOfPortLocations,1)==1
                
                % Populate the SMD ports
                aPort1=SonnetGeometryComponentPort();
                aPort1.Level=theLevelNumber;
                aPort1.XLocation=theArrayOfPortLocations(1);
                aPort1.YLocation=theArrayOfPortLocations(2);
                aPort1.Orientation='T';
                aPort1.PinNumber=1;
                aComponent.ArrayOfPorts{1}=aPort1;
                aComponent.ArrayOfPorts(2)=[];
                
            else
                aComponent.ArrayOfPorts={};                
            end
            
            obj.ArrayOfComponents{length(obj.ArrayOfComponents)+1}=aComponent();
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aComponent = addInductorComponent(obj,theComponentName,theInductorValue,theLevelNumber,...
                theArrayOfPortLocations,theTerminalWidth)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %addInductorComponent   Add a inductor component
            %   Project.addInductorComponent(...) adds an ideal inductor
            %   component to a geometry project.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            aComponent=SonnetGeometryComponent();
            
            aComponent.Type.Type='IDEAL';
            aComponent.Type.Idealtype='IND';
            aComponent.Type.Compval=theInductorValue;
            
            aComponent.Level=theLevelNumber;
            aComponent.Name=theComponentName;
            aComponent.Id=obj.generateUniqueComponentId();
            aComponent.GroundReference='F';
            
            % If the terminal width is a double then the terminal width type is CUST
            % Otherwise the terminal width type may be feed or cell
            if nargin == 6
                if isa(theTerminalWidth,'char')
                    theTerminalWidth=upper(theTerminalWidth);
                    switch theTerminalWidth
                        case 'F'
                            aComponent.TerminalWidthType='FEED';
                        case 'FEED'
                            aComponent.TerminalWidthType='FEED';
                        case 'CELL'
                            aComponent.TerminalWidthType='1CELL';
                        case '1CELL'
                            aComponent.TerminalWidthType='1CELL';
                        case 'C'
                            aComponent.TerminalWidthType='1CELL';
                    end
                else
                    aComponent.TerminalWidthType='CUST';
                    aComponent.TerminalWidth=theTerminalWidth;
                end
            else
                aComponent.TerminalWidthType='FEED';
            end
            
            % Determine port direction if there are two ports. 
            % If there is one port then assume top
            if size(theArrayOfPortLocations,1)==2
                aXCenter=(theArrayOfPortLocations(1)+theArrayOfPortLocations(2))/2;
                aYCenter=(theArrayOfPortLocations(3)+theArrayOfPortLocations(4))/2;
                aXDelta=abs(theArrayOfPortLocations(1)-theArrayOfPortLocations(2));
                aYDelta=abs(theArrayOfPortLocations(3)-theArrayOfPortLocations(4));
                if aXDelta > aYDelta
                    if theArrayOfPortLocations(1) < theArrayOfPortLocations(2)
                        aOrientation1='L';
                        aOrientation2='R';
                    else
                        aOrientation1='R';
                        aOrientation2='L';
                    end
                else
                    if theArrayOfPortLocations(3) < theArrayOfPortLocations(4)
                        aOrientation1='T';
                        aOrientation2='B';
                    else
                        aOrientation1='B';
                        aOrientation2='T';
                    end
                end
                
                % Populate the SMD ports
                aPort1=SonnetGeometryComponentPort();
                aPort1.Level=theLevelNumber;
                aPort1.XLocation=theArrayOfPortLocations(1);
                aPort1.YLocation=theArrayOfPortLocations(3);
                aPort1.Orientation=aOrientation1;
                aPort1.PinNumber=1;
                aPort2=SonnetGeometryComponentPort();
                aPort2.Level=theLevelNumber;
                aPort2.XLocation=theArrayOfPortLocations(2);
                aPort2.YLocation=theArrayOfPortLocations(4);
                aPort2.Orientation=aOrientation2;
                aPort2.PinNumber=2;
                aComponent.Port1=aPort1;
                aComponent.Port2=aPort2;
                
            elseif size(theArrayOfPortLocations,1)==1
                
                % Populate the SMD ports
                aPort1=SonnetGeometryComponentPort();
                aPort1.Level=theLevelNumber;
                aPort1.XLocation=theArrayOfPortLocations(1);
                aPort1.YLocation=theArrayOfPortLocations(2);
                aPort1.Orientation='T';
                aPort1.PinNumber=1;
                aComponent.ArrayOfPorts{1}=aPort1;
                aComponent.ArrayOfPorts(2)=[];
                
            else
                aComponent.ArrayOfPorts={};                
            end
            
            obj.ArrayOfComponents{length(obj.ArrayOfComponents)+1}=aComponent();
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aComponent = addDataFileComponent(obj,theComponentFileBlock,...
                theComponentName,theDataFilename,theLevelNumber,...
                theArrayOfPortLocations,theTerminalWidth)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %addDataFileComponent   Add a data file component
            %   Project.addDataFileComponent(...) adds a data
            %   file component to a geometry project.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        
            aComponent=SonnetGeometryComponent();
            
            aComponent.Type.Type='SPARAM';
            aComponent.Type.paramfileindex=theComponentFileBlock.addSmdFile(theDataFilename);
            
            aComponent.Level=theLevelNumber;
            aComponent.Name=theComponentName;
            aComponent.Id=obj.generateUniqueComponentId();
            aComponent.GroundReference='F';
            
            % If the terminal width is a double then the terminal width type is CUST
            % Otherwise the terminal width type may be feed or cell
            if nargin == 7
                if isa(theTerminalWidth,'char')
                    theTerminalWidth=upper(theTerminalWidth);
                    switch theTerminalWidth
                        case 'F'
                            aComponent.TerminalWidthType='FEED';
                        case 'FEED'
                            aComponent.TerminalWidthType='FEED';
                        case 'CELL'
                            aComponent.TerminalWidthType='1CELL';
                        case '1CELL'
                            aComponent.TerminalWidthType='1CELL';
                        case 'C'
                            aComponent.TerminalWidthType='1CELL';
                    end
                else
                    aComponent.TerminalWidthType='CUST';
                    aComponent.TerminalWidth=theTerminalWidth;
                end
            else
                aComponent.TerminalWidthType='FEED';
            end
            
            % Determine port direction if there are two ports. 
            % If there is one port then assume top
            if size(theArrayOfPortLocations,1)>2
                warning 'Not supported for more than two ports'
                aComponent.ArrayOfPorts={}; 
                    
            elseif size(theArrayOfPortLocations,1)==2
                aXCenter=(theArrayOfPortLocations(1)+theArrayOfPortLocations(2))/2;
                aYCenter=(theArrayOfPortLocations(3)+theArrayOfPortLocations(4))/2;
                aXDelta=abs(theArrayOfPortLocations(1)-theArrayOfPortLocations(2));
                aYDelta=abs(theArrayOfPortLocations(3)-theArrayOfPortLocations(4));
                if aXDelta > aYDelta
                    if theArrayOfPortLocations(1) < theArrayOfPortLocations(2)
                        aOrientation1='L';
                        aOrientation2='R';
                    else
                        aOrientation1='R';
                        aOrientation2='L';
                    end
                else
                    if theArrayOfPortLocations(3) < theArrayOfPortLocations(4)
                        aOrientation1='T';
                        aOrientation2='B';
                    else
                        aOrientation1='B';
                        aOrientation2='T';
                    end
                end
                
                % Populate the SMD ports
                aPort1=SonnetGeometryComponentPort();
                aPort1.Level=theLevelNumber;
                aPort1.XLocation=theArrayOfPortLocations(1);
                aPort1.YLocation=theArrayOfPortLocations(3);
                aPort1.Orientation=aOrientation1;
                aPort1.PinNumber=1;
                aPort2=SonnetGeometryComponentPort();
                aPort2.Level=theLevelNumber;
                aPort2.XLocation=theArrayOfPortLocations(2);
                aPort2.YLocation=theArrayOfPortLocations(4);
                aPort2.Orientation=aOrientation2;
                aPort2.PinNumber=2;
                aComponent.Port1=aPort1;
                aComponent.Port2=aPort2;
                
            elseif size(theArrayOfPortLocations,1)==1
                
                % Populate the SMD ports
                aPort1=SonnetGeometryComponentPort();
                aPort1.Level=theLevelNumber;
                aPort1.XLocation=theArrayOfPortLocations(1);
                aPort1.YLocation=theArrayOfPortLocations(2);
                aPort1.Orientation='T';
                aPort1.PinNumber=1;
                aComponent.ArrayOfPorts{1}=aPort1;
                aComponent.ArrayOfPorts(2)=[];
                
            else
                aComponent.ArrayOfPorts={};                
            end
            
            obj.ArrayOfComponents{length(obj.ArrayOfComponents)+1}=aComponent;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aComponent = addPortOnlyComponent(obj,theComponentName,theLevelNumber,...
                theArrayOfPortLocations,theTerminalWidth)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %   aComponent=Project.addPortOnlyComponent(...) adds an ports only
            %   component to a geometry project.  A reference to the newly added
            %   component is returned which can be used to modify the component's
            %   settings.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            aComponent=SonnetGeometryComponent();
            
            aComponent.Type.Type='NONE';
            
            aComponent.Level=theLevelNumber;
            aComponent.Name=theComponentName;
            aComponent.Id=obj.generateUniqueComponentId();
            aComponent.GroundReference='F';
            
            % If the terminal width is a double then the terminal width type is CUST
            % Otherwise the terminal width type may be feed or cell
            if nargin == 5
                if isa(theTerminalWidth,'char')
                    theTerminalWidth=upper(theTerminalWidth);
                    switch theTerminalWidth
                        case 'F'
                            aComponent.TerminalWidthType='FEED';
                        case 'FEED'
                            aComponent.TerminalWidthType='FEED';
                        case 'CELL'
                            aComponent.TerminalWidthType='1CELL';
                        case '1CELL'
                            aComponent.TerminalWidthType='1CELL';
                        case 'C'
                            aComponent.TerminalWidthType='1CELL';
                    end
                else
                    aComponent.TerminalWidthType='CUST';
                    aComponent.TerminalWidth=theTerminalWidth;
                end
            else
                aComponent.TerminalWidthType='FEED';
            end
            
            % Determine port direction if there are two ports. 
            % If there is one port then assume top
            if size(theArrayOfPortLocations,1)==2
                aXCenter=(theArrayOfPortLocations(1)+theArrayOfPortLocations(2))/2;
                aYCenter=(theArrayOfPortLocations(3)+theArrayOfPortLocations(4))/2;
                aXDelta=abs(theArrayOfPortLocations(1)-theArrayOfPortLocations(2));
                aYDelta=abs(theArrayOfPortLocations(3)-theArrayOfPortLocations(4));
                if aXDelta > aYDelta
                    if theArrayOfPortLocations(1) < theArrayOfPortLocations(2)
                        aOrientation1='L';
                        aOrientation2='R';
                    else
                        aOrientation1='R';
                        aOrientation2='L';
                    end
                else
                    if theArrayOfPortLocations(3) < theArrayOfPortLocations(4)
                        aOrientation1='T';
                        aOrientation2='B';
                    else
                        aOrientation1='B';
                        aOrientation2='T';
                    end
                end
                
                % Populate the SMD ports
                aPort1=SonnetGeometryComponentPort();
                aPort1.Level=theLevelNumber;
                aPort1.XLocation=theArrayOfPortLocations(1);
                aPort1.YLocation=theArrayOfPortLocations(3);
                aPort1.Orientation=aOrientation1;
                aPort1.PinNumber=1;
                aPort2=SonnetGeometryComponentPort();
                aPort2.Level=theLevelNumber;
                aPort2.XLocation=theArrayOfPortLocations(2);
                aPort2.YLocation=theArrayOfPortLocations(4);
                aPort2.Orientation=aOrientation2;
                aPort2.PinNumber=2;
                aComponent.Port1=aPort1;
                aComponent.Port2=aPort2;
                
            elseif size(theArrayOfPortLocations,1)==1
                
                % Populate the SMD ports
                aPort1=SonnetGeometryComponentPort();
                aPort1.Level=theLevelNumber;
                aPort1.XLocation=theArrayOfPortLocations(1);
                aPort1.YLocation=theArrayOfPortLocations(2);
                aPort1.Orientation='T';
                aPort1.PinNumber=1;
                aComponent.ArrayOfPorts{1}=aPort1;
                aComponent.ArrayOfPorts(2)=[];
                
            else
                aComponent.ArrayOfPorts={};                
            end
            
            obj.ArrayOfComponents{length(obj.ArrayOfComponents)+1}=aComponent();
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function deleteComponentUsingId(obj,theId)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will try to delete a component from the
            % array of components. the component's Debug ID is passed to it.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % If a component name was passed then search for the component
            % and delete it if found. Throw an error if not found.
            if isa(theId,'char')
                for iCounter=1:length(obj.ArrayOfComponents)
                    if strcmpi(obj.ArrayOfComponents{iCounter}.Name,theId)==1
                        obj.ArrayOfComponents(iCounter)=[];
                        return
                    end
                end
                error('Component not found.');
            end
            
            % If a component reference was passed then extract its ID
            if isa(theId,'SonnetGeometryComponent')
                theId=theId.Id;
            end
            
            % Search for a component with matching ID, delete it
            for iCounter=1:length(obj.ArrayOfComponents)
                if theId==obj.ArrayOfComponents{iCounter}.Id
                    obj.ArrayOfComponents(iCounter)=[];
                    return
                end
            end
            
            error('Component not found.');
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function deleteComponentUsingIndex(obj,theIndex)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will try to delete a component from the
            % array of components. the component's index is passed to it.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % If a component reference was passed then extract its name
            if isa(theIndex,'SonnetGeometryComponent')
                theIndex=theIndex.Name;
            end
            
            % If a component name was passed then search for the component
            % and delete it if found. Throw an error if not found.
            if isa(theIndex,'char')
                for iCounter=1:length(obj.ArrayOfComponents)
                    if strcmpi(obj.ArrayOfComponents{iCounter}.Name,theIndex)==1
                        obj.ArrayOfComponents(iCounter)=[];
                        return
                    end
                end
                error('Component not found.');
            end
            
            % Remove the component
            if theIndex <= 0 || theIndex > length(obj.ArrayOfComponents)
                error('Invalid index');
            end
            obj.ArrayOfComponents(theIndex)=[];
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addMetalTypeUsingLibrary(obj,theName,theThickness)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This Method will add another metal type
            %   to the project based on an entry in the
            %   Sonnet library of metal types.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            [~, aSonnetInstallDirectoryList]=SonnetPath();
            
            % Find an installed version of Sonnet that has a metal library
            iPathCounter=1;
            while iPathCounter <= length(aSonnetInstallDirectoryList)
                aSonnetPath=strrep(aSonnetInstallDirectoryList{iPathCounter},'"','');
                if exist([aSonnetPath '\data\libraries\metal-library.txt'],'file')
                    break
                end
                iPathCounter=iPathCounter+1;
            end
            if iPathCounter > length(aSonnetInstallDirectoryList)
               error('Could not locate a metal type library file in Sonnet path'); 
            end
            
            aFid=fopen([aSonnetPath '\data\libraries\metal-library.txt']);
            aTempString=fgetl(aFid);
            
            while feof(aFid)~=1
                
                if ~isempty(strfind(aTempString,theName))
                    % Construct an empty layer
                    aType=SonnetGeometryMetalType();
                    
                    aTempString=strrep(aTempString,'MET','');
                    aTempString=strrep(aTempString,'"','');
                    
                    % Import the properties of the layer material
                    aStringIndex=1;
                    aStringLength=length(aTempString);
                    [aType.Name, ~, ~, aIndex]=sscanf(aTempString(aStringIndex:aStringLength),' %s',1);
                    aStringIndex=aStringIndex+aIndex;
                    
                    [~, ~, ~, aIndex]=sscanf(aTempString(aStringIndex:aStringLength),' %g',1);
                    aStringIndex=aStringIndex+aIndex;
                    
                    [aType.Type, ~, ~, aIndex]=sscanf(aTempString(aStringIndex:aStringLength),' %s',1);
                    aStringIndex=aStringIndex+aIndex;
                    
                    switch aType.Type
                        case 'NOR'      % Normal Metal
                            [aType.Conductivity, ~, ~, aIndex]=sscanf(aTempString(aStringIndex:aStringLength),' %g',1);
                            aStringIndex=aStringIndex+aIndex;
                            
                            [aType.CurrentRatio, ~, ~, aIndex]=sscanf(aTempString(aStringIndex:aStringLength),' %g',1);
                            
                            aType.Thickness=theThickness;
                            
                        case 'RES'      % Resistor Metal
                            [aType.Resistance, ~, ~, aIndex]=sscanf(aTempString(aStringIndex:aStringLength),' %g',1);
                            
                        case 'NAT'      % Native Metal
                            [aType.Resistance, ~, ~, aIndex]=sscanf(aTempString(aStringIndex:aStringLength),' %g',1);
                            aStringIndex=aStringIndex+aIndex;
                            
                            [aType.SkinCoefficient, ~, ~, aIndex]=sscanf(aTempString(aStringIndex:aStringLength),' %g',1);
                            
                        case 'SUP'      % General Metal
                            [aType.Resistance, ~, ~, aIndex]=sscanf(aTempString(aStringIndex:aStringLength),' %g',1);
                            aStringIndex=aStringIndex+aIndex;
                            
                            [aType.SkinCoefficient, ~, ~, aIndex]=sscanf(aTempString(aStringIndex:aStringLength),' %g',1);
                            aStringIndex=aStringIndex+aIndex;
                            
                            [aType.Reactance, ~, ~, aIndex]=sscanf(aTempString(aStringIndex:aStringLength),' %g',1);
                            aStringIndex=aStringIndex+aIndex;
                            
                            [aType.KineticInductance, ~, ~, aIndex]=sscanf(aTempString(aStringIndex:aStringLength),' %g',1);
                            
                        case 'SEN'      % Sense Metal
                            [aType.Reactance, ~, ~, aIndex]=sscanf(aTempString(aStringIndex:aStringLength),' %g',1);
                            
                        case 'TMM'      % Thick Metal
                            [aType.Conductivity, ~, ~, aIndex]=sscanf(aTempString(aStringIndex:aStringLength),' %g',1);
                            aStringIndex=aStringIndex+aIndex;
                            
                            [aType.CurrentRatio, ~, ~, aIndex]=sscanf(aTempString(aStringIndex:aStringLength),' %g',1);
                            aStringIndex=aStringIndex+aIndex;
                            
                            [~, ~, ~, aIndex]=sscanf(aTempString(aStringIndex:aStringLength),' %g',1);
                            aType.Thickness=theThickness;
                            aStringIndex=aStringIndex+aIndex;
                            
                            [aType.NumSheets, ~, ~, aIndex]=sscanf(aTempString(aStringIndex:aStringLength),' %d',1);
                            
                        case 'ROG'      % Thick Metal
                            [~, ~, ~, aIndex]=sscanf(aTempString(aStringIndex:aStringLength),' %g',1);
                            aType.Thickness=theThickness;
                            aStringIndex=aStringIndex+aIndex;
                            
                            [aType.Roughness, ~, ~, aIndex]=sscanf(aTempString(aStringIndex:aStringLength),' %g',1);
                            aStringIndex=aStringIndex+aIndex;
                            
                            [aType.NumSheets, ~, ~, aIndex]=sscanf(aTempString(aStringIndex:aStringLength),' %d',1);
                            aStringIndex=aStringIndex+aIndex;
                            
                            [aType.CurrentRatio, ~, ~, aIndex]=sscanf(aTempString(aStringIndex:aStringLength),' %g',1);
                            aStringIndex=aStringIndex+aIndex;
                            
                            [aType.TopSurface, ~, ~, aIndex]=sscanf(aTempString(aStringIndex:aStringLength),' %c',1);
                            aStringIndex=aStringIndex+aIndex;
                            
                            [aType.BottomSurface, ~, ~, aIndex]=sscanf(aTempString(aStringIndex:aStringLength),' %c',1);
                    end
                    
                    % Append the material to the array
                    obj.ArrayOfMetalTypes{length(obj.ArrayOfMetalTypes)+1}=aType;
                    
                    fclose(aFid);
                    return;
                    
                end
                aTempString=fgetl(aFid);
            end
            error('Invalid Metal Material Specified');
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addMetalType(obj,theType,theArgument1,theArgument2,theArgument3,theArgument4,theArgument5,theArgument6,theArgument7,theArgument8)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This Method will add another metal type
            %   to the project. It requires a type as
            %   the first argument which should
            %   be one of the following:
            %
            %       NOR   -   Normal Metal
            %       RES   -   Resistor Metal
            %       NAT   -   Native Metal
            %       SUP   -   General Metal
            %       SEN   -   Sense Metal
            %       TMM   -   Thick Metal
            %       RUF   -   Rough Metal
            %
            % Then you will need to supply the necessary
            %   arguments for each as follows:
            %
            %  NOR-Normal Metal
            %     1) The Name of the metal
            %     2) The Conductivity of the metal
            %     3) The Current Ratio of the metal
            %     4) The Thickness of the metal
            %     5) The Electrical Loss Type
            %
            %  RES-Resistor Metal
            %     1) The Name of the metal
            %     2) The Resistance of the metal
            %
            %  NAT-Native Metal
            %     1) The Name of the metal
            %     2) The Resistance of the metal
            %     3) The Skin Coefficient of the metal
            %
            %  SUP-General Metal
            %     1) The Name of the metal
            %     2) The Resistance of the metal
            %     3) The Skin Coefficient of the metal
            %     4) The Reactance of the metal
            %     5) The Kinetic Inductance of the metal
            %
            %  SEN-Sense Metal
            %     1) The Name of the metal
            %     2) The Reactance of the metal
            %
            %  TMM-Thick Metal
            %     1) The Name of the metal
            %     2) The Conductivity of the metal
            %     3) The Current Ratio of the metal
            %     4) The Thickness of the metal
            %     5) The NumSheets of the metal
            %     6) The Electrical Loss Type
            %
            %   RUF-Rough Metal
            %     1) The Name of the metal
            %     2) Whether the metal should be modeled as being thick or thin
            %          This value may be either (case insensitive)
            %              - 'thick' or 'THK' for thick
            %              - 'thin' or 'THN' for thin           
            %     3) The Thickness of the metal
            %     4) The Conductivity of the metal
            %     5) The Current Ratio of the metal
            %     6) The Roughness of the top
            %     7) The Roughness of the bottom
            %     8) The Electrical Loss Type
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if ~exist('theArgument5', 'var')
                theArgument5=[];
            end

            if ~exist('theArgument6', 'var')
                theArgument6=[];
            end                    

            if ~exist('theArgument8', 'var')
                theArgument8=[];
            end
            
            % make the type uppercase
            theType=upper(theType);
            
            switch theType
                
                case 'NOR'      % Normal Metal

                    
                    obj.addNormalMetal(theArgument1,theArgument2,theArgument3,theArgument4,theArgument5);
                    
                case 'RES'      % Resistor Metal
                    obj.addResistorMetal(theArgument1,theArgument2);
                    
                case 'NAT'      % Native Metal
                    obj.addNativeMetal(theArgument1,theArgument2,theArgument3);
                    
                case 'SUP'      % General Metal
                    obj.addGeneralMetal(theArgument1,theArgument2,theArgument3,theArgument4,theArgument5);
                    
                case 'SEN'      % Sense Metal
                    obj.addSenseMetal(theArgument1,theArgument2);
                    
                case 'TMM'      % Thick Metal

                    obj.addThickMetal(theArgument1,theArgument2,theArgument3,theArgument4,theArgument5,theArgument6);
                    
                case 'RUF'      % Rough Metal

                    obj.addRoughMetal(theArgument1,theArgument2,theArgument3,theArgument4,theArgument5,theArgument6,theArgument7,theArgument8);
                    
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addNormalMetal(obj,theName,theConductivity,theCurrentRatio,theThickness,theElectricalLossType)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will add a normal type of
            % metal to the array of metals. It requires
            % the following arguments:
            %     1) The Name of the metal
            %     2) The Conductivity of the metal
            %     3) The Current Ratio of the metal
            %     4) The Thickness of the metal
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if ~exist('theElectricalLossType','var')
                theElectricalLossType=[];
            end
            
            % Construct an empty metal type
            aMetalType=SonnetGeometryMetalType();
            
            % Find a valid PatternId
            aPatternId=1;
            for iCounter=1:length(obj.ArrayOfMetalTypes)
                if aPatternId==obj.ArrayOfMetalTypes{iCounter}.PatternId
                    aPatternId=aPatternId+1;
                    iCounter=1;  % Reset the counter to start at the beginning of the loop again.
                end
            end
            
            % Modify the values for the metal
            aMetalType.Conductivity = theConductivity;
            aMetalType.CurrentRatio = theCurrentRatio;
            aMetalType.Thickness    = theThickness;
            aMetalType.Name         = theName;
            aMetalType.PatternId    = aPatternId;
            aMetalType.Type         = 'NOR';
            
            aMetalType.ElectricalLossType = theElectricalLossType;
            
            % Append the metal type to the array
            obj.ArrayOfMetalTypes{length(obj.ArrayOfMetalTypes)+1}=aMetalType;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addResistorMetal(obj,theName,theResistance)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will add a resistor type of
            % metal to the array of metals. It requires
            % the following arguments:
            %     1) The Name of the metal
            %     2) The Resistance of the metal
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Construct an empty metal type
            aMetalType=SonnetGeometryMetalType();
            
            % Find a valid PatternId
            aPatternId=0;
            for iCounter=1:length(obj.ArrayOfMetalTypes)
                if aPatternId==obj.ArrayOfMetalTypes{iCounter}.PatternId
                    aPatternId=aPatternId+1;
                    iCounter=1;  % Reset the counter to start at the beginning of the loop again.
                end
            end
            
            % Modify the values for the metal
            aMetalType.Resistance =  theResistance;
            aMetalType.Name       =  theName;
            aMetalType.PatternId  =  aPatternId;
            aMetalType.Type       =  'RES';
            
            % Append the metal type to the array
            obj.ArrayOfMetalTypes{length(obj.ArrayOfMetalTypes)+1}=aMetalType;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addNativeMetal(obj,theName,theResistance,theSkinCoefficient)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will add a native type of
            % metal to the array of metals. It requires
            % the following arguments:
            %     1) The Name of the metal
            %     2) The Resistance of the metal
            %     3) The Skin Coefficient of the metal
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Construct an empty metal type
            aMetalType=SonnetGeometryMetalType();
            
            % Find a valid PatternId
            aPatternId=0;
            for iCounter=1:length(obj.ArrayOfMetalTypes)
                if aPatternId==obj.ArrayOfMetalTypes{iCounter}.PatternId
                    aPatternId=aPatternId+1;
                    iCounter=1;  % Reset the counter to start at the beginning of the loop again.
                end
            end
            
            % Modify the values for the metal
            aMetalType.Resistance      =  theResistance;
            aMetalType.SkinCoefficient =  theSkinCoefficient;
            aMetalType.Name            =  theName;
            aMetalType.PatternId       =  aPatternId;
            aMetalType.Type            =  'NAT';
            
            % Append the metal type to the array
            obj.ArrayOfMetalTypes{length(obj.ArrayOfMetalTypes)+1}=aMetalType;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addRoughMetal(obj,theName,theThicknessType,theThickness,theConductivity,...
                theCurrentRatio,theRoughnessTop,theRoughnessBottom,theElectricalLossType)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will add a rough type of
            % metal to the array of metals. It requires
            % the following arguments:
            %     1) The Name of the metal
            %     2) Whether the metal should be modeled as being thick or thin
            %          This value may be either (case insensitive)
            %              - 'thick' or 'THK' for thick
            %              - 'thin' or 'THN' for thin           
            %     3) The Thickness of the metal
            %     4) The Conductivity of the metal
            %     5) The Current Ratio of the metal
            %     6) The Roughness of the top
            %     7) The Roughness of the bottom
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if ~exist('theElectricalLossType','var')
                theElectricalLossType=[];
            end
            
            
            % Construct an empty metal type
            aMetalType=SonnetGeometryMetalType();
            
            % Find a valid PatternId
            aPatternId=0;
            for iCounter=1:length(obj.ArrayOfMetalTypes)
                if aPatternId==obj.ArrayOfMetalTypes{iCounter}.PatternId
                    aPatternId=aPatternId+1;
                    iCounter=1;  % Reset the counter to start at the beginning of the loop again.
                end
            end
            
            % Determine if the metal thickness type is thick or thin
            if strcmpi(theThicknessType,'THK')==1 || strcmpi(theThicknessType,'THICK')==1
                aMetalType.isThick = true;
            else
                aMetalType.isThick = false;
            end
            
            % Modify the values for the metal
            aMetalType.Name               =  theName;
            aMetalType.Thickness          =  theThickness;
            aMetalType.Conductivity       =  theConductivity;
            aMetalType.CurrentRatio       =  theCurrentRatio;
            aMetalType.TopRoughness       =  theRoughnessTop;
            aMetalType.BottomRoughness    =  theRoughnessBottom;
            aMetalType.Type               =  'RUF';         
            
            aMetalType.ElectricalLossType = theElectricalLossType;
            
            % Append the metal type to the array
            obj.ArrayOfMetalTypes{length(obj.ArrayOfMetalTypes)+1}=aMetalType;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addGeneralMetal(obj,theName,theResistance,theSkinCoefficient,theReactance,theKineticInductance)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will add a general type of
            % metal to the array of metals. It requires
            % the following arguments:
            %     1) The Name of the metal
            %     2) The Resistance of the metal
            %     3) The Skin Coefficient of the metal
            %     4) The Reactance of the metal
            %     5) The Kinetic Inductance of the metal
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Construct an empty metal type
            aMetalType=SonnetGeometryMetalType();
            
            % Find a valid PatternId
            aPatternId=0;
            for iCounter=1:length(obj.ArrayOfMetalTypes)
                if aPatternId==obj.ArrayOfMetalTypes{iCounter}.PatternId
                    aPatternId=aPatternId+1;
                    iCounter=1;  % Reset the counter to start at the beginning of the loop again.
                end
            end
            
            % Modify the values for the metal
            aMetalType.Resistance        =  theResistance;
            aMetalType.SkinCoefficient   =  theSkinCoefficient;
            aMetalType.Reactance         =  theReactance;
            aMetalType.KineticInductance =  theKineticInductance;
            aMetalType.Name              =  theName;
            aMetalType.PatternId         =  aPatternId;
            aMetalType.Type              =  'SUP';
            
            % Append the metal type to the array
            obj.ArrayOfMetalTypes{length(obj.ArrayOfMetalTypes)+1}=aMetalType;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addSenseMetal(obj,theName,theReactance)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will add a Sense type of
            % metal to the array of metals. It requires
            % the following arguments:
            %     1) The Name of the metal
            %     2) The Reactance of the metal
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Construct an empty metal type
            aMetalType=SonnetGeometryMetalType();
            
            % Find a valid PatternId
            aPatternId=0;
            for iCounter=1:length(obj.ArrayOfMetalTypes)
                if aPatternId==obj.ArrayOfMetalTypes{iCounter}.PatternId
                    aPatternId=aPatternId+1;
                    iCounter=1;  % Reset the counter to start at the beginning of the loop again.
                end
            end
            
            % Modify the values for the metal
            aMetalType.Reactance = theReactance;
            aMetalType.Name      = theName;
            aMetalType.PatternId = aPatternId;
            aMetalType.Type      = 'SEN';
            
            % Append the metal type to the array
            obj.ArrayOfMetalTypes{length(obj.ArrayOfMetalTypes)+1}=aMetalType;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addThickMetal(obj,theName,theConductivity,theCurrentRatio,theThickness,theNumSheets,theElectricalLossType)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will add a Thick Metal type of
            % metal to the array of metals. It requires
            % the following arguments:
            %     1) The Name of the metal
            %     2) The Conductivity of the metal
            %     3) The Current Ratio of the metal
            %     4) The Thickness of the metal
            %     5) The NumSheets of the metal
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if ~exist('theElectricalLossType','var')
                theElectricalLossType=[];
            end
            
            % Construct an empty metal type
            aMetalType=SonnetGeometryMetalType();
            
            % Find a valid PatternId
            aPatternId=0;
            for iCounter=1:length(obj.ArrayOfMetalTypes)
                if aPatternId==obj.ArrayOfMetalTypes{iCounter}.PatternId
                    aPatternId=aPatternId+1;
                    iCounter=1;  % Reset the counter to start at the beginning of the loop again.
                end
            end
            
            % Modify the values for the metal
            aMetalType.Conductivity =  theConductivity;
            aMetalType.CurrentRatio =  theCurrentRatio;
            aMetalType.Thickness    =  theThickness;
            aMetalType.NumSheets    =  theNumSheets;
            aMetalType.Name         =  theName;
            aMetalType.PatternId    =  aPatternId;
            aMetalType.Type         =  'TMM';
            
            aMetalType.ElectricalLossType = theElectricalLossType;
            
            % Append the metal type to the array
            obj.ArrayOfMetalTypes{length(obj.ArrayOfMetalTypes)+1}=aMetalType;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function defineNewViaMetalType(obj,theType,theName,theArgument2,theArgument3,theArgument4)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will add a new via metal type to the project
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if ~exist('theArgument4','var')
                theArgument4=[];
            end
                      
            theType=upper(theType);
            switch theType
                case 'VOL'
                    obj.addVolumeMetal(theName,theArgument2,theArgument3,theArgument4);
                case 'VOLUME'
                    obj.addVolumeMetal(theName,theArgument2,theArgument3,theArgument4);
                case 'SFC'
                    obj.addSurfaceMetal(theName,theArgument2,theArgument3,theArgument4);
                case 'SURFACE'
                    obj.addSurfaceMetal(theName,theArgument2,theArgument3);
                case 'ARR'
                    obj.addArrayMetal(theName,theArgument2,theArgument3,theArgument4);
                case 'ARRAY'
                    obj.addArrayMetal(theName,theArgument2,theArgument3,theArgument4);
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addVolumeMetal(obj,theName,theConductivity,theWallThickness,theElectricalLossType)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will add a volume metal type
            % to the array of via metals. It requires
            % the following arguments:
            %     1) The Name of the metal
            %     2) The Conductivity of the metal
            %     3) The Wall Thickness
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % set the electrical loss type
            if ~exist('theElectricalLossType','var')
                theElectricalLossType=[];
            end
            
            % Construct an empty metal type
            aMetalType=SonnetGeometryMetalType();
            
            % Find a valid PatternId
            aPatternId=0;
            for iCounter=1:length(obj.ArrayOfMetalTypes)
                if aPatternId==obj.ArrayOfMetalTypes{iCounter}.PatternId
                    aPatternId=aPatternId+1;
                    iCounter=1;  % Reset the counter to start at the beginning of the loop again.
                end
            end
            
            if strcmpi(theWallThickness,'solid')==1 || (isa(theWallThickness,'double') && theWallThickness < 0)
                aMetalType.isSolid=true;
                theWallThickness=[];
            else
                aMetalType.isSolid=false;
            end
            
            % Modify the values for the metal
            aMetalType.Conductivity  =  theConductivity;
            aMetalType.WallThickness =  theWallThickness;
            aMetalType.Name          =  theName;
            aMetalType.PatternId     =  aPatternId;
            aMetalType.Type          =  'VOL';
            
            if ~isempty(theElectricalLossType);
                aMetalType.ElectricalLossType = theElectricalLossType;
            end
            
            % Append the metal type to the array
            obj.ArrayOfMetalTypes{length(obj.ArrayOfMetalTypes)+1}=aMetalType;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addSurfaceMetal(obj,theName,theRdcValue,theRrfValue,theXdcValue)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will add a surface metal type
            % to the array of via metals. It requires
            % the following arguments:
            %     1) The Name of the metal
            %     2) The Rdc Value
            %     3) The Rrf Value
            %     4) The Xdc Value
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Construct an empty metal type
            aMetalType=SonnetGeometryMetalType();
            
            % Find a valid PatternId
            aPatternId=0;
            for iCounter=1:length(obj.ArrayOfMetalTypes)
                if aPatternId==obj.ArrayOfMetalTypes{iCounter}.PatternId
                    aPatternId=aPatternId+1;
                    iCounter=1;  % Reset the counter to start at the beginning of the loop again.
                end
            end
            
            % Modify the values for the metal
            aMetalType.Rdc       =  theRdcValue;
            aMetalType.Rrf       =  theRrfValue;
            aMetalType.Xdc       =  theXdcValue;
            aMetalType.Name      =  theName;
            aMetalType.PatternId =  aPatternId;
            aMetalType.Type      =  'SFC';
            
            % Append the metal type to the array
            obj.ArrayOfMetalTypes{length(obj.ArrayOfMetalTypes)+1}=aMetalType;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addArrayMetal(obj,theName,theConductivity,theFillFactor,theElectricalLossType)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will add an array metal type
            % to the array of via metals. It requires
            % the following arguments:
            %     1) The Name of the metal
            %     2) The conductivity
            %     3) The fill factor
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % set the electrical loss type
            if ~exist('theElectricalLossType','var')
                theElectricalLossType=[];
            end
            
            % Construct an empty metal type
            aMetalType=SonnetGeometryMetalType();
            
            % Find a valid PatternId
            aPatternId=0;
            for iCounter=1:length(obj.ArrayOfMetalTypes)
                if aPatternId==obj.ArrayOfMetalTypes{iCounter}.PatternId
                    aPatternId=aPatternId+1;
                    iCounter=1;  % Reset the counter to start at the beginning of the loop again.
                end
            end
            
            % Modify the values for the metal
            aMetalType.Conductivity  =  theConductivity;
            aMetalType.FillFactor    =  theFillFactor;
            aMetalType.Name      =  theName;
            aMetalType.PatternId =  aPatternId;
            aMetalType.Type      =  'ARR';
             
            if ~isempty(theElectricalLossType);
                aMetalType.ElectricalLossType = theElectricalLossType;
            end
            
            % Append the metal type to the array
            obj.ArrayOfMetalTypes{length(obj.ArrayOfMetalTypes)+1}=aMetalType;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function displayPolygons(obj,theOption)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will display all the polygons along
            % with their values for easy reference.
            %
            % 'short' will display only important stuff
            % 'long' will display everything
            %
            % default is 'short'
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if nargin == 1 || strcmpi(theOption,'short')==1
                
                % Generate a list of metal types
                aListOfTypes=cell(1,length(obj.ArrayOfPolygons));
                for iCounter=1:length(obj.ArrayOfPolygons)
                    if obj.ArrayOfPolygons{iCounter}.MetalType<1
                        aListOfTypes{iCounter}='Lossless';
                    else
                        aListOfTypes{iCounter}=obj.ArrayOfMetalTypes{obj.ArrayOfPolygons{iCounter}.MetalType}.Name;
                    end
                end
                
                fprintf(1,'%-5s %-7s %-15s %-13s %-10s %-10s %-10s %-10s\n',...
                    '#',...
                    'ID',...
                    'Centroid',...
                    'Mean Point',...
                    'Size',...
                    'Type',...
                    'Level',...
                    'Metal Type');
                fprintf(1,'-----------------------------------------------------------------------------------------\n');
                
                for iCounter=1:length(obj.ArrayOfPolygons)
                    fprintf(1,'%-5g %-5g\t(%-5.3g,%5.3g)\t(%-5.3g,%5.3g)\t%-5.3g\t%10s\t%5g%15s\n',...
                        iCounter,...
                        obj.ArrayOfPolygons{iCounter}.DebugId,...
                        obj.ArrayOfPolygons{iCounter}.CentroidXCoordinate,...
                        obj.ArrayOfPolygons{iCounter}.CentroidYCoordinate,...
                        obj.ArrayOfPolygons{iCounter}.MeanXCoordinate,...
                        obj.ArrayOfPolygons{iCounter}.MeanYCoordinate,...
                        obj.ArrayOfPolygons{iCounter}.PolygonSize,...
                        obj.ArrayOfPolygons{iCounter}.Type,...
                        obj.ArrayOfPolygons{iCounter}.MetalizationLevelIndex,...
                        aListOfTypes{iCounter});
                end
            elseif strcmpi(theOption,'long')==1
                
                % Generate a list of metal types
                aListOfTypes=cell(1,length(obj.ArrayOfPolygons));
                for iCounter=1:length(obj.ArrayOfPolygons)
                    if obj.ArrayOfPolygons{iCounter}.MetalType<1
                        aListOfTypes{iCounter}='Lossless';
                    else
                        aListOfTypes{iCounter}=obj.ArrayOfMetalTypes{obj.ArrayOfPolygons{iCounter}.MetalType}.Name;
                    end
                end
                
                fprintf(1,'%-5s %-7s %-15s %-13s %-10s %-10s %-10s \t %-10s \t %-5s \t %-25s %-25s %-25s %-25s %-25s\t\t%-15s %-25s\n',...
                    '#',...
                    'ID',...
                    'Centroid',...
                    'Mean Point',...
                    'Size',...
                    'Type',...
                    'Level',...
                    'Metal Type',...
                    'Fill Type',...
                    'X Min Subsection Size',...
                    'Y Min Subsection Size',...
                    'X Max Subsection Size',...
                    'Y Max Subsection Size',...
                    'Max Length For The Conformal Mesh',...
                    'Edge Mesh',...
                    'Level Connected to (for Vias)');
                fprintf(1,'----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------\n');
                
                for iCounter=1:length(obj.ArrayOfPolygons)
                    fprintf(1,'%-5g %-5g\t(%-5.3g,%5.3g)\t(%-5.3g,%5.3g)\t%-5.3g\t%10s\t%5g\t%15s\t%15s\t%15g\t%25g\t%25g\t%25g\t%25g\t%25g\t%25g\n',...
                        iCounter,...
                        obj.ArrayOfPolygons{iCounter}.DebugId,...
                        obj.ArrayOfPolygons{iCounter}.CentroidXCoordinate,...
                        obj.ArrayOfPolygons{iCounter}.CentroidYCoordinate,...
                        obj.ArrayOfPolygons{iCounter}.MeanXCoordinate,...
                        obj.ArrayOfPolygons{iCounter}.MeanYCoordinate,...
                        obj.ArrayOfPolygons{iCounter}.PolygonSize,...
                        obj.ArrayOfPolygons{iCounter}.Type,...
                        obj.ArrayOfPolygons{iCounter}.MetalizationLevelIndex,...
                        aListOfTypes{iCounter},...
                        obj.ArrayOfPolygons{iCounter}.FillType,...
                        obj.ArrayOfPolygons{iCounter}.XMinimumSubsectionSize,...
                        obj.ArrayOfPolygons{iCounter}.YMinimumSubsectionSize,...
                        obj.ArrayOfPolygons{iCounter}.XMaximumSubsectionSize,...
                        obj.ArrayOfPolygons{iCounter}.YMaximumSubsectionSize,...
                        obj.ArrayOfPolygons{iCounter}.MaximumLengthForTheConformalMeshSubsection,...
                        obj.ArrayOfPolygons{iCounter}.EdgeMesh,...
                        obj.ArrayOfPolygons{iCounter}.LevelTheViaIsConnectedTo);
                end
            else
                error('The option should be either ''short'' or ''long'' ');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function axCellSize=xCellSize(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % return the cell size in the X direction
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            axCellSize=obj.SonnetBox.xCellSize();
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function ayCellSize=yCellSize(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % return the cell size in the X direction
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            ayCellSize=obj.SonnetBox.yCellSize();
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function axBoxSize=xBoxSize(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % return the size of the box in the X direction
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            axBoxSize=obj.SonnetBox.XWidthOfTheBox;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function ayBoxSize=yBoxSize(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % return the size of the box in the Y direction
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            ayBoxSize=obj.SonnetBox.YWidthOfTheBox;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function removeAllDielectricBricks(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Function that removes any dielectric blocks
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Iterate through all polygons and check for dielectric bricks
            aNumberOfPolygons=length(obj.ArrayOfPolygons);
            iCounter=1;
            while iCounter<=aNumberOfPolygons
                if obj.ArrayOfPolygons{iCounter}.isPolygonBrick
                    obj.ArrayOfPolygons(iCounter)=[];
                    aNumberOfPolygons=aNumberOfPolygons-1;
                else
                    iCounter=iCounter+1;
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeBoxSize(obj, theNewXWidth, theNewYWidth)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Function that changes the size of the Sonnet
            % box. This function requires a new set of X and Y Widths
            % Note: This function is the same as changeBoxSizeXY
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.SonnetBox.changeBoxSize(theNewXWidth, theNewYWidth)
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeBoxSizeXY(obj, theNewXWidth, theNewYWidth)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Function that changes the size of the Sonnet
            % box. This function requires a new set of X and Y Widths.
            % Note: This function is the same as changeBoxSize
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.SonnetBox.changeBoxSizeXY(theNewXWidth, theNewYWidth)
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeBoxSizeX(obj, theNewXWidth)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Function that changes the size of the Sonnet
            % box in the X direction. This function
            % requires a new X width.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.SonnetBox.changeBoxSizeX(theNewXWidth)
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeBoxSizeY(obj, theNewYWidth)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Function that changes the size of the Sonnet
            % box in the Y direction. This function
            % requires a new Y width.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.SonnetBox.changeBoxSizeY(theNewYWidth)
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeNumberOfCells(obj, theNewXCellSize, theNewYCellSize)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Function that changes the number of the cells in
            % a Sonnet box.
            %
            % This function requires two inputs:
            % 1) The new number of cells in the X direction
            % 2) The new number of cells in the Y direction
            %
            % Note: This function is the same as changeNumberOfCellsXY
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.SonnetBox.changeNumberOfCells(theNewXCellSize, theNewYCellSize)
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeNumberOfCellsXY(obj, theNewXCellSize, theNewYCellSize)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Function that changes the number of the cells in
            % a Sonnet box.
            %
            % This function requires two inputs:
            % 1) The new number of cells in the X direction
            % 2) The new number of cells in the Y direction
            %
            % Note: This function is the same as changeNumberOfCells
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.SonnetBox.changeNumberOfCellsXY(theNewXCellSize, theNewYCellSize)
        end
                
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeNumberOfCellsX(obj, theNewXCellSize)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Function that changes the number of the cells in
            % a Sonnet box.
            %
            % This function requires two inputs:
            % 1) The new number of cells in the X direction
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.SonnetBox.changeNumberOfCellsX(theNewXCellSize)
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeNumberOfCellsY(obj, theNewYCellSize)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Function that changes the number of the cells in
            % a Sonnet box.
            %
            % This function requires two inputs:
            % 1) The new number of cells in the Y direction
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.SonnetBox.changeNumberOfCellsY(theNewYCellSize)
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeCellSizeUsingNumberOfCells(obj, theNewXCellSize, theNewYCellSize)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Function that changes the cell size in
            % a Sonnet box.
            %
            % This function requires two inputs:
            % 1) The new cell size in the X direction
            % 2) The new cell size in the Y direction
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.SonnetBox.changeNumberOfCells(theNewXCellSize, theNewYCellSize)
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeCellSizeUsingNumberOfCellsXY(obj, theNewXCellSize, theNewYCellSize)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Function that changes the cell size in
            % a Sonnet box.
            %
            % This function requires two inputs:
            % 1) The new cell size in the X direction
            % 2) The new cell size in the Y direction
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.SonnetBox.changeNumberOfCellsXY(theNewXCellSize, theNewYCellSize)
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeCellSizeUsingNumberOfCellsX(obj, theNewXCellSize)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Function that changes the cell size in
            % a Sonnet box.
            %
            % This function requires two inputs:
            % 1) The new cell size in the X direction
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.SonnetBox.changeNumberOfCellsX(theNewXCellSize)
        end        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeCellSizeUsingNumberOfCellsY(obj, theNewYCellSize)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Function that changes the cell size in
            % a Sonnet box.
            %
            % This function requires two inputs:
            % 1) The new cell size in the Y direction
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.SonnetBox.changeNumberOfCellsY(theNewYCellSize)
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeCellSizeUsingBoxSize(obj, theNewXCellSize, theNewYCellSize)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Function that changes the cell size in
            % a Sonnet box.
            %
            % This function requires two inputs:
            % 1) The new cell size in the X direction
            % 2) The new cell size in the Y direction
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.SonnetBox.changeCellSizeUsingUsingBoxSize(theNewXCellSize, theNewYCellSize)
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeCellSizeUsingBoxSizeXY(obj, theNewXCellSize, theNewYCellSize)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Function that changes the cell size in
            % a Sonnet box.
            %
            % This function requires two inputs:
            % 1) The new cell size in the X direction
            % 2) The new cell size in the Y direction
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.SonnetBox.changeCellSizeUsingBoxSizeXY(theNewXCellSize, theNewYCellSize)
        end
                
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeCellSizeUsingBoxSizeX(obj, theNewXCellSize)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Function that changes the cell size in
            % a Sonnet box.
            %
            % This function requires two inputs:
            % 1) The new cell size in the X direction
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.SonnetBox.changeCellSizeUsingBoxSizeX(theNewXCellSize)
        end      
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeCellSizeUsingBoxSizeY(obj, theNewYCellSize)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Function that changes the cell size in
            % a Sonnet box.
            %
            % This function requires two inputs:
            % 1) The new cell size in the Y direction
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.SonnetBox.changeCellSizeUsingBoxSizeY(theNewYCellSize)
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function isDefined=isMetalTypeDefined(obj, theName)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Function will search the project for a 
            %   defined metal type based on the name.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            isDefined=false;
            
            for iCounter=1:length(obj.ArrayOfMetalTypes)
                if strcmpi(obj.ArrayOfMetalTypes{iCounter}.Name,theName)==1
                    isDefined=true;
                    return
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aMetal=getMetalType(obj, theName)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Function will search the project for a 
            %   defined metal type based on the name.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            for iCounter=1:length(obj.ArrayOfMetalTypes)
                if strcmpi(obj.ArrayOfMetalTypes{iCounter}.Name,theName)==1
                    aMetal=obj.ArrayOfMetalTypes{iCounter};
                    return
                end
            end
            
            error('Metal type is not defined');
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function modifyVariableValue(obj, theString, theValue)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %   Project.modifyVariableValue(Name,Value) Modifies the
            %   value for a geometry dimension variable and any
            %   attached parameters.
            %
            %   If the user supplies the name for an unknown dimension
            %   parameter then no action will take place. The name of
            %   the variable is case insensitive.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Modify the variable
            for iCounter=1:length(obj.ArrayOfVariables)
                if strcmpi(theString,obj.ArrayOfVariables{iCounter}.VariableName)==1
                    obj.ArrayOfVariables{iCounter}.Value=theValue;
                end
            end
            
            % Modify the matching parameter (if one exists)
            for iCounter=1:length(obj.ArrayOfParameters)
                % If the varaible used to a parameter is changed
                % then update the parameter
                if strcmpi(theString,obj.ArrayOfParameters{iCounter}.Parname)==1
                    obj.ArrayOfParameters{iCounter}.changeValue(obj.ArrayOfVariables);
                                        
                    % If the parameter has an equation then update the
                    % parameter because the value for this parameter
                    % may depend on the changed variable value.
                    if ~isempty(obj.ArrayOfParameters{iCounter}.Equation)
                        obj.ArrayOfParameters{iCounter}.changeValue(obj.ArrayOfVariables);
                    end
                end                
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function defineVariable(obj, theString, theValue, theType, theDescription)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % defineVariable defines a new geometry variable.
            %   If the variable already exists replace its
            %   value will be replaced.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % If we recieved no description then 
            % initialize it to empty matrix
            if nargin == 4
                theDescription=[];
            end
            
            % If the variable already exists replace its value
            iCounter=1;
            while iCounter<=length(obj.ArrayOfVariables)
                if strcmpi(theString,obj.ArrayOfVariables{iCounter}.VariableName)==1
                    obj.ArrayOfVariables(iCounter)=[];
                else
                    iCounter=iCounter+1;
                end
            end
            
            % Add a new entry to the end of the array of variables
            aNewVariable=SonnetGeometryVariable();
            aNewVariable.VariableName=theString;
            if nargin == 3
                aNewVariable.UnitType='None';
            else
                aNewVariable.UnitType=theType;
            end
            aNewVariable.Value=theValue;
            aNewVariable.Description=theDescription;
            obj.ArrayOfVariables{length(obj.ArrayOfVariables)+1}=aNewVariable;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aValue=getVariableValue(obj, theString)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % getVariableValue returns the value of a variable
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            aValue=[];
            for iCounter=1:length(obj.ArrayOfVariables)
                if strcmpi(theString,obj.ArrayOfVariables{iCounter}.VariableName)==1
                    if ~isnan(str2double(obj.ArrayOfVariables{iCounter}.Value))
                        aValue=str2double(obj.ArrayOfVariables{iCounter}.Value);
                    else
                        aValue=obj.ArrayOfVariables{iCounter}.Value;
                    end
                    return
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeTopCover(obj,theType)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Chang the material used for the top cover
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            theType=strrep(theType,'"','');
            theType=strtrim(upper(theType));
            aCover=obj.TopCoverMetal;
            
            switch theType
                case 'LOSS LESS'
                    aCover.initialize();
                    
                case 'LOSSLESS'
                    aCover.initialize();
                    
                case 'FREE SPACE'
                    aCover.initialize();
                    aCover.Name='"Free Space"';
                    aCover.Type='FREESPACE';
                    
                case 'FREESPACE'
                    aCover.initialize();
                    aCover.Name='"Free Space"';
                    aCover.Type='FREESPACE';
                    
                case 'WG LOAD'
                    aCover.initialize();
                    aCover.Name='"WG Load"';
                    aCover.Type='WGLOAD';
                    
                case 'WGLOAD'
                    aCover.initialize();
                    aCover.Name='"WG Load"';
                    aCover.Type='WGLOAD';
                    
                otherwise
                    % Check if the metal type exists; if so then copy its
                    % values. If the metal type is not defined then display
                    % an error.
                    for iCounter=1:length(obj.ArrayOfMetalTypes)
                        aMetal=obj.ArrayOfMetalTypes{iCounter};
                        if strcmpi(aMetal.Name,theType)==1
                            aCover.Name=['"' aMetal.Name '"'];
                            aCover.PatternId=aMetal.PatternId;
                            aCover.Conductivity=aMetal.Conductivity;
                            aCover.CurrentRatio=aMetal.CurrentRatio;
                            aCover.Thickness=aMetal.Thickness;
                            aCover.Resistance=aMetal.Resistance;
                            aCover.SkinCoefficient=aMetal.SkinCoefficient;
                            aCover.Reactance=aMetal.Reactance;
                            aCover.KineticInductance=aMetal.KineticInductance;
                            
                            % Use an appropriate type for the metal
                            % based on the custom metal types.
                            switch aMetal.Type
                                case 'Normal'
                                    aCover.Type='NOR';
                                case 'Resistor'
                                    aCover.Type='RES';
                                case 'Natural'
                                    aCover.Type='NAT';
                                case 'General'
                                    aCover.Type='SUP';
                                case 'Sense'
                                    aCover.Type='SEN';
                                case 'Thick'
                                    aCover.Type='TMM';
                                case 'Volume'
                                    aCover.Type='VOL';
                                case 'Surface'
                                    aCover.Type='SFC';
                                case 'Array'
                                    aCover.Type='ARR';
                                case 'Rough'
                                    aCover.Type='ROG';
                                otherwise
                                    aCover.Type=aMetal.Type;
                            end
                            
                            return
                        end
                    end
                    
                    error(['No metal type named "' theType '" was found in the project.'])
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeBottomCover(obj,theType)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Change the material used for the bottom cover
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            theType=strrep(theType,'"','');
            theType=strtrim(upper(theType));
            aCover=obj.BottomCoverMetal;
            
            switch theType
                case 'LOSS LESS'
                    aCover.initialize();
                    
                case 'LOSSLESS'
                    aCover.initialize();
                    
                case 'FREE SPACE'
                    aCover.initialize();
                    aCover.Name='"Free Space"';
                    aCover.Type='FREESPACE';
                    
                case 'FREESPACE'
                    aCover.initialize();
                    aCover.Name='"Free Space"';
                    aCover.Type='FREESPACE';
                    
                case 'WG LOAD'
                    aCover.initialize();
                    aCover.Name='"WG Load"';
                    aCover.Type='WGLOAD';
                    
                case 'WGLOAD'
                    aCover.initialize();
                    aCover.Name='"WG Load"';
                    aCover.Type='WGLOAD';
                    
                otherwise
                    % Check if the metal type exists; if so then copy its
                    % values. If the metal type is not defined then display
                    % an error.
                    for iCounter=1:length(obj.ArrayOfMetalTypes)
                        aMetal=obj.ArrayOfMetalTypes{iCounter};
                        if strcmpi(aMetal.Name,theType)==1
                            aCover.Name=['"' aMetal.Name '"'];
                            aCover.PatternId=aMetal.PatternId;
                            aCover.Conductivity=aMetal.Conductivity;
                            aCover.CurrentRatio=aMetal.CurrentRatio;
                            aCover.Thickness=aMetal.Thickness;
                            aCover.Resistance=aMetal.Resistance;
                            aCover.SkinCoefficient=aMetal.SkinCoefficient;
                            aCover.Reactance=aMetal.Reactance;
                            aCover.KineticInductance=aMetal.KineticInductance;
                            
                            % Use an appropriate type for the metal
                            % based on the custom metal types.
                            switch aMetal.Type
                                case 'Normal'
                                    aCover.Type='NOR';
                                case 'Resistor'
                                    aCover.Type='RES';
                                case 'Natural'
                                    aCover.Type='NAT';
                                case 'General'
                                    aCover.Type='SUP';
                                case 'Sense'
                                    aCover.Type='SEN';
                                case 'Thick'
                                    aCover.Type='TMM';
                                case 'Volume'
                                    aCover.Type='VOL';
                                case 'Surface'
                                    aCover.Type='SFC';
                                case 'Array'
                                    aCover.Type='ARR';
                                case 'Rough'
                                    aCover.Type='ROG';
                                otherwise
                                    aCover.Type=aMetal.Type;
                            end
                            
                            return
                        end
                    end
                    
                    error(['No metal type named "' theType '" was found in the project.'])
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addTechLayer(obj, theType, theName, theDXFName, theGDSStream, ...
                 theGDSData, theGBRFilename, theMetalizationLevelIndex, theMetalizationToLevelIndex)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Add Technology Layer
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            aTechLayer = SonnetGeometryTechLayer();
            
            aTechLayer.Type             = theType;
            aTechLayer.Name             = theName;
            aTechLayer.DXFLayerName     = theDXFName;
            aTechLayer.GDSStream        = theGDSStream;
            aTechLayer.GDSData          = theGDSData;
            aTechLayer.GBRFilename      = theGBRFilename;
            aTechLayer.Polygon          = SonnetGeometryPolygon();        
            
            aTechLayer.Polygon.Type=theType;
            aTechLayer.Polygon.MetalizationLevelIndex=theMetalizationLevelIndex;
            
            aTechLayer.Polygon.MetalType=-1;
            aTechLayer.Polygon.FillType='N';
            aTechLayer.Polygon.DebugId=0;
            aTechLayer.Polygon.XMinimumSubsectionSize=1;
            aTechLayer.Polygon.YMinimumSubsectionSize=1;
            aTechLayer.Polygon.XMaximumSubsectionSize=100;
            aTechLayer.Polygon.YMaximumSubsectionSize=100;
            aTechLayer.Polygon.MaximumLengthForTheConformalMeshSubsection=0;
            aTechLayer.Polygon.EdgeMesh='Y';
            
            if strcmpi(theType, 'VIA')
               aTechLayer.Polygon.Type = 'VIA POLYGON';
               aTechLayer.Polygon.Meshing = 'RING';
               aTechLayer.Polygon.isCapped=false;
               aTechLayer.Polygon.LevelTheViaIsConnectedTo=theMetalizationToLevelIndex;
            else
                if strcmpi(theType, 'BRICK')
                    aTechLayer.Polygon.MetalType=0;
                    aTechLayer.Polygon.Type = 'BRI POLY';
                else                
                    aTechLayer.Polygon.CanWriteType=false;
                end                                          
            end 
            % Append the tech layer to the array
            obj.ArrayOfTechLayers{length(obj.ArrayOfTechLayers)+1}=aTechLayer;            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aValue=getAllPolygonsBySize(obj, theSize)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Returns a list of polygons the is equal to theSsize
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            aArrayOfPolygons = {};
            for iCounter=1:length(obj.ArrayOfPolygons)                
                if(obj.ArrayOfPolygons{iCounter}.PolygonSize == theSize)
                    aArrayOfPolygons{length(aArrayOfPolygons)+1}= obj.ArrayOfPolygons{iCounter};
                end            
            end
            
            aValue = aArrayOfPolygons;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aValue=getAllPolygonsByLevel(obj, theLevel)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Returns a list of polygons the is equal to theLevel
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            aArrayOfPolygons = {};
            for iCounter=1:length(obj.ArrayOfPolygons)                
                if(obj.ArrayOfPolygons{iCounter}.MetalizationLevelIndex == theLevel)
                    aArrayOfPolygons{length(aArrayOfPolygons)+1}= obj.ArrayOfPolygons{iCounter};
                end        
            end
            
            aValue = aArrayOfPolygons;
        end
        
    end
end
%#ok<*AGROW>
%#ok<*FXSET>