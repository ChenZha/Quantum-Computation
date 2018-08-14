classdef SonnetGeometryAnisotropic < handle
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This class defines the values for an anisotropic dielectric material (BRA)
    % in the Geo block of the Sonnet project file.
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
        
        Name
        PatternId
        XRelativeDielectricConstant
        XLossTangent
        XBulkConductivity
        YRelativeDielectricConstant
        YLossTangent
        YBulkConductivity
        ZRelativeDielectricConstant
        ZLossTangent
        ZBulkConductivity
        
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = SonnetGeometryAnisotropic(theFid)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % define the constructor for the anisotropic dielectric material.
            %     the constructor will be passed the file ID from the
            %     SONNET GEO object constructor.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if nargin == 1       
                
                initialize(obj);
                
                obj.Name=SonnetStringReadFormat(theFid);
                obj.Name=strrep(obj.Name,'"','');
                
                obj.PatternId=SonnetStringReadFormat(theFid);
                obj.XRelativeDielectricConstant=SonnetStringReadFormat(theFid);
                obj.XLossTangent=SonnetStringReadFormat(theFid);
                obj.XBulkConductivity=SonnetStringReadFormat(theFid);
                obj.YRelativeDielectricConstant=SonnetStringReadFormat(theFid);
                obj.YLossTangent=SonnetStringReadFormat(theFid);
                obj.YBulkConductivity=SonnetStringReadFormat(theFid);
                obj.ZRelativeDielectricConstant=SonnetStringReadFormat(theFid);
                obj.ZLossTangent=SonnetStringReadFormat(theFid);
                obj.ZBulkConductivity=SonnetStringReadFormat(theFid);
                
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
        function aString=toString(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Returns a string representation of a brick type.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            aString = [obj.Name ' :: XErel=' num2str(obj.XRelativeDielectricConstant)...
                ' :: YErel=' num2str(obj.YRelativeDielectricConstant)...
                ' :: ZErel=' num2str(obj.ZRelativeDielectricConstant)];
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function initialize(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function initializes the BRA properties to some default
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
            
            obj.PatternId=0;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aNewObject=clone(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function builds a deep copy of this object
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            aNewObject=SonnetGeometryAnisotropic();
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
            
            aSignature = 'BRA';
            
            if ~isempty(obj.Name)
                aSignature = [aSignature ' "' SonnetStringWriteFormat(obj.Name) '"'];
            end
            
            if ~isempty(obj.PatternId)
                aTempString=SonnetStringWriteFormat(obj.PatternId);
                aSignature=[aSignature sprintf(' %s',aTempString)];
            end
            
            if ~isempty(obj.XRelativeDielectricConstant)
                aTempString=SonnetStringWriteFormat(obj.XRelativeDielectricConstant);
                aSignature=[aSignature sprintf(' %s',aTempString)];
            end
            
            if ~isempty(obj.XLossTangent)
                aTempString=SonnetStringWriteFormat(obj.XLossTangent);
                aSignature=[aSignature sprintf(' %s',aTempString)];
            end
            
            if ~isempty(obj.XBulkConductivity)
                aTempString=SonnetStringWriteFormat(obj.XBulkConductivity);
                aSignature=[aSignature sprintf(' %s',aTempString)];
            end
            
            if ~isempty(obj.YRelativeDielectricConstant)
                aTempString=SonnetStringWriteFormat(obj.YRelativeDielectricConstant);
                aSignature=[aSignature sprintf(' %s',aTempString)];
            end
            
            if ~isempty(obj.YLossTangent)
                aTempString=SonnetStringWriteFormat(obj.YLossTangent);
                aSignature=[aSignature sprintf(' %s',aTempString)];
            end
            
            if ~isempty(obj.YBulkConductivity)
                aTempString=SonnetStringWriteFormat(obj.YBulkConductivity);
                aSignature=[aSignature sprintf(' %s',aTempString)];
            end
            
            if ~isempty(obj.ZRelativeDielectricConstant)
                aTempString=SonnetStringWriteFormat(obj.ZRelativeDielectricConstant);
                aSignature=[aSignature sprintf(' %s',aTempString)];
            end
            
            if ~isempty(obj.ZLossTangent)
                aTempString=SonnetStringWriteFormat(obj.ZLossTangent);
                aSignature=[aSignature sprintf(' %s',aTempString)];
            end
            
            if ~isempty(obj.ZBulkConductivity)
                aTempString=SonnetStringWriteFormat(obj.ZBulkConductivity);
                aSignature=[aSignature sprintf(' %s',aTempString)];
            end
            
            aSignature = [aSignature sprintf('\n')];
            
        end
        
        
    end
end

