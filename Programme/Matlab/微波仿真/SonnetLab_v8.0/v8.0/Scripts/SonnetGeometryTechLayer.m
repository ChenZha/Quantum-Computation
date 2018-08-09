classdef SonnetGeometryTechLayer < handle
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This class defines the values for a technology layer. Types of tech
    % layers include metals, bricks and  vias.
    % tech layers are defined in the Geometry block.
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
        Name
        DXFLayerName
        GDSStream
        GDSData
        GBRFilename
        Polygon
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = SonnetGeometryTechLayer(theFid)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % define the constructor for the GEO block.
            %     the constructor will be passed the file ID from the
            %     SONNET project constructor.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            initialize(obj);
            
            if nargin == 0
                return;
            end
                                        
            % Read the first line for the polygon.
%             aTempString=fgetl(theFid);

            % Read in the first line of values
            try
                % Read the first token and assign it to Type
                obj.Type = fscanf(theFid,' %s',1);
                  
                % Read Name
                obj.Name=SonnetStringReadFormat(theFid);
                obj.Name=strrep(obj.Name,'"','');
                
                obj.DXFLayerName = SonnetStringReadFormat(theFid);
                obj.DXFLayerName = strrep(obj.DXFLayerName,'"','');

                obj.GDSStream = fscanf(theFid,' %i',1);
                obj.GDSData = fscanf(theFid,' %i',1);

                aBackupOfTheFid=ftell(theFid);          	      % Store a backup of the file ID so that we can restore it afer we read the line
                aTempString=fscanf(theFid,' %c',1);               % Get the next character
                fseek(theFid,aBackupOfTheFid,'bof');	          % Restore the backup of the fid
                 
                if strcmpi(aTempString, 'GBR')
                    obj.GBRFilename = SonnetStringReadFormat(theFid);
                    obj.GBRFilename = strrep(obj.Name,'"','');
                else
                     % fseek(theFid,aBackupOfTheFid,'bof');
                      fgetl(theFid);
                end
                                    
                if strcmpi(obj.Type, 'VIA')
                    fgetl(theFid);
                end
                
                if strcmpi(obj.Type, 'BRICK')
                    fgetl(theFid);
                end
                
                
                
                 if strcmpi(obj.Type, 'VIA')
                      obj.Polygon = SonnetGeometryPolygon(theFid, true, 'VIA POLYGON');
                 else
                     obj.Polygon = SonnetGeometryPolygon(theFid, true, '');
                 end
                                               
            catch exception 
                disp(exception);
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
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aNewObject=clone(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function builds a deep copy of this object
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            aNewObject=SonnetGeometryTechLayer();
            SonnetClone(obj,aNewObject);
        end
        
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function writeObjectContents(obj, theFid, theVersion)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function writes the values from the object to a file.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            fprintf(theFid,'%s', obj.stringSignature(theVersion));            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aSignature=stringSignature(obj,theVersion)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function writes the values from the object to a string.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
            if theVersion < 14
                return;
            end
            
            aSignature = '';
            
            if ~isempty(obj.GBRFilename)
                aSignature = [aSignature sprintf('TECHLAY %s %s %s %i %i GBR %s', ...
                obj.Type, SonnetStringWriteFormat(obj.Name), obj.DXFLayerName, obj.GDSStream, ...
                obj.GDSData, obj.GBRFilename)];
            else
                aSignature = [aSignature sprintf('TECHLAY %s %s %s %i %i', ...
                obj.Type, SonnetStringWriteFormat(obj.Name), obj.DXFLayerName, obj.GDSStream, ...
                obj.GDSData)];                
            end
            
            if strcmpi(obj.Type, 'VIA')
               aSignature = [aSignature sprintf('\nVIA POLYGON')];
            end

            if strcmpi(obj.Type, 'BRICK')
                aSignature = [aSignature sprintf('\nBRI POLY')];                
            end

            obj.Polygon.CanWriteType=false;
            aSignature = [aSignature  sprintf('%s\nEND\n', obj.Polygon.stringSignature(theVersion))];
            obj.Polygon.CanWriteType=true;
            %aSignature = [aSignature sprintf('\n')];
        end        
    end
end