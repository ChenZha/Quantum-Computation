classdef SonnetGeometryEdgeVia < handle
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This class defines the values for an edge via
    % in the Geometry block of the Sonnet project file.
    % Each Edge Via is stored as an element in a Cell Array
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
        
        Polygon
        Level
        Vertex
        SnapStyle
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = SonnetGeometryEdgeVia(theFid)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Defines the constructor for the edge via wrapper. This
            %     will create an edge via and store it in a cell array
            %     that will contain all the edge vias.
            % The constructor will be passed the file ID from the
            %     SONNET GEO object constructor.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if nargin == 1
                
                initialize(obj);
                                
                % Determine if a snap style is specified
                aTempString=fscanf(theFid,' %s',1);
                if ~isempty(strfind(aTempString,'SNAPSTYLE'))
                    obj.SnapStyle=fscanf(theFid,'%d',1);
                    fscanf(theFid,'%s',1);
                end
                
                % Read the debug ID for the polygon; this
                % will be replaced by the polygon reference
                % when the geometry block is done constructing
                % Read in the tag 'POLY' which we dont need 
                % to store first
                obj.Polygon=fscanf(theFid,'%d',1);
                
                % Read in the number of points for the polygon (this is always one for an edge via)
                fscanf(theFid,'%d',1);
                
                % Read in the vertex for the polygon
                obj.Vertex=fscanf(theFid,'%d',1)+1;
                
                % Read the rest of the line (it is empty)
                fgetl(theFid);
                
                fscanf(theFid,' %s',1);                             % Read in the string TOLEVEL, we dont need to store it because it is always there
                
                % TOLEVEL can be a string sometimes like 'GND'
                % so we need to first read it in as a string and
                % determine if it is GND if it is not then we
                % need to read it in again as an integer.
                aBackupOfTheFid=ftell(theFid);          	        % Store a backup of the file ID so that we can restore it afer we read the line
                aTempString=fscanf(theFid,' %s',1);
                
                if strcmp(aTempString,'GND')==0 && strcmp(aTempString,'TOP')==0 && strcmp(aTempString,'BOTTOM')==0
                    fseek(theFid,aBackupOfTheFid,'bof');	            % Restore the backup of the fid
                    obj.Level=fscanf(theFid,' %d',1);
                else
                    obj.Level=aTempString;
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
            % This function initializes the via properties to some default
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
            aNewObject=SonnetGeometryEdgeVia();
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
            aSignature = sprintf('EVIA1\n'); 
            
            aSignature = [aSignature sprintf('POLY %d 1\n%d\n',obj.Polygon.DebugId,obj.Vertex-1)];
            
            if isa(obj.Level,'char')
                aSignature = [aSignature sprintf('TOLEVEL %s\n',obj.Level)]; 
            else
                aSignature = [aSignature sprintf('TOLEVEL %d\n',obj.Level)]; 
            end
            
        end
        
    end
end

