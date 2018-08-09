classdef SonnetFrequencyBlock  < handle
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This class defines the FREQ portion of a SONNET project file.
    % This class is a container for the FREQ information that is obtained
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
        SweepsArray               % This is the number of sweeps we have
        UnknownLines              % Keeps values that we dont understand. These values are written back to files.
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = SonnetFrequencyBlock(theFid)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % The constructor for FREQ.
            %     the FREQ will be passed the file ID from the
            %     SONNET project constructor.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            NumberOfSweepsInFile=0;   % keep track of the number of sweeps in the file
            
            if nargin == 1
                
                initialize(obj);            % Initialize the values of the properties using the initializer function
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % We are going to loop forever reading the name
                %     of the sweep from the file and making an
                %     object out of its information. Different
                %     sweeps have different classes. All the
                %     sweeps get stored in a cell array.
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                aTempString=fscanf(theFid,'%s',1);                                      % try to read the the first type of the sweep from the file.
                
                while (strcmp(aTempString,'END')==0)                                    % check if the input was 'END FREQ', if we find it we can stop looping
                    
                    NumberOfSweepsInFile=NumberOfSweepsInFile+1;                        % increment the sweep counter by one
                    
                    if (strcmp(aTempString,'SIMPLE')==1)                                % check if it is a simple sweep
                        obj.SweepsArray{NumberOfSweepsInFile}=SonnetFrequencySimple(theFid);   % construct the new sweep and store in the cell array
                        
                    elseif (strcmp(aTempString,'ABS')==1)                               % check if it is a abs sweep
                        obj.SweepsArray{NumberOfSweepsInFile}=SonnetFrequencyAbs(theFid);      % construct the new sweep and store in the cell array
                        
                    elseif (strcmp(aTempString,'SWEEP')==1)                             % check if it is a sweep sweep
                        obj.SweepsArray{NumberOfSweepsInFile}=SonnetFrequencySweep(theFid);    % construct the new sweep and store in the cell array
                        
                    elseif (strcmp(aTempString,'ABS_ENTRY')==1)                         % check if it is a abs entry sweep
                        obj.SweepsArray{NumberOfSweepsInFile}=SonnetFrequencyAbsEntry(theFid); % construct the new sweep and store in the cell array
                        
                    elseif (strcmp(aTempString,'STEP')==1)                              % check if it is a step sweep
                        obj.SweepsArray{NumberOfSweepsInFile}=SonnetFrequencyStep(theFid);     % construct the new sweep and store in the cell array
                        
                    elseif (strcmp(aTempString,'ESWEEP')==1)                            % check if it is a esweep sweep
                        obj.SweepsArray{NumberOfSweepsInFile}=SonnetFrequencyEsweep(theFid);   % construct the new sweep and store in the cell array
                        
                    elseif (strcmp(aTempString,'LSWEEP')==1)                            % check if it is a lsweep sweep
                        obj.SweepsArray{NumberOfSweepsInFile}=SonnetFrequencyLsweep(theFid);   % construct the new sweep and store in the cell array
                        
                    elseif (strcmp(aTempString,'ABS_FMIN')==1)                          % check if it is a abs_fmin sweep
                        obj.SweepsArray{NumberOfSweepsInFile}=SonnetFrequencyAbsFmin(theFid);  % construct the new sweep and store in the cell array
                        
                    elseif (strcmp(aTempString,'ABS_FMAX')==1)                          % check if it is a abs_fmax sweep
                        obj.SweepsArray{NumberOfSweepsInFile}=SonnetFrequencyAbsFmax(theFid);  % construct the new sweep and store in the cell array
                        
                    elseif (strcmp(aTempString,'DC_FREQ')==1)                           % check if it is a abs_fmax sweep
                        obj.SweepsArray{NumberOfSweepsInFile}=SonnetFrequencyDcFreq(theFid);   % construct the new sweep and store in the cell array
                    elseif (strcmp(aTempString,'LIST')==1) 
                        obj.SweepsArray{NumberOfSweepsInFile}=SonnetFrequencyList(theFid);   % construct the new sweep and store in the cell array
                    else                                                                    % If it is an unrecognized frequency or some other known line store it so we can write it back out
                        obj.UnknownLines = [obj.UnknownLines aTempString fgetl(theFid) '\n'];	% Add the line to the uknownlines array
                        NumberOfSweepsInFile=NumberOfSweepsInFile-1;                          % Decrement the counter by one beccause we are about to incremenet it without having found a proper freq type
                        
                    end
                    
                    aTempString=fscanf(theFid,'%s',1);                                  % read the next sweep name from the file, if it is END then we are done
                    
                end
                
                % read the rest of the line we are on to get the theFid ready for
                % the next block.
                fgetl(theFid);
                
            else
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % we come here when we didn't recieve a file ID as an argument
                % which means that we are going to create a default freq block with
                % default values by calling the function's initialize method.
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                initialize(obj);
                
            end
            
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function initialize(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function initializes the freq properties to some default
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
            aNewObject=SonnetFrequencyBlock();
            SonnetClone(obj,aNewObject);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function writeObjectContents(obj, theFid, theVersion)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function writes the values from the object to a file.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            fprintf(theFid,'FREQ\n');
            
            % Print out the sweeps
            for iCounter= 1:length(obj.SweepsArray)
                    obj.SweepsArray{iCounter}.writeObjectContents(theFid,theVersion);
            end
            
            % Print out any unknown lines
            if (~isempty(obj.UnknownLines))
                fprintf(theFid, sprintf('%s',obj.UnknownLines));
            end
            
            fprintf(theFid,'END FREQ\n');
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aSignature=stringSignature(obj,theVersion) 
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function writes the values from the object to a string.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            aSignature = sprintf('FREQ\n');
            
            % We want to first write out instances of ABS sweeps to the file
            for iCounter= 1:length(obj.SweepsArray)
                    aSignature = [aSignature obj.SweepsArray{iCounter}.stringSignature(theVersion)]; %#ok<AGROW>
            end
            
            if (~isempty(obj.UnknownLines))
                aSignature = [aSignature strrep(obj.UnknownLines,'\n',sprintf('\n'))]; 
            end
            
            aSignature = [aSignature sprintf('END FREQ\n');]; 
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addSweep(obj,theSweepType,theargument1,theargument2,theargument3)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function adds a sweep to the project. It requires
            % a string specifying the type and all the arguments
            % necessary in order to construct the sweep using the
            % sweep's individual add method. Types and arguments
            % Are as follows:
            %   SWEEP       StartFrequency,EndFrequency,StepFrequency
            %   ABS         StartFrequency,EndFrequency
            %   ABSENTRY    StartFrequency,EndFrequency
            %   ABSFMAX     StartFrequency,EndFrequency,Maximum
            %   ABSFMIN     StartFrequency,EndFrequency,Minimum
            %   DC          Mode,Frequency
            %   ESWEEP      StartFrequency,EndFrequency,AnalysisFrequencies
            %   LSWEEP      StartFrequency,EndFrequency,AnalysisFrequencies
            %   SIMPLE      StartFrequency,EndFrequency,StepFrequency
            %   STEP        StepFrequency
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Convert the Sweep Type string to all uppercase for the switch
            theSweepType=upper(theSweepType);
            
            % Depending on what the string was we will construct the proper type
            % of sweep using the sweep's add function.
            switch theSweepType
                
                case 'SWEEP'
                    obj.addSweepSweep(theargument1,theargument2, theargument3);
                case 'ABS'
                    obj.addAbs(theargument1,theargument2);
                case 'ABSENTRY'
                    obj.addAbsEntry(theargument1,theargument2);
                case 'ABSFMAX'
                    obj.addAbsFmax(theargument1,theargument2,theargument3);
                case 'ABSFMIN'
                    obj.addAbsFmin(theargument1,theargument2,theargument3);
                case 'DC'
                    obj.addDcFreq(theargument1,theargument2);
                case 'ESWEEP'
                    obj.addEsweep(theargument1,theargument2,theargument3);
                case 'LSWEEP'
                    obj.addLsweep(theargument1,theargument2,theargument3);
                case 'SIMPLE'
                    obj.addSimple(theargument1,theargument2,theargument3);
                case 'STEP'
                    obj.addStep(theargument1);
                otherwise
                    error('Improper String for sweep type.');
                    
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addSweepSweep(obj,theStartFrequency,theEndFrequency,theStepFrequency)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function adds a sweep type of frequency sweep
            % to the project. It requires the following parameters
            %     StartFrequency,EndFrequency, StepFrequency
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Construct an empty Sweep and put it in the array
            aNewSizeOfTheSweepArray=length(obj.SweepsArray)+1;
            obj.SweepsArray{aNewSizeOfTheSweepArray}=SonnetFrequencySweep();
            
            % Modify the values for the sweep
            obj.SweepsArray{aNewSizeOfTheSweepArray}.StartFreqValue=theStartFrequency;
            obj.SweepsArray{aNewSizeOfTheSweepArray}.EndFreqValue=theEndFrequency;
            obj.SweepsArray{aNewSizeOfTheSweepArray}.StepValue=theStepFrequency;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addAbs(obj,theStartFrequency,theEndFrequency)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function adds an abs type of frequency sweep
            % to the project. It requires the following parameters
            %     StartFrequency,EndFrequency
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Construct an empty Sweep and put it in the array
            aNewSizeOfTheSweepArray=length(obj.SweepsArray)+1;
            obj.SweepsArray{aNewSizeOfTheSweepArray}=SonnetFrequencyAbs();
            
            % Modify the values for the sweep
            obj.SweepsArray{aNewSizeOfTheSweepArray}.StartFreqValue=theStartFrequency;
            obj.SweepsArray{aNewSizeOfTheSweepArray}.EndFreqValue=theEndFrequency;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addAbsEntry(obj,theStartFrequency,theEndFrequency)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function adds an abs_entry type of frequency sweep
            % to the project. It requires the following parameters
            %     StartFrequency,EndFrequency
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Construct an empty Sweep and put it in the array
            aNewSizeOfTheSweepArray=length(obj.SweepsArray)+1;
            obj.SweepsArray{aNewSizeOfTheSweepArray}=SonnetFrequencyAbsEntry();
            
            % Modify the values for the sweep
            obj.SweepsArray{aNewSizeOfTheSweepArray}.StartFreqValue=theStartFrequency;
            obj.SweepsArray{aNewSizeOfTheSweepArray}.EndFreqValue=theEndFrequency;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addAbsFmax(obj,theStartFrequency,theEndFrequency,theMaximum)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function adds a ABS-FMAX type of frequency sweep
            % to the project. It requires the following parameters
            %     StartFrequency,EndFrequency,Maximum
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Construct an empty Sweep and put it in the array
            aNewSizeOfTheSweepArray=length(obj.SweepsArray)+1;
            obj.SweepsArray{aNewSizeOfTheSweepArray}=SonnetFrequencyAbsFmax();
            
            % Modify the values for the sweep
            obj.SweepsArray{aNewSizeOfTheSweepArray}.StartFreqValue=theStartFrequency;
            obj.SweepsArray{aNewSizeOfTheSweepArray}.EndFreqValue=theEndFrequency;
            obj.SweepsArray{aNewSizeOfTheSweepArray}.Maximum=theMaximum;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addAbsFmin(obj,theStartFrequency,theEndFrequency,theMinimum)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function adds a ABS-FMIN type of frequency sweep
            % to the project. It requires the following parameters
            %     StartFrequency,EndFrequency,Minimum
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Construct an empty Sweep and put it in the array
            aNewSizeOfTheSweepArray=length(obj.SweepsArray)+1;
            obj.SweepsArray{aNewSizeOfTheSweepArray}=SonnetFrequencyAbsFmin();
            
            % Modify the values for the sweep
            obj.SweepsArray{aNewSizeOfTheSweepArray}.StartFreqValue=theStartFrequency;
            obj.SweepsArray{aNewSizeOfTheSweepArray}.EndFreqValue=theEndFrequency;
            obj.SweepsArray{aNewSizeOfTheSweepArray}.Minimum=theMinimum;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addDcFreq(obj,theMode,theFrequency)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function adds a DC Frequency type of frequency sweep
            % to the project. It requires the following parameters
            %     Mode,Frequency
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Construct an empty Sweep and put it in the array
            aNewSizeOfTheSweepArray=length(obj.SweepsArray)+1;
            obj.SweepsArray{aNewSizeOfTheSweepArray}=SonnetFrequencyDcFreq();
            
            % Modify the values for the sweep
            obj.SweepsArray{aNewSizeOfTheSweepArray}.Mode=theMode;
            
            % If the frequency was supplied then store it
            if nargin == 3
                obj.SweepsArray{aNewSizeOfTheSweepArray}.Frequency=theFrequency;
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addEsweep(obj,theStartFrequency,theEndFrequency,theAnalysisFrequencies)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function adds an ESWEEP type of frequency sweep
            % to the project. It requires the following parameters
            %     StartFrequency,EndFrequency,AnalysisFrequencies
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Construct an empty Sweep and put it in the array
            aNewSizeOfTheSweepArray=length(obj.SweepsArray)+1;
            obj.SweepsArray{aNewSizeOfTheSweepArray}=SonnetFrequencyEsweep();
            
            % Modify the values for the sweep
            obj.SweepsArray{aNewSizeOfTheSweepArray}.StartFreqValue=theStartFrequency;
            obj.SweepsArray{aNewSizeOfTheSweepArray}.EndFreqValue=theEndFrequency;
            obj.SweepsArray{aNewSizeOfTheSweepArray}.AnalysisFrequencies=theAnalysisFrequencies;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addLsweep(obj,theStartFrequency,theEndFrequency,theAnalysisFrequencies)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function adds an LSWEEP type of frequency sweep
            % to the project. It requires the following parameters
            %     StartFrequency,EndFrequency,AnalysisFrequencies
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Construct an empty Sweep and put it in the array
            aNewSizeOfTheSweepArray=length(obj.SweepsArray)+1;
            obj.SweepsArray{aNewSizeOfTheSweepArray}=SonnetFrequencyLsweep();
            
            % Modify the values for the sweep
            obj.SweepsArray{aNewSizeOfTheSweepArray}.StartFreqValue=theStartFrequency;
            obj.SweepsArray{aNewSizeOfTheSweepArray}.EndFreqValue=theEndFrequency;
            obj.SweepsArray{aNewSizeOfTheSweepArray}.AnalysisFrequencies=theAnalysisFrequencies;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addSimple(obj,theStartFrequency,theEndFrequency,theStepFrequency)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function adds a simple type of frequency sweep
            % to the project. It requires the following parameters
            %     StartFrequency,EndFrequency, StepFrequency
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Construct an empty Sweep and put it in the array
            aNewSizeOfTheSweepArray=length(obj.SweepsArray)+1;
            obj.SweepsArray{aNewSizeOfTheSweepArray}=SonnetFrequencySimple();
            
            % Modify the values for the sweep
            obj.SweepsArray{aNewSizeOfTheSweepArray}.StartFreqValue=theStartFrequency;
            obj.SweepsArray{aNewSizeOfTheSweepArray}.EndFreqValue=theEndFrequency;
            obj.SweepsArray{aNewSizeOfTheSweepArray}.StepValue=theStepFrequency;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addStep(obj,theStepFrequency)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function adds a step type of frequency sweep
            % to the project. It requires the following parameters
            %     StepFrequency
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Construct an empty Sweep and put it in the array
            aNewSizeOfTheSweepArray=length(obj.SweepsArray)+1;
            obj.SweepsArray{aNewSizeOfTheSweepArray}=SonnetFrequencyStep();
            
            % Modify the values for the sweep
            obj.SweepsArray{aNewSizeOfTheSweepArray}.StepValue=theStepFrequency;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addFrequencyList(obj, theFrequencyList)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function adds a frequency list type of frequency sweep
            % to the project. It requires the following parameters
            %     theFrequencyList
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
            % Construct an empty Sweep and put it in the array
            aNewSizeOfTheSweepArray=length(obj.SweepsArray)+1;
            obj.SweepsArray{aNewSizeOfTheSweepArray}=SonnetFrequencyList();
            
            % Modify the values for the sweep
            obj.SweepsArray{aNewSizeOfTheSweepArray}.Frequencies=theFrequencyList;                        
        end
                
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [aFrequencySweepObject, aIndexInFrequencySweepArray]=returnSelectedFrequencySweep(obj,theSelectedFrequencySweep)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Function that will return a handle to the object
            % for the selected frequency sweep and its
            % location in the array of frequency sweeps.
            %
            % If the frequency sweep type was combination
            % then the return values will be a cell array of
            % frequency sweep objects and a vector of list
            % indices.
            %
            % This function can not be used when the selected
            % frequency sweep is parameter sweep, optimize or
            % external file.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            aFrequencySweepObject=[];
            aIndexInFrequencySweepArray=[];
            
            % Convert the selected frequency sweep string into the same form as the class name
            switch theSelectedFrequencySweep
                case 'ABS'
                    theSelectedFrequencySweep='SonnetFrequencyAbs';
                case 'SIMPLE'
                    theSelectedFrequencySweep='SonnetFrequencySimple';
                case 'STD'
                    theSelectedFrequencySweep='Combination';
                case 'VARSWP'
                    error('This function can not be used for VARSWP');
                case 'OPTIMIZE'
                    error('This function can not be used for OPTIMIZE');
                case 'EXTFILE'
                    error('This function can not be used for EXTFILE');
            end
            
            % For types of ABS or SIMPLE we want to loop through the list
            % of frequency sweeps looking for the selected frequency sweep object
            % dont put a break in here! if there are multiple versions of the same
            % sweep in the list (which is ok) then we want the last such occurance
            % in the list.
            if strcmp(theSelectedFrequencySweep,'Combination') == 0
                for iCounter=1:length(obj.SweepsArray)
                    if strcmp(theSelectedFrequencySweep,class(obj.SweepsArray{iCounter}))==1
                        aFrequencySweepObject=obj.SweepsArray{iCounter};
                        aIndexInFrequencySweepArray=iCounter;
                    end
                end
                % If the selected frequency is a combination then
                % store all the combinational frequency sweep types
                % in the output variables.
            else
                aFrequencySweepObject={};
                aIndexInFrequencySweepArray=[];
                
                for iCounter=1:length(obj.SweepsArray)
                    if strcmpi(class(obj.SweepsArray{iCounter}),'SonnetFrequencyEsweep')==1 || ...
                            strcmpi(class(obj.SweepsArray{iCounter}),'SonnetFrequencySweep')==1 || ...
                            strcmpi(class(obj.SweepsArray{iCounter}),'SonnetFrequencyLsweep')==1 || ...
                            strcmpi(class(obj.SweepsArray{iCounter}),'SonnetFrequencyStep')==1 || ...
                            strcmpi(class(obj.SweepsArray{iCounter}),'SonnetFrequencyAbsEntry')==1 || ...
                            strcmpi(class(obj.SweepsArray{iCounter}),'SonnetFrequencyAbsFmin')==1 || ...
                            strcmpi(class(obj.SweepsArray{iCounter}),'SonnetFrequencyAbsFmax')==1 || ...
                            strcmpi(class(obj.SweepsArray{iCounter}),'SonnetFrequencyDcFreq')==1
                        
                        aFrequencySweepObject{length(aFrequencySweepObject)+1}=obj.SweepsArray{iCounter}; %#ok<AGROW>
                        aIndexInFrequencySweepArray=[aIndexInFrequencySweepArray iCounter]; %#ok<AGROW>
                        
                    end
                end
                
            end
            
        end
       
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aValue = isValid(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function checks to see if the frequencies are valid
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            warning off backtrace
            
            aValue = true;
            
            aNumberOfSweeps = numel(obj.SweepsArray);
            
            for i = 1:aNumberOfSweeps
                aTypeStr = class(obj.SweepsArray{i});
                
                if (strcmp(aTypeStr,'SonnetFrequencySimple')==1)    
                    if ~isempty(obj.SweepsArray{i}.StartFreqValue)                        
                        if obj.SweepsArray{i}.StartFreqValue <= 0
                            aValue = false;
                            warning('The SonnetFrequencySimple Start must be greater than 0.0'); 
                        end
                    else
                        aValue = false;
                        warning('The SonnetFrequencySimple Start must be specified');
                    end
                    
                    if ~isempty(obj.SweepsArray{i}.EndFreqValue)
                        if obj.SweepsArray{i}.EndFreqValue < obj.SweepsArray{i}.StartFreqValue
                            aValue = false;
                            warning('The SonnetFrequencySimple Stop must be greater than or equal to Start');
                        end
                    end
                    
                    if ~isempty(obj.SweepsArray{i}.StepValue) 
                       if obj.SweepsArray{i}.StepValue < 0
                            aValue = false;
                            warning('The SonnetFrequencySimple Step must be greater than 0.0');
                       end
                    end
                    
                elseif (strcmp(aTypeStr,'SonnetFrequencyAbs')==1)
                    if ~isempty(obj.SweepsArray{i}.StartFreqValue)
                         if obj.SweepsArray{i}.StartFreqValue <= 0
                            aValue = false;
                            warning('The SonnetFrequencyAbs Start must be greater than 0.0'); 
                         end
                    else
                        aValue = false;
                        warning('The SonnetFrequencyAbs Start must be specified');
                    end
                    
                    if ~isempty(obj.SweepsArray{i}.EndFreqValue)
                        if obj.SweepsArray{i}.EndFreqValue < obj.SweepsArray{i}.StartFreqValue
                            aValue = false;
                            warning('The SonnetFrequencyAbs Stop must be greater than or equal to Start');
                        end
                    end
                    
                elseif (strcmp(aTypeStr,'SonnetFrequencySweep')==1)
                    if ~isempty(obj.SweepsArray{i}.StartFreqValue)
                        if obj.SweepsArray{i}.StartFreqValue <= 0
                            aValue = false;
                            warning('The SonnetFrequencySweep Start must be greater than 0.0'); 
                        end
                    else
                        aValue = false;
                        warning('The SonnetFrequencySweep Start must be specified');
                    end
                    
                    if ~isempty(obj.SweepsArray{i}.EndFreqValue)
                        if obj.SweepsArray{i}.EndFreqValue < obj.SweepsArray{i}.StartFreqValue
                            aValue = false;
                            warning('The SonnetFrequencySweep Stop must be greater than or equal to Start');
                        end
                    end
                    
                    if ~isempty(obj.SweepsArray{i}.StepValue) 
                       if obj.SweepsArray{i}.StepValue < 0
                            aValue = false;
                            warning('The SonnetFrequencySweep Step must be greater than 0.0');
                       end
                    end                    
                    
                elseif (strcmp(aTypeStr,'SonnetFrequencyAbsEntry')==1)
                    if ~isempty(obj.SweepsArray{i}.StartFreqValue)
                        if obj.SweepsArray{i}.StartFreqValue <= 0
                            aValue = false;
                            warning('The SonnetFrequencyAbsEntry Start must be greater than 0.0'); 
                        end
                    else
                        aValue = false;
                        warning('The SonnetFrequencyAbsEntry Start must be specified');
                    end                    
                    
                    if ~isempty(obj.SweepsArray{i}.EndFreqValue)
                        if obj.SweepsArray{i}.EndFreqValue < obj.SweepsArray{i}.StartFreqValue
                            aValue = false;
                            warning('The SonnetFrequencyAbsEntry Stop must be greater than or equal to Start');
                        end
                    end
                    
                elseif (strcmp(aTypeStr,'SonnetFrequencyStep')==1)
                    if ~isempty(obj.SweepsArray{i}.StepValue) 
                       if obj.SweepsArray{i}.StepValue < 0
                            aValue = false;
                            warning('The SonnetFrequencyStep Step must be greater than 0.0');
                       end
                    end   
                    
                elseif (strcmp(aTypeStr,'SonnetFrequencyEsweep')==1)
                    if ~isempty(obj.SweepsArray{i}.StartFreqValue)
                        if obj.SweepsArray{i}.StartFreqValue <= 0
                            aValue = false;
                            warning('The SonnetFrequencyEsweep Start must be greater than 0.0'); 
                        end
                    else
                        aValue = false;
                        warning('The SonnetFrequencyEsweep Start must be specified');
                    end
                    
                    if ~isempty(obj.SweepsArray{i}.EndFreqValue)
                        if obj.SweepsArray{i}.EndFreqValue < obj.SweepsArray{i}.StartFreqValue
                            aValue = false;
                            warning('The SonnetFrequencyEsweep Stop must be greater than or equal to Start');
                        end
                    else
                        aValue = false;
                        warning('The SonnetFrequencyEsweep Stop must be specified');
                    end
                
                    if ~isempty(obj.SweepsArray{i}.AnalysisFrequencies) 
                       if obj.SweepsArray{i}.AnalysisFrequencies < 0
                            aValue = false;
                            warning('The SonnetFrequencyEsweep AnalysisFrequencies must be greater than 0.0');
                       end
                    else
                        aValue = false;
                        warning('The SonnetFrequencyEsweep Step must be specified');                        
                    end                     
                    
                elseif (strcmp(aTypeStr,'SonnetFrequencyLsweep')==1)
                    if ~isempty(obj.SweepsArray{i}.StartFreqValue) 
                        if obj.SweepsArray{i}.StartFreqValue <= 0
                            aValue = false;
                            warning('The SonnetFrequencyLsweep Start must be greater than 0.0'); 
                        end
                    else
                        aValue = false;
                        warning('The SonnetFrequencyLsweep Start must be specified');
                    end
                    
                    if ~isempty(obj.SweepsArray{i}.EndFreqValue)
                        if obj.SweepsArray{i}.EndFreqValue < obj.SweepsArray{i}.StartFreqValue
                            aValue = false;
                            warning('The SonnetFrequencyLsweep Stop must be greater than or equal to Start');
                        end
                    else
                        aValue = false;
                        warning('The SonnetFrequencyLsweep Stop must be specified');
                    end
                
                    if ~isempty(obj.SweepsArray{i}.AnalysisFrequencies) 
                       if obj.SweepsArray{i}.AnalysisFrequencies < 0
                            aValue = false;
                            warning('The SonnetFrequencyLsweep AnalysisFrequencies must be greater than 0.0');
                       end
                    else
                        aValue = false;
                        warning('The SonnetFrequencyLsweep Step must be specified');                        
                    end
                    
                elseif (strcmp(aTypeStr,'SonnetFrequencyAbsFmin')==1)
                    if ~isempty(obj.SweepsArray{i}.StartFreqValue) 
                        if obj.SweepsArray{i}.StartFreqValue <= 0
                            aValue = false;
                            warning('The SonnetFrequencyAbsFmin Start must be greater than 0.0'); 
                        end
                    else
                        aValue = false;
                        warning('The SonnetFrequencyAbsFmin Start must be specified');
                    end                        
                    
                    if ~isempty(obj.SweepsArray{i}.EndFreqValue)
                        if obj.SweepsArray{i}.EndFreqValue < obj.SweepsArray{i}.StartFreqValue
                            aValue = false;
                            warning('The SonnetFrequencyAbsFmin Stop must be greater than or equal to Start');
                        end
                    else
                        aValue = false;
                        warning('The SonnetFrequencyAbsFmin Stop must be specified');
                    end
                    
                    if isempty(obj.SweepsArray{i}.Minimum)                        
                        aValue = false;
                        warning('The SonnetFrequencyAbsFmin Minimum must be specified');
                    end
                    
                elseif (strcmp(aTypeStr,'SonnetFrequencyAbsFmax')==1)
                    if ~isempty(obj.SweepsArray{i}.StartFreqValue)
                        if obj.SweepsArray{i}.StartFreqValue <= 0
                            aValue = false;
                            warning('The SonnetFrequencyAbsFmax Start must be greater than 0.0'); 
                        end
                    else
                        aValue = false;
                        warning('The SonnetFrequencyAbsFmax Start must be specified');
                    end  
                    
                    if ~isempty(obj.SweepsArray{i}.EndFreqValue)
                        if obj.SweepsArray{i}.EndFreqValue < obj.SweepsArray{i}.StartFreqValue
                            aValue = false;
                            warning('The SonnetFrequencyAbsFmax Stop must be greater than or equal to Start');
                        end
                    else
                        aValue = false;
                        warning('The SonnetFrequencyAbsFmax Stop must be specified');
                    end
                    
                    if isempty(obj.SweepsArray{i}.Maximum)                        
                        aValue = false;
                        warning('The SonnetFrequencyAbsFmax Maximum must be specified');
                    end
                    
                elseif (strcmp(aTypeStr,'SonnetFrequencyDcFreq')==1)                    
                    if ~isempty(obj.SweepsArray{i}.Mode)
                        if strcmpi('MAN',obj.SweepsArray{i}.Mode) ...
                                || strcmpi('AUTO',obj.SweepsArray{i}.Mode)
                        else
                            aValue = false;
                            warning('The SonnetFrequencyDcFreq Mode must be "MAN" or "AUTO"');
                        end
                        
                        if strcmpi('MAN',obj.SweepsArray{i}.Mode)
                            if ~isempty(obj.SweepsArray{i}.Frequency)
                                if  obj.SweepsArray{i}.Frequency <= 0
                                    aValue = false;
                                    warning('The SonnetFrequencyDcFreq Frequency must be greater than 0.0');                  
                                end
                            else
                                aValue = false;
                                warning('The SonnetFrequencyDcFreq Frequency must be specified');
                            end                            
                        end                        
                    else
                        aValue = false;
                        warning('The SonnetFrequencyDcFreq Mode must be specified');
                    end
                    
                end                               
            end      
            
            warning on backtrace
        end
    end
    
end