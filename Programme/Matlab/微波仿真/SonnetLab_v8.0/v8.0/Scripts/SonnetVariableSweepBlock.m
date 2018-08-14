classdef SonnetVariableSweepBlock  < handle
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This class defines the VARSWP portion of a SONNET project file.
    % This class is a container for the VARSWP information that is obtained
    % from the SONNET project file.
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
        
        ArrayOfSweeps;				% This property stores the sweeps that we had in the file.
        
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = SonnetVariableSweepBlock(theFid)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % The constructor for VARSWP.
            %     the VARSWP will be passed the file ID from the
            %     SONNET project constructor.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            NumberOfSweepsInFile=0;   % Keeps track of the number of sweeps we have in the file
            
            initialize(obj);          % Initialize the values of the properties using the initializer function
            
            if nargin == 1
                
                aTempString=fscanf(theFid,'%s',1);     % Try to read the the first type of the sweep from the file.
                
                while (1==1)                           % Keep looping till we get to the end of the block. This is when we have read in all the sweeps and read in 'END'
                    
                    switch aTempString
                        
                        case 'SIMPLE'                                                                                   % check if it is a simple sweep
                            NumberOfSweepsInFile=NumberOfSweepsInFile+1;                                                  % increment the sweep counter by one
                            aTempSweep=SonnetFrequencySimple(theFid);                                                          % construct an sweep and pass it to the constructor for the VARSWPSWEEP
                            obj.ArrayOfSweeps{NumberOfSweepsInFile}=SonnetVariableSweepEntry(theFid,aTempString,aTempSweep);    	% construct the new sweep and store in the cell array, give the sweep the string so it knows what type of sweep it is
                            
                        case 'ABS'                                                                                      % check if it is a abs sweep
                            NumberOfSweepsInFile=NumberOfSweepsInFile+1;                                                  % increment the sweep counter by one
                            aTempSweep=SonnetFrequencyAbs(theFid);                                                             % construct an sweep and pass it to the constructor for the VARSWPSWEEP
                            obj.ArrayOfSweeps{NumberOfSweepsInFile}=SonnetVariableSweepEntry(theFid,aTempString,aTempSweep);    	% construct the new sweep and store in the cell array, give the sweep the string so it knows what type of sweep it is
                            
                        case 'SWEEP'                                                                                    % check if it is a sweep sweep
                            NumberOfSweepsInFile=NumberOfSweepsInFile+1;                                                  % increment the sweep counter by one
                            aTempSweep=SonnetFrequencySweep(theFid);                                                           % construct an sweep and pass it to the constructor for the VARSWPSWEEP
                            obj.ArrayOfSweeps{NumberOfSweepsInFile}=SonnetVariableSweepEntry(theFid,aTempString,aTempSweep);    	% construct the new sweep and store in the cell array, give the sweep the string so it knows what type of sweep it is
                            
                        case 'ABS_ENTRY'                                                                                % check if it is a abs entry sweep
                            NumberOfSweepsInFile=NumberOfSweepsInFile+1;                                                  % increment the sweep counter by one
                            aTempSweep=SonnetFrequencyAbsEntry(theFid);                                                        % construct an sweep and pass it to the constructor for the VARSWPSWEEP
                            obj.ArrayOfSweeps{NumberOfSweepsInFile}=SonnetVariableSweepEntry(theFid,aTempString,aTempSweep);    	% construct the new sweep and store in the cell array, give the sweep the string so it knows what type of sweep it is
                            
                        case 'STEP'                                                                                     % check if it is a step sweep
                            NumberOfSweepsInFile=NumberOfSweepsInFile+1;                                                  % increment the sweep counter by one
                            aTempSweep=SonnetFrequencyStep(theFid);                                                            % construct an sweep and pass it to the constructor for the VARSWPSWEEP
                            obj.ArrayOfSweeps{NumberOfSweepsInFile}=SonnetVariableSweepEntry(theFid,aTempString,aTempSweep);    	% construct the new sweep and store in the cell array, give the sweep the string so it knows what type of sweep it is
                            
                        case 'ESWEEP'                                                                                   % check if it is a esweep sweep
                            NumberOfSweepsInFile=NumberOfSweepsInFile+1;                                                  % increment the sweep counter by one
                            aTempSweep=SonnetFrequencyEsweep(theFid);                                                          % construct an sweep and pass it to the constructor for the VARSWPSWEEP
                            obj.ArrayOfSweeps{NumberOfSweepsInFile}=SonnetVariableSweepEntry(theFid,aTempString,aTempSweep);    	% construct the new sweep and store in the cell array, give the sweep the string so it knows what type of sweep it is
                            
                        case 'LSWEEP'                                                                                   % check if it is a lsweep sweep
                            NumberOfSweepsInFile=NumberOfSweepsInFile+1;                                                  % increment the sweep counter by one
                            aTempSweep=SonnetFrequencyLsweep(theFid);                                                          % construct an sweep and pass it to the constructor for the VARSWPSWEEP
                            obj.ArrayOfSweeps{NumberOfSweepsInFile}=SonnetVariableSweepEntry(theFid,aTempString,aTempSweep);    	% construct the new sweep and store in the cell array, give the sweep the string so it knows what type of sweep it is
                            
                        case 'ABS_FMIN'                                                                                 % check if it is a abs_fmin sweep
                            NumberOfSweepsInFile=NumberOfSweepsInFile+1;                                                  % increment the sweep counter by one
                            aTempSweep=SonnetFrequencyAbsFmin(theFid);                                                         % construct an sweep and pass it to the constructor for the VARSWPSWEEP
                            obj.ArrayOfSweeps{NumberOfSweepsInFile}=SonnetVariableSweepEntry(theFid,aTempString,aTempSweep);    	% construct the new sweep and store in the cell array, give the sweep the string so it knows what type of sweep it is
                            
                        case 'ABS_FMAX'                                                                                 % check if it is a abs_fmax sweep
                            NumberOfSweepsInFile=NumberOfSweepsInFile+1;                                                  % increment the sweep counter by one
                            aTempSweep=SonnetFrequencyAbsFmax(theFid);                                                         % construct an sweep and pass it to the constructor for the VARSWPSWEEP
                            obj.ArrayOfSweeps{NumberOfSweepsInFile}=SonnetVariableSweepEntry(theFid,aTempString,aTempSweep);    	% construct the new sweep and store in the cell array, give the sweep the string so it knows what type of sweep it is
                            
                        case 'DC_FREQ'
                            NumberOfSweepsInFile=NumberOfSweepsInFile+1;                                                  % increment the sweep counter by one
                            aTempSweep=SonnetFrequencyDcFreq(theFid);                                                         % construct an sweep and pass it to the constructor for the VARSWPSWEEP
                            obj.ArrayOfSweeps{NumberOfSweepsInFile}=SonnetVariableSweepEntry(theFid,aTempString,aTempSweep);    	% construct the new sweep and store in the cell array, give the sweep the string so it knows what type of sweep it is
                            
                        case 'END'   			% check if we reached the end of the block
                            fgetl(theFid);		% read the rest of the line we are on to get the theFid ready for the next block.
                            break;
                    end
                    
                    aTempString=fscanf(theFid,'%s',1);    % read the next sweep name from the file, if it is END then we are done
                    
                end
                
            else
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % we come here when we didn't recieve a file ID as an argument
                % which means that we are going to create a default VARSWP block with
                % default values by calling the function's initialize method.
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                initialize(obj);
                
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function initialize(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function initializes the VARSWP properties to some default
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
            aNewObject=SonnetVariableSweepBlock();
            SonnetClone(obj,aNewObject);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function writeObjectContents(obj, theFid, theVersion)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function writes the values from the object to a file.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            fprintf(theFid,'VARSWP\n');
            
            % Call the writeGuts function in each of the objects that we have in our cell array.
            for iCounter= 1:size(obj.ArrayOfSweeps,2)
                obj.ArrayOfSweeps{iCounter}.writeObjectContents(theFid,theVersion);
            end
            
            fprintf(theFid,'END VARSWP\n');
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aSignature=stringSignature(obj,theVersion)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function writes the values from the object to a string.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            aSignature = sprintf('VARSWP\n');
            
            % Call the writeGuts function in each of the objects that we have in our cell array.
            for iCounter= 1:length(obj.ArrayOfSweeps)
                aSignature = [aSignature obj.ArrayOfSweeps{iCounter}.stringSignature(theVersion)]; %#ok<AGROW>
            end
            
            aSignature = [aSignature sprintf('END VARSWP\n')];
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function activateVariableSweepParameter(obj,theVariableName,theSweepIndex)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %   This function will set the parameter in
            %   use value for the specified parameter in the
            %   variable sweep.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if nargin == 2
                theSweepIndex=1;
            end
            
            obj.ArrayOfSweeps{theSweepIndex}.activateVariableSweepParameter(theVariableName);
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function deactivateVariableSweepParameter(obj,theVariableName,theSweepIndex)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %   This function will set the parameter in
            %   use value for the specified parameter in the
            %   variable sweep.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if nargin == 2
                theSweepIndex=1;
            end
            
            obj.ArrayOfSweeps{theSweepIndex}.deactivateVariableSweepParameter(theVariableName);
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function changeVariableSweepParameterState(obj,theVariableName,theStatus,theSweepIndex)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %   This function will modify the parameter in
            %   use value for the specified parameter in the
            %   variable sweep.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if nargin == 3
                theSweepIndex=1;
            end
            
            obj.ArrayOfSweeps{theSweepIndex}.changeVariableSweepParameterState(theVariableName,theStatus);
            
        end
        
    end
end

