classdef SonnetHeaderBlock < handle
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This class defines the Header portion of a SONNET project file.
    % This class is a container for the header information that is obtained
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
        LicenseString
        DateTheFileWasLastSaved
        InformationAboutHowTheProjectWasCreated
        InformationAboutHowTheProjectWasLastSaved
        DateTheProjectWasSavedWithMediumImportanceChanges
        DateTheProjectWasSavedWithHighImportanceChanges
        UnknownLines
        
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = SonnetHeaderBlock(theFid)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % The constructor for the Header.
            %     The header will be passed the file ID from the
            %     SONNET project constructor.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if nargin == 1
                
                initialize(obj);
                
                while (1==1)						% keep looping till we get to the end of the block in which case we read everything
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % Read a string from the file.
                    % This String drives a switch
                    % statement to determine what
                    % values are going to be changed.
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    aTempString=fscanf(theFid,' %s',1);
                    
                    switch aTempString								% Compare the read value to the known property names, if they match then assign the value otherwise save as an unknown line
                        
                        case 'LIC'
                            obj.LicenseString=fgetl(theFid);
                            
                        case 'DAT'
                            obj.DateTheFileWasLastSaved= fgetl(theFid);
                            
                        case 'BUILT_BY_CREATED'
                            obj.InformationAboutHowTheProjectWasCreated=fgetl(theFid);
                            
                        case 'BUILT_BY_SAVED'
                            obj.InformationAboutHowTheProjectWasLastSaved=fgetl(theFid);
                            
                        case 'MDATE'
                            obj.DateTheProjectWasSavedWithMediumImportanceChanges=fgetl(theFid);
                            
                        case 'HDATE'
                            obj.DateTheProjectWasSavedWithHighImportanceChanges=fgetl(theFid);
                        
                        case 'EXF'

                        case 'END'
                            fgetl(theFid);								% Get the rest of the line, we dont need to save it anywhere because anything after END is unimportant
                            break;
                            
                        otherwise												% If we dont recognize the line then we want to save it so we can write it out again.
                            obj.UnknownLines{end+1} = [aTempString fgetl(theFid) '\n'];	% Add the line to the unknownlines array
                            
                    end
                    
                end
                
                
                
            else
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % we come here when we didn't recieve a file ID as an argument
                % which means that we are going to create a default HEADER with
                % default values by calling the function's initialize method.
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                initialize(obj);
                
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function initialize(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function initializes the header to some default
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
            
            % Make and format the date and time based on the current day and time
            theTempDate=fix(clock);        % returns the date and time in an array, we will then parse it to the proper format
            theDateAndTime=[' ' int2str(theTempDate(2)) '/' int2str(theTempDate(3)) '/' int2str(theTempDate(1)) ' ' int2str(theTempDate(4)) ':' int2str(theTempDate(5)) ':' int2str(theTempDate(6))];  % parse the information returned by clock and include the necessary formating
            
            obj.DateTheFileWasLastSaved=theDateAndTime;
            obj.DateTheProjectWasSavedWithMediumImportanceChanges=theDateAndTime;
            obj.DateTheProjectWasSavedWithHighImportanceChanges=theDateAndTime;
            obj.UnknownLines={};
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aNewObject=clone(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function builds a deep copy of this object
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            aNewObject=SonnetHeaderBlock();
            SonnetClone(obj,aNewObject);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function writeObjectContents(obj, theFid, theVersion) %#ok<INUSD>
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function writes the values from the object to a file.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            fprintf(theFid,'HEADER\n');
            
            % If the value is defined print it out to the file
            if (~isempty(obj.LicenseString))
                fprintf(theFid, 'LIC%s\n',obj.LicenseString);
            end
            
            % Make and format the date and time based on the current day and time
            theTempDate=fix(clock);
            theDateAndTime=[' ' int2str(theTempDate(2)) '/' int2str(theTempDate(3)) '/' int2str(theTempDate(1)) ' ' int2str(theTempDate(4)) ':' int2str(theTempDate(5)) ':' int2str(theTempDate(6))];  % parse the information returned by clock and include the necessary formating
            obj.DateTheFileWasLastSaved=theDateAndTime;
            fprintf(theFid, 'DAT%s\n',obj.DateTheFileWasLastSaved);
            
            if (~isempty(obj.InformationAboutHowTheProjectWasCreated))
                fprintf(theFid, 'BUILT_BY_CREATED%s\n',obj.InformationAboutHowTheProjectWasCreated);
            else
                fprintf(theFid, 'BUILT_BY_CREATED%s\n',[' Sonnet Matlab Interface v' num2str(SonnetMatlabVersion(false))]);
            end
            
            fprintf(theFid, 'BUILT_BY_SAVED%s\n',[' Sonnet Matlab Interface v' num2str(SonnetMatlabVersion(false))]);
            
            if (~isempty(obj.DateTheProjectWasSavedWithMediumImportanceChanges))
                fprintf(theFid, 'MDATE%s\n',obj.DateTheProjectWasSavedWithMediumImportanceChanges);
            end
            if (~isempty(obj.DateTheProjectWasSavedWithHighImportanceChanges))
                fprintf(theFid, 'HDATE%s\n',obj.DateTheProjectWasSavedWithHighImportanceChanges);
            end
            for iCounter=1:length(obj.UnknownLines)
                fprintf(theFid, sprintf('%s',obj.UnknownLines{iCounter}));
            end
            
            fprintf(theFid,'END HEADER\n');
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aSignature=stringSignature(obj,theVersion) %#ok<INUSD>
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function writes the values from the object to a string.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            aSignature = sprintf('HEADER\n');
            
            % If the value is defined print it out to the file
            if (~isempty(obj.LicenseString))
                aSignature = [aSignature sprintf('LIC%s\n',obj.LicenseString)];
            end
            
            % Make and format the date and time based on the current day and time
            theTempDate=fix(clock);
            theDateAndTime=[' ' int2str(theTempDate(2)) '/' int2str(theTempDate(3)) '/' int2str(theTempDate(1)) ' ' int2str(theTempDate(4)) ':' int2str(theTempDate(5)) ':' int2str(theTempDate(6))];  % parse the information returned by clock and include the necessary formating
            obj.DateTheFileWasLastSaved=theDateAndTime;
            aSignature = [aSignature sprintf('DAT%s\n',obj.DateTheFileWasLastSaved)];
            
            if (~isempty(obj.InformationAboutHowTheProjectWasCreated))
                aSignature = [aSignature sprintf('BUILT_BY_CREATED%s\n',obj.InformationAboutHowTheProjectWasCreated)];
            end
            if (~isempty(obj.InformationAboutHowTheProjectWasLastSaved))
                aSignature = [aSignature sprintf('BUILT_BY_SAVED%s\n',[' Sonnet Matlab Interface v' num2str(SonnetMatlabVersion(false))])];
            end
            if (~isempty(obj.DateTheProjectWasSavedWithMediumImportanceChanges))
                aSignature = [aSignature sprintf('MDATE%s\n',obj.DateTheProjectWasSavedWithMediumImportanceChanges)];
            end
            if (~isempty(obj.DateTheProjectWasSavedWithHighImportanceChanges))
                aSignature = [aSignature sprintf('HDATE%s\n',obj.DateTheProjectWasSavedWithHighImportanceChanges)];
            end
            for iCounter=1:length(obj.UnknownLines)
                aSignature = [aSignature strrep(obj.UnknownLines{iCounter},'\n',sprintf('\n'))];
            end
            
            aSignature = [aSignature sprintf('END HEADER\n');];
            
        end
    end
end

