classdef SonnetCircuitInductor < handle
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This class defines an inductor element in the circuit (CKT) block
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
        
        NodeNumber1         % The node number that one end of the inductor is connected to
        NodeNumber2         % The node number that the other end of the inductor is connected to, This is optional.
        InductanceValue     % The magnitude of the inductance for the inductor
        NetworkIndex        % The index of the network this element belongs to in the array of networks
        
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = SonnetCircuitInductor(theFid,theNetworkNumber)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % The constructor for Circuit inductor, this is defined
            % in the Circuit Block (CKT) entry in the Sonnet Project
            % File for Netlists.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if nargin == 2
                
                initialize(obj);
                
                % Read in the inductor line
                aTempString=fgetl(theFid);
                
                % Read in the first node number
                [aNode1Number, ~, ~, aNextindex]=sscanf(aTempString,' %d',1);
                aTempString=aTempString(aNextindex:length(aTempString));
                
                % Determine if a second node number was specified
                if isempty(sscanf(aTempString, ' %d')) % If no second node number was specified
                    aNode2Number='';
                else % If a second node number was specified
                    [aNode2Number, ~, ~, aNextindex]=sscanf(aTempString, ' %d');
                    aTempString=aTempString(aNextindex:length(aTempString));
                end
                
                % Remove the 'L='
                aInducatance=strrep(aTempString,'L=','');
                    
                % Convert the value to a double if possible
                if ~isnan(str2double(aInducatance))
                    aInducatance=str2double(aInducatance);
                end
                
                % Store values in properties
                obj.NodeNumber1=aNode1Number;
                obj.NodeNumber2=aNode2Number;
                obj.InductanceValue=aInducatance;
                obj.NetworkIndex=theNetworkNumber;
                
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
            % This function initializes the sweep properties to some default
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
            aNewObject=SonnetCircuitInductor();
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
            
            aSignature='IND';
            
            aSignature=[aSignature sprintf(' %d',obj.NodeNumber1)];
            
            if ~isempty(obj.NodeNumber2)                    % Print out the second node if it exists
                aSignature=[aSignature sprintf(' %d',obj.NodeNumber2)];
            end
            
            if isa(obj.InductanceValue,'char')
                aSignature=[aSignature sprintf(' L=%s\n',obj.InductanceValue)];
            else
                aSignature=[aSignature sprintf(' L=%.15g\n',obj.InductanceValue)];
            end
        end
        
    end
    
end

