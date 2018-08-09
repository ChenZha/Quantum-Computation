% This function will write current data export structures  
% to a CSV file in Sonnet compatible format.
%
% Usage:
%   JXYWrite(aArrayOfExports,Filename)
%     The array of export data objects may be an N length
%     vector of current data structs that should be
%     written to the file named Filename.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function JXYWrite(aArrayOfExports,aFilename)

aFid=fopen(aFilename,'w');

for iCounter=1:length(aArrayOfExports)
    
    % Write out the data filename and the label
    fprintf(aFid,'%s,%s\n',aArrayOfExports(iCounter).Label,aArrayOfExports(iCounter).DataFilename);
    
    % Write out the project filename
    fprintf(aFid,'soncmd Exported Data from:,%s\n',strrep(aArrayOfExports(iCounter).ProjectFilename,'.son',''));
    
    % If there are parameters then print them to the file
    if isfield(aArrayOfExports(iCounter),'Parameters')
        fprintf(aFid,'Parameters:,%s\n',aArrayOfExports(iCounter).Parameters);
    end
    
    % Write out the frequency value
    fprintf(aFid,'Frequency:,%g\n',aArrayOfExports(iCounter).Frequency);
    
    % Write out the level value
    fprintf(aFid,'theLevel:,%g,%g\n',aArrayOfExports(iCounter).Level,aArrayOfExports(iCounter).Level);
    
    fprintf(aFid,'Export Positions in:,MIL\n');
    
    % If the current data is complex then we need to write it in a particular
    % expected syntax.  If the data is not complex then we may use other
    % methods to print the data to the file.
    if aArrayOfExports(iCounter).Complex
        fprintf(aFid,'%s Magnitude,Complex Form,Amps/Meter\n',aArrayOfExports(iCounter).Type);
        
        switch aArrayOfExports(iCounter).Type
            case 'JX'
                fprintf(aFid,'X Directed\n');
                printXValuesCommaAtFront(aFid,aArrayOfExports(iCounter).XPosition');
                printComplexMatrix(aFid,[aArrayOfExports(iCounter).YPosition aArrayOfExports(iCounter).XDirectedData]);
                
            case 'JY'
                fprintf(aFid,'Y Directed\n');
                printXValuesCommaAtFront(aFid,aArrayOfExports(iCounter).XPosition');
                printComplexMatrix(aFid,[aArrayOfExports(iCounter).YPosition aArrayOfExports(iCounter).YDirectedData]);
                
            case 'JXY'
                fprintf(aFid,'X Directed\n');
                printXValuesCommaAtFront(aFid,aArrayOfExports(iCounter).XPosition');
                printComplexMatrix(aFid,[aArrayOfExports(iCounter).YPosition aArrayOfExports(iCounter).XDirectedData]);
                
                fprintf(aFid,'Y Directed\n');
                printXValuesCommaAtFront(aFid,aArrayOfExports(iCounter).XPosition');
                printComplexMatrix(aFid,[aArrayOfExports(iCounter).YPosition aArrayOfExports(iCounter).YDirectedData]);
        end
        
    else
        fprintf(aFid,'%s Magnitude,Magnitude Form,Amps/Meter\n',aArrayOfExports(iCounter).Type);
        printXValuesCommaAtBack(aFid,aArrayOfExports(iCounter).XPosition');
        printRealMatrix(aFid,[aArrayOfExports(iCounter).YPosition aArrayOfExports(iCounter).Data]);
    end
    
end

fclose(aFid);

end

function printXValuesCommaAtFront(theFid,theMatrix)
% This function will print the X values for the 
% current data file. This function will not append
% a comma to the end of each line.
fprintf(theFid,'Y Position\n');
fprintf(theFid,'X Position ->');
for iCounter=1:size(theMatrix,1)
    for jCounter=1:size(theMatrix,2)
        fprintf(theFid,',%g',theMatrix(iCounter,jCounter));
    end
    fprintf(theFid,'\n');
end
end

function printXValuesCommaAtBack(theFid,theMatrix)
% This function will print the X values for the 
% current data file. This function will append
% a comma to the end of each line.
fprintf(theFid,'Y Position\n');
fprintf(theFid,'X Position ->,');
for iCounter=1:size(theMatrix,1)
    for jCounter=1:size(theMatrix,2)
        fprintf(theFid,'%g,',theMatrix(iCounter,jCounter));
    end
    fprintf(theFid,'\n');
end
end

function printRealMatrix(theFid,theMatrix)
% This function will print the current data
% from the matrix to the file.
for iCounter=1:size(theMatrix,1)
    for jCounter=1:size(theMatrix,2)
        fprintf(theFid,'%.15g,',theMatrix(iCounter,jCounter));
    end
    fprintf(theFid,'\n');
end
fprintf(theFid,'\n');
end

function printComplexMatrix(theFid,theMatrix)
% This function will print complex current
% data to the file in the expected syntax.
for iCounter=1:size(theMatrix,1)
    % The first value for the row is the
    % Y coordinate which is not complex
    fprintf(theFid,'%.15g',theMatrix(iCounter,1));
    for jCounter=2:size(theMatrix,2)
        if isreal(theMatrix(iCounter,jCounter))
            fprintf(theFid,',( %.15g +j0 )',theMatrix(iCounter,jCounter));
        else
            if imag(theMatrix(iCounter,jCounter)) < 0
                fprintf(theFid,',( %.15g -j%.15g )',real(theMatrix(iCounter,jCounter)),abs(imag(theMatrix(iCounter,jCounter))));
            else
                fprintf(theFid,',( %.15g +j%.15g )',real(theMatrix(iCounter,jCounter)),abs(imag(theMatrix(iCounter,jCounter))));
            end
        end
    end
    fprintf(theFid,'\n');
end
fprintf(theFid,'\n');
end