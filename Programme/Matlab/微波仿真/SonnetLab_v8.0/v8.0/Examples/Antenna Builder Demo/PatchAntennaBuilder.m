%*******************************************************
% Builds a patch antenna given the size of each patch
% and the number of patches in the X and Y directions.
%*******************************************************
function PatchAntennaBuilder(OutputFilename,XSizeOfEachPatch,YSizeOfEachPatch,XNumberOfPatches,YNumberOfPatches,XBoxSize,YBoxSize)

% Make an empty Sonnet Project
aProject=SonnetProject();

% Change the size of the box
aProject.changeBoxSize(XBoxSize,YBoxSize);
widthOfAntenna = XSizeOfEachPatch*XNumberOfPatches;
heightOfAntenna = YSizeOfEachPatch*YNumberOfPatches;
anAmountOfClearanceX=560;
anAmountOfClearanceY=560;

% Set the dielectric layer thicknesses
aProject.GeometryBlock.SonnetBox.ArrayOfDielectricLayers{1}.Thickness=100;
aProject.GeometryBlock.SonnetBox.ArrayOfDielectricLayers{2}.Thickness=10;

% Set the top of the box to free space
aProject.GeometryBlock.TopCoverMetal.Type='FREESPACE';

% Change the number of cells for the box
aProject.changeNumberOfCells(XBoxSize/XSizeOfEachPatch, YBoxSize/YSizeOfEachPatch)

% Add the copper metal type
aProject.defineNewNormalMetalType('Copper',58000000,0,0.018);
aProject.defineNewNormalMetalType('CopperThin',58000000,0,1e-007)

% Make an S1P file output 
aProject.addFileOutput('TS','D','Y','$BASENAME.s1p','IC','N','S','MA','R',50)

% Set the analysis settings
aProject.addAbsFrequencySweep(.4,.7)

% Change the length units to mm
aProject.changeLengthUnit('MM');

% Build all of the patches:
% We want to make patches starting at an X offset of
% one times the width of the antenna so that the antenna
% is sufficiently far away from the box walls.
debugIdCounter=1;
for iCounter=anAmountOfClearanceX:XSizeOfEachPatch:anAmountOfClearanceX+widthOfAntenna-XSizeOfEachPatch
    
    % We want to make patches starting at an Y offset of
    % one times the height of the antenna so that the antenna
    % is sufficiently far away from the box walls.
    for jCounter=anAmountOfClearanceY:YSizeOfEachPatch:anAmountOfClearanceY+heightOfAntenna-YSizeOfEachPatch
        
        % Find the coordinates for the patch
        theXCoordinateValues{1}=iCounter;  %#ok<*AGROW>
        theXCoordinateValues{2}=iCounter; 
        theXCoordinateValues{3}=iCounter+XSizeOfEachPatch; 
        theXCoordinateValues{4}=iCounter+XSizeOfEachPatch;
        theXCoordinateValues{5}=iCounter;
        theYCoordinateValues{1}=jCounter; 
        theYCoordinateValues{2}=jCounter+YSizeOfEachPatch; 
        theYCoordinateValues{3}=jCounter+YSizeOfEachPatch;
        theYCoordinateValues{4}=jCounter;
        theYCoordinateValues{5}=jCounter;

        % Create a metal polygon to be a patch.
        % We are doing this manually so that it
        % will be faster.
        aNewMetalPolygon=SonnetGeometryPolygon();
        aNewMetalPolygon.Type='';
        aNewMetalPolygon.MetalizationLevelIndex=0;
        aNewMetalPolygon.MetalType=0;
        aNewMetalPolygon.FillType='N';
        aNewMetalPolygon.DebugId=debugIdCounter;
        aNewMetalPolygon.XMinimumSubsectionSize=1;
        aNewMetalPolygon.YMinimumSubsectionSize=1;
        aNewMetalPolygon.XMaximumSubsectionSize=100;
        aNewMetalPolygon.YMaximumSubsectionSize=100;
        aNewMetalPolygon.MaximumLengthForTheConformalMeshSubsection=0;
        aNewMetalPolygon.EdgeMesh='Y';
        aNewMetalPolygon.XCoordinateValues=theXCoordinateValues;
        aNewMetalPolygon.YCoordinateValues=theYCoordinateValues;
        
        % Increment the debugId counter
        debugIdCounter=debugIdCounter+1;
        
        % Add the patch to the project
        aProject.GeometryBlock.ArrayOfPolygons{length(aProject.GeometryBlock.ArrayOfPolygons)+1}=aNewMetalPolygon;
        
    end
    
end

% Place the VIA
% Find the coordinates for the via
XStartLocation=floor((anAmountOfClearanceX+.5*widthOfAntenna)/XSizeOfEachPatch)*XSizeOfEachPatch;
XEndLocation=floor((anAmountOfClearanceX+.5*widthOfAntenna)/XSizeOfEachPatch)*XSizeOfEachPatch+XSizeOfEachPatch;
YStartLocation=ceil((anAmountOfClearanceY+.5*heightOfAntenna)/YSizeOfEachPatch)*YSizeOfEachPatch-YSizeOfEachPatch;
YEndLocation=ceil((anAmountOfClearanceY+.5*heightOfAntenna)/YSizeOfEachPatch)*YSizeOfEachPatch;
theXCoordinateValues=[XStartLocation XStartLocation XEndLocation XEndLocation];
theYCoordinateValues=[YStartLocation YEndLocation YEndLocation YStartLocation];


% Add the via to the project
aProject.addViaPolygonEasy(0,1,theXCoordinateValues,theYCoordinateValues);

% Change the type for the via to be copper
aIndexForVia=length(aProject.GeometryBlock.ArrayOfPolygons);
aPolygon=aProject.GeometryBlock.ArrayOfPolygons{aIndexForVia};
aPolygon.MetalType=0;

% Place a port at the bottom of the via
aProject.addPortToPolygon(aPolygon,1);

% Write the project out to the disk
aProject.saveAs(OutputFilename);

end