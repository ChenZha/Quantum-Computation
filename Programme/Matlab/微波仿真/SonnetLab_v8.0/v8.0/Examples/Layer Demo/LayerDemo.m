%LAYERDEMO   A demo of Matlab modifying and simulating a project
%   This function is a demonstration of an realistic use
%   for the ability to run SONNET from MATLAB.
%
%   This function will read in a Sonnet Project representing
%   an antenna.  This antenna will be made of many
%   square metals in a grid. This function will modify the
%   level that individual patches of the antenna reside on.
%
%   Usage: 
%      LayerDemo()             This will run the demo using
%                              the included Sonnet project
%                              file 'LayerDemo.son'.
%                           
%      LayerDemo(FileName)     This will run the demo using
%                              a particular user created file.
%
%   This demo was written by Bashir Souid

function LayerDemo(FileName)

%**************************************************************************
% These are usually the the only things a user should modify:
% The number of simulations to run and the MAX number of modifications
% from the original circuit EX: 20 means at most 20 toggles will be made.
% The number of toggles will be a random number from 1-20.
%**************************************************************************
NumberOfSimulations=10;      % Stores the number of simulations
MaxNumberOfToggles=20;
%**************************************************************************

% Greet the user and tell them what this demo does.
fprintf(1,'\n------------------------------------------------------------------------\n');
fprintf(1,['This demo will generate %d variations of the template circuit\n' ...
    'by modifying only the level in which a polygon resides.\n' ...
    'This function will also compute the bandwidths of the variations\n' ...
    'and graph the circuit in Matlab.\n'],NumberOfSimulations);
fprintf(1,'------------------------------------------------------------------------\n');

%************************************
% We will loop for X number of times
% and running the simulation. When
% we have done it that many times
% we will be able to determine which
% design was the best.
%*************************************

TheBestBandwidth=1;         % Keeps track of which one of the iterations was the best.
theBestBandwidthSoFar=0;    % Keeps track of what the best bandwidth was

for iCounter=1:NumberOfSimulations
  
    %*****************************************
    % If the user didnt specify a filename
    %   Then use the file we intended to 
    %   be used with this script.
    %*****************************************
    if nargin == 0
        FileName='LayerDemo.son';
    end
    
  %*****************************************
  % Use the SONNET project classes to
  %		make an object for this project.
  %*****************************************
  DemoProject=SonnetProject(FileName);
  
  %*****************************************
  % Empty out the SP1 data arrays
  %*****************************************
  Sp1DataFreq=[];
  Sp1DataMagnitude=[];
  StartFreq=[];
  EndFreq=[];
  hasBeenAbove3dB=false;
  
  fprintf(1,'\n--------------------------- Circuit Number %d ---------------------------\n',iCounter);
  
  %*************************************
  % Generate a random number which will
  % be the number of changes we perform.
  %*************************************
  NumberOfChanges = rand(1);
  NumberOfChanges = round(NumberOfChanges*100);
  NumberOfChanges=mod(NumberOfChanges,MaxNumberOfToggles)+1;
  fprintf(1,'This circuit is the result of changing the level for %d polygons.\n',NumberOfChanges);
  
  %*************************************
  % Generate a random number for the
  % index of the piece of metal we are
  % going to modify the properties of.
  %*************************************
  for i=1:NumberOfChanges
    %***************************************************
    % Choose a metal polygon to modify, dont do the
    % first metal polygon in the array because
    % it is our via polygon
    %***************************************************
    TheIndexForTheMetal = randi(40,1)+1;
    DemoProject.GeometryBlock.ArrayOfPolygons{TheIndexForTheMetal}.MetalizationLevelIndex=1;
        
  end
  
  %*****************************************************
  % Now that we have made the modification we can
  % write the project object back out to the file.
  % We can make the file name be anything but lets
  % make it the same so that we overwrite our
  % Original project.
  %*****************************************************
  DemoProject.saveAs(sprintf('%d_%s',iCounter,FileName));
  DemoProject.cleanProject();
  
  %*****************************************************
  % Draw out the circiut for the user to see.
  %*****************************************************
  DemoProject.drawCircuit(1);
  
  %*******************************************************
  % Call SONNET's built in simulation engine to tell
  % it to simulate the project. 
  %*******************************************************
  DemoProject.simulate();
  
  %*******************************************************
  % We are going to analyze the results of this
  % particular iteration which is of a particular
  % circuit. We will also determine if it is the
  % best design we have come across so far.
  %*******************************************************
  TheBandWidth=LayerDemoAnalyzeResults(iCounter,FileName,Sp1DataFreq,Sp1DataMagnitude,StartFreq,EndFreq,hasBeenAbove3dB);
  if TheBandWidth>theBestBandwidthSoFar
    TheBestBandwidth=iCounter;
    theBestBandwidthSoFar=TheBandWidth;
  end
  
  % Print out the individual bandwidth
  fprintf(1,'The bandwidth for design number %d is %f GHZ\n',iCounter,TheBandWidth);
  fprintf(1,'------------------------------------------------------------------------\n');
  %**************************************************
  % End of the iteration loop. At this point all
  % of the simulations sould have been completed.
  %**************************************************
end

%*******************************************************
% Now that we have run the simulation X number of times
% We can display which one was the best.
%*******************************************************
fprintf(1,'\nThe design with the best bandwidth is %d with a bandwidth of %f GHZ\n\n',TheBestBandwidth,theBestBandwidthSoFar);


end % End of demo