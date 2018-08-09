function varargout = PortValueEditor(varargin)
% PORTVALUEEDITOR MATLAB code for PortValueEditor.fig
%      PORTVALUEEDITOR, by itself, creates a new PORTVALUEEDITOR or raises the existing
%      singleton*.
%
%      H = PORTVALUEEDITOR returns the handle to a new PORTVALUEEDITOR or the handle to
%      the existing singleton*.
%
%      PORTVALUEEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PORTVALUEEDITOR.M with the given input arguments.
%
%      PORTVALUEEDITOR('Property','Value',...) creates a new PORTVALUEEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PortValueEditor_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PortValueEditor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PortValueEditor

% Last Modified by GUIDE v2.5 20-Sep-2010 13:21:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @PortValueEditor_OpeningFcn, ...
    'gui_OutputFcn',  @PortValueEditor_OutputFcn, ...
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


% --- Executes just before PortValueEditor is made visible.
function PortValueEditor_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PortValueEditor (see VARARGIN)

handles.PortObjects=varargin{1};

% Initialize the table with a cell array of port data
if ~isempty(handles.PortObjects)
    aCellArray=cell(length(handles.PortObjects),6);
    for iCounter=1:length(handles.PortObjects)
        aCellArray{iCounter,1}=handles.PortObjects(iCounter).Voltage;
        aCellArray{iCounter,2}=handles.PortObjects(iCounter).Phase;
        aCellArray{iCounter,3}=handles.PortObjects(iCounter).Resistance;
        aCellArray{iCounter,4}=handles.PortObjects(iCounter).Capacitance;
        aCellArray{iCounter,5}=handles.PortObjects(iCounter).Inductance;
        aCellArray{iCounter,6}=handles.PortObjects(iCounter).Reactance;
    end
    set(handles.portTable,'Data',aCellArray);
else
    set(handles.portTable,'Data',{});
end

% Choose default command line output for PortValueEditor
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PortValueEditor wait for user response (see UIRESUME)
uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = PortValueEditor_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
varargout{1} = [];

% --- Executes when entered data in editable cell(s) in portTable.
function portTable_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to portTable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
switch eventdata.Indices(2)
    case 1
        handles.PortObjects(eventdata.Indices(1)).Voltage=eventdata.NewData;
    case 2
        handles.PortObjects(eventdata.Indices(1)).Phase=eventdata.NewData;
    case 3
        handles.PortObjects(eventdata.Indices(1)).Resistance=eventdata.NewData;
    case 4
        handles.PortObjects(eventdata.Indices(1)).Capacitance=eventdata.NewData;
    case 5
        handles.PortObjects(eventdata.Indices(1)).Inductance=eventdata.NewData;
    case 6
        handles.PortObjects(eventdata.Indices(1)).Reactance=eventdata.NewData;
end

% Update handles structure
guidata(hObject, handles);
