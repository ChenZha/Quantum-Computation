%************************************************
% Netlist
%   This is a tutorial on how to use Matlab 
%   to make a Sonnet netlist project. This 
%   tutorial will build and simulate a netlist 
%   circuit.
%
%   This tutorial is intended for Sonnet-Matlab 
%   interface versions 3.0 and later.
%************************************************

% Make a Sonnet Project
Project=SonnetProject();

% Convert the project into a netlist project
Project.initializeNetlist();

% Add a 50 unit resistor between port 1 and 2
Project.addResistorElement(1,2,50);

% Add a floating 50 unit capacitor at port 1
Project.addCapacitorElement(1,[],50);

% Add a transmission line element to the project connected from node 
% 1 to 2 with an impedance of 100, an electrical length of 1000 
% and a frequency of 10.
Project.addTransmissionLineElement(1,2,100,1000,10);

% Add a physical transmission line element to the first
% network of the project. The transmission line will be
% connected from node 1 to 2 with an impedance of 100,
% a length of 1000, a frequency of 10, an eeff of 1,
% and an attenuation of 10.
Project.addPhysicalTransmissionLineElement(1,2,100,1000,10,1,10);

% Add a data file to the project
Project.addDataResponseFileElement('Data.s2p',[1,2]);

% Add a project file element
Project.addProjectFileElement('projectFile.son',[1,2],0);

% Choose an ABS frequency sweep from 5 Ghz to 10 Ghz
Project.addAbsFrequencySweep(5,10);

% Write the project to the file
Project.saveAs('Netlist.son');

% Simulate the project
Project.simulate();

% Open Sonnet's response viewer
Project.viewResponseData();