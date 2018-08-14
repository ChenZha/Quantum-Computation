% This script demonstrates how to use the JXYRequest class.
% This is intended to be an introductory tutorial.
%
% This demo was written by Robert Roach

Project=SonnetProject('DemoApi.son');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Export JXY magnitude data over the entire layout.
%   Frequency:  5 GHz
%   Levels:     All levels
%   Ports:      Port one
%   Resolution: One data point per cell
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Port1=JXYPort(1,5,0,50,0,0,0);                           % Port 1: Voltage=5V, Phase=0 deg, Resistance=50 Ohms, Reactamce/Inductance/Capacitance=0

RequestObject = JXYRequest();
RequestObject.addExport('Output1.csv','Out1',[],'jx',Port1,5,1,1,[0 1],true);
RequestObject.addExport('Output2.csv','Out2',[],'jy',Port1,5,1,1,0,true);
aRequestFilename = 'aRequestFile.xml';
RequestObject.write(aRequestFilename);

DataObject=Project.exportCurrents(aRequestFilename);

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

RequestObject2 = JXYRequest();
RequestObject2.addExport('Output2.csv','Out1',[],'jxy',[Port1 Port2],5,1,1,0);
aRequestFilename2 = 'aRequestFile2.xml';
RequestObject2.write(aRequestFilename2);

DataObject=Project.exportCurrents(aRequestFilename2);

% Plot the JXY data
JXYPlot(DataObject);

