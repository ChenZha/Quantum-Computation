classdef SonnetVariableSweepParameter < handle
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This class defines a parameter for a sweep in the VARSWP block.
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
        
        ParameterName               % Stores the name of the parameter
        MinValue                    % this value specifies the minimum value for the sweep
        MaxValue                    % this value specifies the maximum value for the sweep
        StepValue                   % this value specifies the step value for the sweep
        ParameterBeingUsedForSweep  % this indicated if the value is being used for the sweep, it can be 'N','Y','YN','YS', or 'YE'
        
    end
    
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = SonnetVariableSweepParameter(theFid, theParameterName)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % The constructor for a parameter for a particular
            %   sweep in the VARSWP block.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if nargin == 2
                
                initialize(obj);						   					% Initialize the values of the properties using the initializer function
                
                obj.ParameterName=theParameterName;			% Store the passed parameter name as the parameter name property.
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % We are going to read the values for the parameter
                % from the file and store them in the properties,
                % These can be 'UNDEF' too so we need to sameple the
                % entry and determine if it is a string or an double.
                % We then can read it in the proper way after
                % restoring the file identifier.
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                obj.ParameterBeingUsedForSweep=fscanf(theFid,' %s',1);
                
                aBackupOfTheFid=ftell(theFid);          	        % Store a backup of the file ID so that we can restore it afer we read the line
                aTempString=fscanf(theFid,' %s',1);
                fseek(theFid,aBackupOfTheFid,'bof');	            % Restore the backup of the fid
                
                if strcmp(aTempString,'UNDEF')==1
                    obj.MinValue=fscanf(theFid,' %s',1);
                else
                    obj.MinValue=fscanf(theFid,' %f',1);
                end
                
                aBackupOfTheFid=ftell(theFid);          	        % Store a backup of the file ID so that we can restore it afer we read the line
                aTempString=fscanf(theFid,' %s',1);
                fseek(theFid,aBackupOfTheFid,'bof');	            % Restore the backup of the fid
                
                if strcmp(aTempString,'UNDEF')==1
                    obj.MaxValue=fscanf(theFid,' %s',1);
                else
                    obj.MaxValue=fscanf(theFid,' %f',1);
                end
                
                aBackupOfTheFid=ftell(theFid);          	        % Store a backup of the file ID so that we can restore it afer we read the line
                aTempString=fscanf(theFid,' %s',1);
                fseek(theFid,aBackupOfTheFid,'bof');	            % Restore the backup of the fid
                
                if strcmp(aTempString,'UNDEF')==1
                    obj.StepValue=fscanf(theFid,' %s',1);
                else
                    obj.StepValue=fscanf(theFid,' %f',1);
                end
                
            else
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % we come here when we didn't recieve a file ID as an argument
                % which means that we are going to create a default VarswpParameter block with
                % default values by calling the function's initialize method.
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                initialize(obj);
                
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function initialize(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function initializes the VarswpParameter properties
            %   to some default values. This is called by the
            %   constructor and can be called by the user to
            %   reinitialize the object to default values.
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
            aNewObject=SonnetVariableSweepParameter();
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
            
            % If the value is defined print it out to the file
            if (~isempty(obj.ParameterName))
                
                aTempString=SonnetStringWriteFormat(obj.ParameterName);
                aSignature = sprintf('%s %s',aTempString, obj.ParameterBeingUsedForSweep);
                
                if isa(obj.MinValue,'char')
                    aSignature = [aSignature sprintf(' %s',obj.MinValue)];
                else
                    aSignature = [aSignature sprintf(' %.15g',obj.MinValue)];
                end
                
                if isa(obj.MaxValue,'char')
                    aSignature = [aSignature sprintf(' %s',obj.MaxValue)];
                else
                    aSignature = [aSignature sprintf(' %.15g',obj.MaxValue)];
                end
                
                if isa(obj.StepValue,'char')
                    aSignature = [aSignature sprintf(' %s\n',obj.StepValue)];
                else
                    aSignature = [aSignature sprintf(' %.15g\n',obj.StepValue)];
                end
                
            end
        end
        
    end
    
end

