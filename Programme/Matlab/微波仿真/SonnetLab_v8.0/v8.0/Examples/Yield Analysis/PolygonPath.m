%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Builds polygons according to a vector
% representing a path. This method has the
% ability to champer the path corners.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Inputs: 1) Nx2 matrix of coordinates
%             [ X1 Y1; X2 Y2; X3 Y3; ... ]
%          2) The width of the trace
%          3) The chamfer ratio
%  Outputs: An vector of SonnetLab polygons
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file was written by Bashir Souid and Serhend Arvas
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function aPolygons=PolygonPath(theCenterLine,theWidth,theChamferRatio)

% If no chamfer ratio is specified
% then use a value of zero.
if nargin == 2
    theChamferRatio=0;
end

% Remove the colinear points from the
% centerline. Every new point only exists
% when there is a turn in the path.
theCenterLine=removeColinearPoints(theCenterLine);

% Check that the distance between 
% each turn is at least 3w. If any
% segment fails an error will be thrown.
checkSegmentLength(theCenterLine,theWidth)

% Scale the first and last point so that they are
% in the correct places even after they are 
% scaled for chamfering.
theCenterLine=scaleEndPoints(theCenterLine,theWidth,theChamferRatio);

% Build polygons for the chamfered corners and
% build polygons for the straight-line segments.
aPolygons=buildPolygons(theCenterLine,theWidth,theChamferRatio);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Removes colinear points from vector of coordinates
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Inputs:  nx2 matrix: [ X1 Y1; X2 Y2; X3 Y3; ... ]
%  Returns: void
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function theCenterLine=removeColinearPoints(theCenterLine)

% Determine if points are co-linear. If any
% points are colinear then remove them.
iCounter=1;
while iCounter < size(theCenterLine,1)-2
    if isColinear(theCenterLine(iCounter:iCounter+2,:))
        theCenterLine(iCounter+1,:)=[];
    else
        iCounter=iCounter+1;
    end
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Checks if a set of three points are colinear
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Inputs:  3x2 matrix: [ X1 Y1; X2 Y2; X3 Y3]
%  Returns: boolean true if points are colinear
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function isColinear=isColinear(theThreePoints)

aPoint1X=theThreePoints(1);
aPoint2X=theThreePoints(2);
aPoint3X=theThreePoints(3);
aPoint1Y=theThreePoints(4);
aPoint2Y=theThreePoints(5);
aPoint3Y=theThreePoints(6);

% Colinear test X1(Y2-Y3)+X2(Y3-Y1)+X3(Y1-Y2)=0
if aPoint1X*(aPoint2Y-aPoint3Y)+...
        aPoint2X*(aPoint3Y-aPoint1Y)+...
        aPoint3X*(aPoint1Y-aPoint2Y)==0
    isColinear = 1;
else
    isColinear = 0;
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check if all line segments are at least 3*w long
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Inputs: 1) Nx2 matrix of coordinates
%             [ X1 Y1; X2 Y2; X3 Y3; ... ]
%          2) The width of the trace
%  Outputs: void
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function checkSegmentLength(theCenterLine,theWidth)

for iCounter=1:length(theCenterLine)-2
    aVector=[theCenterLine(iCounter,:)-theCenterLine(iCounter+1,:)];
    aVectorMagnitude=hypot(aVector(1),aVector(2));
    
    if aVectorMagnitude < .1*theWidth
        error('The distance between any two turns must be at least 3*Width')
    end
    
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Build polygons for the chamfered corners
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Inputs: 1) Nx2 matrix of coordinates
%             [ X1 Y1; X2 Y2; X3 Y3; ... ]
%          2) The width of the trace
%          3) The chamfer ratio
%  Outputs: A modified version of the first input
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function theCenterLine=scaleEndPoints(theCenterLine,theWidth,theChamferRatio)

% Define a vector between the two points
aLength=length(theCenterLine);
aVector1=[theCenterLine(1,:)-theCenterLine(2,:)];
aVector2=[theCenterLine(aLength-1,:)-theCenterLine(aLength,:)];

% Define the magnitudes of the above vector.
aVector1m=hypot(aVector1(1),aVector1(2));
aVector2m=hypot(aVector2(1),aVector2(2));

% Define unit vector in the directions of the above vector.
aVector1u=aVector1/aVector1m;
aVector2u=aVector2/aVector2m;

% Define unit NORMAL vector such that
%   Vector1n x Vector1u = positive z direction
aTemp=cross([0 0 -1],[aVector1u 0]);
Vector1n=aTemp(1,1:2);
aTemp=cross([0 0 -1],[aVector2u 0]);
Vector2n=aTemp(1,1:2);

% This is the factor to scale by
aFactor=theWidth/2-2*theChamferRatio*theWidth;

% Adjust the points
theCenterLine(1,:)=theCenterLine(1,:)-aVector1u*aFactor;
theCenterLine(aLength,:)=theCenterLine(aLength,:)+aVector2u*aFactor;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Build polygons for the chamfered corners
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Inputs: 1) Nx2 matrix of coordinates
%             [ X1 Y1; X2 Y2; X3 Y3; ... ]
%          2) The width of the trace
%          3) The chamfer ratio
%  Outputs: An vector of SonnetLab polygons
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function aPolygons=buildPolygons(theCenterLine,theWidth,theChamferRatio)

% Preallocate the array for speed.
%   Number_Of_Polygons = (Number_Of_Coordinate_Pairs - 2) * 2 + 1
aNumberOfPolygons=(size(theCenterLine,1)-2)*2+1;
aPolygons(1:aNumberOfPolygons)=SonnetGeometryPolygon();

% Build polygon corners and trace lines
iPolygonCounter=1;
for iCounter=1:length(theCenterLine)-2
    aPolygonPair=buildPolygonPair(theCenterLine(iCounter:iCounter+2,:),theWidth,theChamferRatio);
    aPolygons(iPolygonCounter)=aPolygonPair(1);
    aPolygons(iPolygonCounter+1)=aPolygonPair(2);
    iPolygonCounter=iPolygonCounter+2;
end

% Build the last polygon trace line
aLength=length(theCenterLine);
aPolygon=buildPathPolygon(theCenterLine(aLength-1:aLength,:),theWidth,theChamferRatio);
aPolygons(iPolygonCounter)=aPolygon;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Build a corner polygon and a leading trace line
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Inputs: 1) 3x2 matrix: [ X1 Y1; X2 Y2; X3 Y3]
%          2) The width of the trace
%          3) The chamfer ratio
%  Outputs: An vector of SonnetLab polygons
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function aPolygons=buildPolygonPair(theThreePoints,theWidth,theChamferRatio)

% Build a polygon for the chamfered corner
aCornerPolygon=buildCornerPolygon(theThreePoints,theWidth,theChamferRatio);

% Build a polygon to be attached
% to the first side of the corner
aPathPolygon=buildPathPolygon(theThreePoints(1:2,:),theWidth,theChamferRatio);

aPolygons=[aPathPolygon aCornerPolygon];

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Build polygon for the chamfered corner
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Inputs: 1) 3x2 matrix: [ X1 Y1; X2 Y2; X3 Y3]
%          2) The width of the trace
%          3) The chamfer ratio
%  Outputs: A SonnetLab polygon for the corner
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function aCornerPolygon=buildCornerPolygon(theThreePoints,theWidth,theChamferRatio)

% Calculate the points used in the turn
aVertices=determineCornerVerticies(theThreePoints,theWidth,theChamferRatio);

% Build polygon object from point coordinates
aCornerPolygon=buildPolygon(aVertices(:,1),aVertices(:,2));

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Determine vertices for the corner polygon
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Inputs: 1) 3x2 matrix: [ X1 Y1; X2 Y2; X3 Y3]
%          2) The width of the trace
%          3) The chamfer ratio
%  Outputs: Nx2 matrix of vertices
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function aVertices=determineCornerVerticies(theThreePoints,theWidth,theChamferRatio)

% Define two vectors, emanating from the intersection point.
aVector1=[theThreePoints(1,:)- theThreePoints(2,:)];
aVector2=[theThreePoints(2,:)- theThreePoints(3,:)];

% Define the magnitudes of the above vectors.
aVector1m=hypot(aVector1(1),aVector1(2));
aVector2m=hypot(aVector2(1),aVector2(2));

% Define unit vectors in the directions of the above vectors.
aVector1u=aVector1/aVector1m;
aVector2u=aVector2/aVector2m;

% Determine the direction of the turn.
% TurnDirection == 1 means a right turn, TurnDirection == -1 means a
% right turn.  TurnDirection should have a magnitude of 1.  This
% indicates a 90 degree turn.  Any other magnitude implies a non
% orthogonal turn.  This should result in an error.
aTurnDirection=round(det([aVector1u ; aVector2u]));

if aTurnDirection < 0
    aVertices=determineCornerPointsRightTurn(theWidth,theChamferRatio);
else
    aVertices=determineCornerPointsLeftTurn(theWidth,theChamferRatio);
end

% The verticies must be rotated and
% translated to the proper location

% Calculate the angle of the first vector;
aVector1Angle=atan2(-aVector1u(2),-aVector1u(1))-pi/2;

% Rotate the corner object to match the vector angle.
aRotationMatrix=[cos(aVector1Angle) -sin(aVector1Angle); sin(aVector1Angle) cos(aVector1Angle)];
aVertices=(aRotationMatrix*aVertices')';

% Translate the corner object to the corner position.
aVertices(:,1)=aVertices(:,1)+theThreePoints(2,1);
aVertices(:,2)=aVertices(:,2)+theThreePoints(2,2);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Determine coordinate vertices for a corner
% polygon used for a right turn.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Inputs: 1) The width of the trace
%          2) The chamfer ratio
%  Outputs: Nx2 matrix of vertices
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function aVertices=determineCornerPointsRightTurn(theWidth,theChamferRatio)

% This is the point at the "inside" of the
% turn (for a right turn at the origin).
x1=theWidth/2;
y1=-theWidth/2;

% Depending on the chamfer ratio, construct the other vertices of the
% corner object.  A chamfer ratio less than .5 results in a square with
% a corner cut off.  A chamfer ratio of .5 results in a triangle.  A
% chamfer ratio greater than .5 results in an L shape, with its corner
% cut off.
K=2*theChamferRatio*theWidth;
s=theChamferRatio*sqrt(2)*theWidth;
if theChamferRatio>=.5 && theChamferRatio<=1;
    x3 = -theWidth/2+K;
    y3 = theWidth/2;
    x4 = -theWidth/2;
    y4 = theWidth/2-sqrt(2)*s;
    x5 = x4+theWidth;
    y5 = y4;
    x2 = x3;
    y2 = y3-theWidth;
elseif theChamferRatio>=0 && theChamferRatio<0.5
    x2 = x1;
    y2 = y1+theWidth;
    x3 = x1-theWidth+K;
    y3 = y1+theWidth;
    x4 = x1-theWidth;
    y4 = y1+theWidth-K;
    x5 = x1-theWidth;
    y5 = y1;
end

aVertices=[x1 y1; x2 y2; x3 y3; x4 y4 ;x5 y5; x1 y1];

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Determine coordinate vertices for a corner
% polygon used for a left turn.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Inputs: 1) The width of the trace
%          2) The chamfer ratio
%  Outputs: Nx2 matrix of vertices
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function aVerticies=determineCornerPointsLeftTurn(theWidth,theChamferRatio)

% Get the coordinates for a right turn
aVerticies=determineCornerPointsRightTurn(theWidth,theChamferRatio);

% The coordinates for a left turn is a 270 degree
% rotation of the coordinates for a right turn
aAngle=pi*3/2;
aRotationMatrix=[cos(aAngle) -sin(aAngle); sin(aAngle) cos(aAngle)];
aVerticies=(aRotationMatrix*aVerticies')';

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Build a polygon for the straight-line paths
%   for the coordinates
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Inputs: 1) Nx2 matrix of coordinates
%             [ X1 Y1; X2 Y2; X3 Y3; ... ]
%          2) The width of the trace
%  Outputs: A SonnetLab polygon for the trace
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function aPathPolygon=buildPathPolygon(theTwoPoints,theWidth,theChamferRatio)

% Define a vector between the two points
aVector1=[theTwoPoints(1,:)- theTwoPoints(2,:)];

% Define the magnitudes of the above vector.
aVector1m=hypot(aVector1(1),aVector1(2));

% Define unit vector in the directions of the above vector.
aVector1u=aVector1/aVector1m;

% Define unit NORMAL vector such that
%   Vector1n x Vector1u = positive z direction
aTemp=cross([0 0 -1],[aVector1u 0]);
Vector1n=aTemp(1,1:2);

% Determine the points for the 
aFactor=theWidth/2-2*theChamferRatio*theWidth;
aVertexOne=-Vector1n*theWidth/2+theTwoPoints(1,:)+aVector1u*(aFactor);
aVertexTwo=Vector1n*theWidth/2+theTwoPoints(1,:)+aVector1u*(aFactor);
aVertexThree=Vector1n*theWidth/2+theTwoPoints(2,:)-aVector1u*(aFactor);
aVertexFour=-Vector1n*theWidth/2+theTwoPoints(2,:)-aVector1u*(aFactor);

% Build polygon vertex lists and build the polygon object
aVerticesX=[aVertexOne(1) aVertexTwo(1) aVertexThree(1) aVertexFour(1) aVertexOne(1)];
aVerticesY=[aVertexOne(2) aVertexTwo(2) aVertexThree(2) aVertexFour(2) aVertexOne(2)];
aPathPolygon=buildPolygon(aVerticesX,aVerticesY);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Build a SonnetLab polygon object given vertices
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Inputs: 1) Nx2 matrix of coordinates
%             [ X1 Y1; X2 Y2; X3 Y3; ... ]
%          2) The width of the trace
%  Outputs: A SonnetLab polygon
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function aPolygon=buildPolygon(theXCoordinates,theYCoordinates)

aPolygon=SonnetGeometryPolygon();

% Modify the values for the polygon
aPolygon.MetalizationLevelIndex  =   0;
aPolygon.MetalType               =   -1;
aPolygon.FillType                =   'N';
aPolygon.XMinimumSubsectionSize  =   1;
aPolygon.YMinimumSubsectionSize  =   1;
aPolygon.XMaximumSubsectionSize  =   100;
aPolygon.YMaximumSubsectionSize  =   100;
aPolygon.EdgeMesh                =   'Y';
aPolygon.XCoordinateValues       =   num2cell(theXCoordinates);
aPolygon.YCoordinateValues       =   num2cell(theYCoordinates);
aPolygon.DebugId                 =   randi(500,1);
aPolygon.MaximumLengthForTheConformalMeshSubsection=0;

end