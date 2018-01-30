f=figure('pos',[400,400,500,150]);
mainlayout=uix.Grid('parent',f);
%
handles.initbutton=uicontrol('parent',mainlayout,'string','init instrument');
handles.starttestbutton=uicontrol('parent',mainlayout,'string','start');
uix.Empty( 'Parent', mainlayout );
%
handles.textbox10=uicontrol('parent',mainlayout,'style','text','string','DAC id');
handles.textbox11=uicontrol('parent',mainlayout,'style','text','string','N9030B ip');
handles.textbox12=uicontrol('parent',mainlayout,'style','text','string','DAC ip');
%
handles.loginputbox=uicontrol('parent',mainlayout,'style','edit',...
    'string','DA_id','tag','inputbox');
handles.ipinputbox=uicontrol('parent',mainlayout,'style','edit',...
    'string','10.0.0.101','tag','inputbox');
handles.dacipinputbox=uicontrol('parent',mainlayout,'style','edit',...
    'string','10.0.1.101','tag','inputbox');
%
mainlayout.Heights=[-1 -1 -1];
mainlayout.Widths=[-1 100 -3];

f=figure('pos',[400,400,500,150]);
meaulayout=uix.TabPanel('parent',f);
initlayout=uix.Grid('parent',meaulayout);
freqlayout=uix.Grid('parent',meaulayout);
osclayout=uix.Grid('parent',meaulayout);
meaulayout.TabTitles={'init','freq','osc'};
%分别定义initlayout,freqlayout,osclayout的内容