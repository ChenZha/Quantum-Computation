function SonnetClone(theSourceObject,theNewObject)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function will make a deep copy of
%  an handle object. This function will only
%  copy non-hidden properties.
%
% Be careful when using this method for
%  classes that have dependent properties.
%  dependent properties will need a set
%  method (even if the set method does
%  nothing).
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
aProperties = properties(theSourceObject);
aBackup=warning();
warning off all
for iCounter = 1:length(aProperties)
    if isobject(theSourceObject.(aProperties{iCounter}))
        % If the variable is a matrix of objects
        % then clone all the values in the matrix
        theNewObject.(aProperties{iCounter}) = theSourceObject.(aProperties{iCounter});
        for jCounter=1:length(theSourceObject.(aProperties{iCounter}))
            theNewObject.(aProperties{iCounter})(jCounter) = theSourceObject.(aProperties{iCounter})(jCounter).clone();
        end
    else
        % If the variable is not an object it may still be a
        % container that holds an object (cell array,
        % struct,...) loop through them and check for
        % anything to be cloned.
        if iscell(theSourceObject.(aProperties{iCounter}))
            % If the variable is a cell array of objects
            % then clone all the values in the matrix
            theNewObject.(aProperties{iCounter})=cellfun(@(x) buildCopy(x),theSourceObject.(aProperties{iCounter}), 'UniformOutput',false);
            
        elseif isstruct(theSourceObject.(aProperties{iCounter}))
            % If the variable is a struct of objects
            % then clone all the values in the matrix
            aFields = fieldnames(theSourceObject.(aProperties{iCounter}));
            for jCounter=1:length(aFields)
                if isobject(theSourceObject.(aProperties{iCounter}).(aFields{jCounter}))
                    theNewObject.(aProperties{iCounter}).(aFields{jCounter}) = theSourceObject.(aProperties{iCounter}).(aFields{jCounter}).clone();
                else
                    theNewObject.(aProperties{iCounter}).(aFields{jCounter}) = theSourceObject.(aProperties{iCounter}).(aFields{jCounter});
                end
            end
        else
            % If the variable is just a primitive
            % (number, character, string...)
            theNewObject.(aProperties{iCounter}) = theSourceObject.(aProperties{iCounter});
        end
    end
end
warning(aBackup);
end

function theNewObject=buildCopy(theSourceObject)
if isobject(theSourceObject)
    theNewObject = theSourceObject.clone();
else
    theNewObject = theSourceObject;
end
end
