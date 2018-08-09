classdef SonnetCircuitProject < handle
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This class defines a project element in the circuit (CKT) block
    % of a Sonnet Netlist project.
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
        
        ArrayOfPortNodeNumbers          % Stores the port numbers
        Filename                        % Stores the filename
        NumberOfPorts
        UseSweepFromSubproject          % UseSweepFromSubproject is 0 to indicate that you use the sweep from this project or 1 to indicate that you use the sweep from the subproject. This setting is overridden if Hierarchy Sweep is on.
        ArrayOfParameters               % Array of the parameters
        NetworkIndex                    % The index of the network this element belongs to in the array of networks
        Date
        Time
        
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = SonnetCircuitProject(theFid,theNetworkNumber)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % The constructor for Circuit project element, this is defined
            % in the Circuit Block (CKT) entry in the Sonnet Project
            % File for Netlists.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if nargin == 2
                
                initialize(obj);
                
                obj.NetworkIndex=theNetworkNumber;
                
                while isempty(obj.Filename) % Read in all the ports.
                    
                    aBackupOfTheFid=ftell(theFid);
                    aTempString=fscanf(theFid,' %s',1);
                    fseek(theFid,aBackupOfTheFid,'bof');
                    
                    if isnan(str2double(aTempString))
                        obj.Filename=SonnetStringReadFormat(theFid);
                    else
                        obj.ArrayOfPortNodeNumbers=[obj.ArrayOfPortNodeNumbers fscanf(theFid,' %d',1)];
                    end
                    
                end
                
                fscanf(theFid,'%d',1); % Read in the number of ports, the value is not needed because we will use a get method to return the number
                obj.UseSweepFromSubproject=fscanf(theFid,'%d',1);
                
                % If we were given the date then just ignore it
                aBackupOfTheFid=ftell(theFid);
                aTempString=fscanf(theFid,' %s',1);
                fseek(theFid,aBackupOfTheFid,'bof');
                
                if strcmpi(aTempString,'DATE')==1
                    fscanf(theFid,' %s',1);  % read the date tag
                    obj.Date=fscanf(theFid,' %s',1);  % read the date value
                    obj.Time=fscanf(theFid,' %s',1);  % read the time
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Now we will loop and read in all the parameters that were included.
                % This will be done by reading in a character, checking if it is a
                % space or a newline character; if it is a space then there is
                % another parameter to be read. If it is a newline then we are
                % done reading parameters.
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                aBackupOfTheFid=ftell(theFid);
                aTempString=fscanf(theFid,' %s',1);
                fseek(theFid,aBackupOfTheFid,'bof');
                
                while ~isempty(strfind(aTempString,'=')) % If it is not a newline then there are more parameters
                    
                    [aTempParameterName aTempParameterValue]=strtok(fscanf(theFid,'%s',1),'='); % Get the values before and after the equals sign
                    
                    % Remove the equals sign from the temp parameter value
                    aTempParameterValue=strrep(aTempParameterValue,'=','');
                    
                    % If there is a space between the equals sign and the variable name
                    % then the variable value then the variable value will not be
                    % read as part of this entry but rather as the next.
                    if isempty(strtrim(aTempParameterValue))
                        aTempParameterValue=strtrim(fscanf(theFid,' %s',1));
                    end
                    
                    % Make a parameter object and store it in the array of parameters
                    aTempParameter=SonnetVariableParameter();
                    
                    aTempParameter.ParameterName=aTempParameterName;
                    aTempParameter.ParameterValue=aTempParameterValue;
                    obj.ArrayOfParameters=[obj.ArrayOfParameters aTempParameter];
                    
                    aBackupOfTheFid=ftell(theFid);
                    aTempString=fscanf(theFid,' %s',1);
                    fseek(theFid,aBackupOfTheFid,'bof');
                    
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
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % This method will return the number of ports when requested
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aNumberOfPorts=get.NumberOfPorts(obj)
            aNumberOfPorts=length(obj.ArrayOfPortNodeNumbers);
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
            aNewObject=SonnetCircuitProject();
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
            
            aSignature = 'PRJ';
            
            for iCounter= 1:length(obj.ArrayOfPortNodeNumbers)
                aSignature = [aSignature sprintf(' %d',obj.ArrayOfPortNodeNumbers(iCounter))]; %#ok<AGROW>
            end
            
            if ~isempty(obj.Filename)
                aSignature = [aSignature sprintf(' %s',obj.Filename)];
            end
            
            if ~isempty(obj.NumberOfPorts)
                aSignature = [aSignature sprintf(' %d',obj.NumberOfPorts)];
            end
            
            if ~isempty(obj.UseSweepFromSubproject)
                aSignature = [aSignature sprintf(' %d',obj.UseSweepFromSubproject)];
            end
            
            for iCounter= 1:length(obj.ArrayOfParameters)
                aSignature = [aSignature ' ' obj.ArrayOfParameters(iCounter).stringSignature(theVersion)]; %#ok<AGROW>
            end
            
            if ~isempty(obj.Date)
                aSignature = [aSignature sprintf(' DATE %s',obj.Date)];
            end
            
            if ~isempty(obj.Time)
                aSignature = [aSignature sprintf(' %s',obj.Time)];
            end
            
            aSignature = [aSignature  sprintf('\n')];
            
        end
        
    end
    
end

