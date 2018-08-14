function [F, Data, Zo, DataCell] = TouchstoneRead(DataFileName) %#ok<STOUT>

% TouchstoneRead reads Touchstone formatted files.
%
% EXAMPLE :
% [freq, data, Zo] = TouchstoneRead(DataFileName);
%
% freq       -  1xF arrays
% data       -  PxPxF matrix, P- number of ports, F- number of freq points
% Zo         -  impedance used in normalization of data
% DataCell   -  an cell array containing the PxP data sets as vectors
%
%
% This function was originally written by Tudor Dima, last rev. 26.10.2008, tudima at zahoo dot com
%                                              (change the z into y...)
%
% Latest Revision made by Serhend Arvas and Bashir Souid.

%------- read from file DataFileName -------
fid = fopen( DataFileName, 'rt');

if fid < 1
    fprintf(fid_log, '%s \n %s', ' ... exiting...', ['Error : requested parameter file ' DataFileName ' not found ! ']);
end;

if fid > 0
    %disp(['Reading parameter data from file '  DataFileName ]);
    
    % - initialise defaults, in case file is corrupted
    F = []; DataTemp = []; 
    
    phrase='!';
    while ~strcmp(phrase(1),'#')
        phrase = deblank(lower(fgets(fid)));
    end
    word = Phrase2Word(phrase);
    
    FmultiplierString=deblank(word(2,:));
    DataType=deblank(word(3,:));  %#ok<*NASGU>
    FormatType=deblank(word(4,:));
    Zo=str2num(deblank(word(6,:)));
    
    switch lower(FmultiplierString)
        case {'hz'}
            Fmultiplier=1;
        case {'khz'}
            Fmultiplier=1e3;
        case {'mhz'}
            Fmultiplier=1e6;
        case {'ghz'}
            Fmultiplier=1e9;
        case {'thz'}
            Fmultiplier=1e12;
    end
    
    LocalDataBlock=[];
    F=[];    
    while 1
        
        LineOfText = fgetl(fid);
        if ~isempty(LineOfText)
            while strcmp(LineOfText(1),'!')
                LineOfText = fgetl(fid);
            end
        end
        if ~ischar(LineOfText), break, end
        TempData=str2num(deblank(LineOfText)); %#ok<*ST2NM>
        if (-1)^length(TempData)==-1 %If Odd number of entries on a line, that is data + Frequency -> Start of a Data block
            if ~isempty(LocalDataBlock)
                DataTemp(:,:,length(F))=LocalDataBlock;
            end
            F=[F TempData(1)];
            DataVec=TempData(2:length(TempData));            
            LocalDataBlock=DataVec;
        end
        if (-1)^length(TempData)==1 %If Even number of entries on a line, that is just data
            LocalDataBlock=[LocalDataBlock TempData]; %#ok<*AGROW>
        end
    end
end
                    
if ~isempty(LocalDataBlock)
     DataTemp(:,:,length(F))=LocalDataBlock; 
end

Data=DataRaw2Data(DataTemp,FormatType);
F=F*Fmultiplier;
    
fclose(fid);

% Convert the data into a cell array that has 
% an vector for each data pair EX: S21
[~,n,Fm]=size(Data);
Data2=permute(Data,[3 2 1]);

for p=1:n
    for q=1:n
        evalStr=['DataCell{' num2str(p) ',' num2str(q) '}=Data2(:,p,q);'];
        eval(evalStr);
    end
end
    
end
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    