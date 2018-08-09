classdef SonnetCircuitRLGC
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ArrayOfPortNodes
        DatFileName
        Length
        
    end
        
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = SonnetCircuitRLGC(theFid)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % The constructor for Circuit network, this is defined
            % in the Circuit Block (CKT) entry in the Sonnet Project
            % File for Netlists.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if nargin == 1      % If we were passed 1 argument which means we got the theFid
                
                initialize(obj);
                
                % Get ports
                aTempString = fscanf(theFid,' %f',1);
                
                while isnumeric(aTempString)  && ~isempty(aTempString)                                      
                    obj.ArrayOfPortNodes = [obj.ArrayOfPortNodes  aTempString];
                    aTempString = fscanf(theFid,' %f',1);
                end
                
                % Read dat file name
                obj.DatFileName=fscanf(theFid,' %s',1); % Read in the name of the .dat file
           
                % Read Length=Value
                aTempString = fscanf(theFid,' %s',1);
                
                % Remove Value
                if strcmpi(aTempString(1:7), 'Length=')
                    aTempString = aTempString(8:length(aTempString));
                end
                
                obj.Length = str2double(aTempString);                                              
                                          
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
            aNewObject=SonnetCircuitRLGC();
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
       
            aCanContinue = 1;
            
            if isempty(obj.ArrayOfPortNodes)
                aCanContinue = 0;
            end
            
            if isempty(obj.DatFileName)
                aCanContinue = 0;
            end
            
            if ~isempty(obj.Length) && aCanContinue == 1
                
                if ischar(obj.ArrayOfPortNodes) == 1
                    aSignature = sprintf(' %s',obj.ArrayOfPortNodes);
                else
                    aSignature = sprintf(' %.15g',obj.ArrayOfPortNodes);            
                end                
                
                aSignature = [sprintf('RLGC') aSignature sprintf([' ' obj.DatFileName]) sprintf('\n')];
            end                                                    
        end % function aSignature=stringSignature(obj,theVersion)        
    end % methods
end

