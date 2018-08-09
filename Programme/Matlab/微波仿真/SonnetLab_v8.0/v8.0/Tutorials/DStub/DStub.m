%************************************************
% DStub Tutorial
%   This script will walk through the 
%   tutorial presented in Chapter 5 of the 
%   Sonnet Getting Started Guide.
%
%   This tutorial shows how easy it can be to
%   make a Sonnet project, simulate it, and view
%   the response.
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
% Specify the box settings
%   - We want the box size to be 330x200 mils
%   - We want the cell size to be 10x10 mils
%************************************************
% Change the size of the box
Project.changeBoxSize(330,200);

% Change the cell size (the number of cells
% in each direction will be modified to realize
% a cell size of 10x10 mils).
Project.changeCellSizeUsingNumberOfCells(10,10);

%************************************************
% Modify the dielectric layers
%   - We want the change the thickness  
%     of the first layer to 20 mils.
%   - We want the second layer to have
%     these values:
%       Name: Alumina
%       Thickness: 20
%       Erel: 9.8
%       Dielectric Loss Tangent: 1.0e-4
%       Dielectric Conductivity: 0.0 
%       Mrel: 1.0
%       Magnetic Loss Tangent: 0.0
%************************************************
% Change the thickness of the first dielectric layer
Project.changeDielectricLayerThickness(1,20);

% Delete the default second layer so we can replace it with a new alumina one
Project.deleteLayer(2);

% Add the alumina layer to the project.
Project.addDielectricLayer('Alumina',20,9.8,1,1.0e-4,0,0);

%************************************************
% Add metalization to the project
%   - Make a throughline
%   - Make a stub
%   - Copy the stub 
%   - Flip the new stub in both
%     the X and Y directions.
%   - Move the new stub such that it
%     is above the throughline.
%
% Note: Sonnet projects have an inverted Y 
%       axis. Y coordinate values of zero
%       correspond to the top of the box.
%
% Note: By default new polygons will be made
%       from lossless metal. The tutorial in
%       Chapter 5 of Sonnet's Getting Started
%       guide makes three lossless metal polygons, 
%       converts them to copper and then converts
%       them back to lossless metal. This tutorial
%       follows the same steps even though they 
%       produce an identical circuit.
%************************************************
% Make a throughline on level zero
aVectorOfXCoordinates=[0 330 330 0];
aVectorOfYCoordinates=[90 90 110 110];
aThroughLine=Project.addMetalPolygonEasy(0,aVectorOfXCoordinates,aVectorOfYCoordinates);

% Make a stub on level zero
aVectorOfXCoordinates=[60 60 80 270 270 80 80 60];
aVectorOfYCoordinates=[110 130 150 150 130 130 110 110];
aBottomStub=Project.addMetalPolygonEasy(0,aVectorOfXCoordinates,aVectorOfYCoordinates);

% We want to copy the bottom stub so send the polygon object 
% to the copyPolygon method. This is the third polygon in
% our project so we cant get a reference to it by using getPolygon(3)
aTopStub=Project.duplicatePolygon(aBottomStub);

% Flip the polygon in the X and Y directions
aTopStub.flipPolygonX();
aTopStub.flipPolygonY();

% Move the polygon so it is adjacent to the throughline
% This is a move such that its center is at (165,70)
aTopStub.movePolygon(165,70);

%************************************************
% Add a new metal type to the project
%   The metal type will be:
%       Name: Half Oz Copper
%       Type: Normal
%       Conductivity: 5.8e7
%       Thickness: .7
%************************************************
Project.defineNewNormalMetalType('Half Oz Copper',5.8e7,0,.7);

%************************************************
% Convert the three polygons in the project into
% Half Oz Copper. Later in the tutorial we will
% convert them back to lossless metal.
%************************************************
Project.changePolygonType(aThroughLine,'Half Oz Copper');
Project.changePolygonType(aTopStub,'Half Oz Copper');
Project.changePolygonType(aBottomStub,'Half Oz Copper');

%************************************************
% Convert the three polygons in the project into
% Lossless metal.
%************************************************
Project.changePolygonType(aThroughLine,'Lossless');
Project.changePolygonType(aTopStub,'Lossless');
Project.changePolygonType(aBottomStub,'Lossless');

%************************************************
% Add ports to both ends of the throughline.
%   We added the throughline at coordinates:
%       (0,90)(330,90)(330,110)(0,110)
%
%   We want our port to be on the two ends of 
%   the throughline so the coorinate for the 
%   first port should be (0,100) and the 
%   second port should be located at (330,100).
%************************************************
Project.addPortAtLocation(0,100);
Project.addPortAtLocation(330,100);

%************************************************
% Save the project as 'DStub.son'
%************************************************
Project.saveAs('DStub.son');

%************************************************
% Add a linear sweep to the project
%   Start Frequency:  4  Ghz
%   End Frequency:    8  Ghz
%   Step Frequency:  .25 Ghz
%************************************************
Project.addSimpleFrequencySweep(4.0,8.0,0.25);

%************************************************
% Analyze the project using Sonnet em
%************************************************
Project.simulate();

%************************************************
% View the response
%************************************************
Project.viewResponseData();