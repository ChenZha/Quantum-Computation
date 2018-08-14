classdef SonnetCircuitBlock  < handle
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This class defines the Circuit portion of a SONNET netlist project file.
    % This class is a container for arrays of all the circuit elements
    % contained in a netlist project.
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
        
        ArrayOfResistorElements
        ArrayOfInductorElements
        ArrayOfCapacitorElements
        ArrayOfTransmissionLineElements
        ArrayOfPhysicalTransmissionLineElements
        ArrayOfDataResponseFileElements
        ArrayOfProjectFileElements
        ArrayOfNetworkElements
        ArrayOfRLGCElements
        
        UnknownLines
        
    end
    
    properties (SetAccess = private, GetAccess = private)
        temp
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = SonnetCircuitBlock(theFid)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % The constructor for the circuit block.
            %     the Circuit will be passed the file ID from the
            %     SONNET project constructor.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if nargin == 1
                
                initialize(obj);
                
                % Initialize all the element arrays
                aArrayOfNetworkElements={};
                aArrayOfResistorElements={};
                aArrayOfInductorElements={};
                aArrayOfCapacitorElements={};
                aArrayOfTransmissionLineElements={};
                aArrayOfPhysicalTransmissionLineElements={};
                aArrayOfDataResponseFileElements={};
                aArrayOfProjectFileElements={};
                aArrayOfRLGCElements={};
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % In a loop we will read the name
                %  of the element from the file and make an
                %  object out of its information. Different
                %  elements have different classes.
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                % Read the type for the first circuit element
                aTempString=fscanf(theFid,'%s',1);
                
                % Keeps track of what network new elements should be added to
                aNetworkNumber=1;
                
                while (strcmp(aTempString,'END')==0)   % Check if the input was 'END', if we find it we can stop looping
                    
                    if (strcmp(aTempString,'RES')==1)
                        % Make a new resistor and add it to the array
                        aSizeOfArray=length(aArrayOfResistorElements)+1;
                        aArrayOfResistorElements{aSizeOfArray}=SonnetCircuitResistor(theFid,aNetworkNumber); %#ok<AGROW>
                        
                    elseif (strcmp(aTempString,'IND')==1)
                        % Make a new inductor and add it to the array
                        aSizeOfArray=length(aArrayOfInductorElements)+1;
                        aArrayOfInductorElements{aSizeOfArray}=SonnetCircuitInductor(theFid,aNetworkNumber); %#ok<AGROW>
                        
                    elseif (strcmp(aTempString,'CAP')==1)
                        % Make a new capacitor and add it to the array
                        aSizeOfArray=length(aArrayOfCapacitorElements)+1;
                        aArrayOfCapacitorElements{aSizeOfArray}=SonnetCircuitCapacitor(theFid,aNetworkNumber); %#ok<AGROW>
                        
                    elseif (strcmp(aTempString,'TLIN')==1)
                        % Make a new transmission line and add it to the array
                        aSizeOfArray=length(aArrayOfTransmissionLineElements)+1;
                        aArrayOfTransmissionLineElements{aSizeOfArray}=SonnetCircuitTransmissionLine(theFid,aNetworkNumber); %#ok<AGROW>
                        
                    elseif (strcmp(aTempString,'TLINP')==1)
                        % Make a new physical transmission line and add it to the array
                        aSizeOfArray=length(aArrayOfPhysicalTransmissionLineElements)+1;
                        aArrayOfPhysicalTransmissionLineElements{aSizeOfArray}=SonnetCircuitPhysicalTransmissionLine(theFid,aNetworkNumber); %#ok<AGROW>
                        
                    elseif (strcmp(aTempString(1),'S')==1)
                        % Make a new data response element and add it to the array
                        aSizeOfArray=length(aArrayOfDataResponseFileElements)+1;
                        aTempString=strrep(aTempString,'S','');
                        aTempString=strrep(aTempString,'P','');
                        aArrayOfDataResponseFileElements{aSizeOfArray}=SonnetCircuitSnp(theFid,str2double(aTempString),aNetworkNumber); %#ok<AGROW>
                        
                    elseif (strcmp(aTempString,'PRJ')==1)
                        % Make a new project element and add it to the array
                        aSizeOfArray=length(aArrayOfProjectFileElements)+1;
                        aArrayOfProjectFileElements{aSizeOfArray}=SonnetCircuitProject(theFid,aNetworkNumber); %#ok<AGROW>
                        
                    elseif (strcmp(aTempString(1),'D')==1) && (strcmp(aTempString(2),'E')==1) && (strcmp(aTempString(3),'F')==1) && ~isempty(str2double(aTempString(4)))
                        % Get the number of ports for the network
                        aTempString(1:3)='';
                        aNumberOfPorts=sscanf(aTempString,'%d');
                        
                        % Make the new network
                        aArrayOfNetworkElements{aNetworkNumber}=SonnetCircuitNetwork(theFid,aNumberOfPorts); %#ok<AGROW>
                        
                        % Increment the network counter; Elements following
                        % this will be part of the next network
                        aNetworkNumber=aNetworkNumber+1;
                     
                    elseif (strcmp(aTempString,'RLGC')==1)
                                                                       
                        aSizeOfArray=length(aArrayOfRLGCElements)+1;
                        aArrayOfRLGCElements{aSizeOfArray}=SonnetCircuitRLGC(theFid);
                                                
                    else
                        obj.UnknownLines = [obj.UnknownLines aTempString fgetl(theFid) '\n'];	% Add the line to the uknownlines array
                        
                    end
                    
                    aTempString=fscanf(theFid,'%s',1);
                    
                end
                
                % Assign the local arrays to the object's properties
                obj.ArrayOfResistorElements=aArrayOfResistorElements;
                obj.ArrayOfInductorElements=aArrayOfInductorElements;
                obj.ArrayOfCapacitorElements=aArrayOfCapacitorElements;
                obj.ArrayOfTransmissionLineElements=aArrayOfTransmissionLineElements;
                obj.ArrayOfPhysicalTransmissionLineElements=aArrayOfPhysicalTransmissionLineElements;
                obj.ArrayOfDataResponseFileElements=aArrayOfDataResponseFileElements;
                obj.ArrayOfProjectFileElements=aArrayOfProjectFileElements;
                obj.ArrayOfNetworkElements=aArrayOfNetworkElements;
                obj.ArrayOfRLGCElements=aArrayOfRLGCElements;
                                
                % Read the rest of the line we are on to
                % get the theFid ready for the next block.
                fgetl(theFid);
                
            else
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % we come here when we didn't recieve a file ID as an argument
                % which means that we are going to create a default Circuit block with
                % default values by calling the function's initialize method.
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                initialize(obj);
                
            end
            
        end
               
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function initialize(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function initializes the Circuit properties to some default
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
            
            % Add in the default network
            obj.addNetworkElement('DEF2P',[1 2],50);
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aNewObject=clone(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function builds a deep copy of this object
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            aNewObject=SonnetCircuitBlock();
            SonnetClone(obj,aNewObject);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function writeObjectContents(obj, theFid, theVersion)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function writes the values from the object to a file.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            fprintf(theFid,'CKT\n');
                                    
            % Call the writeObjectContents function in each of the objects that we have in our cell array
            % if they are in the specified network
            for iCounter= 1:size(obj.ArrayOfRLGCElements, 2)
                obj.ArrayOfRLGCElements{iCounter}.writeObjectContents(theFid,theVersion);                    
            end
            
            % If any of the circuit elements does not have a
            % network number associated with it then make that
            % network number be 1 to indicate that it is part
            % of the first network.
            for jCounter=1:length(obj.ArrayOfNetworkElements)
                if ~isa(obj.ArrayOfNetworkElements{jCounter},'SonnetCircuitNetwork') && isempty(obj.ArrayOfNetworkElements{jCounter}.NetworkIndex)
                    obj.ArrayOfNetworkElements{jCounter}.NetworkIndex=1;
                end
            end
            
            % We want to print out all the elements contained in each network
            for jCounter=1:length(obj.ArrayOfNetworkElements)
                
                % Call the writeObjectContents function in each of the objects that we have in our cell array
                % if they are in the specified network
                for iCounter= 1:size(obj.ArrayOfResistorElements,2)
                    if obj.ArrayOfResistorElements{iCounter}.NetworkIndex == jCounter
                        obj.ArrayOfResistorElements{iCounter}.writeObjectContents(theFid,theVersion);
                    end
                end
                
                % Call the writeObjectContents function in each of the objects that we have in our cell array
                % if they are in the specified network
                for iCounter= 1:size(obj.ArrayOfInductorElements,2)
                    if obj.ArrayOfInductorElements{iCounter}.NetworkIndex == jCounter
                        obj.ArrayOfInductorElements{iCounter}.writeObjectContents(theFid,theVersion);
                    end
                end
                
                % Call the writeObjectContents function in each of the objects that we have in our cell array
                % if they are in the specified network
                for iCounter= 1:size(obj.ArrayOfCapacitorElements,2)
                    if obj.ArrayOfCapacitorElements{iCounter}.NetworkIndex == jCounter
                        obj.ArrayOfCapacitorElements{iCounter}.writeObjectContents(theFid,theVersion);
                    end
                end
                
                % Call the writeObjectContents function in each of the objects that we have in our cell array
                % if they are in the specified network
                for iCounter= 1:size(obj.ArrayOfTransmissionLineElements,2)
                    if obj.ArrayOfTransmissionLineElements{iCounter}.NetworkIndex == jCounter
                        obj.ArrayOfTransmissionLineElements{iCounter}.writeObjectContents(theFid,theVersion);
                    end
                end
                
                % Call the writeObjectContents function in each of the objects that we have in our cell array
                % if they are in the specified network
                for iCounter= 1:size(obj.ArrayOfPhysicalTransmissionLineElements,2)
                    if obj.ArrayOfPhysicalTransmissionLineElements{iCounter}.NetworkIndex == jCounter
                        obj.ArrayOfPhysicalTransmissionLineElements{iCounter}.writeObjectContents(theFid,theVersion);
                    end
                end
                
                % Call the writeObjectContents function in each of the objects that we have in our cell array
                % if they are in the specified network
                for iCounter= 1:size(obj.ArrayOfDataResponseFileElements,2)
                    if obj.ArrayOfDataResponseFileElements{iCounter}.NetworkIndex == jCounter
                        obj.ArrayOfDataResponseFileElements{iCounter}.writeObjectContents(theFid,theVersion);
                    end
                end
                
                % Call the writeObjectContents function in each of the objects that we have in our cell array
                % if they are in the specified network
                for iCounter= 1:size(obj.ArrayOfProjectFileElements,2)
                    if obj.ArrayOfProjectFileElements{iCounter}.NetworkIndex == jCounter
                        obj.ArrayOfProjectFileElements{iCounter}.writeObjectContents(theFid,theVersion);
                    end
                end                
                
                % Call the writeObjectContents function for the network
                obj.ArrayOfNetworkElements{jCounter}.writeObjectContents(theFid,theVersion);
                
            end
            
            if (~isempty(obj.UnknownLines))
                fprintf(theFid, sprintf('%s',obj.UnknownLines));
            end
            
            fprintf(theFid,'END CKT\n');
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aSignature=stringSignature(obj,theVersion) %#ok<INUSD>
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function writes the values from the object to a string.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            aSignature = sprintf('CKT\n');
            
            % If any of the circuit elements does not have a
            % network number associated with it then make that
            % network number be 1 to indicate that it is part
            % of the first network.
            for jCounter=1:length(obj.ArrayOfNetworkElements)
                if ~isa(obj.ArrayOfNetworkElements{jCounter},'SonnetCircuitNetwork') && isempty(obj.ArrayOfNetworkElements{jCounter}.NetworkIndex)
                    obj.ArrayOfNetworkElements{jCounter}.NetworkIndex=1;
                end
            end
            
            % We want to print out all the elements contained in each network
            for jCounter=1:length(obj.ArrayOfNetworkElements)
                
                % Call the stringSignature function in each of the objects that we have in our cell array
                % if they are in the specified network
                for iCounter= 1:length(obj.ArrayOfResistorElements)
                    if obj.ArrayOfResistorElements{iCounter}.NetworkIndex == jCounter
                        aSignature = [aSignature obj.ArrayOfResistorElements{iCounter}.stringSignature(theVersion)]; %#ok<AGROW>
                    end
                end
                
                % Call the stringSignature function in each of the objects that we have in our cell array
                % if they are in the specified network
                for iCounter= 1:length(obj.ArrayOfInductorElements)
                    if obj.ArrayOfInductorElements{iCounter}.NetworkIndex == jCounter
                        aSignature = [aSignature obj.ArrayOfInductorElements{iCounter}.stringSignature(theVersion)]; %#ok<AGROW>
                    end
                end
                
                % Call the stringSignature function in each of the objects that we have in our cell array
                % if they are in the specified network
                for iCounter= 1:length(obj.ArrayOfCapacitorElements)
                    if obj.ArrayOfCapacitorElements{iCounter}.NetworkIndex == jCounter
                        aSignature = [aSignature obj.ArrayOfCapacitorElements{iCounter}.stringSignature(theVersion)]; %#ok<AGROW>
                    end
                end
                
                % Call the stringSignature function in each of the objects that we have in our cell array
                % if they are in the specified network
                for iCounter= 1:length(obj.ArrayOfTransmissionLineElements)
                    if obj.ArrayOfTransmissionLineElements{iCounter}.NetworkIndex == jCounter
                        aSignature = [aSignature obj.ArrayOfTransmissionLineElements{iCounter}.stringSignature(theVersion)]; %#ok<AGROW>
                    end
                end
                
                % Call the stringSignature function in each of the objects that we have in our cell array
                % if they are in the specified network
                for iCounter= 1:length(obj.ArrayOfPhysicalTransmissionLineElements)
                    if obj.ArrayOfPhysicalTransmissionLineElements{iCounter}.NetworkIndex == jCounter
                        aSignature = [aSignature obj.ArrayOfPhysicalTransmissionLineElements{iCounter}.stringSignature(theVersion)]; %#ok<AGROW>
                    end
                end
                
                % Call the stringSignature function in each of the objects that we have in our cell array
                % if they are in the specified network
                for iCounter= 1:length(obj.ArrayOfDataResponseFileElements)
                    if obj.ArrayOfDataResponseFileElements{iCounter}.NetworkIndex == jCounter
                        aSignature = [aSignature obj.ArrayOfDataResponseFileElements{iCounter}.stringSignature(theVersion)]; %#ok<AGROW>
                    end
                end
                
                % Call the stringSignature function in each of the objects that we have in our cell array
                % if they are in the specified network
                for iCounter= 1:length(obj.ArrayOfProjectFileElements)
                    if obj.ArrayOfProjectFileElements{iCounter}.NetworkIndex == jCounter
                        aSignature = [aSignature obj.ArrayOfProjectFileElements{iCounter}.stringSignature(theVersion)]; %#ok<AGROW>
                    end
                end
                
                % Call the stringSignature function for the network
                aSignature = [aSignature obj.ArrayOfNetworkElements{jCounter}.stringSignature(theVersion)]; %#ok<AGROW>
                
            end
            
            if (~isempty(obj.UnknownLines))
                aSignature = [aSignature strrep(obj.UnknownLines,'\n',sprintf('\n'))];
            end
            
            aSignature = [aSignature sprintf('END CKT\n')];
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function insertInList(obj, theElement, theIndex)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Inserts a value into the temp property
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if theElement.NetworkIndex == theIndex
                obj.temp{length(obj.temp)+1}=theElement;
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aArrayOfElements=getNetworkElements(obj,theNetwork)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function will return a structure of for each
            % network in the project with all of its elements.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Find the associated network
            if isa(theNetwork,'char')
                isFound=false;
                for iCounter=1:length(obj.ArrayOfNetworkElements)
                    if strcmpi(obj.ArrayOfNetworkElements{iCounter}.Name,theNetwork)==1
                        aIndex=iCounter;
                        isFound=true;
                        break;
                    end
                end
                
                % If we didnt find the matching network then throw an error
                if ~isFound
                    error('Unknown network specified to getNetworkElements');
                end
            else
                aIndex=theNetwork;
                
                % If the specified network index is out of the range then
                % throw an error.
                if aIndex<1 || aIndex>length(obj.ArrayOfNetworkElements)
                    error('Value for polygon index is outside the range of networks');
                end
            end
            
            % Preallocate for speed
            obj.temp={};
            
            % Search for elements in the network
            cellfun(@(x) obj.insertInList(x,aIndex),obj.ArrayOfResistorElements);
            cellfun(@(x) obj.insertInList(x,aIndex),obj.ArrayOfInductorElements);
            cellfun(@(x) obj.insertInList(x,aIndex),obj.ArrayOfCapacitorElements);
            cellfun(@(x) obj.insertInList(x,aIndex),obj.ArrayOfTransmissionLineElements);
            cellfun(@(x) obj.insertInList(x,aIndex),obj.ArrayOfPhysicalTransmissionLineElements);
            cellfun(@(x) obj.insertInList(x,aIndex),obj.ArrayOfDataResponseFileElements);
            cellfun(@(x) obj.insertInList(x,aIndex),obj.ArrayOfProjectFileElements);
            aArrayOfElements=obj.temp;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addResistorElement(obj,theNodeNumber1,theNodeNumber2,theResistanceValue,theNetworkNumber)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function will add an resistor element to the circuit
            % It takes the following parameters:
            %     1) The first node number that the resistor is connected to
            %     2) The second node number that the resistor is connected to
            %     3) The value for the resistance
            %     4) (Optional) The index of the network in the array of networks
            %           If this isn't specified the element will be added to the
            %           first network. Alternatively the name of the
            %           network can be supplied instead of the index.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Construct an empty element
            aElement=SonnetCircuitResistor();
            
            % Modify the values for the resistor element
            aElement.NodeNumber1      =   theNodeNumber1;
            aElement.NodeNumber2      =   theNodeNumber2;
            aElement.ResistanceValue  =   theResistanceValue;
            
            % If we recieved the network number then set it to theNetworkNumber.
            % If we did not recieve the network number then set it to 1.
            if nargin == 5
                if isa(theNetworkNumber,'char')
                    aIndex=0;
                    
                    % Look for the specified network name in the array of networks
                    for iCounter=1:length(obj.ArrayOfNetworkElements)
                        if strcmp(obj.ArrayOfNetworkElements{iCounter}.Name,theNetworkNumber)==1
                            aIndex=iCounter;
                        end
                    end
                    
                    % If we didnt find a match for the network name then throw an error
                    if aIndex==0
                        error('Attempting to add circuit element to an unknown network');
                    end
                    
                    aElement.NetworkIndex = aIndex;
                    
                else
                    % Add the element to the specified network
                    aElement.NetworkIndex = theNetworkNumber;
                end
            else
                % If no network number was specified then add the element
                % to the first network.
                aElement.NetworkIndex = 1;
            end
            
            % Put the element in the array
            obj.ArrayOfResistorElements{length(obj.ArrayOfResistorElements)+1}=aElement;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addInductorElement(obj,theNodeNumber1,theNodeNumber2,theInductanceValue,theNetworkNumber)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function will add an inductor element to the circuit
            % It takes the following parameters:
            %     1) The first node number that the inductor is connected to
            %     2) The second node number that the inductor is connected to
            %     3) The value for the inductance
            %     4) (Optional) The index of the network in the array of networks
            %           If this isn't specified the element will be added to the
            %           first network.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Construct an empty element
            aElement=SonnetCircuitInductor();
            
            % Modify the values for the inductor element
            aElement.NodeNumber1      =   theNodeNumber1;
            aElement.NodeNumber2      =   theNodeNumber2;
            aElement.InductanceValue  =   theInductanceValue;
            
            % If we recieved the network number then set it to theNetworkNumber.
            % If we did not recieve the network number then set it to 1.
            if nargin == 5
                if isa(theNetworkNumber,'char')
                    aIndex=0;
                    
                    % Look for the specified network name in the array of networks
                    for iCounter=1:length(obj.ArrayOfNetworkElements)
                        if strcmp(obj.ArrayOfNetworkElements{iCounter}.Name,theNetworkNumber)==1
                            aIndex=iCounter;
                        end
                    end
                    
                    % If we didnt find a match for the network name then throw an error
                    if aIndex==0
                        error('Attempting to add circuit element to an unknown network');
                    end
                    
                    aElement.NetworkIndex = aIndex;
                    
                else
                    % Add the element to the specified network
                    aElement.NetworkIndex = theNetworkNumber;
                end
            else
                % If no network number was specified then add the element
                % to the first network.
                aElement.NetworkIndex = 1;
            end
            
            % Put the element in the array
            obj.ArrayOfInductorElements{length(obj.ArrayOfInductorElements)+1}=aElement;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addCapacitorElement(obj,theNodeNumber1,theNodeNumber2,theCapacitanceValue,theNetworkNumber)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function will add an capacitor element to the circuit
            % It takes the following parameters:
            %     1) The first node number that the capacitor is connected to
            %     2) The second node number that the capacitor is connected to
            %     3) The value for the capacitance
            %     4) (Optional) The index of the network in the array of networks
            %           If this isn't specified the element will be added to the
            %           first network.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Construct an empty element
            aElement=SonnetCircuitCapacitor();
            
            % Modify the values for the capacitor element
            aElement.NodeNumber1      =   theNodeNumber1;
            aElement.NodeNumber2      =   theNodeNumber2;
            aElement.CapacitanceValue =   theCapacitanceValue;
            
            % If we recieved the network number then set it to theNetworkNumber.
            % If we did not recieve the network number then set it to 1.
            if nargin == 5
                if isa(theNetworkNumber,'char')
                    aIndex=0;
                    
                    % Look for the specified network name in the array of networks
                    for iCounter=1:length(obj.ArrayOfNetworkElements)
                        if strcmp(obj.ArrayOfNetworkElements{iCounter}.Name,theNetworkNumber)==1
                            aIndex=iCounter;
                        end
                    end
                    
                    % If we didnt find a match for the network name then throw an error
                    if aIndex==0
                        error('Attempting to add circuit element to an unknown network');
                    end
                    
                    aElement.NetworkIndex = aIndex;
                    
                else
                    % Add the element to the specified network
                    aElement.NetworkIndex = theNetworkNumber;
                end
            else
                % If no network number was specified then add the element
                % to the first network.
                aElement.NetworkIndex = 1;
            end
            
            % Put the element in the array
            obj.ArrayOfCapacitorElements{length(obj.ArrayOfCapacitorElements)+1}=aElement;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addTransmissionLineElement(obj,theNodeNumber1,theNodeNumber2,...
                theimpedanceValue,theLengthValue,theFrequencyValue,theNetworkNumber)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function will add an transmission line to the circuit
            % It takes the following parameters:
            %     1) The first node number that the line is connected to
            %     2) The second node number that the line is connected to
            %     3) The value for the impedance of the line
            %     4) The value for the length of the line
            %     5) The value for the frequency of the line
            %     6) (Optional) The index of the network in the array of networks
            %           If this isn't specified the element will be added to the
            %           first network.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Construct an empty element
            aElement=SonnetCircuitTransmissionLine();
            
            % Modify the values for the transmission line
            aElement.NodeNumber1    =   theNodeNumber1;
            aElement.NodeNumber2    =   theNodeNumber2;
            aElement.ImpedanceValue =   theimpedanceValue;
            aElement.LengthValue    =   theLengthValue;
            aElement.FrequencyValue =   theFrequencyValue;
            
            % If we recieved the network number then set it to theNetworkNumber.
            % If we did not recieve the network number then set it to 1.
            if nargin == 7
                if isa(theNetworkNumber,'char')
                    aIndex=0;
                    
                    % Look for the specified network name in the array of networks
                    for iCounter=1:length(obj.ArrayOfNetworkElements)
                        if strcmp(obj.ArrayOfNetworkElements{iCounter}.Name,theNetworkNumber)==1
                            aIndex=iCounter;
                        end
                    end
                    
                    % If we didnt find a match for the network name then throw an error
                    if aIndex==0
                        error('Attempting to add circuit element to an unknown network');
                    end
                    
                    aElement.NetworkIndex = aIndex;
                    
                else
                    % Add the element to the specified network
                    aElement.NetworkIndex = theNetworkNumber;
                end
            else
                % If no network number was specified then add the element
                % to the first network.
                aElement.NetworkIndex = 1;
            end
            
            % Put the element in the array
            obj.ArrayOfTransmissionLineElements{length(obj.ArrayOfTransmissionLineElements)+1}=aElement;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addPhysicalTransmissionLineElement(obj,theNodeNumber1,theNodeNumber2,...
                theimpedanceValue,theLengthValue,theFrequencyValue,...
                theEeffValue,theAttenuationValue,theNetworkNumber,theGroundNode)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function will add an physical transmission line to the circuit
            % It takes the following parameters:
            %     1) The first node number that the line is connected to
            %     2) The second node number that the line is connected to
            %     3) The value for the impedance of the line
            %     4) The value for the length of the line
            %     5) The value for the frequency of the line
            %     6) The value for the eeff of the line
            %     7) The value for the attenuation of the line
            %     8) (Optional) The index of the network in the array of networks
            %           If this isn't specified the element will be added to the
            %           first network.
            %     9) (optional) The node number that acts as ground for the line
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Construct an empty element
            aElement=SonnetCircuitPhysicalTransmissionLine();
            
            % if we didnt get the ground node make it the empty set
            if nargin<10
                theGroundNode=[];
            end
            
            % Modify the values for the transmission line
            aElement.NodeNumber1       =   theNodeNumber1;
            aElement.NodeNumber2       =   theNodeNumber2;
            aElement.ImpedanceValue    =   theimpedanceValue;
            aElement.LengthValue       =   theLengthValue;
            aElement.FrequencyValue    =   theFrequencyValue;
            aElement.EeffValue         =   theEeffValue;
            aElement.AttenuationValue  =   theAttenuationValue;
            aElement.GroundNode        =   theGroundNode;
            
            % If we recieved the network number then set it to theNetworkNumber.
            % If we did not recieve the network number then set it to 1.
            if nargin >=9
                if isa(theNetworkNumber,'char')
                    aIndex=0;
                    
                    % Look for the specified network name in the array of networks
                    for iCounter=1:length(obj.ArrayOfNetworkElements)
                        if strcmp(obj.ArrayOfNetworkElements{iCounter}.Name,theNetworkNumber)==1
                            aIndex=iCounter;
                        end
                    end
                    
                    % If we didnt find a match for the network name then throw an error
                    if aIndex==0
                        error('Attempting to add circuit element to an unknown network');
                    end
                    
                    aElement.NetworkIndex = aIndex;
                    
                else
                    % Add the element to the specified network
                    aElement.NetworkIndex = theNetworkNumber;
                end
            else
                % If no network number was specified then add the element
                % to the first network.
                aElement.NetworkIndex = 1;
            end
            
            % Put the element in the array
            obj.ArrayOfPhysicalTransmissionLineElements{length(obj.ArrayOfPhysicalTransmissionLineElements)+1}=aElement;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addDataResponseFileElement(obj,theFilename,theArrayOfPortNodeNumbers,theNetworkNumber,theGroundReference)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function will add an SnP file to the circuit
            % It takes the following parameters:
            %     1) The filename for the SnP file
            %     2) The vector of port numbers
            %     3) (Optional) The index of the network in the array of networks
            %           If this isn't specified the element will be added to the
            %           first network.
            %     4) (Optional) The node number that acts as ground for the line
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Construct an empty element
            aElement=SonnetCircuitSnp();
            
            % if we didnt get the ground node make it the empty set
            if nargin < 5
                theGroundReference=[];
            end
            
            % Modify the values for the data response element
            aElement.ArrayOfPortNodeNumbers  =   theArrayOfPortNodeNumbers;
            aElement.GroundReference         =   theGroundReference;
            aElement.Filename                =   theFilename;
            
            % If we recieved the network number then set it to theNetworkNumber.
            % If we did not recieve the network number then set it to 1.
            if nargin >= 4
                if isa(theNetworkNumber,'char')
                    aIndex=0;
                    
                    % Look for the specified network name in the array of networks
                    for iCounter=1:length(obj.ArrayOfNetworkElements)
                        if strcmp(obj.ArrayOfNetworkElements{iCounter}.Name,theNetworkNumber)==1
                            aIndex=iCounter;
                        end
                    end
                    
                    % If we didnt find a match for the network name then throw an error
                    if aIndex==0
                        error('Attempting to add circuit element to an unknown network');
                    end
                    
                    aElement.NetworkIndex = aIndex;
                    
                else
                    % Add the element to the specified network
                    aElement.NetworkIndex = theNetworkNumber;
                end
            else
                % If no network number was specified then add the element
                % to the first network.
                aElement.NetworkIndex = 1;
            end
            
            % Put the element in the array
            obj.ArrayOfDataResponseFileElements{length(obj.ArrayOfDataResponseFileElements)+1}=aElement;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addProjectFileElement(obj,theFilename,theArrayOfPortNodeNumbers,theUseSweepFromSubproject,theNetworkNumber)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function will add an project file to the circuit
            % It takes the following parameters:
            %     1) The filename for the project file
            %     2) The vector of port numbers
            %     3) Either 0 or 1. 0 to indicate that you use the sweep
            %         from this project or 1 to indicate that you use
            %         the sweep from the subproject.
            %     4) The date
            %     5) (Optional) The index of the network in the array of networks
            %           If this isn't specified the element will be added to the
            %           first network.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Construct an empty element
            aElement=SonnetCircuitProject();
            
            % Modify the values for the file element
            aElement.ArrayOfPortNodeNumbers  =   theArrayOfPortNodeNumbers;
            aElement.Filename                =   theFilename;
            aElement.UseSweepFromSubproject  =   theUseSweepFromSubproject;
            
            % If we recieved the network number then set it to theNetworkNumber.
            % If we did not recieve the network number then set it to 1.
            if nargin == 5
                if isa(theNetworkNumber,'char')
                    aIndex=0;
                    
                    % Look for the specified network name in the array of networks
                    for iCounter=1:length(obj.ArrayOfNetworkElements)
                        if strcmp(obj.ArrayOfNetworkElements{iCounter}.Name,theNetworkNumber)==1
                            aIndex=iCounter;
                        end
                    end
                    
                    % If we didnt find a match for the network name then throw an error
                    if aIndex==0
                        error('Attempting to add circuit element to an unknown network');
                    end
                    
                    aElement.NetworkIndex = aIndex;
                    
                else
                    % Add the element to the specified network
                    aElement.NetworkIndex = theNetworkNumber;
                end
            else
                % If no network number was specified then add the element
                % to the first network.
                aElement.NetworkIndex = 1;
            end
            
            % Put the element in the array
            obj.ArrayOfProjectFileElements{length(obj.ArrayOfProjectFileElements)+1}=aElement;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addNetworkElement(obj,theName,theArrayOfPortNodeNumbers,theargument3, theargument4)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function will add an network element to the circuit
            % It takes the following parameters:
            %     1) The name for the new network
            %     2) The vector of port numbers
            %
            % And then also include one of the following:
            %
            %   If you want to define a single real impedance for all the ports then:
            %     3) the impedance
            %
            %   If you want to define a single non-real impedance for all the ports then:
            %     3) the real component of the impedance
            %     4) the imaginary component of the impedance
            %
            %   If you want to define different resistances and reactances for each port
            %       then pass the following for an N dimensional network:
            %     3) An  N x 2  matrix with the first column being the
            %           resistance of the port and the second number
            %           being the reactance of the port. Each row in
            %           the matrix should correspond to a single port
            %           and be specified in the same order as was
            %           specified in the second argument which was
            %           an vector of port numbers.
            %
            %   If a port or ports in the circuit have non-zero values for either the
            %       inductance or capacitance then pass the following:
            %     3) An  N x 4  matrix with the first column being the
            %           resistance of the port, the second number
            %           being the reactance of the port,the third column
            %           is for the inductance of the port and the fourth
            %           is for the capacitance of the port. Each row in
            %           the matrix should correspond to a single port
            %           and be specified in the same order as was
            %           specified in the second argument which was
            %           an vector of port numbers.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Construct an empty element
            aElement=SonnetCircuitNetwork();
            
            % Determine the port type
            if nargin == 5
                aElement.PortType                =   'Z';
                aElement.Resistance              =   theargument3;
                aElement.ImaginaryResistance     =   theargument4;
                
            elseif nargin ~= 4
                error('Improper number of arguments, see help for this function.');
                
            elseif length(theargument3)==1
                aElement.PortType                =   'R';
                aElement.Resistance              =   theargument3;
                
            elseif length(theargument3)==2
                aElement.PortType                =   'TERM';
                aElement.Resistance              =   theargument3(:,1);
                aElement.Reactance               =   theargument3(:,2);
                
            elseif length(theargument3)==4
                aElement.PortType                =   'FTERM';
                aElement.Resistance              =   theargument3(:,1);
                aElement.Reactance               =   theargument3(:,2);
                aElement.Inductance              =   theargument3(:,3);
                aElement.Capacitance             =   theargument3(:,4);
                
            else
                error('Improper number of arguments, see help for this function.');
                
            end
            
            % Modify the values for the network element
            aElement.ArrayOfPortNodeNumbers  =   theArrayOfPortNodeNumbers;
            aElement.Name                    =   theName;
            
            % Put the element in the array
            obj.ArrayOfNetworkElements{length(obj.ArrayOfNetworkElements)+1}=aElement;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addRLGCElment(obj, theDatFileName, theLength, theArrayOfPortNodes)
            %%%%%%%%%%%%%%e%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function will add an RLGC Element to the circuit
            % It takes the following parameters:
            %     1) The theDatFileName for the day file
            %     2) The Length
            %     3) The Array of port nodes
            %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            aSizeOfArray=length(obj.ArrayOfRLGCElements)+1;
            obj.ArrayOfRLGCElements{aSizeOfArray}=SonnetCircuitRLGC();
             
            obj.ArrayOfRLGCElements{aSizeOfArray}.DatFileName=theDatFileName;
            obj.ArrayOfRLGCElements{aSizeOfArray}.ArrayOfPortNodes=theArrayOfPortNodes;
            obj.ArrayOfRLGCElements{aSizeOfArray}.Length=theLength;
            
        end
        
        
    end
    
end

