function interface()
global handles;
%��������
handles.f=figure('Menubar','none','Toolbar','none','pos',[100,100,500,500],'Name','���ô���','NumberTitle', 'off');
mainlayout=uix.Grid('parent',handles.f);
%��һ��
title1_text=uicontrol('parent',mainlayout,'style','text','string','��·����');
alpha_text=uicontrol('parent',mainlayout,'style','text','string','alpha');
beta_text=uicontrol('parent',mainlayout,'style','text','string','beta');
kappa_text=uicontrol('parent',mainlayout,'style','text','string','kappa');
sigma_text=uicontrol('parent',mainlayout,'style','text','string','sigma');
Ej_text=uicontrol('parent',mainlayout,'style','text','string','Ej(GHz)');
Ec_text=uicontrol('parent',mainlayout,'style','text','string','Ec(GHz)');
Csh_text=uicontrol('parent',mainlayout,'style','text','string','Csh(fF)');
Cc_text=uicontrol('parent',mainlayout,'style','text','string','Cc(fF)');
Cr_text=uicontrol('parent',mainlayout,'style','text','string','Cr(fF)');
wr_text=uicontrol('parent',mainlayout,'style','text','string','wr(GHz)');

%�ڶ���
uix.Empty( 'Parent', mainlayout );
alpha_edit=uicontrol('parent',mainlayout,'style','edit',...
    'string','0.60','tag','alpha_box');
beta_edit=uicontrol('parent',mainlayout,'style','edit',...
    'string','0.0','tag','beta_box');
kappa_edit=uicontrol('parent',mainlayout,'style','edit',...
    'string','0.0','tag','kappa_box');
sigma_edit=uicontrol('parent',mainlayout,'style','edit',...
    'string','0.0','tag','sigma_box');
Ej_edit=uicontrol('parent',mainlayout,'style','edit',...
    'string','148.0','tag','Ej_box');
Ec_edit=uicontrol('parent',mainlayout,'style','edit',...
    'string','3.29','tag','Ec_box');
Csh_edit=uicontrol('parent',mainlayout,'style','edit',...
    'string','0.0','tag','Csh_box');
Cc_edit=uicontrol('parent',mainlayout,'style','edit',...
    'string','4.19','tag','Cc_box');
Cr_edit=uicontrol('parent',mainlayout,'style','edit',...
    'string','150.0','tag','Cr_box');
wr_edit=uicontrol('parent',mainlayout,'style','edit',...
    'string','10.298','tag','wr_box');

%������

title2_text=uicontrol('parent',mainlayout,'style','text','string','���㾫��');
nk_text=uicontrol('parent',mainlayout,'style','text','string','nk');
nl_text=uicontrol('parent',mainlayout,'style','text','string','nl');
nm_text=uicontrol('parent',mainlayout,'style','text','string','nm');
uix.Empty( 'Parent', mainlayout );
uix.Empty( 'Parent', mainlayout );
uix.Empty( 'Parent', mainlayout );
uix.Empty( 'Parent', mainlayout );
uix.Empty( 'Parent', mainlayout );
set_parameter_button=uicontrol('parent',mainlayout,'string','���ò���');
uix.Empty( 'Parent', mainlayout );
%������
uix.Empty( 'Parent', mainlayout );
nk_edit=uicontrol('parent',mainlayout,'style','edit',...
    'string','5','tag','nk_box');
nl_edit=uicontrol('parent',mainlayout,'style','edit',...
    'string','10','tag','nl_box');
nm_edit=uicontrol('parent',mainlayout,'style','edit',...
    'string','2','tag','nm_box');
uix.Empty( 'Parent', mainlayout );
uix.Empty( 'Parent', mainlayout );
uix.Empty( 'Parent', mainlayout );
uix.Empty( 'Parent', mainlayout );
uix.Empty( 'Parent', mainlayout );
set_parameter_edit=uicontrol('parent',mainlayout,'style','edit',...
    'string','������','tag','set_parameter_box');
uix.Empty( 'Parent', mainlayout );


%������
title3_text=uicontrol('parent',mainlayout,'style','text','string','��ͼ����');
par_text=uicontrol('parent',mainlayout,'style','text','string','�仯����');
left_text=uicontrol('parent',mainlayout,'style','text','string','left');
right_text=uicontrol('parent',mainlayout,'style','text','string','right');
nlevel_text=uicontrol('parent',mainlayout,'style','text','string','nlevel');
uix.Empty( 'Parent', mainlayout );
uix.Empty( 'Parent', mainlayout );
uix.Empty( 'Parent', mainlayout );
uix.Empty( 'Parent', mainlayout );
calculate_button=uicontrol('parent',mainlayout,'string','��ʼ����');
uix.Empty( 'Parent', mainlayout );

%������
uix.Empty( 'Parent', mainlayout );
par_edit = uicontrol('parent',mainlayout,'style','edit',...
    'string','FluxBias','tag','par_box')
left_edit=uicontrol('parent',mainlayout,'style','edit',...
    'string','0.495','tag','left_box');
right_edit=uicontrol('parent',mainlayout,'style','edit',...
    'string','0.505','tag','right_box');
nlevel_edit=uicontrol('parent',mainlayout,'style','edit',...
    'string','10','tag','nlevel_box');
uix.Empty( 'Parent', mainlayout );
uix.Empty( 'Parent', mainlayout );
uix.Empty( 'Parent', mainlayout );
uix.Empty( 'Parent', mainlayout );
uix.Empty( 'Parent', mainlayout );
uix.Empty( 'Parent', mainlayout );

mainlayout.Heights=[ -1 -1  -1 -1 -1 -1 -1];
mainlayout.Widths=[-1 -2 -1 -2  -1 -2];
%���ݶ�ȡ
set(set_parameter_button,'callback',@(o,e,handles)set_parameter_callbak(o,e));
set(calculate_button,'callback',@(o,e)calculate_callbak(o,e));
end