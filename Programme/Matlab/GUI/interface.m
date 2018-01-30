function interface()
global handles

%��������

handles.f=figure('Menubar','none','Toolbar','none','pos',[100,100,500,500],'Name','���ô���','NumberTitle', 'off');
mainlayout=uix.Grid('parent',handles.f);
%��һ��
title1_text=uicontrol('parent',mainlayout,'style','text','string','��·����');
afaq_text=uicontrol('parent',mainlayout,'style','text','string','afaq');
bataq_text=uicontrol('parent',mainlayout,'style','text','string','bataq');
kq_text=uicontrol('parent',mainlayout,'style','text','string','kq');
detaq_text=uicontrol('parent',mainlayout,'style','text','string','detaq');
Ej_text=uicontrol('parent',mainlayout,'style','text','string','Ej(Hz)');
Ec_text=uicontrol('parent',mainlayout,'style','text','string','Ec(GHz)');
Csh_text=uicontrol('parent',mainlayout,'style','text','string','Csh/CJ');
Cc_text=uicontrol('parent',mainlayout,'style','text','string','Cc(fF)');
Cr_text=uicontrol('parent',mainlayout,'style','text','string','Cr(fF)');
wr_text=uicontrol('parent',mainlayout,'style','text','string','wr(GHz)');

%�ڶ���
uix.Empty( 'Parent', mainlayout );
afaq_edit=uicontrol('parent',mainlayout,'style','edit',...
    'string','0.60','tag','afaq_box');
bataq_edit=uicontrol('parent',mainlayout,'style','edit',...
    'string','0.0','tag','bataq_box');
kq_edit=uicontrol('parent',mainlayout,'style','edit',...
    'string','0.0','tag','kq_box');
detaq_edit=uicontrol('parent',mainlayout,'style','edit',...
    'string','0.0','tag','detaq_box');
Ej_edit=uicontrol('parent',mainlayout,'style','edit',...
    'string','100.0','tag','Ej_box');
Ec_edit=uicontrol('parent',mainlayout,'style','edit',...
    'string','1.0','tag','Ec_box');
Csh_edit=uicontrol('parent',mainlayout,'style','edit',...
    'string','1.0','tag','Csh_box');
Cc_edit=uicontrol('parent',mainlayout,'style','edit',...
    'string','0.0','tag','Cc_box');
Cr_edit=uicontrol('parent',mainlayout,'style','edit',...
    'string','150.0','tag','Cr_box');
wr_edit=uicontrol('parent',mainlayout,'style','edit',...
    'string','10.0','tag','wr_box');
%������

title2_text=uicontrol('parent',mainlayout,'style','text','string','���㾫��');
nk_text=uicontrol('parent',mainlayout,'style','text','string','nk');
nl_text=uicontrol('parent',mainlayout,'style','text','string','nl');
nm_text=uicontrol('parent',mainlayout,'style','text','string','nm');
npoint_text=uicontrol('parent',mainlayout,'style','text','string','npoint');
nvector_text=uicontrol('parent',mainlayout,'style','text','string','nvector');
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
npoint_edit=uicontrol('parent',mainlayout,'style','edit',...
    'string','50','tag','npoint_box');
nvector_edit=uicontrol('parent',mainlayout,'style','edit',...
    'string','50','tag','nvector_box');
uix.Empty( 'Parent', mainlayout );
uix.Empty( 'Parent', mainlayout );
uix.Empty( 'Parent', mainlayout );
set_parameter_edit=uicontrol('parent',mainlayout,'style','edit',...
    'string','������','tag','set_parameter_box');
uix.Empty( 'Parent', mainlayout );
%������
title3_text=uicontrol('parent',mainlayout,'style','text','string','��ͼ����');
left_text=uicontrol('parent',mainlayout,'style','text','string','left');
right_text=uicontrol('parent',mainlayout,'style','text','string','right');
nlevel_text=uicontrol('parent',mainlayout,'style','text','string','nlevel');
levelplot_text=uicontrol('parent',mainlayout,'style','text','string','levelplot');
fiqplot_text=uicontrol('parent',mainlayout,'style','text','string','fiqplot');
accuracy_text=uicontrol('parent',mainlayout,'style','text','string','accuracy');
uix.Empty( 'Parent', mainlayout );
uix.Empty( 'Parent', mainlayout );
calculate_button=uicontrol('parent',mainlayout,'string','��ʼ����');
uix.Empty( 'Parent', mainlayout );
%������
uix.Empty( 'Parent', mainlayout );
left_edit=uicontrol('parent',mainlayout,'style','edit',...
    'string','0.495','tag','left_box');
right_edit=uicontrol('parent',mainlayout,'style','edit',...
    'string','0.505','tag','right_box');
nlevel_edit=uicontrol('parent',mainlayout,'style','edit',...
    'string','10','tag','nlevel_box');
levelplot_edit=uicontrol('parent',mainlayout,'style','edit',...
    'string','1 2 3 4 5 6 7 8','tag','levelplot_box');
fiqplot_edit=uicontrol('parent',mainlayout,'style','edit',...
    'string','0.5','tag','fiqplot_box');
accuracy_edit=uicontrol('parent',mainlayout,'style','edit',...
    'string','500','tag','accuracy_box');
uix.Empty( 'Parent', mainlayout );
uix.Empty( 'Parent', mainlayout );
% calculate_edit=uicontrol('parent',mainlayout,'style','edit',...
%     'string','������','tag','calculate_box');
uix.Empty( 'Parent', mainlayout );
uix.Empty( 'Parent', mainlayout );
%
mainlayout.Heights=[ -1 -1  -1 -1 -1 -1 -1];
mainlayout.Widths=[-1 -2 -1 -2  -1 -2];

%���ݶ�ȡ

set(set_parameter_button,'callback',@(o,e,handles)set_parameter_callbak(o,e));
set(calculate_button,'callback',@(o,e)calculate_callbak(o,e));
%[ afaq,bataq,kq,detaq,Ej,Ec, Csh0,Cc,Cr,wr,k,l,m,n_point,n_vector,left,right,n_level,level_plot,fiq_plot,accuracy]
end

function set_parameter_callbak(o,e)
    global handles
    mainlayout=get(o,'parent');
    afaqBox=findobj('Parent', mainlayout,'Tag','afaq_box');
    handles.afaq=str2double(get(afaqBox,'string'));
    set(afaqBox,'string',num2str(handles.afaq));
    
    bataqBox=findobj('Parent', mainlayout,'Tag','bataq_box');
    handles.bataq=str2double(get(bataqBox,'string'));
    set(bataqBox,'string',num2str(handles.bataq));
    
    kqBox=findobj('Parent', mainlayout,'Tag','kq_box');
    handles.kq=str2double(get(kqBox,'string'));
    set(kqBox,'string',num2str(handles.kq));
    
    detaqBox=findobj('Parent', mainlayout,'Tag','detaq_box');
    handles.detaq=str2double(get(detaqBox,'string'));
    set(detaqBox,'string',num2str(handles.detaq));
    
    EjBox=findobj('Parent', mainlayout,'Tag','Ej_box');
    Ej0=str2double(get(EjBox,'string'));
    set(EjBox,'string',num2str(Ej0));
    handles.Ej=Ej0*10^9*6.6260693*10^(-34);
    
    EcBox=findobj('Parent', mainlayout,'Tag','Ec_box');
    Ec0=str2double(get(EcBox,'string'));
    set(EcBox,'string',num2str(Ec0));
    handles.Ec=Ec0*10^9*6.6260693*10^(-34);
    
    CshBox=findobj('Parent', mainlayout,'Tag','Csh_box');
    handles.Csh0=str2double(get(CshBox,'string'));
    set(CshBox,'string',num2str(handles.Csh0));
    
    CcBox=findobj('Parent', mainlayout,'Tag','Cc_box');
    Cc0=str2double(get(CcBox,'string'));
    set(CcBox,'string',num2str(Cc0));
    handles.Cc=Cc0*10^(-15);
    
    CrBox=findobj('Parent', mainlayout,'Tag','Cr_box');
    Cr0=str2double(get(CrBox,'string'));
    set(CrBox,'string',num2str(Cr0));
    handles.Cr=Cr0*10^(-15);
    
    wrBox=findobj('Parent', mainlayout,'Tag','wr_box');
    wr=str2double(get(wrBox,'string'));
    set(wrBox,'string',num2str(wr));
    handles.wr=wr*2*pi*10^9;
    
    
    %
    nkBox=findobj('Parent', mainlayout,'Tag','nk_box');
    handles.k=str2double(get(nkBox,'string'));
    set(nkBox,'string',num2str(handles.k));
    
    nlBox=findobj('Parent', mainlayout,'Tag','nl_box');
    handles.l=str2double(get(nlBox,'string'));
    set(nlBox,'string',num2str(handles.l));
    
    nmBox=findobj('Parent', mainlayout,'Tag','nm_box');
    handles.m=str2double(get(nmBox,'string'));
    set(nmBox,'string',num2str(handles.m));
    
    npointBox=findobj('Parent', mainlayout,'Tag','npoint_box');
    handles.n_point=str2double(get(npointBox,'string'));
    set(npointBox,'string',num2str(handles.n_point));
    
    nvectorBox=findobj('Parent', mainlayout,'Tag','nvector_box');
    handles.n_vector=str2double(get(nvectorBox,'string'));
    set(nvectorBox,'string',num2str(handles.n_vector));
    %
    leftBox=findobj('Parent', mainlayout,'Tag','left_box');
    temp=get(leftBox,'string');
    temp=strcat('left=',temp,';');
    eval(temp);
    handles.left=left;
    set(leftBox,'string',num2str(left));
    
    rightBox=findobj('Parent', mainlayout,'Tag','right_box');
    temp=get(rightBox,'string');
    temp=strcat('right=',temp,';');
    eval(temp);
    handles.right=right;
    set(rightBox,'string',num2str(right));
    
    nlevelBox=findobj('Parent', mainlayout,'Tag','nlevel_box');
    handles.n_level=str2double(get(nlevelBox,'string'));
    set(nlevelBox,'string',num2str(handles.n_level));
    
    levelplotBox=findobj('Parent', mainlayout,'Tag','levelplot_box');
    temp=get(levelplotBox,'string');
    temp=strcat('levelplot=[',temp,']',';');
    eval(temp);
    handles.level_plot=levelplot;
    set(levelplotBox,'string',num2str(levelplot));
    
    fiqplotBox=findobj('Parent', mainlayout,'Tag','fiqplot_box');
    temp=get(fiqplotBox,'string');
    temp=strcat('fiqplot=[',temp,'];');
    eval(temp);
    handles.fiq_plot=fiqplot;
    set(fiqplotBox,'string',num2str(fiqplot));
    
    accuracyBox=findobj('Parent', mainlayout,'Tag','accuracy_box');
    handles.accuracy=str2double(get(accuracyBox,'string'));
    set(accuracyBox,'string',num2str(handles.accuracy));
    
    set_parameterBox=findobj('Parent', mainlayout,'Tag','set_parameter_box');
    set(set_parameterBox,'string','�������');
    ahandle.handles=handles;
        
end

function calculate_callbak(o,e)
    global handles
    h=6.6260693*10^(-34);
    mainlayout=get(o,'parent');
    handles.container1=uix.TabPanel('parent',figure('Name',['�������ʷֲ�' 'afaq=' num2str(handles.afaq) '  Ej=' num2str(handles.Ej/h/10^9) '  Ec=' num2str(handles.Ec/h/10^9) ],'NumberTitle', 'off'));
    handles.container2=uix.TabPanel('parent',figure('Name',['������ʱ���' 'afaq=' num2str(handles.afaq) '  Ej=' num2str(handles.Ej/h/10^9) '  Ec=' num2str(handles.Ec/h/10^9) ],'NumberTitle', 'off'));
    handles.container3=uix.TabPanel('parent',figure('Name',['��������f�ı仯' 'afaq=' num2str(handles.afaq) '  Ej=' num2str(handles.Ej/h/10^9) '  Ec=' num2str(handles.Ec/h/10^9) '  Csh=' num2str(handles.Csh0)],'NumberTitle', 'off'));
    [g,xx_total,xx,p_pesi_kl0,p_pesi_kl ]=calculate_capacitive_coupling( handles.afaq,handles.bataq,handles.kq,handles.detaq,...
        handles.Ej,handles.Ec, handles.Csh0,handles.Cc,handles.Cr,handles.wr,...
        handles.k,handles.l,handles.m,handles.n_point,handles.n_vector,...
        2*pi*handles.left,  2*pi*handles.right,  handles.n_level,handles.level_plot,...
        2*pi*handles.fiq_plot,handles.accuracy) ;
    handles.g=g;
    handles.xx_total=xx_total;
    handles.xx=xx;
    handles.p_pesi_kl0=p_pesi_kl0;
    handles.p_pesi_kl=p_pesi_kl;
    set_parameterBox=findobj('Parent', mainlayout,'Tag','set_parameter_box');
    set(set_parameterBox,'string','������');
end

function [ g,xx_total,xx,p_pesi_kl0,p_pesi_kl  ] =calculate_capacitive_coupling( afaq,bataq,kq,detaq,Ej,Ec, Csh0,Cc,Cr,wr,k,l,m,n_point,n_vector,left,right,n_level,level_plot,fiq_plot,accuracy)
%�������ǿ��
%��������������̬ʸ,������ǿ��(���������ܼ���Ϊһ��)
%�����洫�����ĳ����Ƿ��
%afaq,bataq,kq,detaq,Ej,Ec, Csh0,Cc,Cr,wr,k,l,m,n_point,n_vector,left,right,n_level,level_plot,fiq_plot,accuracy
%��ѧ����(���ʵ�λ)
% h=6.6260693*10^(-34);
% e=1.602*10^(-19);
% i=sqrt(-1);
%FI0=h/(2*e);
%h0=6.6260693*10^(-34)/(2*pi);

%�������루���ʵ�λ��
% afaq=(0.65);
% bataq=0;
% kq=0;
% detaq=0;
% Ej=148*10^9*h;
% Ec=3.5*10^9*h; 
% Cc=4.19*10^(-15);
% Cr=150*10^(-15);
% Csh0=0;
% wr=2*pi*(10.3)*10^9;%��Ƶ��
% %M=(2.9912)*10^(-12);
% %Lq=(80)*10^(-12);
% %Lr=(1000)*10^(-12);

%��ͼ����
% n_point=40;          %fiqȡ������������ż����
% left=2*pi*(0.5-0.01);         %fiq�����ʼ��
% right=2*pi*(0.5+0.01);
% level_plot=[1 2 3 4 5 6 7 8 9 10];

%���㾫��
% k=5;
% l=10;
% m=2;

%��������
%bataq=afaq*Lq/(2*afaq+1)/Lj;
%Em=(FI0)^2/(2*M);
%Elr=(FI0)^2/(2*Lr);
%Cj=(e^2)/2/Ec;
%batac=Cc/Cj;
%Y=1+2*afaq+2*batac;
%gama=Cc/Cr;
%X=(1+2*afaq)*(1+gama)+2*batac;
%Er=h/(2*pi)*wr;

%�ڴ�����
Hl=zeros(2*l+1,2*l+1);
Hm=zeros(m+1,m+1);

%������Ͼ���
%constant=-2*i*sqrt(batac*gama*Er*Ec)*Y^(-1/2)*X^(-1/2)*(0.5/(1+2*afaq));%wr��1/sqrt(Lr*Cr)��һ�²������S26  
Hk0=eye(2*k+1);
Hl0=eye(2*l+1);
Hm0=eye(m+1);
for jj=-l:l
    Hl(jj+l+1,jj+l+1)=jj;
end
Hcq1=kron(kron(Hk0,Hl),Hm0);
for jj=1:m+1
    for jjj=1:m+1
        if(delta(jj,jjj+1))
            Hm(jj,jjj)=sqrt(jjj);
        end
        if(delta(jjj,jj+1))
            Hm(jj,jjj)=-sqrt(jj);
        end
    end
end
Hcq2=kron(kron(Hk0,Hl0),Hm);
%Hcq1=constant*Hcq1;
%Hcq2=0*Hcq2;
%���������ܼ�
[g,xx_total,xx,p_pesi_kl0,p_pesi_kl ]=fiq_E_curve_special( afaq,bataq,kq,detaq,Ej,Ec,Cc,Cr,n_point,left,right,level_plot,Hcq1,Hcq2,wr,Csh0,n_level,fiq_plot,n_vector,accuracy,k,l,m );
end

function [ M_over_all,mt ] = capacitive_coupling_M_over( afaq,C1,C2,C3,Cc,Cr,h,e)
%���������Ҫ�����ı�Ҫ����
%afaq=0;Cj=1;Cc=0.5;Cr=0.5;
S=[  1/2,      -1/(2*(2*afaq+1)),     -afaq/(2*afaq+1),     0;
       -1/2,     -1/(2*(2*afaq+1)),     -afaq/(2*afaq+1),     0;
        0,         afaq/(2*afaq+1),         -afaq/(2*afaq+1),     0;
        0,          0,                            0,                          1   ];
    
M0=[C1  0 0 0; 0 C2 0 0 ;0 0 C3+Cc -Cc; 0 0 -Cc Cr+Cc];
M0_over=M0^(-1);
M_over_all=(4*pi*e/h)^2*S'*M0_over*S;
mt=1/M_over_all(3,3);

end

function [ kkk ] = delta(mmm,nnn )
%ʵ��delta����
%   �˴���ʾ��ϸ˵��
if (mmm==nnn)
    kkk=1;
else
    kkk=0;
end

end

function [ g,xx_total,xx,p_pesi_kl0,p_pesi_kl ] = fiq_E_curve_special( afaq,bataq,kq,detaq,Ej,Ec,Cc,Cr,n_point,left,right,level_plot,Hcq1,Hcq2,wr,Csh0,n_level,fiq_plot,n_vector,accuracy,k,l,m )
global handles
%�̶�����
h=6.6260693*10^(-34);
e=1.602176487*10^(-19);
p=1;
q=2;
i=sqrt(-1);

%Josephson��������ֶ����ã���������
%afaq=0.598;
%bataq= 0.0973;
%kq=0;
%detaq=0;
%Ej=730.12*10^9*h;
%Ec=1.58*10^9*h;            

%���㾫��ѡ�񡪡�Э��������Դ����㾫�ȣ��ֶ����ã���������
% k=5;                 %nk�Ľض�
% l=10;                %nl�Ľض�
% m=2;                 %nm�Ľض�
%n_point=2;          %fiqȡ������������ż����
%left=0;         %fiq�����ʼ��
%right=2*pi;        %fiq�Ҳ���ֹ��
%n_level=100;          %��¼���ܼ�����
%n_vector=500;        %��¼����������ģ���Ӵ�С����

%���ò������������ã�
if (bataq==0)
    bataq=10^(-8);
end
if (Cc==0)
    Cc=10^(-30);
end
if(mod(n_point,2))
    n_point=n_point+1;
end
C_sum=e^2/Ec;
Cs=detaq/2*C_sum;
C1=(1+kq)/2*C_sum+Cs;
C2=(1-kq)/2*C_sum+Cs;
C3=afaq/2*C_sum+Cs+(Csh0/2*C_sum);%��Csh��
[ M_over_all,mt ] = capacitive_coupling_M_over( afaq,C1,C2,C3,Cc,Cr,h,e);
M_over=eye(3,4)*M_over_all*eye(4,3);
wt=(2*Ec/h*2*pi)*sqrt((2*Ej*afaq*(1-kq^2)*((1+detaq)*(1+2*afaq+3*detaq)-kq^2))/(Ec*bataq*(1+2*afaq-kq^2)*(afaq+detaq)*((1+detaq)^2-kq^2)));
n_level_plot=length(level_plot);
fiqs=left:(right-left)/n_point:right;



%�����ڴ�
Hklm=zeros((2*k+1)*(2*l+1)*(m+1),(2*k+1)*(2*l+1)*(m+1));
energy=zeros(n_point+1,(2*k+1)*(2*l+1)*(m+1));
vector=zeros((2*k+1)*(2*l+1)*(m+1),n_level);
EE=zeros(1,(2*k+1)*(2*l+1)*(m+1));
g=zeros(n_point+1,nchoosek(fix(n_level/2),2));
xx_total=zeros(1,n_point+1);
xx=zeros(fix(n_level/2),fix(n_level/2),n_point+1);
pesi=zeros(4,n_vector,n_level_plot);
pesi_x=zeros(accuracy+1,accuracy+1,n_level_plot);
Ip=zeros(n_point,3);
Ip_slope=zeros(n_point-1,3);
temp1=zeros(1,n_point+1);
temp2=zeros(1,n_point+1);
temp3=zeros(1,n_point+1);
temp4=zeros(1,n_point+1);
temp5=zeros(1,n_point+1);


%����H��fiq�޹ز���
Hklm = solve_for_Hklm_1( k,l,m,h,M_over,Hklm);
Hklm = solve_for_Hklm_2( k,l,m,wt,h,mt,M_over,Hklm );
Hklm = special_for_fiq_E_0_Hklm3( p,q,k,l,m,mt,wt,h,Hklm,Ej,afaq,pi,kq );
Hklm = solve_for_Hklm_4( k,l,m,h,wt,Hklm );

%����H��fiq��ز��ֲ������
nn=0;
color1=['b.';'r.';'g.';'k.';'y.';'m.'];
color2=['b-';'r-';'g-';'k-';'y-';'m-'];
color3=['b:';'r:';'g:';'k:';'y:';'m:'];
ax=axes('parent',uicontainer('parent',handles.container3));
for fiq=left:(right-left)/n_point:right 
    nn=nn+1; %��������н���    
    fprintf('������ȣ���%d���㣨��%d���㣩\n',nn,n_point+1); 
    Hklm_fiq = special_for_fiq_E_1_Hklm3(p,q,k,l,m,mt,wt,h,Hklm,Ej,afaq,fiq,kq );
    [eigenvector,eigenvalue]=eig(Hklm_fiq); %eigenvector�������Ǳ�������
    
    %����ض��ܼ�����ʸ��
    for jj=1:(2*k+1)*(2*l+1)*(m+1)  %����ֵ�����һά����
        EE(jj)=eigenvalue(jj,jj);
    end
    [ energy(nn,:),E_index]=sort(real(EE));
    for jj=1:n_level
        for jjj=1:(2*k+1)*(2*l+1)*(m+1)
            vector(jjj,jj)=eigenvector(jjj,E_index(jj));
        end
    end
    
    %�������ǿ�Ȳ���ͼ
    nnn=0;
    %Hcq=Hcq1;
    Hcq=M_over_all(2,4)*i*sqrt(1/M_over_all(4,4)*wr*(h/2/pi)/2)*(h/2/pi)*Hcq1+M_over_all(3,4)*i*sqrt(mt*wt*(h/2/pi)/2)*i*sqrt(1/M_over_all(4,4)*wr*(h/2/pi)/2)*Hcq2;
    for jj=2:(max(5,n_level/2))
        for jjj=1:(jj-1)
            nnn=nnn+1;
            g(nn,nnn)=0;
            g(nn,nnn)=g(nn,nnn)+abs(vector(:,jj*2)'*Hcq*vector(:,jjj*2));
            g(nn,nnn)=g(nn,nnn)+abs(vector(:,jj*2)'*Hcq*vector(:,jjj*2-1));
            g(nn,nnn)=g(nn,nnn)+abs(vector(:,jj*2-1)'*Hcq*vector(:,jjj*2));
            g(nn,nnn)=g(nn,nnn)+abs(vector(:,jj*2-1)'*Hcq*vector(:,jjj*2-1));
            g(nn,nnn)=g(nn,nnn)/h/(10^9)/2;          %����2����Ϊ��������Ч֧��������ڸ��ܼ�����������Ч֧���������Bug
            if(jj<5)   %���Ƶ����ܼ������ǿ���������
                %plot(fiq/(2*pi),g(nn,nnn),color(mod(nnn-1,6)+1,:),'parent',axes('parent',uicontainer('parent',handles.container2)));          
                plot(fiq/(2*pi),g(nn,nnn),color1(mod(nnn-1,6)+1,:),'parent',ax);hold on;
            end
            hold on;%��Ϊ�沢�������ܼ������ӽ���ȡ���ܼ��������߲��ϴ�����������
            xx(jjj,jj,nn)=g(nn,nnn)^2/((energy(nn,jj*2)-energy(nn,jjj*2))/h/(10^9)-wr/(10^9)/2/pi)*10^3;
            xx(jj,jjj,nn)=g(nn,nnn)^2/((energy(nn,jjj*2)-energy(nn,jj*2))/h/(10^9)-wr/(10^9)/2/pi)*10^3;
        end
    end
    for jj=3:n_level/2
        xx_total(nn)=(xx(jj,2,nn)-xx(2,jj,nn)-xx(jj,1,nn)+xx(1,jj,nn))/2+xx_total(nn);
    end
    xx_total(nn)=xx(1,2,nn)-xx(2,1,nn)+xx_total(nn);
end
xlabel(ax,'f');
ylabel(ax,'����GHz');
xlim([left/2/pi right/2/pi]);
title('|g| (b-I&II,r-I&III,g-II&III,k-I&IV,y-II&IV, m-III&IV)','parent',ax);

%��fiq_plot����
Hklm_fiq = special_for_fiq_E_1_Hklm3(p,q,k,l,m,mt,wt,h,Hklm,Ej,afaq,fiq_plot,kq );
%����pi�㲨���������ɷ�
[ p_pesi_kl0,p_pesi_kl ] = plot_pesi_kl(Hklm_fiq,level_plot,k,l,m,fiq_plot);

%�����ܺ���
[ ~,~ ] = plot_U_x( afaq,bataq,kq,fiq_plot,accuracy );

%����pi��������󲨺���
[eigenvector,eigenvalue]=eig(Hklm_fiq); 
handles.eigenvector=eigenvector;
for jj=1:(2*k+1)*(2*l+1)*(m+1)  %����ֵ�����һά����
    EE(jj)=eigenvalue(jj,jj);
end
[~,E_index]=sort(real(EE));
for jj=1:n_level_plot
    for jjj=1:(2*k+1)*(2*l+1)*(m+1)
        vector(jjj,jj)=eigenvector(jjj,E_index(level_plot(jj)));
    end
    [vector_sort,vector_index]=sort(vector(:,jj),'descend');
    for jjj=1:n_vector
        [ kk0,ll0,mm0 ] = index_transformation( vector_index(jjj),k,l,m );
        pesi(1,jjj,jj)=vector_sort(jjj);
        pesi(2,jjj,jj)=kk0;
        pesi(3,jjj,jj)=ll0;
        pesi(4,jjj,jj)=mm0;          
    end
    [ pesi_x(:,:,jj),~ ] = wavefunction_xa_xs( pesi(:,:,jj),n_vector,accuracy,level_plot(jj) );
    %titlecell2{1,level_plot(jj)}=['�ܼ�' num2str(level_plot(jj))];
end
%handles.container2.TabTitles=titlecell2;



%���ǿ�Ȼ�ͼx

ax=axes('parent',uicontainer('parent',handles.container3));
for nn=1:n_point+1
    temp1(nn)=xx(1,2,nn);
    temp2(nn)=xx(2,1,nn);
    temp3(nn)=xx(1,3,nn);
    temp4(nn)=xx(2,3,nn);
    temp5(nn)=xx(3,2,nn);
end
plot(fiqs/(2*pi),xx_total,'b-','parent',ax);hold on;
plot(fiqs/(2*pi),temp1,'r-','parent',ax);
plot(fiqs/(2*pi),temp2,'g-','parent',ax);
plot(fiqs/(2*pi),temp3,'k-','parent',ax);
plot(fiqs/(2*pi),temp4,'y-','parent',ax);
plot(fiqs/(2*pi),temp5,'m-','parent',ax);
xlabel(ax,'f');
ylabel(ax,'����MHz');
xlim([left/2/pi right/2/pi]);
title('X (b-total,r-I&II,g-II&I,k-I&III,y-II&III, m-III&II)','parent',ax);

%���ܼ�ͼ
ax=axes('parent',uicontainer('parent',handles.container3));
for jj=1:n_level/2
    plot(fiqs/(2*pi),(energy(:,2*jj-1)-energy(n_point/2+1,1))/h/(10^9),'b-','parent',ax);hold on;%����Ƶ��
    plot(fiqs/(2*pi),(energy(:,2*jj)-energy(n_point/2+1,1))/h/(10^9),'b-','parent',ax);
end
%xlim([left/2/pi right/2/pi]);
xlabel(ax,'f');
ylabel(ax,'����GHz');
xlim([left/2/pi right/2/pi]);
title('�ܼ�','parent',ax);
handles.energy=energy;

%���ܼ����
ax=axes('parent',uicontainer('parent',handles.container3));
for jj=1:n_level/2-1
    plot(fiqs/(2*pi),(energy(:,2*jj+1)-energy(:,1))/h/(10^9),color2(mod(jj-1,6)+1,:),'parent',ax);hold on;%����Ƶ��
    plot(fiqs/(2*pi),(energy(:,2*jj+1)-energy(:,1))/h/(10^9)/2,color3(mod(jj-1,6)+1,:),'parent',ax);
end
xlabel(ax,'f');
ylabel(ax,'����GHz');
title('�ܼ����(b-w31,r-w51,g-w71,k,y,m)','parent',ax);
ylim([0 18]);

%����������϶
ax=axes('parent',uicontainer('parent',handles.container3));
plot(fiqs/(2*pi),(energy(:,2)-energy(:,1))/h/(10^6),'b-','parent',ax);hold on;%����Ƶ��
plot(fiqs/(2*pi),(energy(:,4)-energy(:,3))/h/(10^6),'r-','parent',ax);
xlabel(ax,'f');
ylabel(ax,'����MHz');
xlim([left/2/pi right/2/pi]);
title('��������϶(b:w12��r:w34)','parent',ax);

%��Ip
fiqs_Ip=fiqs(1:n_point)+0.5*(right-left)/n_point;
ax=axes('parent',uicontainer('parent',handles.container3));
for nn=1:n_point
    Ip(nn,1)=2*e/h*(energy(nn+1,1)-energy(nn,1))/((right-left)/n_point/(2*pi));
    Ip(nn,2)=2*e/h*(energy(nn+1,3)-energy(nn,3))/((right-left)/n_point/(2*pi));
    Ip(nn,3)=Ip(nn,1)-Ip(nn,2);
end
plot(fiqs_Ip/(2*pi),Ip(:,1)*10^9,'b-','parent',ax);hold on;%����Ƶ��
plot(fiqs_Ip/(2*pi),Ip(:,2)*10^9,'r-','parent',ax);
plot(fiqs_Ip/(2*pi),Ip(:,3)*10^9,'g-','parent',ax);
xlabel(ax,'f');
ylabel(ax,'Ip(nA)');
xlim([left/2/pi right/2/pi]);
title('b-Ip(g),r-Ip(e),g-Ip(w)','parent',ax);

%��Ipб��
fiqs_Ip_slope=fiqs_Ip(1:n_point-1)+0.5*(right-left)/n_point;
ax=axes('parent',uicontainer('parent',handles.container3));
for nn=1:n_point-1
    Ip_slope(nn,1)=(Ip(nn+1,1)-Ip(nn,1))/((right-left)/n_point/(2*pi));
    Ip_slope(nn,2)=(Ip(nn+1,2)-Ip(nn,2))/((right-left)/n_point/(2*pi));
    Ip_slope(nn,3)=(Ip(nn+1,3)-Ip(nn,3))/((right-left)/n_point/(2*pi));
end
plot(fiqs_Ip_slope/(2*pi),Ip_slope(:,1)*10^9,'b-','parent',ax);hold on;%����Ƶ��
plot(fiqs_Ip_slope/(2*pi),Ip_slope(:,2)*10^9,'r-','parent',ax);
plot(fiqs_Ip_slope/(2*pi),Ip_slope(:,3)*10^9,'g-','parent',ax);
xlabel(ax,'f');
ylabel(ax,'dIp/df(nA)');
xlim([left/2/pi right/2/pi]);
title('slope_of_Ip b-dIp(g),r-dIp(e),g-dIp(w)','parent',ax);

end

function [ kk0,ll0,mm0 ] = index_transformation( ii,k,l,m )
%��������������ii��ɲ������±�kk,ll,mm
%   �˴���ʾ��ϸ˵��
mm0=mod(ii-1,m+1);
kk=fix((ii-mm0-1)/((2*l+1)*(m+1)))+1;
ll=(ii-mm0-1-(kk-1)*(2*l+1)*(m+1))/(m+1)+1;

kk0=kk-k-1;
ll0=ll-l-1;
end

function [ p_pesi_kl0,p_pesi_kl ] = plot_pesi_kl(Hklm_fiq,level_plot,k,l,m,fiq_plot)
%������̬ʸ�Ķ�������
global handles
n_level_plot=length(level_plot);

%�����ڴ�
p_pesi_kl=zeros(2*k+1,2*l+1,n_level_plot);
p_pesi_kl0=zeros(2*k+1,2*l+1,n_level_plot);
EE=zeros(1,(2*k+1)*(2*l+1)*(m+1) );
vector=zeros((2*k+1)*(2*l+1)*(m+1),n_level_plot);

%�Ȿ��ʸ��
fprintf('���ڼ���fiq=%f�㶯������Ͳ������ͻ�ͼ\n',fiq_plot);
[eigenvector,eigenvalue]=eig(Hklm_fiq); %eigenvector�������Ǳ�������
for jj=1:(2*k+1)*(2*l+1)*(m+1)  %����ֵ�����һά����
    EE(jj)=eigenvalue(jj,jj);
end

%��ȡ��Ҫ�ܼ�����ʸ��
[~,E_index]=sort(real(EE));
for jj=1:n_level_plot
    for jjj=1:(2*k+1)*(2*l+1)*(m+1)
        vector(jjj,jj)=eigenvector(jjj,E_index(level_plot(jj)));
    end
end

%��������
[k_plot,l_plot]=meshgrid(-l:l,-k:k);
for jj=1:n_level_plot 
    for jjj=1:(2*k+1)*(2*l+1)*(m+1) 
        [ kk0,ll0,mm0 ] = index_transformation( jjj,k,l,m );
        p_pesi_kl(kk0+k+1,ll0+l+1,jj)=p_pesi_kl(kk0+k+1,ll0+l+1,jj)+abs(vector(jjj,jj))^2;
        if(mm0==0)
            p_pesi_kl0(kk0+k+1,ll0+l+1,jj)=vector(jjj,jj);
        end
    end
    ax=axes('parent',uicontainer('parent',handles.container1));
    mesh(k_plot,l_plot,p_pesi_kl(:,:,jj),'parent',ax);
    %titlecell1{1,jj}=['�ܼ�' num2str(level_plot(jj))];
    title(['�ܼ�' num2str(level_plot(jj))],'parent',ax);
    hold on;
end
%handles.container1.TabTitles=titlecell1;
end

function [ hklm_3_1 ] = solve_for_hklm_3_1( mm1,mm2,pp,qq,mt,wt,h,afaq,fiq,kq )
%����H����Ԫ��������ǰһ������
%   �˴���ʾ��ϸ˵��
i=sqrt(-1);
mm_min=min(mm1,mm2);
hklm_3_1=0;

if(pp==1&&qq==2)
    factor=0;
    for jj=0:mm_min
        factor=factor+factorial(jj)*nchoosek(mm1,jj)*nchoosek(mm2,jj)*(h/(4*pi*mt*wt))^((mm1+mm2-2*jj)/2)*(i)^(mm1+mm2-2*jj);
    end
    hklm_3_1=0.5*(1-kq)/sqrt(factorial(mm1)*factorial(mm2))*exp(-h/(8*pi*mt*wt))*factor;
end

if(pp==3&&qq==4)
    factor=0;
    for jj=0:mm_min
        factor=factor+factorial(jj)*nchoosek(mm1,jj)*nchoosek(mm2,jj)*(h/(4*pi*mt*wt))^((mm1+mm2-2*jj)/2)*(-i)^(mm1+mm2-2*jj);
    end
    hklm_3_1=0.5*(1-kq)/sqrt(factorial(mm1)*factorial(mm2))*exp(-h/(8*pi*mt*wt))*factor;
end

if(pp==1&&qq==4)
    factor=0;
    for jj=0:mm_min
        factor=factor+factorial(jj)*nchoosek(mm1,jj)*nchoosek(mm2,jj)*(h/(4*pi*mt*wt))^((mm1+mm2-2*jj)/2)*(-i)^(mm1+mm2-2*jj);
    end
    hklm_3_1=0.5*(1+kq)/sqrt(factorial(mm1)*factorial(mm2))*exp(-h/(8*pi*mt*wt))*factor;
end

if(pp==3&&qq==2)
    factor=0;
    for jj=0:mm_min
        factor=factor+factorial(jj)*nchoosek(mm1,jj)*nchoosek(mm2,jj)*(h/(4*pi*mt*wt))^((mm1+mm2-2*jj)/2)*(i)^(mm1+mm2-2*jj);
    end
    hklm_3_1=0.5*(1+kq)/sqrt(factorial(mm1)*factorial(mm2))*exp(-h/(8*pi*mt*wt))*factor;
end

if((pp==2)&&(qq==1))
    factor=0;
    for jj=0:mm_min
        factor=factor+factorial(jj)*nchoosek(mm1,jj)*nchoosek(mm2,jj)*(h/(4*pi*mt*wt*afaq^2))^((mm1+mm2-2*jj)/2)*(-i)^(mm1+mm2-2*jj);
    end
    hklm_3_1=0.5*afaq*exp(i*fiq)/sqrt(factorial(mm1)*factorial(mm2))*exp(-h/(8*pi*mt*wt*afaq^2))*factor;
end         

if((pp==2)&&(qq==5))
    factor=0;
    for jj=0:mm_min
        factor=factor+factorial(jj)*nchoosek(mm1,jj)*nchoosek(mm2,jj)*(h/(4*pi*mt*wt*afaq^2))^((mm1+mm2-2*jj)/2)*(i)^(mm1+mm2-2*jj);
    end
    hklm_3_1=0.5*afaq*exp(-i*fiq)/sqrt(factorial(mm1)*factorial(mm2))*exp(-h/(8*pi*mt*wt*afaq^2))*factor;
end         
    

end

function [ Hklm ] =solve_for_Hklm_1( k,l,m,h,M_over,Hklm)
%����H����Ԫ��һ����
%   �˴���ʾ��ϸ˵��
as=[1 0 0; 0 1 0];
M_over_as=as*M_over*as';
ii=0;
for kk=1:2*k+1
    for ll=1:2*l+1
        for mm=1:m+1
            ii=ii+1;
            kkll=[kk-1-k,ll-1-l];
            Hklm(ii,ii)=(h/(2*pi))^2*0.5*(kkll*M_over_as*kkll');
        end
    end
end
end

function [ Hklm ] = solve_for_Hklm_2( k,l,m,wt,h,mt,M_over,Hklm )
%����H����Ԫ�ڶ�����
%   �˴���ʾ��ϸ˵��
i=sqrt(-1);
ii1=0;

hklm2=zeros((2*k+1)*(2*l+1)*(m+1),(2*k+1)*(2*l+1)*(m+1));
for kk1=1:2*k+1
    for ll1=1:2*l+1
        for mm1=1:m+1
            ii1=ii1+1;
            ii2=0;
            for kk2=1:2*k+1
                for ll2=1:2*l+1
                    for mm2=1:m+1
                        ii2=ii2+1;
                        if(kk1==kk2&&ll1==ll2)
                            hklm2(ii1,ii2)=M_over(1,3)*(kk1-1-k)+M_over(2,3)*(ll1-1-l);
                        end
                        hklm2(ii1,ii2)=hklm2(ii1,ii2)*(sqrt(mm1)*delta(mm1,mm2-1)-sqrt(mm1-1)*delta(mm1-1,mm2));
                    end
                end
            end
        end
    end
end
constant=i*sqrt(mt*wt*(h/2/pi)^3/2);%�����д���
hklm2=hklm2*constant;
Hklm=Hklm+hklm2;
end

function [Hklm] = solve_for_Hklm_4( k,l,m,h,wt,Hklm )
%����H����Ԫ���Ĳ���
%   �˴���ʾ��ϸ˵��
ii=0;
for kk=1:2*k+1
    for ll=1:2*l+1
        for mm=1:m+1
            ii=ii+1;
            Hklm(ii,ii)=Hklm(ii,ii)+(mm-0.5)*h/(2*pi)*wt;
        end
    end
end
end

function [ Hklm ] = special_for_fiq_E_0_Hklm3( p,q,k,l,m,mt,wt,h,Hklm,Ej,afaq,fiq,kq )
%����H����Ԫ��������
%   �˴���ʾ��ϸ˵��
ii1=0;
hklm3=zeros((2*k+1)*(2*l+1)*(m+1),(2*k+1)*(2*l+1)*(m+1));
for kk1=1:2*k+1
    for ll1=1:2*l+1
        for mm1=1:m+1
            ii1=ii1+1;
            ii2=0;
            for kk2=1:2*k+1
                for ll2=1:2*l+1
                    for mm2=1:m+1
                        ii2=ii2+1;           
                        hklm3(ii1,ii2)=0;
                        for pp=1:2*p+1
                            for qq=1:2*q+1
                                if(delta(kk1,(pp-1-p)+kk2)&&delta(ll1,ll2+(qq-q-1))&&(pp~=2))
                                    hklm3(ii1,ii2)=hklm3(ii1,ii2)+solve_for_hklm_3_1(mm1-1,mm2-1,pp,qq,mt,wt,h,afaq,fiq,kq );
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
hklm3=-Ej*hklm3;
Hklm=Hklm+hklm3;
end

function [ Hklm_fiq ] = special_for_fiq_E_1_Hklm3(p,q,k,l,m,mt,wt,h,Hklm,Ej,afaq,fiq,kq )
%��H����fiq�仯�ĵ����ó�������
%   �˴���ʾ��ϸ˵��
ii1=0;
hklm3=zeros((2*k+1)*(2*l+1)*(m+1),(2*k+1)*(2*l+1)*(m+1));
for kk1=1:2*k+1
    for ll1=1:2*l+1
        for mm1=1:m+1
            ii1=ii1+1;
            ii2=0;
            for kk2=1:2*k+1
                for ll2=1:2*l+1
                    for mm2=1:m+1
                        ii2=ii2+1;           
                        hklm3(ii1,ii2)=0;
                        for pp=1:2*p+1
                            for qq=1:2*q+1
                                if(delta(kk1,(pp-1-p)+kk2)&&delta(ll1,ll2+(qq-q-1))&&(pp==2)&&(qq==1||qq==5))
                                    hklm3(ii1,ii2)=hklm3(ii1,ii2)+solve_for_hklm_3_1(mm1-1,mm2-1,pp,qq,mt,wt,h,afaq,fiq,kq );
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
hklm3=-Ej*hklm3;
Hklm_fiq=Hklm+hklm3;

end

function [ pesi_x,pesi_real_imag ] = wavefunction_xa_xs( pesi,n_vector,accuracy,level )

%����˵������������pesi����1�����㲨������2������������ģƽ����xa,xs�ı仯

%����˵��1��pesi��һ��ȷ���ܼ��Ĳ�������
%��"main_eigen_vector_for_certain_fiq"�����pesi����n_level���ܼ���
%�������������ʱҪ�������Ķ��ܼ�����pesi(:,:,n),n���ܼ����

%����˵��2��n_vector���ۼӵĲ�����������ֵԽ=�󣬲�����Լ׼ȷ��
%һ����pesi��n_vectorȡֵ��ͬ

%����˵��3��accuracy��ͼȡ�������������Ϲ�ȡ��accuracy+1��*��accuracy+1�������軭

%���˵��1��pesi_x���ڣ�xa,xs�������µĲ�������
%���˵��2��pesi_real_imag�Ǽ���ÿ��pesi_x����ʵ�ȣ��ô���̫��
global handles
xa = linspace(-2*pi,2*pi,accuracy+1);
xs = xa;
i=sqrt(-1);
pesi_x=zeros(accuracy+1,accuracy+1);
[xas,xss] = meshgrid(xa,xs);
for jj=1:n_vector
    pesi_x=pesi_x+1/(2*pi)*pesi(1,jj)*exp(-i*(pesi(2,jj).*xas+pesi(3,jj).*xss));
end
pesi_real_imag=real(pesi_x)./imag(pesi_x);
ax=axes('parent',uicontainer('parent',handles.container2));
mesh(xas,xss,abs(pesi_x)^2,'parent',ax);
%handles.titlecell2{1,level}=['�ܼ�' num2str(level)];
%mesh(xas,xss,abs(pesi_x)^2);
xlabel(ax,'xa');
ylabel(ax,'xs');
title(['�ܼ�' num2str(level)],'parent',ax);
end

function [ U_xa_xs,U_xt_xs ] = plot_U_x( afaq,bataq,kq,fiq,accuracy )
%������ͼ�����
global handles
xa=linspace(-2*pi,2*pi,accuracy+1);
xs=xa;
xt=linspace(-1,1,accuracy+1);

%��xt=0ƽ��U(xa,xs)ͼ��
[xas,xss] = meshgrid(xa,xs);
U_xa_xs=-((1+kq)*cos(xas-xss)+(1-kq)*cos(xas+xss)+afaq*cos(2*xss+fiq));
ax=axes('parent',uicontainer('parent',handles.container2));
mesh(xas,xss,U_xa_xs,'parent',ax);
xlabel('xa');
ylabel('xs');
title('U(xa,xs),xt=0');

%��xa=0ƽ��U(xt,xs)ͼ��
[xts,xss] = meshgrid(xt,xs);
U_xt_xs=-((1+kq)*cos(-xss-xts)+(1-kq)*cos(xss+xts)+afaq*cos(2*xss+fiq-xts/afaq))+(1+2*afaq)^2*(1-kq^2)/(2*afaq*bataq*(1+2*afaq-kq^2))*xts.*xts;
ax=axes('parent',uicontainer('parent',handles.container2));
mesh(xts,xss,U_xt_xs,'parent',ax);
xlabel('xt');
ylabel('xs');
title('U(xt,xs),xa=0');

end

