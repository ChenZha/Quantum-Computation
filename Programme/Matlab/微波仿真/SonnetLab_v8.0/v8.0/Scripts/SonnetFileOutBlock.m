classdef SonnetFileOutBlock < handle
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This class contains all the file output types included in a
    % Sonnet project.
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
        
        Folder
        ArrayOfFileOutputConfigurations
        
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = SonnetFileOutBlock(theFid)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % The constructor for the file output block
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if nargin == 1          % If we were passed 1 argument which means we got the theFid
                
                initialize(obj);	% Initialize the values of the properties using the initializer function
                
                % Read in the file type, if it is 'END' then we should stop looping
                aBackupOfTheFid=ftell(theFid);          	        % Store a backup of the file ID so that we can restore it afer we read the line
                aTempString=fscanf(theFid,'%s',1);
                                
                fseek(theFid,aBackupOfTheFid,'bof');	            % Restore the backup of the fid
                
                while strcmp(aTempString,'END')==0 % While the string we read is not end which indicates that there are more fileoutput settings to read in
                    
                    if isempty(aTempString)
                        aTempString='';
                    end
                                    
                    % If the line indicates a folder location then store the folder location, otherwise the line pertains to a output file
                    if strcmp(aTempString,'FOLDER') == 1
                        SonnetStringReadFormat(theFid);
                        obj.Folder=SonnetStringReadFormat(theFid);
                    else
                        % Construct a new file output line given the file
                        theNewSizeOfTheArray=length(obj.ArrayOfFileOutputConfigurations)+1;
                        obj.ArrayOfFileOutputConfigurations{theNewSizeOfTheArray}=SonnetFileOutLine(theFid);
                    end
                    
                    % Read in the file type, if it is 'END' then we should stop looping
                    aBackupOfTheFid=ftell(theFid);          	        % Store a backup of the file ID so that we can restore it afer we read the line
                    aTempString=fscanf(theFid,'%s',1);
                    fseek(theFid,aBackupOfTheFid,'bof');	            % Restore the backup of the fid
                    
                end
                
                % Read in and toss the END FILEOUT line
                while strcmp(aTempString,'END FILEOUT') == 0
                    aTempString=strtrim(fgetl(theFid));
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
            aNewObject=SonnetFileOutBlock();
            SonnetClone(obj,aNewObject);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function writeObjectContents(obj, theFid, theVersion)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function writes the values from the object to a file.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            fprintf(theFid,'FILEOUT\n');
            
            for iCounter=1:length(obj.ArrayOfFileOutputConfigurations)
                obj.ArrayOfFileOutputConfigurations{iCounter}.writeObjectContents(theFid,theVersion);
            end
            
            if theVersion >= 13 && ~isempty(obj.Folder)
                fprintf(theFid,'FOLDER %s\n',obj.Folder);
            end
            
            fprintf(theFid,'END FILEOUT\n');
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aSignature=stringSignature(obj, theVersion)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function writes the values from the object to a string.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            aSignature = sprintf('FILEOUT\n');
            
            for iCounter=1:length(obj.ArrayOfFileOutputConfigurations)
                aSignature = [aSignature obj.ArrayOfFileOutputConfigurations{iCounter}.stringSignature(theVersion)]; %#ok<AGROW>
            end
            
            if theVersion >= 13 && ~isempty(obj.Folder)
                aSignature=[aSignature sprintf('FOLDER %s\n',obj.Folder)];
            end
            
            aSignature = [aSignature sprintf('END FILEOUT\n')];
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addFileOutLine(obj, theFileOutLine)
            % Construct a new file output line given the file
            theNewSizeOfTheArray=length(obj.ArrayOfFileOutputConfigurations)+1;
            obj.ArrayOfFileOutputConfigurations{theNewSizeOfTheArray}=theFileOutLine;                             
        end
        
    end
    
end

