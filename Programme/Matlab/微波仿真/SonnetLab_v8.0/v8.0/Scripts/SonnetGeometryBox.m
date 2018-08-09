classdef SonnetGeometryBox < handle
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This class defines the values for a Sonnet Box. This is contained
    % within the geometry block of the project file.
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
        
        XWidthOfTheBox
        YWidthOfTheBox
        DoubleNumberOfCellsInXDirection
        DoubleNumberOfCellsInYDirection
        NumberOfSubsections
        EffectiveDielectricConstant
        
        ArrayOfDielectricLayers
        
    end
    
    properties (Dependent = true)
        NumberOfMetalizationLevels
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = SonnetGeometryBox(theFid)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % define the constructor for the box.
            %     the constructor will be passed the file ID from the
            %     SONNET GEO object constructor.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if nargin == 1        %if we were passed 1 argument which means we go the theFid
                
                initialize(obj);
                
                obj.ArrayOfDielectricLayers=[];                   % Reset the number of dielectric layers so that we delete the ones we made during initialization
                NumberOfDielectricLayers=0;
                
                aBackupOfTheFid=ftell(theFid);                    % Store a backup of the file ID so that we can restore it afer we read the line
                aTempString=fgetl(theFid);
                fseek(theFid,aBackupOfTheFid,'bof');              % Restore the backup of the fid
                
                % Determine if we have 5 arguments or 7
                aTempString=strtrim(aTempString);                 % Trim the read string of leading and trailing whitespace
                theNumberOfSpaces=findstr(aTempString, ' ');      % Find the number of spaces in the string, if 4 then we have 5 arguments, if it is 6 (or otherwise) we have 7 arguments
                if theNumberOfSpaces==4
                    fscanf(theFid,' %d',1);                       % Read in the number of levels, we dont need to store it because we calculate it by the size of the array anyway
                    obj.XWidthOfTheBox=fscanf(theFid,' %f',1);
                    obj.YWidthOfTheBox=fscanf(theFid,' %f',1);
                    obj.DoubleNumberOfCellsInXDirection=fscanf(theFid,' %d',1);
                    obj.DoubleNumberOfCellsInYDirection=fscanf(theFid,' %d',1);
                    
                else
                    fscanf(theFid,' %d',1);                       % Read in the number of levels, we dont need to store it because we calculate it by the size of the array anyway
                    obj.XWidthOfTheBox=fscanf(theFid,' %f',1);
                    obj.YWidthOfTheBox=fscanf(theFid,' %f',1);
                    obj.DoubleNumberOfCellsInXDirection=fscanf(theFid,' %d',1);
                    obj.DoubleNumberOfCellsInYDirection=fscanf(theFid,' %d',1);
                    obj.NumberOfSubsections=fscanf(theFid,' %d',1);
                    obj.EffectiveDielectricConstant=fscanf(theFid,' %f',1);
                    
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Next we want to handle the dielectric layers
                % We don't know how many layers there will be so we have to sample
                % the line and check if it is a layer.  If it is then we can
                % construct a new layer; otherwise we need to restore the file
                % pointer to the location right before the line.  We know that a
                % line is a layer if it contains the tab character.
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                fgetl(theFid);
                while (1==1)                               % Loop forever until we break
                    
                    aBackupOfTheFid=ftell(theFid);		   % Store a backup of the file ID so that we can restore it if we need it
                    aTempString=fgets(theFid);             % Read the beginning of the line and determine if it is a layer. If it is then the string read will be /t
                    fseek(theFid,aBackupOfTheFid,'bof');   % Restore the backup of the fid
                    
                    if ~isempty(findstr(aTempString, '    '))
                        NumberOfDielectricLayers=NumberOfDielectricLayers+1;
                        obj.ArrayOfDielectricLayers{NumberOfDielectricLayers}=SonnetGeometryBoxDielectricLayer(theFid);
                        
                    else
                        break;
                        
                    end
                    
                end
                
                
            else
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % we come here when we didn't recieve a file ID as an argument
                % which means that we are going to create a default metal object with
                % default values by calling the function's initialize method.
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                initialize(obj);
                
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get/Set functions: We want the number of layers to
        % automatically update as we add/remove layers by
        % calculating its value whenever it is needed.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function value = get.NumberOfMetalizationLevels(obj)
            value=length(obj.ArrayOfDielectricLayers)-1;
        end
        function set.NumberOfMetalizationLevels(obj,~) %#ok<MANU>
            warning 'NumberOfMetalizationLevels can not be directly changed. This value is dependent on the dielectric layers.';
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function initialize(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function initializes the metal properties to some default
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
            
            obj.XWidthOfTheBox=160;
            obj.YWidthOfTheBox=160;
            obj.DoubleNumberOfCellsInXDirection=32;
            obj.DoubleNumberOfCellsInYDirection=32;
            obj.NumberOfSubsections=20;
            obj.EffectiveDielectricConstant=0;
            
            obj.ArrayOfDielectricLayers{1}=SonnetGeometryBoxDielectricLayer();
            obj.ArrayOfDielectricLayers{2}=SonnetGeometryBoxDielectricLayer();
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aNewObject=clone(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function builds a deep copy of this object
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            aNewObject=SonnetGeometryBox();
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
        function aSignature=stringSignature(obj,theVersion)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function writes the values from the object to a string.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            aSignature='BOX';
            
            if ~isempty(obj.NumberOfMetalizationLevels)
                aSignature=[aSignature sprintf(' %d',obj.NumberOfMetalizationLevels)];
            end
            
            if ~isempty(obj.XWidthOfTheBox)
                aSignature=[aSignature sprintf(' %.15g',obj.XWidthOfTheBox)];
            end
            
            if ~isempty(obj.YWidthOfTheBox)
                aSignature=[aSignature sprintf(' %.15g',obj.YWidthOfTheBox)];
            end
            
            if ~isempty(obj.DoubleNumberOfCellsInXDirection)
                aSignature=[aSignature sprintf(' %d',obj.DoubleNumberOfCellsInXDirection)];
            end
            
            if ~isempty(obj.DoubleNumberOfCellsInYDirection)
                aSignature=[aSignature sprintf(' %d',obj.DoubleNumberOfCellsInYDirection)];
            end
            
            if ~isempty(obj.NumberOfSubsections)
                aSignature=[aSignature sprintf(' %d',obj.NumberOfSubsections)];
            end
            
            if ~isempty(obj.EffectiveDielectricConstant)
                aSignature=[aSignature sprintf(' %.15g',obj.EffectiveDielectricConstant)];
            end
            
            aSignature=[aSignature sprintf('\n')];
            
            % Call the stringSignature function in each of the objects that we have in our cell array.
            for iCounter= 1:length(obj.ArrayOfDielectricLayers)
                aSignature=[aSignature obj.ArrayOfDielectricLayers{iCounter}.stringSignature(theVersion)]; %#ok<AGROW>
            end
            
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addDielectricLayerUsingLibary(obj,theNameOfDielectricLayer,theThickness)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will add a dielectric layer to the top of
            % the project using a material defined in the Sonnet
            % dielectric library.
            %
            %       1)  Name Of the Dielectric Layer
            %       2)  Thickness of the layer
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
                
                if ~isempty(strfind(aTempString,theNameOfDielectricLayer))
                    % Construct an empty layer
                    aLayer=SonnetGeometryBoxDielectricLayer();
                    
                    aTempString=strrep(aTempString,'BRI','');
                    aTempString=strrep(aTempString,'"','');
                    aTempString=strrep(aTempString,theNameOfDielectricLayer,'');
                    
                    % Import the properties of the layer material
                    aResults=sscanf(aTempString,'%f');
                    aLayer.NameOfDielectricLayer=theNameOfDielectricLayer;
                    aLayer.Thickness=theThickness;
                    aLayer.RelativeDielectricConstant=aResults(1);
                    aLayer.DielectricLossTangent=aResults(2);
                    aLayer.DielectricConductivity=aResults(3);
                    aLayer.RelativeMagneticPermeability=aResults(4);
                    aLayer.MagneticLossTangent=aResults(5);
                    
                    % Append the layer to the array
                    obj.ArrayOfDielectricLayers{length(obj.ArrayOfDielectricLayers)+1}=aLayer;
                    
                    fclose(aFid);
                    return;
                    
                end
                aTempString=fgetl(aFid);
            end
            error('Invalid Dielectric Material Specified');
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeDielectricLayerUsingLibary(obj,theArrayPosition,theNameOfDielectricLayer,theThickness)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will reaplce an existing dielectric layer
            % with a material defined in the Sonnet dielectric library.
            %
            %       1)  Name Of the Dielectric Layer
            %       2)  Thickness of the layer
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
                
                if ~isempty(strfind(aTempString,theNameOfDielectricLayer))
                    aTempString=strrep(aTempString,'BRI','');
                    aTempString=strrep(aTempString,'"','');
                    aTempString=strrep(aTempString,theNameOfDielectricLayer,'');
                    
                    % Import the properties of the layer material
                    aResults=sscanf(aTempString,'%f');
                    obj.ArrayOfDielectricLayers{theArrayPosition}.NameOfDielectricLayer=theNameOfDielectricLayer;
                    obj.ArrayOfDielectricLayers{theArrayPosition}.Thickness=theThickness;
                    obj.ArrayOfDielectricLayers{theArrayPosition}.RelativeDielectricConstant=aResults(1);
                    obj.ArrayOfDielectricLayers{theArrayPosition}.DielectricLossTangent=aResults(2);
                    obj.ArrayOfDielectricLayers{theArrayPosition}.DielectricConductivity=aResults(3);
                    obj.ArrayOfDielectricLayers{theArrayPosition}.RelativeMagneticPermeability=aResults(4);
                    obj.ArrayOfDielectricLayers{theArrayPosition}.MagneticLossTangent=aResults(5);
                    obj.ArrayOfDielectricLayers{theArrayPosition}.NumberOfZPartitions=0;
                    
                    fclose(aFid);
                    return;
                    
                end
                aTempString=fgetl(aFid);
            end
            error('Invalid Dielectric Material Specified');
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function replaceIsotropicDielectricLayer(obj,theArrayPosition,theNameOfDielectricLayer,theThickness,...
                theRelativeDielectricConstant,theRelativeMagneticPermeability,...
                theDielectricLossTangent,theMagneticLossTangent,...
                theDielectricConductivity)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will reaplce an existing dielectric layer
            % with a material defined in the Sonnet dielectric library.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Replace the properties of the layer material
            obj.ArrayOfDielectricLayers{theArrayPosition}.NameOfDielectricLayer=theNameOfDielectricLayer;
            obj.ArrayOfDielectricLayers{theArrayPosition}.Thickness=theThickness;
            obj.ArrayOfDielectricLayers{theArrayPosition}.RelativeDielectricConstant=theRelativeDielectricConstant;
            obj.ArrayOfDielectricLayers{theArrayPosition}.DielectricLossTangent=theDielectricLossTangent;
            obj.ArrayOfDielectricLayers{theArrayPosition}.DielectricConductivity=theDielectricConductivity;
            obj.ArrayOfDielectricLayers{theArrayPosition}.RelativeMagneticPermeability=theRelativeMagneticPermeability;
            obj.ArrayOfDielectricLayers{theArrayPosition}.MagneticLossTangent=theMagneticLossTangent;
            obj.ArrayOfDielectricLayers{theArrayPosition}.RelativeDielectricConstantForZDirection=[];
            obj.ArrayOfDielectricLayers{theArrayPosition}.RelativeMagneticPermeabilityForZDirection=[];
            obj.ArrayOfDielectricLayers{theArrayPosition}.DielectricLossTangentForZDirection=[];
            obj.ArrayOfDielectricLayers{theArrayPosition}.MagneticLossTangentForZDirection=[];
            obj.ArrayOfDielectricLayers{theArrayPosition}.DielectricConductivityForZDirection=[];
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function replaceAnisotropicDielectricLayer(obj,theArrayPosition,theNameOfDielectricLayer,theThickness,...
                theRelativeDielectricConstant,theRelativeMagneticPermeability,theDielectricLossTangent,...
                theMagneticLossTangent,theDielectricConductivity,theRelativeDielectricConstantForZDirection,...
                theRelativeMagneticPermeabilityForZDirection,theDielectricLossTangentForZDirection,...
                theMagneticLossTangentForZDirection,theDielectricConductivityForZDirection)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will reaplce an existing dielectric layer
            % with a material defined in the Sonnet dielectric library.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Replace the properties of the layer material
            obj.ArrayOfDielectricLayers{theArrayPosition}.NameOfDielectricLayer=theNameOfDielectricLayer;
            obj.ArrayOfDielectricLayers{theArrayPosition}.Thickness=theThickness;
            obj.ArrayOfDielectricLayers{theArrayPosition}.RelativeDielectricConstant=theRelativeDielectricConstant;
            obj.ArrayOfDielectricLayers{theArrayPosition}.DielectricLossTangent=theDielectricLossTangent;
            obj.ArrayOfDielectricLayers{theArrayPosition}.DielectricConductivity=theDielectricConductivity;
            obj.ArrayOfDielectricLayers{theArrayPosition}.RelativeMagneticPermeability=theRelativeMagneticPermeability;
            obj.ArrayOfDielectricLayers{theArrayPosition}.MagneticLossTangent=theMagneticLossTangent;
            obj.ArrayOfDielectricLayers{theArrayPosition}.RelativeDielectricConstantForZDirection=theRelativeDielectricConstantForZDirection;
            obj.ArrayOfDielectricLayers{theArrayPosition}.RelativeMagneticPermeabilityForZDirection=theRelativeMagneticPermeabilityForZDirection;
            obj.ArrayOfDielectricLayers{theArrayPosition}.DielectricLossTangentForZDirection=theDielectricLossTangentForZDirection;
            obj.ArrayOfDielectricLayers{theArrayPosition}.MagneticLossTangentForZDirection=theMagneticLossTangentForZDirection;
            obj.ArrayOfDielectricLayers{theArrayPosition}.DielectricConductivityForZDirection=theDielectricConductivityForZDirection;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function replaceDielectricLayerUsingLibrary(obj,theArrayPosition,theNameOfDielectricLayer,theThickness)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will reaplce an existing dielectric layer
            % with a material defined in the Sonnet dielectric library.
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
                
                if ~isempty(strfind(aTempString,theNameOfDielectricLayer))
                    % Construct an empty layer
                    aLayer=SonnetGeometryBoxDielectricLayer();
                    
                    aTempString=strrep(aTempString,'BRI','');
                    aTempString=strrep(aTempString,'"','');
                    aTempString=strrep(aTempString,theNameOfDielectricLayer,'');
                    
                    % Import the properties of the layer material
                    aResults=sscanf(aTempString,'%f');
                    aLayer.NameOfDielectricLayer=theNameOfDielectricLayer;
                    aLayer.Thickness=theThickness;
                    aLayer.RelativeDielectricConstant=aResults(2);
                    aLayer.DielectricLossTangent=aResults(3);
                    aLayer.DielectricConductivity=aResults(4);
                    aLayer.RelativeMagneticPermeability=aResults(5);
                    aLayer.MagneticLossTangent=aResults(6);
                    
                    % Replace the layer
                    obj.ArrayOfDielectricLayers{theArrayPosition}=aLayer;
                    
                    fclose(aFid);
                    return;
                    
                end
                aTempString=fgetl(aFid);
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addDielectricLayer(obj,theNameOfDielectricLayer,theThickness,theRelativeDielectricConstant,theRelativeMagneticPermeability,theDielectricLossTangent,theMagneticLossTangent,theDielectricConductivity,theNumberOfZPartitions)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will add a dielectric layer to the top of
            % the project.
            %
            %   If the layer is isotropic then it requires the
            %   following arguments:
            %
            %       1)  Name Of the Dielectric Layer
            %       2)  Thickness of the layer
            %       3)  Relative Dielectric Constant
            %       4)  Relative Magnetic Permeability
            %       5)  Dielectric Loss Tangent
            %       6)  Magnetic Loss Tangent
            %       7)  Dielectric Conductivity
            %       8)  Number Of ZPartitions (Optional)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Construct an empty layer
            aLayer=SonnetGeometryBoxDielectricLayer();
            
            % Modify the values for the layer
            aLayer.NameOfDielectricLayer=theNameOfDielectricLayer;
            aLayer.Thickness=theThickness;
            aLayer.RelativeDielectricConstant=theRelativeDielectricConstant;
            aLayer.RelativeMagneticPermeability=theRelativeMagneticPermeability;
            aLayer.DielectricLossTangent=theDielectricLossTangent;
            aLayer.MagneticLossTangent=theMagneticLossTangent;
            aLayer.DielectricConductivity=theDielectricConductivity;
            
            if nargin == 9
                aLayer.NumberOfZPartitions=theNumberOfZPartitions;
            end
            
            % Append the layer to the array
            obj.ArrayOfDielectricLayers{length(obj.ArrayOfDielectricLayers)+1}=aLayer;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addAnisotropicDielectricLayer(obj,theNameOfDielectricLayer,theThickness,theRelativeDielectricConstant,theRelativeMagneticPermeability,theDielectricLossTangent,theMagneticLossTangent,theDielectricConductivity,theRelativeDielectricConstantForZDirection,theRelativeMagneticPermeabilityForZDirection,theDielectricLossTangentForZDirection,theMagneticLossTangentForZDirection,theDielectricConductivityForZDirection,theNumberOfZPartitions)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This method will add a dielectric layer to the top of
            % the project.
            %
            %   If the layer is anisotropic then it requires the
            %   following arguments:
            %
            %       1)  Name Of the Dielectric Layer
            %       2)  Thickness of the layer
            %       3)  Relative Dielectric Constant
            %       4)  Relative Magnetic Permeability
            %       5)  Dielectric Loss Tangent
            %       6)  Magnetic Loss Tangent
            %       7)  Dielectric Conductivity
            %       8)  Relative Dielectric Constant For Z Direction
            %       9)  Relative Magnetic Permeability For Z Direction
            %       10) Dielectric Loss Tangent For Z Direction
            %       11) Magnetic Loss Tangent For Z Direction
            %       12) Dielectric Conductivity For Z Direction
            %       13) Number Of ZPartitions (Optional)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Construct an empty layer
            aLayer=SonnetGeometryBoxDielectricLayer();
            
            % Modify the values for the layer
            aLayer.NameOfDielectricLayer=theNameOfDielectricLayer;
            aLayer.Thickness=theThickness;
            aLayer.RelativeDielectricConstant=theRelativeDielectricConstant;
            aLayer.RelativeMagneticPermeability=theRelativeMagneticPermeability;
            aLayer.DielectricLossTangent=theDielectricLossTangent;
            aLayer.MagneticLossTangent=theMagneticLossTangent;
            aLayer.DielectricConductivity=theDielectricConductivity;
            aLayer.RelativeDielectricConstantForZDirection=theRelativeDielectricConstantForZDirection;
            aLayer.RelativeMagneticPermeabilityForZDirection=theRelativeMagneticPermeabilityForZDirection;
            aLayer.DielectricLossTangentForZDirection=theDielectricLossTangentForZDirection;
            aLayer.MagneticLossTangentForZDirection=theMagneticLossTangentForZDirection;
            aLayer.DielectricConductivityForZDirection=theDielectricConductivityForZDirection;
            
            if nargin == 14
                aLayer.NumberOfZPartitions=theNumberOfZPartitions;
            end
            
            % Append the layer to the array
            obj.ArrayOfDielectricLayers{length(obj.ArrayOfDielectricLayers)+1}=aLayer;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeBoxSize(obj, theNewXWidth, theNewYWidth)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Function that changes the size of the Sonnet
            % box. This function requires a new set of X and Y Widths
            % Note: This function is the same as changeBoxSizeXY
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            changeBoxSizeXY(obj, theNewXWidth, theNewYWidth);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeBoxSizeXY(obj, theNewXWidth, theNewYWidth)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Function that changes the size of the Sonnet
            % box. This function requires a new set of X and Y Widths.
            % Note: This function is the same as changeBoxSize
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.XWidthOfTheBox=theNewXWidth;
            obj.YWidthOfTheBox=theNewYWidth;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeBoxSizeX(obj, theNewXWidth)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Function that changes the size of the Sonnet
            % box in the X direction. This function
            % requires a new X width.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.XWidthOfTheBox=theNewXWidth;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeBoxSizeY(obj, theNewYWidth)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Function that changes the size of the Sonnet
            % box in the Y direction. This function
            % requires a new Y width.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.YWidthOfTheBox=theNewYWidth;
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
            changeNumberOfCellsXY(obj, theNewXCellSize, theNewYCellSize)
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
            obj.DoubleNumberOfCellsInXDirection=theNewXCellSize*2;
            obj.DoubleNumberOfCellsInYDirection=theNewYCellSize*2;
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
            obj.DoubleNumberOfCellsInXDirection=theNewXCellSize*2;
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
            obj.DoubleNumberOfCellsInYDirection=theNewYCellSize*2;
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
            obj.DoubleNumberOfCellsInXDirection=round(obj.XWidthOfTheBox/theNewXCellSize*2);
            obj.DoubleNumberOfCellsInYDirection=round(obj.YWidthOfTheBox/theNewYCellSize*2);
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
            obj.DoubleNumberOfCellsInXDirection=round(obj.XWidthOfTheBox/theNewXCellSize*2);
            obj.DoubleNumberOfCellsInYDirection=round(obj.YWidthOfTheBox/theNewYCellSize*2);
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
            obj.DoubleNumberOfCellsInXDirection=round(obj.XWidthOfTheBox/theNewXCellSize*2);
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
            obj.DoubleNumberOfCellsInYDirection=round(obj.YWidthOfTheBox/theNewYCellSize*2);
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
            obj.XWidthOfTheBox=obj.DoubleNumberOfCellsInXDirection*theNewXCellSize/2;
            obj.YWidthOfTheBox=obj.DoubleNumberOfCellsInYDirection*theNewYCellSize/2;
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
            obj.XWidthOfTheBox=obj.DoubleNumberOfCellsInXDirection*theNewXCellSize/2;
            obj.YWidthOfTheBox=obj.DoubleNumberOfCellsInYDirection*theNewYCellSize/2;
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
            obj.XWidthOfTheBox=obj.DoubleNumberOfCellsInXDirection*theNewXCellSize/2;
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
            obj.YWidthOfTheBox=obj.DoubleNumberOfCellsInYDirection*theNewYCellSize/2;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function axCellSize=xCellSize(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % return the cell size in the X direction
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            axCellSize=obj.XWidthOfTheBox/(.5*obj.DoubleNumberOfCellsInXDirection);
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function ayCellSize=yCellSize(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % return the cell size in the X direction
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            ayCellSize=obj.YWidthOfTheBox/(.5*obj.DoubleNumberOfCellsInYDirection);
        end
    end
end

