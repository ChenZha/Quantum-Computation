classdef SonnetDimensionBlock  < handle
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This class defines the DIM portion of a SONNET project file. This class
    % will store information pertaining to the selected units for measurements
    % of length, frequency, resistance, etc.
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
        
        FrequencyUnit
        InductanceUnit
        LengthUnit
        AngleUnit
        ConductivityUnit
        ResistanceUnit
        CapacitanceUnit        
        ResistivityUnit
        SheetResistanceUnit
        UnknownLines
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = SonnetDimensionBlock(theFid)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % The constructor for the DIM.
            %     the DIM will be passed the file ID from the
            %     SONNET project constructor.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if nargin == 1
                
                initialize(obj);	% Initialize the values of the properties using the initializer function
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % We are going to loop and read initial tags
                %		for all the lines in the DIM block and
                %		move to the appropriate case depending
                %		on the input.  This is necessary to
                %		allow for statements to be in different
                %		orders.
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                isKeepLooping=true;											% This boolean controls if we should stay in the reading loop.
                % We loop when true and quit when false.
                while(isKeepLooping)
                    
                    % Read a string from the file,  we will use this to determine what property needs to be modified by using a case statement.
                    aTempString=fscanf(theFid,'%s',1); 							% Read a Value from the file, we will be using this to drive the switch statment
                    
                    switch aTempString
                        
                        case 'FREQ'			% If the input was FREQ then we wil read the value and check the validity by comparing it to the allowed values
                            obj.FrequencyUnit=fscanf(theFid,'%s',1);
                            
                        case 'IND'			% If the input was IND then we wil read the value and check the validity by comparing it to the allowed values
                            obj.InductanceUnit=fscanf(theFid,'%s',1);
                            
                        case 'LNG'			% If the input was LNG then we wil read the value and check the validity by comparing it to the allowed values
                            obj.LengthUnit=fscanf(theFid,'%s',1);
                            
                        case 'ANG'			% If the input was ANG then we wil read the value and check the validity by comparing it to the allowed values
                            obj.AngleUnit=fscanf(theFid,'%s',1);
                            
                        case 'CON'			% If the input was CON then we wil read the value and check the validity by comparing it to the allowed values
                            obj.ConductivityUnit=fscanf(theFid,'%s',1);
                            
                        case 'CAP'			% If the input was CAP then we wil read the value and check the validity by comparing it to the allowed values
                            obj.CapacitanceUnit=fscanf(theFid,'%s',1);
                            
                        case 'RES'			% If the input was RES then we wil read the value and check the validity by comparing it to the allowed values
                            obj.ResistanceUnit=fscanf(theFid,'%s',1);
                        
                        case 'RSVY'			% If the input was RSVY then we wil read the value and check the validity by comparing it to the allowed values
                            obj.ResistivityUnit=fscanf(theFid,'%s',1);
                        
                        case 'SRES'			% If the input was SRES then we wil read the value and check the validity by comparing it to the allowed values
                            obj.SheetResistanceUnit=fscanf(theFid,'%s',1);
                            
                        case 'END'				% If the input was END then we are done with this block and can move on to the next block
                            fgetl(theFid);		% get the rest of the line.  Now the file id should be after the DIM block and ready for the next block
                            isKeepLooping=false;	% Indicate that we should stop looping.
                            
                        case '\n'				% If the input was \n then do nothing; just go back to the top of the loop.
                            continue;
                            
                        otherwise
                            obj.UnknownLines = [obj.UnknownLines aTempString fgetl(theFid) '\n'];	% Add the line to the uknownlines array
                            
                    end
                end
                
            else
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % we come here when we didn't recieve a file ID as an argument
                % which means that we are going to create a default dim block with
                % default values by calling the function's initialize method.
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                initialize(obj);
                
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function initialize(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function initializes the dim properties to some default
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
            
            obj.FrequencyUnit='GHZ';
            obj.InductanceUnit='NH';
            obj.LengthUnit='MIL';
            obj.AngleUnit='DEG';
            obj.ConductivityUnit='/OH';
            obj.ResistanceUnit='OH';
            obj.CapacitanceUnit='PF';
            % Default values for Resistivity and Sheet Res are not stored
            % in the Sonnet Project File of Version 14
            % obj.ResistivityUnit='OHCM';
            % obj.SheetResistanceUnit='OHSQ';
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aNewObject=clone(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function builds a deep copy of this object
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            aNewObject=SonnetDimensionBlock();
            SonnetClone(obj,aNewObject);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function writeObjectContents(obj, theFid, theVersion) %#ok<INUSD>
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function writes the values from the object to a file.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            fprintf(theFid,'DIM\n');
            
            % If the value is defined print it out to the file
            if (~isempty(obj.FrequencyUnit))
                fprintf(theFid, 'FREQ %s\n',obj.FrequencyUnit);
            end
            
            if theVersion >= 14           
                if (~isempty(obj.ResistivityUnit))
                    fprintf(theFid, 'RSVY %s\n',obj.ResistivityUnit);
                end
                
                if (~isempty(obj.SheetResistanceUnit))
                    fprintf(theFid, 'SRES %s\n',obj.SheetResistanceUnit);
                end            
            end            
            
            if (~isempty(obj.InductanceUnit))
                fprintf(theFid, 'IND %s\n',obj.InductanceUnit);
            end
            if (~isempty(obj.LengthUnit))
                fprintf(theFid, 'LNG %s\n',obj.LengthUnit);
            end
            if (~isempty(obj.AngleUnit))
                fprintf(theFid, 'ANG %s\n',obj.AngleUnit);
            end
            if (~isempty(obj.ConductivityUnit))
                fprintf(theFid, 'CON %s\n',obj.ConductivityUnit);
            end
            if (~isempty(obj.CapacitanceUnit))
                fprintf(theFid, 'CAP %s\n',obj.CapacitanceUnit);
            end
            if (~isempty(obj.ResistanceUnit))
                fprintf(theFid, 'RES %s\n',obj.ResistanceUnit);
            end
            if (~isempty(obj.UnknownLines))
                fprintf(theFid, sprintf('%s',obj.UnknownLines));
            end
            
            fprintf(theFid,'END DIM\n');
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aSignature=stringSignature(obj,theVersion) %#ok<INUSD>
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function writes the values from the object to a string.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            aSignature = sprintf('DIM\n');
            
            % If the value is defined print it out to the file
            if (~isempty(obj.FrequencyUnit))
                aSignature = [aSignature sprintf('FREQ %s\n',obj.FrequencyUnit)];
            end
            
            if theVersion >= 14           
                if (~isempty(obj.ResistivityUnit))
                    aSignature = [aSignature sprintf('RSVY %s\n',obj.ResistivityUnit)];                    
                end
                
                if (~isempty(obj.SheetResistanceUnit))
                    aSignature = [aSignature sprintf('SRES %s\n',obj.SheetResistanceUnit)];
                end            
            end 
            
            if (~isempty(obj.InductanceUnit))
                aSignature = [aSignature sprintf('IND %s\n',obj.InductanceUnit)];
            end
            if (~isempty(obj.LengthUnit))
                aSignature = [aSignature sprintf('LNG %s\n',obj.LengthUnit)];
            end
            if (~isempty(obj.AngleUnit))
                aSignature = [aSignature sprintf('ANG %s\n',obj.AngleUnit)];
            end
            if (~isempty(obj.ConductivityUnit))
                aSignature = [aSignature sprintf('CON %s\n',obj.ConductivityUnit)];
            end
            if (~isempty(obj.CapacitanceUnit))
                aSignature = [aSignature sprintf('CAP %s\n',obj.CapacitanceUnit)];
            end
            if (~isempty(obj.ResistanceUnit))
                aSignature = [aSignature sprintf('RES %s\n',obj.ResistanceUnit)];
            end
            if (~isempty(obj.UnknownLines))
                aSignature = [aSignature strrep(obj.UnknownLines,'\n',sprintf('\n'))];
            end
            
            aSignature = [aSignature sprintf('END DIM\n')];
            
        end
        
        
    end
end

