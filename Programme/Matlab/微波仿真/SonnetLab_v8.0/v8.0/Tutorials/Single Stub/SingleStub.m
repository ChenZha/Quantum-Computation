%************************************************
% Single Stub
%   This is a tutorial on how to use Matlab to 
%   make a new Sonnet project, build a single 
%   stub circuit and simulate the design.
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
% Add metalization to the project.
%   - Draw a throughline
%   - Draw a stub connected to the throughline
%   - Draw a via polygon connected to the stub
%************************************************
% Make and add a metal polygon to act as the thoughline
anArrayOfXCoordinates=[0;160;160;0];
anArrayOfYCoordinates=[130;130;150;150];
Project.addMetalPolygonEasy(0,anArrayOfXCoordinates,anArrayOfYCoordinates);

% Make and add a metal polygon to act as the stub
anArrayOfXCoordinates=[70;90;90;70];
anArrayOfYCoordinates=[130;130;20;20];
Project.addMetalPolygonEasy(0,anArrayOfXCoordinates,anArrayOfYCoordinates);

% Make and add a via polygon
anArrayOfXCoordinates=[70;90;90;70];
anArrayOfYCoordinates=[20;20;40;40];
Project.addViaPolygonEasy(0,'GND',anArrayOfXCoordinates,anArrayOfYCoordinates);

%************************************************
% Add ports to both ends of the throughline.
% We added the throughline at coordinates:
%       (0,130)(160,130)(160,130)(160,150)
%
%   We want our port to be on the two ends of 
%   the throughline so the coorinate for the 
%   first port should be (0,100) and the 
%   second port should be located at (330,100).
%************************************************
Project.addPortAtLocation(0,140);
Project.addPortAtLocation(160,140);

%************************************************
% Add an ABS frequency sweep to the project
%   Start Frequency:  5 Ghz
%   End Frequency:   10 Ghz
%************************************************
Project.addAbsFrequencySweep(5,10);

%************************************************
% Save the project as 'DStub.son'
%************************************************
Project.saveAs('SingleStub.son');

%************************************************
% Analyze the project using Sonnet em
%************************************************
Project.simulate();

%************************************************
% Open Sonnet's response viewer
%************************************************
Project.viewResponseData();