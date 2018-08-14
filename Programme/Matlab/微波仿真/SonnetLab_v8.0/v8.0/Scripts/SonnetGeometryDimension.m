classdef SonnetGeometryDimension < handle
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This class defines the values for an Dimension block
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
        
        Type
        
        Direction
        ReferencePolygon1
        ReferenceVertex1
        ReferencePolygon2
        ReferenceVertex2
        
        UnknownLines
        
        ParameterLabelXCoord
        ParameterLabelYCoord
    end
    
    properties (Dependent = true)
        NominalValue
        VariableSign
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = SonnetGeometryDimension(theFid)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Defines the constructor for the GEO DIM.
            % The constructor will be passed the file ID from the
            %     SONNET GEO object constructor.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if nargin == 1
                
                initialize(obj);
                
                % First read in the Type, Direction and Sign from the same line
                % that the DIM statement is on.
                obj.Type=fscanf(theFid,'%s',1);         % read in the type which for now should be STD
                obj.Direction=fscanf(theFid,'%s',1);    % read in the direction which should be XDIR or YDIR
                %obj.VariableSign=fscanf(theFid,'%d',1);         % read in the sign, should be either 1 or -1.
                
                % Now we will loop until we get to the end of the DIM block and
                % read in all the values from tags we find into properties.
                while (1==1)
                    
                    % Read a string from the file,  we will use this to determine what property needs to be modified by using a case statement.
                    aTempString=fscanf(theFid,'%s',1); 							% Read a Value from the file, we will be using this to drive the switch statment
                    
                    switch aTempString
                        case'POS'
                            obj.ParameterLabelXCoord=fscanf(theFid,'%f',1);
                            obj.ParameterLabelYCoord=fscanf(theFid,'%f',1);
                            
                        case'NOM'
                            %obj.NominalValue=fscanf(theFid,'%f',1);
                            
                        case 'REF1'
                            % Read the polygon ID, this will be replaced
                            % with a polygon reference when the geometry block
                            % is done constructing.
                            
                            % Read in the tag 'POLY' which we dont need to store
                            fscanf(theFid,'%s',1);
                            
                            % Read in the polygon ID
                            obj.ReferencePolygon1=fscanf(theFid,'%d',1);
                            
                            % Read in the number of points for the polygon (it is always one for a port)
                            fscanf(theFid,'%d',1);
                            
                            % Read in the vertex
                            obj.ReferenceVertex1=fscanf(theFid,'%d',1)+1;
                            
                            % Read the rest of the line (it is empty)
                            fgetl(theFid);
                            
                        case 'REF2'
                            % Read the polygon ID, this will be replaced
                            % with a polygon reference when the geometry block
                            % is done constructing.
                            
                            % Read in the tag 'POLY' which we dont need to store
                            fscanf(theFid,'%s',1);
                            
                            % Read in the polygon ID
                            obj.ReferencePolygon2=fscanf(theFid,'%d',1);
                            
                            % Read in the number of points for the polygon (it is always one for a port)
                            fscanf(theFid,'%d',1);
                            
                            % Read in the vertex
                            obj.ReferenceVertex2=fscanf(theFid,'%d',1)+1;
                            
                            % Read the rest of the line (it is empty)
                            fgetl(theFid);
                            
                        case 'END'
                            break;
                            
                        otherwise																% If we dont recognize the line then we want to save it so we can write it out again.
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
        function initialize(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function initializes the DIM properties to some default
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
            aNewObject=SonnetGeometryDimension();
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
            
            aSignature='DIM';
            
            if ~isempty(obj.Type)
                aTempString=SonnetStringWriteFormat(obj.Type);
                aSignature = [aSignature sprintf(' %s',aTempString)];
            end
            
            if ~isempty(obj.Direction)
                aSignature = [aSignature sprintf(' %s',obj.Direction)];
            end
            
            if ~isempty(obj.VariableSign)
                aSignature = [aSignature sprintf(' %d',obj.VariableSign)];
            end
            
            aSignature = [aSignature sprintf('\n')];
            
            if ~isempty(obj.ParameterLabelXCoord)
                aSignature = [aSignature sprintf('POS %.15g',obj.ParameterLabelXCoord)];
                aSignature = [aSignature sprintf(' %.15g\n',obj.ParameterLabelYCoord)];
            end
            
            if ~isempty(obj.NominalValue)
                aSignature = [aSignature sprintf( 'NOM %.15g\n',obj.NominalValue)];
            end
            
            if ~isempty(obj.ReferencePolygon1)
                aSignature = [aSignature sprintf('REF1 POLY %d 1\n%d\n',obj.ReferencePolygon1.DebugId,obj.ReferenceVertex1-1)];
            end
            
            if ~isempty(obj.ReferencePolygon2)
                aSignature = [aSignature sprintf('REF2 POLY %d 1\n%d\n',obj.ReferencePolygon2.DebugId,obj.ReferenceVertex2-1)];
            end
            
            if (~isempty(obj.UnknownLines))
                %aSignature = [aSignature strrep(obj.UnknownLines,'\n',sprintf('\n'))];
            end
            
            aSignature = [aSignature sprintf('END\n')];
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function set.NominalValue(obj,~) %#ok<MANU>
            warning 'NominalValue can not be directly changed. You may change the coordinates for the reference polygons' %#ok<*WNTAG>
        end
        function value = get.NominalValue(obj)
            
            % Check the reference points, it they are below 1 then throw an error
            if obj.ReferenceVertex1<1 || obj.ReferenceVertex2<1
                error('Reference point vertex may not less than one');
            end
            
            if strcmpi(obj.Direction,'XDIR')
                value=abs(obj.ReferencePolygon2.XCoordinateValues{obj.ReferenceVertex2}-...
                    obj.ReferencePolygon1.XCoordinateValues{obj.ReferenceVertex1});
            else
                value=abs(obj.ReferencePolygon2.YCoordinateValues{obj.ReferenceVertex2}-...
                    obj.ReferencePolygon1.YCoordinateValues{obj.ReferenceVertex1});
            end
        end
        function set.VariableSign(obj,~) %#ok<MANU>
            warning 'VariableSign can not be directly changed. You may change the coordinates for the reference polygons' %#ok<*WNTAG>
        end
        function value = get.VariableSign(obj)
            
            % Check the reference points, it they are below 1 then throw an error
            if obj.ReferenceVertex1<1 || obj.ReferenceVertex2<1
                error('Reference point vertex may not less than one');
            end
            
            if strcmpi(obj.Direction,'XDIR')
                value=sign(obj.ReferencePolygon2.XCoordinateValues{obj.ReferenceVertex2}-...
                    obj.ReferencePolygon1.XCoordinateValues{obj.ReferenceVertex1});
            else
                value=sign(obj.ReferencePolygon2.YCoordinateValues{obj.ReferenceVertex2}-...
                    obj.ReferencePolygon1.YCoordinateValues{obj.ReferenceVertex1});
            end
        end
        
    end
end

