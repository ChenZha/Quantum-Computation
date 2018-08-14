% BeginnerDemo      An introductory demo of the Sonnet-Matlab Interface
%   This is a very simple demo of how Sonnet projects can be 
%   built and simulated using Matlab.
%
%   This demo was written by Bashir Souid

% Make a Sonnet Project
Project=SonnetProject();

% Write the project to the file
Project.saveAs('Demo1.son');

% Set the dielectric layer thicknesses
Project.changeDielectricLayerThickness(1,50);
Project.changeDielectricLayerThickness(2,5);
Project.openInSonnet();

% Add a metal polygon
anArrayOfXCoordinates=[0;160;160;0];
anArrayOfYCoordinates=[130;130;150;150];
Project.addMetalPolygonEasy(0,anArrayOfXCoordinates,anArrayOfYCoordinates);
Project.openInSonnet();

% Add a metal polygon
anArrayOfXCoordinates=[70;90;90;70];
anArrayOfYCoordinates=[130;130;20;20];
Project.addMetalPolygonEasy(0,anArrayOfXCoordinates,anArrayOfYCoordinates);
Project.openInSonnet();

% Add a via polygon
anArrayOfXCoordinates=[70;90;90;70];
anArrayOfYCoordinates=[20;20;40;40];
Project.addViaPolygonEasy(0,1,anArrayOfXCoordinates,anArrayOfYCoordinates);
Project.openInSonnet();

% Snap the polygons to the grid
Project.snapPolygonsToGrid();
Project.openInSonnet();

% Choose an analysis type
Project.addAbsFrequencySweep(5,50);

% Make two ports
Project.addPortToPolygon(1,2);
Project.addPortToPolygon(1,4);
Project.openInSonnet();

% Add an output file and then resimulate
Project.addTouchstoneOutput;
Project.simulate('-c');

% Read Touchstone Output File for S11 and S21
S11 = TouchstoneParser('Demo1.s2p',1,1);
S21 = TouchstoneParser('Demo1.s2p',2,1);

% Convert the S11 and S21 data to dB
S11dB = 20*log10(abs(S11(:,2)));
S21dB = 20*log10(abs(S21(:,2)));

% Plot S11 and S21 data in dB
F = S11(:,1);
plot(F,S11dB,F,S21dB);
title('dB(S_2_1) and dB(S_1_1) vs Freq.');
xlabel('F [GHz]');
ylabel('dB(S)');
legend('dB(S_1_1)','dB(S_2_1)','Location','Best')
grid on
