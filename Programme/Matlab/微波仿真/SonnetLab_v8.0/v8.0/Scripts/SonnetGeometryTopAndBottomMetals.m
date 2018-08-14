classdef SonnetGeometryTopAndBottomMetals < handle
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This class defines the values for Cover Metals. This is used to define
    %	the top of the box (TMET) and the bottom of the box (BMET).
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
        
        Name        % The name of the material
        PatternId   % The patternID for the matterial, starts at Zero
        Type        % The type of the material.
        Conductivity
        CurrentRatio
        Thickness
        Resistance
        SkinCoefficient
        Reactance
        KineticInductance
        Unknown   % Variable used for storing the arguments for an unknown type
        
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = SonnetGeometryTopAndBottomMetals(theFid)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % define the constructor for the cover metals.
            %     the constructor will be passed the file ID from the
            %     SONNET GEO object constructor.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if nargin == 1        %if we were passed 1 argument which means we go the theFid
                
                initialize(obj);
                
                % Read the name of the metal from the file
                obj.Name=SonnetStringReadFormat(theFid);
                
                % Read in the pattern ID from the file
                obj.PatternId=fscanf(theFid,' %d',1);
                
                % We need to read in a string to determine what type of
                % metal it is.
                aTempString=fscanf(theFid,' %s',1);
                
                switch aTempString
                    case 'WGLOAD'
                        obj.Type='WGLOAD';
                        fgetl(theFid);           % Toss the rest of the line because WGLOAD takes no arguments
                        
                    case 'FREESPACE'
                        obj.Type='FREESPACE';
                        fgetl(theFid);           % Toss the rest of the line because FREESPACE always has the arguments of 376.7303136 0 0 0
                        
                    case 'NOR'
                        obj.Type='NOR';
                        obj.Conductivity=SonnetStringReadFormat(theFid); 
                        obj.CurrentRatio=SonnetStringReadFormat(theFid); 
                        obj.Thickness=SonnetStringReadFormat(theFid);  % Read in the arguments for NOR
                        
                    case 'RESISTOR'
                        obj.Type='RESISTOR';
                        obj.Resistance=SonnetStringReadFormat(theFid);       % Read in the arguments for Resistance
                        
                    case 'NAT'
                        obj.Type='NAT';
                        obj.Resistance=SonnetStringReadFormat(theFid); 
                        obj.SkinCoefficient=SonnetStringReadFormat(theFid);  % Read in the arguments for Resistance
                        
                    case 'SUP'
                        obj.Type='SUP';
                        obj.Resistance=SonnetStringReadFormat(theFid); 
                        obj.SkinCoefficient=SonnetStringReadFormat(theFid); 
                        obj.Reactance=SonnetStringReadFormat(theFid); 
                        obj.KineticInductance=SonnetStringReadFormat(theFid); 
                        
                    case 'SEN'
                        obj.Type='SEN';
                        obj.Resistance=SonnetStringReadFormat(theFid);       % Read in the arguments for Resistance
                        
                    otherwise
                        obj.Type=aTempString;
                        obj.Unknown=fgetl(theFid);
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
            
            obj.Name='Lossless';
            obj.PatternId=0;
            obj.Type='SUP';
            obj.Resistance=0;
            obj.SkinCoefficient=0;
            obj.Reactance=0;
            obj.KineticInductance=0;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aNewObject=clone(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function builds a deep copy of this object
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            aNewObject=SonnetGeometryTopAndBottomMetals();
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
                aTempString=SonnetStringWriteFormat(obj.Name);	% Format the string by adding quotation marks to it if needed.
                aSignature = sprintf('%s',aTempString);
            end
            
            if ~isempty(obj.PatternId)
                aSignature = [aSignature sprintf(' %d',obj.PatternId)];
            end
            
            if ~isempty(obj.Type)
                aSignature = [aSignature sprintf(' %s',obj.Type)];
                
                if strcmp(obj.Type,'WGLOAD')==1 	% If it is WGLOAD then write nothing else nut a new line
                    aSignature = [aSignature sprintf('\n')];
                    
                elseif strcmp(obj.Type,'FREESPACE')==1
                    aSignature = [aSignature sprintf(' 376.7303136 0 0 0\n')];
                    
                elseif strcmp(obj.Type,'NOR')==1
                    if ~isempty(obj.Conductivity)
                        aSignature = [aSignature ' '  SonnetStringWriteFormat(obj.Conductivity)];
                    end
                    
                    if ~isempty(obj.CurrentRatio)
                        aSignature = [aSignature ' '  SonnetStringWriteFormat(obj.CurrentRatio)];
                    end
                    
                    if ~isempty(obj.Thickness)
                        aSignature = [aSignature ' '  SonnetStringWriteFormat(obj.Thickness)];
                    end
                    aSignature = [aSignature sprintf('\n')];
                    
                elseif strcmp(obj.Type,'RESISTOR')==1
                    if ~isempty(obj.Resistance)
                        aSignature = [aSignature ' '  SonnetStringWriteFormat(obj.Resistance)];
                    end
                    aSignature = [aSignature sprintf('\n')];
                    
                elseif strcmp(obj.Type,'NAT')==1
                    if ~isempty(obj.Resistance)
                        aSignature = [aSignature ' '  SonnetStringWriteFormat(obj.Resistance)];
                    end
                    
                    if ~isempty(obj.SkinCoefficient)
                        aSignature = [aSignature ' '  SonnetStringWriteFormat(obj.SkinCoefficient)];
                    end
                    
                    aSignature = [aSignature sprintf('\n')];
                    
                elseif strcmp(obj.Type,'SUP')==1
                    if ~isempty(obj.Resistance)
                        aSignature = [aSignature ' '  SonnetStringWriteFormat(obj.Resistance)];
                    end
                    
                    if ~isempty(obj.SkinCoefficient)
                        aSignature = [aSignature ' '  SonnetStringWriteFormat(obj.SkinCoefficient)];
                    end
                    
                    if ~isempty(obj.Reactance)
                        aSignature = [aSignature ' '  SonnetStringWriteFormat(obj.Reactance)];
                    end
                    
                    if ~isempty(obj.KineticInductance)
                        aSignature = [aSignature ' '  SonnetStringWriteFormat(obj.KineticInductance)];
                    end
                    aSignature = [aSignature sprintf('\n')];
                    
                elseif strcmp(obj.Type,'SEN')==1
                    if ~isempty(obj.KineticInductance)
                        aSignature = [aSignature ' '  SonnetStringWriteFormat(obj.Resistance)];
                    end
                    aSignature = [aSignature sprintf('\n')];
                else
                    if ~isempty(obj.Unknown)
                        aSignature = [aSignature sprintf(' %s',obj.Unknown)];
                    end
                    aSignature = [aSignature sprintf('\n')];
                    
                end
            end
        end
    end
end

