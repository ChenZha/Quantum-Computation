function AntennaDemoGeneticToggle(Filename,OutputFilename)

%*******************************************************
%   Introduce a genetic modification.
%   randomly change one cell in the
%   patch so that we can get a more
%   diverse solution set.
%*******************************************************

aBaseFileName=strrep(OutputFilename,'Best.son','');
fprintf(1,'\n------------------------------------------------------------------------\n');
fprintf(1,'%s\n',aBaseFileName);
fprintf(1,'   - Genetic Toggle\n');
fprintf(1,'------------------------------------------------------------------------\n');

% Open the project
DemoProject=SonnetProject(Filename);
anArrayOfPolygons=DemoProject.GeometryBlock.ArrayOfPolygons;

TheIndexForTheMetal = randi(length(anArrayOfPolygons),1);
if anArrayOfPolygons{TheIndexForTheMetal}.MetalType==0
    anArrayOfPolygons{TheIndexForTheMetal}.MetalType=1; %#ok<NASGU>
else
    anArrayOfPolygons{TheIndexForTheMetal}.MetalType=0; %#ok<NASGU>
end

% Find the polygon that is our VIA; it will be the last polygon in the array.
aIndexForVia=length(DemoProject.GeometryBlock.ArrayOfPolygons);

% We can find the polygon that is behind the via by searching for its centroid
aCentroidX=DemoProject.GeometryBlock.ArrayOfPolygons{aIndexForVia}.CentroidXCoordinate;
aCentroidY=DemoProject.GeometryBlock.ArrayOfPolygons{aIndexForVia}.CentroidYCoordinate;
aViaAndPolygonNextToVia=DemoProject.findPolygonUsingCentroidXY(aCentroidX,aCentroidY);

% Make the via and the polygon behind it thick copper
for jCounter=1:length(aViaAndPolygonNextToVia)
    aViaAndPolygonNextToVia(jCounter).MetalType=0;
end

% Save the project
DemoProject.saveAs(OutputFilename);