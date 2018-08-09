%************************************************
% Coupler Optimization With Parameters
%   This is a tutorial on how to use Matlab to open an
%   existing Sonnet Project, add dimension parameters
%   modify parameter values and determine the return
%   loss at 5 GHz. The optimization routine will
%   increase or decrease the width of sides of the
%   coupler by up to 10% to optimize its size.
%
%   This tutorial is intended for Sonnet-Matlab
%   interface versions 3.0 and later.
%************************************************

% Open the initial geometry project
Project=SonnetProject('2branch.son');

% Get the centroids for all the polygons in the project
[aArrayOfCentroidXCoordinates, aArrayOfCentroidYCoordinates, ~, ~, aArrayOfPolygons]=Project.getAllPolygonCentroids();

%************************************************
% Find the top polygon in the coupler
% The top polygon will have the lowest
% centroid Y coordinate (Sonnet uses an
% inverse grid so (0,0) is at the top
% left of the window)
%************************************************
[~,aIndexInArray]=min(aArrayOfCentroidYCoordinates);
aTopPolygon=aArrayOfPolygons{aIndexInArray};

%************************************************
% Find the bottom polygon in the coupler
% The bottom polygon will have the highest
% centroid Y coordinate.
%************************************************
[~,aIndexInArray]=max(aArrayOfCentroidYCoordinates);
aBottomPolygon=aArrayOfPolygons{aIndexInArray};

%************************************************
% Find the left and right polygons of the
% coupler. The polygons are situated
% roughly half way along the height of
% the box. We can find the polygon that
% is closest to the Y center by comparing
% all the polygons' Y centroid coordinates
% to the size of the box divided by two.
% The closest ones are the left and right
% sides of the coupler; we can determine
% which is which by comparing thier X
% centroid coordinates.
%************************************************
% Get one polygon
[~,aFirstIndexInArray]=min(abs(aArrayOfCentroidYCoordinates-Project.yBoxSize/2));
aFirstPolygon=aArrayOfPolygons{aFirstIndexInArray};

% Get the second polygon
[~,aSecondIndexInArray]=min(abs(aArrayOfCentroidYCoordinates(aIndexInArray+1:length(aArrayOfCentroidYCoordinates))-Project.yBoxSize/2));
aSecondPolygon=aArrayOfPolygons{aFirstIndexInArray+aSecondIndexInArray};

% The polygon with the smaller X centroid
% coordinate is the left polygon. The other
% one is the right polygon.
if aFirstPolygon.CentroidXCoordinate < aSecondPolygon.CentroidXCoordinate
    aLeftPolygon=aFirstPolygon;
    aRightPolygon=aSecondPolygon;
else
    aLeftPolygon=aSecondPolygon;
    aRightPolygon=aFirstPolygon;
end

%************************************************
% Add dimension parameters to the
% polygons that make the coupler
%************************************************
Project.addSymmetricDimensionParameter('Width1',...
    aTopPolygon,aTopPolygon.lowerLeftVertex(),...
    aTopPolygon,aTopPolygon.upperLeftVertex(),...
    aTopPolygon,aTopPolygon.lowerRightVertex(),...
    aTopPolygon,aTopPolygon.upperRightVertex(),'Y');
Project.addSymmetricDimensionParameter('Width2',...
    aBottomPolygon,aBottomPolygon.lowerLeftVertex(),...
    aBottomPolygon,aBottomPolygon.upperLeftVertex(),...
    aBottomPolygon,aBottomPolygon.lowerRightVertex(),...
    aBottomPolygon,aBottomPolygon.upperRightVertex(),'Y');
Project.addSymmetricDimensionParameter('Width3',...
    aLeftPolygon,aLeftPolygon.lowerLeftVertex(),...
    aLeftPolygon,aLeftPolygon.lowerRightVertex(),...
    aLeftPolygon,aLeftPolygon.upperLeftVertex(),...
    aLeftPolygon,aLeftPolygon.upperRightVertex(),'X');
Project.addSymmetricDimensionParameter('Width4',...
    aRightPolygon,aRightPolygon.lowerLeftVertex(),...
    aRightPolygon,aRightPolygon.lowerRightVertex(),...
    aRightPolygon,aRightPolygon.upperLeftVertex(),...
    aRightPolygon,aRightPolygon.upperRightVertex(),'X');

% Add an output file
Project.addTouchstoneOutput();

% Save the initial design
Project.saveAs('Optimization_Start.son');

% This controls how many circuit variations we will try
aMaxIterations=10;

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
    
    % Generate a percent value to increase/decrease the size of the coupler
    aDeltaFactor=rand(1)*.20-.10;
    
    % Modify Width1 to be its initial value +/- 10%
    aCurrentValue=Project.getVariableValue('Width1');
    aNewValue=aCurrentValue+aCurrentValue*aDeltaFactor;
    Project.modifyVariableValue('Width1',aNewValue);
    
    % Modify Width2 to be its initial value +/- 10%
    aCurrentValue=Project.getVariableValue('Width2');
    aNewValue=aCurrentValue+aCurrentValue*aDeltaFactor;
    Project.modifyVariableValue('Width2',aNewValue);
    
    % Modify Width3 to be its initial value +/- 10%
    aCurrentValue=Project.getVariableValue('Width3');
    aNewValue=aCurrentValue+aCurrentValue*aDeltaFactor;
    Project.modifyVariableValue('Width3',aNewValue);
    
    % Modify Width4 to be its initial value +/- 10%
    aCurrentValue=Project.getVariableValue('Width4');
    aNewValue=aCurrentValue+aCurrentValue*aDeltaFactor;
    Project.modifyVariableValue('Width4',aNewValue);
    
    % Write the project to the file
    aFilename=['Optimization_iteration_' num2str(iCounter) '.son'];
    Project.saveAs(aFilename);
    
    % Simulate the project
    Project.simulate();
    
    % Read the S2P file's data at 5.0 GHz
    aSnPFilename=['Optimization_iteration_' num2str(iCounter) '.s4p'];
    aLossOfCurrentIteration = TouchstoneParser(aSnPFilename,1,1,5e9);
    disp(['  Design number ' num2str(iCounter) '/' num2str(aMaxIterations) ...
        ' has a change of ' num2str(aDeltaFactor*100) '% and a return loss of ' ...
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