%************************************************
% ATT Lumped
%   This is a tutorial on how to use Matlab 
%   to make a Sonnet netlist project. This 
%   tutorial will build att_lumped.son which
%   is presented in the Sonnet tutorials and 
%   the Sonnet user guide.
%
%   This tutorial is intended for Sonnet-Matlab 
%   interface versions 3.0 and later.
%************************************************

% Make a Sonnet Project
Project=SonnetProject();

% Convert the project into a netlist project
Project.initializeNetlist();

% Set the frequency units to megahertz
Project.changeFrequencyUnit('MHZ');

% Delete the old network
Project.deleteAllElements();

% Make a new network
Project.addNetworkElement('ATTEN',[1 2],50);

% Add a 16.77 unit resistor between port 3 and 4
Project.addResistorElement(3,4,16.77);

% Add a 16.77 unit resistor between port 5 and 6
Project.addResistorElement(5,6,16.77);

% Add a 67.11 unit resistor between port 7 and 8
Project.addResistorElement(7,8,67.11);

% Add a project file element
Project.addProjectFileElement('att_lgeo.son',[1 2 3 4 5 6 7 8],1);

% Choose an linear frequency sweep from 200 Mhz to 400 Mhz in steps of 100 Mhz
Project.addSimpleFrequencySweep(200,400,100);

% Write the project to the file
Project.saveAs('att_lumped.son');

% Simulate the project
Project.simulate();

% Open Sonnet's response viewer
Project.viewResponseData();