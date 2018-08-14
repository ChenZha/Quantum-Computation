%AntennaDemo   A demo of Matlab modifying and simulating a project
%   This function is a demonstration of an realistic use
%   for the ability to run Sonnet from MATLAB.
%
%   This example will build a Sonnet Project in the form
%   of a patch antenna and remove metal patches from it in
%   order to get a very high -3dB bandwidth.
%
%   This demo was written by Bashir Souid

function AntennaDemo()

clc

fprintf(1,'\n------------------------------------------------------------------------\n');
fprintf(1,'Antenna Demo\n');
fprintf(1,'  Final project is stored in FinalDesign.son\n');
fprintf(1,'  This example will build a Sonnet Project in the form\n');
fprintf(1,'  of a patch antenna and remove metal patches from it in\n');
fprintf(1,'  order to get a very high -3dB bandwidth.\n');
fprintf(1,'------------------------------------------------------------------------\n');

%************************************
% Set the dimensions for the patch antenna
%************************************
XSizeOfEachPatch=40;
YSizeOfEachPatch=40;
XNumberOfPatches=11;
YNumberOfPatches=13;
XBoxSize=1600;
YBoxSize=1600;

%************************************
% Build the patch antenna
%************************************
PatchAntennaBuilder('Antenna1.son',XSizeOfEachPatch,YSizeOfEachPatch,XNumberOfPatches,YNumberOfPatches,XBoxSize,YBoxSize);

%************************************
% Run Phase 1
%************************************
AntennaDemoRandomToggle('Antenna1.son','Phase1Best.son');

% Do phase 2,3 and 4 a large
% number of times.
phaseCounter=0;
for iCounter=1:2
    %************************************
    % Genetic Toggle
    %************************************
    phaseCounter=phaseCounter+1;
    aInputFilename=sprintf('Phase%dBest.son',phaseCounter);
    aOutputFilename=sprintf('Phase%dBest.son',phaseCounter+1);
    AntennaDemoGeneticToggle(aInputFilename,aOutputFilename);
    
    %************************************
    % Empty Space Removal
    %************************************
    phaseCounter=phaseCounter+1;
    aInputFilename=sprintf('Phase%dBest.son',phaseCounter);
    aOutputFilename=sprintf('Phase%dBest.son',phaseCounter+1);
    AntennaDemoEmptySpaceRemoval(aInputFilename,aOutputFilename,YNumberOfPatches);
    
    %************************************
    % Adjacent Toggle
    %************************************
    phaseCounter=phaseCounter+1;
    aInputFilename=sprintf('Phase%dBest.son',phaseCounter);
    aOutputFilename=sprintf('Phase%dBest.son',phaseCounter+1);
    AntennaDemoAdjacentToggle(aInputFilename,aOutputFilename,YNumberOfPatches);
end

%************************************
% End - Copy final project
%************************************
fprintf(1,'\n------------------------------------------------------------------------\n');
fprintf(1,'Demo Complete\n');
fprintf(1,'  Final project is stored in FinalDesign.son\n');
fprintf(1,'------------------------------------------------------------------------\n');
copyfile(aOutputFilename,'XFinalDesign.son')

% Remove the thin patches from the final design
DemoProject=SonnetProject('XFinalDesign.son');

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
DemoProject.saveAs('FinalDesign.son');

end