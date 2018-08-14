classdef SonnetOptimizationVariable < handle
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This class defines a variable that is included in the OPT block.
    % An optimization variable defines one optimization sweep for the project.
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
        
        VariableName              % Stores the name of the Var
        MinValue                  % this value specifies the minimum value for the sweep
        MaxValue                  % this value specifies the maximum value for the sweep
        StepValue                 % this value specifies the step value for the sweep
        VariableBeingUsed  		  % this indicated if the value is being used for the sweep
        
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = SonnetOptimizationVariable(theFid, theVarName)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % The constructor for the var for a particular
            %   line in the VAR area of the OPT block.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if nargin == 2
                
                initialize(obj);              % Initialize the values of the properties using the initializer function
                
                obj.VariableName=theVarName;  % Save the name of the variable as a property
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % We are going to read the values for the Variable
                % from the file and store them in the properties.
                % Some values may be UNDEF (undefined).
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Read whether it is being used as a y/n, this always exists
                obj.VariableBeingUsed=fscanf(theFid,' %s',1);
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % We cant be sure whether any of the values here are
                % going to be a string for UNDEF or an floating point
                % number so We will have to read in a value as a string,
                % check if it is 'UNDEF' if so then we can use that
                % otherwise we will have to read it in again as an integer.
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                aBackupOfTheFid=ftell(theFid);          	        % Store a backup of the file ID so that we can restore it afer we read the line
                aTempString=fscanf(theFid,' %s',1);
                fseek(theFid,aBackupOfTheFid,'bof');	            % Restore the backup of the fid
                
                if strcmp(aTempString,'UNDEF')==0
                    obj.MinValue=fscanf(theFid,' %f',1);
                else
                    obj.MinValue=fscanf(theFid,' %s',1);
                end
                
                aBackupOfTheFid=ftell(theFid);          	        % Store a backup of the file ID so that we can restore it afer we read the line
                aTempString=fscanf(theFid,' %s',1);
                fseek(theFid,aBackupOfTheFid,'bof');	            % Restore the backup of the fid
                
                if strcmp(aTempString,'UNDEF')==0
                    obj.MaxValue=fscanf(theFid,' %f',1);
                else
                    obj.MaxValue=fscanf(theFid,' %s',1);
                end
                
                aBackupOfTheFid=ftell(theFid);          	        % Store a backup of the file ID so that we can restore it afer we read the line
                aTempString=fscanf(theFid,' %s',1);
                fseek(theFid,aBackupOfTheFid,'bof');	            % Restore the backup of the fid
                
                if strcmp(aTempString,'UNDEF')==0
                    obj.StepValue=fscanf(theFid,' %f',1);
                else
                    obj.StepValue=fscanf(theFid,' %s',1);
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
            % This function initializes the object's properties to
            %	some default values. This is called by the constructor
            %	and can be called by the user to reinitialize the
            %	object to default values.
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
            aNewObject=SonnetOptimizationVariable();
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
            
            if nargin == 2 && theVersion >= 13
                aSignature='VAR ';
            else
                aSignature='';
            end
            
            % If the value is defined print it out to the file
            if (~isempty(obj.VariableName))
                aSignature = [aSignature sprintf('%s %s',obj.VariableName, obj.VariableBeingUsed)];
            end
            
            if isa(obj.MinValue,'double')
                aSignature = [aSignature sprintf(' %d',obj.MinValue)];
            elseif isa(obj.MinValue,'char')
                aSignature = [aSignature sprintf(' %s',obj.MinValue)];
            end
            
            if isa(obj.MaxValue,'double')
                aSignature = [aSignature sprintf(' %d',obj.MaxValue)];
            elseif isa(obj.MaxValue,'char')
                aSignature = [aSignature sprintf(' %s',obj.MaxValue)];
            end
            
            if isa(obj.StepValue,'double')
                aSignature = [aSignature sprintf(' %d',obj.StepValue)];
            elseif isa(obj.StepValue,'char')
                aSignature = [aSignature sprintf(' %s',obj.StepValue)];
            end
            
            aSignature = [aSignature sprintf('\n')];
            
        end
    end
end

