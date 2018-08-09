classdef SonnetVariableSweepEntry < handle
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This class defines the SWEEP that is used for a variable sweep.
    %     The sweep will always be contained in a VARSWP object.
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
        
        Sweep                       % Stores an object for the sweep
        ParameterArray              % Stores the parameters that were used for this sweep
        
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = SonnetVariableSweepEntry(theFid, theSweepName, theSweep)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % The constructor for a SWEEP.
            %     The constructor will be passed the file
            %     ID from the SONNET VARSWP block constructor.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if nargin == 3
                
                initialize(obj);                             % Initialize the values of the properties using the initializer function
                
                NumberOfParamters=0;                         % Keep track of the number of parameters for this sweep
                obj.Sweep=theSweep;
                
                aTempString=fscanf(theFid,'%s',1);           % Try to read the the first type of the sweep from the file.
                aBackupOfTheFid=[];
                
                while (1==1)                                 % loop forever till we get to the end of the paramter list for this sweep, there can be an undefined number of parameters
                    
                    switch aTempString
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        % check if it is a new kind of sweep, if so then we need to
                        % move the filepointer back to the beginning of that line.
                        % this will allow us to read in only the parameters for this
                        % sweep without interfering with the other sweeps.
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        case 'SIMPLE'                            % check if it is a simple sweep
                            if ~isempty(aBackupOfTheFid)
                                fseek(theFid,aBackupOfTheFid,'bof'); % Restore the backup of the fid
                            end
                            break;
                        case 'ABS'                               % check if it is a abs sweep
                            if ~isempty(aBackupOfTheFid)
                                fseek(theFid,aBackupOfTheFid,'bof'); % Restore the backup of the fid
                            end
                            break;
                        case 'SWEEP'                             % check if it is a sweep sweep
                            if ~isempty(aBackupOfTheFid)
                                fseek(theFid,aBackupOfTheFid,'bof'); % Restore the backup of the fid
                            end
                            break;
                        case 'ABS_ENTRY'                         % check if it is a abs entry sweep
                            if ~isempty(aBackupOfTheFid)
                                fseek(theFid,aBackupOfTheFid,'bof'); % Restore the backup of the fid
                            end
                            break;
                        case 'STEP'                              % check if it is a step sweep
                            if ~isempty(aBackupOfTheFid)
                                fseek(theFid,aBackupOfTheFid,'bof'); % Restore the backup of the fid
                            end
                            break;
                        case 'ESWEEP'                            % check if it is a esweep sweep
                            if ~isempty(aBackupOfTheFid)
                                fseek(theFid,aBackupOfTheFid,'bof'); % Restore the backup of the fid
                            end
                            break;
                        case 'ABS_FMIN'                          % check if it is a abs_fmin sweep
                            if ~isempty(aBackupOfTheFid)
                                fseek(theFid,aBackupOfTheFid,'bof'); % Restore the backup of the fid
                            end
                            break;
                        case 'ABS_FMAX'                          % check if it is a abs_fmax sweep
                            if ~isempty(aBackupOfTheFid)
                                fseek(theFid,aBackupOfTheFid,'bof'); % Restore the backup of the fid
                            end
                            break;
                        case 'END'                               % check if it is the end of the varswp block
                            if ~isempty(aBackupOfTheFid)
                                aTempString=fgetl(theFid);
                                if isempty(aTempString)
                                    fseek(theFid,aBackupOfTheFid,'bof'); % Restore the backup of the fid
                                    fgetl(theFid);
                                    fgetl(theFid);
                                else
                                    fseek(theFid,aBackupOfTheFid,'bof'); % Restore the backup of the fid
                                end
                                
                            end
                            break;
                            
                        case 'VAR'
                            aTempString=fscanf(theFid,'%s',1);
                            NumberOfParamters=NumberOfParamters+1;                                            % Increment the sweep counter by one
                            obj.ParameterArray{NumberOfParamters}=SonnetVariableSweepParameter(theFid,aTempString);    	% construct the new parameter and store in the cell array, give the parameter the string so it knows its name
                            
                        otherwise                                                                                   % Otherwise it is a parameter and we should make a parameter object
                            NumberOfParamters=NumberOfParamters+1;                                            % Increment the sweep counter by one
                            obj.ParameterArray{NumberOfParamters}=SonnetVariableSweepParameter(theFid,aTempString);    	% construct the new parameter and store in the cell array, give the parameter the string so it knows its name
                            
                    end
                    
                    aBackupOfTheFid=ftell(theFid);             % Store a backup of the file ID so that we can restore it if we need it
                    aTempString=fscanf(theFid,'%s',1);         % read the next sweep name from the file, if it is END then we are done
                    
                end
                
                
                
            else
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % we come here when we didn't recieve a file ID as an argument
                % which means that we are going to create a default varsweep block with
                % default values by calling the function's initialize method.
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                initialize(obj);
                
            end
            
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function initialize(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function initializes the varsweep properties to some
            %   default values. This is called by the constructor and can
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
            aNewObject=SonnetVariableSweepEntry();
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
            
            if (~isempty(obj.Sweep))
                aSignature = obj.Sweep.stringSignature(theVersion);
            end
            
            for iCounter= 1:length(obj.ParameterArray)
                if nargin == 2 && theVersion >= 13
                    aSignature = [aSignature 'VAR ']; %#ok<AGROW>
                end
                aSignature = [aSignature obj.ParameterArray{iCounter}.stringSignature(theVersion)]; %#ok<AGROW>
            end
            
            if theVersion >= 13
                aSignature = [aSignature 'END' sprintf('\n')];
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function activateVariableSweepParameter(obj,theVariableName)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %   This function will set the parameter in
            %   use value for the specified parameter in the
            %   variable sweep.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            for iCounter=1:length(obj.ParameterArray)
               if strcmpi(obj.ParameterArray{iCounter}.ParameterName,theVariableName) == 1
                   obj.ParameterArray{iCounter}.ParameterBeingUsedForSweep='Y';
                   return
               end
            end
            
            error('Specified variable parameter not found')
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function deactivateVariableSweepParameter(obj,theVariableName)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %   This function will set the parameter in
            %   use value for the specified parameter in the
            %   variable sweep.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            for iCounter=1:length(obj.ParameterArray)
               if strcmpi(obj.ParameterArray{iCounter}.ParameterName,theVariableName) == 1
                   obj.ParameterArray{iCounter}.ParameterBeingUsedForSweep='N';
                   return
               end
            end
            
            error('Specified variable parameter not found')
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeVariableSweepParameterState(obj,theVariableName,theStatus)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %   This function will modify the parameter in
            %   use value for the specified parameter in the
            %   variable sweep.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            for iCounter=1:length(obj.ParameterArray)
               if strcmpi(obj.ParameterArray{iCounter}.ParameterName,theVariableName) == 1
                   obj.ParameterArray{iCounter}.ParameterBeingUsedForSweep=theStatus;
                   return
               end
            end
            
            error('Specified variable parameter not found')
            
        end
        
    end
    
end
