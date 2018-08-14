%************************************************
% ATT Lumped2
%   This is a tutorial on how to use Matlab 
%   to make a Sonnet netlist project. This 
%   tutorial will build att_lumped2.son which
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

% Define parameters for the project
Project.defineVariable('Z3',16.77);
Project.defineVariable('Z4',16.77);
Project.defineVariable('Z5',67.11);

% Add a 16.77 unit resistor at port 3
Project.addResistorElement(3,[],'Z3');

% Add a 16.77 unit resistor at port 4
Project.addResistorElement(4,[],'Z4');

% Add a 67.11 unit resistor at port 5
Project.addResistorElement(5,[],'Z5');

% Add a project file element
Project.addProjectFileElement('att_lgeo2.son',[1 2 3 4 5],1);

% Choose an linear frequency sweep from 200 Mhz to 400 Mhz in steps of 100 Mhz
Project.addSimpleFrequencySweep(200,400,100);

% Write the project to the file
Project.saveAs('att_lumped2.son');

% Simulate the project
Project.simulate();

% Open Sonnet's response viewer
Project.viewResponseData();