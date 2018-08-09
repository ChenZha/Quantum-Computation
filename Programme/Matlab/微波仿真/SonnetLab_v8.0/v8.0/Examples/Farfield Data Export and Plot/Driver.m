% This simple example will open a Sonnet project file with SonnetLab,
% export the farfield pattern data to an output file (the project
% is automatically simulated if necessary) and will produce a 3D
% plot of the pattern data at 2.4 GHz.
%
% This example was written by Bashir Souid at Sonnet Software

% The below command will open the Sonnet project file 'Antenna.son' 
% which is in the same directory as the script
Project = SonnetProject('Antenna.son');

% The below command will export pattern data for
%   - Theta Values from 0 to 85 in steps of 1
%   - Phi Value from 0 to 360 in steps of 1
%   - Frequency Values of 2.4 GHz
%   - Port 1 excitation: MAG=1, PHASE=0, R=50, X=0, L=0, C=0
aPatternData=Project.exportPattern([0 360 1], [0 85 1], 2.4, [1 1 0 50 0 0 0]);
    
% The following command will create a 3D plot of the 
% farfield data file which is called 'Antenna.pat'.
PatternPlot(aPatternData.Filename);