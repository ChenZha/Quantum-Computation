function BuildCircuit(theProject,theNewSValue,theNewWValue)

theProject.modifyVariableValue('W1',theNewWValue);
theProject.modifyVariableValue('S',theNewSValue);

% Determine Y coordinate values that will
% lead to the appropriate seperation
aTopChokeValue=256-theNewWValue/2-.5*theNewSValue;
aBottomChokeValue=256+theNewWValue/2+.5*theNewSValue;

% Add polygons for the top line
aCenterLine = [
    64.5     220
    64.5     104.5
    173.5    104.5
    173.5    aTopChokeValue
    257      aTopChokeValue
    ];

% The centerline values must be displaced by
% half the distance from its original value (37)
% because the centerline grows in both directions
% (like a symmetric parameter) and the divit grows
% in one direction with an anchored parameter.
aCenterLine(:,1)=aCenterLine(:,1)+(theNewWValue-37)/2;

ProjectPolygonPath(theProject,0,aCenterLine,theNewWValue,.7,'Copper');

aPort=theProject.addPortAtLocation(256,aTopChokeValue);

aPolygon=aPort.Polygon;

for iCounter=1:length(aPolygon.XCoordinateValues)
   if  aPolygon.XCoordinateValues{iCounter}>256
       aPolygon.XCoordinateValues{iCounter}=256;
   end
end

% Add polygons for the bottom line
aCenterLine = [
    64.5     292
    64.5     407.5
    173.5    407.5
    173.5    aBottomChokeValue
    257      aBottomChokeValue
    ];

% The centerline values must be displaced by
% half the distance from its original value (37)
% because the centerline grows in both directions
% (like a symmetric parameter) and the divit grows
% in one direction with an anchored parameter.
aCenterLine(:,1)=aCenterLine(:,1)+(theNewWValue-37)/2;

ProjectPolygonPath(theProject,0,aCenterLine,theNewWValue,.7,'Copper');

aPort=theProject.addPortAtLocation(256,aBottomChokeValue);

aPolygon=aPort.Polygon;

for iCounter=1:length(aPolygon.XCoordinateValues)
   if  aPolygon.XCoordinateValues{iCounter}>256
       aPolygon.XCoordinateValues{iCounter}=256;
   end
end

end