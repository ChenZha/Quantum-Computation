
% CurrentVectorDemo01
% Serhend Arvas and Robert Roach, 4/2/14

% Remember to run the Sonnet simulation for this project first.  
% In Sonnet, Project -> Analyze.  In Matlab, Project.simulate

clc
disp('Loading Project ...')
Project=SonnetProject('SixTenths_nH.son');
disp(' ')
disp('Exporting Currents ...')
DataObject=Project.exportCurrents('CurrentRequestFile01.xml');

CurrData(1).name='Currents_01.csv';

disp(' ')
disp('Reading Current Data Into Matlab ...')
CurrentDataGND=JXYRead(CurrData(1).name);

disp(' ')
disp('Animating Current Vector Plot ...')

fclose all;
Fig=figure;

for n=1:360
    
 %  PlotQuiver(theCSVFilename,FigureNumber,phaseInDegrees,xArrowCount,yArrowCount,QuiverScale)

    PlotQuiver(CurrentDataGND,Fig,n,20,20,1)

    pause(.1)
end


