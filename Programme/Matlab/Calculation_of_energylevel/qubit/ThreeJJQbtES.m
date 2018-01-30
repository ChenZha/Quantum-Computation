
function varargout = ThreeJJQbtES(varargin)
% THREEJJQBTES M-file for ThreeJJQbtES.fig
%      THREEJJQBTES, by itself, creates a new THREEJJQBTES or raises the existing
%      singleton*.
%
%      H = THREEJJQBTES returns the handle to a new THREEJJQBTES or the handle to
%      the existing singleton*.
%
%      THREEJJQBTES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in THREEJJQBTES.M with the given input arguments.
%
%      THREEJJQBTES('Property','Value',...) creates a new THREEJJQBTES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ThreeJJQbtES_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ThreeJJQbtES_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
% Last Modified by GUIDE v2.5 15-Mar-2012 19:32:52


gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ThreeJJQbtES_OpeningFcn, ...
                   'gui_OutputFcn',  @ThreeJJQbtES_OutputFcn, ...
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


% --- Executes just before ThreeJJQbtES is made visible.
function ThreeJJQbtES_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ThreeJJQbtES (see VARARGIN)
% Choose default command line output for ThreeJJQbtES
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ThreeJJQbtES wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ThreeJJQbtES_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function alpha_value_Callback(hObject, eventdata, handles)
% hObject    handle to alpha_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Check_alpha
str=get(hObject,'String');
temp = str2double(str);
if isempty(str)
    set(handles.alpha_status,'String','Empty!','ForegroundColor',[1 0 0]);
    Check_alpha = false;
elseif isnan(temp)
    set(handles.alpha_status,'String','Must be numeric!','ForegroundColor',[1 0 0]);
    Check_alpha = false;
elseif temp<=0
     set(handles.alpha_status,'String','Incorrect value!','ForegroundColor',[1 0 0]);
     Check_alpha = false;
elseif temp <0.4 || temp >=1
     set(handles.alpha_status,'String','Improper value!','ForegroundColor',[0 0 0]);
     Check_alpha = true;
     set(handles.info_enteralpha,'Visible','off');
else
     set(handles.alpha_status,'String','OK!','ForegroundColor',[0.502 0.502 0.502]);
     Check_alpha = true;
     set(handles.info_enteralpha,'Visible','off');
end
    
% Hints: get(hObject,'String') returns contents of alpha_value as text
%        str2double(get(hObject,'String')) returns contents of alpha_value as a double


% --- Executes during object creation, after setting all properties.
function alpha_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to alpha_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global Check_alpha
Check_alpha = false;    % alpha has no default value
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function alpha_title_CreateFcn(hObject, eventdata, handles)
% hObject    handle to alpha_title (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function beta_value_Callback(hObject, eventdata, handles)
% hObject    handle to beta_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Check_beta
str=get(hObject,'String');
temp = str2double(str);
if isempty(str)
    set(handles.beta_status,'String','Empty!','ForegroundColor',[1 0 0]);
    Check_beta = false;
elseif isnan(temp)
    set(handles.beta_status,'String','Must be numeric!','ForegroundColor',[1 0 0]);
    Check_beta = false;
elseif temp<0
     set(handles.beta_status,'String','Incorrect value!','ForegroundColor',[1 0 0]);
     Check_beta = false;
elseif temp >=1
     set(handles.beta_status,'String','Improper value!','ForegroundColor',[0 0 0]);
     Check_beta = true;
elseif temp == 0
     set(handles.beta_status,'String','Default','ForegroundColor',[0.502 0.502 0.502]);
     Check_beta = true;
else
     set(handles.beta_status,'String','OK!','ForegroundColor',[0.502 0.502 0.502]);
     Check_beta = true;
end

% Hints: get(hObject,'String') returns contents of beta_value as text
%        str2double(get(hObject,'String')) returns contents of beta_value as a double


% --- Executes during object creation, after setting all properties.
function beta_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to beta_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global Check_beta
Check_beta = true;  % beta has a default value
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function kappa_value_Callback(hObject, eventdata, handles)
% hObject    handle to kappa_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Check_kappa
str=get(hObject,'String');
temp = str2double(str);
if isempty(str)
    set(handles.kappa_status,'String','Empty!','ForegroundColor',[1 0 0]);
    Check_kappa = false;
elseif isnan(temp)
    set(handles.kappa_status,'String','Must be numeric!','ForegroundColor',[1 0 0]);
    Check_kappa = false;
elseif abs(temp)>=1
     set(handles.kappa_status,'String','Incorrect value!','ForegroundColor',[1 0 0]);
     Check_kappa = false;
elseif abs(temp)>=0.4
     set(handles.kappa_status,'String','Improper value!','ForegroundColor',[0 0 0]);
     Check_kappa = true;
elseif temp == 0
     set(handles.kappa_status,'String','Default','ForegroundColor',[0.502 0.502 0.502]);
     Check_kappa=true;
else
     set(handles.kappa_status,'String','OK!','ForegroundColor',[0.502 0.502 0.502]);
     Check_kappa=true;
end
% Hints: get(hObject,'String') returns contents of kappa_value as text
%        str2double(get(hObject,'String')) returns contents of kappa_value as a double


% --- Executes during object creation, after setting all properties.
function kappa_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to kappa_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global Check_kappa
Check_kappa=true;   % kappa has a default value
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sigma_value_Callback(hObject, eventdata, handles)
% hObject    handle to sigma_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Check_sigma
str=get(hObject,'String');
temp = str2double(str);
if isempty(str)
    set(handles.sigma_status,'String','Empty!','ForegroundColor',[1 0 0]);
    Check_sigma = false;
elseif isnan(temp)
    set(handles.sigma_status,'String','Must be numeric!','ForegroundColor',[1 0 0]);
    Check_sigma = false;
elseif temp<0
     set(handles.sigma_status,'String','Incorrect value!','ForegroundColor',[1 0 0]);
     Check_sigma = false;
elseif temp>=0.5
     set(handles.sigma_status,'String','Improper value!','ForegroundColor',[0 0 0]);
     Check_sigma = true;
elseif temp == 0
     set(handles.sigma_status,'String','Default','ForegroundColor',[0.502 0.502 0.502]);
     Check_sigma = true;
else
     set(handles.sigma_status,'String','OK!','ForegroundColor',[0.502 0.502 0.502]);
     Check_sigma = true;
end
% Hints: get(hObject,'String') returns contents of sigma_value as text
%        str2double(get(hObject,'String')) returns contents of sigma_value as a double


% --- Executes during object creation, after setting all properties.
function sigma_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sigma_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global Check_sigma
Check_sigma = true;     % sigma has a default value
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Ej_value_Callback(hObject, eventdata, handles)
% hObject    handle to Ej_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Check_Ej
str=get(hObject,'String');
temp = str2double(str);
if isempty(str)
    set(handles.Ej_status,'String','Empty!','ForegroundColor',[1 0 0]);
    Check_Ej = false;
elseif isnan(temp)
    set(handles.Ej_status,'String','Must be numeric!','ForegroundColor',[1 0 0]);
    Check_Ej = false;
elseif temp<=0
     set(handles.Ej_status,'String','Incorrect value!','ForegroundColor',[1 0 0]);
     Check_Ej = false;
elseif temp>500 || temp<20
     set(handles.Ej_status,'String','Improper value!','ForegroundColor',[0.502 0.502 0.502]);
     Check_Ej = true;
else
     set(handles.Ej_status,'String','OK!','ForegroundColor',[0.502 0.502 0.502]);
     Check_Ej = true;
end
% Hints: get(hObject,'String') returns contents of Ej_value as text
%        str2double(get(hObject,'String')) returns contents of Ej_value as a double


% --- Executes during object creation, after setting all properties.
function Ej_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Ej_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global Check_Ej
Check_Ej = false;   % Ej has no default value
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Ec_value_Callback(hObject, eventdata, handles)
% hObject    handle to Ec_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Check_Ec
str=get(hObject,'String');
temp = str2double(str);
if isempty(str)
    set(handles.Ec_status,'String','Empty!','ForegroundColor',[1 0 0]);
    Check_Ec = false;
elseif isnan(temp)
    set(handles.Ec_status,'String','Must be numeric!','ForegroundColor',[1 0 0]);
    Check_Ec = false;
elseif temp<=0
     set(handles.Ec_status,'String','Incorrect value!','ForegroundColor',[1 0 0]);
     Check_Ec = false;
elseif temp>50 || temp<0.5
     set(handles.Ec_status,'String','Improper value!','ForegroundColor',[0.502 0.502 0.502]);
     Check_Ec = true;
else
     set(handles.Ec_status,'String','OK!','ForegroundColor',[0.502 0.502 0.502]);
     Check_Ec = true;
end
% Hints: get(hObject,'String') returns contents of Ec_value as text
%        str2double(get(hObject,'String')) returns contents of Ec_value as a double


% --- Executes during object creation, after setting all properties.
function Ec_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Ec_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global Check_Ec
Check_Ec = false;   % Ec has no default value
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function calc_range_value_Callback(hObject, eventdata, handles)
% hObject    handle to calc_range (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Check_range
str=get(hObject,'String');
temp = str2double(str);
if isempty(str)
    set(handles.calc_range_status,'String','Empty!','ForegroundColor',[1 0 0]);
    Check_range = false;
elseif isnan(temp)
    set(handles.calc_range_status,'String','Must be numeric!','ForegroundColor',[1 0 0]);
    Check_range = false;
elseif temp>=0.5
     set(handles.calc_range_status,'String','Incorrect value!','ForegroundColor',[1 0 0]);
     Check_range = false;
elseif temp<-1
     set(handles.calc_range_status,'String','Improper value!','ForegroundColor',[0.502 0.502 0.502]);
     set(handles.calc_range_end,'String',num2str(1-temp),'ForegroundColor',[0 0 0]);
     Check_range = true;
elseif temp == 0
     set(handles.calc_range_status,'String','Default','ForegroundColor',[0.502 0.502 0.502]);
     set(handles.calc_range_end,'String',num2str(1-temp),'ForegroundColor',[0 0 0]);
     Check_range = true;
else
     set(handles.calc_range_status,'String','OK!','ForegroundColor',[0.502 0.502 0.502]);
     set(handles.calc_range_end,'String',num2str(1-temp),'ForegroundColor',[0 0 0]);
     Check_range = true;
end
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function calc_range_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to calc_range (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global Check_range
Check_range = true;    % calc_range has a default value
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function calc_n_points_Callback(hObject, eventdata, handles)
% hObject    handle to calc_n_points (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Check_calc_n_points
str=get(hObject,'String');
temp = str2double(str);
if isempty(str)
    set(handles.calc_n_points_status,'String','Empty!','ForegroundColor',[1 0 0]);
    Check_calc_n_points = false;
elseif isnan(temp)
    set(handles.calc_n_points_status,'String','Must be numeric!','ForegroundColor',[1 0 0]);
    Check_calc_n_points = false;
elseif temp<=2
     set(handles.calc_n_points_status,'String','Incorrect value!','ForegroundColor',[1 0 0]);
     Check_calc_n_points = false;
elseif temp>500
     set(handles.calc_n_points_status,'String','Too many points, the computation process may take a long time!','ForegroundColor',[1 0 0]);
     Check_calc_n_points = true;
elseif temp<=8 || temp>5e3
     set(handles.calc_n_points_status,'String','Improper value!','ForegroundColor',[0.502 0.502 0.502]);
     Check_calc_n_points = true;
elseif temp == 100
     set(handles.calc_n_points_status,'String','Default','ForegroundColor',[0.502 0.502 0.502]);
     Check_calc_n_points = true;
else
     set(handles.calc_n_points_status,'String','OK!','ForegroundColor',[0.502 0.502 0.502]);
     Check_calc_n_points = true;
end
% Hints: get(hObject,'String') returns contents of calc_n_points as text
%        str2double(get(hObject,'String')) returns contents of calc_n_points as a double


% --- Executes during object creation, after setting all properties.
function calc_n_points_CreateFcn(hObject, eventdata, handles)
% hObject    handle to calc_n_points (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global Check_calc_n_points
Check_calc_n_points = true; % calc_n_points has a default value
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function calc_range_end_CreateFcn(hObject, eventdata, handles)
% hObject    handle to calc_range_end (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function nlevels_value_Callback(hObject, eventdata, handles)
% hObject    handle to nlevels_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Check_nlevels_value
str=get(hObject,'String');
temp = str2double(str);
if isempty(str)
    set(handles.nlevels_value_status,'String','Empty!','ForegroundColor',[1 0 0]);
    Check_nlevels_value = false;
elseif isnan(temp)
    set(handles.nlevels_value_status,'String','Must be numeric!','ForegroundColor',[1 0 0]);
    Check_nlevels_value = false;
elseif temp<1
     set(handles.nlevels_value_status,'String','Incorrect value!','ForegroundColor',[1 0 0]);
     Check_nlevels_value = false;
elseif temp<3 || temp>500
     set(handles.nlevels_value_status,'String','Improper value!','ForegroundColor',[0.502 0.502 0.502]);     
elseif temp==4
     set(handles.nlevels_value_status,'String','Default','ForegroundColor',[0.502 0.502 0.502]);
     Check_nlevels_value = true;
else
     set(handles.nlevels_value_status,'String','OK!','ForegroundColor',[0.502 0.502 0.502]);
     Check_nlevels_value = true;
end
% Hints: get(hObject,'String') returns contents of nlevels_value as text
%        str2double(get(hObject,'String')) returns contents of nlevels_value as a double


% --- Executes during object creation, after setting all properties.
function nlevels_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nlevels_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global Check_nlevels_value
Check_nlevels_value = true;  % nlevels_value has a default value
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function nk_value_Callback(hObject, eventdata, handles)
% hObject    handle to nk_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Check_nk_value
str=get(hObject,'String');
temp = str2double(str);
if isempty(str)
    set(handles.nk_value_status,'String','Empty!','ForegroundColor',[1 0 0]);
    Check_nk_value = false;
elseif isnan(temp)
    set(handles.nk_value_status,'String','Must be numeric!','ForegroundColor',[1 0 0]);
    Check_nk_value = false;
elseif temp<1
     set(handles.nk_value_status,'String','Incorrect value!','ForegroundColor',[1 0 0]);
     Check_nk_value = false;
elseif temp > 20 || temp < 3
    set(handles.nk_value_status,'String','Improper value!','ForegroundColor',[0.502 0.502 0.502]);
    Check_nk_value = true;
elseif temp == 5
     set(handles.nk_value_status,'String','Default','ForegroundColor',[0.502 0.502 0.502]);
     Check_nk_value = true;
else
     set(handles.nk_value_status,'String','OK!','ForegroundColor',[0.502 0.502 0.502]);
     Check_nk_value = true;
end
% Hints: get(hObject,'String') returns contents of nk_value as text
%        str2double(get(hObject,'String')) returns contents of nk_value as a double


% --- Executes during object creation, after setting all properties.
function nk_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nk_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global Check_nk_value
Check_nk_value = true; % nk_value has a default value
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nl_value_Callback(hObject, eventdata, handles)
% hObject    handle to nl_title (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Check_nl_value
str=get(hObject,'String');
temp = str2double(str);
if isempty(str)
    set(handles.nl_value_status,'String','Empty!','ForegroundColor',[1 0 0]);
    Check_nl_value = false;
elseif isnan(temp)
    set(handles.nl_value_status,'String','Must be numeric!','ForegroundColor',[1 0 0]);
    Check_nl_value = false;
elseif temp<1
     set(handles.nl_value_status,'String','Incorrect value!','ForegroundColor',[1 0 0]);
     Check_nl_value = false;
elseif temp > 40 || temp < 5
    set(handles.nl_value_status,'String','Improper value!','ForegroundColor',[0.502 0.502 0.502]);
    Check_nl_value = true;
elseif temp == 10
     set(handles.nl_value_status,'String','Default','ForegroundColor',[0.502 0.502 0.502]);
     Check_nl_value = true;
else
     set(handles.nl_value_status,'String','OK!','ForegroundColor',[0.502 0.502 0.502]);
     Check_nl_value = true;
end
% Hints: get(hObject,'String') returns contents of nl_title as text
%        str2double(get(hObject,'String')) returns contents of nl_title as a double

% --- Executes during object creation, after setting all properties.
function nl_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nk_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global Check_nl_value
Check_nl_value = true; % nl_value has a default value
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function nl_title_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nl_title (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nm_value_Callback(hObject, eventdata, handles)
% hObject    handle to nm_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Check_nm_value
str=get(hObject,'String');
temp = str2double(str);
if isempty(str)
    set(handles.nm_value_status,'String','Empty!','ForegroundColor',[1 0 0]);
    Check_nm_value = false;
elseif isnan(temp)
    set(handles.nm_value_status,'String','Must be numeric!','ForegroundColor',[1 0 0]);
    Check_nm_value = false;
elseif temp<1
     set(handles.nm_value_status,'String','Incorrect value!','ForegroundColor',[1 0 0]);
     Check_nm_value = false;
elseif temp > 8 
    set(handles.nm_value_status,'String','Improper value!','ForegroundColor',[0.502 0.502 0.502]);
    Check_nm_value = true;
elseif temp == 2
     set(handles.nm_value_status,'String','Default','ForegroundColor',[0.502 0.502 0.502]);
     Check_nm_value = true;
else
     set(handles.nm_value_status,'String','OK!','ForegroundColor',[0.502 0.502 0.502]);
     Check_nm_value = true;
end
% Hints: get(hObject,'String') returns contents of nm_value as text
%        str2double(get(hObject,'String')) returns contents of nm_value as a double


% --- Executes during object creation, after setting all properties.
function nm_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nm_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global Check_nm_value
Check_nm_value = true; % nm_value has a default value
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Jc_Callback(hObject, eventdata, handles)
% hObject    handle to Jc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Check_Jc
str=get(hObject,'String');
temp = str2double(str);
if isempty(str)
    set(handles.Jc_status,'String','Empty!','ForegroundColor',[1 0 0]);
    Check_Jc = false;
elseif isnan(temp)
    set(handles.Jc_status,'String','Must be numeric!','ForegroundColor',[1 0 0]);
    Check_Jc = false;
elseif temp<=0
     set(handles.Jc_status,'String','Incorrect value!','ForegroundColor',[1 0 0]);
     Check_Jc = false;
elseif temp > 5 || temp<0.05
    set(handles.Jc_status,'String','Improper value!','ForegroundColor',[0.502 0.502 0.502]);
    Check_Jc = true;
else
     set(handles.Jc_status,'String','OK!','ForegroundColor',[0.502 0.502 0.502]);
     Check_Jc = true;
end
% Hints: get(hObject,'String') returns contents of Jc as text
%        str2double(get(hObject,'String')) returns contents of Jc as a double


% --- Executes during object creation, after setting all properties.
function Jc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Jc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global Check_Jc
Check_Jc = false;   % Jc has no default value
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Cc_Callback(hObject, eventdata, handles)
% hObject    handle to Cc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Check_Cc
str=get(hObject,'String');
temp = str2double(str);
if isempty(str)
    set(handles.Cc_status,'String','Empty!','ForegroundColor',[1 0 0]);
    Check_Cc = false;
elseif isnan(temp)
    set(handles.Cc_status,'String','Must be numeric!','ForegroundColor',[1 0 0]);
    Check_Cc = false;
elseif temp<=0
     set(handles.Cc_status,'String','Incorrect value!','ForegroundColor',[1 0 0]);
     Check_Cc = false;
elseif temp > 200 || temp<10
    set(handles.Cc_status,'String','Improper value!','ForegroundColor',[0.502 0.502 0.502]);
    Check_Cc = true;
elseif temp == 100
    set(handles.Cc_status,'String','Default','ForegroundColor',[0.502 0.502 0.502]);
    Check_Cc = true;
else
     set(handles.Cc_status,'String','OK!','ForegroundColor',[0.502 0.502 0.502]);
     Check_Cc = true;
end
% Hints: get(hObject,'String') returns contents of Cc as text
%        str2double(get(hObject,'String')) returns contents of Cc as a double


% --- Executes during object creation, after setting all properties.
function Cc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Cc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global Check_Cc
Check_Cc = true;    % Cc has a default value
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function junction_area_Callback(hObject, eventdata, handles)
% hObject    handle to junction_area (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Check_junction_area
str=get(hObject,'String');
temp = str2double(str);
if isempty(str)
    set(handles.junction_area_status,'String','Empty!','ForegroundColor',[1 0 0]);
    Check_junction_area = false;
elseif isnan(temp)
    set(handles.junction_area_status,'String','Must be numeric!','ForegroundColor',[1 0 0]);
    Check_junction_area = false;
elseif temp<=0
     set(handles.junction_area_status,'String','Incorrect value!','ForegroundColor',[1 0 0]);
     Check_junction_area = false;
elseif temp > 0.3 || temp<0.01
    set(handles.junction_area_status,'String','Improper value!','ForegroundColor',[0.502 0.502 0.502]);
    Check_junction_area = true;
else
    set(handles.junction_area_status,'String','OK!','ForegroundColor',[0.502 0.502 0.502]);
    Check_junction_area = true;
end
% Hints: get(hObject,'String') returns contents of junction_area as text
%        str2double(get(hObject,'String')) returns contents of junction_area as a double


% --- Executes during object creation, after setting all properties.
function junction_area_CreateFcn(hObject, eventdata, handles)
% hObject    handle to junction_area (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global Check_junction_area
Check_junction_area = false;    % junction_area has no default value
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Inductance_Callback(hObject, eventdata, handles)
% hObject    handle to Inductance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Check_Inductance
str=get(hObject,'String');
temp = str2double(str);
if isempty(str)
    set(handles.Inductance_status,'String','Empty!','ForegroundColor',[1 0 0]);
    Check_Inductance = false;
elseif isnan(temp)
    set(handles.Inductance_status,'String','Must be numeric!','ForegroundColor',[1 0 0]);
    Check_Inductance = false;
elseif temp>1e4 || temp <0
     set(handles.Inductance_status,'String','Incorrect value!','ForegroundColor',[1 0 0]);
     Check_Inductance = false;
elseif temp > 500
    set(handles.Inductance_status,'String','Improper value!','ForegroundColor',[0.502 0.502 0.502]);
    Check_Inductance = true;
elseif temp == 0
    set(handles.Inductance_status,'String','Default','ForegroundColor',[0.502 0.502 0.502]);
    Check_Inductance = true;
else
    set(handles.Inductance_status,'String','OK!','ForegroundColor',[0.502 0.502 0.502]);
    Check_Inductance = true;
end
% Hints: get(hObject,'String') returns contents of Inductance as text
%        str2double(get(hObject,'String')) returns contents of Inductance as a double


% --- Executes during object creation, after setting all properties.
function Inductance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Inductance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global Check_Inductance
Check_Inductance = true;    % Inductance has a default value
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in UserConfirm_Continue.
function UserConfirm_Continue_Callback(hObject, eventdata, handles)
% hObject    handle to UserConfirm_Continue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.UserConfirm_Continue,'Enable','off','Visible','off');
CoreFcn(handles);



% --- Executes on button press in Calc_EjEc.
function Calc_EjEc_Callback(hObject, eventdata, handles)
% hObject    handle to Calc_EjEc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Check_Jc
global Check_Cc
global Check_Ej
global Check_Ec
global Check_junction_area
global Check_Inductance
global Check_alpha
if Check_alpha
    set(handles.info_enteralpha,'Visible','off');
    if Check_Jc && Check_Cc && Check_junction_area && Check_Inductance
        Jc = str2double(get(handles.Jc,'String'));
        Cc = str2double(get(handles.Cc,'String'));
        S = str2double(get(handles.junction_area,'String'));
        L = str2double(get(handles.Inductance,'String'));
        alpha = str2double(get(handles.alpha_value,'String'));
        Ic = Jc*10*S;   % 1kA/cm^2 = 10 muA/mum^2
        C = Cc*S;
        FluxQuantum = 2.067833636e-15;
        PlanksConst = 6.626068e-34;
        ee = 1.602176e-19;
        Ej = Ic*1e-6*FluxQuantum/(2*pi)/PlanksConst/1e9;    % Unit: GHz.
        Ec = ee^2./(2*C*1e-15)/PlanksConst/1e9;  % Unit: GHz.
        beta = (2*pi/(2+1/alpha))*Ic*1e-6*L*1e-12/FluxQuantum;
        Check_Ej = true;
        Check_Ec = true;
        Check_beta = true;
        set(handles.Ej_value,'String',num2str(Ej),'ForegroundColor',[0 0 1]);
        set(handles.Ej_status,'String','Calculated','ForegroundColor',[0.502 0.502 0.502]);
        set(handles.Ec_value,'String',num2str(Ec),'ForegroundColor',[0 0 1]);
        set(handles.Ec_status,'String','Calculated','ForegroundColor',[0.502 0.502 0.502]);
        set(handles.beta_value,'String',num2str(beta),'ForegroundColor',[0 0 1]);
        set(handles.beta_status,'String','Calculated','ForegroundColor',[0.502 0.502 0.502]);
        set(handles.info_Info_disp,'String',['Ic = ', num2str(Ic,'%10.3f'), ' muA (avg.)', char([10 13]),...
            'Ej/Ec = ', num2str(Ej/Ec,'%10.1f')],'ForegroundColor',[0.502 0.502 0.502],'Visible','on');
    end
else
     set(handles.info_enteralpha,'Visible','on');
end
    

function Parallel_labs_Callback(hObject, eventdata, handles)
% hObject    handle to Parallel_labs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Check_Parallel_labs
str=get(hObject,'String');
temp = str2double(str);
if isempty(str)
    set(handles.Parallel_labs_status,'String','Empty! Suggestion: equal to the number of CPU cores','ForegroundColor',[1 0 0]);
    Check_Parallel_labs = false;
elseif isnan(temp)
    set(handles.Parallel_labs_status,'String','Must be numeric! Suggestion: equal to the number of CPU cores','ForegroundColor',[1 0 0]);
    Check_Parallel_labs = false;
elseif temp<1
     set(handles.Parallel_labs_status,'String','Incorrect value! Suggestion: equal to the number of CPU cores','ForegroundColor',[1 0 0]);
     Check_Parallel_labs = false;
elseif floor(temp)<temp
     set(handles.Parallel_labs_status,'String','Must be integer! Suggestion: equal to the number of CPU cores','ForegroundColor',[1 0 0]);
     Check_Parallel_labs = false;
elseif temp==1
     set(handles.Parallel_labs_status,'String','Parallel computing disabled','ForegroundColor',[0.502 0.502 0.502]);
     Check_Parallel_labs = true;
elseif temp>1000
     set(handles.Parallel_labs_status,'String','Improper value! Suggestion: equal to the number of CPU cores','ForegroundColor',[0.502 0.502 0.502]);
     Check_Parallel_labs = true;
elseif temp>100
     set(handles.Parallel_labs_status,'String','Too many labs! Suggestion: equal to the number of CPU cores','ForegroundColor',[0.502 0.502 0.502]);
     Check_Parallel_labs = true;  
else
    set(handles.Parallel_labs_status,'String','(Suggestion: equal to the number of CPU cores)','ForegroundColor',[0.502 0.502 0.502]);
    Check_Parallel_labs = true;  
end
% Hints: get(hObject,'String') returns contents of Parallel_labs as text
%        str2double(get(hObject,'String')) returns contents of Parallel_labs as a double


% --- Executes during object creation, after setting all properties.
function Parallel_labs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Parallel_labs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global Check_Parallel_labs
Check_Parallel_labs = true;     % Parallel_labs has a default value
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Exit_button.
function Exit_button_Callback(hObject, eventdata, handles)
% hObject    handle to Exit_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
nParallel_labs =  str2double(get(handles.Parallel_labs,'String'));
if nParallel_labs > 1
    matlabpool close;
end
exit;


function datafilename_Callback(hObject, eventdata, handles)
% hObject    handle to datafilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Check_datafilename
str=get(hObject,'String');
if isempty(str)
    set(handles.datafilename,'BackgroundColor',[1 0 0]);
    Check_datafilename = false;
else
    k1 = isempty(strfind(str,'\')) + ...
        isempty(strfind(str,'/')) + ...
        isempty(strfind(str,':')) + ...
        isempty(strfind(str,'*')) + ...
        isempty(strfind(str,'?')) + ...
        isempty(strfind(str,'"')) + ...
        isempty(strfind(str,'<')) + ...
        isempty(strfind(str,'>')) + ...
        isempty(strfind(str,'|'));
    if k1 ~= 9
        set(handles.datafilename,'String','Bad filename!','BackgroundColor',[1 0 0]);
        Check_datafilename = false;
    else
        Check_datafilename = true;
        set(handles.datafilename,'BackgroundColor',[1 1 1]);
    end
end
% Hints: get(hObject,'String') returns contents of datafilename as text
%        str2double(get(hObject,'String')) returns contents of datafilename as a double


% --- Executes during object creation, after setting all properties.
function datafilename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to datafilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global Check_datafilename
Check_datafilename = true; % Check_datafilename has a default value
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function save_dir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to save_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global Check_dir
Check_dir = false; % Check_datafilename has no default value
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in browse4dir.
function browse4dir_Callback(hObject, eventdata, handles)
% hObject    handle to browse4dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Check_dir
filename=get(handles.datafilename,'String');
[file,path] = uiputfile([filename,'.dat'],'Save data to:');
if path == 0
    Check_dir = false;
else
    set(handles.save_dir,'String',path);
    set(handles.save_dir,'BackgroundColor',[1 1 1]);
    Check_dir = true;
    set(handles.datafilename,'String',file(1:end-4),'BackgroundColor',[1 1 1]);
    Check_datafilename = true;
end


% --- Executes on button press in StartCalc.
function StartCalc_Callback(hObject, eventdata, handles)
% hObject    handle to StartCalc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Plot3JJQbtEL(Ej,Ec,alpha,beta,kappa,sigma,StartPoint,dFluxBias,nlevels,nk,nl,nm,NMatlabpools)
global Check_alpha;
global Check_beta;
global Check_kappa;
global Check_sigma;
global Check_Ej;
global Check_Ec;
global Check_range;
global Check_calc_n_points;
global Check_nlevels_value;
global Check_nk_value;
global Check_nl_value;
global Check_nm_value;
global Check_Parallel_labs
% Check input parameters:
if ...
        Check_alpha && ...
        Check_beta && ...
        Check_kappa && ...
        Check_sigma && ...
        Check_Ej && ...
        Check_Ec && ...
        Check_range && ...
        Check_calc_n_points && ...
        Check_nlevels_value && ...
        Check_nk_value && ...
        Check_nl_value && ...
        Check_nm_value && ...
        Check_Parallel_labs
    PlotNLevels =  str2double(get(handles.nlevels_value,'String'));
    nk =  str2double(get(handles.nk_value,'String'));
    nl =  str2double(get(handles.nl_value,'String'));
    nm =  str2double(get(handles.nm_value,'String'));
    set(handles.Warnning_Para,'Visible','off');
    matrixdim = nk*nl*nm;
    if PlotNLevels>matrixdim
        set(handles.matrix_dim_check,'String',...
            'Matrix dimension nk*nl*nm smaller than the number of levels to be plotted!',...
            'ForegroundColor',[1 0 0]);
        set(handles.Warnning_Para,'Visible','on');
        set(handles.StartCalc,'ForegroundColor',[0.502 0.502 0.502]);
    else 
        if nm>10 || matrixdim>1000
            set(handles.matrix_dim_check,'String',...
                'Matrix dimension too big, the computation process may take a long time!',...
                'ForegroundColor',[1 0 0]);
            set(handles.UserConfirm_Continue,'Enable','on','Visible','on');
        else
            set(handles.matrix_dim_check,'String','Matrix dimension check: OK!',...
                'ForegroundColor',[0.502 0.502 0.502]);
            set(handles.UserConfirm_Continue,'Enable','off','Visible','off');
            CoreFcn(handles);
        end
    end
else
    set(handles.Warnning_Para,'Visible','on');
    set(handles.StartCalc,'ForegroundColor',[0.502 0.502 0.502]);
end



% --- Executes during object creation, after setting all properties.
function info_Info_disp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to info_Info_disp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function Elapsed_time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Elapsed_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function Remaining_time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Remaining_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function datafilename_title_CreateFcn(hObject, eventdata, handles)
% hObject    handle to datafilename_title (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function info_save_location_CreateFcn(hObject, eventdata, handles)
% hObject    handle to info_save_location (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function Author_Info_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Author_Info (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function Warnning_Para_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Warnning_Para (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function info_UsrCnfrm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to info_UsrCnfrm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function Exit_button_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Exit_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function Parallel_labs_status_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Parallel_labs_status (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function info_Parallel_labs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to info_Parallel_labs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function Parallel_labs_title_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Parallel_labs_title (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in SaveScreenshot.
function SaveScreenshot_Callback(hObject, eventdata, handles)
% hObject    handle to SaveScreenshot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of SaveScreenshot


% --- Executes on button press in DoInterp.
function DoInterp_Callback(hObject, eventdata, handles)
% hObject    handle to DoInterp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of DoInterp


% --- Executes on button press in UnitChoice.
function UnitChoice_Callback(hObject, eventdata, handles)
% hObject    handle to UnitChoice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
button_state = get(hObject,'Value');
if button_state == get(hObject,'Max')
	set(handles.UnitChoice,'String','micro eV');
elseif button_state == get(hObject,'Min')
	set(handles.UnitChoice,'String','h*GHz');
end


function CoreFcn(handles)
global Check_datafilename
global Check_dir
set(handles.Warnning_Para,'Visible','off');
set(handles.StartCalc,'String','BUSY', 'ForegroundColor',[1 0 0],'Enable','inactive');
set(handles.info_Info_disp,'String',['Start time:', datestr(now),char(13),char(10),'Calculating...'],'Visible','on');
alpha =  str2double(get(handles.alpha_value,'String'));
beta =  str2double(get(handles.beta_value,'String'));
kappa =  str2double(get(handles.kappa_value,'String'));
sigma =  str2double(get(handles.sigma_value,'String'));
Ej =  str2double(get(handles.Ej_value,'String'));
Ec =  str2double(get(handles.Ec_value,'String'));
CalcRange =  str2double(get(handles.calc_range_value,'String'));
CalcNPoints =  str2double(get(handles.calc_n_points,'String'));
PlotNLevels =  str2double(get(handles.nlevels_value,'String'));
nk =  str2double(get(handles.nk_value,'String'));
nl =  str2double(get(handles.nl_value,'String'));
nm =  str2double(get(handles.nm_value,'String'));
nParallel_labs =  str2double(get(handles.Parallel_labs,'String'));

FluxBias=linspace(CalcRange,0.5,ceil(CalcNPoints/2));
Npoints=length(FluxBias);
NPperSection = nParallel_labs*3;
ContinuePoint = 1;
OutputDataName=['Data\3JJQbtEL-Ej' num2str(Ej,'%10.2f') 'Ec' num2str(Ec,'%10.3f') 'a' num2str(alpha) 'b' num2str(beta,'%10.3f') 'k' num2str(kappa) 's' num2str(sigma)];
OutputDataName=[OutputDataName 'S' num2str(CalcRange) 'np' num2str(CalcNPoints) '[' num2str(nk), ',', num2str(nl), ',', num2str(nm), ']', '.mat'];

needwait=false;
Convert2microeV=false;  % do not convert energy unit to micro-eV or not buy user choice
if get(handles.UnitChoice,'Value') == get(handles.UnitChoice,'Max')
	Convert2microeV=true;  % convert energy unit to micro-eV or not buy user choice
end
if isempty(dir('Data'))
    mkdir('Data');
elseif ~isempty(dir(OutputDataName))
    load(OutputDataName);
end
if ischar(ContinuePoint)
    set(handles.info_Info_disp,'String',...
        ['Calculation for the present set of paramenters has been done before, energy levels will be ploted directly by loading the saved data file: ',...
        OutputDataName],'Visible','on');
    needwait=true;
else
    if ContinuePoint >1
        set(handles.info_Info_disp,'String','Continue a previous unfinished process for the present set of parameters','Visible','on');
    end
	Nsections = floor(Npoints/NPperSection);
	NPFinal = NPperSection;
	tmp = mod(Npoints,NPperSection);
	if tmp > 0
        Nsections = Nsections +1;
        NPFinal = tmp;
    end
    set(handles.Exit_button,'Visible','on','Enable','on');
    set(handles.info_UsrCnfrm,'Visible','on');
    set(handles.Elapsed_time,'String','Elapsed time: not known yet','Visible','on');
    set(handles.Remaining_time,'String','Remaining time: not known yet','Visible','on');
    LastFinished = (ContinuePoint-1)*NPperSection;
    pause(0.5); % pause needed for panel display refresh to take effect!
    mpool = gcp('nocreate'); 
    if nParallel_labs >1 && (isempty(mpool) || mpool.NumWorkers ~= nParallel_labs)
        delete(gcp('nocreate'));
        parpool(nParallel_labs);
    end
    tic;
    for dd = ContinuePoint:Nsections
        if dd == Nsections
             NPSection = NPFinal;
        else
             NPSection = NPperSection;
        end
        SliceH = (dd-1)*NPperSection+1;
        SliceE = (dd-1)*NPperSection+NPSection;
        BiasSlice = FluxBias(SliceH:SliceE);
        parfor ee=1:NPSection
             EL = TriJFlxQbtEL(Ej,Ec,alpha,beta,kappa,sigma,BiasSlice(ee),nk,nl,nm,nk*nl*nm);
             if ischar(EL)
                 error(EL);
             end 
             el(ee,:) = EL;
        end
        if ContinuePoint == 1
            EnergyLevel = el;
        else
            EnergyLevel = [EnergyLevel; el];
        end
        ContinuePoint = dd + 1;
        save(OutputDataName,'FluxBias','EnergyLevel','ContinuePoint','NPperSection');
        time = toc/60;
        remainingtime = time*(Npoints-SliceE)/(SliceE-LastFinished);
        disp(['Elapsed time: ',num2str(time)]);
        pause(0.8);   % pause needed, otherwise STOP & EXIT... button press on panel will not be effective!
        set(handles.Elapsed_time,'String',['Elapsed time: ',num2str(time,'%10.1f'),' min.'],'Visible','on');
        set(handles.Remaining_time,'String',['Remaining time: ',num2str(remainingtime,'%10.1f'),' min.'],'Visible','on');
        pause(0.8);   % pause needed, otherwise the above two code line will take no effect!
    end
    EnergyLevel=EnergyLevel-EnergyLevel(Npoints,1);    % set the ground level of 0.5*FluxQuantum Flux Bias as the zero energy point.
    dFluxBias = FluxBias(2)-FluxBias(1);
    for kk=Npoints+1:2*Npoints-1
        EnergyLevel(kk,:)=EnergyLevel(2*Npoints-kk,:);
        FluxBias(kk)=FluxBias(kk-1)+dFluxBias;
    end
    ContinuePoint = 'END';
    save(OutputDataName,'FluxBias','EnergyLevel','ContinuePoint','NPperSection');
         % EnergyLevel(jj,kk) is the kkth energy level value of the fluxbias
         % condition Fluxbias = FluxBias(jj)*Flux quantum.
end
Parameters = ['E_J:',num2str(Ej,'%10.2f'),'GHz;  E_C:',num2str(Ec,'%10.3f'),'GHz;  \alpha:',num2str(alpha,'%10.3f'),';  \beta:',num2str(beta,'%10.4f'),';  \sigma:',num2str(sigma),';  \kappa:',num2str(kappa)];
while 1
    if ~Check_datafilename
        set(handles.datafilename,'String','Enter a name!','BackgroundColor',[1 0 0]); 
    elseif ~Check_dir
        set(handles.save_dir,'String','Choose a path to save!','BackgroundColor',[1 0 0]); 
    else
        filename = get(handles.datafilename,'String'); 
        datafilename = [filename,'.dat'];
        path =  get(handles.save_dir,'String'); 
        datfile = fopen([path datafilename],'w');
        fwrite(datfile,Parameters);
        fwrite(datfile,[char(13),char(10)]);
        fwrite(datfile,['FluxBias/Phi_0',char(9),'EnergyLevel1(GHz)',...
            char(9),'EnergyLevel2(GHz)',char(9),'EnergyLevel3(GHz)',char(9),'...']);
        fwrite(datfile,[char(13),char(10)]);
        break;
    end
end
if (get(handles.SaveScreenshot,'Value') == get(handles.SaveScreenshot,'Max'))
    path =  get(handles.save_dir,'String');
    imagefilename = [get(handles.datafilename,'String'),'.png'];
    saveas(get(handles.SaveScreenshot,'Parent'),[path imagefilename]);
end
for kk=1:length(FluxBias)
    fwrite(datfile,[num2str(FluxBias(kk), '%0.6f'),char(9)]);
    for jj =1:PlotNLevels-1
        fwrite(datfile,[num2str(EnergyLevel(kk,jj), '%0.4f'),char(9)]);
    end
    fwrite(datfile,[num2str(EnergyLevel(kk,PlotNLevels), '%0.4f'),char(9)]);
    fwrite(datfile,[char(13),char(10)]);
end
fclose(datfile);
set(handles.Elapsed_time,'Visible','off');
set(handles.Remaining_time,'Visible','off');
set(handles.Exit_button,'Visible','off','Enable','off');
set(handles.info_UsrCnfrm,'Visible','off');
pause(0.5);

EqGroundLevel2Zero = 0;          % No GUI control       
if EqGroundLevel2Zero            % Set the energy value of the ground level to zero
    temp = size(EnergyLevel);
    GroundLevel = (EnergyLevel(:,1) + EnergyLevel(:,2))/2;
    for kk =1:temp(1)
        EnergyLevel(:,kk) = EnergyLevel(:,kk) - GroundLevel;
    end
    EnergyLevel(:,1) = 0;
end

scrsz = get(0,'ScreenSize');
PlotFigHandle1 = figure('Position',[0, 100, scrsz(3)/3, scrsz(4)-200]);
                        %'Position',[x, y, width, height] %pixels
PlotAX1 = axes('parent',PlotFigHandle1);
if (get(handles.DoInterp,'Value') == get(handles.DoInterp,'Max')) && length(FluxBias)>=10 
    % impossible to iterpolate a too short data sequence
    FluxBiasI = interp(FluxBias,4);        % do interpolation to plot more smooth curves
    EnergyLevelI = zeros(length(FluxBiasI),PlotNLevels);
    for kk=1:PlotNLevels
        EnergyLevelI(:,kk) = interp1(FluxBias,EnergyLevel(:,kk),FluxBiasI,'*spline');
        if Convert2microeV  % convert unit  'micro-eV'
            plot(PlotAX1,FluxBiasI,4.1356*EnergyLevelI(:,kk));
        else
            plot(PlotAX1,FluxBiasI,EnergyLevelI(:,kk));
        end
        hold on;
    end
else
    for kk=1:PlotNLevels
        if Convert2microeV  % convert unit  'micro-eV'
            plot(PlotAX1,FluxBias,4.1356*EnergyLevel(:,kk));
        else
            plot(PlotAX1,FluxBias,EnergyLevel(:,kk));
        end
        hold on;
    end
end
xlabel('\Phi_e/\Phi_0','interpreter','tex','fontsize',14);
if Convert2microeV  % convert unit  'micro-eV'
	ylabel('E (\mueV)','interpreter','tex','fontsize',14);
else
	ylabel('E (GHz)','interpreter','tex','fontsize',14);
end
xlim([FluxBias(1),FluxBias(end)]);
if Convert2microeV  % convert unit  'micro-eV'
	ylim([4.1356*min(EnergyLevel(:,1)),4.1356*max(EnergyLevel(:,PlotNLevels))]);
else
	ylim([min(EnergyLevel(:,1)),max(EnergyLevel(:,PlotNLevels))]);
end
title('3JJ Flux Qubit Energy Levels','interpreter','tex','fontsize',14);
text((FluxBias(1)+(0.5-FluxBias(1))*0.2), 0.85*EnergyLevel(1),Parameters,'fontsize',12);
saveas(PlotFigHandle1,[path, filename,'_1.fig']);
if max(FluxBias)<50
    PlotFigHandle2 = figure('Position',[scrsz(3)/3, 100, scrsz(3)/3, scrsz(4)-200]);
                            %'Position',[x, y, width, height] %pixels
    PlotAX2 = axes('parent',PlotFigHandle2);
    if (get(handles.DoInterp,'Value') == get(handles.DoInterp,'Max'))  && length(FluxBias)>=10
        % impossible to iterpolate a too short data sequence
        x = 1000*(FluxBiasI-0.5);
        if Convert2microeV  % convert unit  'micro-eV'
            plot(PlotAX2,...
                x,4.1356*(EnergyLevelI(:,3)-EnergyLevelI(:,1)),'-k',...
                x,4.1356*(EnergyLevelI(:,3)-EnergyLevelI(:,2)),'-k',...
                x,4.1356*(EnergyLevelI(:,4)-EnergyLevelI(:,1)),'-k',...
                x,4.1356*(EnergyLevelI(:,4)-EnergyLevelI(:,2)),'-k',...
                x,4.1356*(EnergyLevelI(:,5)-EnergyLevelI(:,1)),'-b',...
                x,4.1356*(EnergyLevelI(:,5)-EnergyLevelI(:,2)),'-b',...
                x,4.1356*(EnergyLevelI(:,6)-EnergyLevelI(:,1)),'-b',...
                x,4.1356*(EnergyLevelI(:,6)-EnergyLevelI(:,2)),'-b',...
                x,4.1356*(EnergyLevelI(:,7)-EnergyLevelI(:,1)),'-r',...
                x,4.1356*(EnergyLevelI(:,7)-EnergyLevelI(:,2)),'-r',...
                x,4.1356*(EnergyLevelI(:,8)-EnergyLevelI(:,1)),'-r',...
                x,4.1356*(EnergyLevelI(:,8)-EnergyLevelI(:,2)),'-r');
            hold(PlotAX2,'on');
            plot(PlotAX2,...
                x,4.1356*(EnergyLevelI(:,3)-EnergyLevelI(:,1))/2,'--k',...
                x,4.1356*(EnergyLevelI(:,3)-EnergyLevelI(:,2))/2,'--k',...
                x,4.1356*(EnergyLevelI(:,4)-EnergyLevelI(:,1))/2,'--k',...
                x,4.1356*(EnergyLevelI(:,4)-EnergyLevelI(:,2))/2,'--k',...
                x,4.1356*(EnergyLevelI(:,5)-EnergyLevelI(:,1))/2,'--b',...
                x,4.1356*(EnergyLevelI(:,5)-EnergyLevelI(:,2))/2,'--b',...
                x,4.1356*(EnergyLevelI(:,6)-EnergyLevelI(:,1))/2,'--b',...
                x,4.1356*(EnergyLevelI(:,6)-EnergyLevelI(:,2))/2,'--b',...
                x,4.1356*(EnergyLevelI(:,7)-EnergyLevelI(:,1))/2,'--r',...
                x,4.1356*(EnergyLevelI(:,7)-EnergyLevelI(:,2))/2,'--r',...
                x,4.1356*(EnergyLevelI(:,8)-EnergyLevelI(:,1))/2,'--r',...
                x,4.1356*(EnergyLevelI(:,8)-EnergyLevelI(:,2))/2,'--r');
            plot(PlotAX2,...
                x,4.1356*(EnergyLevelI(:,3)-EnergyLevelI(:,1))/3,':k',...
                x,4.1356*(EnergyLevelI(:,3)-EnergyLevelI(:,2))/3,':k',...
                x,4.1356*(EnergyLevelI(:,4)-EnergyLevelI(:,1))/3,':k',...
                x,4.1356*(EnergyLevelI(:,4)-EnergyLevelI(:,2))/3,':k',...
                x,4.1356*(EnergyLevelI(:,5)-EnergyLevelI(:,1))/3,':b',...
                x,4.1356*(EnergyLevelI(:,5)-EnergyLevelI(:,2))/3,':b',...
                x,4.1356*(EnergyLevelI(:,6)-EnergyLevelI(:,1))/3,':b',...
                x,4.1356*(EnergyLevelI(:,6)-EnergyLevelI(:,2))/3,':b',...
                x,4.1356*(EnergyLevelI(:,7)-EnergyLevelI(:,1))/3,':r',...
                x,4.1356*(EnergyLevelI(:,7)-EnergyLevelI(:,2))/3,':r',...
                x,4.1356*(EnergyLevelI(:,8)-EnergyLevelI(:,1))/3,':r',...
                x,4.1356*(EnergyLevelI(:,8)-EnergyLevelI(:,2))/3,':r');
            ylabel('E_{12-34} (\mueV)','interpreter','tex','fontsize',14);
        else
            plot(PlotAX2,...
                x,(EnergyLevelI(:,3)-EnergyLevelI(:,1)),'-k',...
                x,(EnergyLevelI(:,3)-EnergyLevelI(:,2)),'-k',...
                x,(EnergyLevelI(:,4)-EnergyLevelI(:,1)),'-k',...
                x,(EnergyLevelI(:,4)-EnergyLevelI(:,2)),'-k',...
                x,(EnergyLevelI(:,5)-EnergyLevelI(:,1)),'-b',...
                x,(EnergyLevelI(:,5)-EnergyLevelI(:,2)),'-b',...
                x,(EnergyLevelI(:,6)-EnergyLevelI(:,1)),'-b',...
                x,(EnergyLevelI(:,6)-EnergyLevelI(:,2)),'-b',...
                x,(EnergyLevelI(:,7)-EnergyLevelI(:,1)),'-r',...
                x,(EnergyLevelI(:,7)-EnergyLevelI(:,2)),'-r',...
                x,(EnergyLevelI(:,8)-EnergyLevelI(:,1)),'-r',...
                x,(EnergyLevelI(:,8)-EnergyLevelI(:,2)),'-r');
            hold(PlotAX2,'on');
            plot(PlotAX2,...
                x,(EnergyLevelI(:,3)-EnergyLevelI(:,1))/2,'--k',...
                x,(EnergyLevelI(:,3)-EnergyLevelI(:,2))/2,'--k',...
                x,(EnergyLevelI(:,4)-EnergyLevelI(:,1))/2,'--k',...
                x,(EnergyLevelI(:,4)-EnergyLevelI(:,2))/2,'--k',...
                x,(EnergyLevelI(:,5)-EnergyLevelI(:,1))/2,'--b',...
                x,(EnergyLevelI(:,5)-EnergyLevelI(:,2))/2,'--b',...
                x,(EnergyLevelI(:,6)-EnergyLevelI(:,1))/2,'--b',...
                x,(EnergyLevelI(:,6)-EnergyLevelI(:,2))/2,'--b',...
                x,(EnergyLevelI(:,7)-EnergyLevelI(:,1))/2,'--r',...
                x,(EnergyLevelI(:,7)-EnergyLevelI(:,2))/2,'--r',...
                x,(EnergyLevelI(:,8)-EnergyLevelI(:,1))/2,'--r',...
                x,(EnergyLevelI(:,8)-EnergyLevelI(:,2))/2,'--r');
            plot(PlotAX2,...
                x,(EnergyLevelI(:,3)-EnergyLevelI(:,1))/3,':k',...
                x,(EnergyLevelI(:,3)-EnergyLevelI(:,2))/3,':k',...
                x,(EnergyLevelI(:,4)-EnergyLevelI(:,1))/3,':k',...
                x,(EnergyLevelI(:,4)-EnergyLevelI(:,2))/3,':k',...
                x,(EnergyLevelI(:,5)-EnergyLevelI(:,1))/3,':b',...
                x,(EnergyLevelI(:,5)-EnergyLevelI(:,2))/3,':b',...
                x,(EnergyLevelI(:,6)-EnergyLevelI(:,1))/3,':b',...
                x,(EnergyLevelI(:,6)-EnergyLevelI(:,2))/3,':b',...
                x,(EnergyLevelI(:,7)-EnergyLevelI(:,1))/3,':r',...
                x,(EnergyLevelI(:,7)-EnergyLevelI(:,2))/3,':r',...
                x,(EnergyLevelI(:,8)-EnergyLevelI(:,1))/3,':r',...
                x,(EnergyLevelI(:,8)-EnergyLevelI(:,2))/3,':r');
            ylabel('E_{12-34} (GHz)','interpreter','tex','fontsize',14);
        end
    else
        x = 1000*(FluxBias-0.5);
        if Convert2microeV  % convert unit  'micro-eV'
           plot(PlotAX2,...
                x,4.1356*(EnergyLevel(:,3)-EnergyLevel(:,1)),'-k',...
                x,4.1356*(EnergyLevel(:,3)-EnergyLevel(:,2)),'-k',...
                x,4.1356*(EnergyLevel(:,4)-EnergyLevel(:,1)),'-k',...
                x,4.1356*(EnergyLevel(:,4)-EnergyLevel(:,2)),'-k',...
                x,4.1356*(EnergyLevel(:,5)-EnergyLevel(:,1)),'-b',...
                x,4.1356*(EnergyLevel(:,5)-EnergyLevel(:,2)),'-b',...
                x,4.1356*(EnergyLevel(:,6)-EnergyLevel(:,1)),'-b',...
                x,4.1356*(EnergyLevel(:,6)-EnergyLevel(:,2)),'-b',...
                x,4.1356*(EnergyLevel(:,7)-EnergyLevel(:,1)),'-r',...
                x,4.1356*(EnergyLevel(:,7)-EnergyLevel(:,2)),'-r',...
                x,4.1356*(EnergyLevel(:,8)-EnergyLevel(:,1)),'-r',...
                x,4.1356*(EnergyLevel(:,8)-EnergyLevel(:,2)),'-r');
            hold(PlotAX2,'on');
            plot(PlotAX2,...
                x,4.1356*(EnergyLevel(:,3)-EnergyLevel(:,1))/2,'--k',...
                x,4.1356*(EnergyLevel(:,3)-EnergyLevel(:,2))/2,'--k',...
                x,4.1356*(EnergyLevel(:,4)-EnergyLevel(:,1))/2,'--k',...
                x,4.1356*(EnergyLevel(:,4)-EnergyLevel(:,2))/2,'--k',...
                x,4.1356*(EnergyLevel(:,5)-EnergyLevel(:,1))/2,'--b',...
                x,4.1356*(EnergyLevel(:,5)-EnergyLevel(:,2))/2,'--b',...
                x,4.1356*(EnergyLevel(:,6)-EnergyLevel(:,1))/2,'--b',...
                x,4.1356*(EnergyLevel(:,6)-EnergyLevel(:,2))/2,'--b',...
                x,4.1356*(EnergyLevel(:,7)-EnergyLevel(:,1))/2,'--r',...
                x,4.1356*(EnergyLevel(:,7)-EnergyLevel(:,2))/2,'--r',...
                x,4.1356*(EnergyLevel(:,8)-EnergyLevel(:,1))/2,'--r',...
                x,4.1356*(EnergyLevel(:,8)-EnergyLevel(:,2))/2,'--r');
            plot(PlotAX2,...
                x,4.1356*(EnergyLevel(:,3)-EnergyLevel(:,1))/3,':k',...
                x,4.1356*(EnergyLevel(:,3)-EnergyLevel(:,2))/3,':k',...
                x,4.1356*(EnergyLevel(:,4)-EnergyLevel(:,1))/3,':k',...
                x,4.1356*(EnergyLevel(:,4)-EnergyLevel(:,2))/3,':k',...
                x,4.1356*(EnergyLevel(:,5)-EnergyLevel(:,1))/3,':b',...
                x,4.1356*(EnergyLevel(:,5)-EnergyLevel(:,2))/3,':b',...
                x,4.1356*(EnergyLevel(:,6)-EnergyLevel(:,1))/3,':b',...
                x,4.1356*(EnergyLevel(:,6)-EnergyLevel(:,2))/3,':b',...
                x,4.1356*(EnergyLevel(:,7)-EnergyLevel(:,1))/3,':r',...
                x,4.1356*(EnergyLevel(:,7)-EnergyLevel(:,2))/3,':r',...
                x,4.1356*(EnergyLevel(:,8)-EnergyLevel(:,1))/3,':r',...
                x,4.1356*(EnergyLevel(:,8)-EnergyLevel(:,2))/3,':r');
            ylabel('E_{12-34} (\mueV)','interpreter','tex','fontsize',14);
        else
             plot(PlotAX2,...
                x,(EnergyLevel(:,3)-EnergyLevel(:,1)),'-k',...
                x,(EnergyLevel(:,3)-EnergyLevel(:,2)),'-k',...
                x,(EnergyLevel(:,4)-EnergyLevel(:,1)),'-k',...
                x,(EnergyLevel(:,4)-EnergyLevel(:,2)),'-k',...
                x,(EnergyLevel(:,5)-EnergyLevel(:,1)),'-b',...
                x,(EnergyLevel(:,5)-EnergyLevel(:,2)),'-b',...
                x,(EnergyLevel(:,6)-EnergyLevel(:,1)),'-b',...
                x,(EnergyLevel(:,6)-EnergyLevel(:,2)),'-b',...
                x,(EnergyLevel(:,7)-EnergyLevel(:,1)),'-r',...
                x,(EnergyLevel(:,7)-EnergyLevel(:,2)),'-r',...
                x,(EnergyLevel(:,8)-EnergyLevel(:,1)),'-r',...
                x,(EnergyLevel(:,8)-EnergyLevel(:,2)),'-r');
            hold(PlotAX2,'on');
            plot(PlotAX2,...
                x,(EnergyLevel(:,3)-EnergyLevel(:,1))/2,'--k',...
                x,(EnergyLevel(:,3)-EnergyLevel(:,2))/2,'--k',...
                x,(EnergyLevel(:,4)-EnergyLevel(:,1))/2,'--k',...
                x,(EnergyLevel(:,4)-EnergyLevel(:,2))/2,'--k',...
                x,(EnergyLevel(:,5)-EnergyLevel(:,1))/2,'--b',...
                x,(EnergyLevel(:,5)-EnergyLevel(:,2))/2,'--b',...
                x,(EnergyLevel(:,6)-EnergyLevel(:,1))/2,'--b',...
                x,(EnergyLevel(:,6)-EnergyLevel(:,2))/2,'--b',...
                x,(EnergyLevel(:,7)-EnergyLevel(:,1))/2,'--r',...
                x,(EnergyLevel(:,7)-EnergyLevel(:,2))/2,'--r',...
                x,(EnergyLevel(:,8)-EnergyLevel(:,1))/2,'--r',...
                x,(EnergyLevel(:,8)-EnergyLevel(:,2))/2,'--r');
            plot(PlotAX2,...
                x,(EnergyLevel(:,3)-EnergyLevel(:,1))/3,':k',...
                x,(EnergyLevel(:,3)-EnergyLevel(:,2))/3,':k',...
                x,(EnergyLevel(:,4)-EnergyLevel(:,1))/3,':k',...
                x,(EnergyLevel(:,4)-EnergyLevel(:,2))/3,':k',...
                x,(EnergyLevel(:,5)-EnergyLevel(:,1))/3,':b',...
                x,(EnergyLevel(:,5)-EnergyLevel(:,2))/3,':b',...
                x,(EnergyLevel(:,6)-EnergyLevel(:,1))/3,':b',...
                x,(EnergyLevel(:,6)-EnergyLevel(:,2))/3,':b',...
                x,(EnergyLevel(:,7)-EnergyLevel(:,1))/3,':r',...
                x,(EnergyLevel(:,7)-EnergyLevel(:,2))/3,':r',...
                x,(EnergyLevel(:,8)-EnergyLevel(:,1))/3,':r',...
                x,(EnergyLevel(:,8)-EnergyLevel(:,2))/3,':r');
            ylabel('E_{12-34} (GHz)','interpreter','tex','fontsize',14);
        end
    end
    xlabel('(\Phi_e-0.5\Phi_0) (m\Phi_0)','interpreter','tex','fontsize',14);
    xlim([x(1),1000*(FluxBias(end)-0.5)]);
    if Convert2microeV  % convert unit  'micro-eV'
        ylim([0,4.1356*max(EnergyLevel(:,4)-EnergyLevel(:,1))]);
    else
        ylim([0,max(EnergyLevel(:,4)-EnergyLevel(:,1))]);
    end
    saveas(PlotFigHandle2,[path, filename,'_2.fig']);
    PlotFigHandle3 = figure('Position',[scrsz(3)*2/3, 100,scrsz(3)/3, scrsz(4)-200]);
    PlotAX3 = axes('parent',PlotFigHandle3);
    if (get(handles.DoInterp,'Value') == get(handles.DoInterp,'Max')) && length(FluxBias)>=10
        % impossible to iterpolate a too short data sequence
        LevelWidthI = ((EnergyLevelI(:,4)-EnergyLevelI(:,1))-(EnergyLevelI(:,3)-EnergyLevelI(:,2)))*1000;  % MHz
        plot(PlotAX3,x,LevelWidthI);
    else
        LevelWidth = ((EnergyLevel(:,4)-EnergyLevel(:,1))-(EnergyLevel(:,3)-EnergyLevel(:,2)))*1000;  % MHz
        plot(PlotAX3,x,LevelWidth);
    end
    xlabel('(\Phi_e-0.5\Phi_0) (m\Phi_0)','interpreter','tex','fontsize',14);
    ylabel('Level Width (MHz)','interpreter','tex','fontsize',14);
    xlim([x(1),1000*(FluxBias(end)-0.5)]);
    %ylim([0,max(LevelWidth)]);
    saveas(PlotFigHandle3,[path, filename,'_3.fig']);
    
    PlotFigHandle4 = figure('Position',[scrsz(3)*2/3, 100,scrsz(3)/3, scrsz(4)-200]);
    PlotAX4 = axes('parent',PlotFigHandle4);
    if (get(handles.DoInterp,'Value') == get(handles.DoInterp,'Max'))  && length(FluxBias)>=10
        % impossible to iterpolate a too short data sequence
        % E01 = (EnergyLevelI(:,3)+EnergyLevelI(:,4))/2 - (EnergyLevelI(:,1)+EnergyLevelI(:,2))/2;
        E01 = (EnergyLevelI(:,1)+EnergyLevelI(:,2))/2;
        Ip = 160*gradient(E01,1000*(FluxBiasI - 0.5));     % unit: nA
    else
        E01 = (EnergyLevel(:,3)+EnergyLevel(:,4))/2 - (EnergyLevel(:,1)+EnergyLevel(:,2))/2;
        Ip = 160*gradient(E01,1000*(FluxBias - 0.5));     % unit: nA
    end
    plot(PlotAX4,x,Ip);
    xlabel('\Phi_e-0.5\Phi_0 (m\Phi_0)','interpreter','tex','fontsize',14);
    ylabel('Ip (nA)','interpreter','tex','fontsize',14);
    xlim([x(1),1000*(FluxBias(end)-0.5)]);
    %ylim([0,max(LevelWidth)]);
    saveas(PlotFigHandle4,[path, filename,'_4.fig']);
end
if needwait
    pause(8);
end
set(handles.info_Info_disp,'String',['Done.',char(13),char(10),'Time:',...
    datestr(now),char(13),char(10),'To show the figures just calculated, just click [Start]'],'Visible','on');
set(handles.StartCalc,'String','Start', 'ForegroundColor',[0 0.749 0.749],'Enable','on');
set(handles.matrix_dim_check,'String','Matrix dimension check: ?',...
    'ForegroundColor',[0.502 0.502 0.502]);


function EL = TriJFlxQbtEL(Ej,Ec,alpha,beta,kappa,sigma,FluxBias,nk,nl,nm,nlevels)
% 'TriJFlxQbtEL' calculates the energy levels of a three-junction flux qubit. 
% Ref.: Robertson et al., Phys. Rev. Letts. B 73, 174526 (2006). 
% Energy Level values = TriJFlxQbtEL(Ej,Ec,alpha,beta,kappa,sigma,FluxBias,nk,nl,nm,nlevels)
% Example:
% EL = TriJFlxQbtEL(50,1,0.63,0.15,0,0,0.5,5,10,2,20)
% Energy unit: The same as Ej and Ec.
% FluxBias unit:FluxQuantum
% nlevels: return the energy values of the lowest n energy levels.
% Author: Yulin Wu <mail4ywu@gmail.com>
% Date: 2009/5/6
% Revision:
% 2011/4/30
if beta == 0
    beta = 1e-6;    % beta can not be zero ! however small, it always not zero in real flux qubit.
end
hbar=1.054560652926899e-034;
PhiQ=2*pi*FluxBias; 
M=zeros(3,3);       % M here is invert M in Phys. Rev. B 73, 174526 (2006), Eq.16.
tmp=1+2*alpha;
M(1,1)=1+sigma;
M(1,2)=kappa/tmp;
M(1,3)=2*alpha*kappa/tmp;
M(2,1)=M(1,2);
M(2,2)=((sigma+alpha)*(1+sigma)+2*alpha^2*(1-kappa^2+2*sigma+sigma^2))/(tmp^2*(alpha+sigma));
M(2,3)=2*alpha*(sigma+sigma^2+alpha*(kappa^2-sigma-sigma^2))/(tmp^2*(alpha+sigma));
M(3,1)=M(1,3);
M(3,2)=M(2,3);
M(3,3)=2*alpha^2*(2*alpha*(1+sigma)+1+4*sigma+3*sigma^2-kappa^2)/(tmp^2*(alpha+sigma));
M=4*Ec/(hbar^2*((1+sigma)^2-kappa^2))*M;
tmp1=2*Ej*alpha*(1-kappa^2)*((1+sigma)*(1+2*alpha+3*sigma)-kappa^2);
tmp2=Ec*beta*(1+2*alpha-kappa^2)*(alpha+sigma)*((1+sigma)^2-kappa^2);
omega_t=2*Ec/hbar*sqrt(tmp1/tmp2);
tmp1=hbar^2*(alpha+sigma)*((1+sigma^2)-kappa^2)*(1+2*alpha)^2;
tmp2=8*Ec*alpha^2*((1+sigma)*(1+2*alpha+3*sigma)-kappa^2);
m_t=tmp1/tmp2;
U{1,1}=[0 0];		U{1,2}=[(1-kappa)/2 1i];			U{1,3}=[0 0];		U{1,4}=[(1+kappa)/2 -1i];		U{1,5}=[0 0];
                        U{2,2}=[0 0];                    U{2,3}=[0 0];        U{2,4}=[0 0];
U{3,1}=[0 0];		U{3,2}=[(1+kappa)/2 1i];          U{3,3}=[0 0];		U{3,4}=[(1-kappa)/2 -1i];     U{3,5}=[0 0];
U{2,1}=[alpha*exp(1i*PhiQ)/2 -1i/alpha];			U{2,5}=[alpha*exp(-1i*PhiQ)/2 1i/alpha];
	 H=zeros((2*nk+1)*(2*nl+1)*(nm+1));
     for k1=-nk:nk
		 kk1=k1+nk+1;
		 for l1=-nl:nl
			 ll1=l1+nl+1;
			 for m1=0:nm
				 mm1=m1+1;
				 for k2=-nk:nk
					 kk2=k2+nk+1;
					 for l2=-nl:nl
						 ll2=l2+nl+1;
						 for m2=0:nm
							 mm2=m2+1;
							 n1=(kk1-1)*(2*nl+1)*(nm+1)+(ll1-1)*(nm+1)+mm1;
							 n2=(kk2-1)*(2*nl+1)*(nm+1)+(ll2-1)*(nm+1)+mm2;
							 if n2<n1
								 H(n1,n2)=conj(H(n2,n1));
							 else
							 H1=hbar^2*(k1^2*M(1,1)/2+k1*l1*M(1,2)+l1^2*M(2,2)/2)*...
                                 Kdelta(k1,k2)*Kdelta(l1,l2)*Kdelta(m1,m2);
							 H2=-1i*sqrt((m_t*omega_t*hbar^3)/2)*(M(1,3)*k1+M(2,3)*l1)*...
                                 Kdelta(k1,k2)*Kdelta(l1,l2)*(sqrt(m2+1)*Kdelta(m2+1,m1)-sqrt(m2)*Kdelta(m2-1,m1));
							 tmp1=0;
							 for p=-1:1
							         row=p+2;
							 		for q=-2:2
							             cln=q+3;
							 			if k1==p+k2 && l1==q+l2 && U{row,cln}(1)~=0 
							 				cc=U{row,cln}(2);
							 				tmp=0;
							 				tmp2=sqrt(hbar/(2*m_t*omega_t))*cc;
							 				for jj=0:min(m1,m2)
							 					tmp=tmp+factorial(jj)*nchoosek(m1,jj)*nchoosek(m2,jj)*(tmp2)^(m1+m2-2*jj);
							 				end
							 				tmp=tmp*(factorial(m1)*factorial(m2))^(-0.5)*exp(tmp2^2/2);
							   				tmp1=tmp1+U{row,cln}(1)*tmp;
							 			end
							 		end
							 end
							 H3=-Ej*tmp1;
							 H4=(m1+0.5)*hbar*omega_t*Kdelta(k1,k2)*Kdelta(l1,l2)*Kdelta(m1,m2);
							 H(n1,n2)=H1+H2+H3+H4;
							 end
						 end
				 	 end
				 end
			 end
		 end
     end
	 EL=eig(H);
EL(nlevels+1:end)=[];


function f=Kdelta(x1,x2)
if x1==x2
    f=1;
else f=0;
end
