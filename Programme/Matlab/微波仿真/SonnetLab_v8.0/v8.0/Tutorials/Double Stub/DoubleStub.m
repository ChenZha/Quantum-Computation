%************************************************
% Double Stub
%   This is a tutorial on how to use Matlab 
%   to make a new Sonnet project, build a double 
%   stub circuit and simulate the design. This 
%   tutorial is a little more advanced than the 
%   previous single stub tutorial.
%
%   This tutorial is intended for Sonnet-Matlab 
%   interface versions 3.0 and later.
%************************************************

%************************************************
% Make a new Sonnet project. This project will
% be the same as a default Sonnet geometry project.
%************************************************
Project=SonnetProject();

%************************************************
% Modify the dielectric layers
%   - We want the change the thickness  
%     of the first layer to 50 mils.
%   - We want the change the thickness  
%     of the second layer to 5 mils.
%************************************************
Project.changeDielectricLayerThickness(1,50);
Project.changeDielectricLayerThickness(2,5);

%************************************************
% Change the box size and cell size
%   - Box Length should be 200
%   - Box Width should be 200
%   - Cell Length should be 10
%   - Cell Width should be 10
%************************************************
Project.changeBoxSize(200,200);

% We want a cell size of 10 mils X 10 mils.
% we can change the number of cells that 
% span the box length and width in order to
% realize the desired cell size.
 Project.changeCellSizeUsingNumberOfCells(10,10);
 
%************************************************
% Add a new metal type to the project
%   The metal type will be:
%       Name: Copper
%       Type: Normal
%       Conductivity: 5.8e7
%       Thickness: 1.4
%************************************************
Project.defineNewNormalMetalType('Copper',58000000,0,1.4);

%************************************************
% Add metalization to the project.
%   - Draw a throughline.
%   - Draw a copper off-grid stub  
%       connected to the throughline.
%   - Draw a copper off-grid via polygon 
%       connected to the stub.
%************************************************
% Make and add a metal polygon to act as the thoughline
anArrayOfXCoordinates=[0;200;200;0];
anArrayOfYCoordinates=[130;130;150;150];
Project.addMetalPolygonEasy(0,anArrayOfXCoordinates,anArrayOfYCoordinates,'Copper');

% Make and add a metal polygon to act as a stub
anArrayOfXCoordinates=[65;80;80;65];
anArrayOfYCoordinates=[130;130;20;20];
Project.addMetalPolygonEasy(0,anArrayOfXCoordinates,anArrayOfYCoordinates,'Copper');

% Make and add a metal polygon to act as a stub
anArrayOfXCoordinates=[85;100;100;85];
anArrayOfYCoordinates=[130;130;20;20];
Project.addMetalPolygonEasy(0,anArrayOfXCoordinates,anArrayOfYCoordinates,'Copper');

% Make and add a via polygon
anArrayOfXCoordinates=[65;80;80;65];
anArrayOfYCoordinates=[20;20;40;40];
Project.addViaPolygonEasy(0,'GND',anArrayOfXCoordinates,anArrayOfYCoordinates,'Copper');

% Make and add a via polygon
anArrayOfXCoordinates=[85;100;100;85];
anArrayOfYCoordinates=[20;20;40;40];
Project.addViaPolygonEasy(0,'GND',anArrayOfXCoordinates,anArrayOfYCoordinates,'Copper');

%************************************************
% Snap the polygons to the grid
%************************************************
Project.snapPolygonsToGrid();

%************************************************
% Add ports to both ends of the throughline.
%   We added the throughline at coordinates:
%       (0,130)(200,130)(200,150)(0,150)
%
%   We want our port to be on the two ends of 
%   the throughline so the coorinate for the 
%   first port should be (0,140) and the 
%   second port should be located at (200,140).
%************************************************
Project.addPortAtLocation(0,140);
Project.addPortAtLocation(200,140);

%************************************************
% View the new circuit with SonnetLab's 
% circuit plot routine and with the
% Sonnet editor.
%************************************************
% Draw the circuit with SonnetLab
Project.drawCircuit();

%************************************************
% Add an ABS frequency sweep to the project
%   Start Frequency:  5 Ghz
%   End Frequency:   10 Ghz
%************************************************
Project.addAbsFrequencySweep(5,10);

%************************************************
% Add an output file
%************************************************
Project.addTouchstoneOutput();

%************************************************
% Enable current calculations
%************************************************
Project.enableCurrentCalculations();

%************************************************
% Save the project as 'DoubleStub.son'
%************************************************
Project.saveAs('DoubleStub.son');

%************************************************
% Analyze the project using Sonnet em
%************************************************
Project.simulate();

%************************************************
% View the circuit, the response and the currents
%************************************************
Project.openInSonnet(false);
Project.viewResponseData();
Project.viewCurrents();