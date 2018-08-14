classdef SonnetCircuitTransmissionLine < handle
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This class defines a transmission line element in the circuit (CKT) block
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
        
        NodeNumber1         % The node number that one end of the transmission line is connected to
        NodeNumber2         % The node number that the other end of the transmission line is connected to, This is optional.
        ImpedanceValue      % The magnitude of the impedance for the transmission line
        LengthValue         % The length of the transmission line
        FrequencyValue      % The frequency of the transmission line
        NetworkIndex        % The index of the network this element belongs to in the array of networks
        GroundNode          % The Ground Node
        
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = SonnetCircuitTransmissionLine(theFid,theNetworkNumber)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % The constructor for Circuit transmission line, this is defined
            % in the Circuit Block (CKT) entry in the Sonnet Project
            % File for Netlists.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if nargin == 2
                
                initialize(obj);	% Initialize the values of the properties using the initializer function
                
                obj.NetworkIndex=theNetworkNumber;
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % We are going to read the values for the transmission line
                % from the file and store them in the properties
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                obj.NodeNumber1=fscanf(theFid,' %d',1);
                
                obj.NodeNumber2=fscanf(theFid,' %d',1);
                
                aBackupOfTheFid=ftell(theFid);                          % Store a backup of the file ID so that we can restore it afer we read the line
                aTempCharacter=fscanf(theFid,' %c',1);                  % Read in a temporary character, if it is a number then the frequency was represented as an FP number, otherwise it is a variable
                fseek(theFid,aBackupOfTheFid,'bof');                    % Restore the backup of the fid
                
                if strcmp(aTempCharacter,'Z')==0
                    obj.GroundNode=fscanf(theFid,' %d',1);
                end
                
                % Read in the impedance
                fscanf(theFid,' %c',1);                           % Get the string 'Z', we dont need to store it anywhere
                fscanf(theFid,' %c',1);                           % Get the string '=', we dont need to store it anywhere
                
                aBackupOfTheFid=ftell(theFid);          	      % Store a backup of the file ID so that we can restore it afer we read the line
                aTempCharacter=fscanf(theFid,' %s',1);            % Read in a temporary character, if it is a number then the impedance was represented as an FP number, otherwise it is a variable
                fseek(theFid,aBackupOfTheFid,'bof');	          % Restore the backup of the fid
                
                if isnan(str2double(aTempCharacter))
                    obj.ImpedanceValue=fscanf(theFid,' %s',1);
                    obj.ImpedanceValue=strrep(obj.ImpedanceValue,'=','');
                    obj.ImpedanceValue=strtrim(obj.ImpedanceValue);
                    if ~isnan(str2double(obj.ImpedanceValue))
                        obj.ImpedanceValue=str2double(obj.ImpedanceValue);
                    end
                else
                    obj.ImpedanceValue=fscanf(theFid,' %f',1);
                end
                
                % Read in the length
                fscanf(theFid,' %c',1);                         % Get the string 'E', we dont need to store it anywhere
                fscanf(theFid,' %c',1);                         % Get the string '=', we dont need to store it anywhere
                
                aBackupOfTheFid=ftell(theFid);          	    % Store a backup of the file ID so that we can restore it afer we read the line
                aTempCharacter=fscanf(theFid,' %s',1);          % Read in a temporary character, if it is a number then the length was represented as an FP number, otherwise it is a variable
                fseek(theFid,aBackupOfTheFid,'bof');	        % Restore the backup of the fid
                
                if isnan(str2double(aTempCharacter))
                    obj.LengthValue=fscanf(theFid,' %s',1);
                    obj.LengthValue=strrep(obj.LengthValue,'=','');
                    obj.LengthValue=strtrim(obj.LengthValue);
                    if ~isnan(str2double(obj.LengthValue))
                        obj.LengthValue=str2double(obj.LengthValue);
                    end
                else
                    obj.LengthValue=fscanf(theFid,' %f',1);
                end
                
                % Read in the frequency
                fscanf(theFid,' %c',1);                         % Get the string 'F', we dont need to store it anywhere
                fscanf(theFid,' %c',1);                         % Get the string '=', we dont need to store it anywhere
                
                aBackupOfTheFid=ftell(theFid);          	      % Store a backup of the file ID so that we can restore it afer we read the line
                aTempCharacter=fscanf(theFid,' %s',1);          % Read in a temporary character, if it is a number then the frequency was represented as an FP number, otherwise it is a variable
                fseek(theFid,aBackupOfTheFid,'bof');	          % Restore the backup of the fid
                
                if isnan(str2double(aTempCharacter))
                    obj.FrequencyValue=fscanf(theFid,' %s',1);
                    obj.FrequencyValue=strrep(obj.FrequencyValue,'=','');
                    obj.FrequencyValue=strtrim(obj.FrequencyValue);
                    if ~isnan(str2double(obj.FrequencyValue))
                        obj.FrequencyValue=str2double(obj.FrequencyValue);
                    end
                else
                    obj.FrequencyValue=fscanf(theFid,' %f',1);
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
            % This function initializes the sweep properties to some default
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
            aNewObject=SonnetCircuitTransmissionLine();
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
            
            aSignature = 'TLIN';
            
            aSignature = [aSignature sprintf(' %d',obj.NodeNumber1)];
            
            aSignature = [aSignature sprintf(' %d',obj.NodeNumber2)];
            
            if ~isempty(obj.GroundNode)
                aSignature = [aSignature sprintf(' %d',obj.GroundNode)];
            end
            
            if ~isempty(obj.ImpedanceValue)
                if isa(obj.ImpedanceValue,'char')
                    aSignature = [aSignature sprintf(' Z=%s',obj.ImpedanceValue)];
                else
                    aSignature = [aSignature sprintf(' Z=%.15g',obj.ImpedanceValue)];
                end
            end
            
            if ~isempty(obj.LengthValue)
                if isa(obj.LengthValue,'char')
                    aSignature = [aSignature sprintf(' E=%s',obj.LengthValue)];
                else
                    aSignature = [aSignature sprintf(' E=%.15g',obj.LengthValue)];
                end
            end
            
            if ~isempty(obj.FrequencyValue)
                if isa(obj.FrequencyValue,'char')
                    aSignature = [aSignature sprintf(' F=%s',obj.FrequencyValue)];
                else
                    aSignature = [aSignature sprintf(' F=%.15g',obj.FrequencyValue)];
                end
            end
            
            aSignature = [aSignature sprintf('\n')];
            
        end
        
    end
    
end

