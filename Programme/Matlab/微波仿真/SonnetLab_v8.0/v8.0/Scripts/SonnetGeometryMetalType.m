classdef SonnetGeometryMetalType < handle
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This class defines the values for a
    % custom planar metal type created by the user.
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
        
        Name
        PatternId
        Type
        Conductivity
        CurrentRatio
        Thickness
        Resistance
        SkinCoefficient
        Reactance
        KineticInductance
        NumSheets
        Roughness
        TopSurface
        BottomSurface
        
        isSolid
        WallThickness
        
        isThick
        TopRoughness
        BottomRoughness
        
        Rdc
        Rrf
        Xdc
        
        FillFactor
        ElectricalLossType 
        
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = SonnetGeometryMetalType(theFid)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % define the constructor for the metals.
            %     the constructor will be passed the file ID from the
            %     SONNET GEO object constructor.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if nargin == 1
                
                initialize(obj);
                
                % Read the name of the metal from the file
                obj.Name=SonnetStringReadFormat(theFid);
                obj.Name=strrep(obj.Name,'"','');
                
                % Read in the pattern ID from the file
                obj.PatternId=fscanf(theFid,' %d',1);
                
                % We need to read in a string to determine what type of
                % metal it is.
                aTempString=fscanf(theFid,' %s',1);
                
                switch aTempString
                    
                    case 'NOR'
                        obj.Type='Normal';
                        obj.Conductivity=SonnetStringReadFormat(theFid);
                        obj.CurrentRatio=SonnetStringReadFormat(theFid);
                        obj.Thickness=SonnetStringReadFormat(theFid);                        
                        
                    case 'RES'
                        obj.Type='Resistor';
                        obj.Resistance=SonnetStringReadFormat(theFid);
                        
                    case 'NAT'
                        obj.Type='Natural';
                        obj.Resistance=SonnetStringReadFormat(theFid);
                        obj.SkinCoefficient=SonnetStringReadFormat(theFid);
                        
                    case 'SUP'
                        obj.Type='General';
                        obj.Resistance=SonnetStringReadFormat(theFid);
                        obj.SkinCoefficient=SonnetStringReadFormat(theFid);
                        obj.Reactance=SonnetStringReadFormat(theFid);
                        obj.KineticInductance=SonnetStringReadFormat(theFid);
                        
                    case 'SEN'
                        obj.Type='Sense';
                        obj.Reactance=SonnetStringReadFormat(theFid);
                        
                    case 'TMM'
                        obj.Type='Thick';
                        obj.Conductivity=SonnetStringReadFormat(theFid);
                        obj.CurrentRatio=SonnetStringReadFormat(theFid);
                        obj.Thickness=SonnetStringReadFormat(theFid);
                        obj.NumSheets=SonnetStringReadFormat(theFid);
                        
                    case 'VOL'
                        obj.Type='Volume';
                        obj.Conductivity=SonnetStringReadFormat(theFid);
                        
                        aTempValue=SonnetStringReadFormat(theFid);
                        if isa(aTempValue,'char') && strcmpi(aTempValue,'SOLID')==1
                            obj.isSolid=true;
                            obj.WallThickness=str2double(fgetl(theFid));
                        else
                            obj.isSolid=false;
                            obj.WallThickness=aTempValue;
                        end
                        
                    case 'SFC'
                        obj.Type='Surface';
                        obj.Rdc=SonnetStringReadFormat(theFid);
                        obj.Rrf=SonnetStringReadFormat(theFid);
                        obj.Xdc=SonnetStringReadFormat(theFid);
                        
                    case 'ARR'
                        obj.Type='Array';
                        obj.Conductivity=SonnetStringReadFormat(theFid);
                        obj.FillFactor=SonnetStringReadFormat(theFid);
                        
                    case 'ROG'
                        obj.Type='Rough';
                        obj.Thickness=SonnetStringReadFormat(theFid);
                        obj.Roughness=SonnetStringReadFormat(theFid);
                        obj.NumSheets=SonnetStringReadFormat(theFid);
                        
                        aBackupOfTheFid=ftell(theFid);          	      % Store a backup of the file ID so that we can restore it afer we read the line
                        aTempString=fscanf(theFid,' %f',1);               % Get the next character
                        fseek(theFid,aBackupOfTheFid,'bof');	          % Restore the backup of the fid
                        
                        % Sometimes the current ratio isnt specified for
                        % versions of 12.X
                        if ~isempty(aTempString)
                            obj.CurrentRatio=SonnetStringReadFormat(theFid);
                        else
                            obj.CurrentRatio=0;
                        end
                        
                        aBackupOfTheFid=ftell(theFid);          	      % Store a backup of the file ID so that we can restore it afer we read the line
                        aTempString=fscanf(theFid,' %c',1);               % Get the next character
                        fseek(theFid,aBackupOfTheFid,'bof');	          % Restore the backup of the fid
                        
                        % If the character is an S or an R then
                        % it defines a smooth/rough value for
                        % the metal type.
                        if aTempString == 'S' || aTempString == 'R'
                            obj.TopSurface=fscanf(theFid,' %c',1);
                            obj.BottomSurface=fscanf(theFid,' %c',1);
                        else
                            % If no value is given use the default
                            % selection
                            obj.TopSurface='S';
                            obj.BottomSurface='R';
                        end
                        
                        obj.Conductivity=SonnetStringReadFormat(theFid);
                        
                    case 'RUF'
                        obj.Type='Rough';
                        aTempString=fscanf(theFid,' %s',1);
                        if strcmpi(aTempString,'THK')==1
                            obj.isThick=true;
                        else
                            obj.isThick=false;
                        end
                        
                        obj.Conductivity=SonnetStringReadFormat(theFid);
                        obj.Thickness=SonnetStringReadFormat(theFid);
                        obj.TopRoughness=SonnetStringReadFormat(theFid);
                        obj.BottomRoughness=SonnetStringReadFormat(theFid);
                        obj.CurrentRatio=SonnetStringReadFormat(theFid);
                end
                
                aBackupOfTheFid=ftell(theFid);
                
                obj.ElectricalLossType=fscanf(theFid,' %s',1);%SonnetStringReadFormat(theFid);
                
                if ~strcmp(obj.ElectricalLossType, 'RSVY') ...
                      && ~strcmp(obj.ElectricalLossType, 'SRVY')   
                    obj.ElectricalLossType = [];
                    fseek(theFid,aBackupOfTheFid,'bof');
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
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aString=toString(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Returns a string representation of the object
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if strcmpi('NOR',obj.Type)==1 || strcmpi('NORMAL',obj.Type)==1
                aString=[obj.Name ' :: Normal'];
            elseif strcmpi('RES',obj.Type)==1 || strcmpi('RESISTOR',obj.Type)==1
                aString=[obj.Name ' :: Resistor'];
            elseif strcmpi('NAT',obj.Type)==1 || strcmpi('NATURAL',obj.Type)==1
                aString=[obj.Name ' :: Natural'];
            elseif strcmpi('SUP',obj.Type)==1 || strcmpi('GENERAL',obj.Type)==1
                aString=[obj.Name ' :: General'];
            elseif strcmpi('SEN',obj.Type)==1 || strcmpi('SENSE',obj.Type)==1
                aString=[obj.Name ' :: Sense'];
            elseif strcmpi('TMM',obj.Type)==1 || strcmpi('THICK',obj.Type)==1
                aString=[obj.Name ' :: Thick'];
            elseif strcmpi('VOL',obj.Type)==1 || strcmpi('VOLUME',obj.Type)==1
                aString=[obj.Name ' :: Volume'];
            elseif strcmpi('SFC',obj.Type)==1 || strcmpi('SURFACE',obj.Type)==1
                aString=[obj.Name ' :: Surface'];
            elseif strcmpi('ARR',obj.Type)==1 || strcmpi('ARRAY',obj.Type)==1
                aString=[obj.Name ' :: Array'];
            elseif strcmpi('ROG',obj.Type)==1 || strcmpi('ROUGH',obj.Type)==1
                aString=[obj.Name ' :: Rough'];
            end
            
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
            
            obj.PatternId=0;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aNewObject=clone(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function builds a deep copy of this object
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            aNewObject=SonnetGeometryMetalType();
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
            
            if ~isempty(obj.Name)
                aSignature=sprintf('MET "%s"',obj.Name);
            end
            
            aSignature = [aSignature sprintf(' %d',obj.PatternId)];
            
            if strcmpi('NOR',obj.Type)==1 || strcmpi('NORMAL',obj.Type)==1
                aSignature = [aSignature ' NOR'];
                aSignature = [aSignature ' '  SonnetStringWriteFormat(obj.Conductivity)];
                aSignature = [aSignature ' '  SonnetStringWriteFormat(obj.CurrentRatio)];
                aSignature = [aSignature ' '  SonnetStringWriteFormat(obj.Thickness)];
                
                if theVersion >= 14
                   aSignature = [aSignature ' '  SonnetStringWriteFormat(obj.ElectricalLossType)];
                end
                
            elseif strcmpi('RES',obj.Type)==1 || strcmpi('RESISTOR',obj.Type)==1 || strcmpi('RESISTIVE',obj.Type)==1
                aSignature = [aSignature ' RES'];
                aSignature = [aSignature ' '  SonnetStringWriteFormat(obj.Resistance)];
                
            elseif strcmpi('NAT',obj.Type)==1 || strcmpi('NATURAL',obj.Type)==1
                aSignature = [aSignature ' NAT'];
                aSignature = [aSignature ' '  SonnetStringWriteFormat(obj.Resistance)];
                aSignature = [aSignature ' '  SonnetStringWriteFormat(obj.SkinCoefficient)];
                
            elseif strcmpi('SUP',obj.Type)==1 || strcmpi('GENERAL',obj.Type)==1
                aSignature = [aSignature ' SUP'];
                aSignature = [aSignature ' '  SonnetStringWriteFormat(obj.Resistance)];
                aSignature = [aSignature ' '  SonnetStringWriteFormat(obj.SkinCoefficient)];
                aSignature = [aSignature ' '  SonnetStringWriteFormat(obj.Reactance)];
                aSignature = [aSignature ' '  SonnetStringWriteFormat(obj.KineticInductance)];
                
            elseif strcmpi('SEN',obj.Type)==1 || strcmpi('SENSE',obj.Type)==1
                aSignature = [aSignature ' SEN'];
                aSignature = [aSignature ' '  SonnetStringWriteFormat(obj.Reactance)];
                
            elseif strcmpi('TMM',obj.Type)==1 || strcmpi('THICK',obj.Type)==1
                aSignature = [aSignature ' TMM'];
                aSignature = [aSignature ' '  SonnetStringWriteFormat(obj.Conductivity)];
                aSignature = [aSignature ' '  SonnetStringWriteFormat(obj.CurrentRatio)];
                aSignature = [aSignature ' '  SonnetStringWriteFormat(obj.Thickness)];
                aSignature = [aSignature ' '  SonnetStringWriteFormat(obj.NumSheets)];
                
                if theVersion >= 14
                   aSignature = [aSignature ' '  SonnetStringWriteFormat(obj.ElectricalLossType)];
                end
                
            elseif strcmpi('VOL',obj.Type)==1 || strcmpi('Volume',obj.Type)==1
                aSignature = [aSignature ' VOL'];
                aSignature = [aSignature ' '  SonnetStringWriteFormat(obj.Conductivity)];
                if obj.isSolid || (isa(obj.WallThickness,'double') && obj.WallThickness < 0)
                    if isempty(obj.WallThickness)
                        aSignature = [aSignature ' SOLID 0'];
                    else
                        aSignature = [aSignature ' SOLID ' num2str(obj.WallThickness)];
                    end
                else
                    aSignature = [aSignature ' '  SonnetStringWriteFormat(obj.WallThickness)];
                end
                
                if theVersion >= 14
                   aSignature = [aSignature ' '  SonnetStringWriteFormat(obj.ElectricalLossType)];
                end
                
            elseif strcmpi('SFC',obj.Type)==1 || strcmpi('Surface',obj.Type)==1
                aSignature = [aSignature ' SFC'];
                aSignature = [aSignature ' '  SonnetStringWriteFormat(obj.Rdc)];
                aSignature = [aSignature ' '  SonnetStringWriteFormat(obj.Rrf)];
                aSignature = [aSignature ' '  SonnetStringWriteFormat(obj.Xdc)];
                
            elseif strcmpi('ARR',obj.Type)==1 || strcmpi('ARRAY',obj.Type)==1
                aSignature = [aSignature ' ARR'];
                aSignature = [aSignature ' '  SonnetStringWriteFormat(obj.Conductivity)];
                aSignature = [aSignature ' '  SonnetStringWriteFormat(obj.FillFactor)];
                
                if theVersion >= 14
                   aSignature = [aSignature ' '  SonnetStringWriteFormat(obj.ElectricalLossType)];
                end
            elseif strcmpi('ROG',obj.Type)==1 || strcmpi('RUF',obj.Type)==1 || strcmpi('ROUGH',obj.Type)==1
                if theVersion >= 13
                    aSignature = [aSignature ' RUF'];
                    
                    if obj.isThick
                        aSignature = [aSignature ' THK'];
                    else
                        aSignature = [aSignature ' THN'];
                    end
                    
                    aSignature = [aSignature ' ' SonnetStringWriteFormat(obj.Conductivity)];
                    aSignature = [aSignature ' ' SonnetStringWriteFormat(obj.Thickness)];
                    aSignature = [aSignature ' ' SonnetStringWriteFormat(obj.TopRoughness)];
                    aSignature = [aSignature ' ' SonnetStringWriteFormat(obj.BottomRoughness)];
                    aSignature = [aSignature ' ' SonnetStringWriteFormat(obj.CurrentRatio)];
                    
                    if theVersion >= 14
                        aSignature = [aSignature ' '  SonnetStringWriteFormat(obj.ElectricalLossType)];
                    end
                else
                    aSignature = [aSignature ' ROG'];
                    aSignature = [aSignature ' ' SonnetStringWriteFormat(obj.Thickness)];
                    aSignature = [aSignature ' ' SonnetStringWriteFormat(obj.Roughness)];
                    aSignature = [aSignature ' ' SonnetStringWriteFormat(obj.NumSheets)];
                    aSignature = [aSignature ' ' SonnetStringWriteFormat(obj.CurrentRatio) ' '];
                    if strcmpi(obj.TopSurface,'s')==1 || strcmpi(obj.TopSurface,'smooth')==1
                        aSignature = [aSignature 'S'];
                    else
                        aSignature = [aSignature 'R'];
                    end
                    if strcmpi(obj.BottomSurface,'s')==1 || strcmpi(obj.BottomSurface,'smooth')==1
                        aSignature = [aSignature 'S'];
                    else
                        aSignature = [aSignature 'R'];
                    end
                    
                    aSignature = [aSignature ' '  SonnetStringWriteFormat(obj.Conductivity)];
%                     
%                     if theVersion >= 14
%                         aSignature = [aSignature ' '  SonnetStringWriteFormat(obj.ElectricalLossType)];
%                     end
                    
                end
            end
            
            aSignature = [aSignature sprintf('\n')];
            
        end
    end
end

