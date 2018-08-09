% This example will plot JX and JY data at a location specified by the user
%
% This demo was written by Bashir Souid

function varargout = JXYCrossSectionPlot(varargin)
% JXYCROSSSECTIONPLOT MATLAB code for JXYCrossSectionPlot.fig
%      JXYCROSSSECTIONPLOT, by itself, creates a new JXYCROSSSECTIONPLOT or raises the existing
%      singleton*.
%
%      H = JXYCROSSSECTIONPLOT returns the handle to a new JXYCROSSSECTIONPLOT or the handle to
%      the existing singleton*.
%
%      JXYCROSSSECTIONPLOT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in JXYCROSSSECTIONPLOT.M with the given input arguments.
%
%      JXYCROSSSECTIONPLOT('Property','Value',...) creates a new JXYCROSSSECTIONPLOT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before JXYCrossSectionPlot_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to JXYCrossSectionPlot_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help JXYCrossSectionPlot

% Last Modified by GUIDE v2.5 20-Sep-2010 11:23:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @JXYCrossSectionPlot_OpeningFcn, ...
                   'gui_OutputFcn',  @JXYCrossSectionPlot_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function JXYCrossSectionPlot_OpeningFcn(hObject, eventdata, handles, varargin)

% Open two figure windows
scrsz = get(0,'ScreenSize');
handles.JXPlot=figure('Name','JX Data','NumberTitle','off','OuterPosition',[scrsz(3)/2 scrsz(4)/2+25 scrsz(3)/2 scrsz(4)/2-25]);
handles.JYPlot=figure('Name','JY Data','NumberTitle','off','OuterPosition',[scrsz(3)/2 35 scrsz(3)/2 scrsz(4)/2-25]);
setAxisData(handles);

% Make the GUI elements invisible
set(handles.circuitDiagram,'Visible','off');
set(handles.PortValues,'Visible','off');
set(handles.analyzeButton,'Visible','off');
set(handles.levelSelect,'Visible','off');
set(handles.frequencySelect,'Visible','off');
set(handles.text2,'Visible','off');
set(handles.text1,'Visible','off');

% Choose default command line output for JXYCrossSectionPlot
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = JXYCrossSectionPlot_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function openProjectButton_Callback(hObject, eventdata, handles)
disp('Loading Start.son');

[aFileName,aPathName] = uigetfile('.son','Select a Sonnet Project');

if length(aPathName) + length(aFileName) <= 2
    return;
end

handles.ProjectName=aFileName;
handles.FilePath=aPathName;
handles.Project=SonnetProject([handles.FilePath handles.ProjectName]);
getLevels(handles);
getFrequencies(handles);
setAxisData(handles);

% Set up a structure for the ports
for iCounter=1:length(handles.Project.GeometryBlock.ArrayOfPorts)
    handles.PortObjects(iCounter)=JXYPort(handles.Project.GeometryBlock.ArrayOfPorts{iCounter});
end

% Set the first port to be excited one volt by default
handles.PortObjects(1).Voltage=1;

% Make the GUI elements visible
set(handles.circuitDiagram,'Visible','on');
set(handles.PortValues,'Visible','on');
set(handles.analyzeButton,'Visible','on');
set(handles.levelSelect,'Visible','on');
set(handles.frequencySelect,'Visible','on');
set(handles.text2,'Visible','on');
set(handles.text1,'Visible','on');

% Set a mouse button pressed event
set(gcf,'windowbuttondownFcn',{@mouse_Clicked, handles});

% Update handles structure
guidata(hObject, handles);

disp('Loading Complete');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function analyzeButton_Callback(hObject, eventdata, handles)
disp(['Analyzing ' handles.ProjectName]);

% Determien if the project has current calculation enabled
% or disabled. If they are disabled then we need to 
% temporarily enable them for the current export and then
% disable them again.
if ~isempty(strfind(handles.Project.ControlBlock.Options,'j'))
    isCurrentCalculationsDisabled=false;
else
    isCurrentCalculationsDisabled=true;
end

% Enable current calculations  
% and simulate the project.
handles.Project.enableCurrentCalculations();
handles.Project.simulate();

% If the current calculations were previously
% disabled then redisable it.
if isCurrentCalculationsDisabled;
    handles.Project.disableCurrentCalculations();
    handles.Project.save();
end

% Update the frequency selection
getFrequencies(handles);

disp('Analysis Complete');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function frequencySelect_CreateFcn(hObject, eventdata, handles) %#ok<*INUSD>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function frequencySelect_Callback(hObject, eventdata, handles)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function levelSelect_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function levelSelect_Callback(hObject, eventdata, handles)
setAxisData(handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mouse_Clicked(hObject, eventdata, handles)
% If no project is loaded then return
% If we dont yet have a project open then return
if ~isfield(handles,'Project')
   return; 
end

% If the project hasnt been simulated then return
aBaseFilename=strrep(handles.ProjectName,'.son','');
aIndexFilename=[handles.FilePath 'sondata' filesep aBaseFilename filesep 'jxy' filesep 'index.sid'];
if ~exist(aIndexFilename,'file')
    return
end

% Get the mouse position
aMousePosition=get(gca,'currentpoint');
theXCoordinate = aMousePosition(1);
theYCoordinate = aMousePosition(3);

% If we got a valid data location then 
% update the current data graphs
if aMousePosition(5)==1 && ...
        theXCoordinate < handles.Project.xBoxSize && ...
        theXCoordinate > 0 && ...
        theYCoordinate > 0 && ...
        theYCoordinate < handles.Project.yBoxSize
    
    % Update the circuit diagram
    setAxisData(handles);
    
    % Draw lines to show where the
    % data is being exported from
    handles.FirstLine=line([theXCoordinate theXCoordinate],[0 handles.Project.yBoxSize]);
    handles.SecondLine=line([0 handles.Project.xBoxSize],[theYCoordinate theYCoordinate]);
    
    % Update the graphs
    PlotJXData(handles,theXCoordinate);
    PlotJYData(handles,theYCoordinate);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function getLevels(handles)
% If we dont yet have a project open then return
if ~isfield(handles,'Project')
   return; 
end

% Populate the list for the level selector
for iCounter=0:length(handles.Project.GeometryBlock.SonnetBox.ArrayOfDielectricLayers)-1
    aCellArrayOfLevelNumbers{iCounter+1}=num2str(iCounter); %#ok<AGROW>
end
aCellArrayOfLevelNumbers{length(aCellArrayOfLevelNumbers)}='GND';
set(handles.levelSelect,'String',aCellArrayOfLevelNumbers);
set(handles.levelSelect,'Value',1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function getFrequencies(handles)
% If we dont yet have a project open then return
if ~isfield(handles,'Project')
   return; 
end

% If the project hasnt been simulated then return
aBaseFilename=strrep(handles.ProjectName,'.son','');
aIndexFilename=[handles.FilePath 'sondata' filesep aBaseFilename filesep 'jxy' filesep 'index.sid'];
if ~exist(aIndexFilename,'file')
    return
end

% Scale the frequency so it is in terms of the project's units
% Get a multiplier for the frequency
% based on the project's unit selection.
switch lower(handles.Project.DimensionBlock.FrequencyUnit)
    case 'hz'
        aFactor=1;
    case 'khz'
        aFactor=1e3;
    case 'mhz'
        aFactor=1e6;
    case 'ghz'
        aFactor=1e9;
    case 'thz'
        aFactor=1e12;
end

% Get the frequency values from the project's index.sid file
aListOfFrequencies=[];
aFid=fopen(aIndexFilename);
aTempLine=fgetl(aFid);
while true
    if strcmp(aTempLine,'!>< FREQS')
        aFrequencyLine=fgetl(aFid);
        aFrequencyLine=strrep(aFrequencyLine,'!>< ','');
        aListOfFrequencies=[aListOfFrequencies sscanf(aFrequencyLine,'%g')/aFactor]; %#ok<AGROW>
    end
    
    % Get new input and if we are at the end of the file then break
    aTempLine=fgetl(aFid);
    if (feof(aFid)==1)
        break;  
    end
end

% Populate the list for the frequency selector
set(handles.frequencySelect,'String',aListOfFrequencies);
set(handles.frequencySelect,'Value',1);

% Close the index file
fclose(aFid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function PlotJXData(handles,theXCoordinate)
% Define a JXY line object that 
% is located at the vertical cut.
aVerticalLine=JXYLine(true,theXCoordinate);

% Find the selected frequency value
aListOfFrequencies  = cellstr(get(handles.frequencySelect,'String'));
aSelectedFrequency  = str2double(aListOfFrequencies{get(handles.frequencySelect,'Value')});

% Find the selected level value
aListOfLevels = cellstr(get(handles.levelSelect,'String'));
aSelectedLevel  = aListOfLevels{get(handles.levelSelect,'Value')};
if strcmpi(aSelectedLevel,'GND')==0
    aLevelToDraw=str2double(aSelectedLevel);
else
    aSelectedLevel=length(handles.Project.GeometryBlock.SonnetBox.ArrayOfDielectricLayers)-1;
end

% Extract the current data
aData=handles.Project.exportCurrents(aVerticalLine,'JX',handles.PortObjects,...
    aSelectedFrequency,handles.Project.xCellSize,handles.Project.yCellSize,aSelectedLevel);

% Scale the Y values so they match the inverted grid
aYAxisData=handles.Project.yBoxSize-aData(1).YPosition;

% Plot the JX current across the vertical cut
figure(handles.JXPlot)
stairs(aYAxisData,aData(1).Data)
title(['JX Data Across a Vertical Cut at ' num2str(theXCoordinate)])
xlabel('Y Location')
ylabel('Current Magnitude (amp/meter)')
grid on

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function PlotJYData(handles,theYCoordinate)
% Define a JXY line object that 
% is located at the vertical cut.
aHorizontalLine=JXYLine(false,handles.Project.yBoxSize-theYCoordinate);

% Find the selected frequency value
aListOfFrequencies  = cellstr(get(handles.frequencySelect,'String'));
aSelectedFrequency  = str2double(aListOfFrequencies{get(handles.frequencySelect,'Value')});

% Find the selected level value
aListOfLevels = cellstr(get(handles.levelSelect,'String'));
aSelectedLevel  = aListOfLevels{get(handles.levelSelect,'Value')};
if strcmpi(aSelectedLevel,'GND')==0
    aLevelToDraw=str2double(aSelectedLevel);
else
    aSelectedLevel=length(handles.Project.GeometryBlock.SonnetBox.ArrayOfDielectricLayers)-1;
end

% Extract the current data
aData=handles.Project.exportCurrents(aHorizontalLine,'JY',handles.PortObjects,...
    aSelectedFrequency,handles.Project.xCellSize,handles.Project.yCellSize,aSelectedLevel);

% Plot the JY current across the vertical cut
figure(handles.JYPlot)
stairs(aData(1).XPosition,aData(1).Data)
title(['JY Data Across a Horizontal Cut at ' num2str(theYCoordinate)])
xlabel('X Location')
ylabel('Current Magnitude (amp/meter)')
grid on

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function PortValues_Callback(hObject, eventdata, handles) %#ok<*DEFNU,*INUSL>

% If there are no ports then return
if ~isfield(handles,'PortObjects')
    disp('Can not open port view: Project has no ports');
    return
end

% Open the port editor GUI which allows the 
% user to edit the port voltage values.
PortValueEditor(handles.PortObjects);

% Update handles structure
guidata(hObject, handles);

% Set a mouse button pressed event
set(gcf,'windowbuttondownFcn',{@mouse_Clicked, handles});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function setAxisData(handles)
% plots the circuit in the axis area of the GUI

cla(handles.circuitDiagram,'reset')

% If we dont yet have a project open then return
if ~isfield(handles,'Project')
    return;
end

% Determine which level to draw
aListOfLevels = cellstr(get(handles.levelSelect,'String'));
aLevelToDraw  = aListOfLevels{get(handles.levelSelect,'Value')};
if strcmpi(aLevelToDraw,'GND')==0
    aLevelToDraw=str2double(aLevelToDraw);
else
    aLevelToDraw=length(handles.Project.GeometryBlock.SonnetBox.ArrayOfDielectricLayers)-1;
end

% Invert the axis
set(gca,'Ydir','reverse')

hold on

% Loop for all the polygons in the file.
% if they are on the proper level then we will plot them.
% this iteration we will plot metals only.
for iPlotCounter=1:length(handles.Project.GeometryBlock.ArrayOfPolygons);
    
    % if the polygon is on a different level then go to the next
    % polygon in the array of polygons.
    if handles.Project.GeometryBlock.ArrayOfPolygons{iPlotCounter}.MetalizationLevelIndex ~= aLevelToDraw || ...
            strcmpi(handles.Project.GeometryBlock.ArrayOfPolygons{iPlotCounter}.Type,'')==0
        continue;
    end
    
    % Draw the polygon
    anArrayOfXValues = cell2mat(handles.Project.GeometryBlock.ArrayOfPolygons{iPlotCounter}.XCoordinateValues);
    anArrayOfYValues = cell2mat(handles.Project.GeometryBlock.ArrayOfPolygons{iPlotCounter}.YCoordinateValues);
    fill(anArrayOfXValues,anArrayOfYValues,[1 0 1]);
    
    % Add text to display the polygon's debugId
    aTextXLocation=handles.Project.GeometryBlock.ArrayOfPolygons{iPlotCounter}.CentroidXCoordinate-2*handles.Project.xBoxSize()/100;
    aTextYLocation=handles.Project.GeometryBlock.ArrayOfPolygons{iPlotCounter}.CentroidYCoordinate;
    aString=num2str(handles.Project.GeometryBlock.ArrayOfPolygons{iPlotCounter}.DebugId);
    text(aTextXLocation,aTextYLocation,aString)
    
end
% Loop for all the polygons in the file.
% if they are on the proper level then we will plot them.
% this iteration we will plot dielectric bricks only.
for iPlotCounter=1:length(handles.Project.GeometryBlock.ArrayOfPolygons)
    
    % if the polygon is on a different level then go to the next
    % polygon in the array of polygons.
    if handles.Project.GeometryBlock.ArrayOfPolygons{iPlotCounter}.MetalizationLevelIndex ~= aLevelToDraw || ...
            strcmpi(handles.Project.GeometryBlock.ArrayOfPolygons{iPlotCounter}.Type,'BRI POLY')==0
        continue;
    end
    
    % Draw the polygon
    anArrayOfXValues = cell2mat(handles.Project.GeometryBlock.ArrayOfPolygons{iPlotCounter}.XCoordinateValues);
    anArrayOfYValues = cell2mat(handles.Project.GeometryBlock.ArrayOfPolygons{iPlotCounter}.YCoordinateValues);
    fill(anArrayOfXValues,anArrayOfYValues,[.4 .8 .8]);
    
    % Add text to display the polygon's debugId
    aTextXLocation=handles.Project.GeometryBlock.ArrayOfPolygons{iPlotCounter}.CentroidXCoordinate-2*handles.Project.xBoxSize()/100;
    aTextYLocation=handles.Project.GeometryBlock.ArrayOfPolygons{iPlotCounter}.CentroidYCoordinate;
    aString=num2str(handles.Project.GeometryBlock.ArrayOfPolygons{iPlotCounter}.DebugId);
    text(aTextXLocation,aTextYLocation,aString)
    
end
% Loop for all the polygons in the file.
% if they are on the proper level then we will plot them.
% this iteration we will plot vias only.
for iPlotCounter=1:length(handles.Project.GeometryBlock.ArrayOfPolygons)
    
    % if the polygon is on a different level then go to the next
    % polygon in the array of polygons.
    if handles.Project.GeometryBlock.ArrayOfPolygons{iPlotCounter}.MetalizationLevelIndex ~= aLevelToDraw || ...
            strcmpi(handles.Project.GeometryBlock.ArrayOfPolygons{iPlotCounter}.Type,'VIA POLYGON')==0
        continue;
    end
    
    % Draw the polygon
    anArrayOfXValues = cell2mat(handles.Project.GeometryBlock.ArrayOfPolygons{iPlotCounter}.XCoordinateValues);
    anArrayOfYValues = cell2mat(handles.Project.GeometryBlock.ArrayOfPolygons{iPlotCounter}.YCoordinateValues);
    fill(anArrayOfXValues,anArrayOfYValues,[1 .5 .2]);
    
    % Add text to display the polygon's debugId
    aTextXLocation=handles.Project.GeometryBlock.ArrayOfPolygons{iPlotCounter}.CentroidXCoordinate-2*handles.Project.xBoxSize()/100;
    aTextYLocation=handles.Project.GeometryBlock.ArrayOfPolygons{iPlotCounter}.CentroidYCoordinate;
    aString=num2str(handles.Project.GeometryBlock.ArrayOfPolygons{iPlotCounter}.DebugId);
    text(aTextXLocation,aTextYLocation,aString)
    
end
% Loop for all the ports in the file.
% if they are connected to a polygon on the proper level we will plot them
% this iteration we will plot ports only.
for iPlotCounter=1:length(handles.Project.GeometryBlock.ArrayOfPorts)
    
    % if the port is on a different level then go to the next
    % port in the array of ports.
    aPolygon=handles.Project.GeometryBlock.ArrayOfPorts{iPlotCounter}.Polygon;
    if aPolygon==-1 || aPolygon.MetalizationLevelIndex ~= aLevelToDraw
        continue;
    end
    
    % determine the coordinates for the box that surrounds the port number
    aPort = handles.Project.GeometryBlock.ArrayOfPorts{iPlotCounter};
    anArrayOfXValues = [...
        aPort.XCoordinate-1*handles.Project.xBoxSize()/100,...
        aPort.XCoordinate+1*handles.Project.xBoxSize()/100,...
        aPort.XCoordinate+1*handles.Project.xBoxSize()/100,...
        aPort.XCoordinate-1*handles.Project.xBoxSize()/100];
    
    anArrayOfYValues = [...
        aPort.YCoordinate-1*handles.Project.yBoxSize()/100,...
        aPort.YCoordinate-1*handles.Project.yBoxSize()/100,...
        aPort.YCoordinate+1*handles.Project.yBoxSize()/100,...
        aPort.YCoordinate+1*handles.Project.yBoxSize()/100];
    
    % Determine a location to place the text
    aTextYValue=aPort.YCoordinate;
    aTextXValue=aPort.XCoordinate-handles.Project.yBoxSize()/100;
    
    % Draw the box and the text
    fill(anArrayOfXValues,anArrayOfYValues,[1 1 1]);
    text(aTextXValue,aTextYValue,num2str(aPort.PortNumber));
    
end

grid on
hold off

% draw the boundries for the box
XboxLength=handles.Project.GeometryBlock.SonnetBox.XWidthOfTheBox;
YboxLength=handles.Project.GeometryBlock.SonnetBox.YWidthOfTheBox;
line([0 XboxLength XboxLength 0 0],[0 0 YboxLength YboxLength 0]);
line([0 XboxLength XboxLength 0 0],[0 0 YboxLength YboxLength 0]);

% find good major tick sizes
anMajorXTick=linspace(0,XboxLength,10);
anMajorYTick=linspace(0,YboxLength,10);
anMajorXTick=round(anMajorXTick*10)/10;
anMajorYTick=round(anMajorYTick*10)/10;

% store the values for the minor ticks
anMinorXTick=round(linspace(0,XboxLength,10));
anMinorYTick=round(linspace(0,YboxLength,10));

% change the grid
anAxis=get(gcf,'CurrentAxes');

set(anAxis,'XMinorGrid','On');
set(anAxis,'YMinorGrid','On');
% % set(anAxis,'XMinorTick','On');
% % set(anAxis,'YMinorTick','On');

set(anAxis,'XTick',anMajorXTick);
set(anAxis,'YTick',anMajorYTick);

% set(anAxis,'XMinorTick',anMinorXTick);
% set(anAxis,'YMinorTick',anMinorYTick);

% Set the axis
axis([(0-.05*XboxLength) (XboxLength+.05*XboxLength) (0-.05*YboxLength) (YboxLength+.05*YboxLength)]);
