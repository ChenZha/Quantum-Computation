% JXYData=JXYRead(Filename) will read a current data file from the 
% hard drive and build a current data structure in Matlab.
%
% Usage:
%   JXYData=JXYRead(Filename)

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

function aExports=JXYRead(theFilename)

% Data is exported as a vector of structs.
% each struct has the data for a single
% frequency on a single level.

aExportCounter=0;
aExportStartLocation=[];
aExportEndLocation=[];

aFid=fopen(theFilename);
if aFid==-1
    error('File could not be opened');
end

while (feof(aFid)==0)
    
    aBackupOfTheFid=ftell(aFid);
    aTempLine=fgetl(aFid);
    
    % Read an export data set
    if ~isempty(strfind(aTempLine,'.csv'))
        fseek(aFid,aBackupOfTheFid,'bof');
        aExportCounter=aExportCounter+1;
        aExport=processExport(aFid);
        aExports(aExportCounter)=aExport;
    end
end

fclose(aFid);

end

function aExport=processExport(aFid)

% Read the label and data file name
aTempLine=fgetl(aFid);
aComaIndex=strfind(aTempLine,',');
if length(aComaIndex)==2 % We recieved a version number
    aExport.Label=aTempLine(aComaIndex(1)+1:aComaIndex(2)-1);
    aExport.DataFilename=aTempLine(aComaIndex(2)+1:length(aTempLine));
else
    aExport.Label=aTempLine(1:aComaIndex-1);
    aExport.DataFilename=aTempLine(aComaIndex+1:length(aTempLine));
end

% Read the project name
aTempLine=fgetl(aFid);
aComaIndex=strfind(aTempLine,',');
aExport.ProjectFilename=[aTempLine(aComaIndex(end)+1:length(aTempLine)) '.son'];

% If this line is a "Parameters" line
% then read the next line.
aTempLine=fgetl(aFid);
if ~isempty(strfind(aTempLine,'Parameters'))
    aExport.Parameters=strrep(aTempLine,'Parameters:,','');
    aTempLine=fgetl(aFid);
end

% Read the frequency
aExport.Frequency=str2double(strrep(aTempLine,'Frequency:,',''));

% Read the level info
aTempLine=fgetl(aFid);

if isempty(strfind(aTempLine, 'theLevel:,'))
    aTempLine=fgetl(aFid);
end    

aLevels=strrep(aTempLine,'theLevel:,','');
aComaIndex=strfind(aLevels,',');
aExport.Level=aLevels(1:aComaIndex-1);
aExport.LevelIndex=str2double(aLevels(aComaIndex+1:length(aLevels)));

% Throw away the "Export Positions in" and/or any "Export Steps" lines
aTempLine=fgetl(aFid);
if ~isempty(strfind(aTempLine,'Export Positions in'))
    aTempLine=fgetl(aFid);
end
if ~isempty(strfind(aTempLine,'Export Steps'))
    aTempLine=fgetl(aFid);
end

% Read the JXY Magnitude
aFields=textscan(aTempLine,'%s','Delimiter',',');
aExport.Type=aFields{1}{1};
aExport.Units=aFields{1}{3};

% Determine if the data is complex
if ~isempty(strfind(aTempLine,'Complex'))
    aExport.Complex=true;
else
    aExport.Complex=false;
end

% Read the data values
if aExport.Complex
    aExport=readComplexData(aFid,aExport);
else
    aExport=readMagnitudeData(aFid,aExport);
end

end

function aExport=readMagnitudeData(aFid,aExport)

aTempLine='';
while isempty(strfind(aTempLine,'X Position'))
    if (feof(aFid)==1)
        error('Invalid file');
    else
        aBackupOfTheFid=ftell(aFid);
        aTempLine=fgetl(aFid);
    end
end

% Read the X directed data
fseek(aFid,aBackupOfTheFid,'bof');
[aExport.XPosition aExport.YPosition aExport.Data]= readMagnitudeDataBlock(aFid);

end

function [aXPositions aYPositions aData]=readMagnitudeDataBlock(aFid)

% Find the X Positions
aTempLine=fgetl(aFid);
aXPositions=textscan(aTempLine(15:length(aTempLine)),'%f','Delimiter',',');
aXPositions=cell2mat(aXPositions);

% Find the number of lines in the data block
aBackupOfTheFid=ftell(aFid);
aNumberOfRows=0;
while ~isempty(aTempLine)
    aNumberOfRows=aNumberOfRows+1;
    aTempLine=fgetl(aFid);
end
aNumberOfRows=aNumberOfRows-1; % Decrement the count by one because we counted a case were there was only a newline character
fseek(aFid,aBackupOfTheFid,'bof');

% Read data array as a string
aDataSet=textscan(aFid,'%f',(length(aXPositions)+1)*aNumberOfRows,'Delimiter',',');
aDataSet=aDataSet{1};

% Preallocate data arrays for speed
aData=zeros(aNumberOfRows,length(aXPositions));
aYPositions=zeros(1,aNumberOfRows);
aDataPositionCounter=2; % changed to 2 omit y values

% Extract the data and populate the arrays
for iCounter=1:aNumberOfRows
    
    aYPositions(iCounter)=aDataSet(aDataPositionCounter);
    %aDataPositionCounter=aDataPositionCounter+1;
    
    for jCounter=1:length(aXPositions)
        aData(iCounter,jCounter)=aDataSet(aDataPositionCounter);
        if numel(aDataSet) > aDataPositionCounter
            aDataPositionCounter=aDataPositionCounter+1;
        end
    end
    
    if numel(aDataSet) > aDataPositionCounter
        aDataPositionCounter=aDataPositionCounter+1;
    end
    
end
end

function aExport=readComplexData(aFid,aExport)

% If X directed data is present then read X directed data
if ~isempty(strfind(aExport.Type,'X')) || ~isempty(strfind(aExport.Type,'Heat'))
    aTempLine='';
    while isempty(strfind(aTempLine,'X Position'))
        if (feof(aFid)==1)
            error('Invalid file');
        else
            aBackupOfTheFid=ftell(aFid);
            aTempLine=fgetl(aFid);
        end
    end
    
    % Read the X directed data
    fseek(aFid,aBackupOfTheFid,'bof');
    aExport.XPosition={}; 
    aExport.YPosition={};
    aExport.XDirectedData={};
    % aExport.YDirectedData={};
    [aExport.XPosition, aExport.YPosition, aExport.XDirectedData]= readComplexDataBlock(aFid);
end

% If Y directed data is present then read Y directed data
if ~isempty(strfind(aExport.Type,'Y')) || ~isempty(strfind(aExport.Type,'Heat'))
    aTempLine='';
    while isempty(strfind(aTempLine,'X Position'))
        if (feof(aFid)==1)
            error('Invalid file');
        else
            aBackupOfTheFid=ftell(aFid);
            aTempLine=fgetl(aFid);
        end
    end
    
    % Read the Y directed data
    fseek(aFid,aBackupOfTheFid,'bof');
    aExport.XPosition={}; 
    aExport.YPosition={};
    % aExport.XDirectedData={};
    aExport.YDirectedData={};
    
    [aExport.XPosition, aExport.YPosition, aExport.YDirectedData]= readComplexDataBlock(aFid);
end

end

function [aXPositions, aYPositions, aData, aData2]=readComplexDataBlock(aFid)

aData2={};
% Find the X Positions
aTempLine=fgetl(aFid);
aXPositions=textscan(aTempLine(15:length(aTempLine)),'%f','Delimiter',',');
aXPositions=cell2mat(aXPositions);

% Find the number of lines in the data block
aBackupOfTheFid=ftell(aFid);
aNumberOfRows=0;
while ~isempty(aTempLine)
    aNumberOfRows=aNumberOfRows+1;
    aTempLine=fgetl(aFid);
end
aNumberOfRows=aNumberOfRows-1; % Decrement the count by one because we counted a case were there was only a newline character
fseek(aFid,aBackupOfTheFid,'bof');

% Read data array as a string
aDataString=textscan(aFid,'%s',(length(aXPositions)+1)*aNumberOfRows,'Delimiter',',');
aDataString=aDataString{1};

% Preallocate data arrays for speed
aData=zeros(aNumberOfRows,length(aXPositions));
aYPositions=zeros(1,aNumberOfRows);
aDataPositionCounter=2; % changed to 2 omit y values

% Extract and convert the Y position data and the current value data
for iCounter=1:aNumberOfRows
    
    aYPositions(iCounter)=str2double(aDataString(aDataPositionCounter));
    aDataPositionCounter=aDataPositionCounter+1;
    
    for jCounter=1:length(aXPositions)
        % Convert the Sonnet formatted string to one that str2double will understand
        aCurrentValue=aDataString(aDataPositionCounter);
        if strcmp(aCurrentValue{1},'( 0 +j0 )')==1
            aData(iCounter,jCounter)=0;
        else            
            aCurrentRealValue=sscanf(aCurrentValue{1}(3:length(aCurrentValue{1})),'%g');
            aJIndex=strfind(aCurrentValue{1},'j');
            aCurrentImaginaryValue=sscanf(aCurrentValue{1}(aJIndex+1:length(aCurrentValue{1})),'%g');
            
            if aCurrentValue{1}(aJIndex-1) == '-'
                aCurrentImaginaryValue=aCurrentImaginaryValue*-1;
            end
            
            % Store the value in the data array
            aData(iCounter,jCounter)=aCurrentRealValue + aCurrentImaginaryValue*1i;
        end
        
        aDataPositionCounter=aDataPositionCounter+1;
    end
    
end

end