function varargout = image2data(varargin)
% IMAGE2DATA M-file for image2data.fig
%      IMAGE2DATA, by itself, creates a new IMAGE2DATA or raises the existing
%      singleton*.
%
%      H = IMAGE2DATA returns the handle to a new IMAGE2DATA or the handle to
%      the existing singleton*.
%
%      IMAGE2DATA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMAGE2DATA.M with the given input arguments.
%
%      IMAGE2DATA('Property','Value',...) creates a new IMAGE2DATA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before image2data_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to image2data_OpeningFcn via varargin.
% 
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help image2data

% Last Modified by GUIDE v2.5 19-Mar-2014 06:30:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @image2data_OpeningFcn, ...
                   'gui_OutputFcn',  @image2data_OutputFcn, ...
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


% --- Executes just before image2data is made visible.
function image2data_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to image2data (see VARARGIN)

% Choose default command line output for image2data
handles.output = hObject;

% pannel 0
handles.msg_on=0; 
handles.cpx=0;
handles.cpy=0;% gloable variables for current position of mouse

% pannel 1
handles.idata = zeros(2,2);% the key variable for obtaining curve data
handles.iimage = 0;% image data matrix
handles.ximage = 0;
handles.yimage = 0;

% pannel 3
handles.pick_axis_on=0; 
handles.pick_curve_on=0; 
handles.pick_view_num =1;

% pannel 4
handles.point_connect_on = 0;
handles.point_delete_on = 0;

% pannel left_top
handles.zoom_on=0;% status variables recording the data picking operations
handles.pan_on=0;

himage=findobj('tag','axes1');
axes(himage);

% Update handles structure
guidata(hObject, handles);
clc

% UIWAIT makes image2data wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = image2data_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



%--------------------------------------------------------------------------
%*************************  Step 1111 ***********************************                        
%--------------------------------------------------------------------------
% --- Executes on button press in pb_import.
function pb_import_Callback(hObject, eventdata, handles)
% hObject    handle to pb_import (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%****************************************
% reset all data to default value
clear handles.idata
clear handles.iiamge
% pannel 0
handles.msg_on=0; 
set(handles.box_msg,'Value',0);

handles.cpx=0;
handles.cpy=0;% gloable variables for current position of mouse
set(findobj('tag','edit5'),'String',num2str(0));
set(findobj('tag','edit6'),'String',num2str(0));
set(findobj('tag','edit7'),'String',num2str(0));

% pannel 1
handles.idata = zeros(2,2);% the key variable for obtaining curve data
handles.iimage = 0;% image data matrix
handles.ximage = 0;
handles.yimage = 0;

% pannel 3
handles.pick_axis_on=0; 
handles.pick_curve_on=0; 
handles.pick_view_num =1;
set(handles.pb_axis,'Enable','Off')
set(handles.pb_curve,'Enable','Off')
set(findobj('tag','listbox1'),'value',1)
set(findobj('tag','listbox1'),'string','(0.000,0.000)')

% pannel 4
handles.point_connect_on = 0;
handles.point_delete_on = 0;
set(handles.pb_connect,'Enable','Off')
set(handles.pb_delete,'Enable','Off')
set(handles.pb_save,'Enable','Off')

% pannel left_top
handles.zoom_on=0;% status variables recording the data picking operations
handles.pan_on=0;
zoom off
pan off
zoom out
set(handles.pb_panOn,'Enable','On');
set(handles.pb_zoomOn,'Enable','On');
set(handles.pb_pan_zoomOff,'Enable','Off');
set(handles.pb_zoomOut,'Enable','On');

% pan left_middle
    % reset current axes
cla reset   
set(handles.axes1,'Visible','off'); 
    % hide info
set(findobj('tag','versionInfo'),'Visible','off');
set(findobj('tag','versionInfo1'),'Visible','off');
set(findobj('tag','versionInfo2'),'Visible','off');

% Update handles structure
guidata(hObject, handles);

%***************************************

% import and show the graph
[filename,pathname]=uigetfile({'*.jpg','graph files(*.jpg)';'*.*','All files'},'Choose a graph...'); 
if isequal(filename, 0) 
    disp('user cancelled choosing a graph');
else
    disp('import graph successfully');
    cd(pathname); 
    image_temp=imread(filename);
    axes(handles.axes1);
    set(handles.axes1,'Visible','off');
    imshow(image_temp);                 %read and show 
    handles.ximage=size(image_temp,2);
    handles.yimage=size(image_temp,1);
    handles.iimage=image_temp;
    guidata(hObject,handles);
end 

% allow picking axis points
set(handles.pb_axis,'Enable','On')

% output operration message
if (handles.msg_on == 0)
    set(handles.msgboxtext,'ForegroundColor',[0 0 1]);
    set(handles.msgboxtext,'string','Import the image sucessfully => set axis values or pick axis points.')
end

% --- Executes on button press in pb_clear.
function pb_clear_Callback(hObject, eventdata, handles)
% hObject    handle to pb_clear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% clear and reset some variables
%****************************************
% reset all data to default value
clear handles.idata
clear handles.iiamge
% pannel 0
handles.msg_on=0; 
set(handles.box_msg,'Value',0);

handles.cpx=0;
handles.cpy=0;% gloable variables for current position of mouse
set(findobj('tag','edit5'),'String',num2str(0));
set(findobj('tag','edit6'),'String',num2str(0));
set(findobj('tag','edit7'),'String',num2str(0));

% pannel 1
handles.idata = zeros(2,2);% the key variable for obtaining curve data
handles.iimage = 0;% image data matrix
handles.ximage = 0;
handles.yimage = 0;

% pannel 3
handles.pick_axis_on=0; 
handles.pick_curve_on=0; 
handles.pick_view_num =1;
set(handles.pb_axis,'Enable','Off')
set(handles.pb_curve,'Enable','Off')
set(findobj('tag','listbox1'),'value',1)
set(findobj('tag','listbox1'),'string','(0.000,0.000)')

% pannel 4
handles.point_connect_on = 0;
handles.point_delete_on = 0;
set(handles.pb_connect,'Enable','Off')
set(handles.pb_delete,'Enable','Off')
set(handles.pb_save,'Enable','Off')

% pannel left_top
handles.zoom_on=0;% status variables recording the data picking operations
handles.pan_on=0;
zoom off
pan off
zoom out
set(handles.pb_panOn,'Enable','On');
set(handles.pb_zoomOn,'Enable','On');
set(handles.pb_pan_zoomOff,'Enable','Off');
set(handles.pb_zoomOut,'Enable','On');

% pan left_middle
    % reset current axes
cla reset   
set(handles.axes1,'Visible','off'); 
    % hide info
set(findobj('tag','versionInfo'),'Visible','off');
set(findobj('tag','versionInfo1'),'Visible','off');
set(findobj('tag','versionInfo2'),'Visible','off');

% Update handles structure
guidata(hObject, handles);

%***************************************

% show info
set(findobj('tag','versionInfo'),'Visible','on');
set(findobj('tag','versionInfo1'),'Visible','on');
set(findobj('tag','versionInfo2'),'Visible','on');
set(findobj('tag','versionInfo'),'ForegroundColor',[0.501961 0.601961 0.501961]);
set(findobj('tag','versionInfo1'),'ForegroundColor',[0.501961 0.601961 0.501961]);
set(findobj('tag','versionInfo2'),'ForegroundColor',[0.501961 0.601961 0.501961]);

% update guidata structure
guidata(hObject,handles);

% output operating message
if (handles.msg_on == 0)
    set(handles.msgboxtext,'ForegroundColor',[0 0 1]);
    set(handles.msgboxtext,'string','Clear the image sucessfully => renew the image.')
end

% --- Executes on button press in pb_quit.
function pb_quit_Callback(hObject, eventdata, handles)
% hObject    handle to pb_quit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.msgboxtext,'ForegroundColor',[0 0 1]);
set(handles.msgboxtext,'string','Have a nice day! Bye bye! ^-^')
clear all
pause(0.5)
close all

%--------------------------------------------------------------------------
%*************************  Step 2222  **********************************                        
%--------------------------------------------------------------------------

function edit_b1_Callback(hObject, eventdata, handles)
% hObject    handle to edit_b1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_b1 as text
%        str2double(get(hObject,'String')) returns contents of edit_b1 as a double

% --- Executes during object creation, after setting all properties.
function edit_b1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_b1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_b2_Callback(hObject, eventdata, handles)
% hObject    handle to edit_b2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_b2 as text
%        str2double(get(hObject,'String')) returns contents of edit_b2 as a double


% --- Executes during object creation, after setting all properties.
function edit_b2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_b2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_b3_Callback(hObject, eventdata, handles)
% hObject    handle to edit_b3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_b3 as text
%        str2double(get(hObject,'String')) returns contents of edit_b3 as a double


% --- Executes during object creation, after setting all properties.
function edit_b3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_b3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_b4_Callback(hObject, eventdata, handles)
% hObject    handle to edit_b4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_b4 as text
%        str2double(get(hObject,'String')) returns contents of edit_b4 as a double


% --- Executes during object creation, after setting all properties.
function edit_b4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_b4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




%--------------------------------------------------------------------------
%*************************  Step 3333  ***********************************                        
%--------------------------------------------------------------------------
% --- Executes on button press in pb_zoomOn.
function pb_zoomOn_Callback(hObject, eventdata, handles)
% hObject    handle to pb_zoomOn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zoom on
pan off
set(findobj('tag','pb_zoomOn'),'Enable','Off');
set(findobj('tag','pb_panOn'),'Enable','On');
set(findobj('tag','pb_pan_zoomOff'),'Enable','On');
uicontrol(findobj('tag','text_c'));

if (handles.msg_on == 0)
    set(handles.msgboxtext,'ForegroundColor',[0 0 1]);
    set(handles.msgboxtext,'string','Zoom on. Remmenber to close it when picking up points. ')
end

% --- Executes on button press in pb_zoomOut.
function pb_zoomOut_Callback(hObject, eventdata, handles)
% hObject    handle to pb_zoomOut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zoom out
uicontrol(findobj('tag','text_c'));

if (handles.msg_on == 0)
    set(handles.msgboxtext,'ForegroundColor',[0 0 1]);
    set(handles.msgboxtext,'string','Zoom out. Recovery the image to the oringinal size. ')
end

% --- Executes on button press in pb_panOn.
function pb_panOn_Callback(hObject, eventdata, handles)
% hObject    handle to pb_panOn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zoom off
pan on
set(findobj('tag','pb_zoomOn'),'Enable','On');
set(findobj('tag','pb_panOn'),'Enable','Off');
set(findobj('tag','pb_pan_zoomOff'),'Enable','On');
uicontrol(findobj('tag','text_c'));

if (handles.msg_on == 0)
    set(handles.msgboxtext,'ForegroundColor',[0 0 1]);
    set(handles.msgboxtext,'string','Pan on. Remmenber to close it when picking up points. ')
end

% --- Executes on button press in pb_pan_zoomOff.
function pb_pan_zoomOff_Callback(hObject, eventdata, handles)
% hObject    handle to pb_pan_zoomOff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pan off
zoom off
set(findobj('tag','pb_panOn'),'Enable','On');
set(findobj('tag','pb_zoomOn'),'Enable','On');
set(findobj('tag','pb_pan_zoomOff'),'Enable','Off');
uicontrol(findobj('tag','text_c'));

if (handles.msg_on == 0)
    set(handles.msgboxtext,'ForegroundColor',[0 0 1]);
    set(handles.msgboxtext,'string','Zoom off and Pan off. Now pick up point with Ctrl + Mouse. ')
end

% --- Executes on button press in pb_axis.
function pb_axis_Callback(hObject, eventdata, handles)
% hObject    handle to pb_axis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% pannel 3
handles.pick_axis_on=1; 
handles.pick_curve_on=0; 
set(handles.pb_axis,'Enable','Off')
set(handles.pb_curve,'Enable','Off')

% pannel 4
handles.point_connect_on = 0;
handles.point_delete_on = 0;
set(handles.pb_connect,'Enable','Off')
set(handles.pb_delete,'Enable','Off')
set(handles.pb_save,'Enable','Off')

% pannel left_top
handles.zoom_on=0;% status variables recording the data picking operations
handles.pan_on=0;
zoom off
pan off
zoom out
set(handles.pb_panOn,'Enable','On');
set(handles.pb_zoomOn,'Enable','On');
set(handles.pb_pan_zoomOff,'Enable','Off');
set(handles.pb_zoomOut,'Enable','On');

% renew the image
hold off
imshow(handles.iimage);         % show image       
hold on

% two cases:1 first pick 2 renew
if (size(handles.idata,1) > 6)
    handles.idata(3:6,:) = handles.idata(3:6,:)-handles.idata(3:6,:);
    plot(handles.idata(7:end,1),handles.idata(7:end,2),'b*') % show curve
end

% update guidata structure
guidata(hObject,handles);

if (handles.msg_on == 0)
    set(handles.msgboxtext,'ForegroundColor',[0 0 1]);
    set(handles.msgboxtext,'string','Start picking axis point => first Xmin. ')
end



% --- Executes on button press in pb_curve.
function pb_curve_Callback(hObject, eventdata, handles)
% hObject    handle to pb_curve (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% pannel 3
handles.pick_axis_on=0; 
handles.pick_curve_on=1; 
set(handles.pb_axis,'Enable','On')
set(handles.pb_curve,'Enable','Off')

% pannel 4
handles.point_connect_on = 0;
handles.point_delete_on = 0;
set(handles.pb_connect,'Enable','On')
set(handles.pb_delete,'Enable','On')
set(handles.pb_save,'Enable','On')

% pannel left_top
handles.zoom_on=0;% status variables recording the data picking operations
handles.pan_on=0;
zoom off
pan off
zoom out
set(handles.pb_panOn,'Enable','On');
set(handles.pb_zoomOn,'Enable','On');
set(handles.pb_pan_zoomOff,'Enable','Off');
set(handles.pb_zoomOut,'Enable','On');

% renew the image
hold off
imshow(handles.iimage);         % show image       
hold on

plot(handles.idata(3:6,1),handles.idata(3:6,2),'g*') % show coordinate
if (size(handles.idata,1) > 6 )
    plot(handles.idata(7:end,1),handles.idata(7:end,2),'b*') % show coordinate
end

% update guidata structure
guidata(hObject,handles);

if (handles.msg_on == 0)
    set(handles.msgboxtext,'ForegroundColor',[0 0 1]);
    set(handles.msgboxtext,'string','Prepare picking curve points.=> "Ctrl + Mouse" ')
end

%--------------------------------------------------------------------------
%*************************  Step 4444  ***********************************                        
%--------------------------------------------------------------------------
% --- Executes on button press in pb_connect.
function pb_connect_Callback(hObject, eventdata, handles)
% hObject    handle to pb_connect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% pannel 3
handles.pick_axis_on=0; 
handles.pick_curve_on=0; 
set(handles.pb_axis,'Enable','On')
set(handles.pb_curve,'Enable','On')

% pannel 4
handles.point_connect_on = 1;
handles.point_delete_on = 0;
set(handles.pb_connect,'Enable','On')
set(handles.pb_delete,'Enable','On')
set(handles.pb_save,'Enable','On')

% pannel left_top
handles.zoom_on=0;% status variables recording the data picking operations
handles.pan_on=0;
zoom off
pan off
zoom out
set(handles.pb_panOn,'Enable','On');
set(handles.pb_zoomOn,'Enable','On');
set(handles.pb_pan_zoomOff,'Enable','Off');
set(handles.pb_zoomOut,'Enable','On');

if ( size(handles.idata,1) > 7)
    idata_temp=handles.idata(7:end,:);
    
    hold off
    imshow(handles.iimage);         % show image       
    hold on
    plot(handles.idata(3:6,1),handles.idata(3:6,2),'g*') % show coordinate
    handles.idata(7:end,:)=sortrows(idata_temp,1);
    hline = line(handles.idata(7:end,1),handles.idata(7:end,2),'Color','r','Linewidth',4);

    uicontrol(findobj('tag','text_d'));
    set(handles.pb_curve,'Enable','on')
    
    if (handles.msg_on == 0)
        set(handles.msgboxtext,'ForegroundColor',[0 0 1]);
        set(handles.msgboxtext,'string','The view is updated, go on picking data or save directly?')
    end
else
%     msgbox('Please pick up at least two points on the curve','Picking error')
    set(handles.msgboxtext,'ForegroundColor',[1 0 0]);
    set(handles.msgboxtext,'string','Please pick up at least two points on the curve. ^-^ ')
end

% update guidata structure
guidata(hObject,handles);

% --- Executes on button press in pb_save.
function pb_save_Callback(hObject, eventdata, handles)
% hObject    handle to pb_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
temp=str2num(get(findobj('tag','edit_b1'),'string'));
xmin=temp;
temp=str2num(get(findobj('tag','edit_b2'),'string'));
xmax=temp;
temp=str2num(get(findobj('tag','edit_b3'),'string'));
ymin=temp;
temp=str2num(get(findobj('tag','edit_b4'),'string'));
ymax=temp;
 

if (size(handles.idata,1) < 3 )
    %msgbox('Please pick up points before saving data','Save error') 
    set(handles.msgboxtext,'ForegroundColor',[1 0 0]);
    set(handles.msgboxtext,'string','Please pick up points before saving data,^-^');
else
    idata=handles.idata;
    
    % get axis and curve points
    axis_p=[idata(3:6,1),-idata(3:6,2)];    
    data_p=[idata(7:end,1),-idata(7:end,2)];
    % Be careful the coordinate of image is different to normal x-y
    % coordinante.
    xpmin=axis_p(1,1);
    xpmax=axis_p(2,1);
    ypmin=axis_p(3,2);
    ypmax=axis_p(4,2);
    
    % coordinate transform
    data_new(:,1)=data_p(:,1)-xpmin;
    data_new(:,2)=data_p(:,2)-ypmin;  

    data_new(:,1)=data_new(:,1)/(xpmax-xpmin);
    data_new(:,2)=data_new(:,2)/(ypmax-ypmin);

    data_new(:,1)=xmin+data_new(:,1)*(xmax-xmin);
    data_new(:,2)=ymin+data_new(:,2)*(ymax-ymin);

    idata(7:end,:)=data_new;
    handles.newidata=idata;

    % save data
    [filename,pathname]=uiputfile({'*.txt','text file(*.txt)';'*.*','All files'},'Save data...'); 
    if isequal(filename, 0)
        disp('user cancelled.')
    else
        disp('Save data successfully');
        idata=handles.newidata(7:end,:);
        save([pathname filename],'idata','-ascii'); 
    end
   
    guidata(hObject,handles);
    uicontrol(findobj('tag','text_d'));
    if (handles.msg_on == 0)
        set(handles.msgboxtext,'ForegroundColor',[0 0 1]);
        set(handles.msgboxtext,'string','Save the data sucessfully. What do you want to do next?')
    end
end


%--------------------------------------------------------------------------
%*************************  addition functions ****************************                
%--------------------------------------------------------------------------
% --- Executes on mouse motion over figure - except title and menu.
function figure1_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (handles.iimage == 0)
    h=findobj('tag','edit5');
    set(h,'String',num2str(0));
    h=findobj('tag','edit6');
    set(h,'String',num2str(0));
else 
    p=get(gca,'CurrentPoint');
    px = p(end,1); py = p(end,2);
    x0 = xlim; y0 = ylim;
    if ((px > x0(1)) && (px < x0(2)) && (py > y0(1))  && (py < y0(2)))
        h=findobj('tag','edit5');
        set(h,'String',num2str(px));
        h=findobj('tag','edit6');
        set(h,'String',num2str(py));
    end
end



% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA) 4
p = get(gca,'CurrentPoint');
num_axis = handles.pick_axis_on;
num_curve = handles.pick_curve_on;

px = p(end,1); py = p(end,2);
x0 = xlim; y0 = ylim;

if ((px > x0(1)) && (px < x0(2)) && (py > y0(1))  && (py < y0(2)))
    pick_on = 1;
else 
    pick_on = 0;
end

if ((num_axis > 0 ) && (num_curve == 0) && (pick_on ==1))
    % pick up axis points
    switch get(gcf,'CurrentKey')
        case('control')
                handles.cpx=p(end,1);
                handles.cpy=p(end,2);   
                handles.idata(num_axis+2,:)=[handles.cpx,handles.cpy];
                hold on
                plot(handles.cpx,handles.cpy,'r*');
                switch num_axis
                    case(1)
                        if (handles.msg_on == 0)
                            set(handles.msgboxtext,'ForegroundColor',[0 0 1]);
                            set(handles.msgboxtext,'string','Pick up Xmin sucessfully. Next to Xmax.')
                        end
                    case(2)
                        if (handles.msg_on == 0)
                            set(handles.msgboxtext,'ForegroundColor',[0 0 1]);
                            set(handles.msgboxtext,'string','Pick up Xmax sucessfully. Next to Ymin.')
                        end
                    case(3)
                        if (handles.msg_on == 0)
                            set(handles.msgboxtext,'ForegroundColor',[0 0 1]);
                            set(handles.msgboxtext,'string','Pick up Ymin sucessfully. Next to Ymax.')
                        end
                    case(4)
                        if (handles.msg_on == 0)
                            set(handles.msgboxtext,'ForegroundColor',[0 0 1]);
                            set(handles.msgboxtext,'string','Pick up Ymax sucessfully. Next to pick curve.')
                        end
                end
                num_axis = num_axis +1;
    end
    if (num_axis >4)
        num_axis = 0;
        set(handles.pb_axis,'Enable','On')
        set(handles.pb_curve,'Enable','On')
        set(handles.pb_delete,'Enable','On')
    end
elseif ((num_curve >0) && (num_axis == 0) && (pick_on ==1))
    % pick up curve points
        switch get(gcf,'CurrentKey')
        case('control')
                handles.cpx=p(end,1);
                handles.cpy=p(end,2);   
                handles.idata(end+1,:)=[handles.cpx,handles.cpy];
                hold on
                plot(handles.cpx,handles.cpy,'b*');    
                s1 = num2str(handles.cpx);
                s2 = num2str(handles.cpy);
                str_temp=strcat('(',s1,' , ',s2,')');
                if (handles.msg_on == 0)
                    set(handles.msgboxtext,'ForegroundColor',[0 0 1]);
                    set(handles.msgboxtext,'string',strcat('Pick up point', str_temp,'sucessfully.'))
                end
        end
end

if  (pick_on ==1)
    switch get(gcf,'CurrentKey')
            case('control')
                handles.pick_axis_on = num_axis ;
                guidata(hObject, handles);

                %renew status
                h=findobj('tag','edit7');
                set(h,'String',num2str(size(handles.idata,1)-2));
                if (size(handles.idata,1) > 2)
                    s1 = num2str(handles.idata(3:end,1));
                    s2 = num2str(handles.idata(3:end,2));
                    str_temp=strcat('(',s1(:,1:5),' , ',s2(:,1:5),')');
                    set(findobj('tag','listbox1'),'String',str_temp)
                end
    end
else 
    switch get(gcf,'CurrentKey')
    case('control')
        if (handles.msg_on == 0)
           set(handles.msgboxtext,'ForegroundColor',[1 0 0]);
           set(handles.msgboxtext,'string','Sorry, pick points outside. Repeat.')
        end
    end
    
end


%--------------------------------------------------------------------------
%*************************  not useful ***********************************                        
%--------------------------------------------------------------------------
function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double

% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double

% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function pb_pan_zoomOff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pb_pan_zoomOff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
pan off
zoom off
set(findobj('tag','pb_panOn'),'Enable','On');
set(findobj('tag','pb_zoomOn'),'Enable','On');
set(findobj('tag','pb_pan_zoomOff'),'Enable','Off');


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

guidata(hObject, handles);




% --- Executes on button press in pb_delete.
function pb_delete_Callback(hObject, eventdata, handles)
% hObject    handle to pb_delete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% pannel 3
handles.pick_axis_on=0; 
handles.pick_curve_on=0; 
set(handles.pb_axis,'Enable','On')
set(handles.pb_curve,'Enable','On')

% pannel 4
handles.point_connect_on = 0;
handles.point_delete_on = 1;
set(handles.pb_connect,'Enable','On')
set(handles.pb_delete,'Enable','Off')
set(handles.pb_save,'Enable','On')

% pannel left_top
handles.zoom_on=0;% status variables recording the data picking operations
handles.pan_on=0;
zoom off
pan off
zoom out
set(handles.pb_panOn,'Enable','On');
set(handles.pb_zoomOn,'Enable','On');
set(handles.pb_pan_zoomOff,'Enable','Off');
set(handles.pb_zoomOut,'Enable','On');

% update guidata structure
guidata(hObject,handles);

if (handles.msg_on == 0)
    set(handles.msgboxtext,'ForegroundColor',[0 0 1]);
    set(handles.msgboxtext,'string','Prepare delecting curve points.=> "Ctrl + Mouse" ')
end



% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1

handles.pick_view_num = get(hObject,'Value');

% renew the image
    hold off
    imshow(handles.iimage);         % show image       
    hold on
    plot(handles.idata(3:6,1),handles.idata(3:6,2),'g*') % show coordinate
    if (size(handles.idata,1) > 7 )
        plot(handles.idata(7:end,1),handles.idata(7:end,2),'b*') % show coordinate
    end
    plot(handles.idata(handles.pick_view_num+2,1),...
        handles.idata(handles.pick_view_num+2,2),'rs',...
        'LineWidth',2, 'MarkerEdgeColor','k',...
        'MarkerFaceColor','g', 'MarkerSize',10)

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function pb_curve_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pb_curve (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Enable','off')

% --- Executes on key press with focus on listbox1 and none of its controls.
function listbox1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
temp_list=get(findobj('tag','listbox1'),'value');
if ((handles.point_delete_on == 1) && (temp_list > 4))
    switch eventdata.Key
           case('delete')
            temp=handles.idata;
            clear handles.idata;
            if ((size(temp,1)>6) &&((temp_list+2) < size(temp,1)))
                % in the middle
                handles.idata=[temp(1:temp_list+1,:);temp(temp_list+3:end,:)];
            elseif ((temp_list+2) == size(temp,1))
                % in the end
                handles.idata=temp(1:end-1,:); 
            else
                % in region of axis
                handles.idata=temp;
            end
            
            if  (size(temp,1)>6)
                % update
                h=findobj('tag','edit7');
                set(h,'String',num2str(size(handles.idata,1)-2));
                
                s1 = num2str(handles.idata(3:end,1));
                s2 = num2str(handles.idata(3:end,2));
                str_temp=strcat('(',s1(:,1:5),' , ',s2(:,1:5),')');
                
                if ((temp_list == 5) && (size(temp,1) == 7))
                    % the first point
                    set(findobj('tag','listbox1'),'value',4);
                elseif ((temp_list == 5) && (size(temp,1) > 7)) 
                    set(findobj('tag','listbox1'),'value',5);
                elseif (temp_list > 5) 
                    set(findobj('tag','listbox1'),'value',temp_list-1);
                end
                set(findobj('tag','listbox1'),'String',str_temp);
                
                s1 = num2str(temp(temp_list+2,1));
                s2 = num2str(temp(temp_list+2,2));
                str_temp=strcat('(',s1,' , ',s2,')');
                if (handles.msg_on == 0)
                    set(handles.msgboxtext,'ForegroundColor',[0 0 1]);
                    set(handles.msgboxtext,'string',strcat('Delete one point', str_temp,'sucessfully.'))
                end

            else
                if (handles.msg_on == 0)
                    set(handles.msgboxtext,'ForegroundColor',[0 0 1]);
                    set(handles.msgboxtext,'string','You can not delete the axis points.')
                 end
              
            end
    end
    % update handles
    guidata(hObject, handles);
    
    handles.pick_view_num = get(hObject,'Value');
% renew the image
    hold off
    imshow(handles.iimage);         % show image       
    hold on
    plot(handles.idata(3:6,1),handles.idata(3:6,2),'g*') % show coordinate
    if (size(handles.idata,1) > 7 )
        plot(handles.idata(7:end,1),handles.idata(7:end,2),'b*') % show coordinate
    end
    plot(handles.idata(handles.pick_view_num+2,1),...
        handles.idata(handles.pick_view_num+2,2),'rs',...
        'LineWidth',2, 'MarkerEdgeColor','k',...
        'MarkerFaceColor','g', 'MarkerSize',10)
    
end


% --- Executes on button press in box_msg.
function box_msg_Callback(hObject, eventdata, handles)
% hObject    handle to box_msg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of box_msg
handles.msg_on = get(hObject,'Value');
% update handles
guidata(hObject, handles);


% % --- Executes on slider movement.
% function sl_view_Callback(hObject, eventdata, handles)
% % hObject    handle to sl_view (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hints: get(hObject,'Value') returns position of slider
% %        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
% hanldes.viewaxis = get(hObject,'Value')*100 ;
% % update handles
% guidata(hObject, handles);
% 
% % --- Executes during object creation, after setting all properties.
% function sl_view_CreateFcn(hObject, eventdata, handles)
% % hObject    handle to sl_view (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    empty - handles not created until after all CreateFcns called
% 
% % Hint: slider controls usually have a light gray background.
% if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor',[.9 .9 .9]);
% end

% --- Executes during object creation, after setting all properties.
function reset_data(hObject,handles)
% reset all data to default value
clear handles.idata
clear handles.iiamge
% pannel 0
handles.msg_on=0; 
set(handles.box_msg,'Value',0);

handles.cpx=0;
handles.cpy=0;% gloable variables for current position of mouse
set(findobj('tag','edit5'),'String',num2str(0));
set(findobj('tag','edit6'),'String',num2str(0));
set(findobj('tag','edit7'),'String',num2str(0));

% pannel 1
handles.idata = zeros(2,2);% the key variable for obtaining curve data
handles.iimage = 0;% image data matrix
handles.ximage = 0;
handles.yimage = 0;

% pannel 3
handles.pick_axis_on=0; 
handles.pick_curve_on=0; 
handles.pick_view_num =1;
set(handles.pb_axis,'Enable','Off')
set(handles.pb_curve,'Enable','Off')
set(findobj('tag','listbox1'),'string','(0.000,0.000)')

% pannel 4
handles.point_connect_on = 0;
handles.point_delete_on = 0;
set(handles.pb_connect,'Enable','Off')
set(handles.pb_delete,'Enable','Off')
set(handles.pb_save,'Enable','Off')

% pannel left_top
handles.zoom_on=0;% status variables recording the data picking operations
handles.pan_on=0;
zoom off
pan off
zoom out
set(handles.pb_panOn,'Enable','On');
set(handles.pb_zoomOn,'Enable','On');
set(handles.pb_pan_zoomOff,'Enable','Off');
set(handles.pb_zoomOut,'Enable','On');

% pan left_middle
    % reset current axes
cla reset   
set(handles.axes1,'Visible','off'); 
    % hide info
set(findobj('tag','versionInfo'),'Visible','off');
set(findobj('tag','versionInfo1'),'Visible','off');
set(findobj('tag','versionInfo2'),'Visible','off');

% Update handles structure
guidata(hObject, handles);
% 


% --- Executes during object deletion, before destroying properties.
function listbox1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
