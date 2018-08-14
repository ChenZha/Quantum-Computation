% This example will plot the antenna pattern for a
% series of patch antenna designs with varying 
% amounts of separation between patches.
%
% This example was written by Bashir Souid at Sonnet Software

OriginalProject = SonnetProject('Inital.son');

% The inital project file should only have 2 polygons:
% a planar polygon for the antenna patch and a via.
if OriginalProject.polygonCount ~= 2
    error('Invalid inital project. Expected project to have exactly two polygons.');
end

% Get the inital planar and via polygons
if OriginalProject.getPolygon(1).isPolygonVia
    aOriginalViaPolygon = OriginalProject.getPolygon(1);
    aOriginalPlanarPolygon = OriginalProject.getPolygon(2);
else
    aOriginalViaPolygon = OriginalProject.getPolygon(2);
    aOriginalPlanarPolygon = OriginalProject.getPolygon(1);
end

% For seperation values from 16.41 to 64.06 build
% an appropriate patch antenna, simulate it,
% export farfield data and plot.
aIterationCounter=0;
for aSeperation=16.41:0.78125:64.0626
    
    aIterationCounter=aIterationCounter+1;
    
    % This is the distance the polygon centroids must be moved
    % for the seperation between polygon edges to be aSeperation
    aXDistance=aSeperation+aOriginalPlanarPolygon.computeXWidth;
    aYDistance=aSeperation+aOriginalPlanarPolygon.computeYWidth;
    
    % Copy the original project and save it as another file
    aProject = SonnetProject('Inital.son');
    aProject.saveAs(['Iteration_' num2str(aIterationCounter) '_Seperation_' num2str(aSeperation) '.son']);
    
    % Add a copy of the inital planar and via polygons
    % to the project and move them to the left
    aPlanarPolygon=aProject.duplicatePolygon(aOriginalPlanarPolygon);
    aPlanarPolygon.movePolygonRelative(-1*aXDistance,0);
    aViaPolygon=aProject.duplicatePolygon(aOriginalViaPolygon);
    aViaPolygon.movePolygonRelative(-1*aXDistance,0);
    aPort=aProject.addPortToPolygon(aViaPolygon.DebugId,1);
    aPort.PortNumber=1;
    
    % Add a copy of the inital planar and via polygons
    % to the project and move them to the right
    aPlanarPolygon=aProject.duplicatePolygon(aOriginalPlanarPolygon);
    aPlanarPolygon.movePolygonRelative(aXDistance,0);
    aViaPolygon=aProject.duplicatePolygon(aOriginalViaPolygon);
    aViaPolygon.movePolygonRelative(aXDistance,0);
    aPort=aProject.addPortToPolygon(aViaPolygon.DebugId,1);
    aPort.PortNumber=1;
    
    % Add a copy of the inital planar and via polygons
    % to the project and move them up
    aPlanarPolygon=aProject.duplicatePolygon(aOriginalPlanarPolygon);
    aPlanarPolygon.movePolygonRelative(0,-1*aYDistance);
    aViaPolygon=aProject.duplicatePolygon(aOriginalViaPolygon);
    aViaPolygon.movePolygonRelative(0,-1*aYDistance);
    aPort=aProject.addPortToPolygon(aViaPolygon.DebugId,1);
    aPort.PortNumber=1;
    
    % Add a copy of the inital planar and via polygons
    % to the project and move them to the upper left
    aPlanarPolygon=aProject.duplicatePolygon(aOriginalPlanarPolygon);
    aPlanarPolygon.movePolygonRelative(-1*aXDistance,-1*aYDistance);
    aViaPolygon=aProject.duplicatePolygon(aOriginalViaPolygon);
    aViaPolygon.movePolygonRelative(-1*aXDistance,-1*aYDistance);
    aPort=aProject.addPortToPolygon(aViaPolygon.DebugId,1);
    aPort.PortNumber=1;
    
    % Add a copy of the inital planar and via polygons
    % to the project and move them to the upper right
    aPlanarPolygon=aProject.duplicatePolygon(aOriginalPlanarPolygon);
    aPlanarPolygon.movePolygonRelative(aXDistance,-1*aYDistance);
    aViaPolygon=aProject.duplicatePolygon(aOriginalViaPolygon);
    aViaPolygon.movePolygonRelative(aXDistance,-1*aYDistance);
    aPort=aProject.addPortToPolygon(aViaPolygon.DebugId,1);
    aPort.PortNumber=1;
    
    % Snap polygons to the grid, save and simulate the new project
    aProject.snapPolygonsToGrid();
    aProject.simulate();
    
    % Export the pattern data and plot
    aThetaAngleVec=[0 85 1];
    aPhiAngleVec=[0 360 1];
    aFrequency=2.086;
    aPortInfo=[1 1 0 50 0 0 0];
    aProject.exportPattern(aPhiAngleVec,aThetaAngleVec,aFrequency,aPortInfo);
    
    aFilename=['Iteration_' num2str(aIterationCounter) '_Seperation_' num2str(aSeperation) '.pat'];
    PatternPlot(aFilename);
    
    % Save the figure to the disk as a Matlab figure file and as a tiff image
    saveas(gcf,['Figure_' num2str(aIterationCounter) '_Seperation_' num2str(aSeperation) '.fig'])
    saveas(gcf,['Figure_' num2str(aIterationCounter) '_Seperation_' num2str(aSeperation) '.tiff'])
    
end