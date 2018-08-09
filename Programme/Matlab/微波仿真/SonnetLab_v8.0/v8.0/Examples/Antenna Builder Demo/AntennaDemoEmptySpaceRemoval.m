function AntennaDemoEmptySpaceRemoval(Filename,OutputFilename,YNumberOfPatches)

%*******************************************************
%   One by one make thin blobs thick and see if it
%   it better off with those blobs being thick.
%*******************************************************

aBaseFileName=strrep(OutputFilename,'Best.son','');
fprintf(1,'\n------------------------------------------------------------------------\n');
fprintf(1,'%s\n',aBaseFileName);
fprintf(1,'   - Remove Empty Spaces\n');
fprintf(1,'------------------------------------------------------------------------\n');

% Open the best project so far
DemoProject=SonnetProject(Filename);

% Set the analysis settings
DemoProject.addAbsFrequencySweep(.4,.7)

% Make a version without thin patches
% Remove the thin patches by deleting them
aMaxNumberOfPolygons=length(DemoProject.GeometryBlock.ArrayOfPolygons);
jCounter=1;
while (jCounter < aMaxNumberOfPolygons)
    if DemoProject.GeometryBlock.ArrayOfPolygons{jCounter}.MetalType==1
        DemoProject.GeometryBlock.ArrayOfPolygons(jCounter)=[];
        aMaxNumberOfPolygons=aMaxNumberOfPolygons-1;
        jCounter=jCounter-1;
    end
    jCounter=jCounter+1;
end

aIterationFileName=sprintf('%s_Original.son',aBaseFileName);
DemoProject.saveAs(aIterationFileName);

%*******************************************************
% Call SONNET's built in simulation engine to tell
% it to simulate the project.
%*******************************************************
[status message]=DemoProject.simulate('-t -c');
if status==1
    error(['Simulation failed:' message]);
end

% Find the bandwidth for the circuit
bestBandwidthSoFar=AntennaDemoAnalyzeResults(aIterationFileName);
disp(['   The orginal bandwidth is ' num2str(bestBandwidthSoFar)]);
aBestArrayOfBlobs={};
designWithBestBandwidthSoFar=0;

% If the original bandwidth is zero then throw an error
if bestBandwidthSoFar == 0
   error('The circuit has zero bandwidth.'); 
end

% Reopen the original project we had recieved
DemoProject=SonnetProject(Filename);
DemoProject.addAbsFrequencySweep(.4,.7)

% Find all the blobs in the circuit
anArrayOfBlobs = AntennaDemoIdBlobs(DemoProject.GeometryBlock.ArrayOfPolygons,YNumberOfPatches);
aNumberOfBlobs=length(anArrayOfBlobs);

% The number of random trials we will do
numberOfSimulations=aNumberOfBlobs*2;

% Randomly toggle a set of blobs
for iCounter=1:numberOfSimulations
        
    %*************************************
    % Generate a random number which will
    % be the number of changes we perform.
    %*************************************
    numberOfChanges = rand(1);
    numberOfChanges = round(numberOfChanges*100);
    numberOfChanges = mod(numberOfChanges,aNumberOfBlobs)+1;
    
    %*************************************
    % Generate a random number for the
    % index of the piece of metal we are
    % going to modify the properties of.
    %*************************************
    anCurrentToggledBlobs={};
    for i=1:numberOfChanges
        % Make a blob thick
        TheIndexForTheBlob = randi(aNumberOfBlobs,1);
        anArrayOfBlobs{TheIndexForTheBlob}.convertBlobToThickMetal();
        anCurrentToggledBlobs{length(anCurrentToggledBlobs)+1}=anArrayOfBlobs{TheIndexForTheBlob};
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
    
    % Make the blob thin again to be ready for the next iteration
    for jCounter=1:length(anCurrentToggledBlobs)
        anCurrentToggledBlobs{jCounter}.convertBlobToThinMetal(); %#ok<*AGROW>
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
        aBestArrayOfBlobs=anCurrentToggledBlobs;
    end
    
    fprintf(1,'   Design number %d/%d has a bandwidth of %f percent\n',iCounter,numberOfSimulations,theBandWidth);
end

fprintf(1,'\n   The design with the best bandwidth is %d with a bandwidth of %f percent\n',designWithBestBandwidthSoFar,bestBandwidthSoFar);
disp([sprintf('\n') '   The design has ' num2str(length(aBestArrayOfBlobs)) ' empty space that is better off as being metal.']);

% If a patch should be thick then make it thick
for iCounter=1:length(aBestArrayOfBlobs)
    aBestArrayOfBlobs{iCounter}.convertBlobToThickMetal(); %#ok<*AGROW>
end

DemoProject.saveAs(OutputFilename);

end