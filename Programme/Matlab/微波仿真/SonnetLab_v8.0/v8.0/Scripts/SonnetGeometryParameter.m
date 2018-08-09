classdef SonnetGeometryParameter < handle
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This class defines the values for an geometry parameter
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
        
        Parname
        Partype
        Direction
        Scaletype
        
        Equation
        
        ReferencePolygon1
        ReferenceVertex1
        ReferencePolygon2
        ReferenceVertex2
        PointSet1
        PointSet2
        
        UnknownLines
        
        ParameterLabelXCoord
        ParameterLabelYCoord
        
        IsNominalValueUpdated

    end
    properties (SetObservable)
        NominalValue
    end
    
    events
        NominalValueChanged
    end
    
    properties (Dependent = true)        
        VariableSign
    end
    
    properties (Access = protected)
        NominalOverride
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = SonnetGeometryParameter(theFid)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Defines the constructor for the GEOVAR.
            % The constructor will be passed the file ID from the
            %     SONNET GEO object constructor.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if nargin == 1          % if we were passed 1 argument which means we got the theFid
                
                initialize(obj);
                
                % First read in the Type, Direction and Sign from the same line
                % that the Geovar statement is on.
                obj.Parname=fscanf(theFid,' %s',1);     % The name of the parameter
                obj.Partype=fscanf(theFid,' %s',1);     % This field is either ANC for an anchored parameter, SYM for a symmetric parameter or RAD for a radial parameter.
                obj.Direction=fscanf(theFid,' %s',1);   % Read in the direction which should be XDIR or YDIR
                fscanf(theFid,' %d',1);     % Read in the sign, should be either 1 or -1.
                obj.Scaletype=strtrim(fgetl(theFid));   % This field indicates if and how scaling is applied to a dimension parameter when its size is changed
                
                % Now we will loop until we get to the end of the Geovar block and
                % read in all the values from tags we find into properties.
                
                while(1==1)
                    
                    % Read a string from the file,  we will use this to determine what property needs to be modified by using a case statement.
                    aTempString=fscanf(theFid,'%s',1); 			% Read a Value from the file, we will be using this to drive the switch statment
                    
                    switch aTempString
                        case'POS'
                            obj.ParameterLabelXCoord=fscanf(theFid,'%f',1);
                            obj.ParameterLabelYCoord=fscanf(theFid,'%f',1);
                            
                        case'NOM'
                            fscanf(theFid,'%f',1);
                            
                        case 'REF1'
                            % Read in the tag 'POLY' which we dont need to store
                            fscanf(theFid,'%s',1);
                            
                            % Read in the polygon ID; this will be replaced
                            % by a polygon reference when the geometry
                            % block is done constructing
                            obj.ReferencePolygon1=fscanf(theFid,'%d',1);
                            
                            % Read in the number of points for the polygon; this is always one
                            fscanf(theFid,'%d',1);
                            
                            % Read in the vertices for the polygon
                            obj.ReferenceVertex1=fscanf(theFid,'%d',1)+1;
                            
                            % Grab the END tag for the POLY
                            fgetl(theFid);
                            
                        case 'REF2'
                            % Read in the tag 'POLY' which we dont need to store
                            fscanf(theFid,'%s',1);
                            
                            % Read in the polygon ID; this will be replaced
                            % by a polygon reference when the geometry
                            % block is done constructing
                            obj.ReferencePolygon2=fscanf(theFid,'%d',1);
                            
                            % Read in the number of points for the polygon; this is always one
                            fscanf(theFid,'%d',1);
                            
                            % Read in the vertices for the polygon
                            obj.ReferenceVertex2=fscanf(theFid,'%d',1)+1;
                            
                            % Grab the END tag for the POLY
                            fgetl(theFid);
                            
                        case 'EQN'
                            obj.Equation=fgetl(theFid);
                            
                        case 'PS1'
                            obj.PointSet1=SonnetGeometryParameterPointSet(theFid);
                            
                        case 'PS2'
                            obj.PointSet2=SonnetGeometryParameterPointSet(theFid);
                            
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
            
            obj.NominalOverride = false;            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function initialize(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function initializes the GEOVAR properties to some default
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
            
            obj.IsNominalValueUpdated = false;
            
            warning(aBackup);                        
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aNewObject=clone(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function builds a deep copy of this object
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            aNewObject=SonnetGeometryParameter();
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
            
            if ~isempty(obj.Parname)
                aTempString=SonnetStringWriteFormat(obj.Parname);
                aSignature = sprintf('GEOVAR %s',aTempString);
            end
            
            if ~isempty(obj.Partype)
                aTempString=SonnetStringWriteFormat(obj.Partype);
                aSignature = [aSignature sprintf(' %s',aTempString)];
            end
            
            if ~isempty(obj.Direction)
                aSignature = [aSignature sprintf(' %s',obj.Direction)];
            end
            
            if ~isempty(obj.VariableSign)
                aSignature = [aSignature sprintf(' %d',obj.VariableSign)];
            end
            
            if ~isempty(obj.Scaletype)
                aSignature = [aSignature sprintf(' %s',obj.Scaletype)];
            end
            
            aSignature = [aSignature sprintf(' \n')];
            
            if ~isempty(obj.ParameterLabelXCoord)
                aSignature = [aSignature sprintf('POS %.15g',obj.ParameterLabelXCoord)];
                aSignature = [aSignature sprintf(' %.15g\n',obj.ParameterLabelYCoord)];
            end
            
            if ~isempty(obj.NominalValue)
                aSignature = [aSignature sprintf('NOM %.15g\n',obj.NominalValue)];
            end
            
            if ~isempty(obj.ReferencePolygon1)
                aSignature = [aSignature sprintf('REF1 POLY %d 1\n%d\n',obj.ReferencePolygon1.DebugId,obj.ReferenceVertex1-1)];
            end
            
            if ~isempty(obj.ReferencePolygon2)
                aSignature = [aSignature sprintf('REF2 POLY %d 1\n%d\n',obj.ReferencePolygon2.DebugId,obj.ReferenceVertex2-1)];
            end
            
            if ~isempty(obj.Equation)
                if isa(obj.Equation,'char')
                    aSignature = [aSignature sprintf( 'EQN %s\n',obj.Equation)];
                else
                    aSignature = [aSignature sprintf( 'EQN %.15g\n',obj.Equation)];
                end
            end
            
            if ~isempty(obj.PointSet1)
                aSignature = [aSignature sprintf('PS1 ')];
                aSignature = [aSignature obj.PointSet1.stringSignature(theVersion)];
            end
            
            if ~isempty(obj.PointSet2)
                aSignature = [aSignature sprintf('PS2 ')];
                aSignature = [aSignature obj.PointSet2.stringSignature(theVersion)];
            end
            
            if (~isempty(obj.UnknownLines))
                aSignature = [aSignature strrep(obj.UnknownLines,'\n',sprintf('\n'))];
            end
            
            aSignature = [aSignature sprintf('END\n')];
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function setMovePointsSameDistance(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function sets the scaling such
            %   that there is no scaling.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.Scaletype='NSCD';
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function setScalePointsInOneDirection(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function sets the scaling such
            %   that there is in direction of movement.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.Scaletype='SCUNI';
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function setScalePointsInBothDirection(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function sets the scaling such
            %   that there is scaling in x and y.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.Scaletype='SCXY';
        end
           
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function set.NominalValue(obj, theNominalValue) 
            if ~isempty(theNominalValue)
                obj.NominalOverride = true;

                aCanNotifyChange = false;

                if isempty(obj.NominalValue) || (obj.NominalValue ~= theNominalValue)
                    aCanNotifyChange = true;
                end

                obj.NominalValue = theNominalValue;

                if aCanNotifyChange == true 
                    if ~obj.IsNominalValueUpdated
                        notify(obj, 'NominalValueChanged');
                    end
                end
            end
            % warning 'NominalValue cannot be directly changed. You may change the coordinates for the reference polygons or the variable to which the parameter is assigned.' %#ok<*WNTAG>
            % warning 'NominalValue can not be directly changed. You may change the coordinates for the reference polygons' %#ok<*WNTAG>
        end
        
        function value = get.NominalValue(obj)   
            if (~obj.NominalOverride)                
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
            else
                value = obj.NominalValue;
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
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeValue(obj,theVariables)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function will change the value of a geometry
            % parameter and adjust the coordinate values of the
            % polygon(s).
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if isempty(obj.Equation)
                for iCounter=1:length(theVariables)
                    if strcmpi(obj.Parname,theVariables{iCounter}.VariableName)==1
                        theNewValue=theVariables{iCounter}.Value*obj.VariableSign;
                    end
                end
            else
                iVariableCounter=1;
                aNumberOfEvalutatedVariables=0;
                while true
                    
                    % Try to determine the variable's value. If we
                    % can not determine the value (because it depends
                    % on another variable) then decrement the number of
                    % variables we have evaluated so far so that it remains
                    % unchanged when we increment the number.
                    try
                        aValue=strrep(num2str(theVariables{iVariableCounter}.Value),'"','');
                        eval([theVariables{iVariableCounter}.VariableName '=' aValue ';']);
                    catch e
                        aNumberOfEvalutatedVariables=aNumberOfEvalutatedVariables-1;
                    end
                    
                    % Increment the number of variables evaluated. If we have
                    % evaluated all of them then leave the loop.
                    aNumberOfEvalutatedVariables=aNumberOfEvalutatedVariables+1;
                    if aNumberOfEvalutatedVariables == length(theVariables)
                        break;
                    end
                    
                    % Increment the variable counter; if it overflows
                    % then start at the beginning of the variable
                    % array again.
                    iVariableCounter=iVariableCounter+1;
                    if iVariableCounter > length(theVariables)
                        iVariableCounter=1;
                        aNumberOfEvalutatedVariables=0;
                    end
                end
                
                % Assign the variables its new value
                aEquation=strrep(num2str(obj.Equation),'"','');
                theNewValue=eval(aEquation)*obj.VariableSign; % Need to multiply by the sign so the direction is consistent with the nominal value's direction
                
            end
            
            aOldValue=obj.NominalValue*obj.VariableSign;
            
            % Get the anchor position
            if strcmpi(obj.Partype,'ANC')
                aChange=theNewValue-aOldValue;
                aAnchorX=obj.ReferencePolygon1.XCoordinateValues{obj.ReferenceVertex1};
                aAnchorY=obj.ReferencePolygon1.YCoordinateValues{obj.ReferenceVertex1};
            elseif strcmpi(obj.Partype,'SYM')
                aChange=(theNewValue-aOldValue)/2;
                aAnchorX=(obj.ReferencePolygon1.XCoordinateValues{obj.ReferenceVertex1}+...
                    obj.ReferencePolygon2.XCoordinateValues{obj.ReferenceVertex2})/2;
                aAnchorY=(obj.ReferencePolygon1.YCoordinateValues{obj.ReferenceVertex1}+...
                    obj.ReferencePolygon2.YCoordinateValues{obj.ReferenceVertex2})/2;
            else
                return
            end
            
            if strcmpi(obj.Direction,'XDIR')
                
                switch strtrim(obj.Scaletype)
                    case 'NSCD'
                        if strcmpi(obj.Partype,'ANC')
                            
                            % Change the value for the second reference point
                            obj.ReferencePolygon2.XCoordinateValues{obj.ReferenceVertex2}=...
                                obj.ReferencePolygon2.XCoordinateValues{obj.ReferenceVertex2}+aChange;
                            
                            % Make the last point in polygon equal to the first point in the polygon
                            % Even if the modified point isnt the first vertex this won't mess anything up
                            obj.ReferencePolygon2.XCoordinateValues{length(obj.ReferencePolygon2.XCoordinateValues)}=...
                                obj.ReferencePolygon2.XCoordinateValues{1};
                            
                        elseif strcmpi(obj.Partype,'SYM')
                            
                            % Change the value for the reference points
                            obj.ReferencePolygon1.XCoordinateValues{obj.ReferenceVertex1}=...
                                obj.ReferencePolygon1.XCoordinateValues{obj.ReferenceVertex1}-aChange;
                            obj.ReferencePolygon2.XCoordinateValues{obj.ReferenceVertex2}=...
                                obj.ReferencePolygon2.XCoordinateValues{obj.ReferenceVertex2}+aChange;
                            
                            % Make the last point in polygon equal to the first point in the polygon
                            % Even if the modified point isnt the first vertex this won't mess anything up
                            obj.ReferencePolygon1.XCoordinateValues{length(obj.ReferencePolygon1.XCoordinateValues)}=...
                                obj.ReferencePolygon1.XCoordinateValues{1};
                            
                            % Make the last point in polygon equal to the first point in the polygon
                            % Even if the modified point isnt the first vertex this won't mess anything up
                            obj.ReferencePolygon2.XCoordinateValues{length(obj.ReferencePolygon2.XCoordinateValues)}=...
                                obj.ReferencePolygon2.XCoordinateValues{1};
                            
                        else
                            error('Unsupported type');
                        end
                        
                        for iCounter=1:length(obj.PointSet1.ArrayOfPolygons)
                            aPolygon=obj.PointSet1.ArrayOfPolygons{iCounter};
                            for kCounter=1:length(obj.PointSet1.ArrayOfVertexVectors{iCounter})
                                % Check if the point is the reference point in which case dont move it
                                if (aPolygon == obj.ReferencePolygon1 && obj.PointSet1.ArrayOfVertexVectors{iCounter}(kCounter) == obj.ReferenceVertex1) ||...
                                        (aPolygon == obj.ReferencePolygon2 && obj.PointSet1.ArrayOfVertexVectors{iCounter}(kCounter) == obj.ReferenceVertex2)
                                else
                                    aPolygon.XCoordinateValues{obj.PointSet1.ArrayOfVertexVectors{iCounter}(kCounter)}=aPolygon.XCoordinateValues{obj.PointSet1.ArrayOfVertexVectors{iCounter}(kCounter)}-aChange;
                                end
                            end
                            aPolygon.XCoordinateValues{length(aPolygon.XCoordinateValues)}=aPolygon.XCoordinateValues{1};
                        end
                        for iCounter=1:length(obj.PointSet2.ArrayOfPolygons)
                            aPolygon=obj.PointSet2.ArrayOfPolygons{iCounter};
                            for kCounter=1:length(obj.PointSet2.ArrayOfVertexVectors{iCounter})
                                % Check if the point is the reference point in which case dont move it
                                if (aPolygon == obj.ReferencePolygon1 && obj.PointSet2.ArrayOfVertexVectors{iCounter}(kCounter) == obj.ReferenceVertex1) ||...
                                        (aPolygon == obj.ReferencePolygon2 && obj.PointSet2.ArrayOfVertexVectors{iCounter}(kCounter) == obj.ReferenceVertex2)
                                else
                                    aPolygon.XCoordinateValues{obj.PointSet2.ArrayOfVertexVectors{iCounter}(kCounter)}=aPolygon.XCoordinateValues{obj.PointSet2.ArrayOfVertexVectors{iCounter}(kCounter)}+aChange;
                                end
                            end
                            aPolygon.XCoordinateValues{length(aPolygon.XCoordinateValues)}=aPolygon.XCoordinateValues{1};
                        end
                        
                    case 'SCUNI'
                        aScaleFactor=theNewValue/aOldValue;
                        if strcmpi(obj.Partype,'ANC')
                            % Change the value for the second reference point
                            aDistanceFromAnchor=aAnchorX-obj.ReferencePolygon2.XCoordinateValues{obj.ReferenceVertex2};
                            aDistanceToMove=aDistanceFromAnchor*aScaleFactor;
                            obj.ReferencePolygon2.XCoordinateValues{obj.ReferenceVertex2}=aAnchorX-aDistanceToMove;
                            
                            % Make the last point in polygon equal to the first point in the polygon
                            % Even if the modified point isnt the first vertex this won't mess anything up
                            obj.ReferencePolygon2.XCoordinateValues{length(obj.ReferencePolygon2.XCoordinateValues)}=...
                                obj.ReferencePolygon2.XCoordinateValues{1};
                            
                        elseif strcmpi(obj.Partype,'SYM')
                            % Change the value for the reference points
                            aDistanceFromAnchor=aAnchorX-obj.ReferencePolygon1.XCoordinateValues{obj.ReferenceVertex1};
                            aDistanceToMove=aDistanceFromAnchor*aScaleFactor;
                            obj.ReferencePolygon1.XCoordinateValues{obj.ReferenceVertex1}=aAnchorX-aDistanceToMove;
                            aDistanceFromAnchor=aAnchorX-obj.ReferencePolygon2.XCoordinateValues{obj.ReferenceVertex2};
                            aDistanceToMove=aDistanceFromAnchor*aScaleFactor;
                            obj.ReferencePolygon2.XCoordinateValues{obj.ReferenceVertex2}=aAnchorX-aDistanceToMove;
                            
                            % Make the last point in polygon equal to the first point in the polygon
                            % Even if the modified point isnt the first vertex this won't mess anything up
                            obj.ReferencePolygon1.XCoordinateValues{length(obj.ReferencePolygon1.XCoordinateValues)}=...
                                obj.ReferencePolygon1.XCoordinateValues{1};
                            
                            % Make the last point in polygon equal to the first point in the polygon
                            % Even if the modified point isnt the first vertex this won't mess anything up
                            obj.ReferencePolygon2.XCoordinateValues{length(obj.ReferencePolygon2.XCoordinateValues)}=...
                                obj.ReferencePolygon2.XCoordinateValues{1};
                            
                        else
                            error('Unsupported type');
                        end
                        
                        for iCounter=1:length(obj.PointSet1.ArrayOfPolygons)
                            aPolygon=obj.PointSet1.ArrayOfPolygons{iCounter};
                            for kCounter=1:length(obj.PointSet1.ArrayOfVertexVectors{iCounter})
                                % Check if the point is the reference point in which case dont move it
                                if (aPolygon == obj.ReferencePolygon1 && obj.PointSet1.ArrayOfVertexVectors{iCounter}(kCounter) == obj.ReferenceVertex1) ||...
                                        (aPolygon == obj.ReferencePolygon2 && obj.PointSet1.ArrayOfVertexVectors{iCounter}(kCounter) == obj.ReferenceVertex2)
                                else
                                    aDistanceFromAnchor=aAnchorX-aPolygon.XCoordinateValues{obj.PointSet1.ArrayOfVertexVectors{iCounter}(kCounter)};
                                    aDistanceToMove=aDistanceFromAnchor*aScaleFactor;
                                    aPolygon.XCoordinateValues{obj.PointSet1.ArrayOfVertexVectors{iCounter}(kCounter)}=aAnchorX-aDistanceToMove;
                                end
                            end
                            aPolygon.XCoordinateValues{length(aPolygon.XCoordinateValues)}=aPolygon.XCoordinateValues{1};
                        end
                        for iCounter=1:length(obj.PointSet2.ArrayOfPolygons)
                            aPolygon=obj.PointSet2.ArrayOfPolygons{iCounter};
                            for kCounter=1:length(obj.PointSet2.ArrayOfVertexVectors{iCounter})
                                % Check if the point is the reference point in which case dont move it
                                if (aPolygon == obj.ReferencePolygon1 && obj.PointSet2.ArrayOfVertexVectors{iCounter}(kCounter) == obj.ReferenceVertex1) ||...
                                        (aPolygon == obj.ReferencePolygon2 && obj.PointSet2.ArrayOfVertexVectors{iCounter}(kCounter) == obj.ReferenceVertex2)
                                else
                                    aDistanceFromAnchor=aAnchorX-aPolygon.XCoordinateValues{obj.PointSet2.ArrayOfVertexVectors{iCounter}(kCounter)};
                                    aDistanceToMove=aDistanceFromAnchor*aScaleFactor;
                                    aPolygon.XCoordinateValues{obj.PointSet2.ArrayOfVertexVectors{iCounter}(kCounter)}=aAnchorX-aDistanceToMove;
                                end
                            end
                            aPolygon.XCoordinateValues{length(aPolygon.XCoordinateValues)}=aPolygon.XCoordinateValues{1};
                        end
                        
                    case 'SCXY'
                        aScaleFactor=theNewValue/aOldValue;
                        if strcmpi(obj.Partype,'ANC')
                            % Change the value for the second reference point
                            aDistanceFromAnchor=aAnchorX-obj.ReferencePolygon2.XCoordinateValues{obj.ReferenceVertex2};
                            aDistanceToMove=aDistanceFromAnchor*aScaleFactor;
                            obj.ReferencePolygon2.XCoordinateValues{obj.ReferenceVertex2}=aAnchorX-aDistanceToMove;
                            
                            aDistanceFromAnchor=aAnchorY-obj.ReferencePolygon2.YCoordinateValues{obj.ReferenceVertex2};
                            aDistanceToMove=aDistanceFromAnchor*aScaleFactor;
                            obj.ReferencePolygon2.YCoordinateValues{obj.ReferenceVertex2}=aAnchorY-aDistanceToMove;
                            
                            % Make the last point in polygon equal to the first point in the polygon
                            % Even if the modified point isnt the first vertex this won't mess anything up
                            obj.ReferencePolygon2.XCoordinateValues{length(obj.ReferencePolygon2.XCoordinateValues)}=...
                                obj.ReferencePolygon2.XCoordinateValues{1};
                            obj.ReferencePolygon2.YCoordinateValues{length(obj.ReferencePolygon2.YCoordinateValues)}=...
                                obj.ReferencePolygon2.YCoordinateValues{1};  
                            
                        elseif strcmpi(obj.Partype,'SYM')
                            % Change the value for the reference points
                            aDistanceFromAnchor=aAnchorX-obj.ReferencePolygon1.XCoordinateValues{obj.ReferenceVertex1};
                            aDistanceToMove=aDistanceFromAnchor*aScaleFactor;
                            obj.ReferencePolygon1.XCoordinateValues{obj.ReferenceVertex1}=aAnchorX-aDistanceToMove;
                            aDistanceFromAnchor=aAnchorX-obj.ReferencePolygon2.XCoordinateValues{obj.ReferenceVertex2};
                            aDistanceToMove=aDistanceFromAnchor*aScaleFactor;
                            obj.ReferencePolygon2.XCoordinateValues{obj.ReferenceVertex2}=aAnchorX-aDistanceToMove;
                            
                            aDistanceFromAnchor=aAnchorY-obj.ReferencePolygon1.YCoordinateValues{obj.ReferenceVertex1};
                            aDistanceToMove=aDistanceFromAnchor*aScaleFactor;
                            obj.ReferencePolygon1.YCoordinateValues{obj.ReferenceVertex1}=aAnchorY-aDistanceToMove;
                            aDistanceFromAnchor=aAnchorY-obj.ReferencePolygon2.YCoordinateValues{obj.ReferenceVertex2};
                            aDistanceToMove=aDistanceFromAnchor*aScaleFactor;
                            obj.ReferencePolygon2.YCoordinateValues{obj.ReferenceVertex2}=aAnchorY-aDistanceToMove;
                            
                            % Make the last point in polygon equal to the first point in the polygon
                            % Even if the modified point isnt the first vertex this won't mess anything up
                            obj.ReferencePolygon1.XCoordinateValues{length(obj.ReferencePolygon1.XCoordinateValues)}=...
                                obj.ReferencePolygon1.XCoordinateValues{1};
                            obj.ReferencePolygon1.YCoordinateValues{length(obj.ReferencePolygon1.YCoordinateValues)}=...
                                obj.ReferencePolygon1.YCoordinateValues{1};
                            
                            % Make the last point in polygon equal to the first point in the polygon
                            % Even if the modified point isnt the first vertex this won't mess anything up
                            obj.ReferencePolygon2.XCoordinateValues{length(obj.ReferencePolygon2.XCoordinateValues)}=...
                                obj.ReferencePolygon2.XCoordinateValues{1};
                            obj.ReferencePolygon2.YCoordinateValues{length(obj.ReferencePolygon2.YCoordinateValues)}=...
                                obj.ReferencePolygon2.YCoordinateValues{1};
                            
                        else
                            error('Unsupported type');
                        end
                        
                        for iCounter=1:length(obj.PointSet1.ArrayOfPolygons)
                            aPolygon=obj.PointSet1.ArrayOfPolygons{iCounter};
                            for kCounter=1:length(obj.PointSet1.ArrayOfVertexVectors{iCounter})
                                % Check if the point is the reference point in which case dont move it
                                if (aPolygon == obj.ReferencePolygon1 && obj.PointSet1.ArrayOfVertexVectors{iCounter}(kCounter) == obj.ReferenceVertex1) ||...
                                        (aPolygon == obj.ReferencePolygon2 && obj.PointSet1.ArrayOfVertexVectors{iCounter}(kCounter) == obj.ReferenceVertex2)
                                else
                                    aDistanceFromAnchor=aAnchorX-aPolygon.XCoordinateValues{obj.PointSet1.ArrayOfVertexVectors{iCounter}(kCounter)};
                                    aDistanceToMove=aDistanceFromAnchor*aScaleFactor;
                                    aPolygon.XCoordinateValues{obj.PointSet1.ArrayOfVertexVectors{iCounter}(kCounter)}=aAnchorX-aDistanceToMove;
                                    
                                    aDistanceFromAnchor=aAnchorY-aPolygon.YCoordinateValues{obj.PointSet1.ArrayOfVertexVectors{iCounter}(kCounter)};
                                    aDistanceToMove=aDistanceFromAnchor*aScaleFactor;
                                    aPolygon.YCoordinateValues{obj.PointSet1.ArrayOfVertexVectors{iCounter}(kCounter)}=aAnchorY-aDistanceToMove;
                                end
                            end
                            aPolygon.XCoordinateValues{length(aPolygon.XCoordinateValues)}=aPolygon.XCoordinateValues{1};
                            aPolygon.YCoordinateValues{length(aPolygon.YCoordinateValues)}=aPolygon.YCoordinateValues{1};
                        end
                        for iCounter=1:length(obj.PointSet2.ArrayOfPolygons)
                            aPolygon=obj.PointSet2.ArrayOfPolygons{iCounter};
                            for kCounter=1:length(obj.PointSet2.ArrayOfVertexVectors{iCounter})
                                % Check if the point is the reference point in which case dont move it
                                if (aPolygon == obj.ReferencePolygon1 && obj.PointSet2.ArrayOfVertexVectors{iCounter}(kCounter) == obj.ReferenceVertex1) ||...
                                        (aPolygon == obj.ReferencePolygon2 && obj.PointSet2.ArrayOfVertexVectors{iCounter}(kCounter) == obj.ReferenceVertex2)
                                else
                                    aDistanceFromAnchor=aAnchorX-aPolygon.XCoordinateValues{obj.PointSet2.ArrayOfVertexVectors{iCounter}(kCounter)};
                                    aDistanceToMove=aDistanceFromAnchor*aScaleFactor;
                                    aPolygon.XCoordinateValues{obj.PointSet2.ArrayOfVertexVectors{iCounter}(kCounter)}=aAnchorX-aDistanceToMove;
                                    
                                    aDistanceFromAnchor=aAnchorY-aPolygon.YCoordinateValues{obj.PointSet2.ArrayOfVertexVectors{iCounter}(kCounter)};
                                    aDistanceToMove=aDistanceFromAnchor*aScaleFactor;
                                    aPolygon.YCoordinateValues{obj.PointSet2.ArrayOfVertexVectors{iCounter}(kCounter)}=aAnchorY-aDistanceToMove;
                                end
                            end
                            aPolygon.XCoordinateValues{length(aPolygon.XCoordinateValues)}=aPolygon.XCoordinateValues{1};
                            aPolygon.YCoordinateValues{length(aPolygon.YCoordinateValues)}=aPolygon.YCoordinateValues{1};
                        end
                end
                
            else % If the direction is YDIR
                
                switch strtrim(obj.Scaletype)
                    case 'NSCD'
                        if strcmpi(obj.Partype,'ANC')
                            % Change the value for the second reference point
                            obj.ReferencePolygon2.YCoordinateValues{obj.ReferenceVertex2}=...
                                obj.ReferencePolygon2.YCoordinateValues{obj.ReferenceVertex2}+aChange;
                            
                            % Make the last point in polygon equal to the first point in the polygon
                            % Even if the modified point isnt the first vertex this won't mess anything up
                            obj.ReferencePolygon2.YCoordinateValues{length(obj.ReferencePolygon2.YCoordinateValues)}=...
                                obj.ReferencePolygon2.YCoordinateValues{1};
                            
                        elseif strcmpi(obj.Partype,'SYM')
                            % Change the value for the reference points
                            obj.ReferencePolygon1.YCoordinateValues{obj.ReferenceVertex1}=...
                                obj.ReferencePolygon1.YCoordinateValues{obj.ReferenceVertex1}-aChange;
                            obj.ReferencePolygon2.YCoordinateValues{obj.ReferenceVertex2}=...
                                obj.ReferencePolygon2.YCoordinateValues{obj.ReferenceVertex2}+aChange;
                            
                            % Make the last point in polygon equal to the first point in the polygon
                            % Even if the modified point isnt the first vertex this won't mess anything up
                            obj.ReferencePolygon1.YCoordinateValues{length(obj.ReferencePolygon1.YCoordinateValues)}=...
                                obj.ReferencePolygon1.YCoordinateValues{1};
                            
                            % Make the last point in polygon equal to the first point in the polygon
                            % Even if the modified point isnt the first vertex this won't mess anything up
                            obj.ReferencePolygon2.YCoordinateValues{length(obj.ReferencePolygon2.YCoordinateValues)}=...
                                obj.ReferencePolygon2.YCoordinateValues{1};
                            
                        else
                            error('Unsupported type');
                        end
                        
                        for iCounter=1:length(obj.PointSet1.ArrayOfPolygons)
                            aPolygon=obj.PointSet1.ArrayOfPolygons{iCounter};
                            for kCounter=1:length(obj.PointSet1.ArrayOfVertexVectors{iCounter})
                                % Check if the point is the reference point in which case dont move it
                                if (aPolygon == obj.ReferencePolygon1 && obj.PointSet1.ArrayOfVertexVectors{iCounter}(kCounter) == obj.ReferenceVertex1) ||...
                                        (aPolygon == obj.ReferencePolygon2 && obj.PointSet1.ArrayOfVertexVectors{iCounter}(kCounter) == obj.ReferenceVertex2)
                                else
                                    aPolygon.YCoordinateValues{obj.PointSet1.ArrayOfVertexVectors{iCounter}(kCounter)}=aPolygon.YCoordinateValues{obj.PointSet1.ArrayOfVertexVectors{iCounter}(kCounter)}-aChange;
                                end
                            end
                            aPolygon.YCoordinateValues{length(aPolygon.YCoordinateValues)}=aPolygon.YCoordinateValues{1};
                        end
                        for iCounter=1:length(obj.PointSet2.ArrayOfPolygons)
                            aPolygon=obj.PointSet2.ArrayOfPolygons{iCounter};
                            for kCounter=1:length(obj.PointSet2.ArrayOfVertexVectors{iCounter})
                                % Check if the point is the reference point in which case dont move it
                                if (aPolygon == obj.ReferencePolygon1 && obj.PointSet2.ArrayOfVertexVectors{iCounter}(kCounter) == obj.ReferenceVertex1) ||...
                                        (aPolygon == obj.ReferencePolygon2 && obj.PointSet2.ArrayOfVertexVectors{iCounter}(kCounter) == obj.ReferenceVertex2)
                                else
                                    aPolygon.YCoordinateValues{obj.PointSet2.ArrayOfVertexVectors{iCounter}(kCounter)}=aPolygon.YCoordinateValues{obj.PointSet2.ArrayOfVertexVectors{iCounter}(kCounter)}+aChange;
                                end
                            end
                            aPolygon.YCoordinateValues{length(aPolygon.YCoordinateValues)}=aPolygon.YCoordinateValues{1};
                        end
                                                
                    case 'SCUNI'
                        aScaleFactor=theNewValue/aOldValue;
                        if strcmpi(obj.Partype,'ANC')
                            % Change the value for the second reference point
                            aDistanceFromAnchor=aAnchorY-obj.ReferencePolygon2.YCoordinateValues{obj.ReferenceVertex2};
                            aDistanceToMove=aDistanceFromAnchor*aScaleFactor;
                            obj.ReferencePolygon2.YCoordinateValues{obj.ReferenceVertex2}=aAnchorY-aDistanceToMove;
                            
                            % Make the last point in polygon equal to the first point in the polygon
                            % Even if the modified point isnt the first vertex this won't mess anything up
                            obj.ReferencePolygon2.YCoordinateValues{length(obj.ReferencePolygon2.YCoordinateValues)}=...
                                obj.ReferencePolygon2.YCoordinateValues{1};      
                            
                        elseif strcmpi(obj.Partype,'SYM')
                            % Change the value for the reference points
                            aDistanceFromAnchor=aAnchorY-obj.ReferencePolygon1.YCoordinateValues{obj.ReferenceVertex1};
                            aDistanceToMove=aDistanceFromAnchor*aScaleFactor;
                            obj.ReferencePolygon1.YCoordinateValues{obj.ReferenceVertex1}=aAnchorY-aDistanceToMove;
                            aDistanceFromAnchor=aAnchorY-obj.ReferencePolygon2.YCoordinateValues{obj.ReferenceVertex2};
                            aDistanceToMove=aDistanceFromAnchor*aScaleFactor;
                            obj.ReferencePolygon2.YCoordinateValues{obj.ReferenceVertex2}=aAnchorY-aDistanceToMove;
                            
                            % Make the last point in polygon equal to the first point in the polygon
                            % Even if the modified point isnt the first vertex this won't mess anything up
                            obj.ReferencePolygon1.YCoordinateValues{length(obj.ReferencePolygon1.YCoordinateValues)}=...
                                obj.ReferencePolygon1.YCoordinateValues{1};
                            
                            % Make the last point in polygon equal to the first point in the polygon
                            % Even if the modified point isnt the first vertex this won't mess anything up
                            obj.ReferencePolygon2.YCoordinateValues{length(obj.ReferencePolygon2.YCoordinateValues)}=...
                                obj.ReferencePolygon2.YCoordinateValues{1};
                            
                        else
                            error('Unsupported type');
                        end
                        
                        for iCounter=1:length(obj.PointSet1.ArrayOfPolygons)
                            aPolygon=obj.PointSet1.ArrayOfPolygons{iCounter};
                            for kCounter=1:length(obj.PointSet1.ArrayOfVertexVectors{iCounter})
                                % Check if the point is the reference point in which case dont move it
                                if (aPolygon == obj.ReferencePolygon1 && obj.PointSet1.ArrayOfVertexVectors{iCounter}(kCounter) == obj.ReferenceVertex1) ||...
                                        (aPolygon == obj.ReferencePolygon2 && obj.PointSet1.ArrayOfVertexVectors{iCounter}(kCounter) == obj.ReferenceVertex2)
                                else
                                    aDistanceFromAnchor=aAnchorY-aPolygon.YCoordinateValues{obj.PointSet1.ArrayOfVertexVectors{iCounter}(kCounter)};
                                    aDistanceToMove=aDistanceFromAnchor*aScaleFactor;
                                    aPolygon.YCoordinateValues{obj.PointSet1.ArrayOfVertexVectors{iCounter}(kCounter)}=aAnchorY-aDistanceToMove;
                                end
                            end
                            aPolygon.YCoordinateValues{length(aPolygon.YCoordinateValues)}=aPolygon.YCoordinateValues{1};
                        end
                        for iCounter=1:length(obj.PointSet2.ArrayOfPolygons)
                            aPolygon=obj.PointSet2.ArrayOfPolygons{iCounter};
                            for kCounter=1:length(obj.PointSet2.ArrayOfVertexVectors{iCounter})
                                % Check if the point is the reference point in which case dont move it
                                if (aPolygon == obj.ReferencePolygon1 && obj.PointSet2.ArrayOfVertexVectors{iCounter}(kCounter) == obj.ReferenceVertex1) ||...
                                        (aPolygon == obj.ReferencePolygon2 && obj.PointSet2.ArrayOfVertexVectors{iCounter}(kCounter) == obj.ReferenceVertex2)
                                else
                                    aDistanceFromAnchor=aAnchorY-aPolygon.YCoordinateValues{obj.PointSet2.ArrayOfVertexVectors{iCounter}(kCounter)};
                                    aDistanceToMove=aDistanceFromAnchor*aScaleFactor;
                                    aPolygon.YCoordinateValues{obj.PointSet2.ArrayOfVertexVectors{iCounter}(kCounter)}=aAnchorY-aDistanceToMove;
                                end
                            end
                            aPolygon.YCoordinateValues{length(aPolygon.YCoordinateValues)}=aPolygon.YCoordinateValues{1};
                        end
                        
                    case 'SCXY'
                        aScaleFactor=theNewValue/aOldValue;
                        if strcmpi(obj.Partype,'ANC')
                            % Change the value for the second reference point
                            aDistanceFromAnchor=aAnchorX-obj.ReferencePolygon2.XCoordinateValues{obj.ReferenceVertex2};
                            aDistanceToMove=aDistanceFromAnchor*aScaleFactor;
                            obj.ReferencePolygon2.XCoordinateValues{obj.ReferenceVertex2}=aAnchorX-aDistanceToMove;
                            
                            aDistanceFromAnchor=aAnchorY-obj.ReferencePolygon2.YCoordinateValues{obj.ReferenceVertex2};
                            aDistanceToMove=aDistanceFromAnchor*aScaleFactor;
                            obj.ReferencePolygon2.YCoordinateValues{obj.ReferenceVertex2}=aAnchorY-aDistanceToMove;
                            
                            % Make the last point in polygon equal to the first point in the polygon
                            % Even if the modified point isnt the first vertex this won't mess anything up
                            obj.ReferencePolygon2.XCoordinateValues{length(obj.ReferencePolygon2.XCoordinateValues)}=...
                                obj.ReferencePolygon2.XCoordinateValues{1};
                            obj.ReferencePolygon2.YCoordinateValues{length(obj.ReferencePolygon2.YCoordinateValues)}=...
                                obj.ReferencePolygon2.YCoordinateValues{1};
                            
                        elseif strcmpi(obj.Partype,'SYM')
                            % Change the value for the reference points
                            aDistanceFromAnchor=aAnchorX-obj.ReferencePolygon1.XCoordinateValues{obj.ReferenceVertex1};
                            aDistanceToMove=aDistanceFromAnchor*aScaleFactor;
                            obj.ReferencePolygon1.XCoordinateValues{obj.ReferenceVertex1}=aAnchorX-aDistanceToMove;
                            aDistanceFromAnchor=aAnchorX-obj.ReferencePolygon2.XCoordinateValues{obj.ReferenceVertex2};
                            aDistanceToMove=aDistanceFromAnchor*aScaleFactor;
                            obj.ReferencePolygon2.XCoordinateValues{obj.ReferenceVertex2}=aAnchorX-aDistanceToMove;
                            
                            aDistanceFromAnchor=aAnchorY-obj.ReferencePolygon1.YCoordinateValues{obj.ReferenceVertex1};
                            aDistanceToMove=aDistanceFromAnchor*aScaleFactor;
                            obj.ReferencePolygon1.YCoordinateValues{obj.ReferenceVertex1}=aAnchorY-aDistanceToMove;
                            aDistanceFromAnchor=aAnchorY-obj.ReferencePolygon2.YCoordinateValues{obj.ReferenceVertex2};
                            aDistanceToMove=aDistanceFromAnchor*aScaleFactor;
                            obj.ReferencePolygon2.YCoordinateValues{obj.ReferenceVertex2}=aAnchorY-aDistanceToMove;
                            
                            % Make the last point in polygon equal to the first point in the polygon
                            % Even if the modified point isnt the first vertex this won't mess anything up
                            obj.ReferencePolygon1.XCoordinateValues{length(obj.ReferencePolygon1.XCoordinateValues)}=...
                                obj.ReferencePolygon1.XCoordinateValues{1};
                            obj.ReferencePolygon1.YCoordinateValues{length(obj.ReferencePolygon1.YCoordinateValues)}=...
                                obj.ReferencePolygon1.YCoordinateValues{1};
                            
                            % Make the last point in polygon equal to the first point in the polygon
                            % Even if the modified point isnt the first vertex this won't mess anything up
                            obj.ReferencePolygon2.XCoordinateValues{length(obj.ReferencePolygon2.XCoordinateValues)}=...
                                obj.ReferencePolygon2.XCoordinateValues{1};
                            obj.ReferencePolygon2.YCoordinateValues{length(obj.ReferencePolygon2.YCoordinateValues)}=...
                                obj.ReferencePolygon2.YCoordinateValues{1};
                            
                        else
                            error('Unsupported type');
                        end
                        
                        for iCounter=1:length(obj.PointSet1.ArrayOfPolygons)
                            aPolygon=obj.PointSet1.ArrayOfPolygons{iCounter};
                            for kCounter=1:length(obj.PointSet1.ArrayOfVertexVectors{iCounter})
                                % Check if the point is the reference point in which case dont move it
                                if (aPolygon == obj.ReferencePolygon1 && obj.PointSet1.ArrayOfVertexVectors{iCounter}(kCounter) == obj.ReferenceVertex1) ||...
                                        (aPolygon == obj.ReferencePolygon2 && obj.PointSet1.ArrayOfVertexVectors{iCounter}(kCounter) == obj.ReferenceVertex2)
                                else
                                    aDistanceFromAnchor=aAnchorX-aPolygon.XCoordinateValues{obj.PointSet1.ArrayOfVertexVectors{iCounter}(kCounter)};
                                    aDistanceToMove=aDistanceFromAnchor*aScaleFactor;
                                    aPolygon.XCoordinateValues{obj.PointSet1.ArrayOfVertexVectors{iCounter}(kCounter)}=aAnchorX-aDistanceToMove;
                                    
                                    aDistanceFromAnchor=aAnchorY-aPolygon.YCoordinateValues{obj.PointSet1.ArrayOfVertexVectors{iCounter}(kCounter)};
                                    aDistanceToMove=aDistanceFromAnchor*aScaleFactor;
                                    aPolygon.YCoordinateValues{obj.PointSet1.ArrayOfVertexVectors{iCounter}(kCounter)}=aAnchorY-aDistanceToMove;
                                end
                            end
                            aPolygon.XCoordinateValues{length(aPolygon.XCoordinateValues)}=aPolygon.XCoordinateValues{1};
                            aPolygon.YCoordinateValues{length(aPolygon.YCoordinateValues)}=aPolygon.YCoordinateValues{1};
                        end
                        for iCounter=1:length(obj.PointSet2.ArrayOfPolygons)
                            aPolygon=obj.PointSet2.ArrayOfPolygons{iCounter};
                            for kCounter=1:length(obj.PointSet2.ArrayOfVertexVectors{iCounter})
                                % Check if the point is the reference point in which case dont move it
                                if (aPolygon == obj.ReferencePolygon1 && obj.PointSet2.ArrayOfVertexVectors{iCounter}(kCounter) == obj.ReferenceVertex1) ||...
                                        (aPolygon == obj.ReferencePolygon2 && obj.PointSet2.ArrayOfVertexVectors{iCounter}(kCounter) == obj.ReferenceVertex2)
                                else
                                    aDistanceFromAnchor=aAnchorX-aPolygon.XCoordinateValues{obj.PointSet2.ArrayOfVertexVectors{iCounter}(kCounter)};
                                    aDistanceToMove=aDistanceFromAnchor*aScaleFactor;
                                    aPolygon.XCoordinateValues{obj.PointSet2.ArrayOfVertexVectors{iCounter}(kCounter)}=aAnchorX-aDistanceToMove;
                                    
                                    aDistanceFromAnchor=aAnchorY-aPolygon.YCoordinateValues{obj.PointSet2.ArrayOfVertexVectors{iCounter}(kCounter)};
                                    aDistanceToMove=aDistanceFromAnchor*aScaleFactor;
                                    aPolygon.YCoordinateValues{obj.PointSet2.ArrayOfVertexVectors{iCounter}(kCounter)}=aAnchorY-aDistanceToMove;
                                end
                            end
                            aPolygon.XCoordinateValues{length(aPolygon.XCoordinateValues)}=aPolygon.XCoordinateValues{1};
                            aPolygon.YCoordinateValues{length(aPolygon.YCoordinateValues)}=aPolygon.YCoordinateValues{1};
                        end
                end
            end
        end
    end
end

