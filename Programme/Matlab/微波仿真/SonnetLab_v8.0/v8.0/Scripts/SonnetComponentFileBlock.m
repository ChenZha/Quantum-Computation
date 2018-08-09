classdef SonnetComponentFileBlock < handle
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This class contains a list of files used by data file components.
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
        
        ArrayOfFiles
        
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = SonnetComponentFileBlock(theFid)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % The constructor for the component file block
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if nargin == 1
                
                initialize(obj);	% Initialize the values of the properties using the initializer function
                
                % Read in the file type, if it is 'END' then we should stop looping
                aBackupOfTheFid=ftell(theFid);          	        % Store a backup of the file ID so that we can restore it afer we read the line
                aTempString=SonnetStringReadFormat(theFid);
                fseek(theFid,aBackupOfTheFid,'bof');	            % Restore the backup of the fid
                
                while strcmp(aTempString,'END') == 0
                    
                    SonnetStringReadFormat(theFid);
                    aString=SonnetStringReadFormat(theFid);
                    
                    % Don't store any surrounding quotation marks
                    if aString(1)=='"'
                        aString(1)=[];
                        aString(length(aString))=[];
                    end
                    
                    obj.ArrayOfFiles{length(obj.ArrayOfFiles)+1}=aString;
                    
                    % Read in the file type, if it is 'END' then we should stop looping
                    aBackupOfTheFid=ftell(theFid);          	        % Store a backup of the file ID so that we can restore it afer we read the line
                    aTempString=SonnetStringReadFormat(theFid);
                    fseek(theFid,aBackupOfTheFid,'bof');	            % Restore the backup of the fid
                    
                end
                
                % Read in and toss the END SMDFILES line
                fgetl(theFid);
                
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
            aNewObject=SonnetComponentFileBlock();
            SonnetClone(obj,aNewObject);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function writeObjectContents(obj, theFid, theVersion) %#ok<INUSD>
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function writes the values from the object to a file.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            fprintf(theFid,'SMDFILES\n');
            
            for iCounter=1:length(obj.ArrayOfFiles)
                % Don't print any surrounding quotation marks
                aString=obj.ArrayOfFiles{iCounter};
                if aString(1)=='"'
                    aString(1)=[];
                    aString(length(aString))=[];
                end
                fprintf(theFid,'%d "%s"\n',iCounter,aString);
            end    
            
            fprintf(theFid,'END SMDFILES\n');
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aSignature=stringSignature(obj,theVersion) %#ok<INUSD>
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function writes the values from the object to a string.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            aSignature = sprintf('SMDFILES\n');
                        
            for iCounter=1:length(obj.ArrayOfFiles)
                % Don't print any surrounding quotation marks
                aString=obj.ArrayOfFiles{iCounter};
                if aString(1)=='"'
                    aString(1)=[];
                    aString(length(aString))=[];
                end
                aSignature = [aSignature num2str(iCounter) ' "' SonnetStringWriteFormat(aString) sprintf('"\n')]; %#ok<AGROW>
            end
            
            aSignature = [aSignature sprintf('END SMDFILES\n')];
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function iCounter=addSmdFile(obj,theFilename)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This Method will add an SMD file to the SMD files
            %   block. If the file already exists then it will not 
            %   be added. The file's index is returned.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            aString1=theFilename;
            if aString1(1)=='"'
                aString1(1)=[];
                aString1(length(aString1))=[];
            end
                        
            % Check the array to see if the file already exists
            for iCounter=1:length(obj.ArrayOfFiles)
                aString2=obj.ArrayOfFiles{iCounter};
                if aString2(1)=='"'
                    aString2(1)=[];
                    aString2(length(aString2))=[];
                end
                if strcmpi(aString1,aString2)==1
                    return
                end
            end
            
            % Add a new file to the list
            obj.ArrayOfFiles{length(obj.ArrayOfFiles)+1}=aString1;
            iCounter=length(obj.ArrayOfFiles);
        end
        
    end
    
end

