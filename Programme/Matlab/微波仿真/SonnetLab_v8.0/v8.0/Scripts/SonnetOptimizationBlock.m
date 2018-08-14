classdef SonnetOptimizationBlock  < handle
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This class defines the OPT portion of a SONNET project file.
    % This class is a container for the optimization information that
    % is obtained from the SONNET project file.
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
        
        VarsArray               % This array stores the variables that were read in from the file
        MaxIterations 			% This is the max number of iterations
        OptimizationSweep		% The sweep that is being optimized
        ResponseType
        RelationString
        TargetType
        TargetValue
        TargetResponseType
        Weight        
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = SonnetOptimizationBlock(theFid)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % The constructor for OPT.
            %     the OPT will be passed the file ID from the
            %     SONNET project constructor.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            NumberOfParamters=0;            % Keep track of the number of optimization variables in the file
            NumberOfOptimizationSweeps=0;	% The number of sweeps/NET= entries defined in the OPT block
            
            if nargin == 1                  % This checks if we got the file ID as an argument
                
                initialize(obj);            % Initialize the values of the properties using the initializer function
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Read a string from the file.
                % This String drives a switch
                % statement to determine what
                % values are going to be changed.
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                aTempString=fscanf(theFid,' %s',1);
                
                while (1==1)                % Loop forever till we get to the end of the paramter list for this sweep, there can be an undefined number of parameters
                    
                    switch aTempString
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        % We want to read in a the MaxIterations value which will be
                        % after the keyword 'MAX'; we want to read in (and ignore) the
                        % term 'VARS'.  Then we want to read in an undisclosed number
                        % of optimization variables. Then we will read in a Frequency
                        % which will mean that we have completed reading in the
                        % variables.  Then we will read in an optimization line that
                        % begins with 'NET=GEO'.
                        %
                        % We can run this all in a case statement by reading in a
                        % String, then checking if it is MAX or VARS. If it is then
                        % Do the appropriate action.  Otherwise check if it is the
                        % same as a sweep name.  If it isn't a sweep then it is an
                        % optimization variable.  If it is a sweep that means we
                        % read in all of the optmization variables.  We can construct
                        % the appropriate sweep object based on the keyword we read.
                        % We then can read in the optimization parameter.
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        case 'MAX'                                                    % If we are reading in the MAX number of iterations
                            obj.MaxIterations=fscanf(theFid,' %d', 1);
                            
                        case 'VARS'                                                   % If we are reading in the VARS line then just ignore it, we dont need to save it.

                        case 'SWEEP'                                                                            % check if it is a sweep sweep
                            NumberOfOptimizationSweeps=NumberOfOptimizationSweeps+1;                            % Increase the counter for the number of sweeps we have in the block
                            obj.OptimizationSweep{NumberOfOptimizationSweeps}=SonnetFrequencySweep(theFid);     % construct the new sweep and store in the cell array
                            
                        case 'ABS_ENTRY'                                                                        % check if it is a abs entry sweep
                            NumberOfOptimizationSweeps=NumberOfOptimizationSweeps+1;                            % Increase the counter for the number of sweeps we have in the block
                            obj.OptimizationSweep{NumberOfOptimizationSweeps}=SonnetFrequencyAbsEntry(theFid);  % construct the new sweep and store in the cell array
                            
                        case 'STEP'                                                                             % check if it is a step sweep
                            NumberOfOptimizationSweeps=NumberOfOptimizationSweeps+1;                            % Increase the counter for the number of sweeps we have in the block
                            obj.OptimizationSweep{NumberOfOptimizationSweeps}=SonnetFrequencyStep(theFid);      % construct the new sweep and store in the cell array
                            
                        case 'ESWEEP'                                                                           % check if it is a esweep sweep
                            NumberOfOptimizationSweeps=NumberOfOptimizationSweeps+1;                            % Increase the counter for the number of sweeps we have in the block
                            obj.OptimizationSweep{NumberOfOptimizationSweeps}=SonnetFrequencyEsweep(theFid);    % construct the new sweep and store in the cell array
                            
                        case 'LSWEEP'                                                                           % check if it is a lsweep sweep
                            NumberOfOptimizationSweeps=NumberOfOptimizationSweeps+1;                            % Increase the counter for the number of sweeps we have in the block
                            obj.OptimizationSweep{NumberOfOptimizationSweeps}=SonnetFrequencyLsweep(theFid);    % construct the new sweep and store in the cell array
                            
                        case 'DC_FREQ'                                                                          % check if it is a DC_FREQ sweep
                            NumberOfOptimizationSweeps=NumberOfOptimizationSweeps+1;                            % Increase the counter for the number of sweeps we have in the block
                            obj.OptimizationSweep{NumberOfOptimizationSweeps}=SonnetFrequencyDcFreq(theFid);    % construct the new sweep and store in the cell array
                            
                        case 'NET=GEO'                                                                          % If it is the optimization line
                            obj.ResponseType{NumberOfOptimizationSweeps}=fscanf(theFid,' %s',1);
                            obj.RelationString{NumberOfOptimizationSweeps}=fscanf(theFid,' %s',1);
                            aTempString=fscanf(theFid,' %s',1);
                            
                            if ~isempty(strfind(aTempString,'VALUE'))
                                obj.TargetType{NumberOfOptimizationSweeps}='VALUE';
                                obj.TargetValue{NumberOfOptimizationSweeps}=strrep(aTempString,'VALUE=','');
                                obj.TargetValue{NumberOfOptimizationSweeps}=str2double(obj.TargetValue{NumberOfOptimizationSweeps});
                                obj.TargetResponseType{NumberOfOptimizationSweeps}=[];
                            elseif ~isempty(strfind(aTempString,'FILE'))
                                obj.TargetType{NumberOfOptimizationSweeps}='FILE';
                                obj.TargetValue{NumberOfOptimizationSweeps}=fscanf(theFid,'%s',1);
                                obj.TargetResponseType{NumberOfOptimizationSweeps}=fscanf(theFid,'%s',1);
                            elseif ~isempty(strfind(aTempString,'NET'))
                                obj.TargetType{NumberOfOptimizationSweeps}='NET';
                                obj.TargetValue{NumberOfOptimizationSweeps}=strrep(aTempString,'NET=','');
                                obj.TargetResponseType{NumberOfOptimizationSweeps}=fscanf(theFid,'%s',1);
                            else
                                obj.TargetType{NumberOfOptimizationSweeps}=[aTempString fgets(theFid)];
                            end
                            
                            obj.Weight{NumberOfOptimizationSweeps}=fscanf(theFid,' %g',1);
                            
                        case 'END'   % Check if it is END indicating we are done reading OPT
                            % Some projects have an END for vars and then a END OPT line
                            % We need to be sure we are done with the OPT block when we
                            % finish this constructor
                            aTempString=fgetl(theFid);
                            if ~isempty(aTempString)
                                break;
                            end

                        case 'VAR'
                            aTempString=fscanf(theFid,' %s',1);
                            NumberOfParamters=NumberOfParamters+1;                                            % Increment the parameter counter by one
                            obj.VarsArray{NumberOfParamters}=SonnetOptimizationVariable(theFid,aTempString);  % construct the new parameter and store in the cell array, give the parameter the string so it knows its name
                            
                        otherwise                                                                             % Otherwise it is a parameter and we should make a parameter object
                            NumberOfParamters=NumberOfParamters+1;                                            % Increment the parameter counter by one
                            obj.VarsArray{NumberOfParamters}=SonnetOptimizationVariable(theFid,aTempString);  % construct the new parameter and store in the cell array, give the parameter the string so it knows its name
                            
                    end
                    
                    aTempString=fscanf(theFid,' %s',1);   % read the next sweep name from the file, if it is END then we are done
                    
                end
                
            else
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % we come here when we didn't recieve a file ID as an argument
                % which means that we are going to create a default OPT block with
                % default values by calling the function's initialize method.
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                initialize(obj);
                
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function initialize(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function initializes the OPT properties to some default
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
            
            obj.MaxIterations=100;

        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aNewObject=clone(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function builds a deep copy of this object
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            aNewObject=SonnetOptimizationBlock();
            SonnetClone(obj,aNewObject);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function writeObjectContents(obj, theFid, theVersion)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function writes the values from the object to a file.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            fprintf(theFid,'OPT\n');
            
            fprintf(theFid,'MAX %d',obj.MaxIterations);
            
            fprintf(theFid,'\nVARS\n');
            
            % Call the writeObjectContents function in each of the objects that we have in our cell array.
            for iCounter= 1:length(obj.VarsArray)
                obj.VarsArray{iCounter}.writeObjectContents(theFid,theVersion);
            end
            
            % Only print this statement if the project version is greater than 12
            if theVersion >= 13 
                fprintf(theFid,'END\n');
            end
                
            % We want to loop and print out the values for all the sweeps and optimizations
            for iCounter= 1:length(obj.OptimizationSweep)
                
                % Call the writeguts method for the frequency type
                obj.OptimizationSweep{iCounter}.writeObjectContents(theFid,theVersion);
                
                % Write out the optimization parameters
                if strcmpi(obj.TargetType{iCounter},'VALUE')==1
                    fprintf(theFid,'NET=GEO %s %s %s=',obj.ResponseType{iCounter},obj.RelationString{iCounter},obj.TargetType{iCounter});
                    
                    if ischar(obj.TargetValue{iCounter})==1
                        fprintf(theFid,'%s',obj.TargetValue{iCounter});
                    else
                        fprintf(theFid,'%.15g',obj.TargetValue{iCounter});
                    end
                    
                    if ischar(obj.Weight{iCounter})==1
                        fprintf(theFid,' %s\n',obj.Weight{iCounter});
                    else
                        fprintf(theFid,' %.15g\n',obj.Weight{iCounter});
                    end
                    
                elseif strcmpi(obj.TargetType{iCounter},'FILE')==1
                    
                    fprintf(theFid,'NET=GEO %s %s %s=',obj.ResponseType{iCounter},obj.RelationString{iCounter},obj.TargetType{iCounter});
                    
                    if ischar(obj.TargetValue{iCounter})==1
                        fprintf(theFid,' %s',obj.TargetValue{iCounter});
                    else
                        fprintf(theFid,' %.15g',obj.TargetValue{iCounter});
                    end
                    
                    if ischar(obj.TargetResponseType{iCounter})==1
                        fprintf(theFid,' %s',obj.TargetResponseType{iCounter});
                    else
                        fprintf(theFid,' %.15g',obj.TargetResponseType{iCounter});
                    end                    
                    
                    if ischar(obj.Weight{iCounter})==1
                        fprintf(theFid,' %s\n',obj.Weight{iCounter});
                    else
                        fprintf(theFid,' %.15g\n',obj.Weight{iCounter});
                    end
                    
                elseif strcmpi(obj.TargetType{iCounter},'NET')==1
                    
                    fprintf(theFid,'NET=GEO %s %s %s=',obj.ResponseType{iCounter},obj.RelationString{iCounter},obj.TargetType{iCounter});
                    
                    if ischar(obj.TargetValue{iCounter})==1
                        fprintf(theFid,'%s',obj.TargetValue{iCounter});
                    else
                        fprintf(theFid,'%.15g',obj.TargetValue{iCounter});
                    end
                    
                    if ischar(obj.TargetResponseType{iCounter})==1
                        fprintf(theFid,' %s',obj.TargetResponseType{iCounter});
                    else
                        fprintf(theFid,' %.15g',obj.TargetResponseType{iCounter});
                    end
                    
                    if ischar(obj.Weight{iCounter})==1
                        fprintf(theFid,' %s\n',obj.Weight{iCounter});
                    else
                        fprintf(theFid,' %.15g\n',obj.Weight{iCounter});
                    end
                    
                else
                    fprintf(theFid,'NET=GEO %s %s %s',obj.ResponseType{iCounter},obj.RelationString{iCounter},obj.TargetType{iCounter});
                    
                end
                
            end
            
            fprintf(theFid,'END OPT\n');
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aSignature=stringSignature(obj,theVersion)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function writes the values from the object to a string.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            aSignature = sprintf('OPT\n');
            
            aSignature = [aSignature sprintf('MAX %d',obj.MaxIterations)];
            
            aSignature = [aSignature sprintf('\nVARS\n')];
            
            % Call the writeGuts function in each of the objects that we have in our cell array.
            for iCounter= 1:length(obj.VarsArray)
                aSignature = [aSignature obj.VarsArray{iCounter}.stringSignature(theVersion)]; %#ok<AGROW>
            end
            
            % Only print this statement if the project version is greater than 12
            if theVersion >= 13 
                aSignature = [aSignature sprintf('END\n')];
            end
            
            % We want to loop and print out the values for all the sweeps and optimizations
            for iCounter= 1:length(obj.OptimizationSweep)
                
                % Call the writeguts method for the frequency type
                aSignature = [aSignature obj.OptimizationSweep{iCounter}.stringSignature(theVersion)]; %#ok<AGROW>
                
                % Write out the optimization parameters
                if strcmpi(obj.TargetType{iCounter},'VALUE')==1
                    aSignature = [aSignature sprintf('NET=GEO %s %s %s=',obj.ResponseType{iCounter},obj.RelationString{iCounter},obj.TargetType{iCounter})]; %#ok<AGROW>
                    
                    if ischar(obj.TargetValue{iCounter})==1
                        aSignature = [aSignature sprintf('%s',obj.TargetValue{iCounter})]; %#ok<AGROW>
                    else
                        aSignature = [aSignature sprintf('%.15g',obj.TargetValue{iCounter})]; %#ok<AGROW>
                    end
                    
                    if ischar(obj.Weight{iCounter})==1
                        aSignature = [aSignature sprintf(' %s\n',obj.Weight{iCounter})]; %#ok<AGROW>
                    else
                        aSignature = [aSignature sprintf(' %.15g\n',obj.Weight{iCounter})]; %#ok<AGROW>
                    end
                    
                elseif strcmpi(obj.TargetType{iCounter},'FILE')==1
                    aSignature = [aSignature sprintf('NET=GEO %s %s %s=',obj.ResponseType{iCounter},...
                        obj.RelationString{iCounter},obj.TargetType{iCounter})]; %#ok<AGROW>
                    
                    if ischar(obj.TargetValue{iCounter})==1
                        aSignature = [aSignature sprintf(' %s',obj.TargetValue{iCounter})]; %#ok<AGROW>
                    else
                        aSignature = [aSignature sprintf(' %.15g',obj.TargetValue{iCounter})]; %#ok<AGROW>
                    end
                    
                    if ischar(obj.TargetResponseType{iCounter})==1
                        aSignature = [aSignature sprintf(' %s',obj.TargetResponseType{iCounter})]; %#ok<AGROW>
                    else
                        aSignature = [aSignature sprintf(' %.15g',obj.TargetResponseType{iCounter})]; %#ok<AGROW>
                    end                    
                    
                    if ischar(obj.Weight{iCounter})==1
                        aSignature = [aSignature sprintf(' %s\n',obj.Weight{iCounter})]; %#ok<AGROW>
                    else
                        aSignature = [aSignature sprintf(' %.15g\n',obj.Weight{iCounter})]; %#ok<AGROW>
                    end
                    
                elseif strcmpi(obj.TargetType{iCounter},'NET')==1
                    
                    aSignature = [aSignature sprintf('NET=GEO %s %s %s=',obj.ResponseType{iCounter},...
                        obj.RelationString{iCounter},obj.TargetType{iCounter})]; %#ok<AGROW>
                    
                    if ischar(obj.TargetValue{iCounter})==1
                        aSignature = [aSignature sprintf('%s',obj.TargetValue{iCounter})]; %#ok<AGROW>
                    else
                        aSignature = [aSignature sprintf('%.15g',obj.TargetValue{iCounter})]; %#ok<AGROW>
                    end
                    
                    if ischar(obj.TargetResponseType{iCounter})==1
                        aSignature = [aSignature sprintf(' %s',obj.TargetResponseType{iCounter})]; %#ok<AGROW>
                    else
                        aSignature = [aSignature sprintf(' %.15g',obj.TargetResponseType{iCounter})]; %#ok<AGROW>
                    end
                    
                    if ischar(obj.Weight{iCounter})==1
                        aSignature = [aSignature sprintf(' %s\n',obj.Weight{iCounter})]; %#ok<AGROW>
                    else
                        aSignature = [aSignature sprintf(' %.15g\n',obj.Weight{iCounter})]; %#ok<AGROW>
                    end
                    
                else
                    aSignature = [aSignature sprintf('NET=GEO %s %s %s',obj.ResponseType{iCounter},...
                        obj.RelationString{iCounter},obj.TargetType{iCounter})]; %#ok<AGROW>
                end
                
            end
            
            aSignature = [aSignature sprintf('END OPT\n')]; 
        end
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function editOptimizationVariable(obj,theVariableName,theMinimumValue,...
                theMaximumValue,theStepValue,isEnabled)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Add an optimization variable to the optimization
            % block. Optimization variables are the values
            % that are modified when doing an optimization
            % sweep.
            %
            % This function requires the following inputs:
            % 1) The name of the variable to be modified
            % 2) The minimum value for the variable
            % 3) The maximum value for the variable
            % 4) The step value at which we are sweeping
            %       from the minimum value to the maxiumum value.
            % 5) Either 'Y' to specify the variable
            %       is being used or 'n' to specify that the
            %       variable isn't being used.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            for iCounter=1:length(obj.VarsArray)
                if strcmpi(theVariableName,obj.VarsArray{iCounter}.VariableName)==1
                    obj.VarsArray{iCounter}.MinValue=theMinimumValue;
                    obj.VarsArray{iCounter}.MaxValue=theMaximumValue;
                    obj.VarsArray{iCounter}.StepValue=theStepValue;
                    obj.VarsArray{iCounter}.VariableBeingUsed=isEnabled;
                    return
                end
            end
            
            % If the variable is not found then make a new one
            obj.VarsArray{end+1}=SonnetOptimizationVariable();
            obj.VarsArray{end}.VariableName=theVariableName;
            obj.VarsArray{end}.MinValue=theMinimumValue;
            obj.VarsArray{end}.MaxValue=theMaximumValue;
            obj.VarsArray{end}.StepValue=theStepValue;
            obj.VarsArray{end}.VariableBeingUsed=isEnabled;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addOptimizationParameter(obj,theSweep,theResponseType,...
                theRelationString,theTargetType,theTargetValue,theTargetResponseType,theWeight)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Add an optimization parameter to the optimization
            % block. Optimization parameters define how
            % the optimization variables get modified.
            %
            % This function requires the following inputs:
            % 1) A frequency sweep object
            %       (EX: an object of class SonnetAbsFrequencySweep)
            % 2) The response Type (Ex: DB[S11])
            % 3) The relation String ('>', '<', '=')
            % 4) The type for the target response ('VALUE','NET','FILE').
            %       This is what the response will be compared to.
            % 5) The target value. For tagets of type 'VALUE' this
            %       will store the response value we would like
            %       to obtain from optimization. For 'NET'
            %       this argument stores the name of the network
            %       to compare to. For type 'FILE' this stores
            %       the name of the file that should be used.
            % 6) If the target type is 'FILE' or 'NET' then
            %       the response type for the target value is 
            %       required. If the type is 'VALUE' then this
            %       should be the empty string ('');
            % 7) The weight for this optimization parameter. This
            %       value is often 1.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            obj.OptimizationSweep{length(obj.OptimizationSweep)+1}  =   theSweep;
            obj.ResponseType{length(obj.ResponseType)+1}            =   theResponseType;
            obj.RelationString{length(obj.RelationString)+1}        =   theRelationString;
            obj.TargetType{length(obj.TargetType)+1}                =   theTargetType;
            obj.TargetValue{length(obj.TargetValue)+1}              =   theTargetValue;
            obj.Weight{length(obj.Weight)+1}                        =   theWeight;
            obj.TargetResponseType{length(obj.TargetResponseType)+1}=   theTargetResponseType;
            
        end
        
    end
end
