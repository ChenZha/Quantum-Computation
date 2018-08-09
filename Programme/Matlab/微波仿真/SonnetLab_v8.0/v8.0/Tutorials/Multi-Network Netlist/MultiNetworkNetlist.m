%************************************************
% Multi-Network Netlist Tutorial
%   This is a tutorial on how to use 
%   Matlab to make a new Sonnet project,
%   and build a multi-network netlist 
%   circuit and simulate the design.
%
%   This tutorial is intended for Sonnet-Matlab 
%   interface versions 3.0 and later.
%************************************************

% Make a Sonnet Project
Project=SonnetProject();

% Convert the project into a netlist project
Project.initializeNetlist();

% Add a second network to the project
Project.addNetworkElement('NetName1',[1 2 3 4],50);

% Add a 50 unit resistor between port 1 and 2 on network 1
Project.addResistorElement(1,2,50,1);

% Add a floating 50 unit inductor at port 3 on network 2
Project.addInductorElement(3,[],50,2);

% Add a floating 50 unit capactior at port 3 on network 2
Project.addCapacitorElement(3,[],50,'NetName1');

% Add a physical transmission line element to the second
% network of the project. The transmission line will be
% connected from node 1 to 2 with an impedance of 100,
% a length of 1000, a frequency of 10, an eeff of 1,
% and an attenuation of 10. The transmission line will
% grounded at port 1.
Project.addPhysicalTransmissionLineElement(1,2,100,1000,10,1,10,2,1);

% Add a data file to the project
Project.addDataResponseFileElement('Data.s2p',[1,2],2,4);

% Choose an ABS frequency sweep from 5 Ghz to 10 Ghz
Project.addAbsFrequencySweep(5,10);

% Write the project to the file
Project.saveAs('MultiNetworkNetlist.son');

% Simulate the project
Project.simulate();

% Open Sonnet's response viewer
Project.viewResponseData();