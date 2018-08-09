classdef SonnetUnknownBlock  < handle
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This class is used to save information that was part of a block
    %   found in a Sonnet project which is unknown or isn't usful to parse.
    %   The constructor for this class will read in all the lines of the
    %   block so that they can be written back out. This allows for the
    %   block to remain present when it is written out to a file.
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
        
        ArrayOfStringsContainedInBlock              % This stores the lines of the block.
        BlockName                                   % Stores the name of the block.
        
    end
    
    properties (Dependent = true)
        
        Lines
        
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = SonnetUnknownBlock(theFid, theBlockName)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % The constructor for an unknown block.  It needs to get the
            % file that we are reading and it needs to get the name of the block,
            % all the values in the block should be read in and stored in
            % ArrayOfStringsContainedInBlock.  The block is terminated by an
            % statment of the form: 'END X' where X is the name of the block. The
            % name of the block will also be sent to the constructor from the
            % project's constructor.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if nargin == 2
                
                initialize(obj);		% Initialize the values of the properties using the initializer function
                
                theEndTag= ['END ' theBlockName];                 % This is the string that indicates that the block is over
                obj.BlockName=theBlockName;                       % Stored the name of the block in the object's properties
                iNumberOfLinesInBlock=0;                          % Stores the number of lines in the block
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Keep reading lines from the file until we read a
                % line that is equal to theEndTag indicating the
                % block is over.
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                while(1==1)                                         % Loop forever until we break.  We break when we read in the END BLOCK tag
                    
                    % Read a string from the file,  we will use this to determine what property needs to be modified by using a case statement.
                    aTempString=fgetl(theFid);                      % Read a Value from the file, we will be using this to drive the switch statment
                    
                    if strcmp(aTempString,theEndTag)==1;            % if we read in the end of block tag then we can break out of the loop because we are done reading the block
                        break;
                        
                    else                                            % Otherwise we will store the read line in the array so we have a copy of it present.
                        iNumberOfLinesInBlock=iNumberOfLinesInBlock+1;
                        obj.ArrayOfStringsContainedInBlock{iNumberOfLinesInBlock}= aTempString;
                        
                    end
                    
                end
                
            else
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % we come here when we didn't recieve a file ID as an argument
                % which means that we are going to create a default object block with
                % default values by calling the function's initialize method.
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                initialize(obj);
                
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function initialize(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function initializes the Unknown block's properties
            %	to some default values. This is called by the
            %	constructor and can be called by the user to
            %	reinitialize the object to default values.
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
            aNewObject=SonnetUnknownBlock();
            SonnetClone(obj,aNewObject);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function writeObjectContents(obj, theFid, theVersion) %#ok<INUSD>
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function writes the values from the object to a file.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            fprintf(theFid,'%s\n',obj.BlockName);
            
            % print out all the lines we read
            for iCounter= 1:size(obj.ArrayOfStringsContainedInBlock,2)
                fprintf(theFid,'%s\n',obj.ArrayOfStringsContainedInBlock{iCounter});
            end
            
            fprintf(theFid,'END %s\n',obj.BlockName);
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aSignature=stringSignature(obj,theVersion) %#ok<INUSD>
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function writes the values from the object to a string.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            aSignature = sprintf('%s\n',obj.BlockName);
            
            % print out all the lines we read
            for iCounter= 1:length(obj.ArrayOfStringsContainedInBlock)
                aSignature = [aSignature sprintf('%s\n',obj.ArrayOfStringsContainedInBlock{iCounter})]; %#ok<AGROW>
            end
            
            aSignature = [aSignature sprintf('END %s\n',obj.BlockName)];
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function aValue=get.Lines(obj)
            aValue=obj.ArrayOfStringsContainedInBlock;            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function set.Lines(obj,aValue)
            obj.ArrayOfStringsContainedInBlock=aValue;            
        end
        
    end
    
end

