% SonnetBanner will make a Sonnet Geometry project 
%   circuit that will spell out a string using metal polygons
%
% This demo was written by Bashir Souid

function SonnetBanner(theString)

% If no string is specified then spell out "SonnetLab"
if nargin == 0
    theString='SonnetLab';
end

% Only take the first word if they put more than one word
theString=strtok(theString);

% Convert the string to upper case
theString=upper(theString);

% Make a new project
Project=SonnetProject();

% Loop through all the letters and add them to the project
aXOffset=50;
aYOffset=50;
for iCounter=1:length(theString)
    switch theString(iCounter)
        case 'A'
            anArrayOfXValues=[100    80    80    20    20     0     0    20    20    80    80   100   100];
            anArrayOfYValues=[160   160    90    90   160   160    20    20    70    70    20    20   160];
            Project.addMetalPolygonEasy(0,anArrayOfXValues+aXOffset,anArrayOfYValues+aYOffset);
            anArrayOfXValues=[100     0     0   100   100];
            anArrayOfYValues=[20    20     0     0    20];
            Project.addMetalPolygonEasy(0,anArrayOfXValues+aXOffset,anArrayOfYValues+aYOffset);
        case 'B'
            anArrayOfXValues=[80   100   100    80    80];
            anArrayOfYValues=[20    20    70    70    20];
            Project.addMetalPolygonEasy(0,anArrayOfXValues+aXOffset,anArrayOfYValues+aYOffset);
            anArrayOfXValues=[80   100   100    80    80];
            anArrayOfYValues=[90    90   140   140    90];
            Project.addMetalPolygonEasy(0,anArrayOfXValues+aXOffset,anArrayOfYValues+aYOffset);
            anArrayOfXValues=[80     0     0    80    80    20    20    80    80    20    20    80    80];
            anArrayOfYValues=[160   160     0     0    20    20    70    70    90    90   140   140   160];
            Project.addMetalPolygonEasy(0,anArrayOfXValues+aXOffset,anArrayOfYValues+aYOffset);
        case 'C'
            anArrayOfXValues=[100     0     0   100   100    20    20   100   100];
            anArrayOfYValues=[160   160     0     0    20    20   140   140   160];
            Project.addMetalPolygonEasy(0,anArrayOfXValues+aXOffset,anArrayOfYValues+aYOffset);
        case 'D'
            anArrayOfXValues=[90    20    20    80    80    20    20    90    90   100   100    90    90];
            anArrayOfYValues=[160   160   140   140    20    20     0     0    20    20   140   140   160];
            Project.addMetalPolygonEasy(0,anArrayOfXValues+aXOffset,anArrayOfYValues+aYOffset);
            anArrayOfXValues=[0     0    20    20    20     0];
            anArrayOfYValues=[160     0     0   140   160   160];
            Project.addMetalPolygonEasy(0,anArrayOfXValues+aXOffset,anArrayOfYValues+aYOffset);
        case 'E'
            anArrayOfXValues=[100    20    20   100   100     0     0   100   100    20    20   100   100];
            anArrayOfYValues=[90    90   140   140   160   160     0     0    20    20    70    70    90];
            Project.addMetalPolygonEasy(0,anArrayOfXValues+aXOffset,anArrayOfYValues+aYOffset);
        case 'F'
            anArrayOfXValues=[100    20    20     0     0   100   100    20    20   100   100];
            anArrayOfYValues=[90    90   160   160     0     0    20    20    70    70    90];
            Project.addMetalPolygonEasy(0,anArrayOfXValues+aXOffset,anArrayOfYValues+aYOffset);
        case 'G'
            anArrayOfXValues=[100   100     0     0   100   100    20    20    80    80    50    50   100];
            anArrayOfYValues=[80   160   160     0     0    20    20   140   140   100   100    80    80];
            Project.addMetalPolygonEasy(0,anArrayOfXValues+aXOffset,anArrayOfYValues+aYOffset);
        case 'H'
            anArrayOfXValues=[20    20    80    80   100   100    80    80    20    20     0     0    20];
            anArrayOfYValues=[0    70    70     0     0   160   160    90    90   160   160     0     0];
            Project.addMetalPolygonEasy(0,anArrayOfXValues+aXOffset,anArrayOfYValues+aYOffset);
        case 'I'
            anArrayOfXValues=[60    60   100   100     0     0    40    40     0     0   100   100    60];
            anArrayOfYValues=[20   140   140   160   160   140   140    20    20     0     0    20    20];
            Project.addMetalPolygonEasy(0,anArrayOfXValues+aXOffset,anArrayOfYValues+aYOffset);
        case 'J'
            anArrayOfXValues=[10    10     0     0    20    20    40    40    60    60    80    80   100   100    90    90    80    80,...
                70    70    30    30    20    20    10];
            anArrayOfYValues=[140   130   130   110   110   130   130   140   140   130   130     0     0   130   130   140   140   150,...
                150   160   160   150   150   140   140];
            Project.addMetalPolygonEasy(0,anArrayOfXValues+aXOffset,anArrayOfYValues+aYOffset);
        case 'K'
            anArrayOfXValues=[40    30    30    20    20     0     0    20    20    30    30    40    40    50    50    60    60    70,...
                70    90    90    80    80    70    70    60    60    50    50    40    40    50    50    60    60    70,...
                70    80    80    90    90   100   100    80    80    70    70    60    60    50    50    40    40];
            anArrayOfYValues=[100   100   110   110   160   160     0     0    50    50    60    60    40    40    30    30    20    20,...
                0     0    20    20    30    30    50    50    60    60    70    70    80    80    90    90   100   100,...
                110   110   120   120   140   140   160   160   140   140   130   130   120   120   110   110   100];
            Project.addMetalPolygonEasy(0,anArrayOfXValues+aXOffset,anArrayOfYValues+aYOffset);
        case 'L'
            anArrayOfXValues=[100     0     0    20    20   100   100];
            anArrayOfYValues=[160   160     0     0   140   140   160];
            Project.addMetalPolygonEasy(0,anArrayOfXValues+aXOffset,anArrayOfYValues+aYOffset);
        case 'M'
            anArrayOfXValues=[0    10    10    90    90   100   100    80    80    60    60    40    40    20    20     0     0];
            anArrayOfYValues=[10    10     0     0    10    10   160   160    20    20    90    90    20    20   160   160    10];
            Project.addMetalPolygonEasy(0,anArrayOfXValues+aXOffset,anArrayOfYValues+aYOffset);
        case 'N'
            anArrayOfXValues=[70    70    80    80   100   100    70    70    60    60    50    50    40    40    30    30    20    20,...
                0     0    30    30    40    40    50    50    60    60    70];
            anArrayOfYValues=[80   110   110     0     0   160   160   130   130   100   100    70    70    50    50    30    30   160,...
                160     0     0    10    10    30    30    60    60    80    80];
            Project.addMetalPolygonEasy(0,anArrayOfXValues+aXOffset,anArrayOfYValues+aYOffset);
        case 'O'
            anArrayOfXValues=[90    10    10    20    20    80    80    90    90];
            anArrayOfYValues=[20    20    10    10     0     0    10    10    20];
            Project.addMetalPolygonEasy(0,anArrayOfXValues+aXOffset,anArrayOfYValues+aYOffset);
            anArrayOfXValues=[10    10    30    70    90    90    80    80    20    20    10];
            anArrayOfYValues=[150   140   140   140   140   150   150   160   160   150   150];
            Project.addMetalPolygonEasy(0,anArrayOfXValues+aXOffset,anArrayOfYValues+aYOffset);
            anArrayOfXValues=[0     0    10    30    30    20    20    30    30    10     0];
            anArrayOfYValues=[140    20    20    20    30    30   130   130   140   140   140];
            Project.addMetalPolygonEasy(0,anArrayOfXValues+aXOffset,anArrayOfYValues+aYOffset);
            anArrayOfXValues=[70    80    80    70    70    90   100   100    90    70    70];
            anArrayOfYValues=[130   130    30    30    20    20    20   140   140   140   130];
            Project.addMetalPolygonEasy(0,anArrayOfXValues+aXOffset,anArrayOfYValues+aYOffset);
        case 'P'
            anArrayOfXValues=[20    20    60    60    20    20     0     0    70    70    20];
            anArrayOfYValues=[20    60    60    80    80   160   160     0     0    20    20];
            Project.addMetalPolygonEasy(0,anArrayOfXValues+aXOffset,anArrayOfYValues+aYOffset);
            anArrayOfXValues=[80    80    70    70    80    80    90    90   100   100    90    90    80    80    60    60    70    70  80];
            anArrayOfYValues=[50    30    30     0     0    10    10    20    20    60    60    70    70    80    80    60    60    50  50];
            Project.addMetalPolygonEasy(0,anArrayOfXValues+aXOffset,anArrayOfYValues+aYOffset);
        case 'Q'
            anArrayOfXValues=[100    90    90   100   100    90    90    80    80    20    20    10    10     0     0    20    20    30,...
                30    70    70    60    60    50    50    60    60    70    70    80    80   100   100];
            anArrayOfYValues=[120   120   130   130   160   160   150   150   160   160   150   150   140   140    80    80   130   130,...
                140   140   130   130   120   120   100   100   110   110   120   120    80    80   120];
            Project.addMetalPolygonEasy(0,anArrayOfXValues+aXOffset,anArrayOfYValues+aYOffset);
            anArrayOfXValues=[20    80    80    90    90   100   100    80    80    70    70    30    30    20    20     0     0    10,...
                10    20    20];
            anArrayOfYValues=[0     0    10    10    20    20    80    80    30    30    20    20    30    30    80    80    20    20,...
                10    10     0];
            Project.addMetalPolygonEasy(0,anArrayOfXValues+aXOffset,anArrayOfYValues+aYOffset);
        case 'R'
            anArrayOfXValues=[80   100   100    80    80];
            anArrayOfYValues=[10    10    60    60    10];
            Project.addMetalPolygonEasy(0,anArrayOfXValues+aXOffset,anArrayOfYValues+aYOffset);
            anArrayOfXValues=[0     0    80    80    20    20    80    80    40    40    50    50    60    60    70    70    80    80,...
                90    90   100   100    80    80    70    70    60    60    50    50    40    40    30    30    20    20    0];
            anArrayOfYValues=[160     0     0    20    20    50    50    70    70    80    80    90    90   100   100   110   110   120,...
                120   130   130   160   160   150   150   130   130   120   120   110   110   100   100    90    90   160   160];
            Project.addMetalPolygonEasy(0,anArrayOfXValues+aXOffset,anArrayOfYValues+aYOffset);
        case 'S'
            anArrayOfXValues=[90    90   100   100    20    20    90    90   100   100    90    90    10    10     0     0    80    80,...
                10    10     0     0    10    10    90];
            anArrayOfYValues=[0    10    10    20    20    60    60    70    70   150   150   160   160   150   150   140   140    80,...
                80    70    70    10    10     0     0];
            Project.addMetalPolygonEasy(0,anArrayOfXValues+aXOffset,anArrayOfYValues+aYOffset);
        case 'T'
            anArrayOfXValues=[40    40     0     0   100   100    60    60    40];
            anArrayOfYValues=[160    20    20     0     0    20    20   160   160];
            Project.addMetalPolygonEasy(0,anArrayOfXValues+aXOffset,anArrayOfYValues+aYOffset);
        case 'U'
            anArrayOfXValues=[10    10     0     0    20    20    80    80   100   100    90    90    80    80    20    20    10];
            anArrayOfYValues=[150   140   140     0     0   140   140     0     0   140   140   150   150   160   160   150   150];
            Project.addMetalPolygonEasy(0,anArrayOfXValues+aXOffset,anArrayOfYValues+aYOffset);
        case 'V'
            anArrayOfXValues=[20    20    10    10     0     0    20    20    30    30    40    40    60    60    70    70    80    80,...
                100   100    90    90    80    80    70    70    60    60    40    40    30    30    20];
            anArrayOfYValues=[130    80    80    70    70     0     0    70    70    80    80   130   130    80    80    70    70     0,...
                0    70    70    80    80   130   130   140   140   160   160   140   140   130   130];
            Project.addMetalPolygonEasy(0,anArrayOfXValues+aXOffset,anArrayOfYValues+aYOffset);
        case 'W'
            anArrayOfXValues=[0    10    10    90    90   100   100    80    80    60    60    40    40    20    20     0     0];
            anArrayOfYValues=[150   150   160   160   150   150     0     0   140   140    70    70   140   140     0     0   150];
            Project.addMetalPolygonEasy(0,anArrayOfXValues+aXOffset,anArrayOfYValues+aYOffset);
        case 'X'
            anArrayOfXValues=[30    30    20    20    10    10     0     0    20    20    30    30    40    40    60    60    70    70,...
                80    80   100   100    90    90    80    80    70    70    80    80    90    90   100   100    80    80,...
                70    70    60    60    40    40    30    30    20    20     0     0    10    10    20    20    30];
            anArrayOfYValues=[100    60    60    40    40    20    20     0     0    20    20    40    40    60    60    40    40    20,...
                20     0     0    20    20    40    40    60    60   100   100   120   120   140   140   160   160   140,...
                140   120   120   100   100   120   120   140   140   160   160   140   140   120   120   100   100];
            Project.addMetalPolygonEasy(0,anArrayOfXValues+aXOffset,anArrayOfYValues+aYOffset);
        case 'Y'
            anArrayOfXValues=[60    60    40    40    30    30    20    20    10    10     0     0    20    20    30    30    40    40,...
                60    60    70    70    80    80   100   100    90    90    80    80    70    70    60];
            anArrayOfYValues=[80   160   160    80    80    60    60    40    40    20    20     0     0    20    20    40    40    60,...
                60    40    40    20    20     0     0    20    20    40    40    60    60    80    80];
            Project.addMetalPolygonEasy(0,anArrayOfXValues+aXOffset,anArrayOfYValues+aYOffset);
        case 'Z'
            anArrayOfXValues=[0    10    10    20    20    30    30    40    40    50    50    60    60    70    70    80    80     0,...
                0   100   100    90    90    80    80    70    70    60    60    50    50    40    40    30    30    20,...
                20   100   100     0     0];
            anArrayOfYValues=[110   110   100   100    90    90    80    80    70    70    60    60    50    50    40    40    20    20,...
                0     0    50    50    60    60    70    70    80    80    90    90   100   100   110   110   120   120,...
                140   140   160   160   110];
            Project.addMetalPolygonEasy(0,anArrayOfXValues+aXOffset,anArrayOfYValues+aYOffset);
    end
    
    % Increase the X Offset
    aXOffset=aXOffset+150;
    
end

% Determine the appropriate box size and number of cells
aBoxXSize=length(theString)*150+50;
aBoxYSize=250;
aNumberOfCellsX=aBoxXSize/10;
aNumberOfCellsY=aBoxYSize/10;

% Change the box size to fit the circuit
Project.changeBoxSizeXY(aBoxXSize,aBoxYSize);
Project.changeNumberOfCellsXY(aNumberOfCellsX,aNumberOfCellsY);

% Change the thickness of the dielectric layers
Project.changeDielectricLayerThickness(1,10);
Project.changeDielectricLayerThickness(2,10);

% Add a through-line to the circuit
Project.addMetalPolygonEasy(0,[0 aBoxXSize aBoxXSize 0],[220 220 210 210]);

% Add a copper metal type to the circuit
Project.defineNewNormalMetalType('Copper',58000000,0,.7);

% Make the through-line copper
Project.GeometryBlock.ArrayOfPolygons{length(Project.GeometryBlock.ArrayOfPolygons)}.MetalType=0;

% Add the ports to the through-line
Project.addPortAtLocation(0,215);
Project.addPortAtLocation(aBoxXSize,215);

% Add an ABS frequency sweep
Project.addAbsFrequencySweep(1,20);

% Enable current calculations
Project.enableCurrentCalculations();

% Save the project
Project.saveAs([theString '.son']);

% Open the project in XGeom
Project.openInSonnet(false);

end