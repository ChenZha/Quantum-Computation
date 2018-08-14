classdef SonnetFileOutLine < handle
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This class defines a file output type for a Sonnet project.
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
        
        FileType
        NetworkName
        Embed
        IncludeAbs
        Filename
        IncludeComments
        IsOutputHighPerformance
        ParameterType
        ParameterForm
        Options
        PortType
        Resistance
        ImaginaryResistance
        Reactance
        Inductance
        Capacitance
        Topology
       
        % For INDMODEL
        ModelType
        FrequencyBand
        StartFreq
        StopFreq
        
        % For PMODEL
        PINT
        RMAX
        CMIN
        LMAX
        KMIN
        RZERO
        TYPE
        
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = SonnetFileOutLine(theFid)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % The constructor for an individual file output type
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if nargin == 1      % If we were passed 1 argument which means we got the theFid
                
                initialize(obj);	% Initialize the values of the properties using the initializer function
                
                % Read in the file type, if it is 'END' then we should stop looping
                obj.FileType=fscanf(theFid,'%s',1);
                
                % If the file type is FREQBAND then read option and return
                 if strcmp(obj.FileType,'FREQBAND')==1
                    obj.FrequencyBand=fscanf(theFid,'%s',1);
                    
                    if strcmpi(obj.FrequencyBand,'custom')==1
                        obj.StartFreq=fscanf(theFid,'%s',1);
                        obj.StopFreq=fscanf(theFid,'%s',1);
                    end                                 
                    return
                 elseif strcmpi(obj.FileType,'OPTIONS')==1
                    aTempString=fscanf(theFid,'%s',1);
                    if strcmp(aTempString,'END')==1
                    else
                        warning('Unknown Option');
                    end
                    return
                end
                
                
                % If the file type is folder then read in the rest of the
                % line and store it in the filetype
                if strcmp(obj.FileType,'FOLDER')==1
                    obj.FileType=[obj.FileType fgets(theFid)];
                    return
                end
                
                % Read in a temporary string, it may be a 'NET=' string to specify the network if the project is a netlist, oterwise it is ommited for a gerometry project.
                aTempString=fscanf(theFid,'%s',1);
                
                if ~isempty(strfind(aTempString,'NET=')) % If there is a net statement then we can assign it to a variable,
                    [~, obj.NetworkName]=strtok(aTempString,'=');
                    obj.Embed=fscanf(theFid,'%s',1);
                    obj.NetworkName=strrep(obj.NetworkName,'=','');
                    
                else % Otherwise we read in the embedding
                    obj.Embed=aTempString;
                end
                
                % Read in whether we should include ABS
                obj.IncludeAbs=fscanf(theFid,'%s',1);
                
                % Read in whether we should filename
                obj.Filename=SonnetStringReadFormat(theFid);
                
                % Read in whether we should comments
                obj.IncludeComments=fscanf(theFid,'%s',1);
                
                % Read in whether the output should be high precision
                % high precision will be 15 and nonhigh will be 8.
                % this is what we will read but we will store 'Y'/'N'
                % to be simpiler for the user.
                if fscanf(theFid,'%d',1) == 15
                    obj.IsOutputHighPerformance='Y';
                else
                    obj.IsOutputHighPerformance='N';
                end
                                              
                % If the type is pimodel then read in the line
                if strcmp(obj.FileType,'PIMODEL')==1
                    aTempString =fscanf(theFid,'%s',1);
                    while strcmp(aTempString,sprintf('\n'))==0
                        if ~isempty(strfind(aTempString,'PINT'))
                            obj.PINT=str2double(strrep(aTempString,'PINT=',''));
                        elseif ~isempty(strfind(aTempString,'RMAX'))
                            obj.RMAX=str2double(strrep(aTempString,'RMAX=',''));
                        elseif ~isempty(strfind(aTempString,'CMIN'))
                            obj.CMIN=str2double(strrep(aTempString,'CMIN=',''));
                        elseif ~isempty(strfind(aTempString,'LMAX'))
                            obj.LMAX=str2double(strrep(aTempString,'LMAX=',''));
                        elseif ~isempty(strfind(aTempString,'KMIN'))
                            obj.KMIN=str2double(strrep(aTempString,'KMIN=',''));
                        elseif ~isempty(strfind(aTempString,'RZERO'))
                            obj.RZERO=str2double(strrep(aTempString,'RZERO=',''));
                        else
                            obj.TYPE=aTempString;
                            return;
                        end
                        aTempString =fscanf(theFid,'%s',1);
                    end                    
                end
                
                % Read in the type of parameters
                obj.ParameterType=fscanf(theFid,'%s',1);
                
                % If the type was 'NCLINE' for an n-coupled line model
                % we can return and leave since the line is over.
                if strcmp(obj.FileType,'NCLINE')==1
                    return;
                    
                    % If the type was 'BBEXTRACT' for an broadband spice model
                    % we can read in the options block as an unknown block and
                    % return and leave since the fileout selection is over.
                elseif strcmp(obj.FileType,'BBEXTRACT')==1
                    fgetl(theFid);
                    aBlockName=fgetl(theFid);
                    obj.Options=SonnetUnknownBlock(theFid,aBlockName);
                    return;
                end
                
                % Read in the form of parameters
                obj.ParameterForm=fscanf(theFid,'%s',1);

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Now we will read in the value for the ports; there are 4 types
                %   1)R resist
                %   2)Z rresist iresist
                %   3)TERM resist(1) react (1) resist(2) react(2) ... resist(n) react(n)
                %   4)FTERM resist(1) react(1) induct(1) cap(1) ... resist(n) react(n) induct(n) cap(n)
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                aTempString=fscanf(theFid,' %s',1); % read in the type of port
                
                % if INDMODEL there is no port type to read in.
                if strcmp(obj.FileType,'INDMODEL')==1
                    obj.ModelType=fscanf(theFid,'%s',1);
                    return;
                end
                
                switch aTempString
                    
                    case 'R'
                        obj.PortType='R';
                        obj.Resistance=fscanf(theFid,' %f',1);
                        
                    case 'Z'
                        obj.PortType='Z';
                        obj.Resistance=fscanf(theFid,' %f',1);
                        obj.ImaginaryResistance=fscanf(theFid,' %f',1);
                        
                    case 'TERM'
                        obj.PortType='TERM';
                        
                        isKeepLoopsing=true; % This boolean controls if we should read in more values from the statement. We want to go into the loop at least once so start out true.
                        
                        % This reads all the values on a particular line
                        while isKeepLoopsing == true                % If it is not a newline then there are more parameters
                            
                            obj.Resistance=[obj.Resistance fscanf(theFid,' %f',1)];
                            obj.Reactance=[obj.Reactance fscanf(theFid,' %f',1)];
                            
                            aBackupOfTheFid=ftell(theFid);                      % Store a backup of the file ID so that we can restore it afer we read the line
                            aTempString=fgetl(theFid);                          % read in the whole line so that we can determine if there is an ampersand on the line
                            fseek(theFid,aBackupOfTheFid,'bof');                % Restore the backup of the fid
                            
                            if isempty(strtrim(aTempString))                    % If there is nothing left on the line then we can stop reading in values
                                isKeepLoopsing=false;
                            elseif strcmp(strtrim(aTempString),'&')==1
                                fgets(theFid);                                    % Read in the rest of the line
                            end
                            
                        end
                        
                    case 'FTERM'
                        obj.PortType='FTERM';
                        
                        isKeepLoopsing=true; % This boolean controls if we should read in more values from the statement. We want to go into the loop at least once so start out true.
                        
                        % This reads all the values on a particular line
                        while isKeepLoopsing == true                          % If it is not a newline then there are more parameters
                            
                            obj.Resistance=[obj.Resistance fscanf(theFid,' %f',1)];
                            obj.Reactance=[obj.Reactance fscanf(theFid,' %f',1)];
                            obj.Inductance=[obj.Inductance fscanf(theFid,' %f',1)];
                            obj.Capacitance=[obj.Capacitance fscanf(theFid,' %f',1)];
                            
                            aBackupOfTheFid=ftell(theFid);                      % Store a backup of the file ID so that we can restore it afer we read the line
                            aTempString=fgetl(theFid);                          % read in the whole line so that we can determine if there is an ampersand on the line
                            fseek(theFid,aBackupOfTheFid,'bof');                % Restore the backup of the fid
                            
                            if isempty(strtrim(aTempString))                    % If there is nothing left on the line then we can stop reading in values
                                isKeepLoopsing=false;
                            elseif strcmp(strtrim(aTempString),'&')==1
                                fgets(theFid);                                    % Read in the rest of the line
                            end
                            
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
            % This function initializes the object's properties to some default
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
            aNewObject=SonnetFileOutLine();
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
            
            aSignature = '';
            
            if strcmp(obj.FileType, 'INDMODEL')
                if theVersion < 14 
                    return;
                end
            end
            
            if ~isempty(obj.FileType)
                aSignature = [aSignature sprintf('%s',obj.FileType)];
            end
            
            % added in for V13.56 INDMODEL
            if strcmpi(obj.FileType,'FREQBAND')==1
               aSignature = [aSignature sprintf(' %s',obj.FrequencyBand)];
                
               if ~isempty(obj.StartFreq)
                  aSignature = [aSignature sprintf(' %g',obj.StartFreq)];
               end
               
               if ~isempty(obj.StopFreq)
                  aSignature = [aSignature sprintf(' %g',obj.StopFreq)];
               end
               
               aSignature = [aSignature sprintf('\n')];
               return
            elseif strcmp(obj.FileType,'OPTIONS')==1
               aSignature = [aSignature sprintf('\n')];
               aSignature = [aSignature sprintf('%s','END')];
               aSignature = [aSignature sprintf('\n')];
               return
            end            
            
            if ~isempty(obj.NetworkName)
                aString=strrep(obj.NetworkName,'=','');
                aSignature = [aSignature sprintf(' NET=%s',aString)];
            end
            
            if ~isempty(obj.Embed)
                aSignature = [aSignature sprintf(' %s',obj.Embed)];
            end
            
            if ~isempty(obj.IncludeAbs)
                aSignature = [aSignature sprintf(' %s',obj.IncludeAbs)];
            end
            
            if ~isempty(obj.Filename)
                aString=strrep(obj.Filename,'"','');
                aSignature = [aSignature sprintf(' %s', aString)]; %V14 Change
            end
            
            if ~isempty(obj.IncludeComments)
                aSignature = [aSignature sprintf(' %s',obj.IncludeComments)];
            end
            
            if ~isempty(obj.IsOutputHighPerformance)
                if strcmpi(obj.IsOutputHighPerformance,'Y')==1
                    aSignature = [aSignature sprintf(' 15')];
                else
                    aSignature = [aSignature sprintf(' 8')];
                end
            end
            
            if strcmp(obj.FileType,'PIMODEL')==1
                aSignature = [aSignature sprintf(' PINT=%.15g',obj.PINT)];
                aSignature = [aSignature sprintf(' RMAX=%.15g',obj.RMAX)];
                aSignature = [aSignature sprintf(' CMIN=%.15g',obj.CMIN)];
                aSignature = [aSignature sprintf(' LMAX=%.15g',obj.LMAX)];
                aSignature = [aSignature sprintf(' KMIN=%.15g',obj.KMIN)];
                aSignature = [aSignature sprintf(' RZERO=%.15g',obj.RZERO)];
                aSignature = [aSignature sprintf(' %s',obj.TYPE)];
                aSignature = [aSignature sprintf('\n')];
            end
            
            if ~isempty(obj.ParameterType)
                aSignature = [aSignature sprintf(' %s',obj.ParameterType)];
            end
            
            if strcmp(obj.FileType,'NCLINE')==1
                aSignature = [aSignature sprintf('\n')];
            end
            
            if ~isempty(obj.Options)
                aSignature = [aSignature sprintf('\n') obj.Options.stringSignature(theVersion)];
            end
            
            if ~isempty(obj.ParameterForm)
                aSignature = [aSignature sprintf(' %s',obj.ParameterForm)];
            end                      
            
            if ~isempty(obj.Topology)             
                aSignature = [aSignature sprintf(' N %s',obj.Topology)];
                aSignature = [aSignature sprintf('\n')];
                return
            end 
                                   
            if ~isempty(obj.ModelType)             
                aSignature = [aSignature sprintf(' N %s',obj.ModelType)];
                aSignature = [aSignature sprintf('\n')];
                return
            end  
            
            if strcmp(obj.PortType,'R')==1
                if isa(obj.Resistance,'char')
                    aSignature = [aSignature sprintf(' R %s\n',obj.Resistance)];
                else
                    aSignature = [aSignature sprintf(' R %.15g\n',obj.Resistance)];
                end
                
            elseif strcmp(obj.PortType,'Z')==1
                if isa(obj.Resistance,'char')
                    aSignature = [aSignature sprintf(' Z %s %s\n',obj.Resistance,obj.ImaginaryResistance)];
                else
                    aSignature = [aSignature sprintf(' Z %.15g %.15g\n',obj.Resistance,obj.ImaginaryResistance)];
                end
                
            elseif strcmp(obj.PortType,'TERM')==1
                aSignature = [aSignature sprintf(' TERM')];
                for iCounter=1:length(obj.Resistance)
                    if isa(obj.Resistance,'char')
                        aSignature = [aSignature sprintf(' %s %s',obj.Resistance(iCounter),obj.Reactance(iCounter))]; %#ok<AGROW>
                    else
                        aSignature = [aSignature sprintf(' %.15g %.15g',obj.Resistance(iCounter),obj.Reactance(iCounter))]; %#ok<AGROW>
                    end
                end
                aSignature = [aSignature sprintf('\n')];
                
            elseif strcmp(obj.PortType,'FTERM')==1
                aSignature = [aSignature sprintf(' FTERM')];
                for iCounter=1:length(obj.Resistance)
                    if isa(obj.Resistance,'char')
                        aSignature = [aSignature sprintf(' %s %s %s %s',obj.Resistance(iCounter),obj.Reactance(iCounter),...
                            obj.Inductance(iCounter),obj.Capacitance(iCounter))]; %#ok<AGROW>
                    else
                        aSignature = [aSignature sprintf(' %.15g %.15g %.15g %.15g',obj.Resistance(iCounter),obj.Reactance(iCounter),...
                            obj.Inductance(iCounter),obj.Capacitance(iCounter))]; %#ok<AGROW>
                    end
                end
                aSignature = [aSignature sprintf('\n')];
                
            end
            
        end
        
    end
    
end

