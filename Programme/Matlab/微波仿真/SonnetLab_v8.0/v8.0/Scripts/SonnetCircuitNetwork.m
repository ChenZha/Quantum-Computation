classdef SonnetCircuitNetwork < handle
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This class defines a network element in the circuit (CKT) block
    % of a Sonnet Netlist project.
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
        
        ArrayOfPortNodeNumbers          
        Name                            
        
        % If the port was resistor
        Resistance
        
        % If the port had complex impedance
        %resistance
        ImaginaryResistance
        
        % If the port was TERM
        %Resistance
        Reactance
        
        % If the port was FTERM
        %Resistance
        %Reactance
        Inductance
        Capacitance
        
        PortType
        
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = SonnetCircuitNetwork(theFid,theNumberOfPorts)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % The constructor for Circuit network, this is defined
            % in the Circuit Block (CKT) entry in the Sonnet Project
            % File for Netlists.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if nargin == 2      % If we were passed 1 argument which means we got the theFid
                
                initialize(obj);
                
                for iCounter=1:theNumberOfPorts % Read in all the ports.
                    obj.ArrayOfPortNodeNumbers=[obj.ArrayOfPortNodeNumbers fscanf(theFid,' %d',1)];
                end
                
                obj.Name=fscanf(theFid,' %s',1); % Read in the name of the network
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Now we will read in the value for the ports; there are 4 types
                %   1)R resist
                %   2)Z rresist iresist
                %   3)TERM resist(1) react (1) resist(2) react(2) ... resist(n) react(n)
                %   4)FTERM resist(1) react(1) induct(1) cap(1) ... resist(n) react(n) induct(n) cap(n)
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                aTempString=fscanf(theFid,' %s',1); % read in the type of port
                
                switch aTempString
                    
                    case 'R'
                        obj.PortType='R';
                        obj.Resistance=fscanf(theFid,' %f',1);
                        
                    case 'Z'
                        obj.PortType='Z';
                        obj.Resistance=fscanf(theFid,' %f',1);
                        obj.ImaginaryResistance=fscanf(theFid,' %f',1);
                        
                    case 'TERM'
                        obj.PortType='TERM';
                        
                        isKeepLoopsing=true; % This boolean controls if we should read in more values from the statement. We want to go into the loop at least once so start out true.
                        
                        % This reads all the values on a particular line
                        while isKeepLoopsing == true                % If it is not a newline then there are more parameters
                            
                            obj.Resistance=[obj.Resistance fscanf(theFid,' %f',1)];
                            obj.Reactance=[obj.Reactance fscanf(theFid,' %f',1)];
                            
                            aBackupOfTheFid=ftell(theFid);                      % Store a backup of the file ID so that we can restore it afer we read the line
                            aTempString=fgetl(theFid);                          % read in the whole line so that we can determine if there is an ampersand on the line
                            fseek(theFid,aBackupOfTheFid,'bof');                % Restore the backup of the fid
                            
                            if isempty(strtrim(aTempString))                    % If there is nothing left on the line then we can stop reading in values
                                isKeepLoopsing=false;
                            elseif strcmp(strtrim(aTempString),'&')==1
                                fgets(theFid);                                    % Read in the rest of the line
                            end
                            
                        end
                        
                    case 'FTERM'
                        obj.PortType='FTERM';
                        
                        isKeepLoopsing=true; % This boolean controls if we should read in more values from the statement. We want to go into the loop at least once so start out true.
                        
                        % This reads all the values on a particular line
                        while isKeepLoopsing == true                % If it is not a newline then there are more parameters
                            
                            obj.Resistance=[obj.Resistance fscanf(theFid,' %f',1)];
                            obj.Reactance=[obj.Reactance fscanf(theFid,' %f',1)];
                            obj.Inductance=[obj.Inductance fscanf(theFid,' %f',1)];
                            obj.Capacitance=[obj.Capacitance fscanf(theFid,' %f',1)];
                            
                            aBackupOfTheFid=ftell(theFid);                      % Store a backup of the file ID so that we can restore it afer we read the line
                            aTempString=fgetl(theFid);                          % read in the whole line so that we can determine if there is an ampersand on the line
                            fseek(theFid,aBackupOfTheFid,'bof');                % Restore the backup of the fid
                            
                            if isempty(strtrim(aTempString))                    % If there is nothing left on the line then we can stop reading in values
                                isKeepLoopsing=false;
                            elseif strcmp(strtrim(aTempString),'&')==1
                                fgets(theFid);                                    % Read in the rest of the line
                            end
                            
                        end
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
            aNewObject=SonnetCircuitNetwork();
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
            
            aSignature=sprintf('DEF%dP',length(obj.ArrayOfPortNodeNumbers));
            
            for iCounter= 1:length(obj.ArrayOfPortNodeNumbers)
                aSignature=[aSignature sprintf(' %d',obj.ArrayOfPortNodeNumbers(iCounter))]; %#ok<AGROW>
            end
            
            aSignature=[aSignature sprintf(' %s',obj.Name)];          
            
            if strcmp(obj.PortType,'R')==1
                if isa(obj.Resistance,'char')
                    aSignature=[aSignature sprintf(' R %s\n\n',obj.Resistance)];
                else
                    aSignature=[aSignature sprintf(' R %.15g\n\n',obj.Resistance)];
                end
                
            elseif strcmp(obj.PortType,'Z')==1
                if isa(obj.Resistance,'char')
                    aSignature=[aSignature sprintf(' R %s',obj.Resistance)];
                else
                    aSignature=[aSignature sprintf(' R %.15g',obj.Resistance)];
                end
                if isa(obj.ImaginaryResistance,'char')
                    aSignature=[aSignature sprintf(' Z %s\n\n',obj.ImaginaryResistance)];
                else
                    aSignature=[aSignature sprintf(' Z %.15g\n\n',obj.ImaginaryResistance)];
                end
                
            elseif strcmp(obj.PortType,'TERM')==1
                aSignature=[aSignature ' TERM'];
                for iCounter=1:length(obj.Resistance)
                    if isa(obj.Resistance(iCounter),'char')
                        aSignature=[aSignature sprintf(' %s',obj.Resistance(iCounter))]; %#ok<AGROW>
                    else
                        aSignature=[aSignature sprintf(' %.15g',obj.Resistance(iCounter))]; %#ok<AGROW>
                    end
                    
                    if isa(obj.Reactance(iCounter),'char')
                        aSignature=[aSignature sprintf(' %s',obj.Reactance(iCounter))]; %#ok<AGROW>
                    else
                        aSignature=[aSignature sprintf(' %.15g',obj.Reactance(iCounter))]; %#ok<AGROW>
                    end
                end
                aSignature=[aSignature sprintf('\n\n')];
                
            else
                aSignature=[aSignature ' FTERM'];
                for iCounter=1:length(obj.Resistance)
                    if isa(obj.Resistance(iCounter),'char')
                        aSignature=[aSignature sprintf(' %s',obj.Resistance(iCounter))]; %#ok<AGROW>
                    else
                        aSignature=[aSignature sprintf(' %.15g',obj.Resistance(iCounter))]; %#ok<AGROW>
                    end
                    
                    if isa(obj.Reactance(iCounter),'char')
                        aSignature=[aSignature sprintf(' %s',obj.Reactance(iCounter))]; %#ok<AGROW>
                    else
                        aSignature=[aSignature sprintf(' %.15g',obj.Reactance(iCounter))]; %#ok<AGROW>
                    end
                    
                    if isa(obj.Inductance(iCounter),'char')
                        aSignature=[aSignature sprintf(' %s',obj.Inductance(iCounter))]; %#ok<AGROW>
                    else
                        aSignature=[aSignature sprintf(' %.15g',obj.Inductance(iCounter))]; %#ok<AGROW>
                    end
                    
                    if isa(obj.Capacitance(iCounter),'char')
                        aSignature=[aSignature sprintf(' %s',obj.Capacitance(iCounter))]; %#ok<AGROW>
                    else
                        aSignature=[aSignature sprintf(' %.15g',obj.Capacitance(iCounter))]; %#ok<AGROW>
                    end
                    
                end
                aSignature=[aSignature sprintf('\n\n')];               
                
            end
            
        end
        
    end
    
end
