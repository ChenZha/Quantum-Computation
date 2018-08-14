function AntennaDemoAdjacentToggle(Filename,OutputFilename,YNumberOfPatches)

%*******************************************************
%   We want to randomly flip patches that are adjacent
%   to the thin patches in order to hopefully build
%   a larger shape.
%*******************************************************
%#ok<*AGROW>
aBaseFileName=strrep(OutputFilename,'Best.son','');
fprintf(1,'\n------------------------------------------------------------------------\n');
fprintf(1,'%s\n',aBaseFileName);
fprintf(1,'   - Toggle Adjacent Patches\n');
fprintf(1,'------------------------------------------------------------------------\n');

% This is the number of simulations we will do in this phase
numberOfSimulations=15;

% Open the project and save it as design one
DemoProject=SonnetProject(Filename);
DemoProject.saveAs(sprintf('X%s_1.son',aBaseFileName));

% Open the project, make a version without thin patches
aProjectNoThinPatches=SonnetProject(sprintf('X%s_1.son',aBaseFileName));

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

aIterationFileName=sprintf('%s_1.son',aBaseFileName);
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
bestBandwidthSoFar=AntennaDemoAnalyzeResults(aIterationFileName);
designWithBestBandwidthSoFar=1;         % Keeps track of which one of the iterations was the best.
disp(['   The orginal bandwidth is ' num2str(bestBandwidthSoFar)]);

% Find the Y centroid for patches on the top row
TopRowValue=DemoProject.GeometryBlock.ArrayOfPolygons{1}.CentroidYCoordinate;

% Find the Y centroid for patches on the bottom row
BottomRowValue=DemoProject.GeometryBlock.ArrayOfPolygons{YNumberOfPatches}.CentroidYCoordinate;

% Find all the adjacent patches
anArrayOfAdjacentPolygons={};
for iCounter=1:length(DemoProject.GeometryBlock.ArrayOfPolygons)
    if DemoProject.GeometryBlock.ArrayOfPolygons{iCounter}.MetalType==1
        
        anArrayOfAdjacentPolygons{length(anArrayOfAdjacentPolygons)+1}=DemoProject.GeometryBlock.ArrayOfPolygons{iCounter};
        YCentroidValue=DemoProject.GeometryBlock.ArrayOfPolygons{iCounter}.CentroidYCoordinate;
        
        if (iCounter-YNumberOfPatches)>0 && (iCounter-YNumberOfPatches) < length(DemoProject.GeometryBlock.ArrayOfPolygons)% left
            anArrayOfAdjacentPolygons{length(anArrayOfAdjacentPolygons)+1}=DemoProject.GeometryBlock.ArrayOfPolygons{iCounter-YNumberOfPatches};
        end
        if (iCounter+YNumberOfPatches)>0 && (iCounter+YNumberOfPatches) < length(DemoProject.GeometryBlock.ArrayOfPolygons)% right
            anArrayOfAdjacentPolygons{length(anArrayOfAdjacentPolygons)+1}=DemoProject.GeometryBlock.ArrayOfPolygons{iCounter+YNumberOfPatches};
        end
        
        % If it isnt on the top row
        if YCentroidValue ~= TopRowValue
            if (iCounter-1)>0 && (iCounter-1) < length(DemoProject.GeometryBlock.ArrayOfPolygons)% above
                anArrayOfAdjacentPolygons{length(anArrayOfAdjacentPolygons)+1}=DemoProject.GeometryBlock.ArrayOfPolygons{iCounter-1};
            end
            if (iCounter-YNumberOfPatches-1)>0 && (iCounter-YNumberOfPatches-1) < length(DemoProject.GeometryBlock.ArrayOfPolygons)% left-above
                anArrayOfAdjacentPolygons{length(anArrayOfAdjacentPolygons)+1}=DemoProject.GeometryBlock.ArrayOfPolygons{iCounter-YNumberOfPatches-1};
            end
            if (iCounter+YNumberOfPatches-1)>0 && (iCounter+YNumberOfPatches-1) < length(DemoProject.GeometryBlock.ArrayOfPolygons)% right-above
                anArrayOfAdjacentPolygons{length(anArrayOfAdjacentPolygons)+1}=DemoProject.GeometryBlock.ArrayOfPolygons{iCounter+YNumberOfPatches-1};
            end
        end
        
        % If it isnt on the bottom row
        if YCentroidValue ~= BottomRowValue
            if (iCounter+1)>0 && (iCounter+1) < length(DemoProject.GeometryBlock.ArrayOfPolygons)% below
                anArrayOfAdjacentPolygons{length(anArrayOfAdjacentPolygons)+1}=DemoProject.GeometryBlock.ArrayOfPolygons{iCounter+1};
            end
            if (iCounter-YNumberOfPatches+1)>0 && (iCounter-YNumberOfPatches+1) < length(DemoProject.GeometryBlock.ArrayOfPolygons)% left-below
                anArrayOfAdjacentPolygons{length(anArrayOfAdjacentPolygons)+1}=DemoProject.GeometryBlock.ArrayOfPolygons{iCounter-YNumberOfPatches+1};
            end
            if (iCounter+YNumberOfPatches+1)>0 && (iCounter+YNumberOfPatches+1) < length(DemoProject.GeometryBlock.ArrayOfPolygons)% right-below
                anArrayOfAdjacentPolygons{length(anArrayOfAdjacentPolygons)+1}=DemoProject.GeometryBlock.ArrayOfPolygons{iCounter+YNumberOfPatches+1};
            end
        end
        
    end
end

% Remove duplicates from the array
aMaxValue=length(anArrayOfAdjacentPolygons);
iCounter=1;
while iCounter < aMaxValue
    jCounter=iCounter+1;
    while jCounter < aMaxValue
        if anArrayOfAdjacentPolygons{iCounter} == anArrayOfAdjacentPolygons{jCounter}
            anArrayOfAdjacentPolygons(jCounter)=[];
            aMaxValue=aMaxValue-1;
        end
        jCounter=jCounter+1;
    end
    iCounter=iCounter+1;
end

% Find the polygon that is our VIA; it will be the last polygon in the array.
aIndexForVia=length(DemoProject.GeometryBlock.ArrayOfPolygons);

% We can find the polygon that is behind the via by searching for its centroid
aCentroidX=DemoProject.GeometryBlock.ArrayOfPolygons{aIndexForVia}.CentroidXCoordinate;
aCentroidY=DemoProject.GeometryBlock.ArrayOfPolygons{aIndexForVia}.CentroidYCoordinate;
aViaAndPolygonNextToVia=DemoProject.findPolygonUsingCentroidXY(aCentroidX,aCentroidY);

% Run a number of simulations
for iCounter=2:numberOfSimulations+1
    
    %*************************************
    % Generate a random number which will
    % be the number of changes we perform.
    %*************************************
    numberOfChanges = rand(1);
    numberOfChanges = round(numberOfChanges*100);
    maxNumberOfToggles=length(anArrayOfAdjacentPolygons);
    numberOfChanges=mod(numberOfChanges,maxNumberOfToggles)+1;
    
    %*************************************
    % Generate a random number for the
    % index of the piece of metal we are
    % going to modify the properties of.
    %*************************************
    aToggleLog={};
    for jCounter=1:numberOfChanges
        TheIndexForTheMetal = randi(length(anArrayOfAdjacentPolygons),1);
        if anArrayOfAdjacentPolygons{TheIndexForTheMetal}.MetalType==0
            anArrayOfAdjacentPolygons{TheIndexForTheMetal}.MetalType=1;
            aToggleLog{length(aToggleLog)+1}=anArrayOfAdjacentPolygons{TheIndexForTheMetal};
            
        else
            anArrayOfAdjacentPolygons{TheIndexForTheMetal}.MetalType=0;
            aToggleLog{length(aToggleLog)+1}=anArrayOfAdjacentPolygons{TheIndexForTheMetal};
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
    theBandWidth=AntennaDemoAnalyzeResults(sprintf('%s_%d.son',aBaseFileName,iCounter));
    if theBandWidth>bestBandwidthSoFar
        designWithBestBandwidthSoFar=iCounter;
        bestBandwidthSoFar=theBandWidth;
    end
    
    % Go back through the log and untoggle 
    % all the polygons that were toggled
    for jCounter=1:length(aToggleLog)        
        % Make the toggle
        if aToggleLog{jCounter}.MetalType==0
            aToggleLog{jCounter}.MetalType=1;
        else
            aToggleLog{jCounter}.MetalType=0;
        end 
    end
    
    % Print out the individual bandwidth
    fprintf(1,'   Design number %d/%d has a bandwidth of %f percent\n',iCounter,numberOfSimulations,theBandWidth);
end

fprintf(1,'\n   The design with the best bandwidth is %d with a bandwidth of %f GHZ\n',designWithBestBandwidthSoFar,bestBandwidthSoFar);

% If the original bandwidth is zero then throw an error
if bestBandwidthSoFar == 0
    error('The circuit has zero bandwidth.');
end

% Copy the best iteration to the output filename
aBestProjectFileName=sprintf('X%s_%d.son',aBaseFileName,designWithBestBandwidthSoFar);
copyfile(aBestProjectFileName,OutputFilename)