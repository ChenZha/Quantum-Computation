classdef SonnetControlBlock < handle
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This class stores the CONTROL portion of a SONNET project file.
    % The data stored in this object pertains to options selected by the
    % user for this project including which frequency sweep will be
    % used when analyzing the project.
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
        sweepType                           % Stores the type of sweep that is selected
        AbsResolution                       % Stores the ABS resolution value
        AbsResolutionInUse                  % Stores whether ABS resolution is being used
        Options                             % Stores the Options codes for the project
        SubsectionsPerLambda = 20;          % Stores the number of subsections per lambda, default is 20
        SubsectionsPerLambdaInUse           % Stores whether subsections per lambda is in use
        EdgeCheckInUse                      % Stores whether edge check is in use
        EdgeCheck = 1;                      % Stores the vaue for edge check, default is 1
        MaximumSubsectioningFrequencyInUse  % Stores whether Maximum Subsectioning Frequency is being used
        MaximumSubsectioningFrequency       % Stores the Maximum Subsectioning Frequency
        EstimatedEpsilonEffective           % Stores the Estimated Epsilon Effective value of the projects
        EstimatedEpsilonEffectiveInUse      % Stores whether Estimated Epsilon Effective is being used
        Filename                            % Stores the name of the external frequency file used to control the analysis
        Speed                               % Analysis Speed/Memory Control - Valid only for geometry projects.
        CacheAbs                            % ABS Caching Level
        TargetAbs                           % Target for Automatic Frequency Resolution for ABS Sweep
        QFactorAccuracy                     % stores the Q-Factor Accuracy
        Push                                % Only for netlists. If true we will print out push, if false we will not. Default is false.
        UnknownLines                        % Keeps values that we dont understand. These values are written back to files.
        isForceRun
        
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = SonnetControlBlock(theFid)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % The constructor for CONTROL.
            %     the CONTROL object will be passed the file
            %     ID from the SONNET project constructor.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if nargin == 1                   % If we were passed 1 argument which means we got the theFid
                
                initialize(obj);
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Attempt to get the sweep type, this should always
                %	be the first thing present in the control block.
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Read in the selected sweep type from the file and make sure it is one of the supported types
                obj.sweepType=fscanf(theFid,' %s',1);
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % We are going to loop and read initial tags
                %		for all the lines in the CONTROL block
                %		and	move to the appropriate case
                %		depending on the input.  This is
                %		necessary to allow for statements
                %		to be in different orders.
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                isKeepLooping=true;												% This boolean controls if we should stay in the reading loop.
                % We loop when true and quit when false.
                while(isKeepLooping)
                    
                    % Read a string from the file,  we will use this to determine what property needs to be modified by using a case statement.
                    aTempString=fscanf(theFid,' %s',1); 							% Read a Value from the file, we will be using this to drive the switch statment
                    
                    switch aTempString
                        
                        case 'OPTIONS'
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            % If the input was OPTIONS then we will read the value and
                            %   check the validity by comparing it to the allowed values
                            %   Acceptible option switches are 'j','A','m','d' or 'b'
                            %   the Options are stored in a vector.
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            obj.Options=fgetl(theFid);
                            obj.Options=strrep(obj.Options,'-','');
                            obj.Options=strtrim(obj.Options);
                            
                        case 'SUBSPLAM'
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            % If the input was SUBSPLAM then we will read the value and
                            %   check the validity by comparing it to the allowed values
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            obj.SubsectionsPerLambdaInUse=fscanf(theFid,' %c',1);
                            obj.SubsectionsPerLambda=fscanf(theFid,' %f',1);
                            
                        case 'EDGECHECK'
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            % If the input was EDGECHECK then we will read the value and
                            %   check the validity by comparing it to the allowed values
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            obj.EdgeCheckInUse=fscanf(theFid,' %c',1);
                            obj.EdgeCheck=fscanf(theFid,' %f',1);
                            
                        case 'CFMAX'
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            % If the input was CFMAX then we will read the value and
                            %   check the validity by comparing it to the allowed values
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %	This can have the values of 'N','B','L' or 'Y'. If 'Y'
                            % then we	need to read in the frequency.
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            aTempString=fscanf(theFid,' %c',1);                           % read whether is is a Y or a N for yes/no.
                            if aTempString=='N' || aTempString=='L' || aTempString=='B';  % if the read string is one of these values then assign it to the MaximumSubsectioningFrequencyInUse
                                obj.MaximumSubsectioningFrequencyInUse=aTempString;       % indicate the usage of cfmax to be what we read in
                                
                                aBackupOfTheFid=ftell(theFid);          	        % Store a backup of the file ID so that we can restore it afer we read the line
                                aTempString=fscanf(theFid,'%s',1);
                                fseek(theFid,aBackupOfTheFid,'bof');	            % Restore the backup of the fid
                                
                                if ~isempty(aTempString)
                                    obj.MaximumSubsectioningFrequency=fscanf(theFid,' %f',1);
                                end
                                
                            elseif aTempString=='Y';
                                obj.MaximumSubsectioningFrequencyInUse='Y';
                                obj.MaximumSubsectioningFrequency=fscanf(theFid,' %f',1);
                                
                            end
                            
                            
                        case 'CEPSY'
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            % If the input was CEPSY then we will read the value and
                            %   check the validity by comparing it to the allowed values
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            obj.EstimatedEpsilonEffectiveInUse=fscanf(theFid,' %c',1);
                            obj.EstimatedEpsilonEffective=fscanf(theFid,' %f',1);
                            
                        case 'FILENAME'
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            % If the input was FILENAME then we will read the value and
                            %   check the validity by comparing it to the allowed values
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            obj.Filename=fgetl(theFid);
                            obj.Filename=strtrim(obj.Filename);
                            
                            
                        case 'SPEED'
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            % If the input was SPEED then we will read the value and
                            %   check the validity by comparing it to the allowed values
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            obj.Speed=fscanf(theFid,' %d',1);
                            
                        case 'PUSH'
                            obj.Push=true;
                            
                        case 'RES_ABS'
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            % If the input was RES_ABS then we will read the value and
                            %   check the validity by comparing it to the allowed values
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            currentTag=fscanf(theFid,' %c',1);
                            if currentTag=='N' || currentTag=='n';
                                obj.AbsResolutionInUse='N';
                                
                                % Check if there is a value after the N
                                aBackupOfTheFid=ftell(theFid);
                                aTempString=fscanf(theFid,'%f',1);
                                fseek(theFid,aBackupOfTheFid,'bof');
                                
                                if ~isempty(aTempString)
                                    obj.AbsResolution=fscanf(theFid,'%f',1);
                                end
                                
                            elseif currentTag=='Y' || currentTag=='y';
                                obj.AbsResolutionInUse='Y';
                                obj.AbsResolution=fscanf(theFid,' %f',1);
                            end
                            
                        case 'CACHE_ABS'
                            
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            % If the input was CACHE_ABS then we will read the value and
                            %   check the validity by comparing it to the allowed values
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            obj.CacheAbs=fscanf(theFid,' %d',1);
                            
                        case 'TARG_ABS'
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            % If the input was TARG_ABS then we will read the value and
                            %   check the validity by comparing it to the allowed values
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            obj.TargetAbs=fscanf(theFid,' %d',1);
                            
                        case 'Q_ACC'
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            % If the input was Q_ACC then we will read the value and
                            %   check the validity by comparing it to the allowed values
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            obj.QFactorAccuracy=fscanf(theFid,' %c',1);
                            
                        case 'FORCERUN'
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            % If the input was FORCERUN then we will read the value and
                            %   check the validity by comparing it to the allowed values
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            obj.isForceRun=true;
                            
                        case '\n'
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            % If the input was \n then do nothing; just go back to the
                            %   top of the loop.
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            continue;
                            
                            
                        case 'END'
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            % If the input was END then we are done reading this block
                            %   and have to get ready to read the next block.
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            fgetl(theFid);		% get the rest of the line.  Now the file id should be after the DIM block and ready for the next block
                            isKeepLooping=false;	% Indicate that we should stop looping.
                            
                            
                        otherwise
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            % If the input was something we didnt expect then just store
                            %   it in a junk object. we wont use it but will write
                            %   it out again.
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            obj.UnknownLines=[obj.UnknownLines aTempString fgetl(theFid) '\n'];
                            
                    end
                end
                
            else
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % we come here when we didn't recieve a file ID as an argument
                % which means that we are going to create a default control block with
                % default values by calling the function's initialize method.
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                initialize(obj);
                
            end
            
        end
                
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function initialize(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function initializes the control properties to some default
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
            
            obj.sweepType='ABS';
            obj.Options='d';
            obj.Speed=0;
            obj.CacheAbs=1;
            obj.TargetAbs=300;
            obj.QFactorAccuracy='N';
            obj.Push=false;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aNewObject=clone(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function builds a deep copy of this object
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            aNewObject=SonnetControlBlock();
            SonnetClone(obj,aNewObject);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function writeObjectContents(obj, theFid, theVersion) %#ok<INUSD>
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function writes the values from the object to a file.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            fprintf(theFid,'CONTROL\n');
            
            % If the value is defined print it out to the file
            if (~isempty(obj.sweepType))
                fprintf(theFid, '%s\n',obj.sweepType);
            end
            
            if (~isempty(obj.Options))
                fprintf(theFid, 'OPTIONS -%s\n',obj.Options);
            else 
                fprintf(theFid, 'OPTIONS\n');
            end
            
            if ~isempty(obj.isForceRun) && obj.isForceRun==true
                fprintf(theFid, 'FORCERUN\n');
            end
            
            if obj.Push==true
                fprintf(theFid, 'PUSH\n');
            end
            
            if (~isempty(obj.SubsectionsPerLambdaInUse))
                fprintf(theFid, 'SUBSPLAM %s %d\n',obj.SubsectionsPerLambdaInUse,obj.SubsectionsPerLambda);
            end
                        
            if (~isempty(obj.MaximumSubsectioningFrequencyInUse))
                fprintf(theFid, 'CFMAX %s %d\n',obj.MaximumSubsectioningFrequencyInUse,obj.MaximumSubsectioningFrequency);
            end
            
            if (~isempty(obj.EstimatedEpsilonEffectiveInUse))
                fprintf(theFid, 'CEPSY %s %d\n',obj.EstimatedEpsilonEffectiveInUse,obj.EstimatedEpsilonEffective);
            end
            
            if (~isempty(obj.Filename))
                fprintf(theFid, 'FILENAME %s\n',obj.Filename);
            end
            
            if (~isempty(obj.Speed))
                fprintf(theFid, 'SPEED %d\n',obj.Speed);
            end
            
            if (~isempty(obj.EdgeCheckInUse))
                fprintf(theFid, 'EDGECHECK %s %d\n',obj.EdgeCheckInUse,obj.EdgeCheck);
            end
            
            if (~isempty(obj.AbsResolutionInUse))
                fprintf(theFid, 'RES_ABS %s %d\n',obj.AbsResolutionInUse,obj.AbsResolution);
            end
            
            if (~isempty(obj.CacheAbs))
                fprintf(theFid, 'CACHE_ABS %d\n',obj.CacheAbs);
            end
            
            if (~isempty(obj.TargetAbs))
                fprintf(theFid, 'TARG_ABS %d\n',obj.TargetAbs);
            end
            
            if (~isempty(obj.QFactorAccuracy))
                fprintf(theFid, 'Q_ACC %s\n',obj.QFactorAccuracy);
            end
            
            if (~isempty(obj.UnknownLines))
                fprintf(theFid, sprintf('%s',obj.UnknownLines));
            end
            
            fprintf(theFid,'END CONTROL\n');
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aSignature=stringSignature(obj,theVersion) %#ok<INUSD>
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function writes the values from the object to a string.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            aSignature = sprintf('CONTROL\n');
            
            % If the value is defined print it out to the file
            if (~isempty(obj.sweepType))
                aSignature = [aSignature sprintf('%s\n',obj.sweepType)];
            end
            
            if (~isempty(obj.Options))
                aSignature = [aSignature sprintf('OPTIONS -%s\n',obj.Options)];
            else 
                aSignature = [aSignature 'OPTIONS\n'];
            end
            
            if ~isempty(obj.isForceRun) && obj.isForceRun==true
                aSignature = [aSignature sprintf('FORCERUN\n')];
            end
            
            if obj.Push==true
                aSignature = [aSignature sprintf('PUSH\n')];
            end
            
            if (~isempty(obj.SubsectionsPerLambdaInUse))
                aSignature = [aSignature sprintf('SUBSPLAM %s %d\n',obj.SubsectionsPerLambdaInUse,obj.SubsectionsPerLambda)];
            end
            
            if (~isempty(obj.EdgeCheckInUse))
                aSignature = [aSignature sprintf('EDGECHECK %s %d\n',obj.EdgeCheckInUse,obj.EdgeCheck)];
            end
            
            if (~isempty(obj.MaximumSubsectioningFrequencyInUse))
                aSignature = [aSignature sprintf('CFMAX %s %d\n',obj.MaximumSubsectioningFrequencyInUse,obj.MaximumSubsectioningFrequency)];
            end
            
            if (~isempty(obj.EstimatedEpsilonEffectiveInUse))
                aSignature = [aSignature sprintf('CEPSY %s %d\n',obj.EstimatedEpsilonEffectiveInUse,obj.EstimatedEpsilonEffective)];
            end
            
            if (~isempty(obj.Filename))
                aSignature = [aSignature sprintf('FILENAME %s\n',obj.Filename)];
            end
            
            if (~isempty(obj.Speed))
                aSignature = [aSignature sprintf('SPEED %d\n',obj.Speed)];
            end
            
            if (~isempty(obj.AbsResolutionInUse))
                aSignature = [aSignature sprintf('RES_ABS %s %.15g\n',obj.AbsResolutionInUse,obj.AbsResolution)];
            end
            
            if (~isempty(obj.CacheAbs))
                aSignature = [aSignature sprintf('CACHE_ABS %d\n',obj.CacheAbs)];
            end
            
            if (~isempty(obj.TargetAbs))
                aSignature = [aSignature sprintf('TARG_ABS %d\n',obj.TargetAbs)];
            end
            
            if (~isempty(obj.QFactorAccuracy))
                aSignature = [aSignature sprintf('Q_ACC %s\n',obj.QFactorAccuracy)];
            end
            
            if (~isempty(obj.UnknownLines))
                aSignature = [aSignature strrep(obj.UnknownLines,'\n',sprintf('\n'))];
            end
            
            aSignature = [aSignature sprintf('END CONTROL\n')];
            
        end
    end
end

