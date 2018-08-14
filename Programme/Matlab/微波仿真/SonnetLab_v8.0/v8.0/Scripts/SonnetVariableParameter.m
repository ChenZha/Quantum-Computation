classdef SonnetVariableParameter < handle
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This class defines the a particular variable in the sonnet project. 
    % This object should be contained within a Sonnet VAR block. The
    % VAR block only exists for Sonnet netlist projects.
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
        
        ParameterName
        ParameterValue
        
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = SonnetVariableParameter(theTempParameterName,theTempParameterValue)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % The constructor for a Sonnet parameter
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if nargin == 2      
                
                initialize(obj);	% Initialize the values of the properties using the initializer function
                
                obj.ParameterName=theTempParameterName;
                obj.ParameterValue=theTempParameterValue;

            else
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % we come here when we didn't recieve a file ID as an argument
                % which means that we are going to create a default object
                % with
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
            aNewObject=SonnetVariableParameter();
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
            
            if ~isempty(obj.ParameterName) && ~isempty(obj.ParameterValue)
                if isa(obj.ParameterValue,'char')
                    aSignature = sprintf('%s=%s',obj.ParameterName,obj.ParameterValue);
                else
                    aSignature = sprintf('%s=%.15g',obj.ParameterName,obj.ParameterValue);
                end
            end
            
        end
        
    end
    
end