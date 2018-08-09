classdef SonnetGeometryPort < handle
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This class defines the values for a port in the
    % Geometry block of the Sonnnet project file.
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
        Polygon
        Vertex
        PortNumber
        
        Resistance
        Reactance
        Inductance
        Capacitance
        
        GroupName
        GroupId
        TypeOfReferencePlane
        ReferencePlaneOrCalibrationLength
        CalibrationLength
        
        DiagonalAllowed
        ReferencePlaneLength
        ReferencePlaneLink
        
    end
    
    properties (Dependent = true)
        
        XCoordinate
        YCoordinate
        
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = SonnetGeometryPort(theFid)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % define the constructor for the port.
            %     the constructor will be passed the file ID from the
            %     SONNET GEO object constructor.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if nargin == 1        %if we were passed 1 argument which means we go the theFid
                
                initialize(obj);
                
                obj.Type=fscanf(theFid,' %s',1);
                
                % If the type is CUP then we need to read in the group name
                if strcmp('CUP',obj.Type)==1
                    obj.GroupName=fscanf(theFid,' %s',1);
                end
                
                % Sonnet version 13 projects may have the next keyword
                % be "DIAGALLOWED Y/N" which indicates if the port
                % utilizes a diagonal reference plane. If this isn't
                % present then the next keyword is 'POLY' which links
                % the port to a polygon. 
                if strcmp(fscanf(theFid,'%s',1),'DIAGALLOWED')==1
                    if strcmp(fscanf(theFid,'%s',1),'Y')==1
                        obj.DiagonalAllowed=true;
                    else
                        obj.DiagonalAllowed=false;
                    end
                    fscanf(theFid,'%s',1); % Read 'POLY'
                end
                
                % Read in the polygon ID
                obj.Polygon=fscanf(theFid,'%d',1);
                
                % Read in the number of points for the polygon (it is always one for a port)
                fscanf(theFid,'%d',1);
                
                % Read in the vertex
                obj.Vertex=fscanf(theFid,'%d',1)+1;
                
                % Read the rest of the line (it is empty)
                fgetl(theFid);
                
                obj.PortNumber=fscanf(theFid,' %d',1);
                obj.Resistance=fscanf(theFid,' %f',1);
                obj.Reactance=fscanf(theFid,' %f',1);
                obj.Inductance=fscanf(theFid,' %f',1);
                obj.Capacitance=fscanf(theFid,' %f',1);
                fscanf(theFid,' %f',1);
                fscanf(theFid,' %f',1);
                
                if strcmp(obj.Type,'AGND');
                    obj.TypeOfReferencePlane=fscanf(theFid,' %s',1);
                    obj.ReferencePlaneOrCalibrationLength=fscanf(theFid,' %f',1);
                    obj.CalibrationLength=fscanf(theFid,' %f',1);
                end
                
                % Sonnet version 13 projects may have an additional
                % keyword here that defines a reference plane specific
                % to this port.
                aBackupOfTheFid=ftell(theFid);          	     
                aTempString=fscanf(theFid,' %s',1);              
                fseek(theFid,aBackupOfTheFid,'bof');	         
                if strcmpi(aTempString,'FIX')==1
                    fscanf(theFid,' %s',1);
                    obj.ReferencePlaneLength=fscanf(theFid,'%g',1);
                elseif strcmpi(aTempString,'LINK')==1
                    fscanf(theFid,' %s',1);
                    obj.ReferencePlaneLink=fscanf(theFid,'%d',1);
                end
                
            else
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % we come here when we didn't recieve a file ID as an argument
                % which means that we are going to create a default port object with
                % default values by calling the function's initialize method.
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                initialize(obj);
                
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function initialize(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function initializes the port properties to some default
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
            aNewObject=SonnetGeometryPort();
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
            
            aSignature='POR1 ';
            
            if ~isempty(obj.Type)
                aSignature=[aSignature sprintf('%s',obj.Type)];
            end
            
            if strcmp(obj.Type,'CUP')==1 % Print out the group ID if it is of type CUP
                aTempString=SonnetStringWriteFormat(strrep(obj.GroupName,'"',''));
                if theVersion <13
                    aSignature=[aSignature sprintf(' "%s"',aTempString)];
                else
                    aSignature=[aSignature sprintf(' %s',aTempString)];
                end
            end
            
            aSignature=[aSignature sprintf('\n')];
            
            if ~isempty(obj.DiagonalAllowed)
                if obj.DiagonalAllowed
                    aSignature = [aSignature sprintf('DIAGALLOWED Y\n')];
                else
                    aSignature = [aSignature sprintf('DIAGALLOWED N\n')];
                end
            end
            
            if ~isempty(obj.Polygon)
                aSignature = [aSignature sprintf('POLY %d 1\n%d\n',obj.Polygon.DebugId,obj.Vertex-1)];
            end
            
            if ~isempty(obj.PortNumber)
                aSignature=[aSignature sprintf('%d',obj.PortNumber)];
            end
            
            if ~isempty(obj.Resistance)
                aSignature=[aSignature sprintf(' %.15g',obj.Resistance)];
            end
            
            if ~isempty(obj.Reactance)
                aSignature=[aSignature sprintf(' %.15g',obj.Reactance)];
            end
            
            if ~isempty(obj.Inductance)
                aSignature=[aSignature sprintf(' %.15g',obj.Inductance)];
            end
            
            if ~isempty(obj.Capacitance)
                aSignature=[aSignature sprintf(' %.15g',obj.Capacitance)];
            end
            
            if ~isempty(obj.XCoordinate)
                aSignature=[aSignature sprintf(' %.15g',obj.XCoordinate)];
            end
            
            if ~isempty(obj.YCoordinate)
                aSignature=[aSignature sprintf(' %.15g',obj.YCoordinate)];
            end
            
            if ~isempty(obj.TypeOfReferencePlane)
                aSignature=[aSignature sprintf(' %s',obj.TypeOfReferencePlane)];
            end
            
            if ~isempty(obj.ReferencePlaneOrCalibrationLength)
                aSignature=[aSignature sprintf(' %.15g',obj.ReferencePlaneOrCalibrationLength)];
            end
            
            if ~isempty(obj.CalibrationLength)
                aSignature=[aSignature sprintf(' %.15g',obj.CalibrationLength)];
            end
            
            if ~isempty(obj.ReferencePlaneLength)
                aSignature=[aSignature sprintf(' FIX %.15g',obj.ReferencePlaneLength)];
            end
            
            if ~isempty(obj.ReferencePlaneLink)
                aSignature=[aSignature sprintf(' LINK %d',obj.ReferencePlaneLink.DebugId)];
            end
            
            aSignature=[aSignature sprintf('\n')];
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function isStandard=isStandard(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Returns true if the port is standard
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if strcmpi(obj.Type, 'STD')==1
                isStandard=true;
            else
                isStandard=false;
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function isGrounded=isAutoGrounded(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Returns true if the polygon is a brick polygon
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if strcmpi(obj.Type, 'AGND')==1
                isGrounded=true;
            else
                isGrounded=false;
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function isCocalibrated=isCocalibrated(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Returns true if the polygon is a via polygon
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if strcmpi(obj.Type, 'CUP')==1
                isCocalibrated=true;
            else
                isCocalibrated=false;
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function convertToStandard(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Converts the port into a standard port
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.Type='STD';
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function convertToAutoGrounded(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Converts the port into a autogrounded port
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.Type='AGND';
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function convertToCocalibrated(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Converts the port into a cocalibrated port
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.Type='CUP';
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aPortXLocation=computeXCoordinate(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Returns the X coordinate for the polygon
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            aPortXLocation = (obj.Polygon.XCoordinateValues{obj.Vertex}+obj.Polygon.XCoordinateValues{obj.Vertex+1})/2;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aPortYLocation=computeYCoordinate(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Returns the y coordinate for the polygon
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            aPortYLocation = (obj.Polygon.YCoordinateValues{obj.Vertex}+obj.Polygon.YCoordinateValues{obj.Vertex+1})/2;
        end
                
        function set.XCoordinate(obj,~) %#ok<MANU>
            warning 'XCoordinate can not be directly changed. You may change the coordinates for the attached polygon' %#ok<*WNTAG>
        end
        function set.YCoordinate(obj,~) %#ok<MANU>
            warning 'YCoordinate can not be directly changed. You may change the coordinates for the attached polygon'
        end
        function value = get.XCoordinate(obj)
            value=computeXCoordinate(obj);
        end
        function value = get.YCoordinate(obj)
            value=computeYCoordinate(obj);
        end
        
    end
end
