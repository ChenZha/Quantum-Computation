function bestBandwidthSoFar = AntennaDemoRandomToggle(Filename,OutputFilename)

%**************************************************************************
% These are usually the the only things a user should modify:
% The number of simulations to run and the MAX number of modifications
% from the original circuit EX: 20 means at most 20 toggles will be made.
% The number of toggles will be a random number from 1-20.
%**************************************************************************

numberOfSimulations=15;

%************************************
% We will loop for X number of times
% and running the simulation. When
% we have done it that many times
% we will be able to determine which
% design was the best.
%*************************************

aBaseFileName=strrep(OutputFilename,'Best.son','');
fprintf(1,'\n------------------------------------------------------------------------\n');
fprintf(1,'%s\n',aBaseFileName);
fprintf(1,'   - Random Toggles\n');
fprintf(1,'------------------------------------------------------------------------\n');

designWithBestBandwidthSoFar=1;         % Keeps track of which one of the iterations was the best.
bestBandwidthSoFar=0;                   % Keeps track of what the best bandwidth was

%*****************************************
% Use the SONNET project classes to make an object for this project.
%*****************************************
DemoProject=SonnetProject(Filename);

% Find the polygon that is our VIA; it will be the last polygon in the array.
aIndexForVia=length(DemoProject.GeometryBlock.ArrayOfPolygons);

% We can find the polygon that is behind the via by searching for its centroid
aCentroidX=DemoProject.GeometryBlock.ArrayOfPolygons{aIndexForVia}.CentroidXCoordinate;
aCentroidY=DemoProject.GeometryBlock.ArrayOfPolygons{aIndexForVia}.CentroidYCoordinate;
aViaAndPolygonNextToVia=DemoProject.findPolygonUsingCentroidXY(aCentroidX,aCentroidY);

for iCounter=1:numberOfSimulations
       
    %*************************************
    % Generate a random number which will
    % be the number of changes we perform.
    %*************************************
    numberOfChanges = rand(1);
    numberOfChanges = round(numberOfChanges*100);
    numberOfPolygons=length(DemoProject.GeometryBlock.ArrayOfPolygons);
    numberOfChanges=mod(numberOfChanges,numberOfPolygons)+1;
    
    %*************************************
    % Generate a random number for the
    % index of the piece of metal we are
    % going to modify the properties of.
    %*************************************
    for i=1:numberOfChanges
        TheIndexForTheMetal = randi(numberOfPolygons,1);
        if DemoProject.GeometryBlock.ArrayOfPolygons{TheIndexForTheMetal}.MetalType==0
            DemoProject.GeometryBlock.ArrayOfPolygons{TheIndexForTheMetal}.MetalType=1;
        else
            DemoProject.GeometryBlock.ArrayOfPolygons{TheIndexForTheMetal}.MetalType=0;
        end       
    end
    
    % Make the via and the polygon behind it thick copper
    for jCounter=1:length(aViaAndPolygonNextToVia)
        aViaAndPolygonNextToVia(jCounter).MetalType=0;
    end
    
    %*****************************************************
    % Now that we have made the modification we can
    % write the project object back out to a file.
    %*****************************************************    
    DemoProject.saveAs(sprintf('X%s_%d.son',aBaseFileName,iCounter));
    
    %*****************************************************
    % Open the project, make a version without thin patches
    %*****************************************************  
    aProjectNoThinPatches=SonnetProject(sprintf('X%s_%d.son',aBaseFileName,iCounter));
    
    % Remove the thin patches by deleting them
    aMaxNumberOfPolygons=length(aProjectNoThinPatches.GeometryBlock.ArrayOfPolygons);
    jCounter=1;
    while (jCounter < aMaxNumberOfPolygons)
        if aProjectNoThinPatches.GeometryBlock.ArrayOfPolygons{jCounter}.MetalType==1
            aProjectNoThinPatches.GeometryBlock.ArrayOfPolygons(jCounter)=[];
            aMaxNumberOfPolygons=aMaxNumberOfPolygons-1;
            jCounter=jCounter-1;
        end
        jCounter=jCounter+1;
    end
    
    aIterationFileName=sprintf('%s_%d.son',aBaseFileName,iCounter);
    aProjectNoThinPatches.saveAs(aIterationFileName);
    
    %*******************************************************
    % Call SONNET's built in simulation engine to tell
    % it to simulate the project.
    %*******************************************************
    [status message]=aProjectNoThinPatches.simulate('-t -c');
    if status==1
        error(['Simulation failed:' message]);
    end
    
    %*******************************************************
    % We are going to analyze the results of this
    % particular iteration which is of a particular
    % circuit. We will also determine if it is the
    % best design we have come across so far.
    %*******************************************************
    theBandWidth=AntennaDemoAnalyzeResults(aIterationFileName);
    if theBandWidth>bestBandwidthSoFar
        designWithBestBandwidthSoFar=iCounter;
        bestBandwidthSoFar=theBandWidth;
    end
    
    % Revert our changes back
    for jCounter=1:length(DemoProject.GeometryBlock.ArrayOfPolygons)
        DemoProject.GeometryBlock.ArrayOfPolygons{jCounter}.MetalType=0;
    end
    
    % Print out the individual bandwidth
    fprintf(1,'   Design number %d/%d has a bandwidth of %f percent\n',iCounter,numberOfSimulations,theBandWidth);
end

fprintf(1,'\n   The design with the best bandwidth is %d with a bandwidth of %f percent\n',designWithBestBandwidthSoFar,bestBandwidthSoFar);

% If the original bandwidth is zero then throw an error
if bestBandwidthSoFar == 0
   error('The circuit has zero bandwidth.'); 
end

% Copy the best iteration to the output filename
aBestProjectFileName=sprintf('X%s_%d.son',aBaseFileName,designWithBestBandwidthSoFar);
copyfile(aBestProjectFileName,OutputFilename)

end