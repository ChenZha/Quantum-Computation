classdef SonnetGeometryViaMetalType < handle
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This class defines the values for a
    % custom via metal type created by the user.
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
        Type
        
        Conductivity
        isSolid
        WallThickness
        
        R
        X
        
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = SonnetGeometryViaMetalType(theFid)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % define the constructor for the metals.
            %     the constructor will be passed the file ID from the
            %     SONNET GEO object constructor.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if nargin == 1
                
                initialize(obj);
                
                % Read the name of the metal from the file
                obj.Name=SonnetStringReadFormat(theFid);
                obj.Name=strrep(obj.Name,'"','');
                
                % Read in the pattern ID from the file
                obj.PatternId=fscanf(theFid,' %d',1);
                
                % We need to read in a string to determine what type of
                % metal it is.
                aTempString=fscanf(theFid,' %s',1);
                
                switch aTempString
                    
                    case 'VOL'
                        obj.Type='Volume';
                        obj.Conductivity=SonnetStringReadFormat(theFid);
                        
                        aTempValue=SonnetStringReadFormat(theFid);
                        if isa(aTempValue,'char') && strcmpi(aTempValue,'SOLID')==1
                            obj.isSolid=true;
                            SonnetStringReadFormat(theFid);
                        else
                            obj.isSolid=false;
                            obj.WallThickness=aTempValue;
                        end
                        
                    case 'SFC'
                        obj.Type='Surface';
                        obj.R=SonnetStringReadFormat(theFid);
                        obj.X=SonnetStringReadFormat(theFid);
                        
                    case 'TOT'
                        obj.Type='Total';
                        obj.R=SonnetStringReadFormat(theFid);
                        obj.X=SonnetStringReadFormat(theFid);
                end
                
            else
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % we come here when we didn't recieve a file ID as an argument
                % which means that we are going to create a default metal object with
                % default values by calling the function's initialize method.
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                initialize(obj);
                
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function initialize(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function initializes the metal properties to some default
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
            aNewObject=SonnetGeometryViaMetalType();
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
            
            if ~isempty(obj.Name)
                aSignature=sprintf('VMET "%s"',obj.Name);
            end
            
            aSignature = [aSignature sprintf(' %d',obj.PatternId)];
            
            if strcmpi('VOL',obj.Type)==1 || strcmpi('Volume',obj.Type)==1
                aSignature = [aSignature ' VOL'];
                aSignature = [aSignature ' '  SonnetStringWriteFormat(obj.Conductivity)];
                if obj.isSolid
                    aSignature = [aSignature ' SOLID 0'];
                else
                    aSignature = [aSignature ' '  SonnetStringWriteFormat(obj.WallThickness)];
                end

            elseif strcmpi('SFC',obj.Type)==1 || strcmpi('Surface',obj.Type)==1
                aSignature = [aSignature ' SFC'];
                aSignature = [aSignature ' '  SonnetStringWriteFormat(obj.R)];
                aSignature = [aSignature ' '  SonnetStringWriteFormat(obj.X)];
                
            elseif strcmpi('TOT',obj.Type)==1 || strcmpi('Total',obj.Type)==1
                aSignature = [aSignature ' TOT'];
                aSignature = [aSignature ' '  SonnetStringWriteFormat(obj.R)];
                aSignature = [aSignature ' '  SonnetStringWriteFormat(obj.X)];
                
            end
            
            aSignature = [aSignature sprintf(' \n')];
            
        end
    end
end

