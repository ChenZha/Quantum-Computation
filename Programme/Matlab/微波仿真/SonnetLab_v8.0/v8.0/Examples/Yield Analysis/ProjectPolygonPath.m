%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Builds polygons according to a vector representing a path. This method 
% has the ability to champer the path corners. Polygons will be added 
% to the passed project.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Inputs: 1) A SonnetLab project object or the filename 
%              for a Sonnet project on the hard drive.
%          2) The metalization level  
%             to place the polygons.
%          3) Nx2 matrix of coordinates
%             [ X1 Y1; X2 Y2; X3 Y3; ... ]
%          4) The width of the trace
%          5) The chamfer ratio
%          6) (Optional) the name of the
%             desired metal type (default
%             is lossless metal).
%  Outputs: A handle to the SonnetLab project object.
%           if input one was a project object then
%           the output is a handle to the original
%           object. If the first input was a filename
%           then the handle is a project object based
%           off of the Sonnet project file.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function was written by Bashir Souid
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function theProject=ProjectPolygonPath(theProject,theLevel,theCenterLine,theWidth,theChamferRatio,theMetalType)

% Determine if the passed argument for theProject is a 
% SonnetLab project object or the filename for a project
% file. If it is a filename then load it as a project.
if isa(theProject,'char')
   theProject=SonnetProject(theProject);
end

% If no chamfer ratio is specified
% then use a value of zero.
if nargin == 4
    theChamferRatio=0;
    theMetalType='Lossless';
elseif nargin == 5
    theMetalType='Lossless';
end

% Call the PolygonPath method to generate 
% polygons along the centerline
aPolygons=PolygonPath(theCenterLine,theWidth,theChamferRatio);

% Modify the levels for the polygons
for iCounter=1:length(aPolygons)
    
    % Create a polygon on the desired metalization level
    theProject.addPolygon(aPolygons(iCounter));
    aPolygons(iCounter).MetalizationLevelIndex=theLevel;
    
    % Make a unique ID for the polygon
    aUniqueId=theProject.generateUniqueId();
    aPolygons(iCounter).DebugId=aUniqueId;
    
    % Modify the polygon type
    theProject.changePolygonType(aUniqueId,theMetalType);
    
end

end