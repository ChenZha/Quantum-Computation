% This script demonstrates various JXY and heat flux export options.
% This is intended to be an introductory tutorial.
%
% This demo was written by Bashir Souid

Project=SonnetProject('DemoApi.son');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Export JXY magnitude data over the entire layout.
%   Frequency:  5 GHz
%   Levels:     All levels
%   Ports:      Port one
%   Resolution: One data point per cell
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Port1=JXYPort(1,5,0,50,0,0,0);                           % Port 1: Voltage=5V, Phase=0 deg, Resistance=50 Ohms, Reactamce/Inductance/Capacitance=0
DataObject=Project.exportCurrents([],'JXY',Port1,5);

% Plot the JXY data
JXYPlot(DataObject);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Export JXY magnitude data over the entire layout.
%   Frequency:  5 GHz
%   Levels:     Zero
%   Ports:      Both ports
%   Resolution: Every one mil
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Port1=JXYPort(1,5,0,50,0,0,0);                           % Port 1: Voltage=5V, Phase=0 deg, Resistance=50 Ohms, Reactamce/Inductance/Capacitance=0
Port2=JXYPort(2,5,0,50,0,0,0);                           % Port 2: Voltage=5V, Phase=0 deg, Resistance=50 Ohms, Reactamce/Inductance/Capacitance=0
DataObject=Project.exportCurrents([],'JXY',[Port1 Port2],5,1,1,0);

% Plot the JXY data
JXYPlot(DataObject);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Export JXY magnitude data over a rectangular region.
%   Frequency:  5 GHz
%   Levels:     All levels
%   Ports:      Port one
%   Resolution: One data point per cell
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Port1=JXYPort(1,5,0,50,0,0,0);                          % Port 1: Voltage=5V, Phase=0 deg, Resistance=50 Ohms, Reactamce/Inductance/Capacitance=0
Region=JXYRectangle(10,250,542,375);                    % Region: Left=10,    Right=250,   Top=542,            Bottom=375
DataObject=Project.exportCurrents(Region,'JXY',Port1,5,1,1,0);

% Plot the JXY data
JXYPlot(DataObject);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Export heat flux magnitude data over the entire layout.
%   Frequency:  5 GHz
%   Levels:     Zero
%   Ports:      Both ports
%   Resolution: Every one mil
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Port1=JXYPort(1,5,0,50,0,0,0);                           % Port 1: Voltage=5V, Phase=0 deg, Resistance=50 Ohms, Reactamce/Inductance/Capacitance=0
Port2=JXYPort(2,5,0,50,0,0,0);                           % Port 2: Voltage=5V, Phase=0 deg, Resistance=50 Ohms, Reactamce/Inductance/Capacitance=0
DataObject=Project.ExportHeatFlux([],[Port1 Port2],5,1,1,0);

% Plot the JXY data
JXYPlot(DataObject);