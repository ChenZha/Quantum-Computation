function ptr=CreatGUI(obj)
%{
%%
addpath('DAC');
addpath('mainfile');
%
addpath('qos')
import qes.*
import sqc.wv.*
import qes.util.*
import qes.hwdriver.sync.*
import data_taking.public.xmon.*
import qes.hwdriver.*
%%
%dpo70404c = tcpip('10.0.0.100', 5025);
dpo70404c =visa('agilent','TCPIP0::C500014-70KC::inst0::INSTR');
% fopen(dpo70404c);
osc = Oscilloscope.GetInstance('tekdpo7000',dpo70404c,'tekdpo7000');
%%
addpath('layout');
osc.CreatGUI
%%
%}
    %layout
    %addpath('layout')
    
    obj.uihandles.ptr=qes.pointer();
    ptr=obj.uihandles.ptr;
    obj.uihandles.add=0;
    obj.uihandles.hfig=figure('handlevisibility','callback','pos',[50,50,1000,550], 'Name', 'OSC','NumberTitle', 'off');
    %obj.uihandles.hfig=figure('pos',[50,50,1000,550], 'Name', 'OSC','MenuBar', 'none','Toolbar', 'none','NumberTitle', 'off' );
    mainlayout=uix.Grid('parent',obj.uihandles.hfig);
    axeslayout=uix.Grid('parent',mainlayout);
    osclayout=uix.Grid('parent',mainlayout,'padding',10);
    mainlayout.Heights=[-5 -0.5];

    %osclayout
    obj.uihandles.clearbutton=uicontrol('parent',osclayout,'string','clear');
    obj.uihandles.measures=zeros(1,8);
    for index2=1:8
        obj.uihandles.measures(index2)=uicontrol('parent',osclayout,'style','edit',...
                'string',['Measure' num2str(index2)],'tag',['Measure' num2str(index2)]);
    end
    obj.uihandles.numinputbox=uicontrol('parent',osclayout,'style','edit',...
                'string','1','tag','inputbox');
   
    obj.uihandles.addbutton=uicontrol('parent',osclayout,'string','add');
    osclayout.Widths=[-3,zeros(1,8)-2,-1,-3];
    
    %callback
    set(obj.uihandles.clearbutton,'callback',@(o,e)clearosc(obj,o,e));
    set(obj.uihandles.addbutton,'callback',@(o,e)addosc(obj,o,e));

    obj.uihandles.axes1layout=uix.TabPanel( 'Parent', axeslayout);

    
    
    obj.datasource='ch1,ch2,ch3,ch4';
    obj.datastop=obj.acqlength;
    
    obj.uihandles.add=1;
    plottick(obj,0,0);

    
    %%
    function plottick(obj,o,e)  %#ok<INUSD>
        %     osc.CreatGUI
        colc=[[0    0.4470    0.7410];[0.8500    0.3250    0.0980];[0.9290    0.6940    0.1250];[0.4940    0.1840    0.5560]];
        %
        num=get(obj.uihandles.numinputbox,'string');
        try
            num=ceil(str2double(num));
            if num<1 
                num=1;
            end
        catch ee %#ok<NASGU>
            num=1;
        end
        if num~=1
            oldmode=obj.acquisitionmode;
            oldnum=obj.acquisitionnumavg;
            obj.acquisitionnumavg=num;
            obj.acquisitionmode='AVE';
        end
        datas=GetoscMeasure(obj);
        try
            divs=obj.getdata();%wait trigger 120s
        catch ee
            divs=obj.getdatanow();
        end
        if num~=1
            obj.acquisitionnumavg=oldnum;
            obj.acquisitionmode=oldmode;
        end
        %
        divs=divs/32768*5;
        datas=datas;
        waves=divs;
        for index1=1:4
            POSition=str2double(query(obj.interfaceobj,['CH' num2str(index1) ':POSition?']));%0 V -> ? div
            SCALe=str2double(query(obj.interfaceobj,['CH' num2str(index1) ':SCALe?']));% 1 div=? V
            waves(:,index1)=(waves(:,index1)-POSition)*SCALe;
        end
        for index1=1:8
            set(obj.uihandles.measures(index1),'string',num2str(datas(index1)));
        end
        t=linspace(-datas(10)*datas(9)/100,(1-datas(10)/100)*datas(9),round(datas(11)));
        %
        if obj.uihandles.add
            obj.uihandles.add=0;
            tempvbox=uix.VBox('parent',obj.uihandles.axes1layout,'spacing',2);

            for index1 = 1:4
                aline=waves(:,index1);
                tempa=axes('Position',[0 0 1 1],'parent',uicontainer('parent',tempvbox));            
                plot(t,aline,'parent',tempa,'color',colc(index1,:));
                axis(tempa,'tight')
                line([0 0],get(tempa,'YLim'),'color','r','parent',tempa);
                grid(tempa,'on');
            end 
            tempvbox.Heights=[zeros(1,4)-1]; %#ok<NBRAK>
        end
        fPos=obj.uihandles.hfig.Position;
        obj.uihandles.hfig.Position=fPos+0.01;
        obj.uihandles.hfig.Position=fPos;
        clds=get(obj.uihandles.axes1layout,'children');
        obj.uihandles.axes1layout.Selection = numel(clds);
        
%         obj.uihandles.ptr.dataout=cell(1,3);
%         obj.uihandles.ptr.dataout{1}=t;
%         obj.uihandles.ptr.dataout{2}=waves;
%         obj.uihandles.ptr.dataout{3}=datas;
        obj.uihandles.ptr.t=t;
        obj.uihandles.ptr.waves=waves;
        obj.uihandles.ptr.datas=datas;
    end

    function clearosc(obj,o,e) %#ok<INUSD>
        for i = obj.uihandles.axes1layout.Children
            delete(i)
        end
    end

    function addosc(obj,o,e) %#ok<INUSD>

        obj.uihandles.add=1;
        plottick(obj,0,0);
    end



    function datas=GetoscMeasure(obj)
        %val = str2double(query(obj.interfaceobj,'MEASUrement:MEAS2:VALue?'));
        datas=zeros(11,1);
        for index1=1:8
            try
                datas(index1)=str2double(query(obj.interfaceobj,['MEASUrement:MEAS' num2str(index1) ':VALue?']));
                if datas(index1)>1e35
                    datas(index1)=0;
                end
            catch ee %#ok<NASGU>
                datas(index1)=0;
            end
        end
        datas(9)=obj.horizontalscale;
        datas(10)=obj.horizontalposition;
        datas(11)=obj.datastop;
        % t=linspace(-obj.osc.horizontalscale/100.0*obj.osc.horizontalscale,(1-obj.osc.horizontalscale/100.0)*obj.osc.horizontalscale,obj.osc.datastop)
        % t=linspace(-datas(10)*datas(9)/100,(1-datas(10)/100)*datas(9),datas(11))
    end
end