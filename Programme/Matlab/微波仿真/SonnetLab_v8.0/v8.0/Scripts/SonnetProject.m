classdef SonnetProject  <  handle
    %SonnetProject   Provides interoperability with Sonnet
    %   SonnetProject provides support for interacting with Sonnet project
    %   files. This class has support for both Sonnet geometry projects and
    %   Sonnet netlist projects. Please see the included documentation for
    %   a detailed description of the features of SonnetLab.
    %
    %   Author: Bashir Souid
    %
    %   Updated By: Robert Roach
    %
    %   Version Number: 7.0
    %
    %   Version Notes:
    %       This class is intended for Sonnet versions >= 12.
    %       An error will be thrown when being used with projects from
    %       older versions of Sonnet.
    %
    %       This script requires a version of Matlab with object-oriented
    %       programming support (>= R2008a). This script was written
    %       and tested with Matlab 7.8.0 (R2009a), Matlab 7.9.0 (R2009b),
    %       Matlab 7.10.0 (R2010a), and Matlab 7.12.0 (2011a). This interface 
    %       has been tested on Windows XP 32-bit, Windows Vista 32-bit, 
    %       Windows Vista 64-bit and Windows 7 64-bit.
    %
    %       This software is provided without warranty. Neither Sonnet nor the
    %       author of these scripts are responsible for misuse or defects.
    %
    %   Help Notes:
    %       * Type 'help SonnetProject.SonnetProject' for help with the constructor
    %
    %       * Type  'methods(SonnetProject)' to view the available methods
    %           for interacting with Sonnet projects
    %
    %       * To see the help documentation for any method type 'help SonnetProject.<MethodName>'
    %
    %   Licence Notes:
    %       SonnetLab, all included documentation, all included examples
    %       and all other files (unless otherwise specified) are copyrighted by Sonnet Software
    %       in 2011 with all rights reserved.
    %
    %       THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS". ANY AND
    %       ALL EXPRESS OR IMPLIED WARRANTIES ARE DISCLAIMED. UNDER NO CIRCUMSTANCES AND UNDER
    %       NO LEGAL THEORY, TORT, CONTRACT, OR OTHERWISE, SHALL THE COPYWRITE HOLDERS,  CONTRIBUTORS,
    %       MATLAB, OR SONNET SOFTWARE BE LIABLE FOR ANY DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR
    %       CONSEQUENTIAL DAMAGES OF ANY CHARACTER INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF
    %       GOODWILL, WORK STOPPAGE, COMPUTER FAILURE OR MALFUNCTION, OR ANY AND ALL OTHER COMMERCIAL
    %       DAMAGES OR LOSSES, OR FOR ANY DAMAGES EVEN IF THE COPYWRITE HOLDERS, CONTRIBUTORS, MATLAB,
    %       OR SONNET SOFTWARE HAVE BEEN INFORMED OF THE POSSIBILITY OF SUCH DAMAGES, OR FOR ANY CLAIM
    %       BY ANY OTHER PARTY.
    %
    %   See also SonnetProject.SonnetProject
    
    properties
        VersionOfSonnet         % This indicates the version of the Sonnet project editor.
        AutoDelete              % When this is true the project will automatically delete ports, edge vias, etc. when the polygon they are attached to is deleted.
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % These properties hold the instantiations of Sonnet blocks
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        HeaderBlock             % This object stores the Header information
        DimensionBlock          % This object stores the Dimension information
        FrequencyBlock          % This object stores the Frequency information
        ControlBlock            % This object stores the Control information
        GeometryBlock           % This object stores the Geometry information
        OptimizationBlock       % This object stores the Optimization information
        VariableSweepBlock      % This object stores the VariableSweep information
        CircuitElementsBlock    % This object stores the Circuit Element information for a netlist
        ParameterBlock          % This object stores the Parameter information for a netlist
        FileOutBlock            % This object stores the Output File information
        ComponentFileBlock      % This object stores the SMD File information
        CellArrayOfBlocks       % The cell array that we are storing the blocks inside
        
    end
    
    properties (SetAccess = private, GetAccess = public)
        isValidProjectVersion		% If the project version is valid (version >=10) this is true, otherwise false. If the project is invalid then we dont want to write it to the file.
        Filename                    % Stores the filename that will be used to save the project
        FilePath                    % Stores where the file is located in the directory tree
        SpectreRLGC                 % Stores Spectre file data
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Core Methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = SonnetProject(aFilename)
            %SonnetProject   Create a new Sonnet project object
            %   SonnetProject() Initializes an object to represent a Sonnet project.
            %   This Sonnet project has the same default settings as what would be generated
            %   by Sonnet when creating a new geometry project.
            %
            %   SonnetProject('project.son') Initializes an object to represent a Sonnet
            %   project. This project object will import all its settings from the
            %   specified Sonnet project file. The constructor will read the Sonnet
            %   project information from the file and assign it to the properties of
            %   the class instantiation.
            %
            %   See also SonnetProject
            
            if nargin == 0
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % If the project is constructed without an
                %   filename included then construct a
                %   default Sonnet project.
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                initialize(obj);
                
            elseif nargin == 1
                
                aDimensionBlock=[];
                aFrequencyBlock=[];
                aControlBlock=[];
                aGeometryBlock=[];
                aOptimizationBlock=[];
                aVariableSweepBlock=[];
                aCircuitElementsBlock=[];
                aParameterBlock=[];
                aFileOutBlock=[];
                aComponentFileBlock=[];
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % If the constructor was given a filename
                %   then it will attempt to open the file.
                %   if the file is not found then the script
                %   will ask for a new filename.
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                aFid=0;
                while aFid < 1
                    aFid = fopen(aFilename, 'r');
                    if aFid == -1
                        disp('The specified file could not be found in the path. Please try again.');
                        aFilename=input('Please enter the name of the Sonnet project in the path: ', 's');
                    end
                end
                
                % Extract the filename and the path
                aRemainingPath=aFilename;
                aPartialPath='';
                while ~isempty(aRemainingPath)
                    [aPartialPath, aRemainingPath]=strtok(aRemainingPath,filesep); %#ok<STTOK>
                end
                
                % Save the filename and filepath
                aFilePath=strrep(aFilename,aPartialPath,'');
                aFilename=aPartialPath;
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % At this point we have a file that exists
                %     on the hard drive in the path specified.
                %     we can now proceed to read from it.
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                % read in the SONNET project initial tag
                aFtypTagLine=fgetl(aFid);
                
                % if the ftyp line has the word 'Netlist' in it then reinitialize the project as a netlist
                if ~isempty(strfind(aFtypTagLine,'Netlist'))
                    obj.initializeNetlist();
                end
                
                % Try to read the version number ('VER'). VER is Optional so
                % if it isnt present then the line will be HEADER
                aTempString=fscanf(aFid,'%s',1); % try to read from the file.
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % compare the read string to VER, if it is then the VER info
                % was included, otherwise it should be HEADER. If it is neither
                % then the project file is corrupt.
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                aVersionOfSonnet=15.52;
                if (strcmp(aTempString,'VER')==1)   % if it is VER then we need to read the version number
                    aVersionOfSonnet=fgetl(aFid);   % try to read the version number from the file.
                    aVersionOfSonnet=strtrim(aVersionOfSonnet);
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % now we want to read in the HEADER tag. We will check if
                    % it is really the 'HEADER' tag and if not then we have an
                    % corrupted project file.
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    aTempString=fgetl(aFid); % try to read 'HEADER'
                    if (strncmp(aTempString,'HEADER',5)==0) % if the result of the read wasn't 'HEADER'
                        % If it wasn't HeaderBlock then we need to throw an error.
                        error('An error has occured while reading from the file. The project may be corrupt.');
                    end
                    
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Determine if the project is intended for a version of Sonnet below
                % version 12.  This script is intended for versions 12+.
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if cell2mat(textscan(aVersionOfSonnet,'%d'))<12
                    disp(['This script is only intended for Sonnet versions 12 and 13.' ...
                        ' This project is for Sonnet version ' num2str(aVersionOfSonnet)]);
                    obj.isValidProjectVersion=false;  % Keeps track of whether the project is valid. this allows us to only write the project if it is valid
                    return;
                else
                    aisValidProjectVersion=true;	  % Keeps track of whether the project is valid. this allows us to only write the project if it is valid
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % The aFid should now be right after the 'HEADER'
                %   tag.  We can now create a HeaderBlock object
                %   by constructing it and passing along the aFid.
                %   the HeaderBlock constructor will validate the input
                %   and create the object.
                % The result of the read will place the file
                %   marker right after the 'END HEADER' tag.
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                aHeaderBlock = SonnetHeaderBlock(aFid);
                
                % Preallocate the cell array of blocks
                aCellArrayOfBlocks=cell(1,5);
                
                aCellArrayOfBlocks{1}=aHeaderBlock;
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % We are going to loop and read all the block tags
                %	for all the lines in the file.  We will
                %   make an appropriate object for each of the
                %   blocks we find.  If an unknown tag is found we
                %   will store it as an 'unknown' block.
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                % Read a string from the file,
                % we will use this to determine what
                % block is being initialized.
                aTempString=fgetl(aFid);              % Read a Value from the file, we will be using this to drive the switch statment
                aTempString=strtrim(aTempString);	  % Remove the whitespace from the string
                
                % This is a counter to keep track of the length of the cell
                % array of blocks.
                iBlockCounter=2;
                
                while(1==1)
                    
                    switch aTempString
                        
                        case 'DIM'
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            % The aFid should now be right after the 'DIM'
                            %   tag.  We can now create a DIM object
                            %   by constructing it and passing along the aFid.
                            %   the DIM constructor will validate the input
                            %   and create the object.
                            % The result of the read will place the file
                            %   marker right after the 'END DIM' tag.
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            aDimensionBlock = SonnetDimensionBlock(aFid);
                            aCellArrayOfBlocks{iBlockCounter}=aDimensionBlock;
                            iBlockCounter=iBlockCounter+1;
                            
                            
                        case 'FREQ'
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            % The aFid should now be right after the 'FREQ'
                            %   tag.  We can now create a FREQ object
                            %   by constructing it and passing along the aFid.
                            %   the FREQ constructor will validate the input
                            %   and create the object.
                            % The result of the read will place the file
                            %   marker right after the 'END FREQ' tag.
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            aFrequencyBlock = SonnetFrequencyBlock(aFid);
                            aCellArrayOfBlocks{iBlockCounter}=aFrequencyBlock;
                            iBlockCounter=iBlockCounter+1;
                            
                            
                        case 'CONTROL'
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            % The aFid should now be right after the 'CONTROL'
                            %   tag.  We can now create a CONTROL object
                            %   by constructing it and passing along the aFid.
                            %   the CONTROL constructor will validate the input
                            %   and create the object.
                            % The result of the read will place the file
                            %   marker right after the 'END CONTROL' tag.
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            aControlBlock = SonnetControlBlock(aFid);
                            aCellArrayOfBlocks{iBlockCounter}=aControlBlock;
                            iBlockCounter=iBlockCounter+1;
                            
                            
                        case 'GEO'
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            % The aFid should now be right after the 'GEO'
                            %   tag.  We can now create a GEO object
                            %   by constructing it and passing along the aFid.
                            %   the GEO constructor will validate the input
                            %   and create the object.
                            % The result of the read will place the file
                            %   marker right after the 'END GEO' tag.
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            aGeometryBlock = SonnetGeometryBlock(aFid);
                            aCellArrayOfBlocks{iBlockCounter}=aGeometryBlock;
                            iBlockCounter=iBlockCounter+1;
                            
                            
                        case '\n'
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            % If the line was blank (was only a newline)
                            %   then ignore it
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            
                        case 'OPT'
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            % The aFid should now be right after the 'OPT'
                            %   tag.  We can now create a OPT object
                            %   by constructing it and passing along the aFid.
                            %   the OPT constructor will validate the input
                            %   and create the object.
                            % The result of the read will place the file
                            %   marker right after the 'END OPT' tag.
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            aOptimizationBlock = SonnetOptimizationBlock(aFid);
                            aCellArrayOfBlocks{iBlockCounter}=aOptimizationBlock;
                            iBlockCounter=iBlockCounter+1;
                            
                            
                        case 'VARSWP'
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            % The aFid should now be right after the 'VARSWP'
                            %   tag.  We can now create a VARSWP object
                            %   by constructing it and passing along the aFid.
                            %   the VARSWP constructor will validate the input
                            %   and create the object.
                            % The result of the read will place the file
                            %   marker right after the 'END VARSWP' tag.
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            aVariableSweepBlock = SonnetVariableSweepBlock(aFid);
                            aCellArrayOfBlocks{iBlockCounter}=aVariableSweepBlock;
                            iBlockCounter=iBlockCounter+1;
                            
                        case 'CKT'
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            % The aFid should now be right after the 'CKT'
                            %   tag.  We can now create a CKT object
                            %   by constructing it and passing along the aFid.
                            %   the CKT constructor will validate the input
                            %   and create the object.
                            % The result of the read will place the file
                            %   marker right after the 'END CKT' tag.
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            aCircuitElementsBlock = SonnetCircuitBlock(aFid);
                            aCellArrayOfBlocks{iBlockCounter}=aCircuitElementsBlock;
                            iBlockCounter=iBlockCounter+1;
                            
                            
                        case 'VAR'
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            % The aFid should now be right after the 'VAR'
                            %   tag.  We can now create a VAR object
                            %   by constructing it and passing along the aFid.
                            %   the VAR constructor will validate the input
                            %   and create the object.
                            % The result of the read will place the file
                            %   marker right after the 'END VAR' tag.
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            aParameterBlock = SonnetVariableBlock(aFid);
                            aCellArrayOfBlocks{iBlockCounter}=aParameterBlock;
                            iBlockCounter=iBlockCounter+1;
                            
                            
                        case 'FILEOUT'
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            % The aFid should now be right after the 'FILEOUT'
                            %   tag.  We can now create an output file object
                            %   by constructing it and passing along the aFid.
                            %   the outputFile constructor will validate the input
                            %   and create the object.
                            % The result of the read will place the file
                            %   marker right after the 'END FILEOUT' tag.
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            aFileOutBlock = SonnetFileOutBlock(aFid);
                            aCellArrayOfBlocks{iBlockCounter}=aFileOutBlock;
                            iBlockCounter=iBlockCounter+1;
                            
                            
                        case 'QSG'
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            % If the block is the Quick start guide then
                            %   Just read it in like done with unknown
                            %   blocks. Only difference is that we should
                            %   print that it is ignored.
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            aCellArrayOfBlocks{iBlockCounter}=SonnetUnknownBlock(aFid,aTempString);
                            iBlockCounter=iBlockCounter+1;
                            
                        case 'SMDFILES'
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            % The aFid should now be right after the 'SMDFILES'
                            %   tag.  We can now create a component file object
                            %   by constructing it and passing along the aFid.
                            %   the constructor will validate the input
                            %   and create the object.
                            % The result of the read will place the file
                            %   marker right after the 'END SMDFILES' tag.
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            aComponentFileBlock = SonnetComponentFileBlock(aFid);
                            aCellArrayOfBlocks{iBlockCounter}=aComponentFileBlock;
                            iBlockCounter=iBlockCounter+1;
                            
                            
                        otherwise
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            % In all other cases we want to put it into
                            % an 'Unknown' block. The user can not interact
                            % with the unknown block, it is kept only for
                            % consistency.
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            if ~isempty(aTempString)
                                aCellArrayOfBlocks{iBlockCounter}=SonnetUnknownBlock(aFid,aTempString);
                                iBlockCounter=iBlockCounter+1;
                            end
                            
                    end
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % Read a string from the file,
                    % we will use this to determine what
                    % block is being initialized.
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    aTempString=fgetl(aFid);    % Read a value from the file, we will be using this to drive the switch statment
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % Check if the value that we read is the EOF, If the fgetl had
                    % determined that we are at the end of the file it will set feof.
                    % feof is set when the line AFTER the one that is read is EOF; so
                    % the data we read in this iteration is still valid. See help
                    % feof for more information.
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    if (feof(aFid)==1)        	% If we are at the end of the file
                        break;                  % break out of the loop because we are at the end of the file
                    else
                        aTempString=strtrim(aTempString);
                    end
                    
                end
                
                fclose(aFid);
                                
                % Copy all the values to the properties
                obj.VersionOfSonnet=aVersionOfSonnet;
                obj.CellArrayOfBlocks=aCellArrayOfBlocks;
                obj.isValidProjectVersion=aisValidProjectVersion;
                obj.Filename=aFilename;
                obj.FilePath=aFilePath;
                
                % Copy all the blocks to the properties
                obj.HeaderBlock=aHeaderBlock;
                obj.DimensionBlock=aDimensionBlock;
                obj.FrequencyBlock=aFrequencyBlock;
                obj.ControlBlock=aControlBlock;
                obj.OptimizationBlock=aOptimizationBlock;
                obj.VariableSweepBlock=aVariableSweepBlock;
                obj.CircuitElementsBlock=aCircuitElementsBlock;
                obj.ParameterBlock=aParameterBlock;
                obj.FileOutBlock=aFileOutBlock;
                obj.GeometryBlock=aGeometryBlock;
                obj.ComponentFileBlock=aComponentFileBlock;
                
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function initialize(obj)
            % initialize   Initializes a Sonnet geometry project
            %   Project.Initialize() initializes a project to default
            %   values for a Sonnet geometry project.
            %
            % See also  SonnetProject.initializeNetlist,
            %           SonnetProject.initializeGeometry
            
            % Specify the default Ftyp string
            obj.VersionOfSonnet='15.52';
            obj.isValidProjectVersion=true;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % We will make a default instance of all the
            %   objects using their individual zero argument
            %   constructors which call their initialize
            %   methods
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.HeaderBlock=SonnetHeaderBlock();
            obj.DimensionBlock=SonnetDimensionBlock();
            obj.FrequencyBlock=SonnetFrequencyBlock();
            obj.ControlBlock=SonnetControlBlock();
            obj.GeometryBlock=SonnetGeometryBlock();
            obj.OptimizationBlock=SonnetOptimizationBlock();
            obj.VariableSweepBlock=SonnetVariableSweepBlock();
            obj.FileOutBlock=SonnetFileOutBlock();
            obj.ComponentFileBlock=SonnetComponentFileBlock();
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % We dont want an circuit block in geometry projects
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.CircuitElementsBlock=[];
            obj.ParameterBlock=[];
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Add all the block objects to the cell array
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.CellArrayOfBlocks=[];
            obj.CellArrayOfBlocks{1}=obj.HeaderBlock;
            obj.CellArrayOfBlocks{2}=obj.DimensionBlock;
            obj.CellArrayOfBlocks{3}=obj.FrequencyBlock;
            obj.CellArrayOfBlocks{4}=obj.ControlBlock;
            obj.CellArrayOfBlocks{5}=obj.GeometryBlock;
            obj.CellArrayOfBlocks{6}=obj.OptimizationBlock;
            obj.CellArrayOfBlocks{7}=obj.VariableSweepBlock;
            obj.CellArrayOfBlocks{8}=obj.FileOutBlock;
            obj.CellArrayOfBlocks{9}=obj.ComponentFileBlock;
            
            obj.AutoDelete=false;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function initializeGeometry(obj)
            % initializeGeometry   Initializes a Sonnet geometry project
            %   Project.initializeGeometry() initializes a project to the
            %   default values for a Sonnet geometry project.
            %
            % See also SonnetProject.initialize,
            %          SonnetProject.initializeNetlist
            obj.initialize();
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function initializeNetlist(obj)
            % initializeNetlist   Initializes a Sonnet netlist project
            %   Project.initializeNetlist() initializes a project
            %   to the default values for a Sonnet netlist project.
            %
            % See also  SonnetProject.initialize,
            %           SonnetProject.initializeGeometry
            
            % Specify the default Ftyp string
            obj.VersionOfSonnet='14.54';
            obj.isValidProjectVersion=true;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % We will make a default instance of all the
            %   objects using their individual zero argument
            %   constructors which call their initialize
            %   methods
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.HeaderBlock=SonnetHeaderBlock();
            obj.DimensionBlock=SonnetDimensionBlock();
            obj.FrequencyBlock=SonnetFrequencyBlock();
            obj.ControlBlock=SonnetControlBlock();
            obj.OptimizationBlock=SonnetOptimizationBlock();
            obj.VariableSweepBlock=SonnetVariableSweepBlock();
            obj.FileOutBlock=SonnetFileOutBlock();
            obj.CircuitElementsBlock=SonnetCircuitBlock();
            obj.ParameterBlock=SonnetVariableBlock();
            
            % Change some default values in control block
            obj.ControlBlock.Push=true;
            obj.ControlBlock.Options='';
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % We dont want an geometry block in netlists
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.GeometryBlock=[];
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Add all the block objects to a cell array
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.CellArrayOfBlocks=[];
            obj.CellArrayOfBlocks{1}=obj.HeaderBlock;
            obj.CellArrayOfBlocks{2}=obj.DimensionBlock;
            obj.CellArrayOfBlocks{3}=obj.FrequencyBlock;
            obj.CellArrayOfBlocks{4}=obj.ControlBlock;
            obj.CellArrayOfBlocks{5}=obj.OptimizationBlock;
            obj.CellArrayOfBlocks{6}=obj.VariableSweepBlock;
            obj.CellArrayOfBlocks{7}=obj.ParameterBlock;
            obj.CellArrayOfBlocks{8}=obj.CircuitElementsBlock;
            obj.CellArrayOfBlocks{9}=obj.FileOutBlock;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aNewProject=clone(obj)
            % clone   Initializes a replica project
            %   newProject=Project.clone() will return a deep copy of a
            %   Sonnet project. The copy will have all the same values for
            %   the class properties but will contain completely separate
            %   handles.
            %
            %   The new project will have no filename associated
            %   with it but it may be saved with the saveAs()
            %   command.
            %
            %   Example usage:
            %
            %       % Create a new Sonnet project object
            %       Project1=SonnetProject('project.son');
            %
            %       % Clone the project
            %       Project2=Project1.clone();
            %
            %       % Any modifications made to Project1
            %       % or Project2 will not affect the
            %       % other project.
            %
            % See also  SonnetProject.quickClone
            
            if obj.isValidProjectVersion
                
                % Create a new Sonnet Project
                aNewProject=SonnetProject();
                
                % Copy the version number
                aNewProject.VersionOfSonnet=obj.VersionOfSonnet;
                
                % Clear the cell array of blocks
                aNewProject.CellArrayOfBlocks=cell(1,length(obj.CellArrayOfBlocks));
                iBlockCounter=1;
                
                % Clone the blocks
                if ~isempty(obj.HeaderBlock)
                    aNewProject.HeaderBlock=obj.HeaderBlock.clone();
                    aNewProject.CellArrayOfBlocks{iBlockCounter}=aNewProject.HeaderBlock;
                    iBlockCounter=iBlockCounter+1;
                else
                    aNewProject.HeaderBlock=[];
                end
                if ~isempty(obj.DimensionBlock)
                    aNewProject.DimensionBlock=obj.DimensionBlock.clone();
                    aNewProject.CellArrayOfBlocks{iBlockCounter}=aNewProject.DimensionBlock;
                    iBlockCounter=iBlockCounter+1;
                else
                    aNewProject.DimensionBlock=[];
                end
                if ~isempty(obj.FrequencyBlock)
                    aNewProject.FrequencyBlock=obj.FrequencyBlock.clone();
                    aNewProject.CellArrayOfBlocks{iBlockCounter}=aNewProject.FrequencyBlock;
                    iBlockCounter=iBlockCounter+1;
                else
                    aNewProject.FrequencyBlock=[];
                end
                if ~isempty(obj.ControlBlock)
                    aNewProject.ControlBlock=obj.ControlBlock.clone();
                    aNewProject.CellArrayOfBlocks{iBlockCounter}=aNewProject.ControlBlock;
                    iBlockCounter=iBlockCounter+1;
                else
                    aNewProject.ControlBlock=[];
                end
                if ~isempty(obj.GeometryBlock) && ~isstruct(obj.GeometryBlock)
                    aNewProject.GeometryBlock=obj.GeometryBlock.clone();
                    aNewProject.CellArrayOfBlocks{iBlockCounter}=aNewProject.GeometryBlock;
                    iBlockCounter=iBlockCounter+1;
                else
                    aNewProject.GeometryBlock=[];
                end
                if ~isempty(obj.OptimizationBlock)
                    aNewProject.OptimizationBlock=obj.OptimizationBlock.clone();
                    aNewProject.CellArrayOfBlocks{iBlockCounter}=aNewProject.OptimizationBlock;
                    iBlockCounter=iBlockCounter+1;
                else
                    aNewProject.OptimizationBlock=[];
                end
                if ~isempty(obj.VariableSweepBlock)
                    aNewProject.VariableSweepBlock=obj.VariableSweepBlock.clone();
                    aNewProject.CellArrayOfBlocks{iBlockCounter}=aNewProject.VariableSweepBlock;
                    iBlockCounter=iBlockCounter+1;
                else
                    aNewProject.VariableSweepBlock=[];
                end
                if ~isempty(obj.CircuitElementsBlock)
                    aNewProject.CircuitElementsBlock=obj.CircuitElementsBlock.clone();
                    aNewProject.CellArrayOfBlocks{iBlockCounter}=aNewProject.CircuitElementsBlock;
                    iBlockCounter=iBlockCounter+1;
                else
                    aNewProject.CircuitElementsBlock=[];
                end
                if ~isempty(obj.ParameterBlock)
                    aNewProject.ParameterBlock=obj.ParameterBlock.clone();
                    aNewProject.CellArrayOfBlocks{iBlockCounter}=aNewProject.ParameterBlock;
                    iBlockCounter=iBlockCounter+1;
                else
                    aNewProject.ParameterBlock=[];
                end
                if ~isempty(obj.FileOutBlock)
                    aNewProject.FileOutBlock=obj.FileOutBlock.clone();
                    aNewProject.CellArrayOfBlocks{iBlockCounter}=aNewProject.FileOutBlock;
                    iBlockCounter=iBlockCounter+1;
                else
                    aNewProject.FileOutBlock=[];
                end 
                if ~isempty(obj.ComponentFileBlock)
                    aNewProject.ComponentFileBlock=obj.ComponentFileBlock.clone();
                    aNewProject.CellArrayOfBlocks{iBlockCounter}=aNewProject.ComponentFileBlock;
                    iBlockCounter=iBlockCounter+1;
                else
                    aNewProject.ComponentFileBlock=[];
                end 
                
                % Call the clone function for each
                % of the unknown blocks in our cell array.
                for iCounter= 1:length(obj.CellArrayOfBlocks)
                    if isa(obj.CellArrayOfBlocks{iCounter},'SonnetUnknownBlock')
                        aNewProject.CellArrayOfBlocks{iBlockCounter}=obj.CellArrayOfBlocks{iCounter}.clone();
                        iBlockCounter=iBlockCounter+1;
                    end
                end
                
            else
                disp('This project object is invalid; it can not be cloned. This is most likely because the project object was constructed for too old of an Sonnet project.  This script is only intended for versions 12 and 13.');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aNewProject=quickClone(obj)
            % quickClone   Initializes a replica project
            %   newProject=Project.quickClone() will return a deep
            %   copy of a Sonnet project. The copy will have all the
            %   same values for the class properties but will contain
            %   completely separate handles.
            %
            %   The new project will have no filename associated
            %   with it but it may be saved with the saveAs()
            %   command.
            %
            %   This method is typically much faster than clone()
            %   but requires a disk operation.
            %
            %   Example usage:
            %
            %       % Create a new Sonnet project object
            %       Project1=SonnetProject('project.son');
            %
            %       % Clone the project
            %       Project2=Project1.quickClone();
            %
            %       % Any modifications made to Project1
            %       % or Project2 will not affect the
            %       % other project.
            %
            % See also  SonnetProject.clone
            
            % Save the project as a file
            save 'temp.mat' obj
            
            % Load the project from file
            aNewProject=load('temp.mat');
            aNewProject=aNewProject.obj;
            
            % Delete the file
            delete 'temp.mat';
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [isEqual, aOutput]=compare(obj,theSonnetProject)
            %compare   Compares two Sonnet Projects for equivalency
            %   [isEqual aOutput]=aFirstProject.compare(aSecondProject) compares
            %   the data stored in aFirstProject to the data for
            %   aSecondProject. isEqual is true if the two projects
            %   are the same. aOutput stores the data that came out
            %   of the comparison engine.
            %
            %   [isEqual aOutput]=aFirstProject.compare(filename) compares
            %   the data stored in aFirstProject to the data for
            %   the Sonnet project represented by filename. isEqual
            %   is true if the two projects are the same. aOutput
            %   stores the data that came out of the comparison engine.
            %
            %   Example usage:
            %       aFirstProject=SonnetProject('myProject1.son');
            %       aSecondProject=SonnetProject('myProject2.son');
            %       isEqual=aFirstProject.compare(aSecondProject);
            %
            % See also SonnetProject.addFrequencySweep
            
            % Save the passed project as 'Temp1.son'
            if isa(theSonnetProject,'SonnetProject')
                aFilename=theSonnetProject.Filename;
                aPath=theSonnetProject.FilePath;
                theSonnetProject.saveAs('Temp1.son');
                theSonnetProject.Filename=aFilename;
                theSonnetProject.FilePath=aPath;
            else
                copyfile(theSonnetProject,'Temp1.son')
            end
            
            % Save the executing project as 'Temp2.son'
            aFilename=obj.Filename;
            aPath=obj.FilePath;
            obj.saveAs('Temp2.son');
            obj.Filename=aFilename;
            obj.FilePath=aPath;
            
            % Call Sonnet's SSDIFF to compare the projects
            aSonnetPath=SonnetPath();
            if isunix
                aCallToSystem=['"' aSonnetPath filesep 'bin' filesep 'ssdiff" -V geo ' 'Temp1.son ' 'Temp2.son"'];
            else
                aCallToSystem=['"' aSonnetPath filesep 'bin' filesep 'ssdiff.exe" -V geo ' 'Temp1.son ' 'Temp2.son"'];
            end
            [aStatus, aOutput]=system(aCallToSystem);
            isEqual=~aStatus;
            
            % Delete the temporary files
            delete 'Temp1.son';
            delete 'Temp2.son';
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function isGeoProject=isGeometryProject(obj)
            %isGeometryProject   Checks project type
            %   Boolean=Project.isGeometryProject returns true if the
            %   project is a geometry project; it returns
            %   false if it is a netlist project.
            %
            %   Example usage:
            %       if Project.isGeometryProject()
            %           ....
            %       end
            %
            % See also SonnetProject.isNetlistProject
            
            if ~isempty(obj.GeometryBlock)
                isGeoProject=true;
            else
                isGeoProject=false;
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function isNetProject=isNetlistProject(obj)
            %isNetlistProject   Checks project type
            %   Boolean=Project.isNetlistProject returns true if the
            %   project is a netlist project; it returns
            %   false if it is a geometry project.
            %
            %   Example usage:
            %       if Project.isNetlistProject()
            %           ....
            %       end
            %
            % See also SonnetProject.isNetlistProject
            
            if ~isempty(obj.CircuitElementsBlock)
                isNetProject=true;
            else
                isNetProject=false;
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function save(obj)
            %save   Saves a project to the hard drive
            %   Project.save() writes the project to a file.
            %   The file will be saved to the same filename
            %   as was used by the most recent call to saveAs. If
            %   saveAs has never been called it will use the name of
            %   the file that was originally opened by SonnetProject.
            %   If the project was made from scratch and has never
            %   been saved with savesAs then an error will be thrown.
            %
            %   Example usage:
            %       Project.save();
            %
            % See also SonnetProject.saveAs
            
            % Check to see if this is a valid Sonnet Project
            
            if ~obj.checkIsValid()
               error('Please fix the above the above problems to save the project'); 
            end
            
            if obj.isValidProjectVersion	% If the project was indicated to be valid then we write out the project. Otherwise dont write it out.
                
                % Check the optimization variables when autodelete is true
                if obj.AutoDelete
                    obj.checkOptimizationVariables();
                end
                
                % Open the file for writing
                if isempty(obj.Filename)
                    error('There is no filename associated with this project. Please do saveAs.');
                else
                    aFid = fopen([obj.FilePath obj.Filename], 'w');
                end
                
                % Find the version number
                if (~isempty(obj.VersionOfSonnet))
                    if isa(obj.VersionOfSonnet,'char')
                        aVersion=sscanf(obj.VersionOfSonnet,'%d'); % Extract the first two digits of the version number
                    else
                        aVersion=obj.VersionOfSonnet;
                    end
                end
                
                % If the project is an invalid version (less than 12)
                % then throw and error.
                if floor(aVersion)<12
                    error('Improper Sonnet Version Specified. Please change the value of ''VersionOfSonnet''');
                end
                
                % Write the FTYP line for the Sonnet Project
                if obj.isGeometryProject()
                    if floor(aVersion) == 12
                        fprintf(aFid, 'FTYP SONPROJ 4 ! Sonnet Project File\n');
                    elseif floor(aVersion) == 13
                        fprintf(aFid, 'FTYP SONPROJ 10 ! Sonnet Project File\n');
                    elseif floor(aVersion) == 14
                        fprintf(aFid, 'FTYP SONPROJ 12 ! Sonnet Project File\n');
                    elseif floor(aVersion) == 15
                        fprintf(aFid, 'FTYP SONPROJ 13 ! Sonnet Project File\n');
                    else
                        error('Unknown version');
                    end
                else
                    if floor(aVersion) == 12
                        fprintf(aFid, 'FTYP SONNETPRJ 4 ! Sonnet Netlist Project File\n');
                    elseif floor(aVersion) == 13
                        fprintf(aFid, 'FTYP SONNETPRJ 10 ! Sonnet Netlist Project File\n');
                    elseif floor(aVersion) == 14
                        fprintf(aFid, 'FTYP SONNETPRJ 12 ! Sonnet Netlist Project File\n');
                    elseif floor(aVersion) == 15
                        fprintf(aFid, 'FTYP SONNETPRJ 13 ! Sonnet Netlist Project File\n');
                    else
                        error('Unknown version');
                    end
                end
                
                % If there is a Ver value then write it to the file and
                if (~isempty(obj.VersionOfSonnet))
                    if isa(obj.VersionOfSonnet,'char')
                        fprintf(aFid, 'VER %s\n',obj.VersionOfSonnet);
                    else
                        fprintf(aFid, 'VER %.15g\n',obj.VersionOfSonnet);
                    end
                end
                
                % Call the writeGuts function in each of the objects that
                % we have in our cell array.
                for iCounter= 1:length(obj.CellArrayOfBlocks)
                    obj.CellArrayOfBlocks{iCounter}.writeObjectContents(aFid,aVersion);
                end
                
                fclose(aFid);
                
                % If the folder does not exist create it
                if ~(exist([obj.FilePath '.' filesep 'sondata' filesep strrep(obj.Filename,'.son','')],'dir')==7) % If the directory does not exist
                    mkdir([obj.FilePath '.' filesep 'sondata' filesep strrep(obj.Filename,'.son','')]);
                end
                
            else
                disp('This project object is invalid; it can not be written to file. This is most likely because the project object was constructed for too old of an Sonnet project.  This script is only intended for versions 10,11 and 12.');
                
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function saveAs(obj, theFilename, isClean)
            %saveAs   Saves a project to the hard drive
            %   Project.saveAs(Filename) writes the Sonnet project to a
            %	file on the hard drive with the specified filename. If 
            %   the operation involves overwritting a pre-existing project
            %   file the old project's simulation data will be deleted.
            %
            %   Project.saveAs(Filename,clean) writes the Sonnet project 
            %	to a file on the hard drive with the specified filename. 
            %   If the clean argument is a boolean true then any preexisting 
            %   simulation data will be removed.
            %
            %   Note: This function will change the internal filename
            %   property for the project such that future calls to save() 
            %   will save to this filename rather than the original filename.
            %
            %   Note: Be careful when using the optional argument to not
            %   clear project data. Simulation results from the overwritten
            %   project may not be consistant with the new project and may
            %   provide incorrect simulation results.
            %
            %   Example usage:
            %
            %       % Save the project as 'project.son'
            %       Project.saveAs('project.son');
            %
            %       % Save the project as 'project2.son' and will not
            %       % delete simulation data which existed for the old
            %       % version of the project.
            %       Project.saveAs('project.son');
            %
            % See also SonnetProject.save
            
            % If the filename is improper then throw an error
            if ~isa(theFilename,'char')
                error('You must provide a valid filename for saving');
            else
                % Extract the path from the filename
                aRemainingPath=theFilename;
                while ~isempty(aRemainingPath)
                    [aPartialPath, aRemainingPath]=strtok(aRemainingPath,filesep); %#ok<STTOK>
                end
                
                % Save the filename and filepath
                obj.Filename=aPartialPath;
                obj.FilePath=strrep(theFilename,aPartialPath,'');
                
                % Save the project
                obj.save();
                
                % Clean the project if the optional argument is not
                % used or if the optional argument indicates such
                if nargin == 2 || isClean
                    obj.cleanProject();
                end
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aSignature=stringSignature(obj)
            %stringSignature   Returns the project file as a string
            %   string=Project.stringSignature() returns a string which would
            %   contain all the information that would normally
            %   be present when saving a project to the disk.
            %
            %   Example usage:
            %       aString=Project.stringSignature();
            %
            % See also SonnetProject.save
            
            % Check the optimization variables
            obj.checkOptimizationVariables();
            
            % Build the string
            if obj.isValidProjectVersion
                
                % Find the version number
                if (~isempty(obj.VersionOfSonnet))
                    if isa(obj.VersionOfSonnet,'char')
                        aVersion=sscanf(obj.VersionOfSonnet,'%d'); % Extract the first two digits of the version number
                    else
                        aVersion=obj.VersionOfSonnet;
                    end
                end
                
                % If the project is an invalid version (less than 12)
                % then throw and error.
                if floor(aVersion)<12
                    error('Improper Sonnet Version specified. Please change the value of ''VersionOfSonnet''');
                end
                
                if obj.isGeometryProject()
                    if floor(aVersion) == 12
                        aSignature = sprintf('FTYP SONPROJ 4 ! Sonnet Project File\n');
                    elseif floor(aVersion) == 13
                        aSignature = sprintf('FTYP SONPROJ 6 ! Sonnet Project File\n');
                    else
                        error('Unknown version');
                    end
                else
                    if floor(aVersion) == 12
                        aSignature = sprintf('FTYP SONNETPRJ 4 ! Sonnet Netlist Project File\n');
                    elseif floor(aVersion) == 13
                        aSignature = sprintf('FTYP SONNETPRJ 6 ! Sonnet Netlist Project File\n');
                    else
                        error('Unknown version');
                    end
                end
                
                % If there is a VER line then display it
                if (~isempty(obj.VersionOfSonnet))
                    aSignature = [aSignature sprintf('VER %s\n',obj.VersionOfSonnet)];
                end
                
                % Call the stringSignature function for all the blocks
                for iCounter= 1:length(obj.CellArrayOfBlocks)
                    aSignature = [aSignature obj.CellArrayOfBlocks{iCounter}.stringSignature(aVersion)]; %#ok<AGROW>
                end
                
            else
                disp(['This project object is invalid; it can not be written to file. '...
                    'This is most likely because the project object was constructed for '...
                    'too old of an Sonnet project.  This script is only intended '...
                    'for versions 10,11 and 12.']);
                
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function displayPolygons(obj,theOptions)
            %displayPolygons   Displays polygon information
            %   Project.displayPolygons() will print out
            %   the index, ID, centroid point, mean point,
            %   type, level and metal type for all the
            %   polygons in the project.
            %
            %   displayPolygons('Short') will print out
            %   the index, ID, centroid point, mean point,
            %   type, level and metal type for all the
            %   polygons in the project.
            %
            %   displayPolygons('Long') will print
            %   all of the properties for all of
            %   the polygons in the project.
            %
            %   Note: This method is only for geometry projects.
            %
            %   See also SonnetProject.drawCircuit
            
            if obj.isGeometryProject
                if nargin ==1
                    obj.GeometryBlock.displayPolygons();
                else
                    obj.GeometryBlock.displayPolygons(theOptions);
                end
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function FigNum=drawCircuit(obj,FigNum)
            %drawCircuit   3D circuit diagram
            %	n=Project.drawCircuit() will create a new Matlab figure
            %   that will plot a 3D view of the circuit. The
            %   Matlab figure number will be n.
            %
            %   n=drawCircuit(n) will use the Matlab figure
            %   window number n to draw a 3D view of the circuit.
            %
            %   Note: This method is only for geometry projects.
            %   Note: This method is provides the same functionality
            %           as SonnetProject.draw3d
            %
            %   See also SonnetProject.draw3d, SonnetProject.drawLayer,
            %            SonnetProject.draw2d
            if obj.isGeometryProject
                if nargin==2
                    if ismember(FigNum,get(0,'children'))
                        figure(FigNum);
                        [AZ,EL] = view;
                    else
                        figure(FigNum);
                        AZ=-35;
                        EL=30;
                    end
                    clf;
                else
                    FigNum=figure;
                    AZ=-35;
                    EL=30;
                end
                hold on
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Loop for all the polygons in the file.
                % We will read in their x and y values and plot them.
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                XboxLength=obj.GeometryBlock.SonnetBox.XWidthOfTheBox;
                YboxLength=obj.GeometryBlock.SonnetBox.YWidthOfTheBox;
                
                % Store an array of the dielectric layer thicknesses
                anArrayOfThicknesses=[];
                for iCounter=1:length(obj.GeometryBlock.SonnetBox.ArrayOfDielectricLayers)
                    anArrayOfThicknesses=[anArrayOfThicknesses obj.GeometryBlock.SonnetBox.ArrayOfDielectricLayers{iCounter}.Thickness]; %#ok<AGROW>
                end
                
                % Find the Z height of the entire box
                ZboxLength=sum(anArrayOfThicknesses);
                
                % Draw lines for the dielectric layers
                for iCounter=1:length(obj.GeometryBlock.SonnetBox.ArrayOfDielectricLayers)
                    aHandleToTheLayerBoundaryLine=line([0 XboxLength XboxLength 0 0],[0 0 YboxLength YboxLength 0], [1 1 1 1 1]*(ZboxLength-sum(anArrayOfThicknesses(1:iCounter))));
                    set(aHandleToTheLayerBoundaryLine,'Color','r');
                end
                
                for iPlotCounter=1:length(obj.GeometryBlock.ArrayOfPolygons)
                    
                    anArrayOfXValues = cell2mat(obj.GeometryBlock.ArrayOfPolygons{iPlotCounter}.XCoordinateValues);
                    anArrayOfYValues = cell2mat(obj.GeometryBlock.ArrayOfPolygons{iPlotCounter}.YCoordinateValues);
                    
                    % Get the polygon's metallization  index
                    aLevelForPolygon=obj.GeometryBlock.ArrayOfPolygons{iPlotCounter}.MetalizationLevelIndex+2;
                    
                    % Get the Z value for the beginning of the dielectric layer this
                    % polygon is contained in
                    aStartZValue=sum(anArrayOfThicknesses(aLevelForPolygon:length(anArrayOfThicknesses)));
                    
                    % Make Metals purple, Vias orange and bricks blue
                    if strcmpi(obj.GeometryBlock.ArrayOfPolygons{iPlotCounter}.Type,'VIA POLYGON')==1
                        aColorValue=[1 .5 .2];
                    elseif strcmpi(obj.GeometryBlock.ArrayOfPolygons{iPlotCounter}.Type,'BRI POLY')==1
                        aColorValue=[.4 .8 .8];
                    else
                        aColorValue=[1 0 1];
                    end
                    
                    % Draw the Bottom
                    anArrayOfZValues = ones(length(anArrayOfXValues))*(aStartZValue);
                    aFigure=fill3(anArrayOfXValues,anArrayOfYValues,anArrayOfZValues,aColorValue);
                    set(aFigure,'FaceAlpha',.8)
                    
                    % Find the end Z value for the area to draw if it is a
                    % dielectric brick or a via polygon
                    if strcmpi(obj.GeometryBlock.ArrayOfPolygons{iPlotCounter}.Type,'VIA POLYGON')==1
                        
                        % Store the where the via is connected to into a
                        % variable for simplisity
                        aLevelTheViaIsConnectedTo=obj.GeometryBlock.ArrayOfPolygons{iPlotCounter}.LevelTheViaIsConnectedTo;
                        
                        if strcmp(aLevelTheViaIsConnectedTo,'GND')==1
                            aEndZValue=0;
                        elseif strcmp(aLevelTheViaIsConnectedTo,'TOP')==1
                            aEndZValue=ZboxLength;
                        else
                            % Find the Z area length to the
                            % level the via is connected to.
                            aLevelTheViaIsConnectedTo=aLevelTheViaIsConnectedTo+2;
                            aEndZValue=sum(anArrayOfThicknesses(aLevelTheViaIsConnectedTo:length(anArrayOfThicknesses)));
                        end
                        
                        % if the end value is less than the start value then
                        % switch them just to make it easier to understand
                        if aEndZValue < aStartZValue
                            aTempValue=aEndZValue;
                            aEndZValue=aStartZValue;
                            aStartZValue=aTempValue;
                        end
                        
                    elseif strcmpi(obj.GeometryBlock.ArrayOfPolygons{iPlotCounter}.Type,'BRI POLY')==1
                        aEndZValue=sum(anArrayOfThicknesses(aLevelForPolygon-1:length(anArrayOfThicknesses)));
                        
                    end
                    
                    % Only draw the top and sides if it is not a metal
                    if ~isempty(obj.GeometryBlock.ArrayOfPolygons{iPlotCounter}.Type)
                        
                        % Draw the Top
                        anArrayOfZValues = ones(length(anArrayOfXValues))*(aEndZValue);
                        aFigure=fill3(anArrayOfXValues,anArrayOfYValues,anArrayOfZValues,aColorValue);
                        set(aFigure,'FaceAlpha',.8)
                        
                        % Draw The sides of the polygon
                        for iCounter=1:length(obj.GeometryBlock.ArrayOfPolygons{iPlotCounter}.XCoordinateValues)-1
                            
                            % Calculate the X, Y and Z coordinates for the side of the polygon
                            anArrayOfXValues = [obj.GeometryBlock.ArrayOfPolygons{iPlotCounter}.XCoordinateValues{iCounter} obj.GeometryBlock.ArrayOfPolygons{iPlotCounter}.XCoordinateValues{iCounter+1} obj.GeometryBlock.ArrayOfPolygons{iPlotCounter}.XCoordinateValues{iCounter+1} obj.GeometryBlock.ArrayOfPolygons{iPlotCounter}.XCoordinateValues{iCounter}];
                            anArrayOfYValues = [obj.GeometryBlock.ArrayOfPolygons{iPlotCounter}.YCoordinateValues{iCounter} obj.GeometryBlock.ArrayOfPolygons{iPlotCounter}.YCoordinateValues{iCounter+1} obj.GeometryBlock.ArrayOfPolygons{iPlotCounter}.YCoordinateValues{iCounter+1} obj.GeometryBlock.ArrayOfPolygons{iPlotCounter}.YCoordinateValues{iCounter}];
                            anArrayOfZValues = [aEndZValue aEndZValue aStartZValue aStartZValue];
                            
                            % Draw the side and change the opacity
                            aFigure=fill3(anArrayOfXValues,anArrayOfYValues,anArrayOfZValues,aColorValue);
                            set(aFigure,'FaceAlpha',.8)
                            
                        end
                    end
                end
                
                % Make a line at edges with ports
                for iPlotCounter=1:length(obj.GeometryBlock.ArrayOfPorts)
                    
                    % Find the polygon that the port is connected to
                    aPolygon=obj.GeometryBlock.ArrayOfPorts{iPlotCounter}.Polygon;
                    aVertex=obj.GeometryBlock.ArrayOfPorts{iPlotCounter}.Vertex;
                    
                    % Get the polygon's metallization  index
                    aLevelForPolygon=aPolygon.MetalizationLevelIndex+2;
                    
                    % Get the Z value for the beginning of the dielectric layer this
                    % polygon is contained in
                    aZValue=sum(anArrayOfThicknesses(aLevelForPolygon:length(anArrayOfThicknesses)));
                    
                    % Find the X, Y and Z coordinates
                    aLineXCoordinates=[aPolygon.XCoordinateValues{aVertex} aPolygon.XCoordinateValues{aVertex+1}];
                    aLineYCoordinates=[aPolygon.YCoordinateValues{aVertex} aPolygon.YCoordinateValues{aVertex+1}];
                    aLineZCoordinates=[aZValue aZValue];
                    
                    % Draw the line for the port
                    aLine=line(aLineXCoordinates,aLineYCoordinates,aLineZCoordinates);
                    set(aLine,'LineWidth',3);
                    set(aLine,'Color',[0 1 0]);
                    
                    % Draw the port label
                    aLabelText=num2str(obj.GeometryBlock.ArrayOfPorts{iPlotCounter}.PortNumber);
                    text(mean(aLineXCoordinates),mean(aLineYCoordinates),mean(aLineZCoordinates),aLabelText,'FontSize',14);
                    
                end
                
                grid on
                hold off
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Set the axis to be the proper size for the box.
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                axis([0 (XboxLength) 0 (YboxLength)]);
                line([0 XboxLength XboxLength 0 0],[0 0 YboxLength YboxLength 0], [1 1 1 1 1]*ZboxLength);
                line([0 XboxLength XboxLength 0 0],[0 0 YboxLength YboxLength 0], [1 1 1 1 1]*0);
                line([1 1]*0,[1 1]*0,[0 1]*ZboxLength);
                line([1 1]*XboxLength,[1 1]*0,[0 1]*ZboxLength);
                line([1 1]*XboxLength,[1 1]*YboxLength,[0 1]*ZboxLength);
                line([1 1]*0,[1 1]*YboxLength,[0 1]*ZboxLength);
                
                % find good major tick sizes
                axCellSize=obj.GeometryBlock.xCellSize();
                anMajorXTick=0:axCellSize:XboxLength;
                while length(anMajorXTick)>20
                    axCellSize=axCellSize*2;
                    anMajorXTick=0:axCellSize:XboxLength;
                end
                
                ayCellSize=obj.GeometryBlock.yCellSize();
                anMajorYTick=0:ayCellSize:YboxLength;
                while length(anMajorYTick)>20
                    ayCellSize=ayCellSize*2;
                    anMajorYTick=0:ayCellSize:YboxLength;
                end
                
                % change the grid
                anAxis=get(gcf,'CurrentAxes');
                set(anAxis,'XTick',anMajorXTick);
                set(anAxis,'YTick',anMajorYTick);
                
                % Invert the axis
                set(gca,'Ydir','reverse')
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Draw out the demo circuit
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                view(AZ,EL)
                axis vis3d
                axis equal
                
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function FigNum=draw3d(obj,FigNum)
            %draw3d   3D circuit diagram
            %	n=Project.draw3d() will create a new Matlab figure
            %   that will plot a 3D view of the circuit. The
            %   Matlab figure number will be n.
            %
            %   n=drawCircuit(n) will use the Matlab figure
            %   window number n to draw a 3D view of the circuit.
            %
            %   Note: This method is only for geometry projects.
            %   Note: This method is provides the same functionality
            %           as SonnetProject.drawCircuit
            %
            %   See also SonnetProject.drawCircuit, SonnetProject.drawLayer,
            %            SonnetProject.draw2d
            
            if nargin == 1
                FigNum=obj.drawCircuit();
            else
                FigNum=obj.drawCircuit(FigNum);
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function drawLayer(obj,theLevelNumber)
            %drawLayer   2D circuit diagram
            %	Project.drawLayer(theLevelNumber) will create
            %   a new Matlab figure that will plot a 2D view of
            %   the specified metalization level of the circuit.
            %
            %   Note: This method is only for geometry projects.
            %   Note: This method is provides the same functionality
            %           as SonnetProject.draw2d
            %
            %   See also SonnetProject.drawCircuit, SonnetProject.draw2d,
            %            SonnetProject.draw3d
            
            if obj.isGeometryProject
                
                figure;
                set(gca,'Ydir','reverse')
                hold on
                
                if nargin == 1
                    theLevelNumber=0;
                end
                
                % Loop for all the polygons in the file.
                % if they are on the proper level then we will plot them.
                % this iteration we will plot planar metals only.
                for iPlotCounter=1:length(obj.GeometryBlock.ArrayOfPolygons);
                    
                    % if the polygon is on a different level then go to the next
                    % polygon in the array of polygons.
                    if obj.GeometryBlock.ArrayOfPolygons{iPlotCounter}.MetalizationLevelIndex ~= theLevelNumber || ...
                            strcmpi(obj.GeometryBlock.ArrayOfPolygons{iPlotCounter}.Type,'')==0
                        continue;
                    end
                    
                    % Draw the polygon
                    anArrayOfXValues = cell2mat(obj.GeometryBlock.ArrayOfPolygons{iPlotCounter}.XCoordinateValues);
                    anArrayOfYValues = cell2mat(obj.GeometryBlock.ArrayOfPolygons{iPlotCounter}.YCoordinateValues);
                    fill(anArrayOfXValues,anArrayOfYValues,[1 0 1]);
                    
                    % Add text to display the polygon's debugId
                    aTextXLocation=obj.GeometryBlock.ArrayOfPolygons{iPlotCounter}.CentroidXCoordinate;
                    aTextYLocation=obj.GeometryBlock.ArrayOfPolygons{iPlotCounter}.CentroidYCoordinate;
                    aString=num2str(obj.GeometryBlock.ArrayOfPolygons{iPlotCounter}.DebugId);
                    text(aTextXLocation,aTextYLocation,aString,'HorizontalAlignment','center')
                    
                end
                % Loop for all the polygons in the file.
                % if they are on the proper level then we will plot them.
                % this iteration we will plot dielectric bricks only.
                for iPlotCounter=1:length(obj.GeometryBlock.ArrayOfPolygons)
                    
                    % if the polygon is on a different level then go to the next
                    % polygon in the array of polygons.
                    if obj.GeometryBlock.ArrayOfPolygons{iPlotCounter}.MetalizationLevelIndex ~= theLevelNumber || ...
                            strcmpi(obj.GeometryBlock.ArrayOfPolygons{iPlotCounter}.Type,'BRI POLY')==0
                        continue;
                    end
                    
                    % Draw the polygon
                    anArrayOfXValues = cell2mat(obj.GeometryBlock.ArrayOfPolygons{iPlotCounter}.XCoordinateValues);
                    anArrayOfYValues = cell2mat(obj.GeometryBlock.ArrayOfPolygons{iPlotCounter}.YCoordinateValues);
                    fill(anArrayOfXValues,anArrayOfYValues,[.4 .8 .8]);
                    
                    % Add text to display the polygon's debugId
                    aTextXLocation=obj.GeometryBlock.ArrayOfPolygons{iPlotCounter}.CentroidXCoordinate;
                    aTextYLocation=obj.GeometryBlock.ArrayOfPolygons{iPlotCounter}.CentroidYCoordinate;
                    aString=num2str(obj.GeometryBlock.ArrayOfPolygons{iPlotCounter}.DebugId);
                    text(aTextXLocation,aTextYLocation,aString,'HorizontalAlignment','center')
                    
                end
                % Loop for all the polygons in the file.
                % if they are on the proper level then we will plot them.
                % this iteration we will plot vias only.
                for iPlotCounter=1:length(obj.GeometryBlock.ArrayOfPolygons)
                    
                    % if the polygon is on a different level then go to the next
                    % polygon in the array of polygons.
                    if obj.GeometryBlock.ArrayOfPolygons{iPlotCounter}.MetalizationLevelIndex ~= theLevelNumber || ...
                            strcmpi(obj.GeometryBlock.ArrayOfPolygons{iPlotCounter}.Type,'VIA POLYGON')==0
                        continue;
                    end
                    
                    % Draw the polygon
                    anArrayOfXValues = cell2mat(obj.GeometryBlock.ArrayOfPolygons{iPlotCounter}.XCoordinateValues);
                    anArrayOfYValues = cell2mat(obj.GeometryBlock.ArrayOfPolygons{iPlotCounter}.YCoordinateValues);
                    fill(anArrayOfXValues,anArrayOfYValues,[1 .5 .2]);
                    
                    % Add text to display the polygon's debugId
                    aTextXLocation=obj.GeometryBlock.ArrayOfPolygons{iPlotCounter}.CentroidXCoordinate;
                    aTextYLocation=obj.GeometryBlock.ArrayOfPolygons{iPlotCounter}.CentroidYCoordinate;
                    aString=num2str(obj.GeometryBlock.ArrayOfPolygons{iPlotCounter}.DebugId);
                    text(aTextXLocation,aTextYLocation,aString,'HorizontalAlignment','center')
                    
                end
                % Loop for all the ports in the file.
                % if they are connected to a polygon on the proper level we will plot them
                % this iteration we will plot ports only.
                for iPlotCounter=1:length(obj.GeometryBlock.ArrayOfPorts)
                    
                    % if the port is on a different level then go to the next
                    % port in the array of ports.
                    aPolygon=obj.GeometryBlock.ArrayOfPorts{iPlotCounter}.Polygon;
                    if aPolygon==-1 || aPolygon.MetalizationLevelIndex ~= theLevelNumber
                        continue;
                    end
                    
                    % determine the coordinates for the box that surrounds the port number
                    aPort = obj.GeometryBlock.ArrayOfPorts{iPlotCounter};
                    anArrayOfXValues = [...
                        aPort.XCoordinate-1*obj.xBoxSize()/100,...
                        aPort.XCoordinate+1*obj.xBoxSize()/100,...
                        aPort.XCoordinate+1*obj.xBoxSize()/100,...
                        aPort.XCoordinate-1*obj.xBoxSize()/100];
                    
                    anArrayOfYValues = [...
                        aPort.YCoordinate-1*obj.yBoxSize()/100,...
                        aPort.YCoordinate-1*obj.yBoxSize()/100,...
                        aPort.YCoordinate+1*obj.yBoxSize()/100,...
                        aPort.YCoordinate+1*obj.yBoxSize()/100];
                    
                    % Determine a location to place the text
                    aTextYValue=aPort.YCoordinate;
                    aTextXValue=aPort.XCoordinate;
                    
                    % Draw the box and the text
                    fill(anArrayOfXValues,anArrayOfYValues,[1 1 1]);
                    text(aTextXValue,aTextYValue,num2str(aPort.PortNumber),'HorizontalAlignment','center');
                    
                end
                
                grid on
                hold off
                
                % draw the boundries for the box
                XboxLength=obj.GeometryBlock.SonnetBox.XWidthOfTheBox;
                YboxLength=obj.GeometryBlock.SonnetBox.YWidthOfTheBox;
                line([0 XboxLength XboxLength 0 0],[0 0 YboxLength YboxLength 0]);
                line([0 XboxLength XboxLength 0 0],[0 0 YboxLength YboxLength 0]);
                
                % find good major tick sizes
                aXCellSize=obj.GeometryBlock.xCellSize();
                anMajorXTick=0:aXCellSize:XboxLength;
                while length(anMajorXTick)>20
                    aXCellSize=aXCellSize*2;
                    anMajorXTick=0:aXCellSize:XboxLength;
                end
                
                aYCellSize=obj.GeometryBlock.yCellSize();
                anMajorYTick=0:aYCellSize:YboxLength;
                while length(anMajorYTick)>20
                    aYCellSize=aYCellSize*2;
                    anMajorYTick=0:aYCellSize:YboxLength;
                end
                
                % change the grid
                anAxis=get(gcf,'CurrentAxes');
                set(anAxis,'XTick',anMajorXTick);
                set(anAxis,'YTick',anMajorYTick);
                axis([(0-.05*XboxLength) (XboxLength+.05*XboxLength) (0-.05*YboxLength) (YboxLength+.05*YboxLength)]);
                
            else
                error('This method is only available for Geometry projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function draw2d(obj,theLevelNumber)
            %draw2d   2D circuit diagram
            %	Project.draw2d(theLevelNumber) will create
            %   a new Matlab figure that will plot a 2D view of
            %   the specified metalization level of the circuit.
            %
            %   Note: This method is only for geometry projects.
            %   Note: This method is provides the same functionality
            %           as SonnetProject.drawLayer
            %
            %   See also SonnetProject.drawCircuit, SonnetProject.drawLayer,
            %            SonnetProject.draw3d
            
            if nargin == 1
                drawLayer(obj)
            else
                drawLayer(obj,theLevelNumber)
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addComment(obj,theString)
            %addComment   Adds a comment to a Sonnet project
            %   Project.addComment(theString) adds passed text
            %   as a new comment stored in the project file.
            %
            %   Note: Comments are stored in the project file but
            %         are not displayed in the Sonnet project editor.
            
            theString = strrep(theString, 'ANN ', '');
            obj.HeaderBlock.UnknownLines = [obj.HeaderBlock.UnknownLines 'ANN ' theString '\n'];            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Sonnet Tool Methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [aStatus, aMessage]=simulate(obj,theOptions)
            %simulate   Simulates Sonnet projects
            %   [success message]=Project.simulate() saves the project and calls
            %   Sonnet em to simulate the Sonnet Project File. If the simulation
            %   is successful then 'success' will be true; otherwise it
            %   will be false. Error messages returned from em will
            %   be stored in 'message'.
            %
            %   [success message]=Project.simulate(Options) saves the project and
            %   calls Sonnet em to simulate the project with some particular options
            %   as defined below. If the simulation is successful then 'success' will
            %   be true; otherwise it will be false. Error messages returned from em
            %   will be stored in 'message'.
            %
            %   Options are passed as a single
            %   string. Order of option switches does not
            %   matter and unknown option switches are
            %   ignored.
            %
            %   Supported option switches:
            %       '-c'             To clean the project data first
            %       '-x'             To not clean the project data first (default)
            %       '-w'             To display a simulation status window (default)
            %       '-t'             To not display a simulation status window
            %       '-r'             To run the simulation instantaneously (default)
            %       '-p'             To not run the simulation instantaneously (requires status window)
            %       '-v' <VERSION>   To use a particular version of Sonnet to do the simulation (PC only)
            %       '-s' <DIRECTORY> To manually specify the Sonnet directory to
            %                        use for the simulation. The directory may either
            %                        be the base Sonnet directory or the version's bin
            %                        directory.
            %
            %   Note: This method will save the project to the hard drive. If
            %         there hasn't been a filename associated with this project
            %         an error will be thrown. A filename may be specified using
            %         the saveAs method (see "help SonnetProject.saveAs")
            %
            %   Example usage:
            %
            %       % The project is written to a file and
            %       % simulated using the GUI status window
            %       aSonnetProject.simulate();
            %
            %       % The project is written to a file and
            %       % simulated without displaying the status window
            %       aSonnetProject.simulate('-t');
            %
            %       % The project is written to a file, cleaned
            %       % and then simulated without a GUI status window
            %       aSonnetProject.simulate('-t -c');
            %
            %       % The project is simulated using the version of Sonnet
            %       % that exists in the specified location.
            %       aSonnetProject.simulate('-s C:\Program Files\sonnet.12.56'); % PC
            %       aSonnetProject.simulate('-s /disku/app/sonnet/13.54'); % Unix
            %
            %   See also SonnetProject.estimateMemoryUsage, SonnetProject.viewResponseData,
            %            SonnetProject.viewCurrents
            
            if nargin == 1 % We didnt receive options
                
                % Save the project
                if isempty(obj.Filename)
                    error('You must do a saveAs before simulating the project');
                else
                    obj.save();
                end
                
                % Call EM to simulate
                [aStatus, aMessage]=SonnetCallEm([obj.FilePath obj.Filename]);
                
            else % We received options
                
                % Save the project
                if isempty(obj.Filename)
                    error('You must do a saveAs before simulating the project');
                else
                    obj.save();
                end
                
                % Call EM to simulate
                [aStatus, aMessage]=SonnetCallEm([obj.FilePath obj.Filename],theOptions);
                
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function openInSonnet(obj,isWaitForGuiToClose,theSonnetDirectory)
            %openInSonnet   Opens a project in the Sonnet GUI
            %   Project.openInSonnet() saves the project and opens it in Sonnet. The
            %   user can then edit the project in Sonnet. Once the user
            %   is done they can close Sonnet and the version of the project
            %   that exists in Matlab will be updated to reflect the changes
            %   made in Sonnet.
            %
            %   openInSonnet(Boolean) takes an argument to specify
            %   whether or not execution of the function should
            %   halt when the Sonnet window is open.  If the argument is
            %   a Boolean true the function will operate under its normal
            %   behavior and launch Sonnet, wait for Sonnet to be
            %   closed and update the changes to the project.  If the
            %   argument is a Boolean false the Sonnet window will be
            %   launched but the execution state will continue and
            %   the project changes will not be saved to the
            %   Sonnet project object that exists in memory (although
            %   changes may be saved to the version that exists on
            %   the hard drive if the save button in the Sonnet is pressed).
            %
            %   openInSonnet(Boolean,Path) takes an argument to specify
            %   whether or not execution of the function should
            %   halt when the Sonnet window is open.  If the argument is
            %   a Boolean true the function will operate under its normal
            %   behavior and launch Sonnet, wait for Sonnet to be
            %   closed and update the changes to the project.  If the
            %   argument is a Boolean false the Sonnet window will be
            %   launched but the execution state will continue and
            %   the project changes will not be saved to the
            %   Sonnet project object that exists in memory (although
            %   changes may be saved to the version that exists on
            %   the hard drive if the save button in the Sonnet is pressed).
            %   The Path value specifies the directory which has the
            %   version of Sonnet that should be used.
            %
            %   Example usage:
            %
            %       % Opens the project with Sonnet and waits for Sonnet to be
            %       % closed. The project's settings will not be updated in Matlab.
            %       aSonnetProject.openInSonnet();
            %           % Or
            %       aSonnetProject.openInSonnet(true);
            %
            %       % Opens the project with Sonnet and does not wait for Sonnet to be
            %       % closed. The project's settings will not be updated in Matlab.
            %       aSonnetProject.openInSonnet(false);
            %
            %       % Opens the project with Sonnet version 12.52. This call will not
            %       % wait for Sonnet to be closed and the project's settings will not
            %       % be updated in Matlab.
            %       aSonnetProject.openInSonnet(false,'C:\Program Files\sonnet.12.52');
            %
            %   See also SonnetProject.openInGui
            
            % Get the location of Sonnet
            if nargin < 3
                Path=SonnetPath();
            else
                % Remove any quotation marks
                Path=strrep(theSonnetDirectory,'"','');
                Path=strtrim(Path);
                Path=strrep(Path, [filesep 'bin'],'');
                
                % If the specified location does not have \bin\em.exe
                % (\bin\em on unix) then it is not a valid Sonnet directory.
                if ispc && ~exist([Path filesep 'bin' filesep 'em.exe'],'file')
                    error(['Invalid Sonnet Directory Specified: ' Path]);
                elseif isunix && ~exist([Path filesep 'bin' filesep 'em'],'file')
                    error(['Invalid Sonnet Directory Specified: ' Path]);
                end
            end
            
            % Save the project
            obj.save();
            
            % Open up Sonnet
            if nargin == 1 || isWaitForGuiToClose
                if isunix
                    aCallToSystem=['"' Path filesep 'bin' filesep 'xgeom" "' obj.FilePath obj.Filename '"'];
                else
                    aCallToSystem=['"' Path filesep 'bin' filesep 'xgeom.exe" "' obj.FilePath obj.Filename '"'];
                end
                system(aCallToSystem);
                
                % Returned from Sonnet re-read the project
                aNewProject=SonnetProject([obj.FilePath obj.Filename]); % Open the new project
                
                % Copy all the blocks from the new project to this project
                obj.HeaderBlock          =   aNewProject.HeaderBlock;
                obj.DimensionBlock       =   aNewProject.DimensionBlock;
                obj.FrequencyBlock       =   aNewProject.FrequencyBlock;
                obj.ControlBlock         =   aNewProject.ControlBlock;
                obj.GeometryBlock        =   aNewProject.GeometryBlock;
                obj.OptimizationBlock    =   aNewProject.OptimizationBlock;
                obj.VariableSweepBlock   =   aNewProject.VariableSweepBlock;
                obj.CircuitElementsBlock =   aNewProject.CircuitElementsBlock;
                obj.ParameterBlock       =   aNewProject.ParameterBlock;
                obj.FileOutBlock         =   aNewProject.FileOutBlock;
                obj.CellArrayOfBlocks    =   aNewProject.CellArrayOfBlocks;
                
            else
                if isunix
                    aCallToSystem=['"' Path filesep 'bin' filesep 'xgeom" "' obj.FilePath obj.Filename '" & '];
                else
                    aCallToSystem=['"' Path filesep 'bin' filesep 'xgeom.exe" "' obj.FilePath obj.Filename '" & '];
                end
                system(aCallToSystem);
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function viewResponseData(obj, theSonnetDirectory)
            %viewResponseData   Launches emgraph
            %   Project.viewResponseData() will open the project's response data
            %   using Sonnet's built in response analysis tool emgraph.
            %   The project must be simulated before viewing response files.
            %
            %   Project.viewResponseData(Path) will open the project's response data
            %   using Sonnet's built in response analysis tool emgraph. The method
            %   will use the version of Sonnet located at the specified directory.
            %   The project must be simulated before viewing response files.
            %
            %   Example:
            %       % View response using the default version of Sonnet
            %       viewResponseData();
            %
            %       % View response using a particular version of Sonnet
            %       viewResponseData('C:\Program Files\sonnet.12.52')
            
            %   See also SonnetProject.viewCurrents
            
            % Get the location of Sonnet
            if nargin == 1
                Path=SonnetPath();
            else
                % Remove any quotation marks
                Path=strrep(theSonnetDirectory,'"','');
                Path=strtrim(Path);
                Path=strrep(Path,[filesep 'bin'],'');
                
                % If the specified location does not have \bin\em.exe
                % (\bin\em on unix) then it is not a valid Sonnet directory.
                if ispc && ~exist([Path filesep 'bin' filesep 'em.exe'],'file')
                    error(['Invalid Sonnet Directory Specified: ' Path]);
                elseif isunix && ~exist([Path filesep 'bin' filesep 'em'],'file')
                    error(['Invalid Sonnet Directory Specified: ' Path]);
                end
            end
            
            % Open up emgraph
            if isunix
                aCallToSystem=['"' Path filesep 'bin' filesep 'emgraph" "' obj.FilePath obj.Filename '" &'];
            else
               aCallToSystem=['"' Path filesep 'bin' filesep 'emgraph.exe" "' obj.FilePath obj.Filename '" &']; 
            end
            system(aCallToSystem);
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function viewCurrents(obj, theSonnetDirectory)
            %viewCurrents   Launches current viewer
            %   Project.viewCurrents() will call Sonnet's built in
            %   current density viewer application to view the currents
            %   for the project. The project must have had the compute
            %   current setting on in order for the currents to have been
            %   calculated while simulating.  This can be enabled using
            %   the 'enableCurrentCalculations()' function.
            %
            %   Project.viewCurrents(Path) will call Sonnet's built in
            %   current density viewer application to view the currents
            %   for the project. The method will use the version of Sonnet
            %   located at the specified directory. The project must have
            %   had the compute current setting on in order for the currents
            %   to have been calculated while simulating.  This can be
            %   enabled using the 'enableCurrentCalculations()' function.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example:
            %       % View currents using the default version of Sonnet
            %       viewCurrents();
            %
            %       % View currents using a particular version of Sonnet
            %       viewCurrents('C:\Program Files\sonnet.12.52')
            %
            %   See also SonnetProject.viewResponseData,
            %            SonnetProject.enableCurrentCalculations,
            %            SonnetProject.disableCurrentCalculations
            
            if obj.isGeometryProject
                % Get the location of Sonnet
                if nargin == 1
                    Path=SonnetPath();
                else
                    % Remove any quotation marks
                    Path=strrep(theSonnetDirectory,'"','');
                    Path=strtrim(Path);
                    Path=strrep(Path,[filesep 'bin'],'');
                    
                    % If the specified location does not have \bin\em.exe
                    % (\bin\em on unix) then it is not a valid Sonnet directory.
                    if ispc && ~exist([Path filesep 'bin' filesep 'em.exe'],'file')
                        error(['Invalid Sonnet Directory Specified: ' Path]);
                    elseif isunix && ~exist([Path filesep 'bin' filesep 'em'],'file')
                        error(['Invalid Sonnet Directory Specified: ' Path]);
                    end
                end
                
                % Open up emvu
                if isunix
                    aCallToSystem=['"' Path filesep 'bin' filesep 'emvu" "' obj.FilePath obj.Filename '" &'];
                else
                    aCallToSystem=['"' Path filesep 'bin' filesep 'emvu.exe" "' obj.FilePath obj.Filename '" &'];
                end
                
                system(aCallToSystem);
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aExports=exportCurrents(obj,theRegion,...
                theType,thePorts,theFrequency,theGridX,theGridY,theLevel,...
                theComplex,theParameterName,theParameterValue)
            %exportCurrents   Exports current data
            %   Project.exportCurrents(...) will call Sonnet and export
            %   the current data for a region of a layout. This method
            %   will save and simulate the project first. Current
            %   calculations will be enabled for the project.
            %
            %   There are two approaches to calling this method:
            %   The first approach is the pass the method a
            %   Sonnet current data request configuration file.
            %
            %       Example: Project.exportCurrents(aRequestFile);
            %
            %   The second approach to calling this method involves passing
            %   arguments that would specify the output settings such that
            %   the method will essentially build an output configuration
            %   file. The arguments are the following:
            %
            %      1) Region - The region must be either a JXYLine object,
            %                  a JXYRectangle object or []. If the region
            %                  is [] then the currents for the entire layout
            %                  will be outputted.
            %      2) Type  -  The type must be either 'JX','JY','JXY' or
            %                  'PWR' (for heat flux)
            %      3) Ports -  The ports should be either a vector of JXYPort
            %                  objects or a matrix that stores the voltage and
            %                  phase values for each port. The user only has
            %                  to define values for ports that have non-zero
            %                  voltage or phase values. When using a matrix
            %                  the data must be formatted as follows:
            %                     [PortNumber, Voltage, Phase;
            %                      PortNumber, Voltage, Phase; ...]
            %      4) Frequency -  A vector specifying the desired frequency values.
            %                      Values should be specified in the same units as the project.
            %      5) (Optional) X Grid Size - This determines the X direction resolution
            %                                  of the exported data. The grid size is the
            %                                  separation between two data points. The first
            %                                  value in the series is half of the grid size.
            %                                  Ex: a value of two would provide data at the
            %                                  points 1,3,5,7... If the grid X size is
            %                                  unspecified then the cell size from the project
            %                                  will be utilized. If the X grid size is []
            %                                  then the the cell size from the project
            %                                  will be utilized.
            %      6) (Optional) Y Grid Size - This determines the Y direction resolution of
            %                                  the exported data. If the grid Y size
            %                                  is unspecified then the cell size from the
            %                                  project will be utilized. If the X grid size
            %                                  is [] then the the cell size from the project
            %                                  will be utilized.
            %      7) (Optional) Level -  Specifies what metallization  level(s)
            %                             should be outputted. The level should be [] if
            %                             all levels should be outputted. The level should
            %                             be a single number (Ex: 4) if only one level
            %                             should be outputted. If a range of levels
            %                             should be outputted then the level should be a
            %                             vector in the form of [startLevel, endLevel].
            %      8) (Optional) Complex - Should be either true or false. True indicates that
            %                              current data should be returned as complex numbers.
            %
            %   If the user would like to specify values for
            %   parameters they may use the last two arguments.
            %
            %      9)  ParameterName  -    Should be either a vertical vector of strings
            %                              (use strvcat) or a cell array of strings.
            %
            %      10) ParameterValue -    Should be either a vector or a cell array of values
            %                              such that the Nth element of ParameterValue is
            %                              the value for the parameter specified by the Nth
            %                              element of ParameterName.
            %
            %   Note: This method is only for geometry projects.
            %   Note: This method will only work for Sonnet version 13 and later.
            %           This method will look for Sonnet 13 installations and use the
            %           one with the latest install date.
            %   Note: This method will save the project to the hard drive. If
            %           there hasn't been a filename associated with this project
            %           an error will be thrown. A filename may be specified using
            %           the saveAs method (see "help SonnetProject.saveAs")
            %   Note: The X grid size and Y grid size values may be empty matricies ([]).
            %           This will cause the script to default to the project's cell size.
            %           This ability allows you to use default values for the grid size
            %           but still set non-default values for the metalization level and
            %           complex data fields.
            %
            %   See also SonnetProject.viewCurrents,
            %            SonnetProject.enableCurrentCalculations,
            %            SonnetProject.disableCurrentCalculations,
            %            SonnetProject.exportPattern
            
            if obj.isGeometryProject
                
                % Save the project
                if isempty(obj.Filename)
                    error('You must do a saveAs before exporting current data');
                else
                    obj.save();
                end
                
                % If we are given an XML file to use then that is the
                % only argument we need. Otherwise they must specify
                % the other settings so we know how to output
                % the current data.
                if nargin == 2
                    
                    % Determine the filename(s) for the outputted data
                    aDOMnode = xmlread(theRegion);
                    aListOfExports = aDOMnode.getElementsByTagName('JXY_Export');
                    aListOfFilenames = cell(1,aListOfExports.getLength-1);
                    for iCounter = 0:aListOfExports.getLength-1
                        aExport = aListOfExports.item(iCounter);
                        aFilename = aExport.getAttribute('Filename');
                        aListOfFilenames{iCounter+1}=char(aFilename);
                    end
                    
                    % Call Sonnet to compute the currents.
                    JXYExport(theRegion,obj);
                    
                    % Parse the data and return
                    aExports={};
                    for iCounter=1:length(aListOfFilenames)
                        aExportSet=JXYRead(aListOfFilenames{iCounter});
                        for jCounter=1:length(aExportSet)
                            aExports{length(aExports)+1}=aExportSet(jCounter); %#ok<AGROW>
                        end
                    end
                    aExports=cell2mat(aExports);
                    
                else
                    
%                   aXmlFilename=strrep(obj.Filename,'.son','.xml');
                    aDataFilename=strrep(obj.Filename,'.son','.csv');
                    
                    % Get a multiplier for the frequency
                    % based on the project's unit selection.
                    switch lower(obj.DimensionBlock.FrequencyUnit)
                        case 'hz'
                            aFactor=1;
                        case 'khz'
                            aFactor=1e3;
                        case 'mhz'
                            aFactor=1e6;
                        case 'ghz'
                            aFactor=1e9;
                        case 'thz'
                            aFactor=1e12;
                    end
                    
                    % If the ports value was a matrix then
                    % build a set of JXY port objects.
                    if isa(thePorts,'double')
                        aPortNumbers=thePorts(:,1);
                        aPortVoltages=thePorts(:,2);
                        aPortPhases=thePorts(:,3);
                        thePorts=[];
                        for iCounter=1:length(aPortNumbers)
                            aPortNumber=aPortNumbers(iCounter);
                            aPortVoltage=aPortVoltages(iCounter);
                            aPortPhase=aPortPhases(iCounter);
                            aPortResistance=obj.GeometryBlock.ArrayOfPorts{iCounter}.Resistance;
                            aPortReactance=obj.GeometryBlock.ArrayOfPorts{iCounter}.Reactance;
                            aPortInductance=obj.GeometryBlock.ArrayOfPorts{iCounter}.Inductance;
                            aPortCapacitance=obj.GeometryBlock.ArrayOfPorts{iCounter}.Capacitance;
                            thePorts=[thePorts JXYPort(aPortNumber,aPortVoltage,aPortPhase,aPortResistance,aPortReactance,aPortInductance,aPortCapacitance)]; %#ok<AGROW>
                        end
                    end
                    
                    % If no values were specified for the grid sizes
                    % then default to the  project's cell size.
                    if nargin >= 7
                        if isempty(theGridX)
                            theGridX=obj.xCellSize;
                        end
                        if isempty(theGridY)
                            theGridY=obj.yCellSize;
                        end
                    end
                    
                    % Build the XML file that tells Sonnet what
                    % current information needs to be returned.
                    aRequest=JXYRequest();
                    if nargin == 5
                        aRequest.addExport(aDataFilename,obj.Filename,theRegion,theType,thePorts,...
                            theFrequency.*aFactor,obj.xCellSize,obj.yCellSize)
                    elseif nargin == 6
                        error(['Error: Unusual number of arguments specified. If the X Grid size is '...
                            'given then the Y grid size should be given as well.'])
                    elseif nargin == 7
                        aRequest.addExport(aDataFilename,obj.Filename,theRegion,theType,thePorts,...
                            theFrequency.*aFactor,theGridX,theGridY)
                    elseif nargin == 8
                        aRequest.addExport(aDataFilename,obj.Filename,theRegion,theType,thePorts,...
                            theFrequency.*aFactor,theGridX,theGridY,theLevel)
                    elseif nargin == 9
                        aRequest.addExport(aDataFilename,obj.Filename,theRegion,theType,thePorts,...
                            theFrequency.*aFactor,theGridX,theGridY,theLevel,theComplex)
                    elseif nargin == 10
                        error(['Error: Unusual number of arguments specified. If the parameter names are '...
                            'given then the desired parameter values should be given.'])
                    elseif nargin == 11
                        aRequest.addExport(aDataFilename,obj.Filename,theRegion,theType,thePorts,...
                            theFrequency.*aFactor,theGridX,theGridY,theLevel,theComplex,...
                            theParameterName,theParameterValue)
                    else
                        error('Invalid number of arguments');
                    end
                    
                    % Call Sonnet to compute the currents.
                    JXYExport(aRequest,obj);
                    aExports=JXYRead(aDataFilename);
                    
                end
                
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aExports=ExportHeatFlux(theProject,theRegion,...
                thePorts,theFrequency,theGridX,theGridY,theLevel,...
                theComplex,theParameterName,theParameterValue)
            %ExportHeatFlux   Exports heat flux data
            %   Project.ExportHeatFlux(...) will call Sonnet and export
            %   the heat flux data for a region of a layout. This method
            %   will save and simulate the project first. Current
            %   calculations will be enabled for the project.
            %
            %   There are two approaches to calling this method:
            %   The first approach is the pass the method a
            %   Sonnet current data request configuration file.
            %
            %       Example: Project.ExportHeatFlux(aRequestFile);
            %
            %   The second approach to calling this method involves passing
            %   arguments that would specify the output settings such that
            %   the method will essentially build an output configuration
            %   file. The arguments are the following:
            %
            %      1) Region - The region must be either a JXYLine object,
            %                  a JXYRectangle object or []. If the region
            %                  is [] then the currents for the entire layout
            %                  will be outputted.
            %      2) Ports -  The ports should be either a vector of JXYPort
            %                  objects or a matrix that stores the voltage and
            %                  phase values for each port. The user only has
            %                  to define values for ports that have non-zero
            %                  voltage or phase values. When using a matrix
            %                  the data must be formatted as follows:
            %                     [PortNumber, Voltage, Phase;
            %                      PortNumber, Voltage, Phase; ...]
            %      3) Frequency -  A vector specifying the desired frequency values.
            %                      Values should be specified in the same units as the project.
            %      4) (Optional) X Grid Size - This determines the X direction resolution
            %                                  of the exported data. The grid size is the
            %                                  separation between two data points. The first
            %                                  value in the series is half of the grid size.
            %                                  Ex: a value of two would provide data at the
            %                                  points 1,3,5,7... If the grid X size is
            %                                  unspecified then the cell size from the project
            %                                  will be utilized.
            %      5) (Optional) Y Grid Size - This determines the Y direction resolution of
            %                                  the exported data. If the grid Y size
            %                                  is unspecified then the cell size from the
            %                                  project will be utilized.
            %      6) (Optional) Level -  Specifies what metallization  level(s)
            %                             should be outputted. The level should be [] if
            %                             all levels should be outputted. The level should
            %                             be a single number (Ex: 4) if only one level
            %                             should be outputted. If a range of levels
            %                             should be outputted then the level should be a
            %                             vector in the form of [startLevel, endLevel].
            %      7) (Optional) Complex - Should be either true or false. True indicates that
            %                              current data should be returned as complex numbers.
            %
            %   If the user would like to specify values for
            %   parameters they may use the last two arguments.
            %
            %      8)  ParameterName  -    Should be either a vertical vector of strings
            %                              (use strvcat) or a cell array of strings.
            %
            %      9)  ParameterValue -    Should be either a vector or a cell array of values
            %                              such that the Nth element of ParameterValue is
            %                              the value for the parameter specified by the Nth
            %                              element of ParameterName.
            %
            %   Note: This method is only for geometry projects.
            %   Note: This method will only work for Sonnet version 13 and later.
            %           This method will look for Sonnet 13 installations and use the
            %           one with the latest install date.
            %   Note: This method will save the project to the hard drive. If
            %         there hasn't been a filename associated with this project
            %         an error will be thrown. A filename may be specified using
            %         the saveAs method (see "help SonnetProject.saveAs")
            %
            %   See also SonnetProject.viewCurrents,
            %            SonnetProject.enableCurrentCalculations,
            %            SonnetProject.disableCurrentCalculations,
            %            SonnetProject.exportPattern
            
            if theProject.isGeometryProject
                
                % Save the project
                if isempty(theProject.Filename)
                    error('You must do a saveAs before exporting current data');
                else
                    theProject.save();
                end
                
                % If we are given an XML file to use then that is the
                % only argument we need. Otherwise they must specify
                % the other settings so we know how to output
                % the current data.
                if nargin == 2
                    
                    % Determine the filename(s) for the outputted data
                    aDOMnode = xmlread(theRegion);
                    aListOfExports = aDOMnode.getElementsByTagName('JXY_Export');
                    aListOfFilenames = cell(1,aListOfExports.getLength-1);
                    for iCounter = 0:aListOfExports.getLength-1
                        aExport = aListOfExports.item(iCounter);
                        aFilename = aExport.getAttribute('Filename');
                        aListOfFilenames{iCounter+1}=char(aFilename);
                    end
                    
                    % Call Sonnet to compute the currents.
                    JXYExport(theRegion,obj);
                    
                    % Parse the data and return
                    aExports={};
                    for iCounter=1:length(aListOfFilenames)
                        aExportSet=JXYRead(aListOfFilenames{iCounter});
                        for jCounter=1:length(aExportSet)
                            aExports{length(aExports)+1}=aExportSet(jCounter); %#ok<AGROW>
                        end
                    end
                    aExports=cell2mat(aExports);
                    
                else
                    
%                   aXmlFilename=strrep(theProject.Filename,'.son','.xml');
                    aDataFilename=strrep(theProject.Filename,'.son','.csv');
                    
                    % Get a multiplier for the frequency
                    % based on the project's unit selection.
                    switch lower(theProject.DimensionBlock.FrequencyUnit)
                        case 'hz'
                            aFactor=1;
                        case 'khz'
                            aFactor=1e3;
                        case 'mhz'
                            aFactor=1e6;
                        case 'ghz'
                            aFactor=1e9;
                        case 'thz'
                            aFactor=1e12;
                    end
                    
                    % If the ports value was a matrix then
                    % build a set of JXY port objects.
                    if isa(thePorts,'double')
                        aPortNumbers=thePorts(:,1);
                        aPortVoltages=thePorts(:,2);
                        aPortPhases=thePorts(:,3);
                        thePorts=[];
                        for iCounter=1:length(aPortNumbers)
                            aPortNumber=aPortNumbers(iCounter);
                            aPortVoltage=aPortVoltages(iCounter);
                            aPortPhase=aPortPhases(iCounter);
                            aPortResistance=theProject.GeometryBlock.ArrayOfPorts{iCounter}.Resistance;
                            aPortReactance=theProject.GeometryBlock.ArrayOfPorts{iCounter}.Reactance;
                            aPortInductance=theProject.GeometryBlock.ArrayOfPorts{iCounter}.Inductance;
                            aPortCapacitance=theProject.GeometryBlock.ArrayOfPorts{iCounter}.Capacitance;
                            thePorts=[thePorts JXYPort(aPortNumber,aPortVoltage,aPortPhase,aPortResistance,aPortReactance,aPortInductance,aPortCapacitance)]; %#ok<AGROW>
                        end
                    end
                    
                    % Build the XML file that tells Sonnet what
                    % current information needs to be returned.
                    if nargin == 4
                        aRequest=HeatFluxConfiguration(aDataFilename,theProject.Filename,theRegion,thePorts,...
                            theFrequency.*aFactor,theProject.xCellSize,theProject.yCellSize);
                        aRequest.write('aRequestFile.xml');
                    elseif nargin == 5
                        error(['Error: Unusual number of arguments specified. If the X Grid size is '...
                            'given then the Y grid size should be given as well.'])
                    elseif nargin == 6
                        aRequest=HeatFluxConfiguration(aDataFilename,theProject.Filename,theRegion,thePorts,...
                            theFrequency.*aFactor,theGridX,theGridY);
                        aRequest.write('aRequestFile.xml');
                    elseif nargin == 7
                        aRequest=HeatFluxConfiguration(aDataFilename,theProject.Filename,theRegion,thePorts,...
                            theFrequency.*aFactor,theGridX,theGridY,theLevel);
                        aRequest.write('aRequestFile.xml');
                    elseif nargin == 8
                        aRequest=HeatFluxConfiguration(aDataFilename,theProject.Filename,theRegion,thePorts,...
                            theFrequency.*aFactor,theGridX,theGridY,theLevel,theComplex);
                        aRequest.write('aRequestFile.xml');
                    elseif nargin == 9
                        error(['Error: Unusual number of arguments specified. If the parameter names are '...
                            'given then the desired parameter values should be given.'])
                    elseif nargin == 10
                        aRequest=HeatFluxConfiguration(aDataFilename,theProject.Filename,theRegion,thePorts,...
                            theFrequency.*aFactor,theGridX,theGridY,theLevel,theComplex,...
                            theParameterName,theParameterValue);
                        aRequest.write('aRequestFile.xml');
                    else
                        error('Invalid number of arguments');
                    end
                    
                    % Call Sonnet to compute the currents.
                    JXYExport('aRequestFile.xml',theProject);
                    aExports=JXYRead(aDataFilename);
                    
                end
                
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aPatternData=exportPattern(obj,thePhiAngleVec,theThetaAngleVec,theListOfFreqs,thePortInfo)
            %exportPattern   Exports pattern data
            %   Project.exportPattern(...) will call Sonnet and export
            %   the pattern data for a region of a layout. This method
            %   will save and simulate the project first. Current
            %   calculations will be enabled for the project.
            %
            %   The arguments are the following:
            %       1) The PhiAngleVec [start stop step] of Phi (azimuthal angle) in degs.
            %       2) The ThetaAngleVec [start stop step] of Theta ("elevation" angle) in degs.
            %       3) The List of Frequencies at which the pattern should be calculated.
            %       4) The port excitations/terminations.
            %           This should be a matrix with columns:
            %               [PortNumber Magnitude Phase(deg) Real(Z) Imag(Z) Inductance Capacitance]
            %               example: [1 1 0 50 0 0 0]
            %               which means: [Port 1, MAG=1, PHASE=0, R=50, X=0, L=0, C=0]
            %
            %   Note: This method is only for geometry projects.
            %   Note: This method will only work for Sonnet version 13 and later.
            %           This method will look for Sonnet 13 installations and use the
            %           one with the latest install date.
            %   Note: This method will save the project to the hard drive. If
            %         there hasn't been a filename associated with this project
            %         an error will be thrown. A filename may be specified using
            %         the saveAs method (see "help SonnetProject.saveAs")
            %
            %   Example:
            %     % The below command will export pattern data for
            %     %   - Theta Values from 0 to 85 in steps of 1
            %     %   - Phi Value from 0 to 360 in steps of 1
            %     %   - Frequency Values of 2.4 GHz
            %     %   - Port 1 excitation: MAG=1, PHASE=0, R=50, X=0, L=0, C=0
            %     aPatternData=Project.exportPattern([0 360 1], [0 85 1], 2.4, [1 1 0 50 0 0 0]);
            %
            %   See also SonnetProject.exportCurrents,
            %            SonnetProject.enableCurrentCalculations
            
            if obj.isGeometryProject
                % Save the project
                if isempty(obj.Filename)
                    error('You must do a saveAs before exporting current data');
                else
                    obj.save();
                end
                
                % Get the frequency units
                aUnits=obj.DimensionBlock.FrequencyUnit;
                
                % Determine a filename for the export
                aFilename=strrep(obj.Filename,'.son','.pat');
                
                % Determine an appropriate path for the exported file
                if isempty(obj.FilePath)
                    aPath='.';
                else
                    aPath=obj.FilePath;
                end
                
                % Call patvu to export the pattern data
                SonnetCallPatvu(obj.Filename,aPath,aUnits,thePhiAngleVec,theThetaAngleVec,theListOfFreqs,thePortInfo);
                
                % Read the pattern data
                aPatternData=PatternRead(aFilename);
                
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [aNumberOfMegaBytesOfMemory,aNumberOfSubsections]=...
                estimateMemoryUsage(obj,theSonnetDirectory)
            %estimateMemoryUsage   Estimate memory usage
            %   [megabytes subsections]=Project.estimateMemoryUsage() will save the
            %   Sonnet project and call Sonnet's built in memory estimator.
            %   The number of megabytes required for simulation and the number
            %   of subsections are returned. The project must contain
            %   analysis frequencies before this method may be used.
            %
            %   [megabytes subsections]=Project.estimateMemoryUsage() will save the
            %   Sonnet project and call Sonnet's built in memory estimator.
            %   The number of megabytes required for simulation and the number
            %   of subsections are returned. The project must contain
            %   analysis frequencies before this method may be used.
            %
            %   Sonnet will only estimate the memory usages for geometry projects.
            %
            %   Note: This method will save the project to the hard drive. If
            %         there hasn't been a filename associated with this project
            %         an error will be thrown. A filename may be specified using
            %         the saveAs method (see "help SonnetProject.saveAs")
            %
            %   Example usage:
            %       % Use the most recently installed version of Sonnet
            %       % to estimate memory and subsections.
            %       [MegaBytesOfMemory NumberOfSubsections]=Project.estimateMemoryUsage();
            %
            %       % Use Sonnet version 12.52 to estimate memory and subsections.
            %       [MegaBytesOfMemory NumberOfSubsections]=Project.estimateMemoryUsage('C:\Program Files\sonnet.12.52');
            %
            %   See also SonnetProject.simulate
            
            % Get the location of Sonnet
            if nargin == 1
                Path=SonnetPath();
            else
                % Remove any quotation marks
                Path=strrep(theSonnetDirectory,'"','');
                Path=strtrim(Path);
                Path=strrep(Path,[filesep 'bin'],'');
                
                % If the specified location does not have \bin\em.exe
                % (\bin\em on unix) then it is not a valid Sonnet directory.
                if ispc && ~exist([Path filesep 'bin' filesep 'em.exe'],'file')
                    error(['Invalid Sonnet Directory Specified: ' Path]);
                elseif isunix && ~exist([Path filesep 'bin' filesep 'em'],'file')
                    error(['Invalid Sonnet Directory Specified: ' Path]);
                end
            end
            
            % Save the project
            if isempty(obj.Filename)
                error('You must do a saveAs before estimating memory so that a filename exists');
            else
                obj.save();
            end
            
            % Call EM to do the simulation
            if isunix
                aCallToSystem=['"' Path filesep 'bin' filesep 'em" "' obj.FilePath obj.Filename '" "-N"'];
            else
                aCallToSystem=['"' Path filesep 'bin' filesep 'em.exe" "' obj.FilePath obj.Filename '" "-N"'];
            end
            [~, anOutputString]=system(aCallToSystem);
            
            % Find the memory usage
            aStringLocation=strfind(anOutputString,'subsections and');
            aNumberOfMegaBytesOfMemory=sscanf(anOutputString(aStringLocation+16:length(anOutputString)),'%f',1);
            
            % Find the number of subsections
            aStringLocation=strfind(anOutputString,'Circuit requires');
            aNumberOfSubsections=sscanf(anOutputString(aStringLocation+16:length(anOutputString)),'%f',1);
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function cleanProject(obj)
            %cleanProject   Cleans a project
            %   Project.cleanProject() deletes the simulation data for the project.
            %
            %   See also SonnetProject.cleanOutputFiles
            
            % Suspend warnings while deleting the files
            aBackup=warning();
            warning off all
            
            % If the directory exists delete it to clean the simulation
            % results
            if exist([obj.FilePath '.' filesep 'sondata' filesep strrep(obj.Filename,'.son','')],'dir')==7
                rmdir([obj.FilePath '.' filesep 'sondata' filesep strrep(obj.Filename,'.son','')],'s');
                mkdir([obj.FilePath '.' filesep 'sondata' filesep strrep(obj.Filename,'.son','')]);
            end
            
            % re-enable warning messages
            warning(aBackup);
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function cleanOutputFiles(obj)
            %cleanOutputFiles   Deletes output files for a project
            %   Project.cleanOutputFiles() deletes any output response files present
            %   in the directory for a Sonnet project. cleanOutputFiles knows
            %   which files to delete by checking the fileoutBlock for the
            %   project to see if any output files are defined. If there are
            %   output files to be deleted then cleanOutputFiles will look
            %   for those files in the simulation directory and delete them if present.
            %
            %   See also SonnetProject.cleanProject
            
            % get the basename for the filename
            aBaseName=strrep(obj.Filename,'.son','');
            
            % Try to delete all the output response files from
            % its fileout block (if present)
            if ~isempty(obj.FileOutBlock)
                for iCounter=1:length(obj.FileOutBlock.ArrayOfFileOutputConfigurations)
                    aResponseName=obj.FileOutBlock.ArrayOfFileOutputConfigurations{iCounter}.Filename; % get the filename of the response file
                    aResponseName=strrep(aResponseName,'$BASENAME',aBaseName); % if it has thebasename tag then change it to the filename
                    if ~isempty(dir(aResponseName)) % delete the response file
                        disp(['Deleting: ' aResponseName]);
                        system(['del ' aResponseName]);
                    end
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Analysis Settings Modification Methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addFrequencySweep(obj,theSweepType,theargument1,theargument2,theargument3)
            %addFrequencySweep   Adds a frequency sweep to the project
            %   Project.addFrequencySweep(SweepName,...) adds a frequency sweep
            %   to the project. addFrequencySweep requires a string specifying the type
            %   of frequency sweep to be added to the project and
            %   all of the arguments necessary in order to construct
            %   the sweep.
            %
            %   Types and arguments are as follows:
            %
            %       SWEEP       StartFrequency,EndFrequency,StepFrequency
            %       ABS         StartFrequency,EndFrequency
            %       ABSENTRY    StartFrequency,EndFrequency
            %       ABSFMAX     StartFrequency,EndFrequency,Maximum
            %       ABSFMIN     StartFrequency,EndFrequency,Minimum
            %       DC          Mode*,Frequency**
            %       ESWEEP      StartFrequency,EndFrequency,AnalysisFrequencies
            %       LSWEEP      StartFrequency,EndFrequency,AnalysisFrequencies
            %       SIMPLE      StartFrequency,EndFrequency,StepFrequency
            %       STEP        StepFrequency
            %
            %       *  For a DC sweep:  mode is either 'AUTO' for automatic or 'MAN' for manual.
            %       ** For a DC sweep:  when mode is 'AUTO' the frequency does not need to
            %                           be supplied. The frequency is required when the DC
            %                           mode is manual.
            %
            %   When a frequency sweep is added to the project the selected
            %   frequency sweep to be used for analysis will be automatically
            %   changed such that the newly created sweep will be the selected
            %   frequency sweep.
            %
            %   Example usage:
            %
            %       % Add an ABS sweep to the project. The new sweep will
            %       % have the frequency range from 5 to 10 (units are
            %       % specified in the dimension block)
            %       Project.addFrequencySweep('ABS',5,10);
            %
            %       % Add an automatic DC frequency sweep to the project
            %       Project.addFrequencySweep('DC','AUTO');
            %
            %       % Add a manual DC frequency sweep to the project with frequency 5
            %       Project.addFrequencySweep('DC','MAN',5);
            %
            % See also SonnetProject.addSweepFrequencySweep,
            %          SonnetProject.addAbsFrequencySweep,
            %          SonnetProject.addAbsEntryFrequencySweep,
            %          SonnetProject.addAbsFmaxFrequencySweep,
            %          SonnetProject.addAbsFminFrequencySweep,
            %          SonnetProject.addDcFrequencySweep,
            %          SonnetProject.addEsweepFrequencySweep,
            %          SonnetProject.addLsweepFrequencySweep,
            %          SonnetProject.addSimpleFrequencySweep,
            %          SonnetProject.addStepFrequencySweep
            
            if isempty(obj.FrequencyBlock)
                obj.FrequencyBlock=SonnetFrequencyBlock();
                isThereAFrequencyBlock=false;
                for iCounter=1:length(obj.CellArrayOfBlocks)
                    if isa(obj.CellArrayOfBlocks{iCounter},'SonnetFrequencyBlock')
                        isThereAFrequencyBlock=true;
                    end
                end
                if isThereAFrequencyBlock == false
                    obj.CellArrayOfBlocks{length(obj.CellArrayOfBlocks)+1}=obj.FrequencyBlock;
                end
            end
            
            % Convert the Sweep Type string to all uppercase for the switch
            theSweepType=upper(theSweepType);
            
            % Depending on what the string was we will construct the proper type
            % of sweep using the sweep's add function.
            switch theSweepType
                
                case 'SWEEP'
                    obj.addSweepFrequencySweep(theargument1,theargument2, theargument3);
                case 'ABS'
                    obj.addAbsFrequencySweep(theargument1,theargument2);
                case 'ABSENTRY'
                    obj.addAbsEntryFrequencySweep(theargument1,theargument2);
                case 'ABSFMAX'
                    obj.addAbsFmaxFrequencySweep(theargument1,theargument2,theargument3);
                case 'ABSFMIN'
                    obj.addAbsFminFrequencySweep(theargument1,theargument2,theargument3);
                case 'DC'
                    if nargin == 4
                        obj.addDcFrequencySweep(theargument1,theargument2);
                    else
                        obj.addDcFrequencySweep(theargument1);
                    end
                case 'ESWEEP'
                    obj.addEsweepFrequencySweep(theargument1,theargument2,theargument3);
                case 'LSWEEP'
                    obj.addLsweepFrequencySweep(theargument1,theargument2,theargument3);
                case 'SIMPLE'
                    obj.addSimpleFrequencySweep(theargument1,theargument2,theargument3);
                case 'STEP'
                    obj.addStepFrequencySweep(theargument1);
                otherwise
                    error('Improper String for sweep type.');
                    
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addSweepFrequencySweep(obj,theStartFrequency,theEndFrequency,theStepFrequency)
            %addSweepFrequencySweep   Adds a 'Sweep' type of sweep to the project
            %   Project.addSweepFrequencySweep(StartFrequency,EndFrequency,StepFrequency)
            %   adds a 'SWEEP' type of frequency sweep to the project.
            %
            %   This sweep is part of a combination frequency sweep.
            %   This function will change the selected frequency sweep
            %   to frequency sweep combination.
            %
            %   Example usage:
            %
            %       % Add a 'Sweep' type of sweep to the project.
            %       % the sweep will go from 5 to 10 in steps of 1.
            %       Project.addSweepFrequencySweep(5,10,1);
            %
            % See also SonnetProject.addFrequencySweep
            
            if isempty(obj.FrequencyBlock)
                obj.FrequencyBlock=SonnetFrequencyBlock();
                isThereAFrequencyBlock=false;
                for iCounter=1:length(obj.CellArrayOfBlocks)
                    if isa(obj.CellArrayOfBlocks{iCounter},'SonnetFrequencyBlock')
                        isThereAFrequencyBlock=true;
                    end
                end
                if isThereAFrequencyBlock == false
                    obj.CellArrayOfBlocks{length(obj.CellArrayOfBlocks)+1}=obj.FrequencyBlock;
                end
            end
            
            obj.FrequencyBlock.addSweepSweep(theStartFrequency,theEndFrequency,theStepFrequency);
            obj.changeSelectedFrequencySweep('STD');
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addAbsFrequencySweep(obj,theStartFrequency,theEndFrequency)
            %addAbsFrequencySweep   Adds an 'ABS' type of sweep to the project
            %   Project.addAbsFrequencySweep(StartFrequency,EndFrequency) adds an
            %   'ABS' type of frequency sweep to the project.
            %
            %   This function will change the selected frequency sweep to 'ABS'.
            %
            %   Example usage:
            %
            %       % Add an 'ABS' type of sweep to the project.
            %       % the sweep will go from 5 to 10.
            %       Project.addAbsFrequencySweep(5,10);
            %
            % See also SonnetProject.addFrequencySweep
            
            if isempty(obj.FrequencyBlock)
                obj.FrequencyBlock=SonnetFrequencyBlock();
                isThereAFrequencyBlock=false;
                for iCounter=1:length(obj.CellArrayOfBlocks)
                    if isa(obj.CellArrayOfBlocks{iCounter},'SonnetFrequencyBlock')
                        isThereAFrequencyBlock=true;
                    end
                end
                if isThereAFrequencyBlock == false
                    obj.CellArrayOfBlocks{length(obj.CellArrayOfBlocks)+1}=obj.FrequencyBlock;
                end
            end
            
            % Remove old ABS frequency sweep objects from the sweeps array
            for iCounter=1:length(obj.FrequencyBlock.SweepsArray)
                if isa(obj.FrequencyBlock.SweepsArray{iCounter},'SonnetFrequencyAbs')==1
                    obj.FrequencyBlock.SweepsArray(iCounter)=[];
                    break;
                end
            end
            
            obj.FrequencyBlock.addAbs(theStartFrequency,theEndFrequency)
            obj.changeSelectedFrequencySweep('ABS');
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addAbsEntryFrequencySweep(obj,theStartFrequency,theEndFrequency)
            %addAbsEntryFrequencySweep   Adds an 'ABSENTRY' type of sweep to the project
            %   Project.addAbsEntryFrequencySweep(StartFrequency,EndFrequency) adds a
            %   'ABSENTRY' type of frequency sweep to the project.
            %
            %   This sweep is part of a combination frequency sweep.
            %   This function will change the selected frequency sweep
            %   to frequency sweep combination.
            %
            %   Example usage:
            %
            %       % Add an 'ABSENTRY' type of sweep to the project.
            %       % the sweep will go from 5 to 10.
            %       Project.addAbsEntryFrequencySweep(5,10);
            %
            % See also SonnetProject.addFrequencySweep
            
            if isempty(obj.FrequencyBlock)
                obj.FrequencyBlock=SonnetFrequencyBlock();
                isThereAFrequencyBlock=false;
                for iCounter=1:length(obj.CellArrayOfBlocks)
                    if isa(obj.CellArrayOfBlocks{iCounter},'SonnetFrequencyBlock')
                        isThereAFrequencyBlock=true;
                    end
                end
                if isThereAFrequencyBlock == false
                    obj.CellArrayOfBlocks{length(obj.CellArrayOfBlocks)+1}=obj.FrequencyBlock;
                end
            end
            
            obj.FrequencyBlock.addAbsEntry(theStartFrequency,theEndFrequency);
            obj.changeSelectedFrequencySweep('STD');
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addAbsFmaxFrequencySweep(obj,theStartFrequency,theEndFrequency,theMaximum)
            %addAbsFmaxFrequencySweep   Adds an 'ABSFMAX' type of sweep to the project
            %   Project.addAbsFmaxFrequencySweep(StartFrequency,EndFrequency,Maximum) adds a
            %   'ABSFMAX' type of frequency sweep to the project.
            %
            %   This sweep is part of a combination frequency sweep.
            %   This function will change the selected frequency sweep
            %   to frequency sweep combination.
            %
            %   Example usage:
            %
            %       % Add an 'ABSFMAX' type of sweep to the project.
            %       % the sweep will go from 5 to 10 looking for a
            %       % max value of 5.
            %       Project.addAbsFmaxFrequencySweep(5,10,'S11');
            %
            % See also SonnetProject.addFrequencySweep
            
            if isempty(obj.FrequencyBlock)
                obj.FrequencyBlock=SonnetFrequencyBlock();
                isThereAFrequencyBlock=false;
                for iCounter=1:length(obj.CellArrayOfBlocks)
                    if isa(obj.CellArrayOfBlocks{iCounter},'SonnetFrequencyBlock')
                        isThereAFrequencyBlock=true;
                    end
                end
                if isThereAFrequencyBlock == false
                    obj.CellArrayOfBlocks{length(obj.CellArrayOfBlocks)+1}=obj.FrequencyBlock;
                end
            end
            
            obj.FrequencyBlock.addAbsFmax(theStartFrequency,theEndFrequency,theMaximum);
            obj.changeSelectedFrequencySweep('STD');
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addAbsFminFrequencySweep(obj,theStartFrequency,theEndFrequency,theMinimum)
            %addAbsFminFrequencySweep   Adds an 'ABSFMIN' type of sweep to the project
            %   Project.addAbsFminFrequencySweep(StartFrequency,EndFrequency,Minimum) adds a
            %   'ABSFMIN' type of frequency sweep to the project.
            %
            %   This sweep is part of a combination frequency sweep.
            %   This function will change the selected frequency sweep
            %   to frequency sweep combination.
            %
            %   Example usage:
            %
            %       % Add an 'ABSFMIN' type of sweep to the project.
            %       % the sweep will go from 5 to 10 looking for a
            %       % min value of 5.
            %       Project.addAbsFminFrequencySweep(5,10,'S11');
            %
            % See also SonnetProject.addFrequencySweep
            
            if isempty(obj.FrequencyBlock)
                obj.FrequencyBlock=SonnetFrequencyBlock();
                isThereAFrequencyBlock=false;
                for iCounter=1:length(obj.CellArrayOfBlocks)
                    if isa(obj.CellArrayOfBlocks{iCounter},'SonnetFrequencyBlock')
                        isThereAFrequencyBlock=true;
                    end
                end
                if isThereAFrequencyBlock == false
                    obj.CellArrayOfBlocks{length(obj.CellArrayOfBlocks)+1}=obj.FrequencyBlock;
                end
            end
            
            obj.FrequencyBlock.addAbsFmin(theStartFrequency,theEndFrequency,theMinimum);
            obj.changeSelectedFrequencySweep('STD');
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addDcFrequencySweep(obj,theMode,theFrequency)
            %addDcFrequencySweep   Adds an 'DC' type of sweep to the project
            %   Project.addDcFrequencySweep('AUTO') adds an automatic 'DC'
            %   type of frequency sweep to the project.
            %
            %   Project.addDcFrequencySweep('MAN',Frequency) adds an manual
            %   'DC' type of frequency sweep to the project.
            %
            %   This sweep is part of a combination frequency sweep.
            %   This function will change the selected frequency sweep
            %   to frequency sweep combination.
            %
            %   Example usage:
            %
            %       % Add an automatic DC frequency sweep to the project
            %       Project.addDcFrequencySweep('AUTO');
            %
            %       % Add a manual DC frequency sweep to the project with frequency 5
            %       Project.addDcFrequencySweep('MAN',5);
            %
            % See also SonnetProject.addFrequencySweep
            
            if isempty(obj.FrequencyBlock)
                obj.FrequencyBlock=SonnetFrequencyBlock();
                isThereAFrequencyBlock=false;
                for iCounter=1:length(obj.CellArrayOfBlocks)
                    if isa(obj.CellArrayOfBlocks{iCounter},'SonnetFrequencyBlock')
                        isThereAFrequencyBlock=true;
                    end
                end
                if isThereAFrequencyBlock == false
                    obj.CellArrayOfBlocks{length(obj.CellArrayOfBlocks)+1}=obj.FrequencyBlock;
                end
            end
            
            if nargin == 3
                obj.FrequencyBlock.addDcFreq(theMode,theFrequency);
            elseif nargin ==2
                obj.FrequencyBlock.addDcFreq(theMode);
            end
            
            obj.changeSelectedFrequencySweep('STD');
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addEsweepFrequencySweep(obj,theStartFrequency,theEndFrequency,theAnalysisFrequencies)
            %addEsweepFrequencySweep   Adds an 'ESWEEP' type of sweep to the project
            %   Project.addEsweepFrequencySweep(StartFrequency,EndFrequency,NumberOfPoints)
            %   adds a 'ESWEEP' type of frequency sweep to the project.
            %
            %   This sweep is part of a combination frequency sweep.
            %   This function will change the selected frequency sweep
            %   to frequency sweep combination.
            %
            %   Example usage:
            %
            %       % Add an 'ESWEEP' type of sweep to the project.
            %       % the sweep will go from 5 to 10 with 5 points.
            %       Project.addEsweepFrequencySweep(5,10,5);
            %
            % See also SonnetProject.addFrequencySweep
            
            if isempty(obj.FrequencyBlock)
                obj.FrequencyBlock=SonnetFrequencyBlock();
                isThereAFrequencyBlock=false;
                for iCounter=1:length(obj.CellArrayOfBlocks)
                    if isa(obj.CellArrayOfBlocks{iCounter},'SonnetFrequencyBlock')
                        isThereAFrequencyBlock=true;
                    end
                end
                if isThereAFrequencyBlock == false
                    obj.CellArrayOfBlocks{length(obj.CellArrayOfBlocks)+1}=obj.FrequencyBlock;
                end
            end
            
            obj.FrequencyBlock.addEsweep(theStartFrequency,theEndFrequency,theAnalysisFrequencies);
            obj.changeSelectedFrequencySweep('STD');
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addLsweepFrequencySweep(obj,theStartFrequency,theEndFrequency,theAnalysisFrequencies)
            %addLsweepFrequencySweep   Adds an 'LSWEEP' type of sweep to the project
            %   Project.addLsweepFrequencySweep(StartFrequency,EndFrequency,NumberOfPoints)
            %   adds a 'LSWEEP' type of frequency sweep to the project.
            %
            %   This sweep is part of a combination frequency sweep.
            %   This function will change the selected frequency sweep
            %   to frequency sweep combination.
            %
            %   Example usage:
            %
            %       % Add an 'LSWEEP' type of sweep to the project.
            %       % the sweep will go from 5 to 10 with 5 points.
            %       Project.addLsweepFrequencySweep(5,10,5);
            %
            % See also SonnetProject.addFrequencySweep
            
            if isempty(obj.FrequencyBlock)
                obj.FrequencyBlock=SonnetFrequencyBlock();
                isThereAFrequencyBlock=false;
                for iCounter=1:length(obj.CellArrayOfBlocks)
                    if isa(obj.CellArrayOfBlocks{iCounter},'SonnetFrequencyBlock')
                        isThereAFrequencyBlock=true;
                    end
                end
                if isThereAFrequencyBlock == false
                    obj.CellArrayOfBlocks{length(obj.CellArrayOfBlocks)+1}=obj.FrequencyBlock;
                end
            end
            
            obj.FrequencyBlock.addLsweep(theStartFrequency,theEndFrequency,theAnalysisFrequencies);
            obj.changeSelectedFrequencySweep('STD');
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addSimpleFrequencySweep(obj,theStartFrequency,theEndFrequency,theStepFrequency)
            %addSimpleFrequencySweep   Adds an 'SIMPLE' type of sweep to the project
            %   Project.addSimpleFrequencySweep(StartFrequency,EndFrequency,StepValue) adds
            %   a 'SIMPLE' type of frequency sweep to the project.
            %
            %   This function will change the selected frequency sweep to 'SIMPLE'.
            %
            %   Example usage:
            %
            %       % Add an 'SIMPLE' type of sweep to the project.
            %       % the sweep will go from 5 to 10 with steps of 1.
            %       Project.addSimpleFrequencySweep(5,10,1);
            %
            % See also SonnetProject.addFrequencySweep
            
            if isempty(obj.FrequencyBlock)
                obj.FrequencyBlock=SonnetFrequencyBlock();
                isThereAFrequencyBlock=false;
                for iCounter=1:length(obj.CellArrayOfBlocks)
                    if isa(obj.CellArrayOfBlocks{iCounter},'SonnetFrequencyBlock')
                        isThereAFrequencyBlock=true;
                    end
                end
                if isThereAFrequencyBlock == false
                    obj.CellArrayOfBlocks{length(obj.CellArrayOfBlocks)+1}=obj.FrequencyBlock;
                end
            end
            
            % Remove old ABS frequency sweep objects from the sweeps array
            for iCounter=1:length(obj.FrequencyBlock.SweepsArray)
                if isa(obj.FrequencyBlock.SweepsArray{iCounter},'SonnetFrequencySimple')==1
                    obj.FrequencyBlock.SweepsArray(iCounter)=[];
                    break;
                end
            end
            
            obj.FrequencyBlock.addSimple(theStartFrequency,theEndFrequency,theStepFrequency);
            obj.changeSelectedFrequencySweep('SIMPLE');
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addStepFrequencySweep(obj,theStepFrequency)
            %addStepFrequencySweep   Adds an 'STEP' type of sweep to the project
            %   Project.addStepFrequencySweep(Frequency) adds a 'STEP' type of
            %   frequency sweep to the project.
            %
            %   This sweep is part of a combination frequency sweep.
            %   This function will change the selected frequency sweep
            %   to frequency sweep combination.
            %
            %   Example usage:
            %
            %       % Add an 'STEP' type of sweep to the project.
            %       % the sweep simulate at frequency 5
            %       Project.addStepFrequencySweep(5);
            %
            % See also SonnetProject.addFrequencySweep
            
            if isempty(obj.FrequencyBlock)
                obj.FrequencyBlock=SonnetFrequencyBlock();
                isThereAFrequencyBlock=false;
                for iCounter=1:length(obj.CellArrayOfBlocks)
                    if isa(obj.CellArrayOfBlocks{iCounter},'SonnetFrequencyBlock')
                        isThereAFrequencyBlock=true;
                    end
                end
                if isThereAFrequencyBlock == false
                    obj.CellArrayOfBlocks{length(obj.CellArrayOfBlocks)+1}=obj.FrequencyBlock;
                end
            end
            
            obj.FrequencyBlock.addStep(theStepFrequency);
            obj.changeSelectedFrequencySweep('STD');
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addFrequencyListSweep(obj, theFrequencyList)
            % addFrequencyListSweep   Adds an 'FrequencyList' type of sweep to the project
            %   Project.addFrequencyListSweep(theFrequencyList) adds a 'FrequencyList' type of
            %   frequency sweep to the project.
            %
            %   This sweep is part of a combination frequency sweep.
            %   This function will change the selected frequency sweep
            %   to frequency sweep combination.
            %
            %   Example usage:
            %
            %       % Add an 'FrequencyList' type of sweep to the project.
            %       % the sweep simulate at frequency 1 2 3 4 5
            %       Project.addFrequencyListSweep([1, 2, 3, 4, 5]);
            %
            % See also SonnetProject.addFrequencyListSweep
            
            if isempty(obj.FrequencyBlock)
                obj.FrequencyBlock=SonnetFrequencyBlock();
                isThereAFrequencyBlock=false;
                for iCounter=1:length(obj.CellArrayOfBlocks)
                    if isa(obj.CellArrayOfBlocks{iCounter},'SonnetFrequencyBlock')
                        isThereAFrequencyBlock=true;
                    end
                end
                if isThereAFrequencyBlock == false
                    obj.CellArrayOfBlocks{length(obj.CellArrayOfBlocks)+1}=obj.FrequencyBlock;
                end
            end
        
            obj.FrequencyBlock.addFrequencyList(theFrequencyList);
            obj.changeSelectedFrequencySweep('STD');        
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeSelectedFrequencySweep(obj,theStringForSelectedFrequencySweep)
            %changeSelectedFrequencySweep   Change project's selected frequency sweep
            %   Project.changeSelectedFrequencySweep(string) modifies the selected frequency
            %   sweep for the project. The selected frequency sweep is the one that is
            %   performed for simulations. The selected frequency sweep should be a sweep
            %   that is recognized by Sonnet (ABS, SIMPLE, STD).
            %
            %   Example usage:
            %
            %       % Change the selected frequency sweep to adaptive band
            %       Project.changeSelectedFrequencySweep('ABS');
            %
            %       % Change the selected frequency sweep to frequency combination
            %       Project.changeSelectedFrequencySweep('STD');
            %
            %       % Change the selected frequency sweep to parameter sweep
            %       Project.changeSelectedFrequencySweep('VARSWP');
            %
            %       % Change the selected frequency sweep to optimization sweep
            %       Project.changeSelectedFrequencySweep('OPTIMIZE');
            
            if isempty(obj.FrequencyBlock)
                obj.FrequencyBlock=SonnetFrequencyBlock();
                isThereAFrequencyBlock=false;
                for iCounter=1:length(obj.CellArrayOfBlocks)
                    if isa(obj.CellArrayOfBlocks{iCounter},'SonnetFrequencyBlock')
                        isThereAFrequencyBlock=true;
                    end
                end
                if isThereAFrequencyBlock == false
                    obj.CellArrayOfBlocks{length(obj.CellArrayOfBlocks)+1}=obj.FrequencyBlock;
                end
            end
            
            obj.ControlBlock.sweepType=theStringForSelectedFrequencySweep;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [aFrequencySweepObject, aIndexInFrequencySweepArray]=...
                returnSelectedFrequencySweep(obj)
            %returnSelectedFrequencySweep   Returns a reference to the selected frequency sweep
            %   [sweep index]=Project.returnSelectedFrequencySweep() will
            %   return a handle to the object for the selected
            %   frequency sweep and its location in the
            %   array of frequency sweeps.
            %
            %   If the frequency sweep type was combination
            %   then the return values will be a cell array of
            %   frequency sweep objects and a vector of list
            %   indices.
            %
            %   This function cannot be used when the selected
            %   frequency sweep is parameter sweep, optimize or
            %   external file.
            
            if isempty(obj.FrequencyBlock)
                obj.FrequencyBlock=SonnetFrequencyBlock();
                isThereAFrequencyBlock=false;
                for iCounter=1:length(obj.CellArrayOfBlocks)
                    if isa(obj.CellArrayOfBlocks{iCounter},'SonnetFrequencyBlock')
                        isThereAFrequencyBlock=true;
                    end
                end
                if isThereAFrequencyBlock == false
                    obj.CellArrayOfBlocks{length(obj.CellArrayOfBlocks)+1}=obj.FrequencyBlock;
                end
            end
            
            aSelectedFrequencySweep=obj.ControlBlock.sweepType;
            [aFrequencySweepObject, aIndexInFrequencySweepArray]=obj.FrequencyBlock.returnSelectedFrequencySweep(aSelectedFrequencySweep);
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addVariableSweep(obj,theFreqSweepHandle)
            %addVariableSweepSimple   Add a variable sweep
            %   Project.addVariableSweep(theFreqSweepHandle) will add a variable sweep
            %   to the array of sweep entries. The specified frequency sweep will
            %   be used for the parameter sweep
            %
            %   The supplied sweep type must be one of the following:
            %       ABS_ENTRY   -   Adaptive Band Synthesis Sweep
            %       ABS_FMAX    -   Find the maximum frequency response.
            %       ABS_FMIN    -   Find the minimum frequency response.
            %       DC_FREQ     -   Analyze at a DC frequency point.
            %       STEP        -   Discrete analysis frequency
            %       SWEEP       -   Linear frequency sweep with stated interval.
            %       ESWEEP      -   Exponential frequency sweep.
            %       LSWEEP      -   Linear frequency sweep with number of points.
            %
            %   Example usage:
            %       % Create an ABS frequency sweep object
            %       aSweep=SonnetFrequencyAbsEntry();
            %       aSweep.StartFreqValue=4.5;
            %       aSweep.EndFreqValue=5.5;
            %
            %       % Create a variable sweep from
            %       % the ABS frequency sweep.
            %       Project.addVariableSweep(aSweep);
            
            % Check for the existance of a variable sweep block
            if isempty(obj.VariableSweepBlock)
                obj.VariableSweepBlock=SonnetVariableSweepBlock();
                obj.CellArrayOfBlocks{length(obj.CellArrayOfBlocks)+1}=obj.VariableSweepBlock;
            else
                isBlockExists=false;
                for iCounter=1:length(obj.CellArrayOfBlocks)
                    if isa(obj.CellArrayOfBlocks{iCounter},'SonnetVariableSweepBlock')
                        isBlockExists=true;
                    end
                end
                if isBlockExists == false
                    obj.CellArrayOfBlocks{length(obj.CellArrayOfBlocks)+1}=obj.VariableSweepBlock;
                end
            end
            
            %Check length of VariableSweepBlock and add one
            locationInBlock = length(obj.VariableSweepBlock.ArrayOfSweeps) + 1;
            
            %Add the object
            obj.VariableSweepBlock.ArrayOfSweeps{1,locationInBlock} = SonnetVariableSweepEntry();
            
            %Set the sweep type input parameter
            obj.VariableSweepBlock.ArrayOfSweeps{1,locationInBlock}.Sweep = theFreqSweepHandle;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addVariableSweepParameter(obj,theParameterName,theMinValue,theMaxValue,theNumberOfPoints,theEntryIndex)
            %addVariableSweepParameter   Add a variable sweep
            %   Project.addVariableSweepParameter(...) will add a variable
            %   sweep parameter to the array of sweep entries.
            %
            %   Input arguments are:
            %       1) Parameter Name -- The name of the parameter to sweep
            %       2) Min Value -- Starting value of the sweep
            %       3) Max Value -- Ending value of the sweep
            %       4) Number of Points -- Number of points on the sweep.
            %             for a corner sweep make this value be an empty matrix.
            %       5) Sweep Index (Optional) -- The index for the variable
            %              sweep entry block this parameter should be added
            %              to. Default is the first.
            %
            %   Note: The specified variable name should already be defined
            %         and incorporated into the project or Sonnet will
            %         not be able to perform the simulation.
            %
            %   Example usage:
            %       % Add an ABS sweep of variable 'VAR' with a minimum
            %       % of 5 max of 10 simulating 15 points.
            %       Project.addVariableSweepSimple('VAR',5,10,15)
            
            if nargin == 5
                theEntryIndex=1;
            end
            
            %Create and fill the parameter object
            obj.VariableSweepBlock.ArrayOfSweeps{theEntryIndex}.ParameterArray{end+1} = SonnetVariableSweepParameter();
            obj.VariableSweepBlock.ArrayOfSweeps{theEntryIndex}.ParameterArray{end}.ParameterName = theParameterName;
            obj.VariableSweepBlock.ArrayOfSweeps{theEntryIndex}.ParameterArray{end}.MinValue = theMinValue;
            obj.VariableSweepBlock.ArrayOfSweeps{theEntryIndex}.ParameterArray{end}.MaxValue = theMaxValue;
            obj.VariableSweepBlock.ArrayOfSweeps{theEntryIndex}.ParameterArray{end}.ParameterBeingUsedForSweep = 'Y';
            
            if isempty(theNumberOfPoints)
                obj.VariableSweepBlock.ArrayOfSweeps{theEntryIndex}.ParameterArray{end}.StepValue = [];
            else
                obj.VariableSweepBlock.ArrayOfSweeps{theEntryIndex}.ParameterArray{end}.StepValue = (theMaxValue - theMinValue) / theNumberOfPoints;
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function activateVariableSweepParameter(obj,theVariableName,theSweepIndex)
            %activateVariableSweepParameter   Activates a variable sweep parameter
            %   Project.activateVariableSweepParameter(VariableName) will set the
            %   parameter in use value for the specified parameter in the
            %   first variable sweep to true.
            %
            %   Project.activateVariableSweepParameter(VariableName,N) will 
            %   set the parameter in use value for the specified parameter in the
            %   Nth variable sweep to true.
            %
            %   See also SonnetProject.deactivateVariableSweepParameter
            
            if nargin == 3
                obj.VariableSweepBlock.activateVariableSweepParameter(theVariableName,theSweepIndex);
            else
                obj.VariableSweepBlock.activateVariableSweepParameter(theVariableName);
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function deactivateVariableSweepParameter(obj,theVariableName,theSweepIndex)
            %deactivateVariableSweepParameter   Deactivates a variable sweep parameter
            %   Project.deactivateVariableSweepParameter(VariableName) will set the
            %   parameter in use value for the specified parameter in the
            %   first variable sweep to false.
            %
            %   Project.deactivateVariableSweepParameter(VariableName,N) will 
            %   set the parameter in use value for the specified parameter in the
            %   Nth variable sweep to false.
            %
            %   See also SonnetProject.activateVariableSweepParameter
            
            if nargin == 3
                obj.VariableSweepBlock.deactivateVariableSweepParameter(theVariableName,theSweepIndex);
            else
                obj.VariableSweepBlock.deactivateVariableSweepParameter(theVariableName);
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeVariableSweepParameterState(obj,theVariableName,theStatus,theSweepIndex)
            %changeVariableSweepParameterState   Modify variable sweep parameter status
            %   Project.changeVariableSweepParameterState(VariableName) will  
            %   modify the parameter in use value for the specified parameter
            %   in the first variable sweep.
            %
            %   Project.changeVariableSweepParameterState(VariableName,N) will 
            %   modify the parameter in use value for the specified parameter in 
            %   the Nth variable sweep.
            %
            %   Appropriate status values are 'N','Y','YN','YS', and 'YE'.
            %
            %   See also SonnetProject.activateVariableSweepParameter
            
            if nargin == 4
                obj.VariableSweepBlock.changeVariableSweepParameterState(theVariableName,theStatus,theSweepIndex);
            else
                obj.VariableSweepBlock.changeVariableSweepParameterState(theVariableName,theStatus);
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function detectAllOptimizationVariables(obj)
            %detectAllOptimizationVariables   Adds all optimization variables
            %   Project.detectAllOptimizationVariables() will make an
            %   optimization variable entry for every dimensional parameter
            %   in the project. All of the optimization parameters will be
            %   disabled by default.
            %
            %   See also SonnetProject.editOptimizationVariable
            
            for iCounter=1:length(obj.GeometryBlock.ArrayOfVariables)
                
                isVariableInOptimizationBlock=false;
                
                % Check the optimization block for the variable name
                for jCounter=1:length(obj.OptimizationBlock.VarsArray)
                    if strcmpi(obj.GeometryBlock.ArrayOfVariables{iCounter}.VariableName,...
                            obj.OptimizationBlock.VarsArray{jCounter}.VariableName)==1
                        isVariableInOptimizationBlock=true;
                    end
                end
                
                % If the variable is not in the optimization block then
                % add it to the optimization block
                if ~isVariableInOptimizationBlock
                    aNewVariable=SonnetOptimizationVariable();
                    aNewVariable.VariableName=obj.GeometryBlock.ArrayOfVariables{iCounter}.VariableName;
                    aNewVariable.MinValue=1;
                    aNewVariable.MaxValue=2;
                    aNewVariable.StepValue=1;
                    aNewVariable.VariableBeingUsed='N';
                    obj.OptimizationBlock.VarsArray{end+1}=aNewVariable;
                end
                
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function editOptimizationVariable(obj,theVariableName,theMinimumValue,...
                theMaximumValue,theStepValue,isEnabled)
            %editOptimizationVariable   Edit values for an optimization variable
            %   Project.editOptimizationVariable(...) will allow users to edit the
            %   parameters for an optimization.
            %
            %   This function requires the following inputs:
            %       1) The name of the variable to be modified
            %       2) The minimum value for the variable
            %       3) The maximum value for the variable
            %       4) The step value with which we are sweeping
            %           from the minimum value to the maximum value.
            %       5) Either 'Y' to specify the variable
            %           is being used or 'n' to specify that the
            %           variable is not being used.
            %
            %   Example usage:
            %
            %       Project.editOptimizationVariable('dim',5,10,1,'Y')
            %
            %   See also SonnetProject.detectAllOptimizationVariables
            
            obj.OptimizationBlock.editOptimizationVariable(theVariableName,theMinimumValue,...
                theMaximumValue,theStepValue,isEnabled)
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addOptimizationParameter(obj,theSweep,theResponseType,...
                theRelationString,theTargetType,theTargetValue,theTargetResponseType,theWeight)
            %addOptimizationParameter   Create a new optimization parameter
            %   Project.addOptimizationParameter(...) adds a new optimization
            %   parameter to the optimization block. Optimization
            %   parameters define how the optimization variables get modified.
            %
            %   addOptimizationParameter requires the following inputs:
            %       1)  A frequency sweep object. The frequency sweep
            %           cannot be SonnetFrequencyAbs or SonnetFrequencySimple.
            %           but SonnetFrequencyAbsEntry and SonnetFrequencySweep
            %           can be used instead and correspond to the same sweeps.
            %       2)  The response type (Ex: 'DB[S11]')
            %       3)  The relation type ('>', '<', '=')
            %       4)  The type for the target response ('VALUE','NET','FILE').
            %           This is what the response will be compared to.
            %       5)  The target value. For targets of type 'VALUE' this
            %           will store the response value we would like
            %           to obtain from optimization. For 'NET'
            %           this argument stores the name of the network
            %           to compare to. For type 'FILE' this stores
            %           the name of the file that should be used.
            %       6)  If the target type is 'FILE' or 'NET' then
            %           the response type for the target value is
            %           required. If the type is 'VALUE' then this
            %           should be the empty string ('');
            %       7)  The weight for this optimization parameter. This
            %           value is often 1.
            %
            %   Example usage:
            %
            %       % Make an empty frequency sweep
            %       theSweep=SonnetFrequencyAbsEntry();
            %
            %       % Assign values to the frequency sweep properties
            %       theSweep.StartFreqValue=1;
            %       theSweep.EndFreqValue=5;
            %
            %       % Add the optimization parameter to the project
            %       Project.addOptimizationParameter(theSweep,'DB[S11]','=','VALUE',-20,1,1)
            
            if isa(theSweep,'SonnetFrequencyAbs')
                error('Improper sweep type: SonnetAbsFrequencySweep; try SonnetFrequencyAbsEntry instead')
            elseif isa(theSweep,'SonnetFrequencySimple')
                error('Improper sweep type: SonnetSimpleFrequencySweep; try SonnetFrequencySweep instead')
            else
                obj.OptimizationBlock.addOptimizationParameter(theSweep,theResponseType,...
                    theRelationString,theTargetType,theTargetValue,theTargetResponseType,theWeight)
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function enableCurrentCalculations(obj)
            %enableCurrentCalculations   Enable current calculations
            %   Project.enableCurrentCalculations() will enable current
            %   density calculation for this project. The project will
            %   need to be simulated before current density information
            %   will be available. Be aware that current density
            %   calculations can be time consuming.
            %
            %   Note: This method is only for geometry projects.
            %
            %   See also SonnetProject.viewCurrents,
            %            SonnetProject.disableCurrentCalculations
            
            if obj.isGeometryProject
                % set the control option if necessary
                if isempty(strfind(obj.ControlBlock.Options,'j'))
                    obj.ControlBlock.Options=[strtrim(obj.ControlBlock.Options) 'j'];
                end
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function disableCurrentCalculations(obj)
            %disableCurrentCalculations   Disable current calculations
            %   Project.disableCurrentCalculations will disable current
            %   density calculation for this project. This setting can
            %   be enabled with the 'enableCurrentCalculations()' function.
            %
            %   Note: This method is only for geometry projects.
            %
            %   See also SonnetProject.viewCurrents,
            %            SonnetProject.enableCurrentCalculations
            
            if obj.isGeometryProject
                % set the control option if necessary
                if ~isempty(strfind(obj.ControlBlock.Options,'j'))
                    obj.ControlBlock.Options=strrep(obj.ControlBlock.Options,'j','');
                end
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Add Polygon Methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addPolygon(obj,thePolygon)
            %addPolygon   Adds a polygon object to the project
            %   Project.addPolygon(Polygon) will add the passed
            %   polygon to the end of the array of polygons.
            %
            %   Note: This method is only for geometry projects.
            %
            %   See also SonnetProject.viewCurrents,
            %            SonnetProject.enableCurrentCalculations
            
            if obj.isGeometryProject
                if ~isa(thePolygon,'SonnetGeometryPolygon')
                    error('The passed object must be a polygon')
                else
                    obj.GeometryBlock.ArrayOfPolygons{obj.polygonCount+1}=thePolygon;
                end
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addMetalPolygon(obj,theMetalizationLevelIndex,theMetalType,theFillType,...
                theXMinimumSubsectionSize,theYMinimumSubsectionSize,theXMaximumSubsectionSize,...
                theYMaximumSubsectionSize,theMaximumLengthForTheConformalMeshSubsection,...
                theEdgeMesh,theXCoordinateValues,theYCoordinateValues)
            %addMetalPolygon   Add a metal polygon to the polygon array
            %   Project.addMetalPolygon(...) will add an polygon
            %   to the array of polygons.
            %
            %   addMetalPolygon requires these arguments:
            %      1)  metallization  Level Index ( The level the polygon is on)
            %      2)  The type of metal used for the polygon. This may either
            %           be a the index for the metal type in the array of
            %           metal types, or the name of the metal type
            %           (Ex: 'Copper'). Lossless metal is not in the array
            %           of metals but can be selected by either passing 0
            %           or 'Lossless'.
            %      3)  A string to identify the fill type used for the polygon.
            %           N indicates staircase fill, T indicates diagonal
            %           fill and V indicates conformal mesh.
            %      4)  Minimum subsection size in X direction
            %      5)  Minimum subsection size in Y direction
            %      6)  Maximum subsection size in X direction
            %      7)  Maximum subsection size in Y direction
            %      8)  The Maximum Length for The Conformal Mesh Subsection
            %      9)  Edge mesh setting. Y indicates edge meshing is on for this
            %          polygon. N indicates edge meshing is off.
            %      10) A column vector for the X coordinate values
            %      11) A column vector for the Y coordinate values
            %
            %   Note: Many users will prefer to use the 'addMetalPolygonEasy' method.
            %   Note: This method is only for geometry projects.
            %   Note: Sonnet version 12 projects have a shared metal type for planar
            %         and via polygons. Sonnet version 13 projects have separate
            %         metal types for planar polygons and via polygons.
            %
            %   Example usage:
            %       % metal at level 0, metal type -1 (lossless),
            %       % staircase fill, X subsection size from 0 to 50,
            %       % Y subsection size from 0 to 100.
            %       x=[5,10,10,5,5];
            %       y=[10,10,20,20,10];
            %       Project.addMetalPolygon(0,0,'N',0,0,50,100,0,'Y',x,y);
            %
            %       % metal at level 0, metal type 'ThinCopper',
            %       % staircase fill, X subsection size from 0 to 50,
            %       % Y subsection size from 0 to 100.
            %       x=[5,10,10,5,5];
            %       y=[10,10,20,20,10];
            %       Project.addMetalPolygon(0,'ThinCopper','N',0,0,50,100,0,'Y',x,y);
            %
            %   See also SonnetProject.addMetalPolygonEasy
            
            if obj.isGeometryProject
                obj.GeometryBlock.addMetalPolygon(theMetalizationLevelIndex,theMetalType,theFillType,theXMinimumSubsectionSize,theYMinimumSubsectionSize,theXMaximumSubsectionSize,theYMaximumSubsectionSize,theMaximumLengthForTheConformalMeshSubsection,theEdgeMesh,theXCoordinateValues,theYCoordinateValues);
            else
                error('This method is only available for Geometry projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aPolygon=addMetalPolygonEasy(obj,theMetalizationLevelIndex,theXCoordinateValues,theYCoordinateValues,theType)
            %addMetalPolygonEasy   Add a metal polygon to the polygon array
            %   Polygon=Project.addMetalPolygonEasy(...) will add an polygon
            %   to the array of polygons. A reference to the polygon
            %   is returned.
            %
            %   addMetalPolygonEasy requires these arguments:
            %      1) metallization  Level Index (The level the polygon is on)
            %      2) A column vector for the X coordinate values
            %      3) A column vector for the Y coordinate values
            %      4) (Optional) The type of metal used for the polygon.
            %           This may either be a the index for the metal
            %           type in the array of metal types, or the name
            %           of the metal type (Ex: 'Copper'). If this value
            %           is not specified then lossless metal will be used.
            %
            %   Note: This method is only for geometry projects.
            %   Note: Sonnet version 12 projects have a shared metal type for planar
            %         and via polygons. Sonnet version 13 projects have separate
            %         metal types for planar polygons and via polygons.
            %
            %   Example usage:
            %       % Build a lossless metal polygon on layer zero
            %       Project.addMetalPolygonEasy(0,[5,10,10,5,5],[10,10,20,20,10]);
            %
            %       % Build a copper metal polygon on layer zero (the Copper
            %       % metal type must be defined in the project)
            %       Project.addDielectricBrickEasy(0,[5,10,10,5,5],[10,10,20,20,10],'Copper');
            %
            %   See also SonnetProject.addMetalPolygon
            
            if obj.isGeometryProject
                if nargin == 4
                    obj.GeometryBlock.addMetalPolygon(theMetalizationLevelIndex,0,'N',1,1,100,100,0,'Y',theXCoordinateValues,theYCoordinateValues);
                    aPolygon=obj.getPolygon();
                else
                    obj.GeometryBlock.addMetalPolygon(theMetalizationLevelIndex,theType,'N',1,1,100,100,0,'Y',theXCoordinateValues,theYCoordinateValues);
                    aPolygon=obj.getPolygon();
                end
            else
                error('This method is only available for Geometry projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addDielectricBrick(obj,theMetalizationLevelIndex,theMetalType,theXMinimumSubsectionSize,...
                theYMinimumSubsectionSize,theXMaximumSubsectionSize,theYMaximumSubsectionSize,...
                theMaximumLengthForTheConformalMeshSubsection,theEdgeMesh,theXCoordinateValues,theYCoordinateValues)
            %addDielectricBrick   Add a dielectric brick polygon to the polygon array
            %   Project.addDielectricBrick(...) will add a polygon
            %   to the array of polygons.
            %
            %   addDielectricBrick requires these arguments:
            %     1)  metallization Level Index (The level the polygon is on)
            %     2)  The material used for the polygon. This may either
            %          be a the index for the brick material type in the
            %          array of brick types, Or the name of the material
            %          (Ex: 'Air'). Air is not in the array of isotropic
            %          or anisotropic materials but can be selected by
            %          either passing 0 or 'Air'.
            %     3)  Minimum subsection size in X direction
            %     4)  Minimum subsection size in Y direction
            %     5)  Maximum subsection size in X direction
            %     6)  Maximum subsection size in Y direction
            %     7)  The Maximum Length for The Conformal Mesh Subsection
            %     8)  Edge mesh setting. Y indicates edge meshing is on for this
            %           polygon. N indicates edge meshing is off.
            %     9)  A matrix for the X coordinate values
            %     10) A matrix for the Y coordinate values
            %
            %   Note: Many users will prefer to use the 'addDielectricBrickEasy' method.
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %       % Metal at level 0, material type 0 (Air),
            %       % X subsection size from 0 to 50,
            %       % Y subsection size from 0 to 100.
            %       x=[5,10,10,5,5];
            %       y=[10,10,20,20,10];
            %       Project.addDielectricBrick(0,0,0,0,50,100,0,'Y',x,y);
            %
            %       % Metal at level 0, material type Brick1,
            %       % X subsection size from 0 to 50,
            %       % Y subsection size from 0 to 100.
            %       x=[5,10,10,5,5];
            %       y=[10,10,20,20,10];
            %       Project.addDielectricBrick(0,'Brick1',0,0,50,100,0,'Y',x,y);
            %
            %   See also SonnetProject.addDielectricBrickEasy
            
            if obj.isGeometryProject
                obj.GeometryBlock.addDielectricBrick(theMetalizationLevelIndex,theMetalType,theXMinimumSubsectionSize,theYMinimumSubsectionSize,theXMaximumSubsectionSize,theYMaximumSubsectionSize,theMaximumLengthForTheConformalMeshSubsection,theEdgeMesh,theXCoordinateValues,theYCoordinateValues);
            else
                error('This method is only available for Geometry projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aPolygon=addDielectricBrickEasy(obj,theMetalizationLevelIndex,theXCoordinateValues,theYCoordinateValues, theMaterial)
            %addDielectricBrickEasy   Add a dielectric brick polygon to the polygon array
            %   Polygon=Project.addDielectricBrickEasy(...) will add a dielectric brick
            %   to the array of polygons. A reference to the polygon
            %   is returned.
            %
            %   addDielectricBrickEasy requires these arguments:
            %     1) metallization  Level Index (The level the polygon is on)
            %     2) A column vector for the X coordinate values
            %     3) A column vector for the Y coordinate values
            %     4) (Optional) The material used for the polygon. This may
            %         either be a the index for the brick material type in
            %         the array of brick types, or the name of the material
            %         (Ex: 'Air'). If this value is not specified the
            %         function will use 'Air'.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %       % Build a brick on layer zero of type 'Air'
            %       Project.addDielectricBrickEasy(0,[5,10,10,5,5],[10,10,20,20,10]);
            %
            %       % Build a brick on layer zero of type 'Brick1'
            %       Project.addDielectricBrickEasy(0,[5,10,10,5,5],[10,10,20,20,10],'Brick1');
            %
            %   See also SonnetProject.addDielectricBrick
            
            if obj.isGeometryProject
                if nargin==4
                    obj.GeometryBlock.addDielectricBrick(theMetalizationLevelIndex,0,1,1,100,100,0,'Y',theXCoordinateValues,theYCoordinateValues);
                    aPolygon=obj.getPolygon();
                else
                    obj.GeometryBlock.addDielectricBrick(theMetalizationLevelIndex,theMaterial,1,1,100,100,0,'Y',theXCoordinateValues,theYCoordinateValues);
                    aPolygon=obj.getPolygon();
                end
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addViaPolygon(obj,theToLevel,theMetalizationLevelIndex,theMetalType,theFillType,...
                theXMinimumSubsectionSize,theYMinimumSubsectionSize,theXMaximumSubsectionSize,...
                theYMaximumSubsectionSize,theMaximumLengthForTheConformalMeshSubsection,...
                theEdgeMesh,theXCoordinateValues,theYCoordinateValues)
            %addViaPolygon   Add a via polygon to the polygon array
            %   Project.addViaPolygon(...) will add a Via Polygon
            %   to the array of Polygons.
            %
            %   addViaPolygon requires these arguments:
            %     1)  The level the VIA attaches to.
            %     2)  metallization  Level Index (The level the polygon is on)
            %     3)  The type of metal used for the polygon. This may either
            %          be a the index for the metal type in the array of
            %          metal types, or the name of the metal type
            %          (Ex: 'Copper'). Lossless metal is not in the array
            %          of metals but can be selected by either passing 0
            %          or 'Lossless'.
            %     4)  A string to identify the fill type used for the polygon.
            %           N indicates staircase fill, T indicates diagonal
            %           fill and V indicates conformal mesh. Note that filltype
            %           only applies to metal
            %           polygons; this field is ignored for dielectric brick polygons
            %     5)  Minimum subsection size in X direction
            %     6)  Minimum subsection size in Y direction
            %     7)  Maximum subsection size in X direction
            %     8)  Maximum subsection size in Y direction
            %     9)  The Maximum Length for The Conformal Mesh Subsection
            %     10) Edge mesh setting. Y indicates edge meshing is on for this
            %           polygon. N indicates edge meshing is off.
            %     11) A matrix for the X coordinate values.
            %     12) A matrix for the Y coordinate values
            %
            %   Note: Many users will prefer to use the 'addViaPolygonEasy' method.
            %   Note: This method is only for geometry projects.
            %   Note: Sonnet version 12 projects have a shared metal type for planar
            %         and via polygons. Sonnet version 13 projects have separate
            %         metal types for planar polygons and via polygons.
            %
            %   Example usage:
            %       % Create a via at level 0, attached to 'GND', metal type -1 (lossless),
            %       % staircase fill, X subsection size from 0 to 50,
            %       % Y subsection size from 0 to 100.
            %       x=[5,10,10,5,5];
            %       y=[10,10,20,20,10];
            %       Project.addViaPolygon('GND',0,0,'N',0,0,50,100,0,'Y',x,y);
            %
            %       % Create a via at level 0, attached to 'GND', metal type 'Copper',
            %       % staircase fill, X subsection size from 0 to 50,
            %       % Y subsection size from 0 to 100.
            %       x=[5,10,10,5,5];
            %       y=[10,10,20,20,10];
            %       Project.addViaPolygon('GND',0,'Copper','N',0,0,50,100,0,'Y',x,y);
            %
            % See also SonnetProject.addViaPolygonEasy
            
            if obj.isGeometryProject
                
                % Find the version number
                if (~isempty(obj.VersionOfSonnet))
                    if isa(obj.VersionOfSonnet,'char')
                        aVersion=sscanf(obj.VersionOfSonnet,'%d'); % Extract the first two digits of the version number
                    else
                        aVersion=obj.VersionOfSonnet;
                    end
                end
                
                obj.GeometryBlock.addViaPolygon(aVersion,theToLevel,theMetalizationLevelIndex,...
                    theMetalType,theFillType,theXMinimumSubsectionSize,...
                    theYMinimumSubsectionSize,theXMaximumSubsectionSize,...
                    theYMaximumSubsectionSize,theMaximumLengthForTheConformalMeshSubsection,...
                    theEdgeMesh,theXCoordinateValues,theYCoordinateValues);
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aPolygon=addViaPolygonEasy(obj,theMetalizationLevelIndex,theToLevel,...
                theXCoordinateValues,theYCoordinateValues,theType)
            %addViaPolygonEasy   Add a via polygon to the polygon array
            %   Polygon=Project.addViaPolygonEasy(...) will add an via polygon
            %   to the array of polygons. A reference to the polygon
            %   is returned.
            %
            %   addViaPolygonEasy requires these arguments:
            %      1) metallization  Level Index (The level the polygon is on)
            %      2) The level the via is connected to
            %      3) A matrix for the X coordinate values
            %      4) A matrix for the Y coordinate values
            %      5) (Optional) The type of metal used for the polygon.
            %           This may either be a the index for the metal
            %           type in the array of metal types, or the name
            %           of the metal type (Ex: 'Copper'). If this value
            %           is not specified then lossless metal will be used.
            %
            %   Note: This method is only for geometry projects.
            %   Note: Sonnet version 12 projects have a shared metal type for planar
            %         and via polygons. Sonnet version 13 projects have separate
            %         metal types for planar polygons and via polygons.
            %
            %   Example usage:
            %       % Lossless via at level 0, attached to 'GND'
            %       Project.addViaPolygonEasy(0,'GND',[5,10,10,5,5],[10,10,20,20,10]);
            %
            %       % Copper via at level 0, attached to 'GND' (Copper
            %       % metal must type must be defined for the project)
            %       Project.addViaPolygonEasy(0,'GND',[5,10,10,5,5],[10,10,20,20,10],'Copper');
            %
            % See also SonnetProject.addViaPolygon
            
            if obj.isGeometryProject
                
                % Find the version number
                if (~isempty(obj.VersionOfSonnet))
                    if isa(obj.VersionOfSonnet,'char')
                        aVersion=sscanf(obj.VersionOfSonnet,'%d'); % Extract the first two digits of the version number
                    else
                        aVersion=obj.VersionOfSonnet;
                    end
                end
                
                if nargin == 5
                    obj.GeometryBlock.addViaPolygon(aVersion,theToLevel,theMetalizationLevelIndex,0,'N',1,1,100,...
                        100,0,'Y',theXCoordinateValues,theYCoordinateValues);
                    aPolygon=obj.getPolygon();
                else
                    obj.GeometryBlock.addViaPolygon(aVersion,theToLevel,theMetalizationLevelIndex,theType,'N',1,1,100,...
                        100,0,'Y',theXCoordinateValues,theYCoordinateValues);
                    aPolygon=obj.getPolygon();
                end
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function theNewPolyIndex = copyMetalPolygon(obj,aPolyIndex)
            %copyMetalPolygon Makes a copy of a metal polygon
            %   newPolygonIndex=Project.copyMetalPolygon(index) makes a
            %   carbon copy of a metal polygon specified by an index
            %   in the array of polygons. The new polygon's index will
            %   be returned.
            %
            %   Note: This method is only for geometry projects.
            %
            % See also SonnetProject.copyPolygon,
            %          SonnetProject.copyPolygonUsingId,
            %          SonnetProject.copyPolygonUsingIndex
            
            if obj.isGeometryProject
                
                %Find length of the polygon array
                newPosition = length(obj.GeometryBlock.ArrayOfPolygons)+1;
                
                % Find a valid debug ID Number
                % Build an array of all the debugIds
                aArrayOfIds=zeros(1,length(obj.GeometryBlock.ArrayOfPolygons));
                for iCounter=1:newPosition-1
                    aArrayOfIds(iCounter)=obj.GeometryBlock.ArrayOfPolygons{iCounter}.DebugId;
                end
                
                % The new debugId can be one more than the largest one
                theNewPolyId=max(aArrayOfIds)+1;
                
                %Add a new polygon at the end of the array
                obj.GeometryBlock.ArrayOfPolygons{1,newPosition} = SonnetGeometryPolygon();
                
                %Copy all non hidden properties from the original
                theProperties = properties(obj.GeometryBlock.ArrayOfPolygons{1,aPolyIndex});
                for jCounter = 1:length(theProperties)
                    if ~strcmp(theProperties{jCounter},'NumberOfVerticies') && ~strcmp(theProperties{jCounter},'CentroidXCoordinate') && ~strcmp(theProperties{jCounter},'CentroidYCoordinate') && ~strcmp(theProperties{jCounter},'PolygonSize') && ~strcmp(theProperties{jCounter},'MeanXCoordinate') && ~strcmp(theProperties{jCounter},'MeanYCoordinate')%Properties to ignore
                        obj.GeometryBlock.ArrayOfPolygons{1,newPosition}.(theProperties{jCounter}) = obj.GeometryBlock.ArrayOfPolygons{1,aPolyIndex}.(theProperties{jCounter});
                    end
                end
                
                %Overwrite the debug ID with the new one
                obj.GeometryBlock.ArrayOfPolygons{1,newPosition}.DebugId = theNewPolyId;
                theNewPolyIndex = newPosition;
                
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aNewPolygon=copyPolygon(obj,aPolygonId)
            %copyPolygon      Makes a copy of a polygon and adds it to the project
            %   Polygon=Project.copyPolygon(ID) Returns a copy of the polygon with the
            %   passed ID value. The new polygon will have a unique ID.
            %
            %   Polygon=Project.copyPolygon(Polygon) Returns a copy of the passed
            %   polygon. The new polygon will have a unique ID.
            %
            %   Note: This method is only for geometry projects.
            %
            %  See also SonnetProject.copyPolygonUsingId,
            %           SonnetProject.copyPolygonUsingIndex,
            %           SonnetProject.duplicatePolygon,
            %           SonnetProject.duplicatePolygonUsingId,
            %           SonnetProject.duplicatePolygonUsingIndex,
            
            if obj.isGeometryProject
                aNewPolygon=obj.GeometryBlock.copyPolygonUsingId(aPolygonId);
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aNewPolygon=copyPolygonUsingId(obj,aPolygonId)
            %copyPolygonUsingId      Makes a copy of a polygon and adds it to the project
            %   Polygon=Project.copyPolygonUsingId(ID) Makes a copy of the polygon with the
            %   passed ID value. The new polygon will have a unique ID.
            %
            %   Polygon=Project.copyPolygonUsingId(Polygon) Makes a copy of the passed
            %   polygon. The new polygon will have a unique ID.
            %
            %   Note: This method is only for geometry projects.
            %
            %  See also SonnetProject.copyPolygon,
            %           SonnetProject.copyPolygonUsingIndex,
            %           SonnetProject.duplicatePolygon,
            %           SonnetProject.duplicatePolygonUsingId,
            %           SonnetProject.duplicatePolygonUsingIndex,
            
            if obj.isGeometryProject
                aNewPolygon=obj.GeometryBlock.copyPolygonUsingId(aPolygonId);
            else
                error('This method is only available for Geometry projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aNewPolygon=copyPolygonUsingIndex(obj,aPolygonIndex)
            %copyPolygonUsingIndex      Makes a copy of a polygon and adds it to the project
            %   Polygon=Project.copyPolygonUsingIndex(N) Returns a copy of the Nth polygon
            %   in the array of polygons. The new polygon will have a unique debug ID.
            %
            %   Polygon=Project.copyPolygonUsingIndex(Polygon) Returns a copy of the passed
            %   polygon. The new polygon will have a unique ID. The new polygon will be
            %   returned.
            %
            %   Note: This method is only for geometry projects.
            %
            %  See also SonnetProject.copyPolygon,
            %           SonnetProject.copyPolygonUsingId
            %           SonnetProject.duplicatePolygon,
            %           SonnetProject.duplicatePolygonUsingId,
            %           SonnetProject.duplicatePolygonUsingIndex,
            
            if obj.isGeometryProject
                aNewPolygon=obj.GeometryBlock.copyPolygonUsingIndex(aPolygonIndex);
            else
                error('This method is only available for Geometry projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aNewPolygon=duplicatePolygon(obj,aPolygonId)
            %duplicatePolygon      Makes a copy of a polygon and adds it to the project
            %   Polygon=Project.duplicatePolygon(ID) Makes a copy of the polygon with the
            %   passed ID value and adds the copy to the end of the array of polygons.
            %   The new polygon will have a unique ID. The new polygon will be returned.
            %
            %   Polygon=Project.duplicatePolygon(Polygon) Makes a copy of the passed
            %   polygon and adds the copy to the end of the array of polygons.
            %   The new polygon will have a unique ID. The new polygon will be returned.
            %
            %   Note: This method is only for geometry projects.
            %
            %  See also SonnetProject.copyPolygon,
            %           SonnetProject.copyPolygonUsingId,
            %           SonnetProject.copyPolygonUsingIndex,
            %           SonnetProject.duplicatePolygonUsingId,
            %           SonnetProject.duplicatePolygonUsingIndex
            
            if obj.isGeometryProject
                aNewPolygon=obj.copyPolygon(aPolygonId);
                obj.GeometryBlock.ArrayOfPolygons{obj.polygonCount+1}=aNewPolygon;
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aNewPolygon=duplicatePolygonUsingId(obj,aPolygonId)
            %duplicatePolygonUsingId      Makes a copy of a polygon and adds it to the project
            %   Polygon=Project.duplicatePolygonUsingId(ID) Makes a copy of the
            %   polygon with the passed ID value and adds the copy to the end of
            %   the array of polygons. The new polygon will have a unique ID. The
            %   new polygon will be returned.
            %
            %   Polygon=Project.duplicatePolygonUsingId(Polygon) Makes a copy of
            %   the passed polygon and adds the copy to the end of the array of
            %   polygons. The new polygon will have a unique ID. The new polygon
            %   will be returned.
            %
            %   Note: This method is only for geometry projects.
            %
            %  See also SonnetProject.copyPolygon,
            %           SonnetProject.copyPolygonUsingId,
            %           SonnetProject.copyPolygonUsingIndex,
            %           SonnetProject.duplicatePolygon,
            %           SonnetProject.duplicatePolygonUsingIndex
            
            if obj.isGeometryProject
                aNewPolygon=obj.copyPolygonUsingId(aPolygonId);
                obj.GeometryBlock.ArrayOfPolygons{obj.polygonCount+1}=aNewPolygon;
            else
                error('This method is only available for Geometry projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aNewPolygon=duplicatePolygonUsingIndex(obj,aPolygonIndex)
            %duplicatePolygonUsingIndex      Makes a copy of a polygon and adds it to the project
            %   Polygon=Project.duplicatePolygonUsingIndex(N) Makes a copy of the Nth
            %   polygon in the array of polygons and adds the copy to the end of the
            %   array of polygons. The new polygon will have a unique debug ID. The
            %   new polygon will be returned.
            %
            %   Polygon=Project.duplicatePolygonUsingIndex(Polygon) Makes a copy of the
            %   passed polygon and adds the copy to the end of the array of polygons.
            %   The new polygon will have a unique ID. The new polygon will be returned.
            %
            %   Note: This method is only for geometry projects.
            %
            %  See also SonnetProject.copyPolygon,
            %           SonnetProject.copyPolygonUsingId,
            %           SonnetProject.copyPolygonUsingIndex,
            %           SonnetProject.duplicatePolygon,
            %           SonnetProject.duplicatePolygonUsingId
            
            if obj.isGeometryProject
                aNewPolygon=obj.copyPolygonUsingIndex(aPolygonIndex);
                obj.GeometryBlock.ArrayOfPolygons{obj.polygonCount+1}=aNewPolygon;
            else
                error('This method is only available for Geometry projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Polygon Search Methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aPolygon=getPolygon(obj,theIndex)
            %getPolygon   Returns polygon in the project
            %   aPolygon=Project.getPolygon(N) will return the Nth polygon
            %   in the array of polygons.
            %
            %   aPolygon=Project.getPolygon() will return the last polygon
            %   in the array of polygons.
            %
            %   This operation can also be achieved with
            %       polygon=Project.GeometryBlock.ArrayOfPolygons{N};
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Get the 5th polygon in the array of polygons
            %       polygon=Project.getPolygon(5);
            
            if obj.isGeometryProject
                % If no index was specified then return the last
                % polygon in the array of polygons
                if nargin == 1
                    theIndex=length(obj.GeometryBlock.ArrayOfPolygons);
                end
                
                % Check if the index is outside the bounds of the array
                if theIndex<1 || theIndex>length(obj.GeometryBlock.ArrayOfPolygons)
                    error('Value for polygon index is outside the range of polygons');
                else
                    aPolygon=obj.GeometryBlock.ArrayOfPolygons{theIndex};
                end
            else
                error('This method is only available for Geometry projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [thePolygon, thePolygonId, theIndex]=findPolygonUsingFunction(obj,theFunction)
            %findPolygonUsingFunction   Finds a polygon using a function
            %   [polygon ID index]=Project.findPolygonUsingFunction(Function) finds
            %   polygons using a particular user specified function.
            %
            %   The passed function is expected to receive an argument of
            %   type SonnetGeometryPolygon and return a Boolean. The
            %   function should return true if the polygon should be
            %   included in the returned results.
            %
            %   Because the polygon gets sent to a user made function the
            %   passed function may modify the polygon whilst inside the
            %   passed function.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %       % This dummy function returns all polygons
            %       % that have an X Centroid greater than 50.
            %       function result=dummySearch(polygon)
            %           if polygon.CentroidXCoordinate > 50
            %               result=true;
            %           else
            %               result=false;
            %           end
            %       end
            %
            %       % Find all polygons on any layer that have a
            %       % centroid X coordinate greater than 50
            %       [PolygonObject PolygonId IndexInArray]=...
            %       Project.findPolygonUsingFunction(@dummySearch);
            %
            % See also SonnetProject.findPolygonUsingCentroidXY,
            %          SonnetProject.findPolygonUsingCentroidX,
            %          SonnetProject.findPolygonUsingCentroidY,
            %          SonnetProject.findPolygonUsingMeanXY,
            %          SonnetProject.findPolygonUsingMeanX,
            %          SonnetProject.findPolygonUsingMeanY,
            %          SonnetProject.findPolygonUsingPoint
            
            [thePolygon, thePolygonId, theIndex]=obj.GeometryBlock.findPolygonUsingFunction(theFunction);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [thePolygon, thePolygonId, theIndex]=findPolygonUsingCentroidXY(obj,theXCoordinate,theYCoordinate,theLayer,theSize)
            %findPolygonUsingCentroidXY   Finds a polygon given its centroid
            %   [polygon ID index]=Project.findPolygonUsingCentroidXY(X,Y) finds
            %   polygons have an centroid coordinate of ('X','Y').
            %
            %   [polygon ID index]=Project.findPolygonUsingCentroidXY(X,Y,Layer) finds
            %   polygons have an centroid coordinate of ('X','Y') on the metallization
            %   layer specified by 'Layer'.
            %
            %   [polygon ID index]=Project.findPolygonUsingCentroidXY(X,Y,Layer,Size) finds
            %   polygons have an centroid coordinate of ('X','Y') and a size of 'Size' on
            %   the metallization  layer specified by 'Layer'.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Find all polygons on any layer
            %       % that have a centroid at (0,0)
            %       [PolygonObject PolygonId IndexInArray]=Project.findPolygonUsingCentroidXY(0,0);
            %
            % See also SonnetProject.findPolygonUsingCentroidX,
            %          SonnetProject.findPolygonUsingCentroidY,
            %          SonnetProject.findPolygonUsingMeanXY,
            %          SonnetProject.findPolygonUsingMeanX,
            %          SonnetProject.findPolygonUsingMeanY,
            %          SonnetProject.findPolygonUsingPoint
            
            if obj.isGeometryProject
                if nargin == 3
                    [thePolygon, thePolygonId, theIndex]=obj.GeometryBlock.findPolygonUsingCentroidXY(theXCoordinate,theYCoordinate);
                elseif nargin == 4
                    [thePolygon, thePolygonId, theIndex]=obj.GeometryBlock.findPolygonUsingCentroidXY(theXCoordinate,theYCoordinate,theLayer);
                elseif nargin == 5
                    [thePolygon, thePolygonId, theIndex]=obj.GeometryBlock.findPolygonUsingCentroidXY(theXCoordinate,theYCoordinate,theLayer,theSize);
                else
                    error('Invalid number of parameters.');
                end
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [thePolygon, thePolygonId, theIndex]=findPolygonUsingCentroidX(obj,theXCoordinate,theLayer,theSize)
            %findPolygonUsingCentroidX   Finds a polygon given its centroid
            %   [polygon ID index]=Project.findPolygonUsingCentroidX(X) finds
            %   polygons have an centroid x coordinate of 'X'.
            %
            %   [polygon ID index]=Project.findPolygonUsingCentroidX(X,Layer) finds
            %   polygons have an centroid x coordinate of 'X' on the metallization
            %   layer specified by 'Layer'.
            %
            %   [polygon ID index]=Project.findPolygonUsingCentroidX(X,Layer,Size) finds
            %   polygons have an centroid x coordinate of 'X' and a size of 'Size' on
            %   the metallization  layer specified by 'Layer'.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Find all polygons on any layer that have a
            %       % centroid X value of zero.
            %       [PolygonObject PolygonId IndexInArray]=Project.findPolygonUsingCentroidX(0);
            %
            % See also SonnetProject.findPolygonUsingCentroidXY,
            %          SonnetProject.findPolygonUsingCentroidY
            %          SonnetProject.findPolygonUsingMeanXY,
            %          SonnetProject.findPolygonUsingMeanX,
            %          SonnetProject.findPolygonUsingMeanY,
            %          SonnetProject.findPolygonUsingPoint
            if obj.isGeometryProject
                if nargin == 2
                    [thePolygon, thePolygonId, theIndex]=obj.GeometryBlock.findPolygonUsingCentroidX(theXCoordinate);
                elseif nargin == 3
                    [thePolygon, thePolygonId, theIndex]=obj.GeometryBlock.findPolygonUsingCentroidX(theXCoordinate,theLayer);
                elseif nargin == 4
                    [thePolygon, thePolygonId, theIndex]=obj.GeometryBlock.findPolygonUsingCentroidX(theXCoordinate,theLayer,theSize);
                else
                    error('Invalid number of parameters.');
                end
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [thePolygon, thePolygonId, theIndex]=findPolygonUsingCentroidY(obj,theYCoordinate,theLayer,theSize)
            %findPolygonUsingCentroidY   Finds a polygon given its centroid
            %   [polygon ID index]=Project.findPolygonUsingCentroidY(Y) finds
            %   polygons have an centroid y coordinate of 'Y'.
            %
            %   [polygon ID index]=Project.findPolygonUsingCentroidY(Y,Layer) finds
            %   polygons have an centroid y coordinate of 'Y' on the metallization
            %   layer specified by 'Layer'.
            %
            %   [polygon ID index]=Project.findPolygonUsingCentroidY(Y,Layer,Size) finds
            %   polygons have an centroid y coordinate of 'Y' and a size of 'Size' on
            %   the metallization  layer specified by 'Layer'.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Find all polygons on any layer that have a
            %       % centroid Y value of zero.
            %       [PolygonObject PolygonId IndexInArray]=Project.findPolygonUsingCentroidY(0);
            %
            % See also SonnetProject.findPolygonUsingCentroidX,
            %          SonnetProject.findPolygonUsingCentroidXY,
            %          SonnetProject.findPolygonUsingMeanXY,
            %          SonnetProject.findPolygonUsingMeanX,
            %          SonnetProject.findPolygonUsingMeanY,
            %          SonnetProject.findPolygonUsingPoint
            
            if obj.isGeometryProject
                if nargin == 2
                    [thePolygon, thePolygonId, theIndex]=obj.GeometryBlock.findPolygonUsingCentroidY(theYCoordinate);
                elseif nargin == 3
                    [thePolygon, thePolygonId, theIndex]=obj.GeometryBlock.findPolygonUsingCentroidY(theYCoordinate,theLayer);
                elseif nargin == 4
                    [thePolygon, thePolygonId, theIndex]=obj.GeometryBlock.findPolygonUsingCentroidY(theYCoordinate,theLayer,theSize);
                else
                    error('Invalid number of parameters.');
                end
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [thePolygon, thePolygonId, theIndex]=findPolygonUsingMeanXY(obj,theXCoordinate,theYCoordinate,theLayer,theSize)
            %findPolygonUsingMeanXY   Finds a polygon given its mean
            %   [polygon ID index]=Project.findPolygonUsingMeanXY(X,Y) finds
            %   polygons have an mean coordinate of ('X','Y').
            %
            %   [polygon ID index]=Project.findPolygonUsingMeanXY(X,Y,Layer) finds
            %   polygons have an mean coordinate of ('X','Y') on the metallization
            %   layer specified by 'Layer'.
            %
            %   [polygon ID index]=Project.findPolygonUsingMeanXY(X,Y,Layer,Size) finds
            %   polygons have an mean coordinate of ('X','Y') and a size of 'Size' on
            %   the metallization  layer specified by 'Layer'.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Find all polygons on any layer that have a
            %       % mean at (0,0)
            %       [PolygonObject PolygonId IndexInArray]=Project.findPolygonUsingMeanXY(0,0);
            %
            % See also SonnetProject.findPolygonUsingCentroidX,
            %          SonnetProject.findPolygonUsingCentroidY,
            %          SonnetProject.findPolygonUsingCentroidXY,
            %          SonnetProject.findPolygonUsingMeanX,
            %          SonnetProject.findPolygonUsingMeanY,
            %          SonnetProject.findPolygonUsingPoint
            
            if obj.isGeometryProject
                if nargin == 3
                    [thePolygon, thePolygonId, theIndex]=obj.GeometryBlock.findPolygonUsingMeanXY(theXCoordinate,theYCoordinate);
                elseif nargin == 4
                    [thePolygon, thePolygonId, theIndex]=obj.GeometryBlock.findPolygonUsingMeanXY(theXCoordinate,theYCoordinate,theLayer);
                elseif nargin == 5
                    [thePolygon, thePolygonId, theIndex]=obj.GeometryBlock.findPolygonUsingMeanXY(theXCoordinate,theYCoordinate,theLayer,theSize);
                else
                    error('Invalid number of parameters.');
                end
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [thePolygon, thePolygonId, theIndex]=findPolygonUsingMeanX(obj,theXCoordinate,theLayer,theSize)
            %findPolygonUsingMeanX   Finds a polygon given its mean
            %   [polygon ID index]=Project.findPolygonUsingMeanX(X) finds
            %   polygons have an mean x coordinate of 'X'.
            %
            %   [polygon ID index]=Project.findPolygonUsingMeanX(X,Layer) finds
            %   polygons have an mean x coordinate of 'X' on the metallization
            %   layer specified by 'Layer'.
            %
            %   [polygon ID index]=Project.findPolygonUsingMeanX(X,Layer,Size) finds
            %   polygons have an mean x coordinate of 'X' and a size of 'Size' on
            %   the metallization  layer specified by 'Layer'.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Find all polygons on any layer that have a
            %       % mean X value of zero.
            %       [PolygonObject PolygonId IndexInArray]=Project.findPolygonUsingMeanX(0);
            %
            % See also SonnetProject.findPolygonUsingCentroidX,
            %          SonnetProject.findPolygonUsingCentroidY,
            %          SonnetProject.findPolygonUsingCentroidXY,
            %          SonnetProject.findPolygonUsingMeanXY,
            %          SonnetProject.findPolygonUsingMeanY,
            %          SonnetProject.findPolygonUsingPoint
            
            if obj.isGeometryProject
                if nargin == 2
                    [thePolygon, thePolygonId, theIndex]=obj.GeometryBlock.findPolygonUsingMeanX(theXCoordinate);
                elseif nargin == 3
                    [thePolygon, thePolygonId, theIndex]=obj.GeometryBlock.findPolygonUsingMeanX(theXCoordinate,theLayer);
                elseif nargin == 4
                    [thePolygon, thePolygonId, theIndex]=obj.GeometryBlock.findPolygonUsingMeanX(theXCoordinate,theLayer,theSize);
                else
                    error('Invalid number of parameters.');
                end
            else
                error('This method is only available for Geometry projects');
            end
            
        end 
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [thePolygon, thePolygonId, theIndex]=findPolygonUsingMeanY(obj,theYCoordinate,theLayer,theSize)
            %findPolygonUsingMeanY   Finds a polygon given its mean
            %   [polygon ID index]=Project.findPolygonUsingMeanY(Y) finds
            %   polygons have an mean y coordinate of 'Y'.
            %
            %   [polygon ID index]=Project.findPolygonUsingMeanY(Y,Layer) finds
            %   polygons have an mean y coordinate of 'Y' on the metallization
            %   layer specified by 'Layer'.
            %
            %   [polygon ID index]=Project.findPolygonUsingMeanY(Y,Layer,Size) finds
            %   polygons have an mean y coordinate of 'Y' and a size of 'Size' on
            %   the metallization  layer specified by 'Layer'.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Find all polygons on any layer that have a
            %       % mean Y value of zero.
            %       [PolygonObject PolygonId IndexInArray]=Project.findPolygonUsingMeanY(0);
            %
            % See also SonnetProject.findPolygonUsingCentroidX,
            %          SonnetProject.findPolygonUsingCentroidY,
            %          SonnetProject.findPolygonUsingCentroidXY,
            %          SonnetProject.findPolygonUsingMeanX,
            %          SonnetProject.findPolygonUsingMeanXY,
            %          SonnetProject.findPolygonUsingPoint
            
            if obj.isGeometryProject
                if nargin == 2
                    [thePolygon, thePolygonId, theIndex]=obj.GeometryBlock.findPolygonUsingMeanY(theYCoordinate);
                elseif nargin == 3
                    [thePolygon, thePolygonId, theIndex]=obj.GeometryBlock.findPolygonUsingMeanY(theYCoordinate,theLayer);
                elseif nargin == 4
                    [thePolygon, thePolygonId, theIndex]=obj.GeometryBlock.findPolygonUsingMeanY(theYCoordinate,theLayer,theSize);
                else
                    error('Invalid number of parameters.');
                end
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [thePolygon, thePolygonId, theIndex]=findPolygonUsingPoint(obj, theXCoordinate, theYCoordinate, theLevel)
            %findPolygonUsingPoint   Find a polygon that contains a particular coordinate pair
            %   [polygon ID index]=Project.findPolygonUsingPoint(X,Y) finds a
            %   polygon in the array of polygons given an X and Y coordinate pair
            %   that is within the polygon. This method returns a reference to the
            %   polygon object, the polygon's Debug Id, and the index for the polygon
            %   in the cell array of polygons. If the supplied point is within more
            %   than one polygon all of the polygons are returned.
            %
            %   [polygon ID index]=Project.findPolygonUsingPoint(X,Y,Level) finds a
            %   polygon in the array of polygons given an X and Y coordinate pair
            %   that is within the polygon. Only polygons on the specified layer are
            %   checked. This method returns a reference to the polygon object, the
            %   polygon's Debug Id, and the index for the polygon in the cell array
            %   of polygons. If the supplied point is within more than one polygon
            %   all of the polygons are returned.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Find all polygons on any layer
            %       % encompass the point (0,0)
            %       [PolygonObject PolygonId IndexInArray]=Project.findPolygonUsingPoint(0,0);
            %
            % See also SonnetProject.findPolygonUsingCentroidX,
            %          SonnetProject.findPolygonUsingCentroidY,
            %          SonnetProject.findPolygonUsingCentroidXY,
            %          SonnetProject.findPolygonUsingMeanX,
            %          SonnetProject.findPolygonUsingMeanY,
            %          SonnetProject.findPolygonUsingMeanXY
            
            if obj.isGeometryProject
                if nargin == 3 % If we did not receive the level as an argument
                    [thePolygon, thePolygonId, theIndex]=obj.GeometryBlock.findPolygonUsingPoint(theXCoordinate, theYCoordinate);
                elseif nargin == 4 % If we did receive the level as an argument
                    [thePolygon, thePolygonId, theIndex]=obj.GeometryBlock.findPolygonUsingPoint(theXCoordinate, theYCoordinate, theLevel);
                else
                    error('Invalid number of parameters.');
                end
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aIndex=findPolygonIndex(obj,thePolygon)
            %findPolygonIndex   Search for a polygon index
            %   index=Project.findPolygonIndex(Polygon) will search for the
            %   index of a polygon in the array of polygons. If the polygon
            %   is not found in the polygon array then [] is returned.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Find the index of a particular polygon
            %       index=Project.findPolygonIndex(polygon);
            %
            % See also SonnetProject.scalePolygon
            
            if obj.isGeometryProject
                aIndex=obj.GeometryBlock.findPolygonIndex(thePolygon);
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [aIndex, aPolygon]=findPolygonUsingId(obj,theId)
            %findPolygonUsingId   Search for a polygon using its ID
            %   [index polygon]=Project.findPolygonUsingId(Id) accepts
            %   the Debug ID for a polygon and returns the polygon's
            %   index in the array of polygons and a reference to the
            %   polygon. If the supplied polygon is not in the array
            %   then [] is returned.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Find the polygon's index and obtain a reference to it
            %       [polygonIndex,polygonObject]=Project.findPolygonUsingId(12);
            %
            % See also SonnetProject.findPolygonIndex
            
            if obj.isGeometryProject
                [aIndex, aPolygon]=obj.GeometryBlock.findPolygonUsingId(theId);
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [aArrayOfIdValues, aArrayOfReferences]=getAllPolygonIds(obj)
            %getAllPolygonIds   Generates vectors of IDs and references
            %   [IDs Polygons]=Project.getAllPolygonIds() will return a vector of all of the
            %   polygon ID's in a project and a cell array of a reference
            %   to each polygon such that IDs(n) is the ID for Polygons(n).
            %
            %   Note: This method is only for geometry projects.
            %
            % See also SonnetProject.findPolygonIndex
            if obj.isGeometryProject
                [aArrayOfIdValues, aArrayOfReferences]=obj.GeometryBlock.getAllPolygonIds();
            else
                error('This method is only available for Geometry projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [aCentroidX, aCentroidY, aLayer, aSize, thePolygon]=getAllPolygonCentroids(obj)
            %getAllPolygonCentroids   Generates vectors for centroids and references
            %   [X Y Layers Sizes Polygons]=Project.getAllPolygonCentroids() will
            %   return a vector of all of the centroid X coordinates, the
            %   centroid Y coordinates, the layers, the sizes and polygon
            %   handles for all the polygons in a project.
            %
            %   Note: This method is only for geometry projects.
            %
            % See also SonnetProject.findPolygonIndex
            if obj.isGeometryProject
                [aCentroidX, aCentroidY, aLayer, aSize, thePolygon]=obj.GeometryBlock.getAllPolygonCentroids();
            else
                error('This method is only available for Geometry projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [aMeanX, aMeanY, aLayer, aSize, aPolygons]=getAllPolygonMeans(obj)
            %getAllPolygonMeans   Generates vectors for means and references
            %   [X Y Layers Sizes Polygons]=Project.getAllPolygonMeans() will
            %   return a vector of all of the mean X coordinates, the
            %   mean Y coordinates, the layers, the sizes and polygon
            %   handles for all the polygons in a project.
            %
            %   Note: This method is only for geometry projects.
            %
            % See also SonnetProject.findPolygonIndex
            if obj.isGeometryProject
                [aMeanX, aMeanY, aLayer, aSize, aPolygons]=obj.GeometryBlock.getAllPolygonMeans();
            else
                error('This method is only available for Geometry projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [aXCoordinateValues, aYCoordinateValues, thePolygon]=getAllPolygonPoints(obj)
            %getAllPolygonIds   Generates vectors for coordinates and references
            %   [X Y Layers Sizes Polygons]=Project.getAllPolygonPoints() will
            %   return arrays of all of the polygon X coordinates and
            %   the polygon Y coordinates.
            %
            %   Note: This method is only for geometry projects.
            %
            % See also SonnetProject.findPolygonIndex
            if obj.isGeometryProject
                [aXCoordinateValues, aYCoordinateValues, thePolygon]=obj.GeometryBlock.getAllPolygonPoints();
            else
                error('This method is only available for Geometry projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Polygon Modification Methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function movePolygon(obj,thePolygon, theNewXCoordinate, theNewYCoordinate)
            %movePolygon   Moves a polygon to a new X and Y location
            %   Project.movePolygon(polygon,X,Y) will move a polygon such that its centroid
            %   will be at the desired location.
            %
            %   Project.movePolygon(polygon,X,Y) will move the passed
            %   polygon such that its centroid will be at the desired location.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Move a particular polygon such that
            %       % its centroid is at location (0,0)
            %       Project.movePolygon(polygon,0,0);
            %
            %       % Move the polygon with debug ID 12
            %       % such that its centroid is at location (0,0)
            %       Project.movePolygon(12,0,0);
            %
            % See also SonnetProject.movePolygonExact, SonnetProject.movePolygonRelative
            
            if obj.isGeometryProject
                obj.GeometryBlock.movePolygon(thePolygon, theNewXCoordinate, theNewYCoordinate);
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function movePolygonUsingId(obj,thePolygon, theNewXCoordinate, theNewYCoordinate)
            %movePolygon   Moves a polygon to a new X and Y location
            %   Project.movePolygonUsingId(ID,X,Y) will move the polygon specified
            %   by the passed ID value such that its centroid will be at the
            %   desired location.
            %
            %   Project.movePolygonUsingId(polygon,X,Y) will move the passed
            %   polygon such that its centroid will be at the desired location.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Move the polygon with debug ID 12
            %       % such that its centroid is at location (0,0)
            %       Project.movePolygonUsingId(12,0,0);
            %
            %       % Move a particular polygon such that
            %       % its centroid is at location (0,0)
            %       Project.movePolygonUsingId(polygon,0,0);
            %
            % See also SonnetProject.movePolygonExact, SonnetProject.movePolygonRelative
            
            if obj.isGeometryProject
                obj.GeometryBlock.movePolygon(thePolygon, theNewXCoordinate, theNewYCoordinate);
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function movePolygonUsingIndex(obj,thePolygon, theNewXCoordinate, theNewYCoordinate)
            %movePolygon   Moves a polygon to a new X and Y location
            %   Project.movePolygonUsingIndex(N,X,Y) will move the Nth polygon
            %   in the array of polygons such that its centroid will be at
            %   the desired location.
            %
            %   Project.movePolygonUsingIndex(polygon,X,Y) will move the passed
            %   polygon such that its centroid will be at the desired location.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Move a particular polygon such that
            %       % its centroid is at location (0,0)
            %       Project.movePolygonUsingIndex(polygon,0,0);
            %
            %       % Move the polygon with index 3
            %       % such that its centroid is at location (0,0)
            %       Project.movePolygonUsingIndex(3,0,0);
            %
            % See also SonnetProject.movePolygonExact, SonnetProject.movePolygonRelative
            
            if obj.isGeometryProject
                obj.GeometryBlock.movePolygonUsingIndex(thePolygon, theNewXCoordinate, theNewYCoordinate);
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function movePolygonExact(obj,thePolygon, theNewXCoordinate, theNewYCoordinate)
            %movePolygonExact   Moves a polygon to a new X and Y location
            %   Project.movePolygonExact(Polygon,X,Y) will move
            %   a polygon such that its centroid will be at the
            %   desired location.
            %
            %   Project.movePolygonExact(ID,X,Y) will move a
            %   polygon such that its centroid will be at the
            %   desired location.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Move a particular polygon such that
            %       % its centroid is at location (0,0)
            %       Project.movePolygonExact(polygon,0,0);
            %
            %       % Move the polygon with debug ID 12
            %       % such that its centroid is at location (0,0)
            %       Project.movePolygonExact(12,0,0);
            %
            % See also SonnetProject.movePolygon, SonnetProject.movePolygonRelative
            
            if obj.isGeometryProject
                obj.GeometryBlock.movePolygonExact(thePolygon, theNewXCoordinate, theNewYCoordinate);
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function movePolygonExactUsingId(obj,thePolygon, theNewXCoordinate, theNewYCoordinate)
            %movePolygonExactUsingId   Moves a polygon to a new X and Y location
            %   Project.movePolygonExactUsingId(ID,X,Y) will move a
            %   polygon such that its centroid will be at the
            %   desired location.
            %
            %   Project.movePolygonExactUsingId(Polygon,X,Y) will move
            %   the passed polygon such that its centroid will be at
            %   the desired location.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Move the polygon with debug ID 12
            %       % such that its centroid is at location (0,0)
            %       Project.movePolygonExactUsingId(12,0,0);
            %
            %       % Move a particular polygon such that
            %       % its centroid is at location (0,0)
            %       Project.movePolygonExactUsingId(polygon,0,0);
            %
            % See also SonnetProject.movePolygon, SonnetProject.movePolygonRelative
            
            if obj.isGeometryProject
                obj.GeometryBlock.movePolygonExact(thePolygon, theNewXCoordinate, theNewYCoordinate);
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function movePolygonExactUsingIndex(obj,thePolygon, theNewXCoordinate, theNewYCoordinate)
            %movePolygonExactUsingIndex   Moves a polygon to a new X and Y location
            %   Project.movePolygonExactUsingIndex(N,X,Y) will move
            %   the Nth polygon in the array of polygons such that
            %   its centroid will be at the desired location.
            %
            %   Project.movePolygonExactUsingIndex(Polygon,X,Y) will move
            %   the passed polygon such that its centroid will be at
            %   the desired location.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Move a particular polygon such that
            %       % its centroid is at location (0,0)
            %       Project.movePolygonExactUsingIndex(polygon,0,0);
            %
            %       % Move the polygon with debug ID 12
            %       % such that its centroid is at location (0,0)
            %       Project.movePolygonExactUsingIndex(12,0,0);
            %
            % See also SonnetProject.movePolygon, SonnetProject.movePolygonRelative
            
            if obj.isGeometryProject
                obj.GeometryBlock.movePolygonExactUsingIndex(thePolygon, theNewXCoordinate, theNewYCoordinate);
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function movePolygonRelative(obj,thePolygon, theXChange, theYChange)
            %movePolygonRelative   Moves a polygon by a particular amount
            %   Project.movePolygonRelative(Polygon,X,Y) will move a
            %   polygon such that its centroid X value will be moved
            %   by the specified distance for the X direction and
            %   the centroid Y value will be moved by the specified
            %   distance in the Y direction.
            %
            %   Project.movePolygonRelative(ID,X,Y) will move the polygon
            %   with the passed ID such that its centroid X value will be
            %   moved by the specified distance for the X direction
            %   and the centroid Y value will be moved by the specified
            %   distance in the Y direction.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Move a particular polygon such that
            %       % its centroid is at location (0,0)
            %       Project.movePolygonRelative(polygon,0,0);
            %
            %       % Move the polygon with debugID 12
            %       % such that its centroid is at location (0,0)
            %       Project.movePolygonRelative(12,0,0);
            %
            % See also SonnetProject.movePolygon, SonnetProject.movePolygonExact
            
            if obj.isGeometryProject
                obj.GeometryBlock.movePolygonRelative(thePolygon, theXChange, theYChange);
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function movePolygonRelativeUsingId(obj,thePolygon, theXChange, theYChange)
            %movePolygonRelativeUsingId   Moves a polygon by a particular amount
            %   Project.movePolygonRelativeUsingId(ID,X,Y) will move the polygon
            %   with the passed ID such that its centroid X value will be
            %   moved by the specified distance for the X direction
            %   and the centroid Y value will be moved by the specified
            %   distance in the Y direction.
            %
            %   Project.movePolygonRelativeUsingId(Polygon,X,Y) will move a
            %   polygon such that its centroid X value will be moved
            %   by the specified distance for the X direction and
            %   the centroid Y value will be moved by the specified
            %   distance in the Y direction.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Move the polygon with debugID 12
            %       % such that its centroid is at location (0,0)
            %       Project.movePolygonRelative(12,0,0);
            %
            %       % Move a particular polygon such that
            %       % its centroid is at location (0,0)
            %       Project.movePolygonRelative(polygon,0,0);
            %
            % See also SonnetProject.movePolygon, SonnetProject.movePolygonExact
            
            if obj.isGeometryProject
                obj.GeometryBlock.movePolygonRelative(thePolygon, theXChange, theYChange);
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function movePolygonRelativeUsingIndex(obj,thePolygon, theXChange, theYChange)
            %movePolygonRelativeUsingIndex   Moves a polygon by a particular amount
            %   Project.movePolygonRelativeUsingId(N,X,Y) will move the Nth polygon
            %   in the array of polygons such that its centroid X value will be
            %   moved by the specified distance for the X direction
            %   and the centroid Y value will be moved by the specified
            %   distance in the Y direction.
            %
            %   Project.movePolygonRelativeUsingId(Polygon,X,Y) will move a
            %   polygon such that its centroid X value will be moved
            %   by the specified distance for the X direction and
            %   the centroid Y value will be moved by the specified
            %   distance in the Y direction.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Move a particular polygon such that
            %       % its centroid is at location (0,0)
            %       Project.movePolygonRelativeUsingIndex(polygon,0,0);
            %
            %       % Move the polygon with debugID 12
            %       % such that its centroid is at location (0,0)
            %       Project.movePolygonRelativeUsingIndex(12,0,0);
            %
            % See also SonnetProject.movePolygon, SonnetProject.movePolygonExact
            
            if obj.isGeometryProject
                obj.GeometryBlock.movePolygonRelativeUsingIndex(thePolygon, theXChange, theYChange);
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function scalePolygon(obj,thePolygon, theXChangeFactor, theYChangeFactor)
            %scalePolygon   Expands polygons
            %   Project.scalePolygon(Polygon,XChange,YChange) will
            %   increase the size of a polygon by multiplying all of its coordinates
            %   by the specified X change factor and Y change factor. The polygon
            %   is scaled from its centroid so the polygon's position does not change.
            %
            %   Project.scalePolygon(ID,XChange,YChange) will increase
            %   the size of the polygon with the passed ID by multiplying all of
            %   its coordinates  by the specified X change factor and Y change factor.
            %   The polygon is scaled from its centroid so the polygon's position does
            %   not change.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Scale a particular polygon such that
            %       % it is twice as large in the X and Y directions
            %       Project.scalePolygon(polygon,2,2);
            %
            %       % Scale a particular polygon such that
            %       % it is twice as large in the X and Y directions
            %       Project.scalePolygon(12,2,2);
            %
            % See also SonnetProject.scalePolygonFromPoint
            
            if obj.isGeometryProject
                obj.GeometryBlock.scalePolygon(thePolygon, theXChangeFactor, theYChangeFactor);
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function scalePolygonUsingId(obj,thePolygon, theXChangeFactor, theYChangeFactor)
            %scalePolygonUsingId   Expands polygons
            %   Project.scalePolygonUsingId(ID,XChange,YChange) will increase
            %   the size of the polygon with the passed ID by multiplying all of
            %   its coordinates  by the specified X change factor and Y change factor.
            %   The polygon is scaled from its centroid so the polygon's position does
            %   not change.
            %
            %   Project.scalePolygonUsingId(Polygon,XChange,YChange) will
            %   increase the size of a polygon by multiplying all of its coordinates
            %   by the specified X change factor and Y change factor. The polygon
            %   is scaled from its centroid so the polygon's position does not change.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Scale a particular polygon such that
            %       % it is twice as large in the X and Y directions
            %       Project.scalePolygonUsingId(12,2,2);
            %
            %       % Scale a particular polygon such that
            %       % it is twice as large in the X and Y directions
            %       Project.scalePolygonUsingId(polygon,2,2);
            %
            % See also SonnetProject.scalePolygonFromPoint
            
            if obj.isGeometryProject
                obj.GeometryBlock.scalePolygon(thePolygon, theXChangeFactor, theYChangeFactor);
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function scalePolygonUsingIndex(obj,thePolygon, theXChangeFactor, theYChangeFactor)
            %scalePolygonUsingIndex   Expands polygons
            %   Project.scalePolygonUsingIndex(N,XChange,YChange) will increase
            %   the size of the Nth polygon in the array of polygons by multiplying all of
            %   its coordinates  by the specified X change factor and Y change factor.
            %   The polygon is scaled from its centroid so the polygon's position does
            %   not change.
            %
            %   Project.scalePolygonUsingIndex(Polygon,XChange,YChange) will
            %   increase the size of a polygon by multiplying all of its coordinates
            %   by the specified X change factor and Y change factor. The polygon
            %   is scaled from its centroid so the polygon's position does not change.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Scale a particular polygon such that
            %       % it is twice as large in the X and Y directions
            %       Project.scalePolygonUsingIndex(polygon,2,2);
            %
            %       % Scale a particular polygon such that
            %       % it is twice as large in the X and Y directions
            %       Project.scalePolygonUsingIndex(12,2,2);
            %
            % See also SonnetProject.scalePolygonFromPoint
            
            if obj.isGeometryProject
                obj.GeometryBlock.scalePolygonUsingIndex(thePolygon, theXChangeFactor, theYChangeFactor);
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function scalePolygonFromPoint(obj, thePolygon,  theXChangeFactor, theYChangeFactor, thePointX, thePointY)
            %scalePolygonFromPoint   Expands polygons
            %   scalePolygonFromPoint(Polygon,X,Y) will increase the size
            %   of a polygon by scaling the polygon by factors in the X and Y
            %   directions with respect to the centroid. This provides the
            %   same functionality as scalePolygon().
            %
            %   scalePolygonFromPoint(Polygon,X,Y,PX,PY) will increase the size
            %   of a polygon by scaling the polygon by factors in the X and Y
            %   directions with respect to the coordinate location (PX,PY).
            %
            %   scalePolygonFromPoint(ID,X,Y) will increase the size
            %   of a polygon by scaling the polygon by factors in the X and Y
            %   directions with respect to the centroid. This provides the
            %   same functionality as scalePolygon().
            %
            %   scalePolygonFromPoint(ID,X,Y,PX,PY) will increase the size
            %   of a polygon by scaling the polygon by factors in the X and Y
            %   directions with respect to the coordinate location (PX,PY).
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Scale a particular polygon such that
            %       % it is twice as large in the X and Y directions
            %       % with respect to the point (0,0)
            %       Project.scalePolygonFromPoint(polygon,2,2,0,0);
            %
            %       % Scale a particular polygon such that
            %       % it is twice as large in the X and Y directions
            %       % with respect to the point (0,0)
            %       Project.scalePolygonFromPoint(12,2,2,0,0);
            %
            % See also SonnetProject.scalePolygon
            
            if obj.isGeometryProject
                if nargin == 6
                    obj.GeometryBlock.scalePolygonFromPoint(thePolygon,  theXChangeFactor, theYChangeFactor, thePointX, thePointY);
                elseif nargin == 4
                    obj.GeometryBlock.scalePolygonFromPoint(thePolygon,  theXChangeFactor, theYChangeFactor);
                elseif nargin == 2
                    obj.GeometryBlock.scalePolygonFromPoint(thePolygon);
                end
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function scalePolygonFromPointUsingId(obj, thePolygon,  theXChangeFactor, theYChangeFactor, thePointX, thePointY)
            %scalePolygonFromPointUsingId   Expands polygons
            %   scalePolygonFromPointUsingId(ID,X,Y) will increase the size
            %   of a polygon by scaling the polygon by factors in the X and Y
            %   directions with respect to the centroid. This provides the
            %   same functionality as scalePolygon().
            %
            %   scalePolygonFromPointUsingId(ID,X,Y,PX,PY) will increase the size
            %   of a polygon by scaling the polygon by factors in the X and Y
            %   directions with respect to the coordinate location (PX,PY).
            %
            %   scalePolygonFromPointUsingId(Polygon,X,Y) will increase the size
            %   of a polygon by scaling the polygon by factors in the X and Y
            %   directions with respect to the centroid. This provides the
            %   same functionality as scalePolygon().
            %
            %   scalePolygonFromPointUsingId(Polygon,X,Y,PX,PY) will increase the size
            %   of a polygon by scaling the polygon by factors in the X and Y
            %   directions with respect to the coordinate location (PX,PY).
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Scale a particular polygon such that
            %       % it is twice as large in the X and Y directions
            %       % with respect to the point (0,0)
            %       Project.scalePolygonFromPointUsingId(polygon,2,2,0,0);
            %
            %       % Scale a particular polygon such that
            %       % it is twice as large in the X and Y directions
            %       % with respect to the point (0,0)
            %       Project.scalePolygonFromPointUsingId(12,2,2,0,0);
            %
            % See also SonnetProject.scalePolygon
            
            if obj.isGeometryProject
                if nargin == 6
                    obj.GeometryBlock.scalePolygonFromPoint(thePolygon,  theXChangeFactor, theYChangeFactor, thePointX, thePointY);
                elseif nargin == 4
                    obj.GeometryBlock.scalePolygonFromPoint(thePolygon,  theXChangeFactor, theYChangeFactor);
                elseif nargin == 2
                    obj.GeometryBlock.scalePolygonFromPoint(thePolygon);
                end
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function scalePolygonFromPointUsingIndex(obj, thePolygon,  theXChangeFactor, theYChangeFactor, thePointX, thePointY)
            %scalePolygonFromPointUsingIndex   Expands polygons
            %   scalePolygonFromPointUsingIndex(N,X,Y) will increase the size
            %   of the Nth polygon in the array of polygons by scaling
            %   the polygon by factors in the X and Y directions with
            %   respect to the centroid. This provides the
            %   same functionality as scalePolygon().
            %
            %   scalePolygonFromPointUsingIndex(N,X,Y,PX,PY) will increase the size
            %   of the Nth polygon in the array of polygons by scaling the
            %   polygon by factors in the X and Y directions with respect
            %   to the coordinate location (PX,PY).
            %
            %   scalePolygonFromPointUsingIndex(Polygon,X,Y) will increase the size
            %   of a polygon by scaling the polygon by factors in the X and Y
            %   directions with respect to the centroid. This provides the
            %   same functionality as scalePolygon().
            %
            %   scalePolygonFromPointUsingIndex(Polygon,X,Y,PX,PY) will increase the size
            %   of a polygon by scaling the polygon by factors in the X and Y
            %   directions with respect to the coordinate location (PX,PY).
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Scale a particular polygon such that
            %       % it is twice as large in the X and Y directions
            %       % with respect to the point (0,0)
            %       Project.scalePolygonFromPointUsingIndex(polygon,2,2,0,0);
            %
            %       % Scale a particular polygon such that
            %       % it is twice as large in the X and Y directions
            %       % with respect to the point (0,0)
            %       Project.scalePolygonFromPointUsingIndex(12,2,2,0,0);
            %
            % See also SonnetProject.scalePolygon
            
            if obj.isGeometryProject
                if nargin == 6
                    obj.GeometryBlock.scalePolygonFromPointUsingIndex(thePolygon,  theXChangeFactor, theYChangeFactor, thePointX, thePointY);
                elseif nargin == 4
                    obj.GeometryBlock.scalePolygonFromPointUsingIndex(thePolygon,  theXChangeFactor, theYChangeFactor);
                elseif nargin == 2
                    obj.GeometryBlock.scalePolygonFromPointUsingIndex(thePolygon);
                end
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function flipPolygonX(obj,thePolygonOrId)
            %flipPolygonX   Flips a polygon about its center X axis
            %   Project.flipPolygonX(Polygon) will flip
            %   the passed polygon over its X axis.
            %
            %   Project.flipPolygonX(ID) will flip the polygon
            %   which has the passed ID over its X axis.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Flip the first polygon in the
            %       % array of polygons.
            %       aPolygon=Project.GeometryBlock.ArrayOfPolygons{1};
            %       Project.flipPolygonX(aPolygon)
            
            if obj.isGeometryProject
                obj.GeometryBlock.flipPolygonXUsingId(thePolygonOrId);
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function flipPolygonY(obj,thePolygonOrId)
            %flipPolygonY   Flips a polygon about its center Y axis
            %   Project.flipPolygonY(Polygon) will flip
            %   the passed polygon over its Y axis.
            %
            %   Project.flipPolygonY(ID) will flip the polygon
            %   which has the passed ID over its Y axis.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Flip the first polygon in the
            %       % array of polygons.
            %       aPolygon=Project.GeometryBlock.ArrayOfPolygons{1};
            %       Project.flipPolygonY(aPolygon)
            
            if obj.isGeometryProject
                obj.GeometryBlock.flipPolygonYUsingId(thePolygonOrId);
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function flipPolygonXUsingId(obj,thePolygonOrId)
            %flipPolygonXUsingId   Flips a polygon about its center X axis
            %   Project.flipPolygonXUsingId(ID) will flip the
            %   polygon which has the passed ID over its X axis.
            %
            %   Project.flipPolygonXUsingId(Polygon) will
            %   flip the passed polygon over its X axis.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Flip the first polygon in the
            %       % array of polygons.
            %       aId=Project.GeometryBlock.ArrayOfPolygons{1}.DebugId;
            %       Project.flipPolygonXUsingId(aId)
            
            if obj.isGeometryProject
                obj.GeometryBlock.flipPolygonXUsingId(thePolygonOrId);
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function flipPolygonYUsingId(obj,thePolygonOrId)
            %flipPolygonY   Flips a polygon about its center Y axis
            %   Project.flipPolygonYUsingId(ID) will flip the
            %   polygon which has the passed ID over its Y axis.
            %
            %   Project.flipPolygonYUsingId(Polygon) will
            %   flip the passed polygon over its Y axis.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Flip the first polygon in the
            %       % array of polygons.
            %       aId=Project.GeometryBlock.ArrayOfPolygons{1}.DebugId;
            %       Project.flipPolygonY(aId)
            
            if obj.isGeometryProject
                obj.GeometryBlock.flipPolygonYUsingId(thePolygonOrId);
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function flipPolygonXUsingIndex(obj,thePolygonOrIndex)
            %flipPolygonXUsingIndex   Flips a polygon about its center X axis
            %   Project.flipPolygonXUsingId(N) will flip the Nth
            %   polygon in the array of polygons over its X axis.
            %
            %   Project.flipPolygonXUsingId(Polygon) will
            %   flip the passed polygon over its X axis.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Flip the first polygon in the
            %       % array of polygons.
            %       Project.flipPolygonX(1)
            
            if obj.isGeometryProject
                obj.GeometryBlock.flipPolygonXUsingIndex(thePolygonOrIndex);
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function flipPolygonYUsingIndex(obj,thePolygonOrIndex)
            %flipPolygonYUsingIndex   Flips a polygon about its center Y axis
            %   Project.flipPolygonYUsingId(N) will flip the Nth
            %   polygon in the array of polygons over its Y axis.
            %
            %   Project.flipPolygonYUsingId(Polygon) will
            %   flip the passed polygon over its Y axis.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Flip the first polygon in the
            %       % array of polygons.
            %       Project.flipPolygonY(1)
            
            if obj.isGeometryProject
                obj.GeometryBlock.flipPolygonYUsingIndex(thePolygonOrIndex);
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function snapPolygonsToGrid(obj,theAxis)
            %snapPolygonsToGrid   Snaps polygons to the grid
            %   Project.snapPolygonsToGrid() will snap all the
            %   polygons in a project to the grid in both the
            %   X and Y directions.
            %
            %   Project.snapPolygonsToGrid(axis) will snap all
            %   polygons to the grid in the direction(s) specified
            %   by axis. snapPolygonsToGrid(axis) will call the
            %   appropriate snap method to either snap to the X
            %   axis, the Y axis or both.
            %
            %   The user can specify the axis with one of the following strings:
            %           'x'  or 'X'  for the X direction
            %           'Y'  or 'Y'  for the X direction
            %           'xy' or 'XY' for the X and Y directions
            %
            %           If an invalid axis string is supplied an 'XY' snap will be performed.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Snap polygons in the X direction
            %       Project.snapPolygonsToGrid('x');
            %
            %       % Snap polygons in the X and Y directions
            %       Project.snapPolygonsToGrid();
            %           % or
            %       Project.snapPolygonsToGrid('XY');
            
            if obj.isGeometryProject
                if nargin == 2
                    obj.GeometryBlock.snapPolygonsToGrid(theAxis);
                else
                    obj.GeometryBlock.snapPolygonsToGrid();
                end
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changePolygonType(obj,theId,theType)
            %changePolygonType   Change the composition of a polygon
            %   Project.changePolygonType(ID,Type) will try to change the
            %   composition of the polygon with the debugID of ID to the
            %   passed type. If the polygon is a metal or via polygon then
            %   Type must be the name of a metal type in the project. If
            %   the polygon is a dielectric brick then Type must be the
            %   name of one of the brick types in the project.
            %
            %   Project.changePolygonType(Polygon,Type) will try to change the
            %   composition of the passed polygon to the passed type.
            %   If the polygon is a metal or via polygon then Type
            %   must be the name of a metal type in the project. If
            %   the polygon is a dielectric brick then Type must be the
            %   name of one of the brick types in the project.
            %
            %   Note: This method is only for geometry projects.
            %   Note: Sonnet version 12 projects have a shared metal type for planar
            %         and via polygons. Sonnet version 13 projects have separate
            %         metal types for planar polygons and via polygons.
            %
            %   Example usage:
            %
            %       % Change the polygon with debug ID 12 to 'ThinCopper'
            %       % (A metal type called 'ThinCopper' must already be
            %       % defined in the project).
            %       Project.changePolygonType(12,'ThinCopper');
            %
            %       % Change the polygon with debug ID 12 to 'Lossless'
            %       % (Lossless is the default type for metal polygons).
            %       Project.changePolygonType(12,'Lossless');
            %
            % See also SonnetProject.changePolygonTypeUsingId,
            %          SonnetProject.changePolygonTypeUsingIndex
            
            % Find the version number
            if (~isempty(obj.VersionOfSonnet))
                if isa(obj.VersionOfSonnet,'char')
                    aVersion=sscanf(obj.VersionOfSonnet,'%d'); % Extract the first two digits of the version number
                else
                    aVersion=obj.VersionOfSonnet;
                end
            end
            
            if obj.isGeometryProject
                obj.GeometryBlock.changePolygonTypeUsingId(aVersion,theId,theType);
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changePolygonTypeUsingIndex(obj,theIndex,theType)
            %changePolygonTypeUsingIndex   Change the composition of a polygon
            %   Project.changePolygonType(N,Type) will try to change the
            %   composition of the Nth polygon in the array of polygons to the
            %   passed type. If the polygon is a metal or via polygon then
            %   Type must be the name of a metal type in the project. If
            %   the polygon is a dielectric brick then Type must be the
            %   name of one of the brick types in the project.
            %
            %   Project.changePolygonTypeUsingIndex(Polygon,Type) will try
            %   to change the composition of the passed polygon to the
            %   passed type. If the polygon is a metal or via polygon
            %   then Type must be the name of a metal type in the
            %   project. If the polygon is a dielectric brick then
            %   Type must be the name of one of the brick types
            %   in the project.
            %
            %   Note: This method is only for geometry projects.
            %   Note: Sonnet version 12 projects have a shared metal type for planar
            %         and via polygons. Sonnet version 13 projects have separate
            %         metal types for planar polygons and via polygons.
            %
            %   Example usage:
            %
            %       % Change first polygon in the array of polygons to
            %       % 'ThinCopper' (A metal type called 'ThinCopper'
            %       % must already be defined in the project).
            %       Project.changePolygonTypeUsingIndex(1,'ThinCopper');
            %
            %       % Change first polygon in the array of polygons to
            %       % 'Lossless' (Lossless is the default type for
            %       %  metal polygons).
            %       Project.changePolygonTypeUsingIndex(1,'Lossless');
            %
            % See also SonnetProject.changePolygonType,
            %          SonnetProject.changePolygonTypeUsingIndex
            
            % Find the version number
            if (~isempty(obj.VersionOfSonnet))
                if isa(obj.VersionOfSonnet,'char')
                    aVersion=sscanf(obj.VersionOfSonnet,'%d'); % Extract the first two digits of the version number
                else
                    aVersion=obj.VersionOfSonnet;
                end
            end
            
            if obj.isGeometryProject
                obj.GeometryBlock.changePolygonTypeUsingIndex(aVersion,theIndex,theType);
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changePolygonTypeUsingId(obj,theId,theType)
            %changePolygonTypeUsingId   Change the composition of a polygon
            %   Project.changePolygonType(ID,Type) will try to change the
            %   composition of the polygon with the debugID of ID to the
            %   passed type. If the polygon is a metal or via polygon then
            %   Type must be the name of a metal type in the project. If
            %   the polygon is a dielectric brick then Type must be the
            %   name of one of the brick types in the project.
            %
            %   Project.changePolygonTypeUsingId(Polygon,Type) will try
            %   to change the composition of the passed polygon to the
            %   passed type. If the polygon is a metal or via polygon
            %   then Type must be the name of a metal type in the
            %   project. If the polygon is a dielectric brick then
            %   Type must be the name of one of the brick types
            %   in the project.
            %
            %   Note: This method is only for geometry projects.
            %   Note: Sonnet version 12 projects have a shared metal type for planar
            %         and via polygons. Sonnet version 13 projects have separate
            %         metal types for planar polygons and via polygons.
            %
            %   Example usage:
            %
            %       % Change the polygon with debug ID 12 to 'ThinCopper'
            %       % (A metal type called 'ThinCopper' must already be
            %       % defined in the project).
            %       Project.changePolygonTypeUsingId(12,'ThinCopper');
            %
            %       % Change the polygon with debug ID 12 to 'Lossless'
            %       % (Lossless is the default type for metal polygons).
            %       Project.changePolygonTypeUsingId(12,'Lossless');
            %
            % See also SonnetProject.changePolygonType,
            %          SonnetProject.changePolygonTypeUsingId
            
            % Find the version number
            if (~isempty(obj.VersionOfSonnet))
                if isa(obj.VersionOfSonnet,'char')
                    aVersion=sscanf(obj.VersionOfSonnet,'%d'); % Extract the first two digits of the version number
                else
                    aVersion=obj.VersionOfSonnet;
                end
            end
            
            if obj.isGeometryProject
                obj.GeometryBlock.changePolygonTypeUsingId(aVersion,theId,theType);
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function assignUniqueDebugId(obj,aPolygon)
            %assignUniqueDebugId   Assign a polygon an unique debugId.
            %   Project.assignUniqueDebugId(aPolygon) will assign the
            %   passed polygon a unique debugId. The passed polygon
            %   does not necessarily need to be from same project.
            %
            %   Note: This method is only for geometry projects.
            %
            % See also SonnetProject.assignAllPolygonssequentialIds,
            %          SonnetProject.generateUniqueId
            aPolygon.DebugId=obj.generateUniqueId();
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function assignAllPolygonsSequentialIds(obj)
            %assignAllPolygonssequentialIds  Makes sure polygons have unique IDs
            %   Project.assignAllPolygonssequentialIds() will make sure all the
            %   polygons in a project have unique debugIds by making their
            %   debugIds be their index in the array of polygons. The
            %   debugIds of all the polygons in the project may be changed.
            %
            %   Note: This method is only for geometry projects.
            %
            % See also SonnetProject.assignUniqueDebugId,
            %          SonnetProject.generateUniqueId
            
            obj.GeometryBlock.assignAllPolygonsSequentialIds();
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aDebugId=generateUniqueId(obj)
            %generateUniqueId   Generate a unique debugId
            %   Id=Project.generateUniqueId() will very quickly find a
            %   debugId that is not being used by any other
            %   polygons in the project. Values are not sequential
            %   but are found quickly even with a large number
            %   of polygons.
            %
            %   If the project has no polygons a debugId of one
            %   is always returned.
            %
            %   This method is useful when manually creating polygons
            %   or when wanting to make sure that cloned polygons
            %   have unique debugId values.
            %
            %   Note: This method is only for geometry projects.
            %
            % See also SonnetProject.assignUniqueDebugId,
            %          SonnetProject.generateUniqueId
            
            aDebugId=obj.GeometryBlock.generateUniqueId();
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aCounter=polygonCount(obj)
            %polygonCount   Counts project's polygons
            %   n=Project.polygonCount()  Will return the number of
            %   polygons in the project.
            %
            %   This operation can also be achieved with
            %       length(Project.GeometryBlock.ArrayOfPolygons)
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Get the number of polygons
            %       n=Project.polygonCount();
            
            
            if obj.isGeometryProject
                aCounter=length(obj.GeometryBlock.ArrayOfPolygons);
            else
                error('This method is only available for Geometry projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Polygon Removal Methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [theArrayOfPolygonPairs, theArrayOfPolygonIndexPairs, iNumberOfMatches]=...
                findDuplicatePolygons(obj)
            %findDuplicatePolygons   Finds duplicate polygons
            %   [Polygons Indices NumberOfMatches]=Project.findDuplicatePolygons() searches
            %   for duplicate polygons in the project. The polygon references to the
            %   duplicates are returned along with their indices.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       [Polygons PolygonIndex NumberOfMatches]=Project.findDuplicatePolygons();
            %
            % See also SonnetProject.deleteDuplicatePolygons
            
            if obj.isGeometryProject
                [theArrayOfPolygonPairs, theArrayOfPolygonIndexPairs, iNumberOfMatches]=obj.GeometryBlock.findDuplicatePolygons();
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function deleteDuplicatePolygons(obj)
            %deleteDuplicatePolygons   Deletes duplicate polygons
            %   Project.deleteDuplicatePolygons() will search for duplicate polygons in the
            %   project and delete one of the duplicate occurrences such
            %   that there will no longer be a pair of duplicate polygons.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       Project.deleteDuplicatePolygons();
            %
            % See also SonnetProject.findDuplicatePolygons
            
            if obj.isGeometryProject
                obj.GeometryBlock.deleteDuplicatePolygons();
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function deleteDuplicatePoints(obj)
            %deleteDuplicatePoints   Deletes duplicate polygon points
            %   Project.deleteDuplicatePoints() will remove any
            %   duplicate points for all polygons in the project.
            %
            %   Note: This method is only for geometry projects.
            %
            % See also SonnetProject.deleteDuplicatePolygons
            
            if obj.isGeometryProject
                for iCounter=1:obj.polygonCount()
                    aPolygon=obj.getPolygon(iCounter);
                    aPolygon.removeDuplicatePoints();
                end
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function deletePolygon(obj,theId)
            %deletePolygon   Delete a polygon
            %   Project.deletePolygon(Id) will delete the polygon
            %   with the passed ID from the array of polygons. If any ports,
            %   edge vias or parameters are connected to the polygon then
            %   they will be deleted as well.
            %
            %   Project.deletePolygon(Polygon) will delete the
            %   passed polygon from the array of polygons. If any ports,
            %   edge vias or parameters are connected to the polygon then
            %   they will be deleted as well.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Delete the polygon with debug ID 12
            %       BooleanWasThePolygonDeleted=Project.deletePolygon(12);
            
            obj.deletePolygonUsingId(theId);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function deletePolygonUsingIndex(obj,theIndex)
            %deletePolygonUsingIndex   Deletes a polygon from the project
            %   Project.deletePolygonUsingIndex(N) will delete the Nth polygon
            %   in the array of polygons. If any ports, edge vias or parameters
            %   are connected to the polygon then they will be deleted as well.
            %
            %   Project.deletePolygonUsingIndex(Polygon) will delete the
            %   passed polygon from the array of polygons. If any ports,
            %   edge vias or parameters are connected to the polygon then
            %   they will be deleted as well.
            %
            %   This operation can also be achieved with
            %       Project.GeometryBlock.ArrayOfPolygons(N)=[];
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Delete the 5th polygon in the array of polygons
            %       Project.deletePolygonUsingIndex(5);
            
            if obj.isGeometryProject
                obj.GeometryBlock.deletePolygonUsingIndex(theIndex);
            else
                error('This method is only available for Geometry projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function deletePolygonUsingId(obj,theId)
            %deletePolygonUsingId   Delete a polygon
            %   Project.deletePolygonUsingId(Id) will delete the polygon
            %   with the passed ID from the array of polygons. If any ports,
            %   edge vias or parameters are connected to the polygon then
            %   they will be deleted as well.
            %
            %   Project.deletePolygonUsingId(Polygon) will delete the
            %   passed polygon from the array of polygons. If any ports,
            %   edge vias or parameters are connected to the polygon then
            %   they will be deleted as well.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Delete the polygon with debug ID 12
            %       BooleanWasThePolygonDeleted=Project.deletePolygonUsingId(12);
            
            if obj.isGeometryProject
                obj.GeometryBlock.deletePolygonUsingId(theId);
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Polygon Type Definition Methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function defineNewMetalType(obj,theType,theArgument1,theArgument2,theArgument3,...
                theArgument4,theArgument5,theArgument6,theArgument7,theArgument8)
            %defineNewMetalType   Create a new type of metal
            %   Project.defineNewMetalType(...) will add
            %   a metal type to the project.
            %
            %   There are two ways to use defineNewMetalType. The user
            %   may define a metal type using a set of custom options or
            %   the user may define a type using a predefined property set
            %   from the Sonnet library.
            %
            %   If defineNewMetalType is to import a metal type from the
            %   Sonnet library then the following arguments must be specified
            %     1) The name of the metal
            %     2) The metal's thickness
            %
            %   If defineNewMetalType is to be used to define a custom
            %   metal type then the user must first specify the type of
            %   metal that is being defined and then specify the parameters
            %   for the metal type.
            %
            %   defineNewMetalType requires a type as
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
            %   Then you will need to supply the necessary
            %   arguments for each type as follows:
            %
            %   NOR-Normal Metal
            %     1) The Name of the metal
            %     2) The Conductivity of the metal
            %     3) The Current Ratio of the metal
            %     4) The Thickness of the metal
            %
            %   RES-Resistor Metal
            %     1) The Name of the metal
            %     2) The Resistance of the metal
            %
            %   NAT-Native Metal
            %     1) The Name of the metal
            %     2) The Resistance of the metal
            %     3) The Skin Coefficient of the metal
            %
            %   SUP-General Metal
            %     1) The Name of the metal
            %     2) The Resistance of the metal
            %     3) The Skin Coefficient of the metal
            %     4) The Reactance of the metal
            %     5) The Kinetic Inductance of the metal
            %
            %   SEN-Sense Metal
            %     1) The Name of the metal
            %     2) The Reactance of the metal
            %
            %   TMM-Thick Metal
            %     1) The Name of the metal
            %     2) The Conductivity of the metal
            %     3) The Current Ratio of the metal
            %     4) The Thickness of the metal
            %     5) The Number of Sheets of the metal
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
            %
            %   Note: This method is only for geometry projects.
            %   Note: For Sonnet 13 projects planar metal types are
            %         different than via metal types. For information
            %         on how to define via metal types see the help
            %         information for defineNewViaMetalType.
            %
            %   Example usage:
            %
            %       % Import aluminum from the Sonnet metal library
            %       Project.defineNewMetalType('Aluminum',1.4);
            %
            %       % Define a new normal metal type named 'NormalMetal1'
            %       % of conductivity 58000000, current ratio 50 and thickness 50.
            %       Project.defineNewMetalType('NOR','NormalMetal1',58000000,50,50);
            %
            %       % Define a new resistor metal type named 'ResistorMetal1'
            %       % with a resistance of 100.
            %       Project.defineNewMetalType('RES','ResistorMetal1',100);
            %
            %       % Define a new native metal type named 'NativeMetal1'
            %       % with a resistance of 100 and a skin coefficient of 50
            %       Project.defineNewMetalType('NAT','NativeMetal1',100,50);
            %
            %       % Define a new general metal type named 'GeneralMetal1'
            %       % with a resistance of 100, a skin coefficient of 50,
            %       % a reactance of 50 and a kinetic inductance of 50.
            %       Project.defineNewMetalType('SUP','GeneralMetal1',100,50,50,50);
            %
            %       % Define a new sense metal type named 'SenseMetal1'
            %       % with a reactance of 50
            %       Project.defineNewMetalType('SEN','SenseMetal1',50);
            %
            %       % Define a new thick metal type named 'ThickMetal1'
            %       % with a conductivity of 58000000, a current ratio of 50,
            %       % a thickness of 50, and is comprised of 2 sheets.
            %       Project.defineNewMetalType('TMM','ThickMetal1',58000000,50,50,2);
            %
            %       % Define a new rough metal type named 'RoughMetal1'
            %       % modeled as thick metal with a thickness of 5 units,
            %       % a conductivity of 58000000, a current ratio value of
            %       % zero and top/bottom roughness values of 1.1.
            %       Project.defineNewMetalType('RUF','RoughMetal1','thick',5,58000000,0,1.1,1.1);
            %
            %   See also SonnetProject.defineNewNormalMetalType,
            %            SonnetProject.defineNewResistorMetalType,
            %            SonnetProject.defineNewNativeMetalType,
            %            SonnetProject.defineNewGeneralMetalType,
            %            SonnetProject.defineNewSenseMetalType,
            %            SonnetProject.defineNewThickMetalType,
            %            SonnetProject.defineNewRoughMetalType
            
            if obj.isGeometryProject
                if nargin == 10
                    obj.GeometryBlock.addMetalType(theType,theArgument1,theArgument2,theArgument3,theArgument4,theArgument5,theArgument6,theArgument7,theArgument8);
                elseif nargin == 9
                    obj.GeometryBlock.addMetalType(theType,theArgument1,theArgument2,theArgument3,theArgument4,theArgument5,theArgument6,theArgument7);
                elseif nargin == 8
                    obj.GeometryBlock.addMetalType(theType,theArgument1,theArgument2,theArgument3,theArgument4,theArgument5,theArgument6);
                elseif nargin == 7
                    obj.GeometryBlock.addMetalType(theType,theArgument1,theArgument2,theArgument3,theArgument4,theArgument5);
                elseif nargin == 6
                    obj.GeometryBlock.addMetalType(theType,theArgument1,theArgument2,theArgument3,theArgument4);
                elseif nargin == 5
                    obj.GeometryBlock.addMetalType(theType,theArgument1,theArgument2,theArgument3);
                elseif nargin == 4
                    obj.GeometryBlock.addMetalType(theType,theArgument1,theArgument2);
                elseif nargin == 3
                    obj.GeometryBlock.addMetalTypeUsingLibrary(theType,theArgument1);
                end
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function defineNewRoughMetalType(obj,theName,theThicknessType,theThickness,...
                theConductivity,theCurrentRatio,theRoughnessTop,theRoughnessBottom)
            %defineNewRoughMetalType   Defines a new type of metal
            %   Project.defineNewRoughMetalType(...) will add a rough type of
            %   metal to the array of metal types.
            %
            %   defineNewRoughMetalType requires the following arguments:
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
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Define a new rough metal type named 'RoughMetal1'
            %       % modeled as thick metal with a thickness of 5 units,
            %       % a conductivity of 58000000, a current ratio value of
            %       % zero and top/bottom roughness values of 1.1.
            %       Project.defineNewRoughMetalType('RoughMetal1','thick',5,58000000,0,1.1,1.1);
            %
            %   See also SonnetProject.defineNewMetalType
            
            if obj.isGeometryProject
                obj.GeometryBlock.addRoughMetal(theName,theThicknessType,theThickness,...
                    theConductivity,theCurrentRatio,theRoughnessTop,theRoughnessBottom);
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function defineNewNormalMetalType(obj,theName,theConductivity,theCurrentRatio,theThickness)
            %defineNewNormalMetalType   Defines a new type of metal
            %   Project.defineNewNormalMetalType(Name,Conductivity,CurrentRatio,Thickness)
            %   will add a normal type of metal to the array of metals.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Define a new normal metal type named 'Copper'
            %       % of conductivity 58000000, current ratio 0 and thickness 1.4.
            %       Project.defineNewNormalMetalType('Copper',58000000,0,1.4);
            %
            %   See also SonnetProject.defineNewMetalType
            
            if obj.isGeometryProject
                obj.GeometryBlock.addNormalMetal(theName,theConductivity,theCurrentRatio,theThickness);
            else
                error('This method is only available for Geometry projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function defineNewResistorMetalType(obj,theName,theResistance)
            %defineNewResistorMetalType   Defines a new type of metal
            %   Project.defineNewResistorMetalType(Name,Resistance) will
            %   add a resistor type of metal to the array of metals.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Define a new resistor metal type named 'ResistorMetal1'
            %       % with a resistance of 100.
            %       Project.defineNewResistorMetalType('ResistorMetal1',100);
            %
            %   See also SonnetProject.defineNewMetalType
            
            if obj.isGeometryProject
                obj.GeometryBlock.addResistorMetal(theName,theResistance);
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function defineNewNativeMetalType(obj,theName,theResistance,theSkinCoefficient)
            %defineNewNativeMetalType   Defines a new type of metal
            %   Project.defineNewNativeMetalType(Name,Resistance,SkinCoefficient) will
            %   add a native type of metal to the array of metals.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Define a new native metal type named 'NativeMetal1'
            %       % with a resistance of 100 and a skin coefficient of 50
            %       Project.defineNewNativeMetalType('NativeMetal1',100,50);
            %
            %   See also SonnetProject.defineNewMetalType
            
            if obj.isGeometryProject
                obj.GeometryBlock.addNativeMetal(theName,theResistance,theSkinCoefficient);
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function defineNewGeneralMetalType(obj,theName,theResistance,theSkinCoefficient,...
                theReactance,theKineticInductance)
            %defineNewGeneralMetalType   Defines a new type of metal
            %   Project.defineNewGeneralMetalType(Name,Resistance,SkinCoefficient,
            %   Reactance,KineticInductance) will add a general type of
            %   metal to the array of metals.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Define a new general metal type named 'GeneralMetal1'
            %       % with a resistance of 100, a skin coefficient of 50,
            %       % a reactance of 50 and a kinetic inductance of 50.
            %       Project.defineNewGeneralMetalType('GeneralMetal1',100,50,50,50);
            %
            %   See also SonnetProject.defineNewMetalType
            
            if obj.isGeometryProject
                obj.GeometryBlock.addGeneralMetal(theName,theResistance,theSkinCoefficient,theReactance,theKineticInductance);
            else
                error('This method is only available for Geometry projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function defineNewSenseMetalType(obj,theName,theReactance)
            %defineNewSenseMetalType   Defines a new type of metal
            %   Project.defineNewSenseMetalType(Name,Reactance) will
            %   add a Sense type of metal to the array of metals.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Define a new sense metal type named 'SenseMetal1'
            %       % with a reactance of 50
            %       Project.defineNewSenseMetalType('SenseMetal1',50);
            %
            %   See also SonnetProject.defineNewMetalType
            
            if obj.isGeometryProject
                obj.GeometryBlock.addSenseMetal(theName,theReactance);
            else
                error('This method is only available for Geometry projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function defineNewThickMetalType(obj,theName,theConductivity,theCurrentRatio,theThickness,theNumSheets)
            %defineNewThickMetalType   Defines a new type of metal
            %   Project.defineNewThickMetalType(Name,Conductivity,CurrentRatio,
            %   Thickness,NumSheets) will add a Thick Metal type of metal to
            %   the array of metals.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Define a new thick metal type named 'ThickMetal1'
            %       % with a conductivity of 100, a current ratio of 50,
            %       % a thickness of 50, and is comprised of 2 sheets.
            %       Project.defineNewThickMetalType('ThickMetal1',100,50,50,2);
            %
            %   See also SonnetProject.defineNewMetalType
            
            if obj.isGeometryProject
                obj.GeometryBlock.addThickMetal(theName,theConductivity,theCurrentRatio,theThickness,theNumSheets);
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function defineNewViaMetalType(obj,theType,theName,theArgument2,theArgument3,theArgument4)
            %defineNewViaMetalType   Create a new type of via metal
            %   Project.defineNewViaMetalType(...) will add
            %   a via metal type to the project.
            %
            %   There are two ways to use defineNewViaMetalType. The user
            %   may define a metal type using a set of custom options or
            %   the user may define a type using a predefined property set
            %   from the Sonnet library.
            %
            %   If defineNewViaMetalType is to import a metal type from the
            %   Sonnet library then the following arguments must be specified
            %     1) The name of the metal
            %     2) The metal's thickness
            %
            %   If defineNewViaMetalType is to be used to define a custom
            %   metal type then the user must first specify the type of
            %   metal that is being defined and then specify the parameters
            %   for the metal type.
            %
            %   defineNewViaMetalType requires a type as
            %   the first argument which should
            %   be one of the following:
            %
            %       VOL   -   Volume Metal
            %       SFC   -   Surface Metal
            %       ARR   -   Array Metal
            %
            %   Then you will need to supply the necessary
            %   arguments for each type as follows:
            %
            %   VOL - Volume Metal
            %     1) The Name of the metal
            %     2) The Conductivity of the metal (inf for infinite)
            %     3) The Wall thickness (-1 or 'Solid' for solid)
            %
            %   SFC - Surface Metal
            %     1) The Name of the metal
            %     2) The Rdc value
            %     3) The Rrf value
            %     4) The Xdc value
            %
            %   ARR - Array Metal
            %     1) The Name of the metal
            %     2) The Conductivity value
            %     3) The Fill Factor
            %
            %   Note: This method is only for geometry projects.
            %   Note: This method is only for Sonnet version 13 projects.
            %
            %   Example usage:
            %
            %       % Make an aluminum volume metal type with 3.72e7 s/m
            %       % conductivity and a wall thickness of 1.4 mils.
            %       Project.defineNewViaMetalType('VOL','Aluminum',3.72e7,1.4);
            %
            %       % Make an aluminum volume metal type with 3.72e7 s/m
            %       % conductivity with a solid via wall.
            %       Project.defineNewViaMetalType('VOL','Aluminum2',3.72e7,-1);
            %
            %       % Make an aluminum volume metal type with 3.72e7 s/m
            %       % conductivity with a solid via wall.
            %       Project.defineNewVolumeMetalType('Aluminum2',3.72e7,'Solid');
            %
            %       % Define a new array metal type named 'ArrayMetal1'
            %       Project.defineNewViaMetalType('ARR','ArrayMetal1',50,100);
            %
            %       % Define a new surface metal type named 'SurfaceMetal1'
            %       Project.defineNewViaMetalType('SFC','SurfaceMetal1',5,5,5);
            %
            %   See also SonnetProject.defineNewMetalType
            
            % Find the version number
            if (~isempty(obj.VersionOfSonnet))
                if isa(obj.VersionOfSonnet,'char')
                    aVersion=sscanf(obj.VersionOfSonnet,'%d'); % Extract the first two digits of the version number
                else
                    aVersion=obj.VersionOfSonnet;
                end
            end
            
            % If the project is an invalid version (less than 13)
            % then throw and error.
            if floor(aVersion)<13
                error('ERROR: Improper Sonnet Version. Via metals can only be added to Sonnet 13 projects. Sonnet 12 projects use the same metal types for planar and via polygons.');
            end
            
            if obj.isGeometryProject
                if nargin == 6
                    obj.GeometryBlock.defineNewViaMetalType(theType,theName,theArgument2,theArgument3,theArgument4);
                elseif nargin == 5
                    obj.GeometryBlock.defineNewViaMetalType(theType,theName,theArgument2,theArgument3);
                else
                    error('Invalid number of arguments');
                end
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function defineNewSurfaceMetalType(obj,theName,theRdcValue,theRrfValue,theXdcValue)
            %defineNewSurfaceMetalType   Defines a new type of via metal
            %   Project.defineNewSurfaceMetalType(Name,Rdc,Rrf,Xdc) will define
            %   a surface metal type for the project.
            %
            %   Note: This method is only for geometry projects.
            %   Note: This method is only for Sonnet version 13 projects.
            %
            %   Example usage:
            %
            %       % Define a new surface metal type named 'SurfaceMetal1'
            %       Project.defineNewSurfaceMetalType('SurfaceMetal1',5,5,5);
            %
            %   See also SonnetProject.defineNewViaMetalType
            
            % Find the version number
            if (~isempty(obj.VersionOfSonnet))
                if isa(obj.VersionOfSonnet,'char')
                    aVersion=sscanf(obj.VersionOfSonnet,'%d'); % Extract the first two digits of the version number
                else
                    aVersion=obj.VersionOfSonnet;
                end
            end
            
            % If the project is an invalid version (less than 13)
            % then throw and error.
            if floor(aVersion)<13
                error('ERROR: Improper Sonnet Version. Via metals can only be added to Sonnet 13 projects. Sonnet 12 projects use the same metal types for planar and via polygons.');
            end
            
            if obj.isGeometryProject
                obj.GeometryBlock.addSurfaceMetal(theName,theRdcValue,theRrfValue,theXdcValue);
            else
                error('This method is only available for Geometry projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function defineNewVolumeMetalType(obj,theName,theConductivity,theWallThickness)
            %defineNewVolumeMetalType   Defines a new type of via metal
            %   Project.defineNewVolumeMetalType(theName,theConductivity,
            %   theWallThickness) will define a volume metal type for the project.
            %   If the wall should be solid then either pass -1 as the wall thickness
            %   or the string 'Solid' (case insensitive).
            %
            %   Note: This method is only for geometry projects.
            %   Note: This method is only for Sonnet version 13 projects.
            %
            %   Example usage:
            %
            %       % Make an aluminum volume metal type with 3.72e7 s/m
            %       % conductivity and a wall thickness of 1.4 mils.
            %       Project.defineNewVolumeMetalType('Aluminum',3.72e7,1.4);
            %
            %       % Make an aluminum volume metal type with 3.72e7 s/m
            %       % conductivity with a solid via wall.
            %       Project.defineNewVolumeMetalType('Aluminum2',3.72e7,-1);
            %
            %       % Make an aluminum volume metal type with 3.72e7 s/m
            %       % conductivity with a solid via wall.
            %       Project.defineNewVolumeMetalType('Aluminum2',3.72e7,'Solid');
            %
            %   See also SonnetProject.defineNewViaMetalType
            
            % Find the version number
            if (~isempty(obj.VersionOfSonnet))
                if isa(obj.VersionOfSonnet,'char')
                    aVersion=sscanf(obj.VersionOfSonnet,'%d'); % Extract the first two digits of the version number
                else
                    aVersion=obj.VersionOfSonnet;
                end
            end
            
            % If the project is an invalid version (less than 13)
            % then throw and error.
            if floor(aVersion)<13
                error('ERROR: Improper Sonnet Version. Via metals can only be added to Sonnet 13 projects. Sonnet 12 projects use the same metal types for planar and via polygons.');
            end
            
            if obj.isGeometryProject
                obj.GeometryBlock.addVolumeMetal(theName,theConductivity,theWallThickness);
            else
                error('This method is only available for Geometry projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function defineNewArrayMetalType(obj,theName,theConductivity,theFillFactor)
            %defineNewArrayMetalType   Defines a new type of via metal
            %   Project.defineNewArrayMetalType(Name,R,X) will define
            %   an array metal type for the project.
            %
            %   Note: This method is only for geometry projects.
            %   Note: This method is only for Sonnet version 13 projects.
            %
            %   Example usage:
            %
            %       % Define a new array metal type named 'ArrayMetal1'
            %       Project.defineNewArrayMetalType('ArrayMetal1',50,100);
            %
            %   See also SonnetProject.defineNewViaMetalType
            
            % Find the version number
            if (~isempty(obj.VersionOfSonnet))
                if isa(obj.VersionOfSonnet,'char')
                    aVersion=sscanf(obj.VersionOfSonnet,'%d'); % Extract the first two digits of the version number
                else
                    aVersion=obj.VersionOfSonnet;
                end
            end
            
            % If the project is an invalid version (less than 13)
            % then throw and error.
            if floor(aVersion)<13
                error('ERROR: Improper Sonnet Version. Via metals can only be added to Sonnet 13 projects. Sonnet 12 projects use the same metal types for planar and via polygons.');
            end
            
            if obj.isGeometryProject
                obj.GeometryBlock.addArrayMetal(theName,theConductivity,theFillFactor);
            else
                error('This method is only available for Geometry projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function defineNewBrickType(obj,theArgument1,theArgument2,theArgument3,...
                theArgument4,theArgument5,theArgument6,theArgument7,theArgument8,...
                theArgument9,theArgument10)
            %defineNewBrickType   New anisotropic dielectric brick type
            %   Project.defineNewBrickType(...) will add a
            %   dielectric brick type to the array of brick types.
            %
            %   There are two ways to use defineNewBrickType. The user
            %   may define a brick type using a set of custom options or
            %   the user may define a type using a predefined property set
            %   from the Sonnet library.
            %
            %   If defineNewBrickType is used to import a brick type from the
            %   Sonnet library then the following arguments must be specified
            %     1) The name of the material
            %
            %   defineNewBrickType can be used to add an Isotropic Dielectric
            %   brick type to the project by specifying the following parameters.
            %     1)  The name of the dielectric
            %     2)  Relative dielectric constant
            %     3)  Loss tangent
            %     4)  Bulk conductivity
            %
            %   defineNewBrickType can be used to add an anisotropic Dielectric
            %   brick type to the project by specifying the following parameters.
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
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %       % Define the Aluminum Nitride brick material
            %       % using the Sonnet material library
            %       Project.defineNewBrickType('Aluminum Nitride');
            %
            %       % Make a new brick material named 'Brick1' with
            %       % a relative dielectric constant of 1, a loss
            %       % tangent of 2 and a bulk conductivity of 3.
            %       Project.defineNewBrickType('Brick1',1,2,3);
            %
            %       % Make a new brick material named 'Brick1' with
            %       % the following settings:
            %       % X direction:
            %       %   relative dielectric constant of 1
            %       %   loss tangent of 2
            %       %   bulk conductivity of 3
            %       % Y direction:
            %       %   relative dielectric constant of 4
            %       %   loss tangent of 5
            %       %   bulk conductivity of 6
            %       % Z direction:
            %       %   relative dielectric constant of 7
            %       %   loss tangent of 8
            %       %   bulk conductivity of 9
            %       Project.defineNewBrickType('Brick1',1,2,3,4,5,6,7,8,9);
            %
            % See also SonnetProject.addIsotropicDielectricBrickType
            
            if obj.isGeometryProject
                if nargin == 2
                    obj.GeometryBlock.addDielectricBrickTypeFromLibrary(theArgument1);
                elseif nargin == 5
                    obj.GeometryBlock.addIsotropicDielectric(theArgument1,theArgument2,theArgument3,theArgument4);
                elseif nargin == 11
                    obj.GeometryBlock.addAnisotropicDielectric(theArgument1,theArgument2,...
                        theArgument3,theArgument4,theArgument5,theArgument6,theArgument7,...
                        theArgument8,theArgument9,theArgument10);
                end
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Port Methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aPort=addPort(obj,theType,theArgument1,theArgument2,theArgument3,...
                theArgument4,theArgument5,theArgument6,theArgument7,theArgument8,...
                theArgument9)
            %addPort   Add a port to the project
            %   Port=Project.addPort(...) will add a port to the project.
            %   This method is only for geometry projects. A reference to
            %   the new port is returned.
            %
            %   addPort requires a type as
            %   the first argument which should
            %   be one of the following:
            %
            %       STD   -   Standard Port
            %       AGND  -   Auto Grounded Port
            %       CUP   -   Co-Calibrated Port
            %
            %   Then you will need to supply the necessary
            %   arguments for each as follows:
            %
            %   STD - Standard Port
            %     1) The Polygon to which the port is attached.
            %           This can be replaced by the polygon's
            %           debug ID value.
            %     2) The Vertex to which the polygon is attached
            %     3) The Resistance for the port
            %     4) The Reactance for the port
            %     5) The Inductance for the port
            %     6) The Capacitance for the port
            %     7) The Port Number (Optional)
            %
            %   AGND - Auto Grounded Port
            %     1) The Polygon to which the port is attached.
            %           This can be replaced by the polygon's
            %           debug ID value.
            %     2) The Vertex to which the polygon is attached
            %     3)  The Resistance for the port
            %     4)  The Reactance for the port
            %     5)  The Inductance for the port
            %     6)  The capacitance for the port
            %     7)  A character string which identifies a
            %          reference plane for the autogrounded port.
            %          This value is FIX for a reference
            %          plane and NONE for a calibration length.
            %     8)  A floating point number which provides the
            %          length of the reference plane when the type
            %          is FIX and provides the calibration length
            %          when the type is NONE.
            %     9) The Port Number(Optional)
            %
            %   CUP - Co-calibrated Port
            %     1) The Polygon to which the port is attached.
            %           This can be replaced by the polygon's
            %           debug ID value.
            %     2) The Name of the group to which it belongs
            %     2) The Vertex to which the polygon is attached
            %     4) The Resistance for the port
            %     5) The Reactance for the port
            %     6) The Inductance for the port
            %     7) The capacitance for the port
            %     8) The Port Number (Optional)
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %       % Add a standard port
            %       Project.addPort('STD',11,1,75,0,0,0);
            %
            %       % Add an autogrounded port
            %       Project.addPort('AGND',11,1,50,0,0,0,'FIX',10);
            %
            %       % Add an co-calibrated port
            %       PortReference=Project.addPort('CUP',11,'A',1,75,0,0,0);
            %
            %   See also SonnetProject.addPortToPolygon, SonnetProject.addPortCocalibrated,
            %            SonnetProject.addPortAtLocation, SonnetProject.addPortStandard,
            %            SonnetProject.addPortAutoGrounded
            
            if obj.isGeometryProject
                if nargin == 8
                    aPort=obj.GeometryBlock.addPort(theType,theArgument1,theArgument2,theArgument3,...
                        theArgument4,theArgument5,theArgument6);
                elseif nargin == 9
                    aPort=obj.GeometryBlock.addPort(theType,theArgument1,theArgument2,theArgument3,...
                        theArgument4,theArgument5,theArgument6,theArgument7);
                elseif nargin == 10
                    aPort=obj.GeometryBlock.addPort(theType,theArgument1,theArgument2,theArgument3,...
                        theArgument4,theArgument5,theArgument6,theArgument7,theArgument8);
                elseif nargin == 11
                    aPort=obj.GeometryBlock.addPort(theType,theArgument1,theArgument2,theArgument3,...
                        theArgument4,theArgument5,theArgument6,theArgument7,theArgument8,theArgument9);
                end
                
            else
                error('This method is only available for Geometry projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aPort=addPortToPolygon(obj,thePolygon,theVertexNumber)
            %addPortToPolygon   Add a port to the project
            %   Port=Project.addPortToPolygon(Polygon, Vertex) will add a
            %   standard port to the specified vertex of the passed
            %   polygon. The vertex number should be the index for
            %   the first vertex number that defines the polygon edge;
            %   if the user would like to attach a port between the
            %   third and fourth (X,Y) coordinate points for a polygon
            %   then the vertex number should be three. A reference to
            %   the new port is returned.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % In this example we will add a port to
            %       % a particular polygon in the project.
            %       % The X and Y coordinates of the sixth
            %       % polygon in the project are as follows:
            %       %
            %       % Project.getPolygon(6).XCoordinateValues
            %       % ans =
            %       %    [34]    [227]    [227]    [34]    [34]
            %       %
            %       % Project.getPolygon(6).YCoordinateValues
            %       % ans =
            %       %    [105]    [105]    [75]    [75]    [105]
            %       %
            %       % Add we want to add a port on the edge between (227,105)
            %       % and (227,75). Because (227,105) is the second coordinate
            %       % pair the vertex number should be two. The polygon
            %       % in this case is the sixth polygon in the project; we can
            %       % get a reference to the sixth polygon in the project
            %       % with the command Project.getPolygon(6).
            %       PortReference=Project.addPort(6,2);
            %
            %   See also SonnetProject.addPort, SonnetProject.addPortAtLocation,
            %            SonnetProject.addPortCocalibrated, SonnetProject.addPortStandard,
            %            SonnetProject.addPortAutoGrounded
            
            if obj.isGeometryProject
                if nargin == 3
                    aPort=obj.GeometryBlock.addPortToPolygon(thePolygon,theVertexNumber);
                else
                    disp('Improper Arguments.  See help SonnetProject.addPortToPolygon');
                end
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aPort=addPortAtLocation(obj,theXCoordinate,theYCoordinate, theLevel)
            %addPortAtLocation   Add a port to the project
            %   Port=Project.addPortAtLocation(X,Y) will add an standard port
            %   to the project by specifying an X and Y coordinate.
            %   The function will find the closest polygon edge and
            %   place the port there. A reference to the new port is returned.
            %
            %   Port=Project.addPortAtLocation(X,Y,Level) will add an standard port
            %   to the project by specifying an X and Y coordinate.
            %   The function will find the closest polygon edge and
            %   place the port there. Only polygons on the specified
            %   level will be checked. A reference to the new port is returned.
            %
            %   Note: This method is only for geometry projects.
            %   Note: If the distance between the closest edge and the port
            %         location is more than 5% of the average of the length
            %         and width of the box then the port will not be placed
            %         and an error will be thrown.
            %
            %   Example usage:
            %       % Add a standard port
            %       Port=Project.addPortAtLocation(330,200);
            %
            %   See also SonnetProject.addPort, SonnetProject.addPortToPolygon,
            %            SonnetProject.addPortCocalibrated, SonnetProject.addPortStandard,
            %            SonnetProject.addPortAutoGrounded
            
            if obj.isGeometryProject
                if nargin == 3
                    aPort=obj.GeometryBlock.addPortAtLocation(theXCoordinate,theYCoordinate);
                elseif nargin == 4
                    aPort=obj.GeometryBlock.addPortAtLocation(theXCoordinate,theYCoordinate, theLevel);
                else
                    disp('Improper Arguments.  See help SonnetProject.addPortAtLocation');
                end
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aPort=addPortStandard(obj,thePolygon,theVertex,theResistance,theReactance,theInductance,...
                theCapacitance,thePortNumber)
            %addPortStandard   Add a port to the project
            %   Port=Project.addPortStandard(Polygon,Vertex,Resistance,Reactance,
            %   Inductance,Capacitance) will add a standard port to the
            %   array of ports. The vertex number should be the index for
            %   the first vertex number that defines the polygon edge;
            %   if the user would like to attach a port between the
            %   third and fourth (X,Y) coordinate points for a polygon
            %   then the vertex number should be three. A reference to the
            %   new port is returned.
            %
            %   Port=Project.addPortStandard(Polygon,Vertex,Resistance,Reactance,
            %   Inductance,Capacitance,PortNumber) will add a standard port to the
            %   array of ports. The vertex number should be the index for
            %   the first vertex number that defines the polygon edge;
            %   if the user would like to attach a port between the
            %   third and fourth (X,Y) coordinate points for a polygon
            %   then the vertex number should be three. The port number
            %   for the port will be 'PortNumber'. A reference to the new
            %   port is returned.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %       % Add a standard port
            %       Port=Project.addPortStandard(11,1,75,0,0,0);
            %
            %   See also SonnetProject.addPort, SonnetProject.addPortToPolygon,
            %            SonnetProject.addPortCocalibrated, SonnetProject.addPortAtLocation,
            %            SonnetProject.addPortAutoGrounded
            
            if obj.isGeometryProject
                if nargin == 8
                    aPort=obj.GeometryBlock.addPortStandard(thePolygon,theVertex,theResistance,theReactance,theInductance,theCapacitance,thePortNumber);
                else
                    aPort=obj.GeometryBlock.addPortStandard(thePolygon,theVertex,theResistance,theReactance,theInductance,theCapacitance);
                end
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aPort=addPortAutoGrounded(obj,thePolygon,theVertex,theResistance,theReactance,theInductance,...
                theCapacitance,theTypeOfReferencePlane,...
                theReferencePlaneOrCalibrationLength,thePortNumber)
            %addPortAutoGrounded   Add a port to the project
            % Port=Project.addPortAutoGrounded(...) will add an autogrounded port
            % to the array of ports. A reference to the new port is returned.
            %
            %   It requires the following arguments:
            %     1)  The Polygon to which the port is attached (or its debugID)
            %     2)  The Vertex to which the polygon is attached. The vertex number
            %           should be the index for the first vertex number that
            %           defines the polygon edge; if the user would like to
            %           attach a port between the third and fourth (X,Y)
            %           coordinate points for a polygon then the vertex
            %           number should be three. The port number for the
            %           port will be 'PortNumber'.
            %     3)  The Resistance for the port
            %     4)  The Reactance for the port
            %     5)  The Inductance for the port
            %     6)  The capacitance for the port
            %     7)  A character string which identifies a
            %           reference plane for the autogrounded port.
            %           this value is FIX for a reference
            %           plane and NONE for a calibration length.
            %     8)  A floating point number which provides the
            %           length of the reference plane when the type
            %           is FIX and provides the calibration length
            %           when the type is NONE.
            %     9) The Port Number(Optional)
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %       % Add an autogrounded port
            %       Port=Project.addPortAutoGrounded(11,1,50,0,0,0,'FIX',10);
            %
            %   See also SonnetProject.addPort, SonnetProject.addPortToPolygon,
            %            SonnetProject.addPortCocalibrated, SonnetProject.addPortAtLocation,
            %            SonnetProject.addPortStandard
            
            if obj.isGeometryProject
                if nargin == 10
                    aPort=obj.GeometryBlock.addPortAutoGrounded(thePolygon,theVertex,theResistance,theReactance,theInductance,theCapacitance,theTypeOfReferencePlane,theReferencePlaneOrCalibrationLength,thePortNumber);
                else
                    aPort=obj.GeometryBlock.addPortAutoGrounded(thePolygon,theVertex,theResistance,theReactance,theInductance,theCapacitance,theTypeOfReferencePlane,theReferencePlaneOrCalibrationLength);
                end
            else
                error('This method is only available for Geometry projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aPort=addPortCocalibrated(obj,thePolygon,theGroupName,theVertex,theResistance,theReactance,...
                theInductance,theCapacitance,thePortNumber)
            %addPortCocalibrated   Add a port to the project
            % Port=Project.addPortCocalibrated(...) will add a standard port
            % to the array of ports. A reference to the new port is returned.
            %
            %   It requires the following arguments:
            %     1) The Polygon to which the port is attached (or its debugID)
            %     2) The Name of the group to which it belongs
            %     3)  The Vertex to which the polygon is attached. The vertex number
            %           should be the index for the first vertex number that
            %           defines the polygon edge; if the user would like to
            %           attach a port between the third and fourth (X,Y)
            %           coordinate points for a polygon then the vertex
            %           number should be three. The port number for the
            %           port will be 'PortNumber'.
            %     4) The Resistance for the port
            %     5) The Reactance for the port
            %     6) The Inductance for the port
            %     7) The capacitance for the port
            %     8) The Port Number (Optional)
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %       % Add an co-calibrated port
            %       Port=Project.addPortCocalibrated(11,'A',1,75,0,0,0);
            %
            %   See also SonnetProject.addPort, SonnetProject.addPortToPolygon,
            %            SonnetProject.addPortAutoGrounded, SonnetProject.addPortAtLocation,
            %            SonnetProject.addPortStandard
            
            if obj.isGeometryProject
                if nargin == 9
                    aPort=obj.GeometryBlock.addPortCocalibrated(thePolygon,theGroupName,theVertex,theResistance,theReactance,theInductance,theCapacitance,thePortNumber);
                else
                    aPort=obj.GeometryBlock.addPortCocalibrated(thePolygon,theGroupName,theVertex,theResistance,theReactance,theInductance,theCapacitance);
                end
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addCoCalibratedGroup(obj,theGroupName,theGroundReference,theTerminalWidthType)
            %addCoCalibratedGroup   Add a co-calibrated port group
            %   Project.addCoCalibratedGroup(name,GroundReference,TerminalWidthType) will
            %   add a co-calibration group to the array of co-calibration groups.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %       Project.addCoCalibratedGroup('A','B','FEED');
            %
            %     See also SonnetProject.addPort, SonnetProject.addPortCocalibrated
            
            if obj.isGeometryProject
                obj.GeometryBlock.addCoCalibratedGroup(theGroupName,theGroundReference,theTerminalWidthType);
            else
                error('This method is only available for Geometry projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addReferencePlaneToPortGroup(obj,theGroupName,theSide,theTypeOfReferencePlane,theLengthOrPolygon,theVertex)
            %addReferencePlaneToPortGroup   Adds a reference plane to a cocalibrated port group
            %   Project.addReferencePlaneToPortGroup(...) will add a reference plane
            %   to a cocalibrated port group.
            %
            %   addReferencePlaneToPortGroup requires these arguments:
            %     1) The Name    -  the name of the cocalibrated port group
            %     2) The Side    -  the side the plane is on ('LEFT', 'RIGHT', 'Top', 'BOTTOM')
            %     3) The Type    -  type of reference plane (FIX, LINK, NONE)
            %     4) The length  -  length of the reference plane (If type is FIX or NONE)
            %          or
            %     4) The polygon -  the polygon to which the reference plane is linked
            %                       either the polygon object or the polygon's ID.
            %     5) If it is a polygon the vertex to which the reference
            %         plane will be connected to will need to be specified
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Add a reference plane to the 'TOP' side
            %       % of type 'FIX' of length 12.
            %       Project.addReferencePlaneToPortGroup('A','TOP','FIX',12);
            %
            %       % Add a reference plane to the 'BOTTOM' side
            %       % of type 'NONE' of length 10.
            %       Project.addReferencePlaneToPortGroup('A','BOTTOM','NONE',10);
            %
            %       % Add a reference plane to the 'RIGHT' side
            %       % of type 'LINK' with vertex 1 of a particular polygon.
            %       Project.addReferencePlaneToPortGroup('B','RIGHT','LINK',aPolygonObject,1);
            %
            %       % Add a reference plane to the 'RIGHT' side
            %       % of type 'LINK' at the 2nd vertex of the polygon
            %       % with an ID of 1.
            %       Project.addReferencePlaneToPortGroup('B','RIGHT','LINK',1,2);
            
            if obj.isGeometryProject
                if nargin == 6
                    obj.GeometryBlock.addReferencePlaneToPortGroup(theGroupName,theSide,theTypeOfReferencePlane,theLengthOrPolygon,theVertex);
                else
                    obj.GeometryBlock.addReferencePlaneToPortGroup(theGroupName,theSide,theTypeOfReferencePlane,theLengthOrPolygon);
                end
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function deletePort(obj,thePortNumber)
            %deletePort   Deletes a port
            %   Project.deletePort(N) will delete
            %   the port represented by the port
            %   number N from the project.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %       % Delete port number one from a project
            %       Project.deletePort(1);
            %
            %     See also SonnetProject.deletePortUsingIndex
            
            if obj.isGeometryProject
                obj.GeometryBlock.deletePort(thePortNumber);
            else
                error('This method is only available for Geometry projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function deletePortUsingIndex(obj,thePortIndex)
            %deletePortUsingIndex   Deletes a port
            %   Project.deletePortUsingIndex(N) will delete
            %   the Nth port in the array of ports.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %       % Delete the first port in a project
            %       Project.deletePortUsingIndex(1);
            %
            %     See also SonnetProject.deletePort
            
            if obj.isGeometryProject
                obj.GeometryBlock.deletePortUsingIndex(thePortIndex);
            else
                error('This method is only available for Geometry projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [aPort, aPortNumber, aIndex]=findPort(obj,thePortNumber)
            %findPort   Finds a port
            %   [Port PortNumber Index]=Project.findPort(N) will
            %   find the port with the port number N in the array
            %   of ports.
            %
            %   Note: This method is only for geometry projects.
            %
            %   See also SonnetProject.findPortUsingPoint
            
            if obj.isGeometryProject
                [aPort, aPortNumber, aIndex]=obj.GeometryBlock.findPort(thePortNumber);
            else
                error('This method is only available for Geometry projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [thePort, thePortNumber, theIndex]=findPortUsingPoint(obj, theXCoordinate, theYCoordinate, theLevel)
            %findPortUsingPoint   Find a port given an approximate location
            %   [Port PortNumber Index]=Project.findPortUsingPoint(X, Y) finds a port
            %   in the array of ports given an (X,Y) coordinate pair that is near the port.
            %   This method returns a reference to the port object, the port number,
            %   and the index for the port in the cell array of ports. If all the ports
            %   are beyond a certain distance from the location then an error will be
            %   thrown.
            %
            %   [Port PortNumber Index]=Project.findPortUsingPoint(X, Y, Level) finds a port
            %   in the array of ports given an (X,Y) coordinate pair that is near the port.
            %   only ports on the specified level will be checked. This method returns a
            %   reference to the port object, the port number, and the index for the port
            %
            %   in the cell array of ports. If all the ports are beyond a certain distance
            %   from the location then an error will be thrown.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Find all ports on any layer that are near (0,120)
            %       [thePort thePortNumber theIndex]=Project.findPortUsingPoint(0,120);
            %
            % See also SonnetProject.findPortsInGroup
            
            if obj.isGeometryProject
                if nargin == 3      % If we did not receive the level as an argument
                    [thePort, thePortNumber, theIndex]=obj.GeometryBlock.findPortUsingPoint(theXCoordinate, theYCoordinate);
                elseif nargin == 4  % If we did receive the level as an argument
                    [thePort, thePortNumber, theIndex]=obj.GeometryBlock.findPortUsingPoint(theXCoordinate, theYCoordinate, theLevel);
                else
                    error('Invalid number of parameters.');
                end
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [thePort, thePortNumber, theIndex]=findPortsInGroup(obj, theGroupName)
            %findPortUsingPoint   Find a port given an approximate location
            %   [Port PortNumber Index]=Project.findPortsInGroup(GroupName) finds
            %   all the ports in the specified group name.
            %
            %   Note: This method is only for geometry projects.
            %
            % See also SonnetProject.findPortUsingPoint
            
            if obj.isGeometryProject
                [thePort, thePortNumber, theIndex]=obj.GeometryBlock.findPortsInGroup(theGroupName);
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% File Output Methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addTouchstoneOutput(obj)
            %addTouchstoneOutput   Find a port given an approximate location
            %   Project.addTouchstoneOutput() will add a touchstone
            %   file output to the project. The output file will have
            %   the same base filename as the project but will have the
            %   extension ".s#p" where # is the number of ports currently
            %   in the project.
            %
            %   Note: This method is the equivalent of the following command
            %         Project.addFileOutput('TS','D','Y','$BASENAME.s#p','IC','N','S','MA','R',50);
            %         where # is the number of ports in the project.
            %
            % See also SonnetProject.findPortUsingPoint
            
            % Determine the number for s#p
            if obj.isGeometryProject
                aNumberOfPorts=length(obj.GeometryBlock.ArrayOfPorts);
            else
                aNumberOfPorts=length(obj.CircuitElementsBlock.ArrayOfNetworkElements{1}.ArrayOfPortNodeNumbers);
                for iCounter=2:length(obj.CircuitElementsBlock.ArrayOfNetworkElements)
                    if aNumberOfPorts < length(obj.CircuitElementsBlock.ArrayOfNetworkElements{iCounter}.ArrayOfPortNodeNumbers)
                        aNumberOfPorts=length(obj.CircuitElementsBlock.ArrayOfNetworkElements{iCounter}.ArrayOfPortNodeNumbers);
                    end
                end
            end
            
            obj.addFileOutput('TS','D','Y',['$BASENAME.s' num2str(aNumberOfPorts) 'p'],'IC','N','S','MA','R',50);
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addFileOutput(obj,theargument1,theargument2,theargument3,theargument4,theargument5,...
                theargument6,theargument7,theargument8,theargument9,theargument10,theargument11,...
                theargument12,theargument13,theargument14)
            %addFileOutput   Create a new output file
            %   Project.addFileOutput(...) will add another output file to the
            %   project. This method takes the following arguments:
            %
            %      1) A string to represent the File Type as follows:
            %          File Type      Entry Definition
            %            TS              Touchstone
            %            DATA_BANK       Databank
            %            SC              SCompact
            %            CSV             Spreadsheet
            %            CADENCE         Cadence
            %            MDIF            MDIF (S2P)
            %            EBMDIF          MDIF (ebridge)
            %
            %      2) The Network Name to be exported (only applies to Netlist).  If you want
            %         the output of all networks then have this argument be the empty string
            %         ( '' ). This parameter can be completely ignored in most cases.
            %
            %      3) Whether or not to embed. This field is "D" for de-embedded data
            %           or "ND" for non-de-embedded data.
            %
            %      4) This field is "Y" to include the ABS adaptive data or "N" to
            %           include only the discrete data.
            %
            %      5) The filename consists of a basename and extension. If the basename
            %           of the project file is used, the variable "$BASENAME" may be
            %           substituted in the filename. For example, in the project file
            %           steps.son if an output file steps.s2p is entered, the filename
            %           would appears as "$BASENAME.s2p" in the fileout block. The user may
            %           enter any filename they wish and is not restricted in their
            %           use of extensions.
            %
            %      6) This field is "NC" for no comments or "IC" to include comments.
            %
            %      7) This field is 'Y' if the output is high precision and 'N' if not.
            %
            %      8) This field is "S" for S-Parameters, "Y" for Y-Parameters,
            %           and "Z" for Z-Parameters. This value is 'SPECTRE'
            %           for NCLINE (RLGC) file outputs. If the output is
            %           NCLINE then do not include any of the below
            %           arguments.
            %
            %      9) The form for the Parameter has the following entry possibilities
            %            MA  -  Mag-Angle
            %            DB  -  DB-Angle
            %            RI  -  Real-Imaginary
            %
            %      10) The PortType should be one of the following
            %            R       If all ports in the circuit use real impedance
            %                       with the same resistance and all other values 0
            %
            %            Z       If all ports in the circuit use complex impedance
            %                       with the same resistance and all other values 0
            %
            %            TERM    If a port or ports in the circuit have a non-zero value
            %                       for either the Resistance or Reactance
            %
            %            FTERM   If a port or ports in the circuit have a non-zero value
            %                       for the Resistance or Reactance and either
            %                       the inductance or capacitance
            %
            %   If the port type was resistor
            %      11) One or more Resistance values stored as a matrix
            %
            %   If the port type was complex impedance
            %      11) One or more Resistance values stored as a matrix
            %      12) One or more ImaginaryResistance
            %
            %   If the port type was TERM
            %      11) One or more Resistance values stored as a matrix
            %      12) One or more Reactance values stored as a matrix
            %
            %   If the port type was FTERM
            %      11) One or more Resistance values stored as a matrix
            %      12) One or more Reactance values stored as a matrix
            %      13) One or more Inductance values stored as a matrix
            %      14) One or more Capacitance values stored as a matrix
            %
            %   Example usage:
            %
            %       % Add a new touchstone file output to the project
            %       % the name out the outputted file will be the name
            %       % name of the project ('BASENAME' gets replaced
            %       % with the project name automatically)
            %       Project.addFileOutput('TS','D','Y','$BASENAME.s1p','IC','N','S','MA','R',20);
            %
            %   See also SonnetProject.addFileOutputForNetlist,
            %            SonnetProject.addFileOutputForGeometry
            
            if obj.isGeometryProject  % If the project is a geometry project
                if nargin == 11
                    addFileOutputForGeometry(obj,theargument1,theargument2,theargument3,theargument4,theargument5,theargument6,theargument7,theargument8,theargument9,theargument10)
                elseif nargin == 12
                    addFileOutputForGeometry(obj,theargument1,theargument2,theargument3,theargument4,theargument5,theargument6,theargument7,theargument8,theargument9,theargument10,theargument11)
                elseif nargin == 13
                    addFileOutputForGeometry(obj,theargument1,theargument2,theargument3,theargument4,theargument5,theargument6,theargument7,theargument8,theargument9,theargument10,theargument11,theargument12)
                elseif nargin == 14
                    addFileOutputForGeometry(obj,theargument1,theargument2,theargument3,theargument4,theargument5,theargument6,theargument7,theargument8,theargument9,theargument10,theargument11,theargument12,theargument13)
                elseif nargin == 8
                    addFileOutputForGeometry(obj,theargument1,theargument2,theargument3,theargument4,theargument5,theargument6,theargument7);
                end
                
            else                       % If the project is a netlist project
                if nargin == 11
                    addFileOutputForGeometry(obj,theargument1,theargument2,theargument3,theargument4,theargument5,theargument6,theargument7,theargument8,theargument9,theargument10)
                elseif nargin == 12
                    addFileOutputForNetlist(obj,theargument1,theargument2,theargument3,theargument4,theargument5,theargument6,theargument7,theargument8,theargument9,theargument10,theargument11)
                elseif nargin == 13
                    addFileOutputForNetlist(obj,theargument1,theargument2,theargument3,theargument4,theargument5,theargument6,theargument7,theargument8,theargument9,theargument10,theargument11,theargument12)
                elseif nargin == 14
                    addFileOutputForNetlist(obj,theargument1,theargument2,theargument3,theargument4,theargument5,theargument6,theargument7,theargument8,theargument9,theargument10,theargument11,theargument12,theargument13)
                elseif nargin == 15
                    addFileOutputForNetlist(obj,theargument1,theargument2,theargument3,theargument4,theargument5,theargument6,theargument7,theargument8,theargument9,theargument10,theargument11,theargument12,theargument13,theargument14)
                elseif nargin == 9
                    addFileOutputForNetlist(obj,theargument1,theargument2,theargument3,theargument4,theargument5,theargument6,theargument7,theargument8);
                elseif nargin == 8
                    addFileOutputForNetlist(obj,theargument1,theargument2,theargument3,theargument4,theargument5,theargument6,theargument7);
                end
                
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addFileOutputForNetlist(obj,theFileType,theNetworkName,theEmbed,theIncludeAbs,...
                theFilename,theIncludeComments,theIsOutputHighPerformance,theParameterType,...
                theParameterForm,thePortType,theargument1,theargument2,theargument3,theargument4)
            %addFileOutputForNetlist   Create a new output file
            % Project.addFileOutputForNetlist(...) will add another output file to the
            % project. This method was not meant to be called
            % directly; please use addFileOutput instead to make
            % sure the project is a netlist project.
            %
            %   Type 'help SonnetProject.addFileOutput' for arguments and more information.
            %
            %   See also SonnetProject.addFileOutput, SonnetProject.addFileOutputForGeometry
            
            % Check if the fileoutput block is in
            % the cell array of blocks; if not then add it
            if isempty(obj.FileOutBlock)
                obj.FileOutBlock=SonnetFileOutBlock();
                obj.CellArrayOfBlocks{length(obj.CellArrayOfBlocks)+1}=obj.FileOutBlock;
            else
                isThereAFileOutBlock=false;
                for iCounter=1:length(obj.CellArrayOfBlocks)
                    if isa(obj.CellArrayOfBlocks{iCounter},'SonnetFileOutBlock')
                        isThereAFileOutBlock=true;
                    end
                end
                if isThereAFileOutBlock == false
                    obj.CellArrayOfBlocks{length(obj.CellArrayOfBlocks)+1}=obj.FileOutBlock;
                end
            end
            
            % Construct a new file output line given the file
            theNewSizeOfTheArray=length(obj.FileOutBlock.ArrayOfFileOutputConfigurations)+1;
            obj.FileOutBlock.ArrayOfFileOutputConfigurations{theNewSizeOfTheArray}=SonnetFileOutLine();
            
            % Assign values to the properties
            if nargin ==8
                obj.FileOutBlock.ArrayOfFileOutputConfigurations{theNewSizeOfTheArray}.FileType=upper(theFileType);
                obj.FileOutBlock.ArrayOfFileOutputConfigurations{theNewSizeOfTheArray}.Embed=upper(theNetworkName);
                obj.FileOutBlock.ArrayOfFileOutputConfigurations{theNewSizeOfTheArray}.IncludeAbs=upper(theEmbed);
                obj.FileOutBlock.ArrayOfFileOutputConfigurations{theNewSizeOfTheArray}.Filename=theIncludeAbs;
                obj.FileOutBlock.ArrayOfFileOutputConfigurations{theNewSizeOfTheArray}.IncludeComments=theFilename;
                obj.FileOutBlock.ArrayOfFileOutputConfigurations{theNewSizeOfTheArray}.IsOutputHighPerformance=upper(theIncludeComments);
                obj.FileOutBlock.ArrayOfFileOutputConfigurations{theNewSizeOfTheArray}.ParameterType=upper(theIsOutputHighPerformance);
                return
            elseif nargin ==9
                obj.FileOutBlock.ArrayOfFileOutputConfigurations{theNewSizeOfTheArray}.FileType=upper(theFileType);
                obj.FileOutBlock.ArrayOfFileOutputConfigurations{theNewSizeOfTheArray}.Embed=upper(theEmbed);
                obj.FileOutBlock.ArrayOfFileOutputConfigurations{theNewSizeOfTheArray}.IncludeAbs=upper(theIncludeAbs);
                obj.FileOutBlock.ArrayOfFileOutputConfigurations{theNewSizeOfTheArray}.Filename=theFilename;
                obj.FileOutBlock.ArrayOfFileOutputConfigurations{theNewSizeOfTheArray}.IncludeComments=upper(theIncludeComments);
                obj.FileOutBlock.ArrayOfFileOutputConfigurations{theNewSizeOfTheArray}.IsOutputHighPerformance=upper(theIsOutputHighPerformance);
                obj.FileOutBlock.ArrayOfFileOutputConfigurations{theNewSizeOfTheArray}.ParameterType=upper(theParameterType);
                return
            else
                obj.FileOutBlock.ArrayOfFileOutputConfigurations{theNewSizeOfTheArray}.FileType=upper(theFileType);
                obj.FileOutBlock.ArrayOfFileOutputConfigurations{theNewSizeOfTheArray}.Embed=upper(theEmbed);
                obj.FileOutBlock.ArrayOfFileOutputConfigurations{theNewSizeOfTheArray}.IncludeAbs=upper(theIncludeAbs);
                obj.FileOutBlock.ArrayOfFileOutputConfigurations{theNewSizeOfTheArray}.Filename=theFilename;
                obj.FileOutBlock.ArrayOfFileOutputConfigurations{theNewSizeOfTheArray}.IncludeComments=upper(theIncludeComments);
                obj.FileOutBlock.ArrayOfFileOutputConfigurations{theNewSizeOfTheArray}.IsOutputHighPerformance=upper(theIsOutputHighPerformance);
                obj.FileOutBlock.ArrayOfFileOutputConfigurations{theNewSizeOfTheArray}.ParameterType=upper(theParameterType);
            end
            
            obj.FileOutBlock.ArrayOfFileOutputConfigurations{theNewSizeOfTheArray}.ParameterForm=upper(theParameterForm);
            obj.FileOutBlock.ArrayOfFileOutputConfigurations{theNewSizeOfTheArray}.PortType=upper(thePortType);
            
            % If the Network name is not the empty string then specify a network
            if strcmp(theNetworkName,'')==0
                obj.FileOutBlock.ArrayOfFileOutputConfigurations{theNewSizeOfTheArray}.NetworkName=upper(theNetworkName);
            end
            
            % If the port was resistor
            if strcmpi(thePortType,'R')==1
                obj.FileOutBlock.ArrayOfFileOutputConfigurations{theNewSizeOfTheArray}.Resistance=theargument1;
                
                % If the port had complex impedance
            elseif strcmpi(thePortType,'Z')==1
                obj.FileOutBlock.ArrayOfFileOutputConfigurations{theNewSizeOfTheArray}.Resistance=theargument1;
                obj.FileOutBlock.ArrayOfFileOutputConfigurations{theNewSizeOfTheArray}.ImaginaryResistance=theargument2;
                
                % If the port was TERM
            elseif strcmpi(thePortType,'TERM')==1
                obj.FileOutBlock.ArrayOfFileOutputConfigurations{theNewSizeOfTheArray}.Resistance=theargument1;
                obj.FileOutBlock.ArrayOfFileOutputConfigurations{theNewSizeOfTheArray}.Reactance=theargument2;
                
                % If the port was FTERM
            elseif strcmpi(thePortType,'FTERM')==1
                obj.FileOutBlock.ArrayOfFileOutputConfigurations{theNewSizeOfTheArray}.Resistance=theargument1;
                obj.FileOutBlock.ArrayOfFileOutputConfigurations{theNewSizeOfTheArray}.Reactance=theargument2;
                obj.FileOutBlock.ArrayOfFileOutputConfigurations{theNewSizeOfTheArray}.Inductance=theargument3;
                obj.FileOutBlock.ArrayOfFileOutputConfigurations{theNewSizeOfTheArray}.Capacitance=theargument4;
                
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addFileOutputForGeometry(obj,theFileType,theEmbed,theIncludeAbs,theFilename,...
                theIncludeComments,theIsOutputHighPerformance,theParameterType,theParameterForm,...
                thePortType,theargument1,theargument2,theargument3,theargument4)
            %addFileOutputForGeometry   Create a new output file
            %   Project.addFileOutputForGeometry(...) will add another output file to the
            %   project. This method was not meant to be called
            %   directly; please use addFileOutput instead to make
            %   sure the project is a geometry project.
            %
            %   Type 'help SonnetProject.addFileOutput' for arguments and more information.
            %
            %   See also SonnetProject.addFileOutput, SonnetProject.addFileOutputForNetlist
            
            % Check if the fileoutput block is in
            % the cell array of blocks; if not then add it
            if isempty(obj.FileOutBlock)
                obj.FileOutBlock=SonnetFileOutBlock();
                obj.CellArrayOfBlocks{length(obj.CellArrayOfBlocks)+1}=obj.FileOutBlock;
            else
                isThereAFileOutBlock=false;
                for iCounter=1:length(obj.CellArrayOfBlocks)
                    if isa(obj.CellArrayOfBlocks{iCounter},'SonnetFileOutBlock')
                        isThereAFileOutBlock=true;
                    end
                end
                if isThereAFileOutBlock == false
                    obj.CellArrayOfBlocks{length(obj.CellArrayOfBlocks)+1}=obj.FileOutBlock;
                end
            end
            
            % Construct a new file output line given the file
            aNewSizeOfTheArray=length(obj.FileOutBlock.ArrayOfFileOutputConfigurations)+1;
            obj.FileOutBlock.ArrayOfFileOutputConfigurations{aNewSizeOfTheArray}=SonnetFileOutLine();
            
            % Assign values to the properties
            obj.FileOutBlock.ArrayOfFileOutputConfigurations{aNewSizeOfTheArray}.FileType=upper(theFileType);
            obj.FileOutBlock.ArrayOfFileOutputConfigurations{aNewSizeOfTheArray}.Embed=upper(theEmbed);
            obj.FileOutBlock.ArrayOfFileOutputConfigurations{aNewSizeOfTheArray}.IncludeAbs=upper(theIncludeAbs);
            obj.FileOutBlock.ArrayOfFileOutputConfigurations{aNewSizeOfTheArray}.Filename=theFilename;
            obj.FileOutBlock.ArrayOfFileOutputConfigurations{aNewSizeOfTheArray}.IncludeComments=upper(theIncludeComments);
            obj.FileOutBlock.ArrayOfFileOutputConfigurations{aNewSizeOfTheArray}.IsOutputHighPerformance=upper(theIsOutputHighPerformance);
            obj.FileOutBlock.ArrayOfFileOutputConfigurations{aNewSizeOfTheArray}.ParameterType=upper(theParameterType);
            
            if nargin == 8
                return
            end
            
            obj.FileOutBlock.ArrayOfFileOutputConfigurations{aNewSizeOfTheArray}.ParameterForm=upper(theParameterForm);
            obj.FileOutBlock.ArrayOfFileOutputConfigurations{aNewSizeOfTheArray}.PortType=upper(thePortType);
            
            % If the port was resistor
            if strcmpi(thePortType,'R')==1
                obj.FileOutBlock.ArrayOfFileOutputConfigurations{aNewSizeOfTheArray}.Resistance=theargument1;
                
                % If the port had complex impedance
            elseif strcmpi(thePortType,'Z')==1
                obj.FileOutBlock.ArrayOfFileOutputConfigurations{aNewSizeOfTheArray}.Resistance=theargument1;
                obj.FileOutBlock.ArrayOfFileOutputConfigurations{aNewSizeOfTheArray}.ImaginaryResistance=theargument2;
                
                % If the port was TERM
            elseif strcmpi(thePortType,'TERM')==1
                obj.FileOutBlock.ArrayOfFileOutputConfigurations{aNewSizeOfTheArray}.Resistance=theargument1;
                obj.FileOutBlock.ArrayOfFileOutputConfigurations{aNewSizeOfTheArray}.Reactance=theargument2;
                
                % If the port was FTERM
            elseif strcmpi(thePortType,'FTERM')==1
                obj.FileOutBlock.ArrayOfFileOutputConfigurations{aNewSizeOfTheArray}.Resistance=theargument1;
                obj.FileOutBlock.ArrayOfFileOutputConfigurations{aNewSizeOfTheArray}.Reactance=theargument2;
                obj.FileOutBlock.ArrayOfFileOutputConfigurations{aNewSizeOfTheArray}.Inductance=theargument3;
                obj.FileOutBlock.ArrayOfFileOutputConfigurations{aNewSizeOfTheArray}.Capacitance=theargument4;
                
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addPiModel(obj,theFormat,theEmbed,theIncludeAbs,theFilename,...
                theIncludeComments,theIsOutputHighPerformance,thePINT,theRMAX,...
                theCMIN,theLMAX,theKMIN,theRZERO)
            %addPiModel   Create a new Pi Model output file
            %   Project.addPiModel(...) will add a pi model output file 
            %   to the project.
            %
            %   Arguments are:
            %      1) The format for the export. Should be either 'PSPICE'
            %           or 'SPECTRE'
            %      2) Whether or not to use embedded data. This field is "D" 
            %           for de-embedded data or "ND" for non-de-embedded data.
            %      3) This field is "Y" to include the ABS adaptive data or "N" to
            %           include only the discrete data.
            %      4) The filename consists of a basename and extension. If the basename
            %           of the project file is used, the variable "$BASENAME" may be
            %           substituted in the filename. For example, in the project file
            %           steps.son if an output file steps.s2p is entered, the filename
            %           would appears as "$BASENAME.s2p" in the fileout block. The user may
            %           enter any filename they wish and is not restricted in their
            %           use of extensions.
            %      5) This field is "NC" for no comments or "IC" to include comments.
            %      6) This field is 'Y' if the output is high precision and 'N' if not.
            %      7) This is a floating point number for the percentage used to 
            %           determine the intervals between the two frequencies used to 
            %           determine each SPICE model.
            %      8) This is a floating point number for the percentage used to determine the 
            %          intervals between the two frequencies used to determine each SPICE model
            %      9) This is a floating point number for the maximum allowed resistance
            %     10) This is a floating point number for the minimum allowed capacitance
            %     11) This is a floating point number for the maximum allowed inductance
            %     12) This is a floating point number for the minimum allowed mutual inductance
            %     13) This is a floating point number for the resistor to go in series with 
            %           all lossless inductors
            %
            %   See also SonnetProject.addFileOutput
            
            % Check if the fileoutput block is in
            % the cell array of blocks; if not then add it
            if isempty(obj.FileOutBlock)
                obj.FileOutBlock=SonnetFileOutBlock();
                obj.CellArrayOfBlocks{length(obj.CellArrayOfBlocks)+1}=obj.FileOutBlock;
            else
                isThereAFileOutBlock=false;
                for iCounter=1:length(obj.CellArrayOfBlocks)
                    if isa(obj.CellArrayOfBlocks{iCounter},'SonnetFileOutBlock')
                        isThereAFileOutBlock=true;
                    end
                end
                if isThereAFileOutBlock == false
                    obj.CellArrayOfBlocks{length(obj.CellArrayOfBlocks)+1}=obj.FileOutBlock;
                end
            end
            
            % Construct a new file output line given the file
            aNewSizeOfTheArray=length(obj.FileOutBlock.ArrayOfFileOutputConfigurations)+1;
            obj.FileOutBlock.ArrayOfFileOutputConfigurations{aNewSizeOfTheArray}=SonnetFileOutLine();
            aEntry=obj.FileOutBlock.ArrayOfFileOutputConfigurations{aNewSizeOfTheArray};
            
            % Assign values to the properties
            aEntry.FileType='PIMODEL';
            aEntry.Embed=theEmbed;
            aEntry.IncludeAbs=theIncludeAbs;
            aEntry.Filename=theFilename;
            aEntry.IsOutputHighPerformance=theIsOutputHighPerformance;
            aEntry.IncludeComments=theIncludeComments;
            aEntry.PINT=thePINT;
            aEntry.RMAX=theRMAX;
            aEntry.CMIN=theCMIN;
            aEntry.LMAX=theLMAX;
            aEntry.KMIN=theKMIN;
            aEntry.RZERO=theRZERO;
            aEntry.TYPE=theFormat;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addNCoupledLineOutput(obj,theEmbed,theIncludeAbs,theFilename,...
                theIsOutputHighPerformance,theNetwork)
            %addNCoupledLineOutput   Create a new N-Coupled Line Model
            %   Project.addNCoupledLineOutput(...) will add a N-Coupled  
            %   line model output file to the project.
            %
            %   Arguments are:
            %      1) Whether or not to use embedded data. This field is "D" 
            %           for de-embedded data or "ND" for non-de-embedded data.
            %      2) This field is "Y" to include the ABS adaptive data or "N" to
            %           include only the discrete data.
            %      3) The filename consists of a basename and extension. If the basename
            %           of the project file is used, the variable "BASENAME" may be
            %           substituted in the filename. For example, in the project file
            %           steps.son if an output file steps.s2p is entered, the filename
            %           would appears as "$BASENAME.dat" in the fileout block. The user may
            %           enter any filename they wish and is not restricted in their
            %           use of extensions.
            %      4) This field is 'Y' if the output is high precision and 'N' if not.
            %      5) (Optional) When used with a netlist project this
            %          argument allows users to output data for only a
            %          specified network by name.
            %
            %   Example:
            %       Project.addNCoupledLineOutput('D','Y','$BASENAME.dat','Y');
            %       Project.addNCoupledLineOutput('D','Y','$BASENAME.dat','Y','Network1');
            %
            %   See also SonnetProject.addFileOutput
            
            % Check if the fileoutput block is in
            % the cell array of blocks; if not then add it
            if isempty(obj.FileOutBlock)
                obj.FileOutBlock=SonnetFileOutBlock();
                obj.CellArrayOfBlocks{length(obj.CellArrayOfBlocks)+1}=obj.FileOutBlock;
            else
                isThereAFileOutBlock=false;
                for iCounter=1:length(obj.CellArrayOfBlocks)
                    if isa(obj.CellArrayOfBlocks{iCounter},'SonnetFileOutBlock')
                        isThereAFileOutBlock=true;
                    end
                end
                if isThereAFileOutBlock == false
                    obj.CellArrayOfBlocks{length(obj.CellArrayOfBlocks)+1}=obj.FileOutBlock;
                end
            end
            
            % Construct a new file output line given the file
            aNewSizeOfTheArray=length(obj.FileOutBlock.ArrayOfFileOutputConfigurations)+1;
            obj.FileOutBlock.ArrayOfFileOutputConfigurations{aNewSizeOfTheArray}=SonnetFileOutLine();
            aEntry=obj.FileOutBlock.ArrayOfFileOutputConfigurations{aNewSizeOfTheArray};
            
            % Assign values to the properties
            aEntry.FileType='NCLINE';
            aEntry.Embed=theEmbed;
            aEntry.IncludeAbs=theIncludeAbs;
            aEntry.Filename=theFilename;
            aEntry.IsOutputHighPerformance=theIsOutputHighPerformance;
            aEntry.IncludeComments='IC';
            aEntry.ParameterType='SPECTRE';
            
            if nargin == 6
                aEntry.NetworkName=theNetwork;
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addINDModel(obj,theEmbed,theIncludeAbs,theFilename,...
                theIncludeComments,theSig,theFormat,theGen_Data,...
                theModelType,theSource,theStart,theStop)
            %addINDModel   Create a new Inductor Model output file
            %   Project.addINDModel(...) will add a inductor model output file 
            %   to the project.
            %
            %   Arguments are:
            %      1) Whether or not to use embedded data. This field is "D" 
            %           for de-embedded data or "ND" for non-de-embedded data.
            %      2) This field is "Y" to include the ABS adaptive data or "N" to
            %           include only the discrete data.
            %      3) The filename consists of a basename and extension. If the basename
            %           of the project file is used, the variable "$BASENAME" may be
            %           substituted in the filename. For example, in the project file
            %           steps.son if an output file steps.s2p is entered, the filename
            %           would appears as "$BASENAME.scs" in the fileout block. The user may
            %           enter any filename they wish and is not restricted in their
            %           use of extensions.
            %      4) This value is "IC" for include comments
            %      4) This value is “Y” if High precision is on and “N” if High Precision is not selected.
            %      5) This is the format for the BBExtract Model output file. This field is “PSPICE” for
            %           PSpice and “SPECTRE” for Spectre.
            %      6) This field indicates whether a predicted S-Parameter data file should also be
            %           generated. Set to “Y” for yes and “N” for No.
            %      7) Indicates the what type of inductor model is being generated: Untapped or Center
            %           Tapped. Set to “SKIN_EFFECT” for Untapped and “CENTER_TAP” for Center Tapped.
            %      8) Set to “AUTO” to have the software generate the band. The
            %           start and stop field do not appear for this setting. Set to “CUSTOM” to use
            %           values input by the user.
            %      9) Floating point number for the starting frequency of the bandwidth.
            %      10)Floating point number for the ending frequency of the bandwidth.   
            %
            % Check if the fileoutput block is in
            % the cell array of blocks; if not then add it
            if isempty(obj.FileOutBlock)
                obj.FileOutBlock=SonnetFileOutBlock();
                obj.CellArrayOfBlocks{length(obj.CellArrayOfBlocks)+1}=obj.FileOutBlock;
            else
                isThereAFileOutBlock=false;
                for iCounter=1:length(obj.CellArrayOfBlocks)
                    if isa(obj.CellArrayOfBlocks{iCounter},'SonnetFileOutBlock')
                        isThereAFileOutBlock=true;
                    end
                end
                if isThereAFileOutBlock == false
                    obj.CellArrayOfBlocks{length(obj.CellArrayOfBlocks)+1}=obj.FileOutBlock;
                end
            end
            
            % Construct a new file output line given the file
            aNewSizeOfTheArray=length(obj.FileOutBlock.ArrayOfFileOutputConfigurations)+1;
            obj.FileOutBlock.ArrayOfFileOutputConfigurations{aNewSizeOfTheArray}=SonnetFileOutLine();
            aEntry=obj.FileOutBlock.ArrayOfFileOutputConfigurations{aNewSizeOfTheArray};
            
            % Assign values to the properties
            aEntry.FileType='INDMODEL';
            aEntry.Embed=theEmbed;
            aEntry.IncludeAbs=theIncludeAbs;
            aEntry.Filename=theFilename;
            aEntry.IsOutputHighPerformance=theSig;
            aEntry.IncludeComments=theIncludeComments;
            aEntry.ModelType=theModelType;
            aEntry.ParameterType=theFormat;
            aEntry.ParameterForm=theGen_Data;
            
            aNewSizeOfTheArray=length(obj.FileOutBlock.ArrayOfFileOutputConfigurations)+1;
            obj.FileOutBlock.ArrayOfFileOutputConfigurations{aNewSizeOfTheArray}=SonnetFileOutLine();
            aEntry=obj.FileOutBlock.ArrayOfFileOutputConfigurations{aNewSizeOfTheArray};
            
            aEntry.FileType='FREQBAND';
            
            if ~isempty(theSource)               
                aEntry.FrequencyBand=theSource;
                if strcmpi(aEntry.FrequencyBand,'custom')==1
                    aEntry.FrequencyBand='custom';
                    aEntry.StartFreq=theStart;
                    aEntry.StopFreq=theStop;
                else
                    aEntry.FrequencyBand='auto';
                end                 
            end 
            
            aNewSizeOfTheArray=length(obj.FileOutBlock.ArrayOfFileOutputConfigurations)+1;
            obj.FileOutBlock.ArrayOfFileOutputConfigurations{aNewSizeOfTheArray}=SonnetFileOutLine();
            aEntry=obj.FileOutBlock.ArrayOfFileOutputConfigurations{aNewSizeOfTheArray};
            
            aEntry.FileType='OPTIONS';
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Unit Modification Methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeFrequencyUnit(obj,theStringForNewUnit)
            %changeFrequencyUnit   Change project's frequency unit
            %   Project.changeFrequencyUnit(string) modifies the frequency unit
            %   selected for the project. The passed frequency unit should
            %   be a unit that is supported by Sonnet. (HZ, KHZ, MHZ, GHZ, THZ, PHZ)
            %
            %   changeFrequencyUnit(unitString)     Changes the selected frequency unit
            %                                       to the passed unit identifier
            %
            %   Example usage:
            %
            %       % Change the frequency unit to 'HZ'
            %       Project.changeFrequencyUnit('HZ');
            
            obj.DimensionBlock.FrequencyUnit=theStringForNewUnit;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeInductanceUnit(obj,theStringForNewUnit)
            %changeInductanceUnit   Change project's inductance unit
            %   Project.changeInductanceUnit(string) modifies the inductance unit
            %   selected for the project. The passed inductance unit should
            %   be a unit that is supported by Sonnet. (H, MH, UH, NH, PH, FH)
            %
            %   changeInductanceUnit(unitString)     Changes the selected inductance unit
            %                                        to the passed unit identifier
            %
            %   Example usage:
            %
            %       % Change the inductance unit to 'H'
            %       Project.changeInductanceUnit('H');
            obj.DimensionBlock.InductanceUnit=theStringForNewUnit;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeLengthUnit(obj,theStringForNewUnit)
            %changeLengthUnit   Change project's length unit
            %   Project.changeLengthUnit(string) modifies the length unit
            %   selected for the project. The passed length unit should
            %   be a unit that is supported by Sonnet. (MIL, UM, MM, CM, IN, M)
            %
            %   changeLengthUnit(unitString)     Changes the selected length unit
            %                                    to the passed unit identifier
            %
            %   Example usage:
            %
            %       % Change the length unit to 'MIL'
            %       Project.changeLengthUnit('MIL');
            obj.DimensionBlock.LengthUnit=theStringForNewUnit;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeAngleUnit(obj,theStringForNewUnit)
            %changeAngleUnit   Change project's angle unit
            %   Project.changeAngleUnit(string) modifies the angle unit
            %   selected for the project. The passed angle unit should
            %   be a unit that is supported by Sonnet.
            %   (At the moment the only supported unit is DEG)
            %
            %   changeAngleUnit(unitString)     Changes the selected angle unit
            %                                   to the passed unit identifier
            %
            %   Example usage:
            %
            %       % Change the angle unit to 'DEG'
            %       Project.changeAngleUnit('DEG');
            obj.DimensionBlock.AngleUnit=theStringForNewUnit;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeConductivityUnit(obj,theStringForNewUnit)
            %changeConductivityUnit   Change project's conductivity unit
            %   Project.changeConductivityUnit(string) modifies the conductivity unit
            %   selected for the project. The passed conductivity unit should
            %   be a unit that is supported by Sonnet.
            %
            %   changeConductivityUnit(unitString)     Changes the selected conductivity
            %                                          unit to the passed unit identifier
            
            obj.DimensionBlock.ConductivityUnit=theStringForNewUnit;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeResistanceUnit(obj,theStringForNewUnit)
            %changeResistanceUnit   Change project's resistance unit
            %   Project.changeResistanceUnit(string) modifies the resistance unit
            %   selected for the project. The passed resistance unit should
            %   be a unit that is supported by Sonnet. (OH, KOH, MOH)
            %
            %   changeResistanceUnit(unitString)     Changes the selected resistance
            %                                        unit to the passed unit identifier
            %
            %   Example usage:
            %
            %       % Change the resistance unit to 'OH'
            %       Project.changeResistanceUnit('OH');
            
            obj.DimensionBlock.ResistanceUnit=theStringForNewUnit;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeCapacitanceUnit(obj,theStringForNewUnit)
            %changeCapacitanceUnit   Change project's capacitance unit
            %   Project.changeCapacitanceUnit(string) modifies the capacitance unit
            %   selected for the project. The passed capacitance unit should
            %   be a unit that is supported by Sonnet.
            %
            %   changeCapacitanceUnit(unitString)     Changes the selected capacitance
            %                                         unit to the passed unit identifier
            %   Example usage:
            %
            %       % Change the resistance unit to 'nF'
            %       Project.changeCapacitanceUnit('nF');
            
            obj.DimensionBlock.CapacitanceUnit=theStringForNewUnit;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Sonnet Box Methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function symmetryOn(obj)
            %symmetryOn   Turns symmetry on for the project
            %   Project.symmetryOn() Will turn symmetry on for
            %   the top and bottom halves of the project layout.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %       Project.symmetryOn();
            %
            %   See also SonnetProject.symmetryOff
            
            if obj.isGeometryProject
                obj.GeometryBlock.IsSymmetric='True';
            else
                error('This method is only available for Geometry projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function symmetryOff(obj)
            %symmetryOff   Turns symmetry off for the project
            %   Project.symmetryOff() Will turn symmetry off for
            %   the top and bottom halves of the project layout.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %       Project.symmetryOff();
            %
            %   See also SonnetProject.symmetryOn
            
            if obj.isGeometryProject
                obj.GeometryBlock.IsSymmetric='False';
            else
                error('This method is only available for Geometry projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aLayer=getLayer(obj,theIndex)
            %getLayer   Returns polygon in the project
            %   layer=Project.getLayer(N) will return the Nth
            %   dielectric layer in the array of
            %   dielectric layers.
            %
            %   This operation can also be achieved with
            %       layer=Project.GeometryBlock.SonnetBox.ArrayOfDielectricLayers{N};
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Get the 2nd dielectric layer in the project
            %       layer=Project.getLayer(2);
            
            if obj.isGeometryProject
                % Check if the index is outside the bounds of the array
                if theIndex<1 || theIndex>length(obj.GeometryBlock.SonnetBox.ArrayOfDielectricLayers)
                    error('Value for layer index is outside the range of layers');
                else
                    aLayer=obj.GeometryBlock.SonnetBox.ArrayOfDielectricLayers{theIndex};
                end
            else
                error('This method is only available for Geometry projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function axCellSize=xCellSize(obj)
            %xCellSize   Return cell size for X direction
            %   CellSize=Project.xCellSize() determines the width of each cell in the grid.
            %   The grid is clearly visible in the Sonnet GUI. Polygons
            %   edges are typically along grid lines.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Get the cell size in the X direction
            %       number=Project.xCellSize();
            %
            %   See also SonnetProject.yCellSize, SonnetProject.xBoxSize
            %            SonnetProject.yBoxSize
            
            if obj.isGeometryProject
                axCellSize=obj.GeometryBlock.xCellSize();
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function ayCellSize=yCellSize(obj)
            %yCellSize   Return cell size for Y direction
            %   CellSize=Project.yCellSize() determines the height of each cell in the grid.
            %   The grid is clearly visible in the Sonnet GUI. Polygons
            %   edges are typically along grid lines.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Get the cell size in the Y direction
            %       number=Project.yCellSize();
            %
            %   See also SonnetProject.xCellSize, SonnetProject.xBoxSize
            %            SonnetProject.yBoxSize
            
            if obj.isGeometryProject
                ayCellSize=obj.GeometryBlock.yCellSize();
            else
                error('This method is only available for Geometry projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aXBoxSize=xBoxSize(obj)
            %xBoxSize   Return box size for X direction
            %   BoxSize=Project.xBoxSize() returns the total width of the Sonnet box.
            %   The Sonnet box is the rectangular area that represents the
            %   boundaries for a circuit.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Get the cell size in the X direction
            %       number=Project.xBoxSize();
            %
            %   See also SonnetProject.xCellSize, SonnetProject.yCellSize
            %            SonnetProject.yBoxSize
            
            if obj.isGeometryProject
                aXBoxSize=obj.GeometryBlock.xBoxSize();
            else
                error('This method is only available for Geometry projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aYBoxSize=yBoxSize(obj)
            %yBoxSize   Return box size for Y direction
            %   BoxSize=Project.yBoxSize() returns the total height of the Sonnet box.
            %   The Sonnet box is the rectangular area that represents the
            %   boundaries for a circuit.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Get the cell size in the Y direction
            %       number=Project.yBoxSize();
            %
            %   See also SonnetProject.xCellSize, SonnetProject.yCellSize
            %            SonnetProject.YBoxSize
            
            if obj.isGeometryProject
                aYBoxSize=obj.GeometryBlock.yBoxSize();
            else
                error('This method is only available for Geometry projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function copyDielectricLayer(obj,theDielectricLayerArrayPos)
            %copyDielectricLayer    Copies a dielectric layer
            %   Project.copyDielectricLayer(N) makes a copy of the
            %   Nth dielectric layer and places it on the bottom
            %   of the stackup.
            %
            %   Note: This method is only for geometry projects.
            %
            % See also SonnetProject.replaceDielectricLayer
            
            if obj.isGeometryProject
                
                %Find the total number of layers
                theTotalNumLayers = length(obj.GeometryBlock.SonnetBox.ArrayOfDielectricLayers);
                
                %Make the new layer
                obj.GeometryBlock.SonnetBox.ArrayOfDielectricLayers{1,theTotalNumLayers+1} = SonnetGeometryBoxDielectricLayer();
                
                %Copy the names of the original properties
                theProperties = properties(obj.GeometryBlock.SonnetBox.ArrayOfDielectricLayers{1,theDielectricLayerArrayPos});
                
                %Copy all non-hidden properties
                for iCounter = 1:length(theProperties)
                    obj.GeometryBlock.SonnetBox.ArrayOfDielectricLayers{1,theTotalNumLayers+1}.(theProperties{iCounter}) = obj.GeometryBlock.SonnetBox.ArrayOfDielectricLayers{1,theDielectricLayerArrayPos}.(theProperties{iCounter});
                end
                
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function replaceDielectricLayer(obj,theArrayPosition,theNameOfDielectricLayer,theThickness,...
                theRelativeDielectricConstant,theRelativeMagneticPermeability,...
                theDielectricLossTangent,theMagneticLossTangent,theDielectricConductivity,...
                theRelativeDielectricConstantForZDirection,theRelativeMagneticPermeabilityForZDirection,...
                theDielectricLossTangentForZDirection,theMagneticLossTangentForZDirection,...
                theDielectricConductivityForZDirection)
            %replaceDielectricLayer   Replace an existing dielectric layer
            %   Project.replaceDielectricLayer(...) will replace an existing
            %   dielectric layer in the stackup.
            %
            %   There are two ways to use replaceDielectricLayer. The user
            %   may define a layer using a set of custom options or
            %   the user may define a using a predefined property set
            %   from the Sonnet library.
            %
            %   Users may use replaceDielectricLayer to replace a layer with an isotropic dielectric
            %   layer in the project using the following parameters:
            %       1)  The array position for the layer to be replaced
            %       2)  Name of the Dielectric Layer
            %       3)  Thickness of the layer
            %       4)  Relative Dielectric Constant
            %       5)  Relative Magnetic Permeability
            %       6)  Dielectric Loss Tangent
            %       7)  Magnetic Loss Tangent
            %       8)  Dielectric Conductivity
            %
            %   The user may also complete the same operation with an anisotropic
            %   layer by using the following parameters:
            %       1)  The array position for the layer to be replaced
            %       2)  Name of the Dielectric Layer
            %       3)  Thickness of the layer
            %       4)  Relative Dielectric Constant
            %       5)  Relative Magnetic Permeability
            %       6)  Dielectric Loss Tangent
            %       7)  Magnetic Loss Tangent
            %       8)  Dielectric Conductivity
            %       9)  Relative Dielectric Constant for Z Direction
            %       10)  Relative Magnetic Permeability for Z Direction
            %       11) Dielectric Loss Tangent for Z Direction
            %       12) Magnetic Loss Tangent for Z Direction
            %       13) Dielectric Conductivity for Z Direction
            %
            %   Users may replace an existing layer with one based
            %   on an entry from the Sonnet library by using the
            %   following parameters:
            %       1) The array position for the layer to be replaced
            %       2) The name of the material (Ex: "Rogers RT6006")
            %       3) Thickness of the layer
            %
            %   If no dielectric layer exists in the SonnetLibrary
            %   with the specified name then an error will be thrown.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %       % Replace the second dielectric layer with a layer which
            %       % is 10 units thick, has a relative dielectric constant
            %       % of 1, a relative magnetic permeability of 1,
            %       % a dielectric loss tangent of 0, a magnetic loss
            %       % tangent of 0, an dielectric conductivity of 0.
            %       Project.replaceDielectricLayer(2,'newLayer',10,1,1,0,0,0);
            %
            %       % Replace the third layer of the project with an anisotropic
            %       % dielectric layer. The new layer is 10 units thick, has a
            %       % relative dielectric constant of 1, a relative magnetic
            %       % permeability of 1, a dielectric loss tangent of 0, a
            %       % magnetic loss tangent of 0, an dielectric conductivity of 0.
            %       % The Z direction has a relative dielectric constant
            %       % of 1, a dielectric loss tangent of 1, a magnetic
            %       % loss tangent of 0, and an dielectric conductivity of 0.
            %       Project.replaceDielectricLayer(3,'newLayer',10,1,1,0,0,0,1,1,0,0,0);
            %
            %       % Replace the first layer's material with Rogers RT6006
            %       Project.replaceDielectricLayer(1,'Rogers RT6006',50);
            %
            % See also SonnetProject.addAnisotropicDielectricLayer
            
            if obj.isGeometryProject
                if nargin == 9
                    obj.GeometryBlock.SonnetBox.replaceIsotropicDielectricLayer(theArrayPosition,theNameOfDielectricLayer,theThickness,...
                        theRelativeDielectricConstant,theRelativeMagneticPermeability,theDielectricLossTangent,...
                        theMagneticLossTangent,theDielectricConductivity);
                elseif nargin == 14
                    obj.GeometryBlock.SonnetBox.replaceAnisotropicDielectricLayer(theArrayPosition,theNameOfDielectricLayer,theThickness,...
                        theRelativeDielectricConstant,theRelativeMagneticPermeability,theDielectricLossTangent,...
                        theMagneticLossTangent,theDielectricConductivity,theRelativeDielectricConstantForZDirection,...
                        theRelativeMagneticPermeabilityForZDirection,theDielectricLossTangentForZDirection,...
                        theMagneticLossTangentForZDirection,theDielectricConductivityForZDirection)
                elseif nargin == 4
                    obj.GeometryBlock.SonnetBox.replaceDielectricLayerUsingLibrary(theArrayPosition,theNameOfDielectricLayer,theThickness);
                end
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeDielectricLayerThickness(obj,theDielectricLayerArrayPos,theThickness)
            %changeDielectricLayerThickness   Changes layer thickness
            %   Project.changeDielectricLayerThickness(N,Thickness) will change
            %   the thickness of the Nth dielectric layer.
            %
            %   Project.changeDielectricLayerThickness(Name,Thickness) will change
            %   the thickness of the dielectric layer with the specified name.
            %   If none of the layers in the project have the specified name
            %   then an error will be thrown.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Change the thickness of the first layer
            %       % to be 50 units thick.
            %       Project.changeDielectricLayerThickness(1,50)
            %
            % See also SonnetProject.replaceDielectricLayer
            
            if obj.isGeometryProject
                
                if isa(theDielectricLayerArrayPos,'char')
                    isFound=false;
                    for iCounter=1:length(obj.GeometryBlock.SonnetBox.ArrayOfDielectricLayers)
                        aTempString=strtrim(strrep(obj.GeometryBlock.SonnetBox.ArrayOfDielectricLayers{iCounter}.NameOfDielectricLayer,'"',''));
                        if strcmp(aTempString,theDielectricLayerArrayPos)==1
                            obj.GeometryBlock.SonnetBox.ArrayOfDielectricLayers{iCounter}.Thickness = theThickness;
                            isFound=true;
                            break;
                        end
                    end
                    if ~isFound
                        error('Attempting to modify thickness of dielectric layer given an unknown name');
                    end
                else
                    if theDielectricLayerArrayPos > length(obj.GeometryBlock.SonnetBox.ArrayOfDielectricLayers)
                        error('Attempting to modify thickness of dielectric layer that is outside the range of available dielectric layers');
                    else
                        obj.GeometryBlock.SonnetBox.ArrayOfDielectricLayers{theDielectricLayerArrayPos}.Thickness = theThickness;
                    end
                end
                
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeTopCover(obj, theType)
            %changeTopCover   Changes the type for the top cover
            %   changeTopCover(Project,theType) will modify the
            %   cover to be the specified cover type. The cover
            %   type may be one of the three built in cover types
            %   that are defined for all Sonnet projects
            %   ('Lossless','Freespace','WG Load') or the name
            %   of an existing user defined metal type (the metal
            %   type must already be defined).
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Make a new Sonnet project and
            %       % make the cover be 'Freespace'
            %       theProject=SonnetProject();
            %       Project.changeTopCover('Freespace');
            %
            %       % Modify the cover to be a custom
            %       % user defined type known as 'ThinCopper'
            %       Project.changeTopCover('ThinCopper');
            %
            %   See also SonnetProject.changeBottomCover
            
            if obj.isGeometryProject
                obj.GeometryBlock.changeTopCover(theType)
            else
                error('This method is only available for Geometry projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeBottomCover(obj, theType)
            %changeBottomCover   Changes the type for the bottom cover
            %   changeBottomCover(Project,theType) will modify the
            %   cover to be the specified cover type. The cover
            %   type may be one of the three built in cover types
            %   that are defined for all Sonnet projects
            %   ('Lossless','Freespace','WG Load') or the name
            %   of an existing user defined metal type (the metal
            %   type must already be defined).
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Make a new Sonnet project and
            %       % make the cover be 'Freespace'
            %       theProject=SonnetProject();
            %       Project.changeBottomCover('Freespace');
            %
            %       % Modify the cover to be a custom
            %       % user defined type known as 'ThinCopper'
            %       Project.changeBottomCover('ThinCopper');
            %
            %   See also SonnetProject.changeTopCover
            
            if obj.isGeometryProject
                obj.GeometryBlock.changeBottomCover(theType)
            else
                error('This method is only available for Geometry projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeBoxSize(obj, theNewXWidth, theNewYWidth)
            %changeBoxSize   Changes the size of the box
            %   Project.changeBoxSize(XSize,YSize) changes the
            %   size of the Sonnet box. The Sonnet box encompasses
            %   the circuit area.  The new box width will be
            %   XSize and the new box height will be YSize.
            %
            %   Note: This function is the same as changeBoxSizeXY
            %   Note: This method is only for geometry projects.
            %
            %   See also SonnetProject.changeBoxSizeXY         SonnetProject.changeBoxSizeX
            %            SonnetProject.changeBoxSizeY          SonnetProject.changeNumberOfCells
            %            SonnetProject.changeNumberOfCellsXY   SonnetProject.changeNumberOfCellsX
            %            SonnetProject.changeNumberOfCellsY
            
            if obj.isGeometryProject
                obj.GeometryBlock.SonnetBox.changeBoxSize(theNewXWidth, theNewYWidth)
            else
                error('This method is only available for Geometry projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeBoxSizeXY(obj, theNewXWidth, theNewYWidth)
            %changeBoxSizeXY   Changes the size of the box
            %   Project.changeBoxSizeXY(XSize,YSize) changes the size of the Sonnet box.
            %   The Sonnet box encompasses the circuit area. The new box width will be
            %   XSize and the new box height will be YSize.
            %
            %   Note: This method is only for geometry projects.
            %   Note: This function is the same as changeBoxSize
            %
            %   See also SonnetProject.changeBoxSize,         SonnetProject.changeBoxSizeX,
            %            SonnetProject.changeBoxSizeY,        SonnetProject.changeNumberOfCells,
            %            SonnetProject.changeNumberOfCellsXY, SonnetProject.changeNumberOfCellsX,
            %            SonnetProject.changeNumberOfCellsY
            
            if obj.isGeometryProject
                obj.GeometryBlock.SonnetBox.changeBoxSizeXY(theNewXWidth, theNewYWidth)
            else
                error('This method is only available for Geometry projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeBoxSizeX(obj, theNewXWidth)
            %changeBoxSizeX   Changes the size of the box
            %   Project.changeBoxSizeX(XSize) changes the size of the Sonnet box
            %   in the X direction only. The Sonnet box encompasses
            %   the circuit area. The new box width will be XSize.
            %
            %   Note: This method is only for geometry projects.
            %
            %   See also SonnetProject.changeBoxSize,         SonnetProject.changeBoxSizeXY,
            %            SonnetProject.changeBoxSizeY,        SonnetProject.changeNumberOfCells,
            %            SonnetProject.changeNumberOfCellsXY, SonnetProject.changeNumberOfCellsX,
            %            SonnetProject.changeNumberOfCellsY
            
            if obj.isGeometryProject
                obj.GeometryBlock.SonnetBox.changeBoxSizeX(theNewXWidth)
            else
                error('This method is only available for Geometry projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeBoxSizeY(obj, theNewYWidth)
            %changeBoxSizeY   Changes the size of the box
            %   Project.changeBoxSizeY(YSize) changes the size of the Sonnet box
            %   in the Y direction only. The Sonnet box encompasses
            %   the circuit area. The new box height will be YSize.
            %
            %   Note: This method is only for geometry projects.
            %
            %   See also SonnetProject.changeBoxSize,         SonnetProject.changeBoxSizeXY,
            %            SonnetProject.changeBoxSizeX,        SonnetProject.changeNumberOfCells,
            %            SonnetProject.changeNumberOfCellsXY, SonnetProject.changeNumberOfCellsX,
            %            SonnetProject.changeNumberOfCellsY
            
            if obj.isGeometryProject
                obj.GeometryBlock.SonnetBox.changeBoxSizeY(theNewYWidth)
            else
                error('This method is only available for Geometry projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeNumberOfCells(obj, theNumberOfXCells, theNumberOfYCells)
            %changeNumberOfCells   Changes the number of cells
            %   Project.changeNumberOfCells(XCells,YCells) changes the number of cells
            %   that make up the grid. This function changes the
            %   number of cells in the X direction to be XCells
            %   and the number of cells in the Y direction to be YCells.
            %
            %   Note: This method is only for geometry projects.
            %   Note: This function is the same as changeNumberOfCellsXY
            %
            %   See also SonnetProject.changeBoxSize,          SonnetProject.changeBoxSizeXY,
            %            SonnetProject.changeBoxSizeX,         SonnetProject.changeBoxSizeY,
            %            SonnetProject.changeNumberOfCellsXY,  SonnetProject.changeNumberOfCellsX,
            %            SonnetProject.changeNumberOfCellsY
            
            if obj.isGeometryProject
                obj.GeometryBlock.SonnetBox.changeNumberOfCells(theNumberOfXCells, theNumberOfYCells)
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeNumberOfCellsXY(obj, theNumberOfXCells, theNumberOfYCells)
            %changeNumberOfCellsXY   Changes the number of cells
            %   Project.changeNumberOfCellsXY(XCells,YCells) changes the number of cells
            %   that make up the grid. This function changes the
            %   number of cells in the X direction to be XCells
            %   and the number of cells in the Y direction to be YCells.
            %
            %   Note: This method is only for geometry projects.
            %   Note: This function is the same as changeNumberOfCells
            %
            %   See also SonnetProject.changeBoxSize,        SonnetProject.changeBoxSizeXY,
            %            SonnetProject.changeBoxSizeX,       SonnetProject.changeBoxSizeY,
            %            SonnetProject.changeNumberOfCells,  SonnetProject.changeNumberOfCellsX,
            %            SonnetProject.changeNumberOfCellsY
            
            if obj.isGeometryProject
                obj.GeometryBlock.SonnetBox.changeNumberOfCellsXY(theNumberOfXCells, theNumberOfYCells)
            else
                error('This method is only available for Geometry projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeNumberOfCellsX(obj, theNumberOfXCells)
            %changeNumberOfCellsX   Changes the number of cells
            %   Project.changeNumberOfCellsX(XCells) changes the number of cells
            %   that make up the grid. This function modifies the
            %   number of cells in the X direction to be XCells.
            %
            %   Note: This method is only for geometry projects.
            %
            %   See also SonnetProject.changeBoxSize,        SonnetProject.changeBoxSizeXY,
            %            SonnetProject.changeBoxSizeX,       SonnetProject.changeBoxSizeY,
            %            SonnetProject.changeNumberOfCells,  SonnetProject.changeNumberOfCellsXY,
            %            SonnetProject.changeNumberOfCellsY
            
            if obj.isGeometryProject
                obj.GeometryBlock.SonnetBox.changeNumberOfCellsX(theNumberOfXCells)
            else
                error('This method is only available for Geometry projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeNumberOfCellsY(obj, theNumberOfYCells)
            %changeNumberOfCellsY   Changes the number of cells
            %   Project.changeNumberOfCellsY(YCells) changes the number of cells
            %   that make up the grid. This function modifies the
            %   number of cells in the Y direction to be YCells.
            %
            %   Note: This method is only for geometry projects.
            %
            %   See also SonnetProject.changeBoxSize,        SonnetProject.changeBoxSizeXY,
            %            SonnetProject.changeBoxSizeX,       SonnetProject.changeBoxSizeY,
            %            SonnetProject.changeNumberOfCells,  SonnetProject.changeNumberOfCellsXY,
            %            SonnetProject.changeNumberOfCellsX
            
            if obj.isGeometryProject
                obj.GeometryBlock.SonnetBox.changeNumberOfCellsY(theNumberOfYCells)
            else
                error('This method is only available for Geometry projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeCellSizeUsingNumberOfCells(obj, theXCellSize, theYCellSize)
            %changeCellSizeUsingNumberOfCells   Changes the cell size
            %   Project.changeCellSizeUsingNumberOfCells(XCellSize,YCellSize) changes the
            %   cell size used for a project. The number of cells in each direction
            %   will be modified to realize the given cell size.
            %
            %   Note: This method is only for geometry projects.
            %   Note: This function is the same as changeCellSizeUsingNumberOfCellsXY.
            %
            %   See also SonnetProject.changeBoxSize,        SonnetProject.changeBoxSizeXY,
            %            SonnetProject.changeBoxSizeX,       SonnetProject.changeBoxSizeY,
            %            SonnetProject.changeNumberOfCells,  SonnetProject.changeNumberOfCellsX,
            %            SonnetProject.changeNumberOfCellsY
            
            if obj.isGeometryProject
                obj.GeometryBlock.SonnetBox.changeCellSizeUsingNumberOfCells(theXCellSize, theYCellSize)
            else
                error('This method is only available for Geometry projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeCellSizeUsingNumberOfCellsXY(obj, theXCellSize, theYCellSize)
            %changeCellSizeUsingNumberOfCellsXY   Changes the cell size
            %   Project.changeCellSizeUsingNumberOfCellsXY(XCellSize,YCellSize) changes
            %   the cell size used for a project. The number of cells in each direction
            %   will be modified to realize the given cell size.
            %
            %   Note: This method is only for geometry projects.
            %   Note: This function is the same as changeCellSizeUsingNumberOfCells
            %
            %   See also SonnetProject.changeBoxSize,        SonnetProject.changeBoxSizeXY,
            %            SonnetProject.changeBoxSizeX,       SonnetProject.changeBoxSizeY,
            %            SonnetProject.changeNumberOfCells,  SonnetProject.changeNumberOfCellsX,
            %            SonnetProject.changeNumberOfCellsY
            
            if obj.isGeometryProject
                obj.GeometryBlock.SonnetBox.changeCellSizeUsingNumberOfCellsXY(theXCellSize, theYCellSize)
            else
                error('This method is only available for Geometry projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeCellSizeUsingNumberOfCellsX(obj, theXCellSize)
            %changeCellSizeUsingNumberOfCellsX   Changes the cell size
            %   Project.changeCellSizeUsingNumberOfCellsX(XCellSize) changes
            %   the cell size used for a project. The number of cells in the X direction
            %   will be modified to realize the given cell size.
            %
            %   Note: This method is only for geometry projects.
            %
            %   See also SonnetProject.changeBoxSize,        SonnetProject.changeBoxSizeXY,
            %            SonnetProject.changeBoxSizeX,       SonnetProject.changeBoxSizeY,
            %            SonnetProject.changeNumberOfCells,  SonnetProject.changeNumberOfCellsX,
            %            SonnetProject.changeNumberOfCellsY
            
            if obj.isGeometryProject
                obj.GeometryBlock.SonnetBox.changeCellSizeUsingNumberOfCellsX(theXCellSize)
            else
                error('This method is only available for Geometry projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeCellSizeUsingNumberOfCellsY(obj, theYCellSize)
            %changeCellSizeUsingNumberOfCellsY   Changes the cell size
            %   Project.changeCellSizeUsingNumberOfCellsY(YCellSize) changes the cell size
            %   used for a project. The number of cells in the Y direction
            %   will be modified to realize the given cell size.
            %
            %   Note: This method is only for geometry projects.
            %
            %   See also SonnetProject.changeBoxSize,        SonnetProject.changeBoxSizeXY,
            %            SonnetProject.changeBoxSizeX,       SonnetProject.changeBoxSizeY,
            %            SonnetProject.changeNumberOfCells,  SonnetProject.changeNumberOfCellsX,
            %            SonnetProject.changeNumberOfCellsY
            
            if obj.isGeometryProject
                obj.GeometryBlock.SonnetBox.changeCellSizeUsingNumberOfCellsY(theYCellSize)
            else
                error('This method is only available for Geometry projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeCellSizeUsingBoxSize(obj, theXCellSize, theYCellSize)
            %changeCellSizeUsingBoxSize   Changes the cell size
            %   Project.changeCellSizeUsingBoxSize(XCellSize,YCellSize) changes
            %   the cell size used for a project. The size of the box in each
            %   direction will be modified to realize the given
            %   cell size.
            %
            %   Note: This method is only for geometry projects.
            %   Note: This function is the same as changeCellSizeUsingBoxSizeXY
            %
            %   See also SonnetProject.changeBoxSize,        SonnetProject.changeBoxSizeXY,
            %            SonnetProject.changeBoxSizeX,       SonnetProject.changeBoxSizeY,
            %            SonnetProject.changeNumberOfCells,  SonnetProject.changeNumberOfCellsX,
            %            SonnetProject.changeNumberOfCellsY
            
            if obj.isGeometryProject
                obj.GeometryBlock.SonnetBox.changeCellSizeUsingBoxSize(theXCellSize, theYCellSize)
            else
                error('This method is only available for Geometry projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeCellSizeUsingBoxSizeXY(obj, theXCellSize, theYCellSize)
            %changeCellSizeUsingBoxSizeXY   Changes the cell size
            %   Project.changeCellSizeUsingBoxSizeXY(XCellSize,YCellSize) changes the cell size
            %   used for a project. The size of the box in each
            %   direction will be modified to realize the given
            %   cell size.
            %
            %   Note: This method is only for geometry projects.
            %   Note: This function is the same as changeCellSizeUsingBoxSize
            %
            %   See also SonnetProject.changeBoxSize,        SonnetProject.changeBoxSizeXY,
            %            SonnetProject.changeBoxSizeX,       SonnetProject.changeBoxSizeY,
            %            SonnetProject.changeNumberOfCells,  SonnetProject.changeNumberOfCellsX,
            %            SonnetProject.changeNumberOfCellsY
            
            if obj.isGeometryProject
                obj.GeometryBlock.SonnetBox.changeCellSizeUsingBoxSizeXY(theXCellSize, theYCellSize)
            else
                error('This method is only available for Geometry projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeCellSizeUsingBoxSizeX(obj, theXCellSize)
            %changeCellSizeUsingBoxSizeX   Changes the cell size
            %   Project.changeCellSizeUsingBoxSizeX(XCellSize) changes the cell size
            %   used for a project. The box size in the X direction
            %   will be modified to realize the given cell size.
            %
            %   Note: This method is only for geometry projects.
            %
            %   See also SonnetProject.changeBoxSize,        SonnetProject.changeBoxSizeXY,
            %            SonnetProject.changeBoxSizeX,       SonnetProject.changeBoxSizeY,
            %            SonnetProject.changeNumberOfCells,  SonnetProject.changeNumberOfCellsX,
            %            SonnetProject.changeNumberOfCellsY
            
            if obj.isGeometryProject
                obj.GeometryBlock.SonnetBox.changeCellSizeUsingBoxSizeX(theXCellSize)
            else
                error('This method is only available for Geometry projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeCellSizeUsingBoxSizeY(obj, theYCellSize)
            %changeCellSizeUsingBoxSizeY   Changes the cell size
            %   Project.changeCellSizeUsingBoxSizeY(YCellSize) changes the cell size
            %   used for a project. The box size in the Y direction
            %   will be modified to realize the given cell size.
            %
            %   Note: This method is only for geometry projects.
            %
            %   See also SonnetProject.changeBoxSize,        SonnetProject.changeBoxSizeXY,
            %            SonnetProject.changeBoxSizeX,       SonnetProject.changeBoxSizeY,
            %            SonnetProject.changeNumberOfCells,  SonnetProject.changeNumberOfCellsX,
            %            SonnetProject.changeNumberOfCellsY
            
            if obj.isGeometryProject
                obj.GeometryBlock.SonnetBox.changeCellSizeUsingBoxSizeY(theYCellSize)
            else
                error('This method is only available for Geometry projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addDielectricLayer(obj,theNameOfDielectricLayer,theThickness,...
                theRelativeDielectricConstant,theRelativeMagneticPermeability,...
                theDielectricLossTangent,theMagneticLossTangent,...
                theDielectricConductivity,theNumberOfZPartitions)
            %addDielectricLayer   Add a dielectric layer to the project
            %   Project.addDielectricLayer(...) will add a dielectric layer
            %   to the top of the stackup (the end of the array of dielectric
            %   layers).
            %
            %   There are two ways to use addDielectricLayer. The user
            %   may define a layer using a set of custom options or
            %   the user may define a using a predefined property set
            %   from the Sonnet library.
            %
            %   Users may use addDielectricLayer to add a custom dielectric
            %   layer to the project using the following parameters:
            %       1)  Name of the Dielectric Layer
            %       2)  Thickness of the layer
            %       3)  Relative Dielectric Constant
            %       4)  Relative Magnetic Permeability
            %       5)  Dielectric Loss Tangent
            %       6)  Magnetic Loss Tangent
            %       7)  Dielectric Conductivity
            %       8)  Number of Z-Partitions (Optional)
            %
            %   Users may add a layer based on an entry from the Sonnet
            %   library by using the following parameters:
            %       1) The name of the material (Ex: "Rogers RT6006")
            %       2) Thickness of the layer
            %
            %   If no dielectric layer exists in the SonnetLibrary
            %   with the specified name then an error will be thrown.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %       % Add a new dielectric layer to the project. The layer
            %       % is 10 units thick, has a relative dielectric constant
            %       % of 1, a relative magnetic permeability of 1,
            %       % a dielectric loss tangent of 0, a magnetic loss
            %       % tangent of 0, an dielectric conductivity of 0.
            %       Project.addDielectricLayer('newLayer',10,1,1,0,0,0);
            %
            %       % This layer is the same as the one above but
            %       % it specifies that there are 2 Z-partitions.
            %       Project.addDielectricLayer('newLayer2',10,1,1,0,0,0,2);
            %
            %       % This layer uses Rogers RT6006
            %       Project.addDielectricLayer('Rogers RT6006',50);
            %
            % See also SonnetProject.addAnisotropicDielectricLayer
            
            if obj.isGeometryProject
                if nargin == 8
                    obj.GeometryBlock.SonnetBox.addDielectricLayer(theNameOfDielectricLayer,theThickness,...
                        theRelativeDielectricConstant,theRelativeMagneticPermeability,theDielectricLossTangent,...
                        theMagneticLossTangent,theDielectricConductivity);
                elseif nargin == 9
                    obj.GeometryBlock.SonnetBox.addDielectricLayer(theNameOfDielectricLayer,theThickness,...
                        theRelativeDielectricConstant,theRelativeMagneticPermeability,theDielectricLossTangent,...
                        theMagneticLossTangent,theDielectricConductivity,theNumberOfZPartitions);
                elseif nargin == 3
                    obj.GeometryBlock.SonnetBox.addDielectricLayerUsingLibary(theNameOfDielectricLayer,theThickness);
                end
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addAnisotropicDielectricLayer(obj,theNameOfDielectricLayer,theThickness,...
                theRelativeDielectricConstant,theRelativeMagneticPermeability,...
                theDielectricLossTangent,theMagneticLossTangent,theDielectricConductivity,...
                theRelativeDielectricConstantForZDirection,theRelativeMagneticPermeabilityForZDirection,...
                theDielectricLossTangentForZDirection,theMagneticLossTangentForZDirection,...
                theDielectricConductivityForZDirection,theNumberOfZPartitions)
            %addAnisotropicDielectricLayer   Add an anisotropic dielectric layer to the project
            %   Project.addAnisotropicDielectricLayer(...) will add a dielectric
            %   layer to the top of the project.
            %
            %   If the layer is anisotropic then it requires the
            %   following arguments:
            %
            %       1)  Name of the Dielectric Layer
            %       2)  Thickness of the layer
            %       3)  Relative Dielectric Constant
            %       4)  Relative Magnetic Permeability
            %       5)  Dielectric Loss Tangent
            %       6)  Magnetic Loss Tangent
            %       7)  Dielectric Conductivity
            %       8)  Relative Dielectric Constant for Z Direction
            %       9)  Relative Magnetic Permeability for Z Direction
            %       10) Dielectric Loss Tangent for Z Direction
            %       11) Magnetic Loss Tangent for Z Direction
            %       12) Dielectric Conductivity for Z Direction
            %       13) Number of Z-Partitions (Optional)
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %       % Add a new dielectric layer to the project. The layer
            %       % is 10 units thick, has a relative dielectric constant
            %       % of 1, a relative magnetic permeability of 1,
            %       % a dielectric loss tangent of 0, a magnetic loss
            %       % tangent of 0, a dielectric conductivity of 0.
            %       % The Z direction has a relative dielectric constant
            %       % of 1, a dielectric loss tangent of 1, a magnetic
            %       % loss tangent of 0, and an dielectric conductivity of 0.
            %       Project.addAnisotropicDielectricLayer('newLayer',10,1,1,0,0,0,1,1,0,0,0);
            %
            % See also SonnetProject.addDielectricLayer
            
            if obj.isGeometryProject
                if nargin == 13
                    obj.GeometryBlock.SonnetBox.addAnisotropicDielectricLayer(theNameOfDielectricLayer,theThickness,...
                        theRelativeDielectricConstant,theRelativeMagneticPermeability,theDielectricLossTangent,theMagneticLossTangent,...
                        theDielectricConductivity,theRelativeDielectricConstantForZDirection,theRelativeMagneticPermeabilityForZDirection,...
                        theDielectricLossTangentForZDirection,theMagneticLossTangentForZDirection,theDielectricConductivityForZDirection);
                elseif nargin == 14
                    obj.GeometryBlock.SonnetBox.addAnisotropicDielectricLayer(theNameOfDielectricLayer,theThickness,...
                        theRelativeDielectricConstant,theRelativeMagneticPermeability,theDielectricLossTangent,theMagneticLossTangent,...
                        theDielectricConductivity,theRelativeDielectricConstantForZDirection,theRelativeMagneticPermeabilityForZDirection,...
                        theDielectricLossTangentForZDirection,theMagneticLossTangentForZDirection,theDielectricConductivityForZDirection,...
                        theNumberOfZPartitions);
                end
                
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function deleteLayer(obj,theIndex)
            %deleteLayer   Deletes a layer from the project
            %   Project.deleteLayer(N) will delete the Nth
            %   dielectric layer from the array of
            %   dielectric layers.
            %
            %   This operation can also be achieved with
            %   Project.GeometryBlock.SonnetBox.ArrayOfDielectricLayers(N)=[];
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Delete the 2nd layer in the array of layers
            %       Project.deletePolygon(5);
            
            if obj.isGeometryProject
                % Check if the index is outside the bounds of the array
                if theIndex<1 || theIndex>length(obj.GeometryBlock.SonnetBox.ArrayOfDielectricLayers)
                    error('Value for layer index is outside the range of layers');
                else
                    obj.GeometryBlock.SonnetBox.ArrayOfDielectricLayers(theIndex)=[];
                end
            else
                error('This method is only available for Geometry projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Netlist Methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addResistorElement(obj,theNodeNumber1,theNodeNumber2,theResistanceValue,theNetworkNumber)
            %addResistorElement   Creates a resistor element
            %   Project.addResistorElement(Node1,Node2,Resistance) will add
            %   an resistor element to the circuit between Node1 and Node2 with
            %   the specified resistance. If the second node of the resistor
            %   should not be attached to any node then Node2 should be [].
            %
            %   Project.addResistorElement(Node1,Node2,Resistance,Network) will add
            %   an resistor element to the specified network of the circuit between
            %   Node1 and Node2 with the specified resistance. If the second node
            %   of the resistor should not be attached to any node then Node2 should
            %   be []. The network selection may be the network's index or the
            %   network's name.
            %
            %   Note: This method is only for netlist projects.
            %
            %   Example usage:
            %
            %       % Add a resistor element to the first network
            %       % in the project. The resistor is connected
            %       % from node 1 to 2 with resistance of 50
            %       Project.addResistorElement(1,2,50);
            %
            %       % Add a resistor element to the second network
            %       % in the project. The resistor is connected
            %       % from node 1 to 2 with resistance of 50
            %       Project.addResistorElement(1,2,50,2);
            %
            %   See also SonnetProject.addInductorElement,
            %            SonnetProject.addCapacitorElement,
            %            SonnetProject.addTransmissionLineElement,
            %            SonnetProject.addPhysicalTransmissionLineElement,
            %            SonnetProject.addDataResponseFileElement,
            %            SonnetProject.addProjectFileElement,
            %            SonnetProject.addNetworkElement
            
            if obj.isNetlistProject
                if nargin == 5
                    obj.CircuitElementsBlock.addResistorElement(theNodeNumber1,theNodeNumber2,theResistanceValue,theNetworkNumber);
                else
                    obj.CircuitElementsBlock.addResistorElement(theNodeNumber1,theNodeNumber2,theResistanceValue);
                end
                
            else
                error('This method is only available for Netlist projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addInductorElement(obj,theNodeNumber1,theNodeNumber2,theInductanceValue,theNetworkNumber)
            %addInductorElement   Creates a inductor element
            %   Project.addInductorElement(Node1,Node2,Inductance) will add
            %   an inductor element to the circuit between Node1 and Node2 with
            %   the specified inductance. If the second node of the inductor
            %   should not be attached to any node then Node2 should be [].
            %
            %   Project.addInductorElement(Node1,Node2,Inductance,Network) will add
            %   an inductor element to the specified network of the circuit between
            %   Node1 and Node2 with the specified inductance. If the second node
            %   of the inductor should not be attached to any node then Node2 should
            %   be []. The network selection may be the network's index or the
            %   network's name.
            %
            %   Note: This method is only for netlist projects.
            %
            %   Example usage:
            %
            %       % Add a inductor element to the first network
            %       % in the project. The inductor is connected
            %       % from node 1 to 2 with inductance of 50
            %       Project.addInductorElement(1,2,50);
            %
            %       % Add a inductor element to the second network
            %       % in the project. The inductor is connected
            %       % from node 1 to 2 with inductance of 50
            %       Project.addInductorElement(1,2,50,2);
            %
            %   See also SonnetProject.addResistorElement,
            %            SonnetProject.addCapacitorElement,
            %            SonnetProject.addTransmissionLineElement,
            %            SonnetProject.addPhysicalTransmissionLineElement,
            %            SonnetProject.addDataResponseFileElement,
            %            SonnetProject.addProjectFileElement,
            %            SonnetProject.addNetworkElement
            
            if obj.isNetlistProject
                if nargin == 5
                    obj.CircuitElementsBlock.addInductorElement(theNodeNumber1,theNodeNumber2,theInductanceValue,theNetworkNumber);
                else
                    obj.CircuitElementsBlock.addInductorElement(theNodeNumber1,theNodeNumber2,theInductanceValue);
                end
            else
                error('This method is only available for Netlist projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addCapacitorElement(obj,theNodeNumber1,theNodeNumber2,theCapacitanceValue,theNetworkNumber)
            %addCapacitorElement   Creates a capacitor element
            %   Project.addCapacitorElement(Node1,Node2,Capacitance) will add
            %   an capacitor element to the circuit between Node1 and Node2 with
            %   the specified capacitance. If the second node of the capacitor
            %   should not be attached to any node then Node2 should be [].
            %
            %   Project.addCapacitorElement(Node1,Node2,Capacitance,Network) will add
            %   an capacitor element to the specified network of the circuit between
            %   Node1 and Node2 with the specified capacitance. If the second node
            %   of the capacitor should not be attached to any node then Node2 should
            %   be []. The network selection may be the network's index or the
            %   network's name.
            %
            %   Note: This method is only for netlist projects.
            %
            %   Example usage:
            %
            %       % Add a capacitor element to the first network
            %       % in the project. The capacitor is connected
            %       % from node 1 to 2 with capacitance of 50
            %       Project.addCapacitorElement(1,2,50);
            %
            %       % Add a capacitor element to the second network
            %       % in the project. The capacitor is connected
            %       % from node 1 to 2 with capacitance of 50
            %       Project.addCapacitorElement(1,2,50,2);
            %
            %   See also SonnetProject.addResistorElement,
            %            SonnetProject.addInductorElement,
            %            SonnetProject.addTransmissionLineElement,
            %            SonnetProject.addPhysicalTransmissionLineElement,
            %            SonnetProject.addDataResponseFileElement,
            %            SonnetProject.addProjectFileElement,
            %            SonnetProject.addNetworkElement
            
            if obj.isNetlistProject
                if nargin == 5
                    obj.CircuitElementsBlock.addCapacitorElement(theNodeNumber1,theNodeNumber2,theCapacitanceValue,theNetworkNumber);
                else
                    obj.CircuitElementsBlock.addCapacitorElement(theNodeNumber1,theNodeNumber2,theCapacitanceValue);
                end
            else
                error('This method is only available for Netlist projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addTransmissionLineElement(obj,theNodeNumber1,theNodeNumber2,theImpedanceValue,...
                theLengthValue,theFrequencyValue,theNetworkNumber)
            %addTransmissionLineElement   Creates a transmission line element
            %   Project.addTransmissionLineElement(...) will add an transmission line to the circuit
            %
            %   Project.addTransmissionLineElement(Node1,Node2,Impedance,Length,Frequency)
            %   will add a transmission line element to the circuit between Node1
            %   and Node2 with the specified impedance, length and frequency of operation.
            %   If the second node of the capacitor should not be attached to any node
            %   then Node2 should be [].
            %
            %   Project.addTransmissionLineElement(Node1,Node2,Impedance,Length,Frequency,Network)
            %   will add a transmission line element to the circuit between Node1
            %   and Node2 with the specified impedance, length and frequency of operation.
            %   If the second node of the capacitor should not be attached to any node
            %   then Node2 should be []. The network selection may be the network's index
            %   or the network's name.
            %
            %   Note: This method is only for netlist projects.
            %
            %   Example usage:
            %
            %       % Add a transmission line element to
            %       % the first network of the project
            %       % connected from node 1 to 2 with
            %       % an impedance of 100, an electrical
            %       % length of 1000 and a frequency of 10.
            %       Project.addTransmissionLineElement(1,2,100,1000,10);
            %
            %       % Add a transmission line element to
            %       % the second network of the project
            %       % connected from node 1 to 2 with
            %       % an impedance of 100, an electrical
            %       % length of 1000 and a frequency of 10.
            %       Project.addTransmissionLineElement(1,2,100,1000,10,2);
            %
            %   See also SonnetProject.addResistorElement,
            %            SonnetProject.addInductorElement,
            %            SonnetProject.addCapacitorElement,
            %            SonnetProject.addPhysicalTransmissionLineElement,
            %            SonnetProject.addDataResponseFileElement,
            %            SonnetProject.addProjectFileElement,
            %            SonnetProject.addNetworkElement
            
            if obj.isNetlistProject
                if nargin == 7
                    obj.CircuitElementsBlock.addTransmissionLineElement(theNodeNumber1,theNodeNumber2,...
                        theImpedanceValue,theLengthValue,theFrequencyValue,theNetworkNumber);
                else
                    obj.CircuitElementsBlock.addTransmissionLineElement(theNodeNumber1,theNodeNumber2,...
                        theImpedanceValue,theLengthValue,theFrequencyValue);
                end
            else
                error('This method is only available for Netlist projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addPhysicalTransmissionLineElement(obj,theNodeNumber1,theNodeNumber2,theImpedanceValue,...
                theLengthValue,theFrequencyValue,theEeffValue,theAttentuationValue,theNetworkNumber,theGroundNode)
            %addPhysicalTransmissionLineElement   Creates a physical transmission line element
            %   Project.addPhysicalTransmissionLineElement(...) will add an physical
            %   transmission line element to the circuit.
            %
            %   addPhysicalTransmissionLineElement takes the following parameters:
            %     1) The first node number to which the line is connected to
            %     2) The second node number to which the line is connected to
            %         (If the element is not to be connected to another node
            %          then pass [] as for the value for the second node number)
            %     3) The value for the impedance of the line
            %     4) The value for the length of the line
            %     5) The value for the frequency of the line
            %     6) The value for the eeff of the line
            %     7) The value for the attenuation of the line
            %     8) (Optional) The index of the network in the array of networks
            %        If this is not specified the element will be added to the
            %        first network.
            %     9) (Optional) The node number that acts as ground for the line.
            %        In order to specify a ground node the user must specify
            %        the network (argument number 8 must be included in order to
            %        specify argument number 9)
            %
            %   Note: This method is only for netlist projects.
            %
            %   Example usage:
            %
            %       % Add a physical transmission line element to the first
            %       % network of the project. The transmission line will be
            %       % connected from node 1 to 2 with an impedance of 100,
            %       % a length of 1000, a frequency of 10, an eeff of 1,
            %       % and an attenuation of 10.
            %       Project.addPhysicalTransmissionLineElement(1,2,100,1000,10,1,10);
            %
            %       % Add a physical transmission line element to the second
            %       % network of the project. The transmission line will be
            %       % connected from node 1 to 2 with an impedance of 100,
            %       % a length of 1000, a frequency of 10, an eeff of 1,
            %       % and an attenuation of 10.
            %       Project.addPhysicalTransmissionLineElement(1,2,100,1000,10,1,10,2);
            %
            %       % Add a physical transmission line element to the second
            %       % network of the project. The transmission line will be
            %       % connected from node 1 to 2 with an impedance of 100,
            %       % a length of 1000, a frequency of 10, an eeff of 1,
            %       % and an attenuation of 10. The transmission line will
            %       % grounded at port 1.
            %       Project.addPhysicalTransmissionLineElement(1,2,100,1000,10,1,10,2,1);
            %
            %   See also SonnetProject.addResistorElement,
            %            SonnetProject.addInductorElement,
            %            SonnetProject.addCapacitorElement,
            %            SonnetProject.addTransmissionLineElement,
            %            SonnetProject.addDataResponseFileElement,
            %            SonnetProject.addProjectFileElement,
            %            SonnetProject.addNetworkElement
            
            if obj.isNetlistProject
                if nargin == 8
                    obj.CircuitElementsBlock.addPhysicalTransmissionLineElement(theNodeNumber1,theNodeNumber2,...
                        theImpedanceValue,theLengthValue,theFrequencyValue,theEeffValue,theAttentuationValue);
                elseif nargin == 9
                    obj.CircuitElementsBlock.addPhysicalTransmissionLineElement(theNodeNumber1,theNodeNumber2,...
                        theImpedanceValue,theLengthValue,theFrequencyValue,theEeffValue,theAttentuationValue,theNetworkNumber);
                elseif nargin == 10
                    obj.CircuitElementsBlock.addPhysicalTransmissionLineElement(theNodeNumber1,theNodeNumber2,...
                        theImpedanceValue,theLengthValue,theFrequencyValue,theEeffValue,theAttentuationValue,theNetworkNumber,theGroundNode);
                end
            else
                error('This method is only available for Netlist projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addDataResponseFileElement(obj,theFilename,theArrayOfPortNodeNumbers,theNetworkNumber,theGroundReference)
            %addDataResponseFileElement   Creates a data response file element
            %   Project.addDataResponseFileElement(Filename,PortNodes) will
            %   add a SnP file to the circuit connected to the ports
            %   specified by PortNodes.
            %
            %   Project.addDataResponseFileElement(Filename,PortNodes,Network) will
            %   add a SnP file to the circuit connected to the ports specified
            %   by PortNodes. The network selection may be the network's index
            %   or the network's name.
            %
            %   Project.addDataResponseFileElement(Filename,PortNodes,Network,GroundNode)
            %   will add a SnP file to the circuit connected to the ports specified
            %   by PortNodes and grounded at the specified ground node number. The
            %   network selection may be the network's index or the network's name.
            %
            %   Note: This method is only for netlist projects.
            %
            %   Example usage:
            %
            %       % Add a data response file element to the first network of the project
            %       Project.addDataResponseFileElement('data.s2p',[1,2]);
            %
            %       % Add a data response file element to the second network of the project
            %       Project.addDataResponseFileElement('data.s2p',[1,2],2);
            %
            %       % Add a data response file element to the second network of the project
            %       % and has its ground reference node connected to node 1.
            %       Project.addDataResponseFileElement('data.s2p',[1,2],2,1);
            %
            %   See also SonnetProject.addResistorElement,
            %            SonnetProject.addInductorElement,
            %            SonnetProject.addCapacitorElement,
            %            SonnetProject.addTransmissionLineElement,
            %            SonnetProject.addPhysicalTransmissionLineElement,
            %            SonnetProject.addProjectFileElement,
            %            SonnetProject.addNetworkElement
            
            if obj.isNetlistProject
                if nargin == 3
                    obj.CircuitElementsBlock.addDataResponseFileElement(theFilename,theArrayOfPortNodeNumbers);
                elseif nargin == 4
                    obj.CircuitElementsBlock.addDataResponseFileElement(theFilename,theArrayOfPortNodeNumbers,theNetworkNumber);
                elseif nargin == 5
                    obj.CircuitElementsBlock.addDataResponseFileElement(theFilename,theArrayOfPortNodeNumbers,theNetworkNumber,theGroundReference);
                end
            else
                error('This method is only available for Netlist projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addProjectFileElement(obj,theFilename,theArrayOfPortNodeNumbers,theUseSweepFromSubproject,theNetworkNumber)
            %addProjectFileElement   Creates a project file element
            %   Project.addProjectFileElement(File,PortNodes,SweepFromSubproject)
            %   Will add an project file to the circuit connected to the ports
            %   specified by PortNodes. SweepFromSubproject should be either 0 or 1.
            %   0 to indicate that you use the sweep from this project or 1 to
            %   indicate that you use the sweep from the subproject.
            %
            %   Project.addProjectFileElement(File,PortNodes,SweepFromSubproject,Network)
            %   Will add an project file to the circuit connected to the ports
            %   specified by PortNodes. SweepFromSubproject should be either 0 or 1.
            %   0 to indicate that you use the sweep from this project or 1 to
            %   indicate that you use the sweep from the subproject. The network
            %   selection may be the network's index or the network's name.
            %
            %   Note: This method is only for netlist projects.
            %
            %   Example usage:
            %
            %       % Add a project file element to the first network of the project
            %       Project.addProjectFileElement('projectFile.son',[1,2],0);
            %
            %       % Add a project file element to the second network of the project
            %       Project.addProjectFileElement('projectFile.son',[1,2],0,2);
            %
            %   See also SonnetProject.addResistorElement,
            %            SonnetProject.addInductorElement,
            %            SonnetProject.addCapacitorElement,
            %            SonnetProject.addTransmissionLineElement,
            %            SonnetProject.addPhysicalTransmissionLineElement,
            %            SonnetProject.addDataResponseFileElement,
            %            SonnetProject.addNetworkElement
            
            if obj.isNetlistProject
                if nargin == 5
                    obj.CircuitElementsBlock.addProjectFileElement(theFilename,theArrayOfPortNodeNumbers,theUseSweepFromSubproject,theNetworkNumber);
                elseif nargin == 4
                    obj.CircuitElementsBlock.addProjectFileElement(theFilename,theArrayOfPortNodeNumbers,theUseSweepFromSubproject);
                else
                    error('Invalid number of arguments');
                end
            else
                error('This method is only available for Netlist projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addNetworkElement(obj,theName,theArrayOfPortNodeNumbers,theargument3, theargument4)
            %addNetworkElement   Creates a network element
            %   Project.addNetworkElement(...) will add an network element to the circuit
            %
            %       addNetworkElement takes the following parameters:
            %
            %               1) The name for the new network
            %               2) The vector of port numbers
            %
            %       And then also include one of the following:
            %
            %        * If you want to define a single real impedance for all the ports then:
            %               3) the impedance
            %
            %        * If you want to define a single non-real impedance for all the ports then:
            %               3) the real component of the impedance
            %               4) the imaginary component of the impedance
            %
            %        * If you want to define different resistances and reactances for each port
            %          then pass the following for an N dimensional network:
            %               3) An  N x 2  matrix with the first column being the
            %               resistance of the port and the second number
            %               being the reactance of the port. Each row in
            %               the matrix should correspond to a single port
            %               and be specified in the same order as was
            %               specified in the second argument which was
            %               an vector of port numbers.
            %
            %        * If a port or ports in the circuit have non-zero values for either the
            %          inductance or capacitance then pass the following:
            %               3) An  N x 4  matrix with the first column being the
            %               resistance of the port, the second number
            %               being the reactance of the port, the third column
            %               is for the inductance of the port and the fourth
            %               is for the capacitance of the port. Each row in
            %               the matrix should correspond to a single port
            %               and be specified in the same order as was
            %               specified in the second argument which was
            %               an vector of port numbers.
            %
            %   Note: This method is only for netlist projects.
            %
            %   Example usage:
            %
            %       % Add a new network to the project. All ports will
            %       % have a real impedance of 50.
            %       Project.addNetworkElement('NetName1',[1 2 3 4],50);
            %
            %       % Add a new network to the project. All ports will
            %       % have a real impedance of 50 and an imaginary component
            %       % of 50.
            %       Project.addNetworkElement('NetName2',[1 2 3 4],50,50);
            %
            %       % Add a new network to the project. All ports will
            %       % have a differing resistances and reactances.
            %       Project.addNetworkElement('NetName3',[1 2 3 4],[50 50; 100 100]);
            %
            %       % Add a new network to the project. All ports will
            %       % have a differing resistances, reactances,
            %       % inductances, and capacitances.
            %       Project.addNetworkElement('NetName4',[1 2 3 4],[50 50 10 10; 100 100 10 10]);
            %
            %   See also SonnetProject.addResistorElement,
            %            SonnetProject.addInductorElement,
            %            SonnetProject.addCapacitorElement,
            %            SonnetProject.addTransmissionLineElement,
            %            SonnetProject.addPhysicalTransmissionLineElement,
            %            SonnetProject.addDataResponseFileElement,
            %            SonnetProject.addProjectFileElement
            
            if obj.isNetlistProject
                if nargin == 5
                    obj.CircuitElementsBlock.addNetworkElement(theName,theArrayOfPortNodeNumbers,theargument3, theargument4);
                elseif nargin == 4
                    obj.CircuitElementsBlock.addNetworkElement(theName,theArrayOfPortNodeNumbers,theargument3);
                else
                    error('Invalid number of arguments');
                end
            else
                error('This method is only available for Netlist projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aNetwork=getNetworkElements(obj,theNetwork)
            %getNetworkElements   Returns network in a project
            %   aNetwork=Project.getNetworkElements(N) will return a cell
            %   array of all the circuit elements in the
            %   Nth network of a netlist.
            %
            %   Note: This method is only for netlist projects.
            %
            %   Example usage:
            %
            %       % Get the 5th network in a netlist
            %       network=Project.getNetworkElements(5);
            
            if obj.isNetlistProject
                aNetwork=obj.CircuitElementsBlock.getNetworkElements(theNetwork);
            else
                error('This method is only available for Netlist projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function setNetworkPorts(obj,theFirstArgument,theSecondArgument)
            %setNetworkPorts   Sets the ports for a network
            %   Project.setNetworkPorts(N,[1 2 3 ...]) will modify the
            %   ports for the Nth network in the project to be the
            %   numbers specified in the second argument.
            %
            %   Project.setNetworkPorts([1 2 3 ...]) will modify the
            %   ports for the last network in the project to be the
            %   numbers specified in the second argument. The last
            %   network in a project is the main network and
            %   specifies the external ports.
            %
            %   Note: This method is only for netlist projects.
            %
            %   Example usage:
            %
            %       % Modify the ports for the fifth
            %       % network to be one through five.
            %       Project.setNetworkPorts(5,[1 2 3 4 5]);
            %
            %       % Modify the ports for the last
            %       % network to be one through ten.
            %       Project.setNetworkPorts(1:10);
            
            if obj.isNetlistProject
                if nargin == 2
                    aNumberOfNetworksInTheProject=length(obj.CircuitElementsBlock.ArrayOfNetworkElements);
                    aNetwork=obj.CircuitElementsBlock.ArrayOfNetworkElements{aNumberOfNetworksInTheProject};
                    aNetwork.ArrayOfPortNodeNumbers=theFirstArgument;
                elseif nargin == 3
                    aNetwork=obj.CircuitElementsBlock.ArrayOfNetworkElements{theFirstArgument};
                    aNetwork.ArrayOfPortNodeNumbers=theSecondArgument;
                else
                    error('Improper number of arguments');
                end
            else
                error('This method is only available for Netlist projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function deleteNetworkElement(obj,theHandleOrNameOrIndex)
            %deleteNetworkElement   Delete a network element
            %   Project.deleteNetworkElement(N) will delete 
            %   the Nth network.
            %
            %   Project.deleteNetworkElement(aNetwork) will delete
            %   the passed network element from the project.
            %
            %   Project.deleteNetworkElement(aNetworkName) will 
            %   delete the network element in the project with
            %   the matching name.
            %
            %   Note: This method is only for netlist projects.
            
            if obj.isNetlistProject
                if isa(theHandleOrNameOrIndex,'double')
                    obj.CircuitElementsBlock.ArrayOfNetworkElements(theHandleOrNameOrIndex)=[];
                elseif isa(theHandleOrNameOrIndex,'char')
                    for iCounter=1:length(obj.CircuitElementsBlock.ArrayOfNetworkElements)
                        if strcmpi(obj.CircuitElementsBlock.ArrayOfNetworkElements{iCounter}.Name,theHandleOrNameOrIndex)==1
                            obj.CircuitElementsBlock.ArrayOfNetworkElements(iCounter)=[];
                            return
                        end
                        error('Specified element not found in project');
                    end
                else
                    for iCounter=1:length(obj.CircuitElementsBlock.ArrayOfNetworkElements)
                        if obj.CircuitElementsBlock.ArrayOfNetworkElements{iCounter}==theHandleOrNameOrIndex
                            obj.CircuitElementsBlock.ArrayOfNetworkElements(iCounter)=[];
                            return
                        end
                        error('Specified element not found in project');
                    end
                end
            else
                error('This method is only available for Netlist projects');
            end
        end
                
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function deleteAllElements(obj)
            %deleteAllElements   Delete all circuit elements
            %   Project.deleteAllElements() will delete 
            %   all circuit elements from the project.
            %
            %   Note: This method is only for netlist projects.
            
            if obj.isNetlistProject
                obj.CircuitElementsBlock.ArrayOfResistorElements={};
                obj.CircuitElementsBlock.ArrayOfInductorElements={};
                obj.CircuitElementsBlock.ArrayOfCapacitorElements={};
                obj.CircuitElementsBlock.ArrayOfTransmissionLineElements={};
                obj.CircuitElementsBlock.ArrayOfPhysicalTransmissionLineElements={};
                obj.CircuitElementsBlock.ArrayOfDataResponseFileElements={};
                obj.CircuitElementsBlock.ArrayOfProjectFileElements={};
                obj.CircuitElementsBlock.ArrayOfNetworkElements={};
            else
                error('This method is only available for Netlist projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addRLGCElement(obj, theDatFileName, theLength, theArrayOfPortNodes)
            % addRLGCElement Creates a RLGC Element in the Circuit Block
            
            if obj.isNetlistProject
                if nargin == 4
                    obj.CircuitElementsBlock.addRLGCElement(theDatFileName, theLength, theArrayOfPortNodes);
                else
                    error('Invalid number or arguments. 3 expected.');
                end
            else
                error('This method is only available for Netlist projects');
            end                           
        end
            
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Component Methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aReference = addResistorComponent(obj,aComponentName,aResistorValue,...
                aLevelNumber,aArrayOfPorts,aTerminalWidth)
            %addResistorComponent   Add a resistor component
            %   aComponent=Project.addResistorComponent(...) adds an ideal resistor
            %   component to a geometry project.  A reference to the newly added
            %   component is returned which can be used to modify the component's
            %   settings.
            %
            %   addResistorComponent takes the following arguments:
            %     1) The component name (Ex: 'R1')
            %     2) The resistor value (Ex: 50)
            %     3) Level number
            %     4) A nx2 matrix of the component port locations.
            %           The first row should be the first port's X value, then its Y value
            %           The second row should be the second port's X value, then its Y value
            %              etc.
            %     5) (Optional) The terminal width
            %           This value should be either
            %               - "Feed" to use the feedline width (Default)
            %               - "Cell" for one cell width
            %               - A number which represents a custom width
            %
            %   Note: This method is only for geometry projects.
            %   Note: This method will add components to a project.
            %         To modify the value of a component use the
            %         modifyComponentValue method.
            %
            %   Example usage:
            %       Project.addResistorComponent('R1',50,0,[104.5 156; 104.5 189])
            %       Project.addResistorComponent('R2',50,0,[104.5 156; 104.5 189],5)
            %       Project.addResistorComponent('R3',50,0,[104.5 156; 104.5 189],'Feed')
            %       Project.addResistorComponent('R4',50,0,[104.5 156; 104.5 189],'1Cell')
            
            if obj.isGeometryProject
                if nargin == 6
                    aReference = obj.GeometryBlock.addResistorComponent(aComponentName,aResistorValue,aLevelNumber,aArrayOfPorts,aTerminalWidth);
                else
                    aReference = obj.GeometryBlock.addResistorComponent(aComponentName,aResistorValue,aLevelNumber,aArrayOfPorts);
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aReference = addCapacitorComponent(obj,aComponentName,aCapacitorValue,...
                aLevelNumber,aArrayOfPorts,aTerminalWidth)
            %addCapacitorComponent   Add a capacitor component
            %   Project.addCapacitorComponent(...) adds an ideal capacitor
            %   component to a geometry project.
            %
            %   addCapacitorComponent takes the following arguments:
            %     1) The component name (Ex: 'C1')
            %     2) The capacitor value (Ex: 50)
            %     3) Level number
            %     4) A nx2 matrix of the component port locations.
            %           The first row should be the first port's X value, then its Y value
            %           The second row should be the second port's X value, then its Y value
            %              etc.
            %     5) (Optional) The terminal width
            %           This value should be either
            %               - "Feed" to use the feedline width (Default)
            %               - "Cell" for one cell width
            %               - A number which represents a custom width
            %
            %   Note: This method is only for geometry projects.
            %   Note: This method will add components to a project.
            %         To modify the value of a component use the
            %         modifyComponentValue method.
            %
            %   Example usage:
            %       Project.addCapacitorComponent('C1',50,0,[104.5 156; 104.5 189])
            %       Project.addCapacitorComponent('C2',50,0,[104.5 156; 104.5 189],5)
            %       Project.addCapacitorComponent('C3',50,0,[104.5 156; 104.5 189],'Feed')
            %       Project.addCapacitorComponent('C4',50,0,[104.5 156; 104.5 189],'1Cell')
            
            if obj.isGeometryProject
                if nargin == 6
                    aReference = obj.GeometryBlock.addCapacitorComponent(aComponentName,aCapacitorValue,aLevelNumber,aArrayOfPorts,aTerminalWidth);
                else
                    aReference = obj.GeometryBlock.addCapacitorComponent(aComponentName,aCapacitorValue,aLevelNumber,aArrayOfPorts);
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aReference = addInductorComponent(obj,aComponentName,aInductorValue,...
                aLevelNumber,aArrayOfPorts,aTerminalWidth)
            %addInductorComponent   Add a inductor component
            %   Project.addInductorComponent(...) adds an ideal inductor
            %   component to a geometry project.
            %
            %   addInductorComponent takes the following arguments:
            %     1) The component name (Ex: 'L1')
            %     2) The inductor value (Ex: 50)
            %     3) Level number
            %     4) A nx2 matrix of the component port locations.
            %           The first row should be the first port's X value, then its Y value
            %           The second row should be the second port's X value, then its Y value
            %              etc.
            %     5) (Optional) The terminal width
            %           This value should be either
            %               - "Feed" to use the feedline width (Default)
            %               - "Cell" for one cell width
            %               - A number which represents a custom width
            %
            %   Note: This method is only for geometry projects.
            %   Note: This method will add components to a project.
            %         To modify the value of a component use the
            %         modifyComponentValue method.
            %
            %   Example usage:
            %       Project.addInductorComponent('L1',50,0,[104.5 156; 104.5 189])
            %       Project.addInductorComponent('L2',50,0,[104.5 156; 104.5 189],5)
            %       Project.addInductorComponent('L3',50,0,[104.5 156; 104.5 189],'Feed')
            %       Project.addInductorComponent('L4',50,0,[104.5 156; 104.5 189],'1Cell')
            
            if obj.isGeometryProject
                if nargin == 6
                    aReference = obj.GeometryBlock.addInductorComponent(aComponentName,aInductorValue,aLevelNumber,aArrayOfPorts,aTerminalWidth);
                else
                    aReference = obj.GeometryBlock.addInductorComponent(aComponentName,aInductorValue,aLevelNumber,aArrayOfPorts);
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aReference = addDataFileComponent(obj,aComponentName,aDataFilename,...
                aLevelNumber,aArrayOfPorts,aTerminalWidth)
            %addDataFileComponent   Add a data file component
            %   Project.addDataFileComponent(...) adds a data
            %   file component to a geometry project.
            %
            %   addDataFileComponent takes the following arguments:
            %     1) The component name (Ex: 'R1')
            %     2) The data file name (Ex: 'Project.s2p')
            %     3) Level number
            %     4) A nx2 matrix of the component port locations.
            %           The first row should be the first port's X value, then its Y value
            %           The second row should be the second port's X value, then its Y value
            %              etc.
            %     5) (Optional) The terminal width
            %           This value should be either
            %               - "Feed" to use the feedline width (Default)
            %               - "Cell" for one cell width
            %               - A number which represents a custom width
            %
            %   Note: This method is only for geometry projects.
            %   Note: This method will add components to a project.
            %         To modify the value of a component use the
            %         modifyComponentValue method.
            %
            %   Example usage:
            %       Project.addDataFileComponent('DF1','Project.s2p',0,[104.5 156; 104.5 189])
            %       Project.addDataFileComponent('DF2','Project.s2p',0,[104.5 156; 104.5 189],5)
            %       Project.addDataFileComponent('DF3','Project.s2p',0,[104.5 156; 104.5 189],'Feed')
            %       Project.addDataFileComponent('DF4','Project.s2p',0,[104.5 156; 104.5 189],'1Cell')
            
            if obj.isGeometryProject
                
                % Check if the ComponentFileBlock exists
                if isempty(obj.ComponentFileBlock)
                    obj.ComponentFileBlock=SonnetComponentFileBlock();
                    obj.CellArrayOfBlocks{length(obj.CellArrayOfBlocks)+1}=obj.ComponentFileBlock;
                else
                    isBlockExists=false;
                    for iCounter=1:length(obj.CellArrayOfBlocks)
                        if isa(obj.CellArrayOfBlocks{iCounter},'SonnetComponentFileBlock')
                            isBlockExists=true;
                        end
                    end
                    if isBlockExists == false
                        obj.CellArrayOfBlocks{length(obj.CellArrayOfBlocks)+1}=obj.ComponentFileBlock;
                    end
                end
                
                if nargin == 6
                    aReference = obj.GeometryBlock.addDataFileComponent(obj.ComponentFileBlock,aComponentName,aDataFilename,aLevelNumber,aArrayOfPorts,aTerminalWidth);
                else
                    aReference = obj.GeometryBlock.addDataFileComponent(obj.ComponentFileBlock,aComponentName,aDataFilename,aLevelNumber,aArrayOfPorts);
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aReference = addPortOnlyComponent(obj,aComponentName,...
                aLevelNumber,aArrayOfPorts,aTerminalWidth)
            %addPortOnlyComponent   Add a ports only component
            %   Project.addPortOnlyComponent(...) adds a ports only 
            %   component to a geometry project.
            %
            %   addPortOnlyComponent takes the following arguments:
            %     1) The component name (Ex: 'COMP1')
            %     2) Level number
            %     3) A nx2 matrix of the component port locations.
            %           The first row should be the first port's X value, then its Y value
            %           The second row should be the second port's X value, then its Y value
            %              etc.
            %     4) (Optional) The terminal width
            %           This value should be either
            %               - "Feed" to use the feedline width (Default)
            %               - "Cell" for one cell width
            %               - A number which represents a custom width
            %
            %   Note: This method is only for geometry projects.
            %   Note: This method will add components to a project.
            %         To modify the value of a component use the
            %         modifyComponentValue method.
            %
            %   Example usage:
            %       Project.addPortOnlyComponent('COM1',0,[104.5 156; 104.5 189])
            %       Project.addPortOnlyComponent('COM2',0,[104.5 156; 104.5 189],5)
            %       Project.addPortOnlyComponent('COM3',0,[104.5 156; 104.5 189],'Feed')
            %       Project.addPortOnlyComponent('COM4',0,[104.5 156; 104.5 189],'1Cell')
            
            if obj.isGeometryProject
                if nargin == 5
                    aReference = obj.GeometryBlock.addPortOnlyComponent(aComponentName,aLevelNumber,aArrayOfPorts,aTerminalWidth);
                else
                    aReference = obj.GeometryBlock.addPortOnlyComponent(aComponentName,aLevelNumber,aArrayOfPorts);
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aArrayOfComponents = getResistorComponents(obj)
            %getResistorComponents   Returns resistor components
            %   components=Project.getResistorComponents() searches
            %   for resistor components and returns a vector of
            %   component references.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %       components=Project.getResistorComponents()
            %       length(components)   % The number of returned components
            
            if obj.isGeometryProject
                aArrayOfComponents=[];
                for iCounter=1:length(obj.GeometryBlock.ArrayOfComponents)
                    if obj.GeometryBlock.ArrayOfComponents{iCounter}.isResistorComponent()
                        if isempty(aArrayOfComponents)
                            aArrayOfComponents=obj.GeometryBlock.ArrayOfComponents{iCounter};
                        else
                            aArrayOfComponents(length(aArrayOfComponents)+1)=obj.GeometryBlock.ArrayOfComponents{iCounter}; %#ok<AGROW>
                        end
                    end
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aArrayOfComponents = getCapacitorComponents(obj)
            %getCapacitorComponents   Returns capacitor components
            %   components=Project.getCapacitorComponents() searches
            %   for capacitor components and returns a vector of
            %   component references.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %       components=Project.getCapacitorComponents()
            %       length(components)   % The number of returned components
            
            if obj.isGeometryProject
                aArrayOfComponents=[];
                for iCounter=1:length(obj.GeometryBlock.ArrayOfComponents)
                    if obj.GeometryBlock.ArrayOfComponents{iCounter}.isCapacitorComponent()
                        if isempty(aArrayOfComponents)
                            aArrayOfComponents=obj.GeometryBlock.ArrayOfComponents{iCounter};
                        else
                            aArrayOfComponents(length(aArrayOfComponents)+1)=obj.GeometryBlock.ArrayOfComponents{iCounter}; %#ok<AGROW>
                        end
                    end
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aArrayOfComponents = getInductorComponents(obj)
            %getInductorComponents   Returns inductor components
            %   components=Project.getInductorComponents() searches
            %   for inductor components and returns a vector of
            %   component references.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %       components=Project.getInductorComponents()
            %       length(components)   % The number of returned components
            
            if obj.isGeometryProject
                aArrayOfComponents=[];
                for iCounter=1:length(obj.GeometryBlock.ArrayOfComponents)
                    if obj.GeometryBlock.ArrayOfComponents{iCounter}.isInductorComponent()
                        if isempty(aArrayOfComponents)
                            aArrayOfComponents=obj.GeometryBlock.ArrayOfComponents{iCounter};
                        else
                            aArrayOfComponents(length(aArrayOfComponents)+1)=obj.GeometryBlock.ArrayOfComponents{iCounter}; %#ok<AGROW>
                        end
                    end
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aArrayOfComponents = getDataFileComponents(obj)
            %addDataFileComponent   Returns data file components
            %   components=Project.getDataFileComponents() searches
            %   for data file components and returns a vector of
            %   component references.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %       components=Project.getDataFileComponents()
            %       length(components)   % The number of returned components
            
            if obj.isGeometryProject
                aArrayOfComponents=[];
                for iCounter=1:length(obj.GeometryBlock.ArrayOfComponents)
                    if obj.GeometryBlock.ArrayOfComponents{iCounter}.isDataFileComponent()
                        if isempty(aArrayOfComponents)
                            aArrayOfComponents=obj.GeometryBlock.ArrayOfComponents{iCounter};
                        else
                            aArrayOfComponents(length(aArrayOfComponents)+1)=obj.GeometryBlock.ArrayOfComponents{iCounter}; %#ok<AGROW>
                        end
                    end
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [aIndex, aPolygon]=findComponent(obj,theId)
            %findComponentUsingId   Search for a component using its ID
            %
            %   [index component]=Project.findComponentUsingId(name) accepts
            %   the Debug ID for a component and returns the component's
            %   index in the array of components and a reference to the
            %   component. If the supplied component is not in the array
            %   then [] is returned.
            %
            %   [index component]=Project.findComponentUsingId(Id) accepts
            %   the Debug ID for a component and returns the component's
            %   index in the array of components and a reference to the
            %   component. If the supplied component is not in the array
            %   then [] is returned.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %       % Find the component's index and obtain a reference to it
            %       [ComponentIndex,ComponentObject]=Project.findComponentUsingId('R1');
            %
            %       % Find the component's index and obtain a reference to it
            %       [ComponentIndex,ComponentObject]=Project.findComponentUsingId(5);
            %
            % See also SonnetProject.getComponent
            
            if obj.isGeometryProject
                if isa(theId,'char')
                    [aIndex, aPolygon]=obj.GeometryBlock.findComponentUsingName(theId);
                else
                    [aIndex, aPolygon]=obj.GeometryBlock.findComponentUsingId(theId);
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aComponent=getComponent(obj,theIndex)
            %getComponent   Returns a component in the project
            %   aComponent=Project.getComponent(N) will return the Nth component
            %   in the array of components. This operation can also be achieved with
            %       component=Project.GeometryBlock.ArrayOfComponents{N};
            %
            %   aComponent=Project.getComponent(ComponentName) will return the component
            %   in the array of components with the specified name. If the component
            %   is not found then [] will be returned.
            %
            %   aComponent=Project.getComponent() will return the last component
            %   in the array of components.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Get the 5th component in the array of components
            %       component=Project.getComponent(5);
            
            if obj.isGeometryProject
                % If no index was specified then return the last
                % component in the array of components
                if nargin == 1
                    theIndex=length(obj.GeometryBlock.ArrayOfComponents);
                end
                
                if isa(theIndex,'char')
                    % Search the array for components with the matching name.  
                    % If it is unfound return an empty matrix.
                    aComponent=[];
                    for iCounter=1:length(obj.GeometryBlock.ArrayOfComponents)
                        aComponentName=strrep(obj.GeometryBlock.ArrayOfComponents{iCounter}.Name,'"','');
                        if strcmp(aComponentName,theIndex)==1
                           aComponent=obj.GeometryBlock.ArrayOfComponents{iCounter};
                           return
                        end
                    end
                else
                    % Check if the index is outside the bounds of the array
                    if theIndex < 1 || theIndex > length(obj.GeometryBlock.ArrayOfComponents)
                        error('Value for component index is outside the range of components');
                    else
                        aComponent=obj.GeometryBlock.ArrayOfComponents{theIndex};
                    end
                end
            else
                error('This method is only available for Geometry projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function deleteComponent(obj,theId)
            %deleteComponent   Delete a component
            %   Project.deleteComponent(Id) will delete the component
            %   with the passed ID from the array of components.
            %
            %   Project.deleteComponent(Component) will delete the
            %   passed component from the array of components.
            %
            %   Project.deleteComponent(Name) will delete the component
            %   with the passed name from the array of components.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Delete the component with debug ID 12
            %       Project.deleteComponent(12);
            
            obj.deleteComponentUsingId(theId);
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function deleteComponentUsingIndex(obj,theIndex)
            %deleteComponentUsingIndex   Deletes a component from the project
            %   Project.deleteComponentUsingIndex(N) will delete the Nth component
            %   in the array of components
            %
            %   Project.deleteComponentUsingIndex(Component) will delete the
            %   passed component from the array of components.
            %
            %   Project.deleteComponent(Name) will delete the component
            %   with the passed name from the array of components.
            %
            %   This operation can also be achieved with
            %       Project.GeometryBlock.ArrayOfComponents(N)=[];
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Delete the 5th component in the array of components
            %       Project.deleteComponentUsingIndex(5);
            
            if obj.isGeometryProject
                obj.GeometryBlock.deleteComponentUsingIndex(theIndex);
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function deleteComponentUsingId(obj,theId)
            %deletePolygonUsingId   Delete a polygon
            %   Project.deleteComponentUsingId(Id) will delete the component
            %   with the passed ID from the array of components.
            %
            %   Project.deleteComponentUsingId(Component) will delete the
            %   passed component from the array of components.
            %
            %   Project.deleteComponent(Name) will delete the component
            %   with the passed name from the array of components.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Delete the component with debug ID 12
            %       Project.deleteComponentUsingId(12);
            
            if obj.isGeometryProject
                obj.GeometryBlock.deleteComponentUsingId(theId);
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Other Methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addOption(obj,theOptionString)
            %addOption   Adds values to option string
            %   addOption(str) will add the passed option string
            %     to the defined set of project options.
            
            obj.ControlBlock.Options=[obj.ControlBlock.Options theOptionString];
        end    
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function removeOption(obj,theOptionString)
            %removeOption   Removes values from option string
            %   removeOption(str) will removed the specified 
            %     text from the project option string.
            
            obj.ControlBlock.Options=strrep(obj.ControlBlock.Options,theOptionString,'');
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function setOptions(obj,theOptionString)
            %setOptions   Adds values to option string
            %   setOptions(str) will replace the project options
            %   test with the specified text. All previously 
            %   defined options are lost.
            
            obj.ControlBlock.Options=theOptionString;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function isDefined=isMetalTypeDefined(obj,theMetalName)
            %isMetalTypeDefined   Checks if a metal type is defined
            %   isDefined=isMetalTypeDefined(name) will return true
            %   or false depending on if any metals in the project
            %   have the same name.
            
            isDefined = obj.GeometryBlock.isMetalTypeDefined(theMetalName);
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aMetal=getMetalType(obj,theMetalName)
            %getMetalType   Get a metal type
            %   metal=getMetalType(name) will search the project
            %   for the specified metal type based on its name.
            %   if the metal is not found an error is thrown.
            
            aMetal = obj.GeometryBlock.getMetalType(theMetalName);
        end        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeMeshToCoarseWithEdgeMesh(obj)
            %changeMeshToCoarseWithEdgeMesh   Changes memory/speed option
            %   This function will change a project's subsectioning
            %   setting to be course meshing with edge meshing
            
            obj.ControlBlock.Speed=1;
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeMeshToCoarseWithNoEdgeMesh(obj)
            %changeMeshToCoarseWithNoEdgeMesh   Changes memory/speed option
            %   This function will change a project's subsectioning
            %   setting to be course meshing with no edge meshing
            
            obj.ControlBlock.Speed=2;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeMeshToFineWithEdgeMesh(obj)
            %changeMeshToFineWithEdgeMesh   Changes memory/speed option
            %   This function will change a project's subsectioning
            %   setting to be fine meshing with edge meshing
            
            obj.ControlBlock.Speed=0;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function removeAllDielectricBricks(obj)
            %removeAllDielectricBricks   Removes all bricks
            %   Project.removeAllDielectricBricks() will look through the
            %   array of polygons and delete any dielectric brick polygons.
            %
            %   Note: This method is only for geometry projects.
            %
            %   This function is useful if you are using dielectric
            %   bricks as a placeholder for objects.
            
            if obj.isGeometryProject
                obj.GeometryBlock.removeAllDielectricBricks();
            else
                error('This method is only available for Geometry projects');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addParallelSubsection(obj,theSide,theDistance)
            %addParallelSubsection   Adds a parallel subsection
            %   Project.addParallelSubsection(Side,Length) will add a
            %   specified length Parallel Subsection to the
            %   project. Side may be 'LEFT', 'RIGHT', 'TOP',
            %   or 'BOTTOM'.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Add a parallel subsection to the 'TOP' of length 12
            %       Project.addParallelSubsection('TOP',12);
            
            if obj.isGeometryProject
                obj.GeometryBlock.addParallelSubsection(theSide,theDistance);
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addReferencePlane(obj,theSide,theTypeOfReferencePlane,theLengthOrPolygon,theVertex)
            %addReferencePlane   Adds a reference plane to the project
            %   Project.addReferencePlane(...) will add another reference plane
            %   to the array of reference planes.
            %
            %   addReferencePlane requires these arguments:
            %     1) The Side    -  the side the plane is on ('LEFT', 'RIGHT', 'Top', 'BOTTOM')
            %     2) The Type    -  type of reference plane (FIX, LINK, NONE)
            %     3) The length  -  length of the reference plane (If type is FIX or NONE)
            %          or
            %     3) The polygon -  the polygon to which the reference plane is linked
            %                       either the polygon object or the polygon's ID.
            %     4) If it is a polygon the vertex to which the reference
            %         plane will be connected to will need to be specified
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Add a reference plane to the 'TOP' side
            %       % of type 'FIX' of length 12.
            %       Project.addReferencePlane('TOP','FIX',12);
            %
            %       % Add a reference plane to the 'BOTTOM' side
            %       % of type 'NONE' of length 10.
            %       Project.addReferencePlane('BOTTOM','NONE',10);
            %
            %       % Add a reference plane to the 'RIGHT' side
            %       % of type 'LINK' with vertex 1 of a particular polygon.
            %       Project.addReferencePlane('RIGHT','LINK',aPolygonObject,1);
            %
            %       % Add a reference plane to the 'RIGHT' side
            %       % of type 'LINK' at the 2nd vertex of the polygon
            %       % with an ID of 1.
            %       Project.addReferencePlane('RIGHT','LINK',1,2);
            
            if obj.isGeometryProject
                if nargin == 5
                    obj.GeometryBlock.addReferencePlane(theSide,theTypeOfReferencePlane,theLengthOrPolygon,theVertex);
                else
                    obj.GeometryBlock.addReferencePlane(theSide,theTypeOfReferencePlane,theLengthOrPolygon);
                end
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addEdgeVia(obj,thePolygon,theEdgeNumber,theToLevel)
            %addEdgeVia   Add a new edge via
            %   Project.addEdgeVia(Polygon,EdgeNumber,Level) will add an Edge Via
            %   to a polygon in the project. Polygon may be either a reference
            %   to a polygon object or the polygon's ID. The via is placed on
            %   the polygon edge between the specified number and the next number.
            %   For example, if vertex 3 is specified, the via extends from
            %   vertex 3 to vertex 4 on the polygon. Level should be either
            %   the index of the metallization  level the via should be attached
            %   to or 'GND' or 'TOP'.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %       % Add an edge via to the polygon with
            %       % debug ID 8 at vertex number 1. The via
            %       % will be connected to layer 0.
            %       Project.addEdgeVia(8,1,0);
            %
            %       % Add an edge via to the polygon with
            %       % debug ID 8 at vertex number 2. The via
            %       % will be connected to 'GND'.
            %       Project.addEdgeVia(8,2,'GND');
            
            if obj.isGeometryProject
                obj.GeometryBlock.addEdgeVia(thePolygon,theEdgeNumber,theToLevel);
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [numIndex,arrayOfIndex] = findParameterIndex(obj,name)
            %findParameterIndex   Find parameter index
            %   [numIndex arrayOfIndex]=Project.findParameterIndex(name) returns the
            %   number of indices and an array of indices index of the parameter
            %   in a Sonnet Project based on its name.
            %
            %   Note: This method is only for geometry projects.
            
            numIndex = 0;
            for i = 1:length(obj.GeometryBlock.ArrayOfParameters)
                if strcmp(obj.GeometryBlock.ArrayOfParameters{1,i}.Parname,name)
                    numIndex = numIndex + 1;
                    arrayOfIndex{1,numIndex} = i; %#ok<AGROW>
                    return;
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aValue = getVariableValue(obj,theVariableName)
            %getVariableValue  Returns the value of a variable
            %   aValue=Project.getVariableValue(name) returns
            %   the value of the variable specified by name.
            %   if the variable does not exist [] is returned.
            %   This method supports both geometry and netlist
            %   variables.
            
            if obj.isGeometryProject
                aValue=obj.GeometryBlock.getVariableValue(theVariableName);
            else
                aValue=obj.ParameterBlock.getVariableValue(theVariableName);
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function modifyVariableValue(obj, theVariableName, theValue)
            %modifyVariableValue   Modify Geometry/Netlist Variable Value
            %   Project.modifyVariableValue(Name,Value) When used with
            %   a geometry project will modify the value for the geometry
            %   variable with the passed name. If there are
            %   any parameters associated with the variable then the
            %   parameter's values will be updated to be consistent. If
            %   Project is a netlist project then the value for the
            %   netlist variable will be modified.
            %
            %   If the user supplies the name for an invalid variable name then no
            %   action will take place. The name of the variable is
            %   case insensitive.
            %
            %   Example usage:
            %       Project.modifyVariableValue('Length',1)
            
            if obj.isGeometryProject
                obj.GeometryBlock.modifyVariableValue(theVariableName, theValue);
            else
                obj.ParameterBlock.modifyVariableValue(theVariableName, theValue);
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function defineVariable(obj, theVariableName, theValue, theType, theDescription)
            %defineVariable   Define a Geometry/Netlist Variable
            %   Project.defineVariable(Name,Value) When used with
            %   a geometry project will define a new geometry
            %   variable. When used with a netlist project defineVariable
            %   will define a new Netlist parameter.
            %
            %   Project.defineVariable(Name,Value,Type) When used with
            %   a geometry project will define a new geometry variable of
            %   the specified type. When used with a netlist project
            %   the value of Type is ignored and defineVariable
            %   will define a new Netlist parameter.
            %
            %   Project.defineVariable(Name,Value,Type,Description) This
            %   command will operate the same as above except the user
            %   may supply a description for the newly created variable.
            %   Descriptions are only stored for geometry projects.
            %
            %   Type may be one of the following values:
            %     LNG      Length
            %     RES      Resistance
            %     CAP      Capacitance
            %     IND      Inductance
            %     FREQ     Frequency
            %     OPS      Ohms/sq
            %     SPM      Siemens/meter
            %     PHPM     picoHenries/meter
            %     RRF      Rrf
            %     NONE     Undefined
            %
            %   If the specified variable or parameter already
            %   exists its value will be replaced.
            %
            %   Example usage:
            %       Project.defineVariable('Z0',50)
            %       Project.defineVariable('Length',50,'LNG')
            
            if obj.isGeometryProject
                if nargin == 3
                    obj.GeometryBlock.defineVariable(theVariableName, theValue);
                elseif nargin == 4
                    obj.GeometryBlock.defineVariable(theVariableName, theValue, theType);
                elseif nargin == 5
                    obj.GeometryBlock.defineVariable(theVariableName, theValue, theType, theDescription);
                else
                    error('Improper number of arguments');
                end
            else
                if nargin == 3
                    obj.ParameterBlock.defineVariable(theVariableName, theValue);
                else
                    obj.ParameterBlock.defineVariable(theVariableName, theValue, theType);
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function index = findVariableIndex(obj,name)
            %findVariableIndex find the index of a variable in the SonnetProject
            %   index=Project.findVariableIndex(name) returns the index of a variable in a Sonnet
            %   Project (layout or netlist) based on its name.
            
            %If CircuitElementsBlock is empty then it's not a netlist
            if isempty(obj.CircuitElementsBlock)
                for i = 1:length(obj.GeometryBlock.ArrayOfVariables)
                    if strcmp(obj.GeometryBlock.ArrayOfVariables{1,i}.VariableName,name);
                        index = i;
                        return;
                    end
                end
            else % Otherwise it is a netlist
                for i = 1:length(obj.ParameterBlock.ArrayOfParameters)
                    if strcmp(obj.ParameterBlock.ArrayOfParameters{1,i}.ParameterName,name);
                        index = i;
                        return;
                    end
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addDimensionLabel(obj,theReferencePolygon1,theReferenceVertex1,theReferencePolygon2,theReferenceVertex2,theDirection)
            %addDimensionLabel   Adds a dimension label
            %   Project.addDimensionLabel(...) will add a
            %   dimension label to the project.
            %
            %   addDimensionLabel eight arguments:
            %     1) Handle for first reference polygon or the polygon's ID
            %     2) The vertex number used for the first reference polygon
            %     3) Handle for second reference polygon or the polygon's ID
            %     4) The vertex number used for the second reference polygon
            %     5) The direction of movement; this may be 'x','X', or 'XDir'
            %           for the X direction and 'y','Y', or 'YDir' for the Y
            %           direction.
            %
            %   Note: This method is only for geometry projects.
            %
            %   Example usage:
            %
            %     Example 1:
            %       % We have a polygon in a project and we want to mark its
            %       % width with a dimension label. This particular polygon
            %       % has coordinate values of: (10,10),(30,10),(30,40),
            %       % (10,40),(10,10). The polygon has an ID of seven. The polygon
            %       % looks like the following diagram with the vertices numbered.
            %       % We want to place a dimension label between
            %       % coordinates 1 and 2.
            %       %
            %       %                         4-----3
            %       %                         |     |
            %       %                         |     |
            %       %                         |     |
            %       %                         1-----2
            %       %
            %       % The two reference polygon inputs will be the same
            %       % polygon. The reference polygon can be specified with
            %       % its debug ID which is seven. The label can be added 
            %       % with the following command:
            %
            %       Project.addDimensionLabel(7,1,7,2,'x');
            %
            %       % Alternately, the polygon's coordinates could have been selected
            %       % easier with the polygon methods lowerRightVertex(), lowerLeftVertex(),
            %       % upperRightVertex(), upperLeftVertex(). These methods will return
            %       % the index of the coordinate that is at the desired location of
            %       % the polygon. The polygon coordinate methods are intended for
            %       % rectangular polygons only. Using the polygon coordinate access
            %       % methods on non-rectangular polygons could potential yield
            %       % undesirable results (Example: what is the lower left corner
            %       % of a spiral? lowerLeftVertex() will return the best value it
            %       % can but the user should be aware that in that case they may
            %       % be better off specifying the coordinate manually). In order
            %       % to use methods such as lowerRightVertex() we will need to
            %       % obtain a reference to the desired polygon; this can be
            %       % accomplished using the findPolygonUsingId() method.
            %
            %       [~, polygon]=Project.findPolygonUsingId(7);
            %       Project.addDimensionLabel(polygon,polygon.lowerLeftVertex(),...
            %               polygon,polygon.lowerRightVertex(),'x');
            %
            %   See also SonnetProject.addAnchoredDimensionParameter,
            %            SonnetProject.addSymmetricDimensionParameter,
            
            if obj.isGeometryProject
                obj.GeometryBlock.addDimensionLabel(theReferencePolygon1,theReferenceVertex1,theReferencePolygon2,theReferenceVertex2,theDirection);
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addAnchoredDimensionParameter(obj,theParameterName,...
                theReferencePolygon1,theReferenceVertex1,...
                theReferencePolygon2,theReferenceVertex2,...
                theArrayOfOtherPolygons, theArrayOfOtherVertices,...
                theDirection,theEquation)
            %addAnchoredDimensionParameter   Adds a dimension parameter
            %   Project.addAnchoredDimensionParameter(...) will add an anchored
            %   geometry dimension parameter to the project.
            %
            %   addDimensionParameter eight arguments:
            %     1) The parameter name (Ex: 'Width')
            %     2) Handle for first reference polygon or the polygon's ID
            %     3) The vertex number used for the first reference polygon
            %     4) Handle for second reference polygon or the polygon's ID
            %     5) The vertex number used for the second reference polygon
            %     6) A cell array of any polygons that have points that should
            %           be altered by this dimension parameter. If there is
            %           only one polygon to be altered then this parameter
            %           does not need to be a cell array.
            %     7) A cell array of vectors that indicate which vertices of
            %           the polygon should be altered. If there is
            %           only one polygon to be altered then this parameter
            %           does not need to be a cell array.
            %     8) The direction of movement; this may be 'x','X', or 'XDir'
            %           for the X direction and 'y','Y', or 'YDir' for the Y
            %           direction.
            %     9) (Optional) The equation that should be used.
            %
            %   Note: This method is only for geometry projects.
            %   Note: This method will add dimension parameters to a project.
            %         To modify the value of a dimension parameter use the
            %         modifyVariableValue method.
            %
            %   Example usage:
            %
            %     Example 1:
            %       % We have a polygon in a project and we want to alter its
            %       % width with a dimension parameter. This particular polygon
            %       % has coordinate values of: (10,10),(30,10),(30,40),
            %       % (10,40),(10,10). The polygon has an ID of seven. The polygon
            %       % looks like the following diagram with the vertices numbered.
            %       % We want the polygon to grow/shrink on the right hand side
            %       % (coordinates 2 and 3) while keeping the left hand
            %       % (coordinates 1 and 4) constant.
            %       %
            %       %                         4-----3
            %       %                         |     |
            %       %                         |     |
            %       %                         |     |
            %       %                         1-----2
            %       %
            %       % To accomplish our goal we can add a dimension parameter
            %       % to the project. The parameter will be named 'Width' and
            %       % be attached to the polygon with an ID of seven. The first
            %       % reference vertex will be the first vertex of the desired
            %       % polygon and the second vertex value will be the second
            %       % vertex of the polygon. The two reference points signify
            %       % a move in the X direction.
            %       %
            %       % Now we will add some polygons that have altering points
            %       % to the point set.  In this case we want to alter the points
            %       % on the right hand side of the polygon.  The second
            %       % reference point already corresponds to one of the points;
            %       % the second point we want to select for movement is the
            %       % first coordinate of the polygon.
            %
            %       Project.addAnchoredDimensionParameter('Width',7,3,7,2,7,1,'x');
            %
            %       % Alternately, the polygon's coordinates could have been selected
            %       % easier with the polygon methods lowerRightVertex(), lowerLeftVertex(),
            %       % upperRightVertex(), upperLeftVertex(). These methods will return
            %       % the index of the coordinate that is at the desired location of
            %       % the polygon. The polygon coordinate methods are intended for
            %       % rectangular polygons only. Using the polygon coordinate access
            %       % methods on non-rectangular polygons could potential yield
            %       % undesirable results (Example: what is the lower left corner
            %       % of a spiral? lowerLeftVertex() will return the best value it
            %       % can but the user should be aware that in that case they may
            %       % be better off specifying the coordinate manually). In order
            %       % to use methods such as lowerRightVertex() we will need to
            %       % obtain a reference to the desired polygon; this can be
            %       % accomplished using the findPolygonUsingId() method.
            %
            %       [~, polygon]=Project.findPolygonUsingId(7);
            %       Project.addAnchoredDimensionParameter('Width',...
            %               polygon,polygon.lowerLeftVertex(),...
            %               polygon,polygon.lowerRightVertex(),...
            %               polygon,polygon.upperRightVertex(),'x');
            %
            %     Example 2:
            %       % We have two polygons in a project and we want to alter
            %       % their separation with a dimension parameter. The left
            %       % polygon has coordinate values of: (10,10),(30,10),(30,40),
            %       % (10,40),(10,10). The right polygon has coordinate values
            %       % of (50,10),(80,10),(80,30),(70,30),(70,40),(50,40). The left polygon
            %       % has an ID of seven and the right polygon has an ID of eight.
            %       % The polygon layout looks like the following diagram with the vertices
            %       % numbered. We want the right polygon to move closer or farther
            %       % away from the fixed left polygon.
            %       %
            %       %             4-----3       6-----5
            %       %             |     |       |     |__3
            %       %             |     |       |     4  |
            %       %             |     |       |        |
            %       %             1-----2       1--------2
            %       %
            %       % To accomplish our goal we will add a dimension parameter. We
            %       % will call our parameter 'Sep'. The first reference point will
            %       % be attached to vertex number two of the left polygon (ID of seven)
            %       % and the second reference point will be attached to vertex
            %       % number one of the right polygon (ID of eight).
            %       %
            %       % Now we will add some polygons that have altering points
            %       % to the point set.  In this case we want to alter the all
            %       % the points for the polygon on the right. We may indicate
            %       % that all the points in the polygon should be altered by
            %       % not specifying which points in the polygon should be altered.
            %
            %       Project.addAnchoredDimensionParameter('Sep',7,2,8,1,8,[],'x');
            %
            %     Example 3:
            %       % We have three polygons in a project and we want to alter the separation
            %       % between the right two polygons and the left most polygon. The left
            %       % polygon has coordinate values of: (10,10),(30,10),(30,40),
            %       % (10,40),(10,10). The middle polygon has coordinate values
            %       % of (50,10),(80,10),(80,30),(70,30),(70,40),(50,40). The polygon on
            %       % the right has coordinate values of (90,10),(120,10),(120,30),(110,30),
            %       % (110,40),(90,40). The left polygon has an ID of seven, the middle
            %       % polygon has an ID of eight  and the right polygon has an ID of nine.
            %       % The polygon layout looks like the following diagram with the vertices
            %       % numbered. We want the middle and right polygons to move closer or farther
            %       % away from the fixed left polygon.
            %       %
            %       %             4-----3       6-----5     6-----5
            %       %             |     |       |     |__3  |     |__3
            %       %             |     |       |     4  |  |     4  |
            %       %             |     |       |        |  |        |
            %       %             1-----2       1--------2  1--------2
            %       %
            %       % To accomplish our goal we will add a dimension parameter. We
            %       % will call our parameter 'Sep'. The first reference point will
            %       % be attached to vertex number two of the left polygon (ID of seven)
            %       % and the second reference point will be attached to vertex
            %       % number one of the middle polygon (ID of eight).
            %       %
            %       % Now we will add some polygons that have altering points
            %       % to the point set.  In this case we want to alter the all
            %       % the points for the middle polygon and the right polygon.
            %       % Because more than one polygon is to be modified we must
            %       % put the polygons and vertices in cell arrays. Because the
            %       % entire polygons should be moved the vertices may be specified
            %       % by the empty set ([]); in this example we will explicitly state
            %       % the vertices anyway so that the user can see how to indicate
            %       % individual vertices.
            %
            %       aArrayOfPolygons{1}=8;
            %       aArrayOfPolygons{2}=9;
            %       aArrayOfPoints{1}=[1 2 3 4 5 6];
            %       aArrayOfPoints{2}=[1 2 3 4 5 6];
            %       Project.addAnchoredDimensionParameter('Sep',7,2,8,1,aArrayOfPolygons,aArrayOfPoints,'x');
            
            if obj.isGeometryProject
                if nargin == 10
                    obj.GeometryBlock.addAnchoredDimensionParameter(...
                        theParameterName,...
                        theReferencePolygon1,theReferenceVertex1,...
                        theReferencePolygon2,theReferenceVertex2,...
                        theArrayOfOtherPolygons, theArrayOfOtherVertices,...
                        theDirection,theEquation);
                else
                    obj.GeometryBlock.addAnchoredDimensionParameter(...
                        theParameterName,...
                        theReferencePolygon1,theReferenceVertex1,...
                        theReferencePolygon2,theReferenceVertex2,...
                        theArrayOfOtherPolygons, theArrayOfOtherVertices,...
                        theDirection);
                end
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addSymmetricDimensionParameter(obj,theParameterName,...
                theReferencePolygon1,theReferenceVertex1,...
                theReferencePolygon2,theReferenceVertex2,...
                theArrayOfFirstPointSetPolygons, theArrayOfFirstPointSetVertices,...
                theArrayOfSecondPointSetPolygons, theArrayOfSecondPointSetVertices,...
                theDirection,theEquation)
            %addSymmetricDimensionParameter   Adds a dimension parameter
            %   Project.addSymmetricDimensionParameter(...) will add a symmetric
            %   geometry dimension parameter to the project.
            %
            %   addSymmetricDimensionParameter ten arguments:
            %     1) The parameter name (Ex: 'Width')
            %     2) Handle for first reference polygon or the polygon's ID
            %     3) The vertex number used for the first reference polygon
            %     4) Handle for second reference polygon or the polygon's ID
            %     5) The vertex number used for the second reference polygon
            %     6) A cell array of any polygons that have points that should
            %           be included in the first point set. If there is
            %           only one polygon to be altered then this parameter
            %           does not need to be a cell array. Polygons in the
            %           first point set are the ones to be altered in the
            %           same way as the first reference point.
            %     7) A cell array of vectors that indicate which polygon
            %           vertices should be in the first point set. If there is
            %           only one polygon to be altered then this parameter
            %           does not need to be a cell array.
            %     8) A cell array of any polygons that have points that should
            %           be included in the second point set. If there is
            %           only one polygon to be altered then this parameter
            %           does not need to be a cell array. Polygons in the
            %           second point set are the ones to be altered in the
            %           same way as the first reference point.
            %     9) A cell array of vectors that indicate which polygon
            %           vertices should be in the first point set. If there is
            %           only one polygon to be altered then this parameter
            %           does not need to be a cell array.
            %    10) The direction of movement; this may be 'x', 'X', or 'XDir'
            %           for the X direction and 'y', 'Y', or 'YDir' for the Y
            %           direction.
            %    11) (Optional) The equation that should be used.
            %
            %   Note: This method is only for geometry projects.
            %   Note: This method will add dimension parameters to a project.
            %         To modify the value of a dimension parameter use the
            %         modifyVariableValue method.
            %
            %   Example usage:
            %
            %     Example 1:
            %       % We have a polygon in a project and we want to alter its
            %       % width with a dimension parameter. This particular polygon
            %       % has coordinate values of: (10,10),(30,10),(30,40),
            %       % (10,40),(10,10). The polygon has an ID of seven. The polygon
            %       % looks like the following diagram with the vertices numbered.
            %       % We want the polygon to grow/shrink on both the left and right
            %       % hand sides.
            %       %
            %       %                         4-----3
            %       %                         |     |
            %       %                         |     |
            %       %                         |     |
            %       %                         1-----2
            %       %
            %       % To accomplish our goal we can add a symmetric dimension parameter
            %       % to the project. The parameter will be named 'Width' and
            %       % be attached to the polygon with an ID of seven. The first
            %       % reference vertex will be the first vertex of the desired
            %       % polygon and the second vertex value will be the second
            %       % vertex of the polygon. The two reference points signify
            %       % a move in the X direction.
            %       %
            %       % Now we will add some polygons that have altering points
            %       % to the point set.  In this case we want the left two coordinates
            %       % to move together (coordinates 1 and 4) and the right two
            %       % coordinates to move together (coordinates 2 and 3). Each set
            %       % of points that will move together is a point set. One of the
            %       % point sets should be [1 4] and the other [2 3]. Alternatively
            %       % the point sets may just be [4] and [3] because points 1 and 2 are
            %       % already going to be moved because they are the reference points.
            %
            %       Project.addSymmetricDimensionParameter('Width',7,1,7,2,7,[1 4],7,[2 3],'x');
            %
            %       % Alternately, the polygon's coordinates could have been selected
            %       % easier with the polygon methods lowerRightVertex(), lowerLeftVertex(),
            %       % upperRightVertex(), upperLeftVertex(). These methods will return
            %       % the index of the coordinate that is at the desired location of
            %       % the polygon. The polygon coordinate methods are intended for
            %       % rectangular polygons only. Using the polygon coordinate access
            %       % methods on non-rectangular polygons could potential yield
            %       % undesirable results (Example: what is the lower left corner
            %       % of a spiral? lowerLeftVertex() will return the best value it
            %       % can but the user should be aware that in that case they may
            %       % be better off specifying the coordinate manually). In order
            %       % to use methods such as lowerRightVertex() we will need to
            %       % obtain a reference to the desired polygon; this can be
            %       % accomplished using the findPolygonUsingId() method.
            %
            %       [~, polygon]=Project.findPolygonUsingId(7);
            %       Project.addSymmetricDimensionParameter('Width',...
            %               polygon,polygon.lowerLeftVertex(),...
            %               polygon,polygon.lowerRightVertex(),...
            %               polygon,polygon.upperLeftVertex(),...
            %               polygon,polygon.upperRightVertex(),'x');
            %
            %     Example 2:
            %       % We have two polygons in a project and we want to alter
            %       % their separation with a dimension parameter. The left
            %       % polygon has coordinate values of: (10,10),(30,10),(30,40),
            %       % (10,40),(10,10). The right polygon has coordinate values
            %       % of (50,10),(80,10),(80,30),(70,30),(70,40),(50,40). The left polygon
            %       % has an ID of seven and the right polygon has an ID of eight.
            %       % The polygon layout looks like the following diagram with the vertices
            %       % numbered. We want to alter the separation between the polygons such
            %       % that they are closer together / farther apart.
            %       %
            %       %             4-----3       6-----5
            %       %             |     |       |     |__3
            %       %             |     |       |     4  |
            %       %             |     |       |        |
            %       %             1-----2       1--------2
            %       %
            %       % To accomplish our goal we will add a dimension parameter. We
            %       % will call our parameter 'Sep'. The first reference point will
            %       % be attached to vertex number two of the left polygon (ID of seven)
            %       % and the second reference point will be attached to vertex
            %       % number one of the right polygon (ID of eight).
            %       %
            %       % In this example we want to alter all the points for the left
            %       % polygon separately and all the points in the right polygon
            %       % separately. This can be done by making then be in different
            %       % point sets. We may indicate that all the points in a polygon
            %       % should be altered by passing [] for the vertex vector.
            %
            %       Project.addSymmetricDimensionParameter('Sep',7,2,8,1,7,[],8,[],'x');
            %
            %     Example 3:
            %       % We have three polygons in a project and we want to alter the separation
            %       % between the right two polygons and the left most polygon. The left
            %       % polygon has coordinate values of: (10,10),(30,10),(30,40),
            %       % (10,40),(10,10). The middle polygon has coordinate values
            %       % of (50,10),(80,10),(80,30),(70,30),(70,40),(50,40). The polygon on
            %       % the right has coordinate values of (90,10),(120,10),(120,30),(110,30),
            %       % (110,40),(90,40). The left polygon has an ID of seven, the middle
            %       % polygon has an ID of eight  and the right polygon has an ID of nine.
            %       % The polygon layout looks like the following diagram with the vertices
            %       % numbered. We want the middle and right polygons to move closer or farther
            %       % away from the fixed left polygon.
            %       %
            %       %             4-----3         6-----5     6-----5
            %       %             |     |         |     |__3  |     |__3
            %       %             |     |         |     4  |  |     4  |
            %       %             |     |         |        |  |        |
            %       %             1-----2         1--------2  1--------2
            %       %                   |<--Sep-->|
            %       %
            %       % To accomplish our goal we will add a dimension parameter. We
            %       % will call our parameter 'Sep'. The first reference point will
            %       % be attached to vertex number two of the left polygon (ID of seven)
            %       % and the second reference point will be attached to vertex
            %       % number one of the middle polygon (ID of eight).
            %       %
            %       % Now we will add some polygons that have altering points
            %       % to the point sets. In this case we want the left polygon to
            %       % move independently and the right two polygons to move
            %       % together. So the left most polygon should be used for the
            %       % first point set and the right two polygons used for the
            %       % second point set. Because the second point set contains more
            %       % than one polygon the polygons and vertices must be specified
            %       % as cell arrays. Because the entire polygons should be moved the
            %       % vertices may be specified by the empty set ([]); in this example
            %       % we will explicitly state the vertices anyway so that the user can
            %       % see how to indicate individual vertices.
            %
            %       aPointSet1Polygons=7;
            %       aPointSet1Points=[1 2 3 4];
            %       aPointSet2Polygons{1}=8;
            %       aPointSet2Polygons{2}=9;
            %       aPointSet2Points{1}=[1 2 3 4 5 6];
            %       aPointSet2Points{2}=[1 2 3 4 5 6];
            %       Project.addAnchoredDimensionParameter('Sep',7,2,8,1,aPointSet1Polygons,aPointSet1Points,aPointSet2Polygons,aPointSet2Points,'x');
            
            if obj.isGeometryProject
                if nargin == 12
                    obj.GeometryBlock.addSymmetricDimensionParameter(...
                        theParameterName,...
                        theReferencePolygon1,theReferenceVertex1,...
                        theReferencePolygon2,theReferenceVertex2,...
                        theArrayOfFirstPointSetPolygons, theArrayOfFirstPointSetVertices,...
                        theArrayOfSecondPointSetPolygons, theArrayOfSecondPointSetVertices,...
                        theDirection,theEquation);
                else
                    obj.GeometryBlock.addSymmetricDimensionParameter(...
                        theParameterName,...
                        theReferencePolygon1,theReferenceVertex1,...
                        theReferencePolygon2,theReferenceVertex2,...
                        theArrayOfFirstPointSetPolygons, theArrayOfFirstPointSetVertices,...
                        theArrayOfSecondPointSetPolygons, theArrayOfSecondPointSetVertices,...
                        theDirection);
                end
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aValue = getLayerIndexes(obj)
            %getLayerIndexes  Returns the list of dielectric layer names
            %   aValue=Project.getLayerIndexes() returns a vertically
            %   concatinated vector of layer indexes. If the project
            %   has thick metal types the sublevels will be included.
            %
            %   This method is useful for determining the indexes
            %   of levels (and sublevels defined by thick metal
            %   types) for JXY data exporting.
            %
            %   Note: This method is only for geometry projects.
            %   Note: This method is only supported on Sonnet version 13
            %   Note: This method will perform a save operation. If the
            %           project does not yet have an associated filename
            %           the save will not be successful.
            %
            %   Example:
            %     % Export level numbers from a project
            %     % with a defined thick metal type.
            %     Project.getLayerIndexes()
            
            if obj.isGeometryProject
                % Save the project
                obj.save()
                
                % Get the Sonnet 13 path
                [aDefaultPath, aListOfPaths]=SonnetPath();
                
                % Check if the default path is a version 13 path
                if isempty(strfind(aDefaultPath,'13.'))
                    % Search the list of other installed versions
                    isFoundValidVersion=false;
                    for iCounter=1:length(aListOfPaths)
                        if ~isempty(strfind(aListOfPaths{iCounter},'13.'))
                            Path=aListOfPaths{iCounter};
                            isFoundValidVersion=true;
                        end
                    end
                else
                    % Indicate that we have found a valid version
                    Path=aDefaultPath;
                    isFoundValidVersion=true;
                end
                
                % If a valid version 13 installation is not found then display an error
                if ~isFoundValidVersion
                    error('Could not find a Sonnet 13 installation');
                end
                
                % Perform the system call
                Path=strrep(Path,'"','');
                if isunix
                    aCallToSystem=['"' Path filesep 'bin' filesep 'autodoc" -NoBrowser  -XMLPath . "' obj.FilePath '.' filesep obj.Filename '"'];
                else
                    aCallToSystem=['"' Path filesep 'bin' filesep 'autodoc.exe" -NoBrowser  -XMLPath . "' obj.FilePath '.' filesep obj.Filename '"'];
                end
                [aStatus, aMessage]=system(aCallToSystem);
                if aStatus
                    error(['Failed to call soncmd to unlock the project: ' aMessage]);
                end
                
                % Check that the autodoc file exists
                if ~exist([obj.FilePath '.' filesep 'autodoc.xml'],'file')==2
                    error('AutoDoc File Not Found');
                end
                
                % Read the autodoc file
                aDocumentModel= xmlread([obj.FilePath '.' filesep 'autodoc.xml']);
                aLayerPartitionNodes = aDocumentModel.getElementsByTagName('layer_partitions');
                aValue='';
                for k = 0:aLayerPartitionNodes.getLength-2 % (-2 instead of -1) Dont store the last layer (ground)
                    aLayerPartition = aLayerPartitionNodes.item(k);
                    
                    % Get the list of partitions for this level
                    aSubLayerPartions = aLayerPartition.getElementsByTagName('partition');
                    
                    for j = 0:aSubLayerPartions.getLength-1
                        aElement = aSubLayerPartions.item(j);
                        
                        % Store the partition name
                        if isempty(aValue)
                            % If we have more than one sub-partition
                            % then concatinate the level with a letter index
                            if aSubLayerPartions.getLength > 1
                                aValue = [num2str(k) char('a'+j)];
                            else
                                aValue = num2str(k);
                            end
                        else
                            % If we have more than one sub-partition
                            % then concatinate the level with a letter index
                            if aSubLayerPartions.getLength > 1
                                aValue = char(aValue,[num2str(k) char('a'+j)]);
                            else
                                aValue = char(aValue,num2str(k));
                            end
                            
                        end
                    end
                end
                
                % Delete the autodoc file
                delete([obj.FilePath '.' filesep 'autodoc.xml']);
                
            else
                error('This method is only available for Geometry projects');
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aValue = readSpectreRLGC(obj, theFileName)
           aValue = SonnetSpectreRLGCReader(theFileName);
           obj.SpectreRLGC = aValue;           
        end

        function aValue = checkIsValid(obj)
            aValue = true;
            
            if ~isempty(obj.FrequencyBlock)
                if ~obj.FrequencyBlock.isValid() 
                    aValue = false;
                end 
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Add TechLayer Methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addTechLayer(obj, theType, theName, theDXFName, theGDSStream, ...
                 theGDSData, theGBRFilename, theLevel, theToLevel)
            % Add Technology Layer to a dielectric.
            % addTechLayer requires these arguments
            %   1)  theType specfies the type of tech layer to add
            %   2)  theName the name of the tech layer
            %   3)  theDXFName the associated DXF name
            %   4)  theGDSStream the associated GDS stream
            %   5)  theGDSData the associated GDS data
            %   6)  theGBRFilename the associated Gerber filename
            %   7) theLevel the starting metalization level index
            %   8) theToLevel the endinf metalization level index
            %
            % Note: Many users will prefer to use the following functions
            %   1) addBrickTechLayer
            %   2) addMetalTechLayer
            %   3) addViaTechLayer
            %
            % Example usage:
            %     Project.addTechLayer('METAL', 'Metal-1', 'DXF', 0, ...
            %           1, 'GBRFilename', 0, 0);
            %                      
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
            obj.GeometryBlock.addTechLayer(theType, theName, theDXFName, theGDSStream, ...
                 theGDSData, theGBRFilename, theLevel, theToLevel);
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addMetalTechLayer(obj, theName, theDXFName, theGDSStream, ...
                 theGDSData, theGBRFilename, theLevel)
            % Add Metal Technology Layer to a dielectric.
            % 
            % addMetalTechLayer requires these arguments
            %   1)  theName the name of the tech layer
            %   2)  theDXFName the associated DXF name
            %   3)  theGDSStream the associated GDS stream
            %   4)  theGDSData the associated GDS data
            %   5)  theGBRFilename the associated Gerber filename
            %   6) theLevel the starting metalization level index
            %
            % Example usage:
            %     Project.addMetalTechLayer('Metal-1', 'DXF', 0, ...
            %           1, 'GBRFilename', 0);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
            obj.GeometryBlock.addTechLayer('METAL', theName, theDXFName, theGDSStream, ...
                 theGDSData, theGBRFilename, theLevel);            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addViaTechLayer(obj, theName, theDXFName, theGDSStream, ...
                 theGDSData, theGBRFilename, theLevel, theToLevel)
            % Add Via Technology Layer to a dielectric.
            % 
            % addViaTechLayer requires these arguments
            %   1)  theName the name of the tech layer
            %   2)  theDXFName the associated DXF name
            %   3)  theGDSStream the associated GDS stream
            %   4)  theGDSData the associated GDS data
            %   5)  theGBRFilename the associated Gerber filename
            %   6) theLevel the starting metalization level index
            %   7) theToLevel the endinf metalization level index
            %
            % Example usage:
            %     Project.addViaTechLayer('Via-1', 'DXF', 0, ...
            %           1, 'GBRFilename', 0, 0);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
            obj.GeometryBlock.addTechLayer('VIA', theName, theDXFName, theGDSStream, ...
                 theGDSData, theGBRFilename, theLevel, theToLevel);           
        end        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addBrickTechLayer(obj, theName, theDXFName, theGDSStream, ...
                 theGDSData, theGBRFilename, theLevel)
            % Add Brick Technology Layer to a dielectric.
            % 
            % addBrickTechLayer requires these arguments
            %   1)  theName the name of the tech layer
            %   2)  theDXFName the associated DXF name
            %   3)  theGDSStream the associated GDS stream
            %   4)  theGDSData the associated GDS data
            %   5)  theGBRFilename the associated Gerber filename
            %   6) theLevel the starting metalization level index
            %
            % Example usage:
            %     Project.addBrickTechLayer('Brick-1', 'DXF', 0, ...
            %           1, 'GBRFilename', 0);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
            obj.GeometryBlock.addTechLayer('BRICK', theName, theDXFName, theGDSStream, ...
                 theGDSData, theGBRFilename, theLevel, 0);
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Get/Set Methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function set.HeaderBlock(obj,value)
            obj.HeaderBlock = value;
            
            % Replace the block in the cell array of blocks
            for iCounter=1:length(obj.CellArrayOfBlocks) %#ok<*MCSUP>
                if strcmp(class(obj.CellArrayOfBlocks{iCounter}),class(value))==1
                    obj.CellArrayOfBlocks{iCounter}=value;
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function set.DimensionBlock(obj,value)
            obj.DimensionBlock = value;
            
            % Replace the block in the cell array of blocks
            for iCounter=1:length(obj.CellArrayOfBlocks)
                if strcmp(class(obj.CellArrayOfBlocks{iCounter}),class(value))==1
                    obj.CellArrayOfBlocks{iCounter}=value;
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function set.FrequencyBlock(obj,value)
            obj.FrequencyBlock = value;
            
            % Replace the block in the cell array of blocks
            for iCounter=1:length(obj.CellArrayOfBlocks)
                if strcmp(class(obj.CellArrayOfBlocks{iCounter}),class(value))==1
                    obj.CellArrayOfBlocks{iCounter}=value;
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function set.ControlBlock(obj,value)
            obj.ControlBlock = value;
            
            % Replace the block in the cell array of blocks
            for iCounter=1:length(obj.CellArrayOfBlocks)
                if strcmp(class(obj.CellArrayOfBlocks{iCounter}),class(value))==1
                    obj.CellArrayOfBlocks{iCounter}=value;
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function set.GeometryBlock(obj,value)
            
            % Replace the block
            obj.GeometryBlock = value;
            
            % Replace the block in the cell array of blocks
            for iCounter=1:length(obj.CellArrayOfBlocks)
                if strcmp(class(obj.CellArrayOfBlocks{iCounter}),class(value))==1
                    obj.CellArrayOfBlocks{iCounter}=value;
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function set.OptimizationBlock(obj,value)
            obj.OptimizationBlock = value;
            
            % Replace the block in the cell array of blocks
            for iCounter=1:length(obj.CellArrayOfBlocks)
                if strcmp(class(obj.CellArrayOfBlocks{iCounter}),class(value))==1
                    obj.CellArrayOfBlocks{iCounter}=value;
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function set.VariableSweepBlock(obj,value)
            obj.VariableSweepBlock = value;
            
            % Replace the block in the cell array of blocks
            for iCounter=1:length(obj.CellArrayOfBlocks)
                if strcmp(class(obj.CellArrayOfBlocks{iCounter}),class(value))==1
                    obj.CellArrayOfBlocks{iCounter}=value;
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function set.FileOutBlock(obj,value)
            obj.FileOutBlock = value;
            
            % Replace the block in the cell array of blocks
            for iCounter=1:length(obj.CellArrayOfBlocks)
                if strcmp(class(obj.CellArrayOfBlocks{iCounter}),class(value))==1
                    obj.CellArrayOfBlocks{iCounter}=value;
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function set.ComponentFileBlock(obj,value)
            obj.ComponentFileBlock = value;
            
            % Replace the block in the cell array of blocks
            for iCounter=1:length(obj.CellArrayOfBlocks)
                if strcmp(class(obj.CellArrayOfBlocks{iCounter}),class(value))==1
                    obj.CellArrayOfBlocks{iCounter}=value;
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function set.CircuitElementsBlock(obj,value)
            obj.CircuitElementsBlock = value;
            
            % Replace the block in the cell array of blocks
            for iCounter=1:length(obj.CellArrayOfBlocks)
                if strcmp(class(obj.CellArrayOfBlocks{iCounter}),class(value))==1
                    obj.CellArrayOfBlocks{iCounter}=value;
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function set.ParameterBlock(obj,value)
            obj.ParameterBlock = value;
            
            % Replace the block in the cell array of blocks
            for iCounter=1:length(obj.CellArrayOfBlocks)
                if strcmp(class(obj.CellArrayOfBlocks{iCounter}),class(value))==1
                    obj.CellArrayOfBlocks{iCounter}=value;
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function set.AutoDelete(obj,value)
            obj.AutoDelete = value;
            obj.GeometryBlock.AutoDelete=value;
        end
        
        
    end
    
    methods (Access = private)
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function checkOptimizationVariables(obj)
            if ~isempty(obj.OptimizationBlock) && obj.isGeometryProject
                iCounter=1;
                while iCounter<=length(obj.OptimizationBlock.VarsArray)
                    aParameterExists=false;
                    
                    for jCounter=1:length(obj.GeometryBlock.ArrayOfParameters)
                        if strcmp(obj.GeometryBlock.ArrayOfParameters{jCounter}.Parname,...
                            obj.OptimizationBlock.VarsArray{iCounter}.VariableName)==1
                            aParameterExists=true;
                            break;
                        end
                    end
                    
                    if aParameterExists==false
                        obj.OptimizationBlock.VarsArray(iCounter)=[];
                    else
                        iCounter=iCounter+1;
                    end
                end
            end
        end
    end
end