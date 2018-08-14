classdef SonnetVariableBlock < handle
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This class defines the VAR block for a Sonnet netlist project.
    % It stores all the variables that are used for a Sonnet netlist project.
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
        
        ArrayOfParameters
        
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = SonnetVariableBlock(theFid)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % The constructor for The Sonnet parameter block for netlists
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if nargin == 1      % If we were passed 1 argument which means we got the theFid
                
                initialize(obj);	% Initialize the values of the properties using the initializer function
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Now we will loop and read in all the parameters that were included.
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                aTempLine=fgetl(theFid);
                
                while strcmpi(aTempLine,'END VAR')==0   % keep reading till the end of the block
                    
                    % if the line was not the end then we need to parse it as a parameter, we will remove the whitespace and deliminate by the equals sign
                    aTempLine=strtrim(aTempLine);         % remove leading and trailing whitespace
                    aTempLine=strrep(aTempLine,' ','');   % remove spaces from the middle of the line
                    
                    [aTempParameterName aTempParameterValue]=strtok(aTempLine,'=');   % Get the values before and after the equals sign
                    aTempParameterValue=strrep(aTempParameterValue,'=','');           % Remove the equals sign from the string
                    
                    aNewSizeOfArray=length(obj.ArrayOfParameters)+1;
                    obj.ArrayOfParameters{aNewSizeOfArray}=SonnetVariableParameter(aTempParameterName,aTempParameterValue); % Make a new VAR parameter
                    
                    aTempLine=fgetl(theFid);              % Read in another line and test it if is a parameter or not
                    
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
            aNewObject=SonnetVariableBlock();
            SonnetClone(obj,aNewObject);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function writeObjectContents(obj, theFid, theVersion)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function writes the values from the object to a file.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            fprintf(theFid,'VAR\n');
            
            for iCounter= 1:length(obj.ArrayOfParameters)
                obj.ArrayOfParameters{iCounter}.writeObjectContents(theFid,theVersion);
                fprintf(theFid, '\n');
            end
            
            fprintf(theFid,'END VAR\n');
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aSignature=stringSignature(obj,theVersion)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function writes the values from the object to a string.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            aSignature = sprintf('VAR\n');
            
            for iCounter= 1:length(obj.ArrayOfParameters)
                aSignature = [aSignature obj.ArrayOfParameters{iCounter}.stringSignature(theVersion)]; %#ok<AGROW>
                aSignature = [aSignature sprintf('\n')]; %#ok<AGROW>
            end
            
            aSignature = [aSignature sprintf('END VAR\n')];
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function modifyVariableValue(obj, theString, theValue)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %   Project.modifyVariableValue(Name,Value) Modifies the
            %   value for a netlist variable.
            %
            %   If the user supplies the name for an unknown variable
            %   then no action will take place. The name of
            %   the variable is case insensitive.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Modify the variable
            for iCounter=1:length(obj.ArrayOfParameters)
                if strcmpi(theString,obj.ArrayOfParameters{iCounter}.ParameterName)==1
                    obj.ArrayOfParameters{iCounter}.ParameterValue=theValue;
                    return
                end
            end
            
            error ('Variable not found');
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function defineVariable(obj, theString, theValue, ~)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % defineVariable defines a new netlist parameter.
            %   If the variable already exists replace its
            %   value will be replaced.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % If the variable already exists replace its value
            for iCounter=1:length(obj.ArrayOfParameters)
                if strcmpi(theString,obj.ArrayOfParameters{iCounter}.ParameterName)==1
                    obj.ArrayOfParameters{iCounter}.ParameterValue=theValue;
                    return
                end
            end
            
            % Add a new entry to the end of the array of variables
            aNewParameter=SonnetVariableParameter();
            aNewParameter.ParameterName=theString;
            aNewParameter.ParameterValue=theValue;
            obj.ArrayOfParameters{length(obj.ArrayOfParameters)+1}=aNewParameter;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aValue=getVariableValue(obj, theString)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % getVariableValue returns the value of a parameter
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            aValue=[];
            for iCounter=1:length(obj.ArrayOfParameters)
                if strcmpi(theString,obj.ArrayOfParameters{iCounter}.ParameterName)==1
                    if ~isnan(str2double(obj.ArrayOfParameters{iCounter}.ParameterValue))
                        aValue=str2double(obj.ArrayOfParameters{iCounter}.ParameterValue);
                    else
                        aValue=obj.ArrayOfParameters{iCounter}.ParameterValue;
                    end
                    return
                end
            end
        end
    end
end