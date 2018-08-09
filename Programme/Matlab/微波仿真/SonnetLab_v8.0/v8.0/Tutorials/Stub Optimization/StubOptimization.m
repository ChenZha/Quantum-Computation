%************************************************
% Single Stub Optimization
%   This is a tutorial on how to use Matlab to open an
%   existing Sonnet Project and add different length
%   stubs to get a low return loss at 5 Ghz.
%
%   This tutorial is intended for Sonnet-Matlab 
%   interface versions 3.0 and later.
%************************************************

% These values control our optimization parameters
aMaxIterations=10;
aMinStubLength=75;
aMaxStubLength=100;

% These variables keep track of the best
% loss that we have encountered so far.
aCircuitWithBestLoss=0;
aBestLossSoFar=inf;

disp('-----------------------------------------------------------------------');
disp('Beginning Optimization');
disp('-----------------------------------------------------------------------');
for iCounter=1:aMaxIterations
    
    % Open the starting project
    Project=SonnetProject('Optimization_Start.son');
    
    % Generate a stub length
    aLength=randi([aMinStubLength aMaxStubLength],1);
    
    % Add a metal polygon for the stub
    anArrayOfXCoordinates=[70;90;90;70];
    anArrayOfYCoordinates=[130;130;130-aLength;130-aLength];
    Project.addMetalPolygonEasy(0,anArrayOfXCoordinates,anArrayOfYCoordinates);
    
    % Write the project to the file
    aFilename=['Optimization_iteration_' num2str(iCounter) '.son'];
    Project.saveAs(aFilename);
    
    % Simulate the project
    Project.simulate();
    
    % Read the S2P file
    aSnPFilename=['Optimization_iteration_' num2str(iCounter) '.s2p'];
    aLossOfCurrentIteration = TouchstoneParser(aSnPFilename,1,1,5e9);
    
    disp(['  Design number ' num2str(iCounter) '/' num2str(aMaxIterations) ...
        ' has a stub length of ' num2str(aLength) ' and a return loss of ' ...
        num2str(aLossOfCurrentIteration)]);
    
    % If it is the best iteration then store its 
    % loss as the best we have seen so far.
    if aLossOfCurrentIteration < aBestLossSoFar
        aCircuitWithBestLoss=iCounter;
        aBestLossSoFar=aLossOfCurrentIteration;
        aFilenameOfBestIteration=aFilename;
    end
end

% Tell the user which iteration was best
copyfile(aFilenameOfBestIteration,'Optimization_End.son')
disp('-----------------------------------------------------------------------');
disp('Optimization Complete');
disp(['  The design with the best return loss was ' ...
    num2str(aCircuitWithBestLoss) ' with a loss of ' num2str(aBestLossSoFar)]);
disp('  Best project is stored in Optimization_End.son');
disp('-----------------------------------------------------------------------');