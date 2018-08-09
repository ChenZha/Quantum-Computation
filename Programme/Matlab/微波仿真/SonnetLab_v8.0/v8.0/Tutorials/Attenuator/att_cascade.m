%************************************************
% ATT Cascade
%   This is a tutorial on how to use Matlab 
%   to make a Sonnet netlist project. This 
%   tutorial will build att_cascade.son which
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
Project.addNetworkElement('RESNET',[1 3],50);

% Add a data file to the project
Project.addDataResponseFileElement('att_res16.s2p',[1,2]);

% Add a data file to the project
Project.addDataResponseFileElement('att_res16.s2p',[2,3]);

% Choose an linear frequency sweep from 200 Mhz to 400 Mhz in steps of 100 Mhz
Project.addSimpleFrequencySweep(200,400,100);

% Write the project to the file
Project.saveAs('att_cascade.son');

% Simulate the project
Project.simulate();

% Open Sonnet's response viewer
Project.viewResponseData();