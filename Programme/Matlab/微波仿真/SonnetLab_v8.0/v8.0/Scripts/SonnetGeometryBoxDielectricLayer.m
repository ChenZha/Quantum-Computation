classdef SonnetGeometryBoxDielectricLayer < handle
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This class defines the values for a dielectric layer in a Sonnet Box
    %   which is defined in the geometry block.
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
        
        
        Thickness
        RelativeDielectricConstant
        RelativeMagneticPermeability
        DielectricLossTangent
        MagneticLossTangent
        DielectricConductivity
        NumberOfZPartitions
        NameOfDielectricLayer
        
        RelativeDielectricConstantForZDirection
        RelativeMagneticPermeabilityForZDirection
        DielectricLossTangentForZDirection
        MagneticLossTangentForZDirection
        DielectricConductivityForZDirection
        
        ElectricalLoss
        ElectricalLossType
        
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = SonnetGeometryBoxDielectricLayer(theFid)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % define the constructor for the dielectric layer.
            %     the constructor will be passed the file ID from the
            %     SONNET GEO object constructor.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if nargin == 1        %if we were passed 1 argument which means we go the theFid
                
                initialize(obj);
                
                % Lets backup the file ID so that we can read the line for the dielectric and determine if it is an regular dielectric or an andielectric
                aBackupOfTheFid=ftell(theFid);          	      % Store a backup of the file ID so that we can restore it afer we read the line
                aTempString=fgetl(theFid);
                fseek(theFid,aBackupOfTheFid,'bof');	          % Restore the backup of the fid
                
                aTempString=strtrim(aTempString);                 % Remove preceeding and trailing whitespace from the line we read.
                
                if length(strfind(aTempString,' '))< 12             % If there are too few terms to be anisotropic then we only read in the terms we need for a dielectric
                    
                    obj.Thickness=SonnetStringReadFormat(theFid);
                    obj.RelativeDielectricConstant=SonnetStringReadFormat(theFid);
                    obj.RelativeMagneticPermeability=SonnetStringReadFormat(theFid);
                    obj.DielectricLossTangent=SonnetStringReadFormat(theFid);
                    obj.MagneticLossTangent=SonnetStringReadFormat(theFid);
                    
                    % Occationally the DielectricConductivity will be a string instead of a number,
                    % so we are going to have to check what it is
                    aBackupOfTheFid=ftell(theFid);          	        % Store a backup of the file ID so that we can restore it afer we read the line
                    aTempString=fgetl(theFid);
                    fseek(theFid,aBackupOfTheFid,'bof');	            % Restore the backup of the fid
                    if ~isempty(strfind(aTempString,'"'))               % Search for quotation marks in the value to determine if it is a string or a number
                        obj.DielectricConductivity=SonnetStringReadFormat(theFid);
                    else
                        obj.DielectricConductivity=SonnetStringReadFormat(theFid);
                    end
                    
                    obj.NumberOfZPartitions=SonnetStringReadFormat(theFid);
                    obj.NameOfDielectricLayer=strrep(strtrim(fgetl(theFid)),'"','');
                    
                else
                    
                    obj.Thickness=SonnetStringReadFormat(theFid);
                    obj.RelativeDielectricConstant=SonnetStringReadFormat(theFid);
                    obj.RelativeMagneticPermeability=SonnetStringReadFormat(theFid);
                    obj.DielectricLossTangent=SonnetStringReadFormat(theFid);
                    obj.MagneticLossTangent=SonnetStringReadFormat(theFid);
                    
                    % Occationally the DielectricConductivity will be a string instead of a number,
                    % so we are going to have to check what it is
                    aBackupOfTheFid=ftell(theFid);          	        % Store a backup of the file ID so that we can restore it afer we read the line
                    aTempString=fgetl(theFid);
                    fseek(theFid,aBackupOfTheFid,'bof');	            % Restore the backup of the fid
                    if ~isempty(strfind(aTempString,'"'))               % Search for quotation marks in the value to determine if it is a string or a number
                        obj.DielectricConductivity=SonnetStringReadFormat(theFid);
                    else
                        obj.DielectricConductivity=SonnetStringReadFormat(theFid);
                    end
                    
                    obj.NumberOfZPartitions=SonnetStringReadFormat(theFid);
                    obj.NameOfDielectricLayer=strrep(SonnetStringReadFormat(theFid),'"','');
                    fscanf(theFid,' %c',1);                           % Get the 'A' which is unnecessary
                    obj.RelativeDielectricConstantForZDirection=SonnetStringReadFormat(theFid);
                    obj.RelativeMagneticPermeabilityForZDirection=SonnetStringReadFormat(theFid);
                    obj.DielectricLossTangentForZDirection=SonnetStringReadFormat(theFid);
                    obj.MagneticLossTangentForZDirection=SonnetStringReadFormat(theFid);
                    
                    % Occationally the DielectricConductivityForZDirection will be a string instead of a number,
                    % so we are going to have to check what it is
                    aBackupOfTheFid=ftell(theFid);          	        % Store a backup of the file ID so that we can restore it afer we read the line
                    aTempString=fgetl(theFid);
                    fseek(theFid,aBackupOfTheFid,'bof');	            % Restore the backup of the fid
                    if ~isempty(strfind(aTempString,'"'))               % Search for quotation marks in the value to determine if it is a string or a number
                        obj.DielectricConductivityForZDirection=SonnetStringReadFormat(theFid);
                    else
                        obj.DielectricConductivityForZDirection=SonnetStringReadFormat(theFid);
                    end
                    
                    fgetl(theFid);                                    % Dump the newline character from the line
                    
                end
                
            else
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % we come here when we didn't recieve a file ID as an argument
                % which means that we are going to create a default dielectric layer object with
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
            
            obj.Thickness=0;
            obj.RelativeDielectricConstant=1;
            obj.RelativeMagneticPermeability=1;
            obj.DielectricLossTangent=0;
            obj.MagneticLossTangent=0;
            obj.DielectricConductivity=0;
            obj.NumberOfZPartitions=0;
            obj.NameOfDielectricLayer='Unnamed';
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aNewObject=clone(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function builds a deep copy of this object
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            aNewObject=SonnetGeometryBoxDielectricLayer();
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
            
            aSignature = ['      ' SonnetStringWriteFormat(obj.Thickness)];
            
            if ~isempty(obj.RelativeDielectricConstant)
                aSignature = [aSignature ' ' SonnetStringWriteFormat(obj.RelativeDielectricConstant)];
            end
            
            if ~isempty(obj.RelativeMagneticPermeability)
                aSignature = [aSignature ' ' SonnetStringWriteFormat(obj.RelativeMagneticPermeability)];
            end
            
            if ~isempty(obj.DielectricLossTangent)
                aSignature = [aSignature ' ' SonnetStringWriteFormat(obj.DielectricLossTangent)];
            end
            
            if ~isempty(obj.MagneticLossTangent)
                aSignature = [aSignature ' ' SonnetStringWriteFormat(obj.MagneticLossTangent)];
            end
            
            if ~isempty(obj.DielectricConductivity)
                aSignature = [aSignature ' ' SonnetStringWriteFormat(obj.DielectricConductivity)];
            end
            
            if ~isempty(obj.NumberOfZPartitions)
                aSignature = [aSignature ' ' SonnetStringWriteFormat(obj.NumberOfZPartitions)];
            end
            
            if ~isempty(obj.NameOfDielectricLayer)
                aTempString=strrep(obj.NameOfDielectricLayer,'"','');
                aSignature = [aSignature ' "' aTempString '" '];
            end
            
            % Print these if it is anisotropic
            
            if ~isempty(obj.RelativeDielectricConstantForZDirection)
                aSignature = [aSignature ' A ' SonnetStringWriteFormat(obj.RelativeDielectricConstantForZDirection)];
            end
            
            if ~isempty(obj.RelativeMagneticPermeabilityForZDirection)
                aSignature = [aSignature ' ' SonnetStringWriteFormat(obj.RelativeMagneticPermeabilityForZDirection)];
            end
            
            if ~isempty(obj.DielectricLossTangentForZDirection)
                aSignature = [aSignature ' ' SonnetStringWriteFormat(obj.DielectricLossTangentForZDirection)];
            end
            
            if ~isempty(obj.MagneticLossTangentForZDirection)
                aSignature = [aSignature ' ' SonnetStringWriteFormat(obj.MagneticLossTangentForZDirection)];
            end
            
            if ~isempty(obj.DielectricConductivityForZDirection)
                aSignature = [aSignature ' ' SonnetStringWriteFormat(obj.DielectricConductivityForZDirection)];
            end
            
            aSignature = [aSignature sprintf('\n')];
            
        end
    end
end

