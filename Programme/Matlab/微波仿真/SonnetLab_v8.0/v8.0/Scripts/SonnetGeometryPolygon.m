classdef SonnetGeometryPolygon < handle
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This class defines the values for a polygon. Types of polygons
    % include metals, dielectric bricks and rectangular/circular vias.
    % Polygons are defined in the Geometry block.
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
        
        
        Type
        MetalizationLevelIndex
        MetalType
        FillType
        DebugId
        XMinimumSubsectionSize
        YMinimumSubsectionSize
        XMaximumSubsectionSize
        YMaximumSubsectionSize
        MaximumLengthForTheConformalMeshSubsection
        EdgeMesh
        LevelTheViaIsConnectedTo
        Label
        Label2
        
        XCoordinateValues
        YCoordinateValues
        
        Meshing
        isCapped
        CanWriteType
        
        hasTechLayer
        TechLayerName
        isInherit                                
    end
    
    properties (Dependent = true)
        
        NumberOfVerticies
        CentroidXCoordinate
        CentroidYCoordinate
        PolygonSize
        MeanXCoordinate
        MeanYCoordinate
        BoundingBox
        
    end
    
    properties (Access = private)
        TechLayerPoly
    end
    
    methods
             
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = SonnetGeometryPolygon(varargin)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % define the constructor for a polygon.
            %     the constructor will be passed the file ID from the
            %     SONNET GEO object constructor.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                 
            if nargin > 1
                obj.TechLayerPoly = varargin{2};
            else
                obj.TechLayerPoly = false;
            end
            
            obj.CanWriteType=true;
            obj.hasTechLayer=false;
             
            if nargin >= 1
            
                theFid = varargin{1};
                
                % Initialize the local variables that will hold the
                % properties
                aLevelTheViaIsConnectedTo=[];
                aLabel='';
                aLabel2='';
                aType='';
                aMeshing=[];
                aCovers=[];
                
                % Read the first line for the polygon.
                % this may either be the type of the
                % parameter line.
                aTempString=fgetl(theFid);
                
                if ~obj.TechLayerPoly                                                  
                    % If the type exists then store it and read the next line
                    if ~ismember(aTempString(1),'0123456789-')
                        aType=aTempString;
                        aTempString=fgetl(theFid);
                    end
                else
                    aType = varargin{3};
                    
                end
                % Read in the first line of values
                try
                    aResult=sscanf(aTempString,' %d %d %d %c %d %d %d %d %d %f %d %d %c');
                    aMetalizationLevelIndex=aResult(1);
                    aNumberOfVerticies=aResult(2);
                    aMetalType=aResult(3);
                    aFillType=char(aResult(4));
                    aDebugId=aResult(5);
                    aXMinimumSubsectionSize=aResult(6);
                    aYMinimumSubsectionSize=aResult(7);
                    aXMaximumSubsectionSize=aResult(8);
                    aYMaximumSubsectionSize=aResult(9);
                    aMaximumLengthForTheConformalMeshSubsection=aResult(10);
                    aEdgeMesh=char(aResult(13));
                catch exception
                    disp(exception);
                end
                
                % Make the fill type be a more recognizable string
                if strcmpi(aFillType,'N')
                    aFillType='Staircase';
                elseif strcmpi(aFillType,'T')
                    aFillType='Diagonal';
                elseif strcmpi(aFillType,'V')
                    aFillType='Conformal';
                end
                
                % Preallocate the variables
                aXCoordinateValues=cell(1,aNumberOfVerticies);
                aYCoordinateValues=cell(1,aNumberOfVerticies);
                
                % Counter to keep track of the number of data points we
                % have, each one has an X and Y value.
                iNumberOfValues=1;
                                
                % We want to check if the next line is a LevelTheViaIsConnectedTo
                % line which is for VIAs.  We also want to look for any hidden
                % labels. These are both optional lines.
                aTempString=fgetl(theFid);
                
                if ~isnan(strfind(aTempString,'END'))                   
                                                   
                % If this line is a via's 'toLevel' line then store the
                % value and check if there is a hidden label.
                elseif ~isnan(strfind(aTempString,'TOLEVEL '))
                    % If this is a version 13 project there will
                    % be via fill information present on the line.
                    % one of the via fill values will be either
                    % "COVERS" or "NOCOVERS". We will search for
                    % those strings to see if we also need to store
                    % via fill information.
                    if ~isnan(strfind(aTempString,'COVERS'))
                        
                        [~, ~, ~, aNextIndex]=sscanf(aTempString,'%s',1); % Read TOLEVEL
                        aTempString=aTempString(aNextIndex:length(aTempString));
                        [aLevelTheViaIsConnectedTo, ~, ~, aNextIndex]=sscanf(aTempString,'%s',1);
                        
                        aTempString=aTempString(aNextIndex:length(aTempString));
                        [aMeshing, ~, ~, ~]=sscanf(aTempString,'%s',1);
                                                
                        if ~isnan(strfind(aTempString,'NOCOVERS'))
                            aCovers=false;
                        elseif ~isnan(strfind(aTempString,'COVERS'))
                            aCovers=true;
                        end
                    else
                        % Store the value we had read before; this may be a
                        % string ('GND') or a number ('0')
                        aLevelTheViaIsConnectedTo=strrep(aTempString,'TOLEVEL ','');
                    end
                                        
                    % If the level is a number then convert it into a number
                    if ~isnan(str2double(aLevelTheViaIsConnectedTo))
                        aLevelTheViaIsConnectedTo=str2double(aLevelTheViaIsConnectedTo);
                    end
                                                            
                    % Read the next line; we want to check if it is a
                    % hidden label. If it isnt then it is an (X,Y)
                    % coordinate pair.
                    aTempString=fgetl(theFid);
                    
                    % Check to see if techlayer
                    if ~isnan(strfind(aTempString,'TLAYNAM'))                        
                        obj.hasTechLayer=true;

                        [~, aRemain]=strtok(aTempString);
                        [obj.TechLayerName, aRemain]=strtok(aRemain);
                        
                         if numel(strfind(obj.TechLayerName, '"')) == 1
                            while 1
                                [aNxtToken, aRemain]=strtok(aRemain);
                                obj.TechLayerName = [obj.TechLayerName ' ' aNxtToken];

                                if numel(strfind(obj.TechLayerName, '"')) == 2 
                                    break;
                                end
                            end                            
                        end
                        
                        if numel(strfind(obj.TechLayerName, '"')) == 2
                            obj.TechLayerName=obj.TechLayerName(2:end);
                            obj.TechLayerName=obj.TechLayerName(1:(numel(obj.TechLayerName) -1));
                        end
    
                        aToken=strtok(aRemain);
 
                        if strcmpi(aToken, 'INH')
                            obj.isInherit=true;
                        elseif strcmpi(aToken, 'NOH')
                            obj.isInherit=false;
                        end
                        
                        aTempString=fgetl(theFid);
                    end
                    
                    if ~ismember(aTempString(1),'0123456789-')
                        aLabel=aTempString;
                                                
                        % Check for a second label
                        aTempString=fgetl(theFid);
                        
                        if ~ismember(aTempString(1),'0123456789-')
                            aLabel2=aTempString;
                        else
                            % Increment the counter for the number of
                            % coordinate pairs we have read.
                            iNumberOfValues=iNumberOfValues+1;
                            
                            % Store the first X and Y coordinate pair
                            aResult=sscanf(aTempString,'%f %f');
                            aXCoordinateValues{1}=aResult(1);
                            aYCoordinateValues{1}=aResult(2);
                        end
                        
                    else
                        % Increment the counter for the number of
                        % coordinate pairs we have read.
                        iNumberOfValues=iNumberOfValues+1;
                        
                        % Store the first X and Y coordinate pair
                        aResult=sscanf(aTempString,'%f %f');
                        aXCoordinateValues{1}=aResult(1);
                        aYCoordinateValues{1}=aResult(2);
                    end
                else
                    % Check to see if techlayer
                    if ~isnan(strfind(aTempString,'TLAYNAM'))                        
                        obj.hasTechLayer=true;
                        
                        [~, aRemain]=strtok(aTempString);
                        
                        % obj.TechLayerName=SonnetStringReadFormat(theFid);
                        
                        [obj.TechLayerName, aRemain]=strtok(aRemain);
                        
                        if numel(strfind(obj.TechLayerName, '"')) == 1
                            while 1
                                [aNxtToken, aRemain]=strtok(aRemain);
                                obj.TechLayerName = [obj.TechLayerName ' ' aNxtToken];

                                if numel(strfind(obj.TechLayerName, '"')) == 2 
                                    break;
                                end
                            end                            
                        end
                        
                        if numel(strfind(obj.TechLayerName, '"')) == 2
                            obj.TechLayerName=obj.TechLayerName(2:end);
                            obj.TechLayerName=obj.TechLayerName(1:(numel(obj.TechLayerName) -1));
                        end                        
    
                        aToken=strtok(aRemain);
 
                        if strcmpi(aToken, 'INH')
                            obj.isInherit=true;
                        elseif strcmpi(aToken, 'NOH')
                            obj.isInherit=false;
                        end
                        
                        aTempString=fgetl(theFid);
                    end
                    
                    % If this line is a hidden label line then store the
                    % value. Otherwise store it as an (X,Y) coordinate pair
                    if ~ismember(aTempString(1),'0123456789-')
                        aLabel=aTempString;
                        
                        % Check for a second label
                        aTempString=fgetl(theFid);
                        
                        if ~ismember(aTempString(1),'0123456789-')
                            aLabel2=aTempString;
                        else
                            % Increment the counter for the number of
                            % coordinate pairs we have read.
                            iNumberOfValues=iNumberOfValues+1;
                            
                            % Store the first X and Y coordinate pair
                            aResult=sscanf(aTempString,'%f %f');
                            aXCoordinateValues{1}=aResult(1);
                            aYCoordinateValues{1}=aResult(2);
                        end
                        
                    else
                        % Increment the counter for the number of
                        % coordinate pairs we have read.
                        iNumberOfValues=iNumberOfValues+1;
                        
                        % Store the first X and Y coordinate pair
                        aResult=sscanf(aTempString,'%f %f');
                        aXCoordinateValues{1}=aResult(1);
                        aYCoordinateValues{1}=aResult(2);
                    end
                end
                
                % Read the values from the disk
                aResult=fscanf(theFid,'%f',(aNumberOfVerticies-iNumberOfValues+1)*2);
                
                % Read all the coordinate values
                try
                    iResultCounter=1;
                    for iCounter=iNumberOfValues:aNumberOfVerticies
                        aXCoordinateValues{iNumberOfValues}=aResult(iResultCounter);
                        aYCoordinateValues{iNumberOfValues}=aResult(iResultCounter+1);
                        iResultCounter=iResultCounter+2;
                        iNumberOfValues=iNumberOfValues+1;
                    end
                catch e
                    disp(e)
                end
                
                % Assign the arrays to the properties
                obj.Type=aType;
                obj.MetalizationLevelIndex=aMetalizationLevelIndex;
                obj.MetalType=aMetalType;
                obj.FillType=aFillType;
                obj.DebugId=aDebugId;
                obj.XMinimumSubsectionSize=aXMinimumSubsectionSize;
                obj.YMinimumSubsectionSize=aYMinimumSubsectionSize;
                obj.XMaximumSubsectionSize=aXMaximumSubsectionSize;
                obj.YMaximumSubsectionSize=aYMaximumSubsectionSize;
                obj.MaximumLengthForTheConformalMeshSubsection=aMaximumLengthForTheConformalMeshSubsection;
                obj.EdgeMesh=aEdgeMesh;
                obj.LevelTheViaIsConnectedTo=aLevelTheViaIsConnectedTo;
                
                if strcmp(aLabel, aLabel2)
                    if ~strcmp(aLabel, 'END')                 
                        obj.Label=aLabel;
                        obj.Label2=aLabel2;
                    end                    
                else
                    obj.Label=aLabel;
                    obj.Label2=aLabel2;
                end                
              
                obj.Meshing=aMeshing;
                obj.isCapped=aCovers;
                obj.XCoordinateValues=aXCoordinateValues;
                obj.YCoordinateValues=aYCoordinateValues;
                
                
                
                % added this so the class can be used with techlayers
                if ~isempty(obj.TechLayerPoly)
                    if obj.TechLayerPoly == true 
                        return;                    
                    end
                end
                
                % Dump the the 'END' line
                fgetl(theFid);
                fgetl(theFid);                               
            else
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % we come here when we didn't recieve a file ID as an argument
                % which means that we are going to create a default polygon with
                % default values by calling the function's initialize method.
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                initialize(obj);
                
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function initialize(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function initializes the dielectric layer properties to some default
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
            
            obj.Type='';
            obj.CanWriteType=true;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aNewObject=clone(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function builds a deep copy of this object
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            aNewObject=SonnetGeometryPolygon();
            SonnetClone(obj,aNewObject);
            
            % Change the debugId for the new polygon.
            % although we do not know what an availible
            % debugId is for the polygon we can choose
            % a random one and hope it does not intersect
            % with any existing ones.
            % % %             aNewObject.DebugId=randi((obj.DebugId+10)*100,1);
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addTechLayer(obj, theTechLayer, theIsInherit)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % adds a techlayer to the polygon
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if ~isa(theTechLayer, 'SonnetGeometryTechLayer');                
                error('addTechLayer: Invalid object type found');                                
            end
            
            if isempty(obj.Type)
                if ~strcmpi('METAL', theTechLayer.Type)                                  
                    error('addTechLayer: Invalid type found');              
                end
            else
                if strcmpi(obj.Type, 'VIA')
                    if ~strcmpi(theTechLayer.Type, 'VIA POLYGON')
                        error('addTechLayer: Invalid type found');
                    end
                elseif strcmpi(obj.Type, 'BRICK')
                    if ~strcmpi(theTechLayer.Type, 'BRI POLY')
                        error('addTechLayer: Invalid type found');
                    end
                end
            end

            if ~isa(theIsInherit, 'logical')
                error('addTechLayer: Invalid parameter type. Expected "true" or "false".');                
            end
            
            obj.hasTechLayer=true;
            obj.TechLayerName = theTechLayer.Name;
            obj.isInherit=theIsInherit;            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get/Set functions: We want to change the value of
        % the polygon properties when the coordinates change.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function value = get.NumberOfVerticies(obj)
            value=computeNumberOfPoints(obj);
        end
        function value = get.CentroidXCoordinate(obj)
            value=computeCentroidX(obj);
        end
        function value = get.CentroidYCoordinate(obj)
            value=computeCentroidY(obj);
        end
        function value = get.PolygonSize(obj)
            value=computeRelativeSize(obj);
        end
        function value = get.MeanXCoordinate(obj)
            value=computeMeanPointX(obj);
        end
        function value = get.MeanYCoordinate(obj)
            value=computeMeanPointY(obj);
        end
        function value = get.BoundingBox(obj)
            aX = cell2mat(obj.XCoordinateValues);
            aY = cell2mat(obj.YCoordinateValues);
            
            aBBox.Start.X = min(aX);
            aBBox.Start.Y = min(aY);            
            aBBox.End.X = max(aX);
            aBBox.End.Y = max(aY);
            
            value=aBBox; %{xMin yMin xMax yMax};
        end
        function set.NumberOfVerticies(~,~) 
            warning 'NumberOfVerticies can not be directly changed. You may change the coordinates for the polygon (XCoordinateValues and YCoordinateValues)' %#ok<*WNTAG>
        end
        function set.CentroidXCoordinate(~,~) 
            warning 'CentroidXCoordinate can not be directly changed. You may change the coordinates for the polygon (XCoordinateValues and YCoordinateValues)'
        end
        function set.CentroidYCoordinate(~,~) 
            warning 'CentroidYCoordinate can not be directly changed. You may change the coordinates for the polygon (XCoordinateValues and YCoordinateValues)'
        end
        function set.PolygonSize(~,~) 
            warning 'PolygonSize can not be directly changed. You may change the coordinates for the polygon (XCoordinateValues and YCoordinateValues)'
        end
        function set.MeanXCoordinate(~,~) 
            warning 'MeanXCoordinate can not be directly changed. You may change the coordinates for the polygon (XCoordinateValues and YCoordinateValues)'
        end
        function set.MeanYCoordinate(~,~) 
            warning 'MeanYCoordinate can not be directly changed. You may change the coordinates for the polygon (XCoordinateValues and YCoordinateValues)'
        end
        function set.BoundingBox(~,~) 
            warning 'BoundingBox can not be directly changed. You may change the points in the polygon (XCoordinateValues and YCoordinateValues)'
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
            
            aSignature = sprintf('\n');
            
            if obj.CanWriteType            
                if ~isempty(obj.Type)
                    aSignature = [aSignature sprintf('%s\n',obj.Type)];
                end            
            end
            
            if ~isempty(obj.MetalizationLevelIndex)
                aSignature = [aSignature sprintf('%d',obj.MetalizationLevelIndex)];
            end
            
            if ~isempty(obj.NumberOfVerticies)
                aSignature = [aSignature sprintf(' %d',obj.NumberOfVerticies)];
            end
            
            if ~isempty(obj.MetalType)
                aSignature = [aSignature sprintf(' %d',obj.MetalType)];
            end
            
            if ~isempty(obj.FillType)
                if strcmpi(obj.FillType,'Staircase')
                    aSignature = [aSignature ' N'];
                elseif strcmpi(obj.FillType,'Diagonal')
                    aSignature = [aSignature ' T'];
                elseif strcmpi(obj.FillType,'Conformal')
                    aSignature = [aSignature ' V'];
                else
                    aSignature = [aSignature sprintf(' %s',obj.FillType)];
                end
            end
            
            if ~isempty(obj.DebugId)
                aSignature = [aSignature sprintf(' %d',obj.DebugId)];
            end
            
            if ~isempty(obj.XMinimumSubsectionSize)
                aSignature = [aSignature sprintf(' %d',obj.XMinimumSubsectionSize)];
            end
            
            if ~isempty(obj.YMinimumSubsectionSize)
                aSignature = [aSignature sprintf(' %d',obj.YMinimumSubsectionSize)];
            end
            
            if ~isempty(obj.XMaximumSubsectionSize)
                aSignature = [aSignature sprintf(' %d',obj.XMaximumSubsectionSize)];
            end
            
            if ~isempty(obj.YMaximumSubsectionSize)
                aSignature = [aSignature sprintf(' %d',obj.YMaximumSubsectionSize)];
            end
            
            if ~isempty(obj.MaximumLengthForTheConformalMeshSubsection)
                aSignature = [aSignature sprintf(' %.15g',obj.MaximumLengthForTheConformalMeshSubsection)];
            end
            
            % Reserved Keywords
            aSignature = [aSignature ' 0 0'];
            
            if ~isempty(obj.EdgeMesh)
                aSignature = [aSignature sprintf(' %s',obj.EdgeMesh)];
            end
            
            aSignature = [aSignature sprintf('\n')];
                        
            if ~isempty(obj.LevelTheViaIsConnectedTo) && obj.isPolygonVia()
                if theVersion >= 13
                    if isa(obj.LevelTheViaIsConnectedTo,'char')
                        aSignature = [aSignature sprintf('TOLEVEL %s ',obj.LevelTheViaIsConnectedTo)];
                    else
                        aSignature = [aSignature sprintf('TOLEVEL %d ',obj.LevelTheViaIsConnectedTo)];
                    end
                    if isa(obj.Meshing,'char')
                        aSignature = [aSignature sprintf('%s ',obj.Meshing)];
                    else
                        aSignature = [aSignature sprintf('%d ',obj.Meshing)];
                    end
                    if obj.isCapped
                        aSignature = [aSignature sprintf('COVERS\n')];
                    else
                        aSignature = [aSignature sprintf('NOCOVERS\n')];
                    end
                else
                    if isa(obj.LevelTheViaIsConnectedTo,'char')
                        aSignature = [aSignature sprintf('TOLEVEL %s\n',obj.LevelTheViaIsConnectedTo)];
                    else
                        aSignature = [aSignature sprintf('TOLEVEL %d\n',obj.LevelTheViaIsConnectedTo)];
                    end
                end
            end
            
            if obj.hasTechLayer
                if obj.isInherit
                    aSignature = [aSignature sprintf('TLAYNAM %s INH\n',SonnetStringWriteFormat(obj.TechLayerName))];
                else
                    aSignature = [aSignature sprintf('TLAYNAM %s NOH\n',SonnetStringWriteFormat(obj.TechLayerName))];
                end
            end
            
            if ~isempty(obj.Label)
                aSignature = [aSignature sprintf('%s\n',obj.Label)];
            end
            
            if ~isempty(obj.Label2)
                aSignature = [aSignature sprintf('%s\n',obj.Label2)];
            end
            
            for iCounter= 1:length(obj.XCoordinateValues)
                aSignature = [aSignature sprintf('%.15g',obj.XCoordinateValues{iCounter}) ...
                    sprintf(' %.15g\n',obj.YCoordinateValues{iCounter})]; %#ok<AGROW>
            end
            
            aSignature = [aSignature sprintf('END')];
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function XCoordinate=computeCentroidX(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function computes the centroid of the polygon
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            aTempXArray=cell2mat(obj.XCoordinateValues);
            XCoordinate=computeXWidth(obj)/2 + min(aTempXArray);
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function YCoordinate=computeCentroidY(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function computes the centroid of the polygon
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            aTempYArray=cell2mat(obj.YCoordinateValues);
            YCoordinate=computeYWidth(obj)/2 + min(aTempYArray);
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function theSize=computeRelativeSize(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function computes the size of the polygon
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            theSize=computeXWidth(obj)+computeYWidth(obj);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function theWidth=computeXWidth(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function computes the width in the X
            % direction for the polygon.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            aTempArray=cell2mat(obj.XCoordinateValues);
            theWidth=max(aTempArray)-min(aTempArray);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function theWidth=computeYWidth(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function computes the width in the Y
            % direction for the polygon.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            aTempArray=cell2mat(obj.YCoordinateValues);
            theWidth=max(aTempArray)-min(aTempArray);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aNum=computeNumberOfPoints(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function returns how many points this
            % polygon has.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            aNum=length(obj.XCoordinateValues);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function XCoordinate=computeMeanPointX(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function computes the mean point of the polygon.
            % This is the average of the x values and y values.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            aTempXArray=cell2mat(obj.XCoordinateValues);
            XCoordinate=mean(aTempXArray);
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function YCoordinate=computeMeanPointY(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function computes the mean point of the polygon.
            % This is the average of the x values and y values.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            aTempYArray=cell2mat(obj.YCoordinateValues);
            YCoordinate=mean(aTempYArray);
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function flipPolygonX(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Flip the polygon over its X axis.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            aCenter=obj.CentroidXCoordinate;
            for iCounter=1:length(obj.XCoordinateValues)
                if obj.XCoordinateValues{iCounter} < aCenter
                    aDistance=aCenter-obj.XCoordinateValues{iCounter};
                    obj.XCoordinateValues{iCounter}=aCenter+aDistance;
                else
                    aDistance=obj.XCoordinateValues{iCounter}-aCenter;
                    obj.XCoordinateValues{iCounter}=aCenter-aDistance;
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function flipPolygonY(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Flip the polygon over its Y axis.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            aCenter=obj.CentroidYCoordinate;
            for iCounter=1:length(obj.YCoordinateValues)
                if obj.YCoordinateValues{iCounter} < aCenter
                    aDistance=aCenter-obj.YCoordinateValues{iCounter};
                    obj.YCoordinateValues{iCounter}=aCenter+aDistance;
                else
                    aDistance=obj.YCoordinateValues{iCounter}-aCenter;
                    obj.YCoordinateValues{iCounter}=aCenter-aDistance;
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function snapPolygonToGrid(obj,theAxis,CellSizeXDimension,CellSizeYDimension)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will call the appropriate snap method
            % depending on the provided input to either snap to
            % the X axis, the Y axis or both. This snaps only
            % a single polygon to the grid.
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
                snapPolygonToGridXY(obj);
                
            else
                if strcmp(theAxis,'X')==1 || strcmp(theAxis,'x')==1
                    snapPolygonToGridX(obj,CellSizeXDimension);
                elseif strcmp(theAxis,'Y')==1 || strcmp(theAxis,'y')==1
                    snapPolygonToGridY(obj,CellSizeYDimension);
                else
                    snapPolygonToGridXY(obj,CellSizeXDimension,CellSizeYDimension)
                end
                
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function snapPolygonToGridX(obj,CellSizeXDimension)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will snap all the polygons to gridlines
            % in the X direction.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if nargin == 2
                
                % Loop for all of the points in the polygon
                for jCounter=1:length(obj.XCoordinateValues)
                    
                    aNumberOfFullCellsX=floor(obj.XCoordinateValues{jCounter}/CellSizeXDimension); % Store how many boxes are to the left of the x value and how many boxes are below the y value.
                    
                    aLeftOverX=mod(obj.XCoordinateValues{jCounter},CellSizeXDimension); % Mod the X coordinate by the size of a grid box in the X direction
                    
                    if aLeftOverX >= .5*CellSizeXDimension     % If the result is closer to the next gridline then snap to that otherwise lose the leftover
                        aNumberOfFullCellsX=aNumberOfFullCellsX+1;
                    end
                    
                    obj.XCoordinateValues{jCounter}=CellSizeXDimension*aNumberOfFullCellsX; % Add the values to recieve the new location of the box relative to the grid.
                    
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Add the first value onto the end of the list of points to make
                % sure that the polygon is geometrically closed. Even if we already
                % had a point there it is fine since we will be removing duplicate
                % points.
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                obj.XCoordinateValues{jCounter+1}=obj.XCoordinateValues{1};
                obj.YCoordinateValues{jCounter+1}=obj.YCoordinateValues{1};
                
                removeDuplicatePoints(obj); % remove the duplicate points from the polygon
                
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function snapPolygonToGridY(obj,CellSizeYDimension)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will snap all the polygons to gridlines
            % in the Y direction.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if nargin == 2
                
                % Loop for all of the points in the polygon
                for jCounter=1:length(obj.XCoordinateValues)
                    
                    aNumberOfFullCellsY=floor(obj.YCoordinateValues{jCounter}/CellSizeYDimension);
                    
                    aLeftOverY=mod(obj.YCoordinateValues{jCounter},CellSizeYDimension);
                    
                    if aLeftOverY >= .5*CellSizeYDimension     % If the result is closer to the next gridline then snap to that otherwise lose the leftover
                        aNumberOfFullCellsY=aNumberOfFullCellsY+1;
                    end
                    
                    obj.YCoordinateValues{jCounter}=CellSizeYDimension*aNumberOfFullCellsY;
                    
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Add the first value onto the end of the list of points to make
                % sure that the polygon is geometrically closed. Even if we already
                % had a point there it is fine since we will be removing duplicate
                % points.
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                obj.XCoordinateValues{jCounter+1}=obj.XCoordinateValues{1};
                obj.YCoordinateValues{jCounter+1}=obj.YCoordinateValues{1};
                
                removeDuplicatePoints(obj); % remove the duplicate points from the polygon
                
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function snapPolygonToGridXY(obj,CellSizeXDimension,CellSizeYDimension)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will snap all the polygons to gridlines
            % in the X and Y directions.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if nargin == 3
                
                % Loop for all of the points in the polygon
                for jCounter=1:length(obj.XCoordinateValues)
                    
                    aNumberOfFullCellsX=floor(obj.XCoordinateValues{jCounter}/CellSizeXDimension); % Store how many boxes are to the left of the x value and how many boxes are below the y value.
                    aNumberOfFullCellsY=floor(obj.YCoordinateValues{jCounter}/CellSizeYDimension);
                    
                    aLeftOverX=mod(obj.XCoordinateValues{jCounter},CellSizeXDimension); % Mod the X coordinate by the size of a grid box in the X direction
                    aLeftOverY=mod(obj.YCoordinateValues{jCounter},CellSizeYDimension);
                    
                    if aLeftOverX >= .5*CellSizeXDimension     % If the result is closer to the next gridline then snap to that otherwise lose the leftover
                        aNumberOfFullCellsX=aNumberOfFullCellsX+1;
                    end
                    if aLeftOverY >= .5*CellSizeYDimension     % If the result is closer to the next gridline then snap to that otherwise lose the leftover
                        aNumberOfFullCellsY=aNumberOfFullCellsY+1;
                    end
                    
                    obj.XCoordinateValues{jCounter}=CellSizeXDimension*aNumberOfFullCellsX; % Add the values to recieve the new location of the box relative to the grid.
                    obj.YCoordinateValues{jCounter}=CellSizeYDimension*aNumberOfFullCellsY;
                    
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Add the first value onto the end of the list of points to make
                % sure that the polygon is geometrically closed. Even if we already
                % had a point there it is fine since we will be removing duplicate
                % points.
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                obj.XCoordinateValues{jCounter+1}=obj.XCoordinateValues{1};
                obj.YCoordinateValues{jCounter+1}=obj.YCoordinateValues{1};
                
                removeDuplicatePoints(obj); % remove the duplicate points from the polygon
                
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function removeDuplicatePoints(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will try to find and remove duplicate
            % points in a polygon.  The first and last point
            % were the same before and still is after calling this
            % function.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            jCounter=1;
            while jCounter < obj.NumberOfVerticies
                
                % If the vertex pointed to by jCounter is the same as
                % jCounter+1 then we have a duplicate vertex that should be
                % removed.
                if obj.XCoordinateValues{jCounter}==obj.XCoordinateValues{jCounter+1} && ...
                        obj.YCoordinateValues{jCounter}==obj.YCoordinateValues{jCounter+1}
                    
                    % If they are the same then delete the later vertex
                    obj.XCoordinateValues(jCounter+1)=[];
                    obj.YCoordinateValues(jCounter+1)=[];
                    
                else
                    % If the two vertecies do not match then check the next
                    % vertex by incrementing jCounter.
                    jCounter=jCounter+1;
                end
                
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function movePolygon(obj,theNewXCoordinate,theNewYCoordinate)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will move a polygon to a new x and
            % y location. It accepts as input either a polygon
            % object or an index for the appropriate polygon in
            % the polygon array. X and Y values are required.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if nargin == 3
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % determine how far we are going to have to move the
                % polygon by finding the difference in x and y values
                % from the new coodinate pair and the current center.
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                theXDistance=theNewXCoordinate-obj.CentroidXCoordinate;
                theYDistance=theNewYCoordinate-obj.CentroidYCoordinate;
                movePolygonRelative(obj,theXDistance, theYDistance)
                
            else
                error('Invalid number of parameters.');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function movePolygonRelative(obj, theXChange, theYChange)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will move a polygon to an specified
            % amount in the x direction and y direction from
            % where it is currently located.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if nargin >= 3
                
                aTheNumberOfCoordinates=length(obj.XCoordinateValues);
                for iCounter=1:aTheNumberOfCoordinates
                    obj.XCoordinateValues{iCounter}=obj.XCoordinateValues{iCounter}+theXChange;
                    obj.YCoordinateValues{iCounter}=obj.YCoordinateValues{iCounter}+theYChange;
                end
                
            else
                error('Invalid number of parameters.');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function scalePolygon(obj,theXChangeFactor, theYChangeFactor)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will increase the size of a polygon by
            % multipling all of its coordinates by the passed
            % variables
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            for iCounter=1:length(obj.XCoordinateValues)
                obj.XCoordinateValues{iCounter}=obj.XCoordinateValues{iCounter}*theXChangeFactor;
                obj.YCoordinateValues{iCounter}=obj.YCoordinateValues{iCounter}*theYChangeFactor;
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function scalePolygonFromPoint(obj, theXChangeFactor, theYChangeFactor, thePointX, thePointY)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will increase the size of a polygon by
            % scaling the polygon by factors in the x and y
            % directions with respect to a particular coordinate.
            % if no coordinate is supplied the centroid is used.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % If the passed polygon value was a polygon then change
            % the properties of that polygon. If the passed value was
            % an integer then modify the values for the polygon
            % specified at that integer location.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if nargin == 1 % this means we didnt get the point's coordinates in which case we scale with respect to the centroid.
                thePointX=obj.CentroidXCoordinate;
                thePointY=obj.CentroidYCoordinate;
                theXChangeFactor=2;
                theYChangeFactor=2;
            elseif nargin == 3
                thePointX=obj.CentroidXCoordinate;
                thePointY=obj.CentroidYCoordinate;
            elseif nargin == 5
            else
                error('Requires more arguments');
            end
            
            % Update the value for the coordinates
            for iCounter=1:length(obj.XCoordinateValues)
                obj.XCoordinateValues{iCounter}=thePointX+(obj.XCoordinateValues{iCounter}-thePointX)*theXChangeFactor;
                obj.YCoordinateValues{iCounter}=thePointY+(obj.YCoordinateValues{iCounter}-thePointY)*theYChangeFactor;
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function isMetal=isPolygonMetal(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Returns true if the polygon is a metal polygon
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if isempty(obj.Type)
                isMetal=true;
            else
                isMetal=false;
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function isBrick=isPolygonBrick(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Returns true if the polygon is a brick polygon
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if strcmp(obj.Type, 'BRI POLY')==1
                isBrick=true;
            else
                isBrick=false;
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function isVia=isPolygonVia(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Returns true if the polygon is a via polygon
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if strcmp(obj.Type, 'VIA POLYGON')==1
                isVia=true;
            else
                isVia=false;
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function convertToMetal(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Converts this polygon into a metal polygon
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.Type='';
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function convertToBrick(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Converts this polygon into a brick
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.Type='BRI POLY';
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function convertToVia(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Converts this polygon into a via
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.Type='VIA POLYGON';
            obj.LevelTheViaIsConnectedTo='GND';
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function includeMetalCaps(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Sets the via to have metal caps (Sonnet 13)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.isCapped=true;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function removeMetalCaps(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Sets the via to not have metal caps (Sonnet 13)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.isCapped=false;
        end
                
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeViaMeshing(obj,theMeshingType)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Changes the via meshing type (Sonnet 13)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.Meshing=theMeshingType;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aIndex=lowerRightVertex(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Returns the lower right vertex for rectangular polygons
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            aValue=-inf;
            aIndecies=[];
            
            % Find the coordinates with highest X value
            for iCounter=1:length(obj.XCoordinateValues)
                if obj.XCoordinateValues{iCounter} > aValue
                    aValue=obj.XCoordinateValues{iCounter};
                    aIndecies=iCounter;
                elseif obj.XCoordinateValues{iCounter} == aValue
                    aIndecies=[aIndecies iCounter]; %#ok<AGROW>
                end
            end
            
            % Find the coordinates with highest Y value
            aValue=-inf;
            aIndex=[];
            for iCounter=1:length(aIndecies)
                if obj.YCoordinateValues{aIndecies(iCounter)} > aValue
                    aValue=obj.YCoordinateValues{aIndecies(iCounter)};
                    aIndex=aIndecies(iCounter);
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aIndex=lowerLeftVertex(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Returns the lower left vertex for rectangular polygons
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            aValue=inf;
            aIndecies=[];
            
            % Find the coordinates with lowest X value
            for iCounter=1:length(obj.XCoordinateValues)
                if obj.XCoordinateValues{iCounter} < aValue
                    aValue=obj.XCoordinateValues{iCounter};
                    aIndecies=iCounter;
                elseif obj.XCoordinateValues{iCounter} == aValue
                    aIndecies=[aIndecies iCounter]; %#ok<AGROW>
                end
            end
            
            % Find the coordinates with highest Y value
            aValue=-inf;
            aIndex=[];
            for iCounter=1:length(aIndecies)
                if obj.YCoordinateValues{aIndecies(iCounter)} > aValue
                    aValue=obj.YCoordinateValues{aIndecies(iCounter)};
                    aIndex=aIndecies(iCounter);
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aIndex=upperRightVertex(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Returns the upper right vertex for rectangular polygons
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            aValue=-inf;
            aIndecies=[];
            
            % Find the coordinates with highest X value
            for iCounter=1:length(obj.XCoordinateValues)
                if obj.XCoordinateValues{iCounter} > aValue
                    aValue=obj.XCoordinateValues{iCounter};
                    aIndecies=iCounter;
                elseif obj.XCoordinateValues{iCounter} == aValue
                    aIndecies=[aIndecies iCounter]; %#ok<AGROW>
                end
            end
            
            % Find the coordinates with lowest Y value
            aValue=inf;
            aIndex=[];
            for iCounter=1:length(aIndecies)
                if obj.YCoordinateValues{aIndecies(iCounter)} < aValue
                    aValue=obj.YCoordinateValues{aIndecies(iCounter)};
                    aIndex=aIndecies(iCounter);
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aIndex=upperLeftVertex(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Returns the upper left vertex for rectangular polygons
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            aValue=inf;
            aIndecies=[];
            
            % Find the coordinates with lowest X value
            for iCounter=1:length(obj.XCoordinateValues)
                if obj.XCoordinateValues{iCounter} < aValue
                    aValue=obj.XCoordinateValues{iCounter};
                    aIndecies=iCounter;
                elseif obj.XCoordinateValues{iCounter} == aValue
                    aIndecies=[aIndecies iCounter]; %#ok<AGROW>
                end
            end
            
            % Find the coordinates with lowest Y value
            aValue=inf;
            aIndex=[];
            for iCounter=1:length(aIndecies)
                if obj.YCoordinateValues{aIndecies(iCounter)} < aValue
                    aValue=obj.YCoordinateValues{aIndecies(iCounter)};
                    aIndex=aIndecies(iCounter);
                end
            end
        end
        
    end
    
end

